GPIOTRIAC = 2 
GPIOZC = 15
gpio.config({ gpio = { GPIOTRIAC }, dir = gpio.OUT })
gpio.config({ gpio = { GPIOZC }, dir = gpio.IN })
gpio.trig(GPIOZC, gpio.INTR_TRIAC)
gpio.set_triac_delay_pin(2500,GPIOTRIAC)
gpio.set_triac_delay_pin(8091,GPIOTRIAC)
