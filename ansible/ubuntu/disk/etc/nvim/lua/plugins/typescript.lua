return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- 禁用 vtsls
        vtsls = {
          enabled = false,
        },
        -- 或者禁用 tsserver（旧版或备用）
        tsserver = {
          enabled = false,
        },
      },
    },
  },
}
