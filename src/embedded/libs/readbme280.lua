-- SPDX-FileCopyrightText: 2025 info@altermundi.net
--
-- SPDX-License-Identifier: AGPL-3.0-only

sensor=require('bme280')
if sensor.init(14,15,true) then -- volatile module
  print (sensor.read()) -- default sampling
end

