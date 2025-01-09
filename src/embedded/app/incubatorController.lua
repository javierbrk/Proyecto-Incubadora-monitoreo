---@diagnostic disable: lowercase-global

-----------------------------------------------------------------------------
--  This is the reference implementation to train lua fucntions. It
--  implements part of the core functionality and has some incomplete comments.
--
--  javier jorge
--
--  License:
-----------------------------------------------------------------------------
require("credentials")
require("SendToGrafana")
alerts = require("alerts")
incubator = require("incubator")
apiserver = require("restapi")
deque = require ('deque')
log = require ('log')
configurator = require('configurator')


--log.level = "debug"
--log.usecolor=false


--holds the last 10 values
local last_temps_queue = deque.new()

controlervars = {
    rotation_enabled=true,
    rotation_activated = false,
    downtime = 0,
    uptime = 0,
    demora = 0,
    half = 0
}
-----------------------------------------------------------------------------------
-- ! @function is_temp_changing 	     verifies if temperature is changing
-- ! @param temperature						 actual temperature
------------------------------------------------------------------------------------
function is_temp_changing(temperature)
    last_temps_queue:push_right(temperature)
    if last_temps_queue:length() < 10 then
        ---les than 9 elements in the queue
        return true
    end
    if last_temps_queue:length() > 10 then
        -- remove one item
        last_temps_queue:pop_left()
    end
    local vant = nil

    for i, v in ipairs(last_temps_queue:contents()) do
        log.trace("[T] val:", i, v, vant)
        if vant ~= nil and vant ~= v then
            --everything is fine...
            return true
        end
        vant = v
    end
    --temp is not changin
    return false
end

-----------------------------------------------------------------------------------
-- ! @function temp_control 	     handles temperature control
-- ! @param temperature						 overall temperature
-- ! @param min_temp 							 temperature at which the resistor turns on
-- ! @param,max_temp 							 temperature at which the resistor turns off
------------------------------------------------------------------------------------
function temp_control(temperature, min_temp, max_temp)
    log.trace("[T] temp " .. temperature .. " min:" .. min_temp .. " max:" .. max_temp)

    if temperature <= min_temp then
        if is_temp_changing(temperature) then
            log.trace("[T] temperature is changing")
            log.trace("[T] turn resistor on")
            incubator.heater(true)
        else
            log.error("[T] temperature is not changing")
            alerts.send_alert_to_grafana("temperature is not changing")
            log.trace("[T] turn resistor off")
            incubator.heater(false)
        end
    elseif temperature >= max_temp then
        incubator.heater(false)
        log.trace("[T] turn resistor off")
    end -- end if
end     -- end function

function hum_control(hum, min, max)
    log.trace("[H] Humydity " .. hum .. " min:" .. min .. " max:" .. max .. " humidifier " .. tostring(incubator.humidifier))
    if hum <= min then
        log.trace("[H] turn hum on")
        incubator.humidifier_switch(true)
    elseif hum >= max then
        log.trace("[H] turn hum off")
        incubator.humidifier_switch(false)
    else
        log.trace("[H] volver a llamar")
        incubator.humidifier_switch(incubator.humidifier)
    end -- end if
end     -- end function

function read_and_control()
    temp, hum, pres = incubator.get_values()
    log.trace("[C]  t:" .. temp .. " h:" .. hum .. " p:" .. pres)
    hum_control(hum, incubator.min_hum, incubator.max_hum)
    temp_control(temp, incubator.min_temp, incubator.max_temp)
end -- end function

------------------------------------------------------------------------------------
-- ! @function read_and_send_data           is in charge of calling the read and  data sending
-- !                                        functions
------------------------------------------------------------------------------------
function read_and_send_data()
    temp, hum, pres = incubator.get_values()
    send_data_grafana(incubator.temperature, incubator.humidity, incubator.pressure, INICIALES .. "-bme")
end -- read_and_send_data end

------------------------------------------------------------------------------------
-- ! @function stop_rot                     is responsible for turning off the rotation
------------------------------------------------------------------------------------
function stop_rot()
    incubator.rotation_switch(false)
    if incubator.rotation_activated == true then
        log.trace("[R] rotation working :)")
    else
        log.error("[R] rotation error ----- sensors not activated after rotation")
        incubator.rotation_enabled = false
        --send_alert_to_grafana
    end
end

------------------------------------------------------------------------------------
-- ! @function trigger                    is responsible for checking the proper functioning of the rotation
--! @param pin                            number of pin to watch
------------------------------------------------------------------------------------

function trigger_rotation_off(pin, level)
    if(level==0) then
        if gpio.read(pin) == 1 then
            log.trace("[R] ruidoooo ")
            --this function is activated when signal is going down ... it should be 0
            return
        else
            gpio.trig(pin, gpio.INTR_DISABLE)
            incubator.rotation_activated = true
            log.trace("[R]  rotation working pin activated ", pin, level)
            incubator.rotation_switch(false)

            if pin == GPIOREEDS_UP then
                log.trace("[R]  GPIOREEDS_UP ", pin, level)

                --estoy arriba
                if controlervars.demora > 0 then
                    controlervars.uptime = node.uptime() / 1000000 - controlervars.demora
                    log.trace("GPIOREEDS_UP controled vars------------", controlervars.downtime, " ",
                        controlervars.uptime, " ", controlervars.demora)
                else
                    log.trace("GPIOREEDS_UP controled vars------------", controlervars.demora)
                end
            elseif pin == GPIOREEDS_DOWN then
                log.trace("[R]  GPIOREEDS_DOWN ", pin, level)
                if controlervars.demora > 0 then
                    controlervars.downtime = node.uptime() / 1000000 - controlervars.demora
                    log.trace("GPIOREEDS_DOWN controled vars------------", controlervars.downtime, " ",
                        controlervars.uptime, " ", controlervars.demora)
                else
                    log.trace("GPIOREEDS_UP controled vars------------", controlervars.demora)
                end
            else
                controlervars.rotation_enabled = false
                log.error("[R] rotation disabed, sensors are not working")
            end
        end
    end
end

------------------------------------------------------------------------------------
-- ! @function enable rotation will be trigered when a switch is deactivated
------------------------------------------------------------------------------------
function enable_rotation(pin, level)
    if (level == 1) then
        if gpio.read(pin) == 0 then
            log.trace("[R] noise, not able to enable rotation ")
            --this function is activated when signal is going up ... it should be 1
            return
        else
            gpio.trig(pin, gpio.INTR_DISABLE)
            log.trace("[R] rotation working rotation is active thanks to pin ", pin," level ", level)
            incubator.rotation_enabled = true
        end
    end
end

function abortrotation_and_notify()
    if incubator.rotation_enabled then
        return
    else
        log.error("[R] Fatalllllllllll rotation not working pin not de activated pin DOWN ",
        gpio.read(GPIOREEDS_DOWN), ",UP ", gpio.read(GPIOREEDS_UP))
        incubator.rotation_switch(false)
    end
end

------------------------------------------------------------------------------------
-- ! @function rotate                     is responsible for starting the rotation
------------------------------------------------------------------------------------
function rotate()
    log.trace("[R] rotation-------------------------------")
    if incubator.rotation_enabled then
        --will be activated when switch goes down
        incubator.rotation_activated = false


        gpio.trig(GPIOREEDS_DOWN, gpio.INTR_DISABLE)
        gpio.trig(GPIOREEDS_UP, gpio.INTR_DISABLE)
        -- only subscribe to the interrupts if state is up
        -- Check if both pins are in the "up" state (assuming 1 is "up")
        if gpio.read(GPIOREEDS_UP) == 1 then
            -- Subscribe to interrupts, it will go down when sensor is activated
            gpio.trig(GPIOREEDS_UP, gpio.INTR_DOWN, trigger_rotation_off)
        else
            --if switch is down it shuld quickly go up ... if not disable rotation and notify
            incubator.rotation_enabled = false
            gpio.trig(GPIOREEDS_UP, gpio.INTR_UP, enable_rotation)
        end

        if gpio.read(GPIOREEDS_DOWN) == 1 then
            gpio.trig(GPIOREEDS_DOWN, gpio.INTR_DOWN, trigger_rotation_off)
        else
            --if switch is down it shuld quickly go up ... if not disable rotation and notify
            incubator.rotation_enabled = false
            gpio.trig(GPIOREEDS_DOWN, gpio.INTR_UP, enable_rotation)
        end
        if gpio.read(GPIOREEDS_DOWN) == 0 or gpio.read(GPIOREEDS_UP) == 0 then
          

        --this timers are registered only once, so any change will be reflected after reset
            abortrotation:register(incubator.rotation_switch_deactivate_time, tmr.ALARM_SINGLE, abortrotation_and_notify) 
            abortrotation:start()
        end


        incubator.rotation_switch(true)
        log.trace("[R] turn rotation on-------------------------------")
        stoprotation:register(incubator.rotation_duration, tmr.ALARM_SINGLE, stop_rot)

        -- wait a reasonable ammount of time, but just in case, if everything fails, stop rotation
        stoprotation:start()
    else
        log.error("[R] rotation disabled, sensors are not working")
    end
end


------------------------------------------------------------------------------------
-- ! timers
------------------------------------------------------------------------------------

rotate_half_timer = tmr.create()
stoprotation = tmr.create()
abortrotation = tmr.create()

local send_data_timer = tmr.create()
send_data_timer:register(10000, tmr.ALARM_AUTO, read_and_send_data)
-- send_data_timer:start()

temp_control_timer = tmr.create()
temp_control_timer:register(3000, tmr.ALARM_AUTO, read_and_control)
-- temp_control_timer:start()

rotation = tmr.create()
rotation:register(incubator.rotation_period, tmr.ALARM_AUTO, rotate)
-- rotation:start()

-- local send_heap_uptime = tmr.create()
-- send_heap_uptime:register(30000, tmr.ALARM_AUTO, send_heap_and_uptime_grafana)
-- send_heap_uptime:start()

--timer que rota dos veces y luego hasta la mitad
function rotateandgettimes()
    controlervars.demora = node.uptime() / 1000000
    if (controlervars.downtime > 0 and controlervars.uptime == 0) then
        log.trace("[R] ----------primero downtime  ", controlervars.downtime)
        if math.floor(controlervars.downtime / 2) > 1 then
            controlervars.half = math.floor(controlervars.downtime / 2) * 1000
        else
            controlervars.half = 3 * 1000
        end
    elseif (controlervars.downtime == 0 and controlervars.uptime > 0) then
        log.trace("[R] ------------primero uptime  ", controlervars.uptime)
        if math.floor(controlervars.uptime / 2) > 1 then
            controlervars.half = math.floor(controlervars.uptime / 2) * 1000
        else
            controlervars.half = 3 * 1000
        end
    end
    if (controlervars.downtime > 0 and controlervars.uptime > 0) then
        rotateandgettimes_timer:unregister()
        incubator.rotation_duration = math.max(controlervars.downtime,controlervars.uptime)*1000 + 1000 
        log.trace("[R] Seting rotation duration to    ",  incubator.rotation_duration )
        rotate_half_timer:register(controlervars.half, tmr.ALARM_SINGLE, function()
            incubator.rotation_switch(false)
            log.trace("[R] Finished rotating half for ...   ", controlervars.half)
            log.trace("[R] Rotation is working ... starting with the rest ", controlervars.half)
            rotation:start()
            temp_control_timer:start()
            send_data_timer:start()
        end)
        incubator.rotation_switch(true)
        log.trace("[R] rotating half for ...   ", controlervars.half)
        rotate_half_timer:start()
    else
        log.trace("[R] turn rotation on again ------------", controlervars.downtime, " ", controlervars.uptime, " ",
            controlervars.demora)
        rotate()
    end
end

------------------------------------------------------------------------------------
-- ! @function incubator.init_values           start incubator values
-- ! @function incubator.init_module           start the incubator modules
-- ! @function incubator.init_testing          set test mode

-- ! @param incubator
------------------------------------------------------------------------------------

incubator.init_values()
configurator.init_module(incubator)

if gpio.read(GPIOREEDS_UP) == 1 and gpio.read(GPIOREEDS_DOWN) == 1 then
    --encontrar un sensor
    log.trace("[R] turn rotation on first time ")
    rotate()
else
    log.trace("[R] at least one sensor is active not activating rotation")
end
--medir tiempos y dejar en la mitad
rotateandgettimes_timer = tmr.create()
rotateandgettimes_timer:register(incubator.rotation_duration+1000, tmr.ALARM_AUTO, rotateandgettimes)
rotateandgettimes_timer:start()






-- apiserver.init_module(incubator, configurator)
-- incubator.enable_testing(false)

------------------------------------------------------------------------------------
-- ! timers
------------------------------------------------------------------------------------


stoprotation = tmr.create()
abortrotation = tmr.create()

local send_data_timer = tmr.create()
send_data_timer:register(10000, tmr.ALARM_AUTO, read_and_send_data)
-- send_data_timer:start()

temp_control_timer = tmr.create()
temp_control_timer:register(3000, tmr.ALARM_AUTO, read_and_control)
-- temp_control_timer:start()

rotation = tmr.create()
rotation:register(incubator.rotation_period, tmr.ALARM_AUTO, rotate)
-- rotation:start()

-- local send_heap_uptime = tmr.create()
-- send_heap_uptime:register(30000, tmr.ALARM_AUTO, send_heap_and_uptime_grafana)
-- send_heap_uptime:start()
