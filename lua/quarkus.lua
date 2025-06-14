local M = {}

M.addMicroprofileJar = function(jar)
  local ok, microprofile = pcall(require, "microprofile")
  if ok then
    local microprofile_path
    if jar then
      if vim.endswith(jar, ".jar") then
        microprofile_path = jar
      else
        local microprofile_jar = vim.fn.glob(jar .. "/com.redhat.quarkus.ls.jar")
        if microprofile_jar ~= "" then
          microprofile_path = microprofile_jar
        else
          vim.notify("No MicroProfile JAR found in " .. jar, vim.log.levels.WARN)
        end
      end
    else
      microprofile_path =
        require("quarkus.vscode").find_one("/redhat.vscode-quarkus-*/server/com.redhat.quarkus.ls.jar")
    end
    if microprofile_path then
      microprofile.addMicroprofileJar(microprofile_path)
    end
  end
end

---@param opts quarkus.Config
M.setup = function(opts)
  require("quarkus.config")._init(opts)
  M.addMicroprofileJar(opts.microprofile_ext_path)
end

M.java_extensions = function()
  local bundles = {}
  local config = require("quarkus.config")
  local function bundle_jar(path)
    for _, jar in ipairs(config.jdt_extensions_jars) do
      if vim.endswith(path, jar) then
        return true
      end
    end
  end
  local quarkus_path = config.jdt_extensions_path or require("quarkus.vscode").find_one("/redhat.vscode-quarkus-*/jars")
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
