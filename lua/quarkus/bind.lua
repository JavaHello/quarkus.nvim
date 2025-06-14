local M = {}
local jdtls = require("quarkus.jdtls")
local util = require("quarkus.util")

local bind_qute_request = function(client, command)
  client.handlers[command] = function(_, result)
    return jdtls.execute_command(command, result)
  end
end

M._bind = false
M._bind_count = 0

local function defer_bind(ms)
  if M._bind_count > 10 then
    vim.notify("Failed to bind qute requests", vim.log.levels.ERROR)
    return
  end
  M._bind_count = M._bind_count + 1
  vim.defer_fn(function()
    M.try_bind_qute_all_request()
  end, ms)
end
M.try_bind_qute_all_request = function()
  if M._bind then
    return
  end

  local client = util.get_qute_ls_client()
  if client == nil then
    defer_bind(500)
    return
  end
  M.bind_qute_all_request(client)
  M._bind = true
end

M.bind_qute_all_request = function(client)
  bind_qute_request(client, "qute/template/project")
  bind_qute_request(client, "qute/template/projectDataModel")
  bind_qute_request(client, "qute/template/userTags")
  bind_qute_request(client, "qute/template/javaTypes")
  bind_qute_request(client, "qute/template/resolvedJavaType")
  bind_qute_request(client, "qute/template/javaDefinition")
  bind_qute_request(client, "qute/template/javadoc")
  bind_qute_request(client, "qute/template/generateMissingJavaMember")
  bind_qute_request(client, "qute/java/codeLens")
  bind_qute_request(client, "qute/java/diagnostics")
  bind_qute_request(client, "qute/java/documentLink")
end

return M
