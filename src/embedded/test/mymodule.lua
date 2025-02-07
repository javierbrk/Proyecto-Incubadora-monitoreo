-- SPDX-FileCopyrightText: 2025 info@altermundi.net
--
-- SPDX-License-Identifier: AGPL-3.0-only

-- this file is only requiered for testing examples 
local mymodule = {}

function mymodule.foo()
    print("Hello World!")
end

function mymodule.greet(text)
    print("original greet fucntion called whith " .. text)
end

return mymodule