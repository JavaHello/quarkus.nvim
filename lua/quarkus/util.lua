local M = {}

M.Windows = "Windows"
M.Linux = "Linux"
M.Mac = "Mac"

M.os_type = function()
  local has = vim.fn.has
  local t = M.Linux
  if has("win32") == 1 or has("win64") == 1 then
    t = M.Windows
  elseif has("mac") == 1 then
    t = M.Mac
  end
  return t
end

M.is_win = M.os_type() == M.Windows
M.is_linux = M.os_type() == M.Linux
M.is_mac = M.os_type() == M.Mac

M.java_bin = function()
  local java_home = vim.env["JAVA_HOME"]
  if java_home then
    return java_home .. "/bin/java"
  end
  return "java"
end

M.get_client = function(name)
  local clients = vim.lsp.get_clients({ name = name })
  if clients and #clients > 0 then
    return clients[1]
  end
  return nil
end

M.get_qute_ls_client = function()
  return M.get_client("qute_ls")
end
M.qute_execute_command = function(command, param, callback)
  local err, resp = M.execute_command(M.get_qute_ls_client(), command, param, callback)
  if err then
    print("Error executeCommand: " .. command .. "\n" .. vim.inspect(err))
  end
  return resp
end

M.execute_command = function(client, command, param, callback)
  local co
  if not callback then
    co = coroutine.running()
    if co then
      callback = function(err, resp)
        coroutine.resume(co, err, resp)
      end
    end
  end
  client.request("workspace/executeCommand", {
    command = command,
    arguments = param,
  }, callback, nil)
  if co then
    return coroutine.yield()
  end
end

M.is_application_yml_file = function(filename)
  return string.find(filename, ".*/src/main/resources/application.*%.ya?ml$") ~= nil
end

M.is_application_properties_file = function(filename)
  return string.find(filename, ".*/src/main/resources/application.*%.properties$") ~= nil
    or string.find(filename, ".*src/main/resources/META-INF/microprofile-config.properties$") ~= nil
end

return M
