-- SPDX-FileCopyrightText: 2025 info@altermundi.net
--
-- SPDX-License-Identifier: AGPL-3.0-only

gpio.config( { gpio={13}, dir=gpio.OUT })
gpio.set_drive(13, gpio.DRIVE_3)
--gpio.set_drive(12, gpio.DRIVE_3)
--gpio.write(12, 0)
gpio.write(13, 0)

--gpio.write(12, 1)
gpio.write(13, 1)
