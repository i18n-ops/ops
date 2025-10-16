return {
  {
    "i18n-fork/vim-stylus",
    ft = { "svelte", "stylus" },
  },
  {
    "i18n-fork/vim-svelte-plugin",
    ft = { "svelte" },
    dependencies = {
      "digitaltoad/vim-pug",
      "i18n-fork/context_filetype.vim",
    },
    config = function()
      vim.g.vim_svelte_plugin_use_pug = 1
      vim.g.vim_svelte_plugin_use_stylus = 1
      vim.g.vim_svelte_plugin_use_coffee = 1
      vim.g.vim_svelte_plugin_has_init_indent = 0
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = vim.api.nvim_create_augroup("SetCommentStringForSvelte", { clear = true }),
        pattern = "*.svelte",
        callback = function()
          local ok, context = pcall(vim.fn["context_filetype#get_filetype"])
          if not ok or not context then
            return
          end

          local commentstring_map = {
            coffee = "# %s",
            pug = "//- %s",
            stylus = "// %s",
          }

          local ft = context.filetype or context

          if commentstring_map[ft] then
            vim.bo.commentstring = commentstring_map[ft]
          end
        end,
      })
    end,
  }
}
