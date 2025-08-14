-- fix https://github.com/LazyVim/LazyVim/discussions/6235

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("MyKeymaps", { clear = true }),
  pattern = "*",
  callback = function()
    local set = vim.keymap.set
    set("v", "<", "<gv", { noremap = true, silent = true, buffer = true })
    set("v", ">", ">gv", { noremap = true, silent = true, buffer = true })
    set(
      "v",
      ".",
      ":<C-u>normal .<CR>",
      { silent = true, desc = "在可视模式下重复上一个操作", buffer = true }
    )
    set("v", "<BS>", "gc", { remap = true, desc = "comment selection", buffer = true })
  end,
})
