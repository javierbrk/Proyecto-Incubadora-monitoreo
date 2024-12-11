local log = require('log')
require("credentials")

------------------------------------------------------------------------------------
--
-- ! @module w
-- ! WiFi management module for ESP32
-- ! Handles both AP and Station mode configurations
--
------------------------------------------------------------------------------------

local w = {
    -- Configuration tables
    sta_cfg = {
        ip = '192.168.16.10',
        netmask = '255.255.255.0',
        gateway = '192.168.16.1',
        dns = '8.8.8.8'
    },
    ap_config = {
        ssid = "incubator",
        pwd = "12345678",
        auth = wifi.AUTH_WPA2_PSK
    },
    station_cfg = {
        ssid = "default_ssid",
        pwd = "default_pwd",
        scan_method = "all"
    },
    -- State management
    online = 0,
    connection_timeout = 10000, -- 10 seconds
    max_retries = 10,
    current_retry = 0,
    reconnect_timer = nil
}

------------------------------------------------------------------------------------
--
-- ! @function format_ip
-- ! Formats IP information for display
-- !
-- ! @param ip          table containing ip configuration
-- ! @return string     formatted IP information
--
------------------------------------------------------------------------------------
local function format_ip(ip)
    return string.format(
        "IP: %s\nNetmask: %s\nGateway: %s\nDNS: %s",
        ip.ip or "N/A",
        ip.netmask or "N/A",
        ip.gw or "N/A",
        w.sta_cfg.dns
    )
end

------------------------------------------------------------------------------------
--
-- ! @function set_new_ssid
-- ! Modifies the actual SSID WiFi configuration
-- !
-- ! @param new_ssid    string containing the new SSID
-- ! @return boolean    true if successful, false otherwise
--
------------------------------------------------------------------------------------
function w:set_new_ssid(new_ssid)
    if type(new_ssid) == "string" and new_ssid ~= "" then
        self.station_cfg.ssid = new_ssid
        return true
    end
    return false
end

------------------------------------------------------------------------------------
--
-- ! @function set_passwd
-- ! Modifies the actual WiFi password
-- !
-- ! @param new_passwd  string containing the new password
-- ! @return boolean    true if successful, false otherwise
--
------------------------------------------------------------------------------------
function w:set_passwd(new_passwd)
    if type(new_passwd) == "string" and new_passwd ~= "" then
        self.station_cfg.pwd = new_passwd
        return true
    end
    return false
end

------------------------------------------------------------------------------------
--
-- ! @function schedule_reconnect
-- ! Schedules a reconnection attempt using a timer
--
------------------------------------------------------------------------------------
function w:schedule_reconnect()
    if self.reconnect_timer then
        self.reconnect_timer:unregister()
    end
    
    self.reconnect_timer = tmr.create()
    self.reconnect_timer:register(self.connection_timeout, tmr.ALARM_SINGLE, function()
        self:connect()
    end)
    self.reconnect_timer:start()
end

------------------------------------------------------------------------------------
--
-- ! @function connect
-- ! Initiates WiFi connection with configured parameters
--
------------------------------------------------------------------------------------
function w:connect()
    wifi.sta.disconnect()
    wifi.sta.config(self.station_cfg, true)
    wifi.sta.connect()
end

------------------------------------------------------------------------------------
--
-- ! @function wifi_connect_event
-- ! Handles successful WiFi connection events
-- !
-- ! @param ev         event status
-- ! @param info       connection information
--
------------------------------------------------------------------------------------
local function wifi_connect_event(ev, info)
    w.current_retry = 0
    log.trace(string.format("Connection to AP %s established!", tostring(info.ssid)))
    log.trace("Waiting for IP address...")
end

------------------------------------------------------------------------------------
--
-- ! @function wifi_got_ip_event
-- ! Handles successful IP acquisition events
-- ! Configures NTP if not enabled
-- !
-- ! @param ev         event status
-- ! @param info       IP configuration information
--
------------------------------------------------------------------------------------
local function wifi_got_ip_event(ev, info)
    w.online = 1
    log.trace("Network Configuration:")
    log.trace(format_ip(info))
    
    -- Setup NTP if not enabled
    if not time.ntpenabled() then
        time.initntp("pool.ntp.org")
        if TIMEZONE then
            time.settimezone(TIMEZONE)
        end
    end
    
    log.trace("System is online and ready!")
end

------------------------------------------------------------------------------------
--
-- ! @function wifi_disconnect_event
-- ! Handles WiFi disconnection events
-- ! Manages reconnection attempts and fallback to previous credentials
-- !
-- ! @param ev         event status
-- ! @param info       disconnection information
--
------------------------------------------------------------------------------------
local function wifi_disconnect_event(ev, info)
    w.online = 0
    
    log.trace(string.format("WiFi disconnected from AP(%s). Reason: %s", 
        info.ssid or "unknown",
        info.reason or "unknown"))
    
    if w.current_retry < w.max_retries then
        w.current_retry = w.current_retry + 1
        log.trace(string.format("Attempting reconnection... (%d/%d)", 
            w.current_retry, 
            w.max_retries))
        w:schedule_reconnect()
    else
        if w.old_ssid and w.old_passwd then
            log.trace("Maximum retries reached. Attempting to connect with previous credentials...")
            w:set_new_ssid(w.old_ssid)
            w:set_passwd(w.old_passwd)
            w.old_ssid = nil
            w.old_passwd = nil
            w.current_retry = 0
            w:connect()
        else
            log.trace("Maximum retries reached. Please check WiFi configuration.")
        end
    end
end

------------------------------------------------------------------------------------
--
-- ! @function init
-- ! Initializes WiFi configuration and starts connection
-- ! Sets up event handlers and configures both AP and Station modes
--
------------------------------------------------------------------------------------
function w:init()
    -- Setup event handlers
    wifi.sta.on("got_ip", wifi_got_ip_event)
    wifi.sta.on("connected", wifi_connect_event)
    wifi.sta.on("disconnected", wifi_disconnect_event)
    
    -- Configure AP and Station mode
    wifi.mode(wifi.STATIONAP)
    wifi.ap.setip(self.sta_cfg)
    wifi.ap.config(self.ap_config, true)
    
    -- Setup AP connection handler
    wifi.ap.on("sta_connected", function(event, info)
        log.trace(string.format("Device connected to AP - MAC: %s, ID: %s", info.mac, info.id))
    end)
    
    -- Start WiFi
    wifi.start()
    
    -- Configure station
    if SSID and PASSWORD then
        self.station_cfg.ssid = SSID
        self.station_cfg.pwd = PASSWORD
    end
    
    if INICIALES then
        wifi.sta.sethostname(INICIALES .. "-ESP32")
    end
    
    self:connect()
end

------------------------------------------------------------------------------------
--
-- ! @function on_change
-- ! Handles WiFi configuration changes
-- ! Manages credential backup and updates
-- !
-- ! @param new_config_table    table containing new configuration
--
------------------------------------------------------------------------------------
function w:on_change(new_config_table)
    if type(new_config_table) ~= "table" then return end
    
    local config_changed = false
    
    if new_config_table.ssid and new_config_table.ssid ~= self.station_cfg.ssid then
        self.old_ssid = self.station_cfg.ssid
        self.old_passwd = self.station_cfg.pwd
        config_changed = self:set_new_ssid(new_config_table.ssid)
    end
    
    if new_config_table.passwd and new_config_table.passwd ~= self.station_cfg.pwd then
        if not self.old_ssid then
            self.old_ssid = self.station_cfg.ssid
            self.old_passwd = self.station_cfg.pwd
        end
        config_changed = self:set_passwd(new_config_table.passwd) or config_changed
    end
    
    if config_changed then
        self.current_retry = 0
        self:connect()
    end
end

-- Initialize the WiFi connection
w:init()

return w