---@class quarkus.Config
---@field ls_path? string The path to the language server jar path.
---@field jdtls_name string The name of the JDTLS language server. default: "jdtls"
---@field java_bin? string The path to the java command.
---@field jdt_extensions_path? string The path to the JDT extensions.
---@field jdt_extensions_jars string[] The list of JDT extensions jars.
---@field microprofile_ext_path? string[] The path to the microprofile jars.

---@type quarkus.Config
local M = {
  ls_path = nil,
  jdtls_name = "jdtls",
  java_bin = nil,
  jdt_extensions_path = nil,
  jdt_extensions_jars = {
    "com.redhat.microprofile.jdt.quarkus.jar",
    "com.redhat.qute.jdt.jar",
  },
  microprofile_ext_path = nil,
}

---@param opts quarkus.Config
---@diagnostic disable-next-line: inject-field
M._init = function(opts)
  M.ls_path = opts.ls_path or M.ls_path
  M.java_bin = opts.java_bin or M.java_bin
  M.jdt_extensions_path = opts.jdt_extensions_path or M.jdt_extensions_path
  M.microprofile_ext_path = opts.microprofile_ext_path or M.microprofile_ext_path
end

return M
