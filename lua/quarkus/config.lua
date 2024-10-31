---@class quarkus.Config
---@field ls_path? string The path to the language server jar path.
---@field jdtls_name string The name of the JDTLS language server. default: "jdtls"
---@field java_cmd? string The path to the java command.

---@type quarkus.Config
local M = {
  ls_path = nil,
  jdtls_name = "jdtls",
  java_cmd = nil,
}

---@param opts bootls.Config
---@diagnostic disable-next-line: inject-field
M._init = function(opts)
  M = vim.tbl_deep_extend("keep", opts, M)
end

return M
