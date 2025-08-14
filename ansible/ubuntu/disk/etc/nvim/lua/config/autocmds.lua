-- 文件的后缀模板
vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("TemplateLoader", { clear = true }),
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
