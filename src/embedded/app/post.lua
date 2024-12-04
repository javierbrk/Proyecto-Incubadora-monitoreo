local startup_test = {
    results = {},
    timeouts = {
        temperature_change = 60000, -- 60 segundos para detectar cambio de temperatura
        humidity_change = 30000,    -- 30 segundos para detectar cambio de humedad
        rotation_test = 60000,      -- 10 segundos para completar test de rotación
    }
}

-- Función auxiliar para registrar resultados
function startup_test.log_result(test_name, success, message)
    startup_test.results[test_name] = {
        success = success,
        message = message,
        timestamp = time.get()
    }
    log.trace(string.format("[TEST] %s: %s - %s", 
        test_name, 
        success and "PASS" or "FAIL", 
        message))
    if success == "FAIL" then
        log.error(string.format("[TEST] %s: %s - %s", 
        test_name, 
        success and "PASS" or "FAIL", 
        message))
    end
end

-- Test de sensores BME280
function startup_test.test_sensors()
    local temp, hum, pres = incubator.get_values()
    
    -- Verifica que los valores sean razonables
    local valid_temp = temp ~= 99.9 and temp > -40 and temp < 86
    local valid_hum = hum ~= 99.9 and hum >= 0 and hum <= 100
    local valid_pres = pres ~= 99.9 and pres > 800 and pres < 1100

    startup_test.log_result("sensors", 
        valid_temp and valid_hum and valid_pres,
        string.format("T:%.1f°C H:%.1f%% P:%.1fhPa", temp, hum, pres))
end

-- Test de calentamiento
function startup_test.test_heater()
    local initial_temp
    local temp_changed = false
    local test_complete = false
    
    -- Función para verificar cambio de temperatura
    local function check_temp_change()
        local current_temp = incubator.get_values()
        if not initial_temp then
            initial_temp = current_temp
            -- Activar resistencia
            incubator.heater(true)
            return
        end
        
        if current_temp > initial_temp + 3 then -- Detecta cambio de 3°C
            temp_changed = true
            test_complete = true
            -- Desactivar resistencia
            incubator.heater(false)
            startup_test.log_result("heater", true,
                string.format("Temperature increased from %.1f°C to %.1f°C", 
                initial_temp, current_temp))
        end
    end
    
    -- Timer para el test
    local heater_timer = tmr.create()
    heater_timer:register(2000, tmr.ALARM_AUTO, 
    function()
        if test_complete then
            heater_timer:unregister()
            if not temp_changed then
                startup_test.log_result("heater", false,
                    "No temperature change detected after timeout")
            end
        else
            check_temp_change()
        end
    end)
    heater_timer:start()
end

-- Test de humidificador
function startup_test.test_humidifier()
    local initial_hum
    local hum_changed = false
    local test_complete = false
    
    -- Función para verificar cambio de humedad
    local function check_humidity_change()
        local _, current_hum = incubator.get_values()
        if not initial_hum then
            initial_hum = current_hum
            -- Activar humidificador
            incubator.humidifier_switch(true)
            return
        end
        
        if current_hum > initial_hum + 5 then -- Detecta cambio de 2%
            hum_changed = true
            test_complete = true
            -- Desactivar humidificador
            incubator.humidifier_switch(false)
            startup_test.log_result("humidifier", true,
                string.format("Humidity increased from %.1f%% to %.1f%%", 
                initial_hum, current_hum))
        end
    end
    
    -- Timer para el test
    local humidifier_timer = tmr.create()
    humidifier_timer:register(2000, tmr.ALARM_AUTO, function()
        if test_complete then
            humidifier_timer:unregister()
            if not hum_changed then
                startup_test.log_result("humidifier", false,
                    "No humidity change detected after timeout")
            end
        else
            check_humidity_change()
        end
    end)
    humidifier_timer:start()
end

-- Test de rotación
function startup_test.test_rotation()
    local rotation_complete = false
    local sensors_activated = {
        up = false,
        down = false
    }
        -- Función para verificar si la rotación se completó
    local function check_rotation_complete()
        if sensors_activated.up and sensors_activated.down then
            rotation_complete = true
            -- Desactivar interrupciones
            gpio.trig(GPIOREEDS_UP, gpio.INTR_DISABLE)
            gpio.trig(GPIOREEDS_DOWN, gpio.INTR_DISABLE)
        end
    end
    
        
    -- Configurar interrupciones para los sensores reed
    gpio.trig(GPIOREEDS_UP, gpio.INTR_DOWN, function()
        if(rotation_start_time == 0) then
            rotation_start_time=time.get()
            log.trace("midiendo tiempo de arriba")

            rotate()
        else
            sensors_activated.up = true
            incubator.uptitme = time.get()-rotation_start_time
            log.trace("tiempo en subir " ,  incubator.uptitme)

            check_rotation_complete()
            
            rotation_start_time=time.get()
            rotate()
        end
        

    end)
    
    gpio.trig(GPIOREEDS_DOWN, gpio.INTR_DOWN, function()
        log.trace("rotate activo de abajo ")

        if(rotation_start_time == 0) then
            rotation_start_time=time.get()
            log.trace("midiendo tiempo de abajo")

        else
            sensors_activated.down = true
            incubator.downtime= time.get()-rotation_start_time
            log.trace("tiempo en bajar " ,  incubator.downtime)
            check_rotation_complete()

            rotation_start_time=time.get()
            rotate()
        end

    end)
    

    rotation_start_time=0
    -- Iniciar rotación
    rotate()
    log.trace("rotate inicial")
    -- Timer para timeout
    local rotation_timer = tmr.create()
    rotation_timer:register(startup_test.timeouts.rotation_test, tmr.ALARM_SINGLE, function()
        if not rotation_complete then
            startup_test.log_result("rotation", false,
                string.format("Rotation incomplete: UP= ",sensors_activated.up," DOWN= ", sensors_activated.down))
            -- Detener rotación y limpiar
            else
                startup_test.log_result("rotation", true,
                "Rotation cycle completed successfully")
        end
    end)
    rotation_timer:start()
end

-- -- Test de conectividad WiFi
-- function startup_test.test_wifi()
--     local wifi_connected = false
--     local timeout = 30000 -- 30 segundos
    
--     -- Timer para verificar conexión
--     local wifi_timer = tmr.create()
--     wifi_timer:register(1000, tmr.ALARM_AUTO, function()
--         if configurator.WiFi.ONLINE == 1 then
--             wifi_connected = true
--             wifi_timer:unregister()
--             startup_test.log_result("wifi", true, "Connected to WiFi network")
--         end
--     end)
    
--     -- Timer para timeout
--     local timeout_timer = tmr.create()
--     timeout_timer:register(timeout, tmr.ALARM_SINGLE, function()
--         if not wifi_connected then
--             wifi_timer:unregister()
--             startup_test.log_result("wifi", false, "Failed to connect to WiFi")
--         end
--     end)
    
--     wifi_timer:start()
--     timeout_timer:start()
-- end

-- Ejecutar todos los tests
function startup_test.run_all()
    log.trace("[TEST] Starting system tests...")
    
    -- Ejecutar tests en secuencia
    startup_test.test_sensors()
--    startup_test.test_wifi()
    startup_test.test_heater()
    startup_test.test_humidifier()
end
log.trace("[TEST] Startig")
startup_test.run_all()
