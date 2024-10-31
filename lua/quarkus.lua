vim.g.quarkus = {
  jdt_extensions_path = nil,
  jdt_extensions_jars = {
    "com.redhat.microprofile.jdt.quarkus.jar",
    "com.redhat.qute.jdt.jar",
  },
}

local M = {}

M.init_lsp_commands = function()
  local o, _ = pcall(require, "jdtls")
  if o then
    return
  end
  -- see  https://github.com/mfussenegger/nvim-jdtls/blob/29255ea26dfb51ef0213f7572bff410f1afb002d/lua/jdtls.lua#L819
  if not vim.lsp.handlers["workspace/executeClientCommand"] then
    vim.lsp.handlers["workspace/executeClientCommand"] = function(_, params, ctx) -- luacheck: ignore 122
      local client = vim.lsp.get_client_by_id(ctx.client_id) or {}
      local commands = client.commands or {}
      local global_commands = vim.lsp.commands
      local fn = commands[params.command] or global_commands[params.command]
      if fn then
        local ok, result = pcall(fn, params.arguments, ctx)
        if ok then
          return result
        else
          return vim.lsp.rpc_response_error(vim.lsp.protocol.ErrorCodes.InternalError, result)
        end
      else
        return vim.lsp.rpc_response_error(
          vim.lsp.protocol.ErrorCodes.MethodNotFound,
          "Command " .. params.command .. " not supported on client"
        )
      end
    end
  end
end

M.addMicroprofileJar = function(jar)
  local ok, microprofile = pcall(require, "microprofile")
  if ok then
    local microprofile_path = jar
      or require("quarkus.vscode").find_one("/redhat.vscode-quarkus-*/server/com.redhat.quarkus.ls.jar")
    if microprofile_path then
      microprofile.addMicroprofileJar(microprofile_path)
    end
  end
end

M.setup = function(opts)
  require("quarkus.config")._init(opts)
  M.addMicroprofileJar()
end

M.java_extensions = function()
  local bundles = {}
  local function bundle_jar(path)
    for _, jar in ipairs(vim.g.quarkus.jdt_extensions_jars) do
      if vim.endswith(path, jar) then
        return true
      end
    end
  end
  local quarkus_path = vim.g.quarkus.jdt_extensions_path
    or require("quarkus.vscode").find_one("/redhat.vscode-quarkus-*/jars")
  if quarkus_path then
    for _, bundle in ipairs(vim.split(vim.fn.glob(quarkus_path .. "/*.jar"), "\n")) do
      if bundle_jar(bundle) then
        table.insert(bundles, bundle)
      end
    end
  end
  return bundles
end

return M
