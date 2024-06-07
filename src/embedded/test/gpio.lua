GPIORESISTOR = 10
GPIOZC = 11

gpio.config({ gpio = { GPIORESISTOR }, dir = gpio.OUT })
gpio.set_drive(GPIORESISTOR, gpio.DRIVE_3)
gpio.config({ gpio = { GPIOZC }, dir = gpio.INTR_UP })
define_zc_trigger()

function define_zc_trigger()
    gpio.trig(GPIOREEDS, gpio.INTR_LOW, zc_trigger)
    send_heap_uptime:register(3000, tmr.ALARM_SINGLE, define_zc_trigger_half)
    send_heap_uptime:start()
end

function define_zc_trigger_half()
    gpio.trig(GPIOREEDS, gpio.INTR_LOW, zc_trigger)
    send_heap_uptime:register(3000, tmr.ALARM_SINGLE, define_zc_trigger_third)
    send_heap_uptime:start()
end

function define_zc_trigger_third()
    gpio.trig(GPIOREEDS, gpio.INTR_LOW, zc_trigger)
    send_heap_uptime:register(3000, tmr.ALARM_SINGLE, define_zc_trigger)
    send_heap_uptime:start()
end

--[the same but using zc_trigger]
function zc_trigger(gpio, _)
    if M.resistor then
        gpio.write(GPIORESISTOR, 1)
    else
        gpio.write(GPIORESISTOR, 0)
    end
end

--[using half power]
function zc_trigger_half(gpio, _)
    if M.resistor then
        M.zc_counter = M.zc_counter ~ 1
        if (M.zc_counter) then
            gpio.write(GPIORESISTOR, 1)
        else
            gpio.write(GPIORESISTOR, 0)
        end
    else
        gpio.write(GPIORESISTOR, 0)
    end
end

function zc_trigger_third(gpio, _)
    if M.resistor then
        M.zc_counter = (M.zc_counter + 1) % 3
        if (M.zc_counter == 0) then
            gpio.write(GPIORESISTOR, 1)
        else
            gpio.write(GPIORESISTOR, 0)
        end
    else
        gpio.write(GPIORESISTOR, 0)
    end
end
