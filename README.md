[English](./README_en.md)

# Quarkus Nvim

参考 [Quarkus](https://github.com/redhat-developer/vscode-quarkus) 插件, 将它的部分功能集成到 `Neovim` 中。

[![asciicast](https://asciinema.org/a/8707wkagSgj2t1rQuonplGuv0.svg)](https://asciinema.org/a/8707wkagSgj2t1rQuonplGuv0)

## 安装

- `lazy.nvim`

```lua
  {
    "JavaHello/quarkus.nvim",
    dependencies = {
      "JavaHello/microprofile.nvim",
      "mfussenegger/nvim-jdtls",
    },
  },
```

- 安装[Quarkus](https://github.com/redhat-developer/vscode-quarkus)和[Microprofile](https://github.com/redhat-developer/vscode-microprofile)插件或者自定义目录

## 配置

```lua
  -- quarkus setup 需要在 microprofile setup 之前调用
  require("quarkus.launch").setup {
    on_init = function(client, ctx)
      client.server_capabilities.documentHighlightProvider = false
    end,
  }
  require("microprofile.launch").setup {
    on_init = function(client, ctx)
      client.server_capabilities.documentHighlightProvider = false
    end,
  }
```

### nvim-jdtls

```lua
local jdtls_config = {
  bundles = {}
}
-- 添加 jdtls 扩展 jar 包
local ok_microprofile, microprofile = pcall(require, "microprofile")
if ok_microprofile then
  vim.list_extend(bundles, microprofile.java_extensions())
end

local ok_quarkus, quarkus = pcall(require, "quarkus")
if ok_quarkus then
  vim.list_extend(bundles, quarkus.java_extensions())
end
jdtls_config.on_init = function(_, _)
    if ok_quarkus then
        require("quarkus.bind").try_bind_qute_all_request()
    end
    if ok_microprofile then
        require("microprofile.bind").try_bind_microprofile_all_request()
    end
end
```
