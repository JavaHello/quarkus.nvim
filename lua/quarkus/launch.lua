local M = {}
local config = require("quarkus.config")
local vscode = require("quarkus.vscode")
local util = require("quarkus.util")

local root_dir = function()
  return vim.loop.cwd()
end

local qutels_path = function()
  if config.ls_path then
    return config.ls_path
  end
  return vscode.find_one("/redhat.vscode-quarkus-*/server")
end

local function qute_ls_cmd(java_cmd)
  local qute_ls_path = qutels_path()
  if not qute_ls_path then
    vim.notify("Qute LS is not installed", vim.log.levels.WARN)
    return
  end
  local boot_classpath = {}
  table.insert(boot_classpath, qute_ls_path .. "/com.redhat.qute.ls-uber.jar")

  local cmd = {
    java_cmd or util.java_bin(),
    "-XX:TieredStopAtLevel=1",
    "-Xmx1G",
    "-XX:+UseZGC",
    "-cp",
    table.concat(boot_classpath, util.is_win and ";" or ":"),
    "com.redhat.qute.ls.QuteServerLauncher",
  }

  return cmd
end

local ls_config = {
  name = "qute_ls",
  filetypes = { "java", "yaml", "jproperties", "html" },
  init_options = {},
  settings = {
    qute_ls = {
      validation = { enabled = true },
    },
  },
  handlers = {},
  commands = {},
  get_language_id = function(bufnr, filetype)
    if filetype == "yaml" then
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if util.is_application_yml_file(filename) then
        return "qute-yaml"
      end
    elseif filetype == "jproperties" then
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if util.is_application_properties_file(filename) then
        return "quarkus-properties"
      end
    elseif filetype == "html" then
      return "qute-html"
    end
    return filetype
  end,
}

---@param opts table<string, any>
M.setup = function(opts)
  ls_config = vim.tbl_deep_extend("keep", ls_config, opts)
  local capabilities = ls_config.capabilities or vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("keep", capabilities, {
    commands = {
      commandsKind = {
        valueSet = {
          "qute.command.open.uri",
          "qute.command.java.definition",
          "qute.command.configuration.update",
          "qute.command.show.references",
        },
      },
    },
  })
  ls_config.capabilities = capabilities
  if not ls_config.root_dir then
    ls_config.root_dir = root_dir()
  end
  ls_config.cmd = (ls_config.cmd and #ls_config.cmd > 0) and ls_config.cmd or qute_ls_cmd(config.java_bin)
  if not ls_config.cmd then
    return
  end
  ls_config.init_options.workspaceFolders = ls_config.root_dir
  local group = vim.api.nvim_create_augroup("qute_ls", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    group = group,
    pattern = { "java", "yaml", "jproperties", "html" },
    desc = "Qute Language Server",
    callback = function(e)
      if e.file == "java" and vim.bo[e.buf].buftype == "nofile" then
        return
      end
      if vim.endswith(e.file, ".yaml") or vim.endswith(e.file, ".yml") then
        if not util.is_application_yml_file(e.file) then
          return
        end
      elseif vim.endswith(e.file, ".properties") then
        if not util.is_application_properties_file(e.file) then
          return
        end
      end
      vim.lsp.start(ls_config, { bufnr = e.buf })
    end,
  })
end

return M
