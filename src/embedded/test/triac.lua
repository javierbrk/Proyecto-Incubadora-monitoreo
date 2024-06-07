GPIORESISTOR = 10
GPIOZC = 11


--local TRIAC_PULSE_MICROS = 30
local TRIAC_PULSE_MICROS = 1

local FADE_MAX = 9
local FADE_MIN = 2

local triacOn = false
local period = FADE_MIN -- microseconds cut out from AC pulse

local fadeAmount = 10


triac_poweron_tmr = tmr.create()
triac_poweroo_tmr:register(period, tmr.ALARM_SINGLE, triacPulse)

triac_poweroff_tmr = tmr.create()
triac_poweroff_tmr:register(TRIAC_PULSE_MICROS, tmr.ALARM_SINGLE, triacPulse)

fade_switch = tmr.create()
fade_switch:register(100000, tmr.ALARM_SINGLE, fade)
fade_switch:start()

function zeroCrossing() 
  triacOn = false --// triac tuns off self at zero crossing
  triac_poweroo_tmr:start()
end

function triacPulse() 
  if (triacOn) then --// stop pulse
    gpio.write(GPIORESISTOR, 0)
 else  --// start pulse
    gpio.write(GPIORESISTOR, 1)
    triacOn = true
    triac_poweroff_tmr:start()
end
end

function fade()
  period = period + fadeAmount
  if (period <= FADE_MIN or period >= FADE_MAX) then
    fadeAmount = -fadeAmount
  end
  triac_poweroo_tmr:register(period, tmr.ALARM_SINGLE, triacPulse)
end

gpio.trig(GPIOREEDS, gpio.INTR_HIGH, zeroCrossing)

