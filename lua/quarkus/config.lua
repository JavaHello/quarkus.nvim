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
  M = vim.tbl_deep_extend("keep", opts, M)
end

return M
