-- SPDX-FileCopyrightText: 2025 info@altermundi.net
--
-- SPDX-License-Identifier: AGPL-3.0-only

local config = require("lapis.config")

config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1"
})
