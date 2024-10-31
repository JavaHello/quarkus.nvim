local M = {}
local config = require("quarkus.config")
local util = require("quarkus.util")
M._co = {}
M.get_jdtls_client = function()
  return util.get_client(config.jdtls_name)
end

M.wait_service_ready = function(cbfn)
  if M._server_ready then
    return cbfn()
  end
  local pco = coroutine.running()
  local co = coroutine.create(function()
    local resp = cbfn()
    coroutine.resume(pco, resp)
    return resp
  end)
  table.insert(M._co, co)
  return coroutine.yield()
end

M.execute_command = function(command, param)
  return M.wait_service_ready(function()
    local err, resp = util.execute_command(M.get_jdtls_client(), command, param)
    if err then
      print("Error executeCommand: " .. command .. "\n" .. vim.inspect(err))
    end
    return resp
  end)
end

local handle_service_ready = function(err, msg)
  if "ServiceReady" == msg.type then
    M._server_ready = true
    for _, co in ipairs(M._co) do
      coroutine.resume(co)
    end
    M._co = {}
  end
end

local function defer_init(ms)
  vim.defer_fn(function()
    M.init_config()
  end, ms)
end

function M.init_config()
  if M._init then
    return
  end
  local client = M.get_jdtls_client()
  if client == nil then
    defer_init(100)
    return
  end
  M._init = true
  if client.config.handlers["language/status"] then
    local old_handler = client.config.handlers["language/status"]
    client.config.handlers["language/status"] = function(...)
      old_handler(...)
      handle_service_ready(...)
    end
  else
    client.config.handlers["language/status"] = M.handle_service_ready
  end
end

return M
