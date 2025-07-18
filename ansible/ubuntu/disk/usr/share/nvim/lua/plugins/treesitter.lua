return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = {
      enable = true,
      -- disable = { "markdown" },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        node_decremental = false, -- 避免和backspace注释冲突 用 verbose vmap <BS> 查看
      },
    },
  },
}
