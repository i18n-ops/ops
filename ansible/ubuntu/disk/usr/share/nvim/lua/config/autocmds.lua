-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 文件的后缀模板
vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("MyTemplateLoader", { clear = true }),
  pattern = "*.*",
  callback = function(args)
    local extension = vim.fn.fnamemodify(args.file, ":e")
    if extension == "" then
      return
    end

    local template_path = vim.fn.stdpath("config") .. "/bundle/template/vim." .. extension
    if vim.fn.filereadable(template_path) == 1 then
      local template_content = vim.fn.readfile(template_path)
      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, template_content)
    end
  end,
})
