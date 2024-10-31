local M = {}
local jdtls = require("quarkus.jdtls")

local bind_qute_request = function(client, command)
  client.handlers[command] = function(_, result)
    return jdtls.execute_command(command, result)
  end
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
