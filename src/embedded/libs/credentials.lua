-- This file is only a placeholder.
-- Put your credentials here, and 
-- rename the file to remove the underscore.
SSID = "INTI"
PASSWORD = ""
TIMEZONE = "UTC+3"

IP_ADDR = ""         -- static IP
NETMASK = ""   -- your subnet
GATEWAY = ""     -- your gateway
--16mb board
GPIOBMESDA = 21
GPIOBMESCL = 22

--inputs
GPIOREEDS_UP = 5
GPIOREEDS_DOWN = 18
--old board
--GPIOBMESDA = 16
--GPIOBMESCL = 0

--outputs
GPIORESISTOR=26
GPIOHUMID = 33

GPIOVOLTEO_UP = 14
GPIOVOLTEO_DOWN = 27
GPIOVOLTEO_EN = 35

INICIALES = "JJ-RIO4"
SERVER="http://grafana.altermundi.net:8086/write?db=cto"

--critical configurations resitor must be turned off
gpio.config( { gpio={GPIORESISTOR}, dir=gpio.OUT })
gpio.set_drive(GPIORESISTOR, gpio.DRIVE_3)
gpio.write(GPIORESISTOR, 0)
