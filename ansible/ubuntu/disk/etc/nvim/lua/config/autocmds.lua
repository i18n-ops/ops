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

-- 当保存 txt 或 md 文件后，运行 add_space -w <文件路径> 并重新加载
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.txt", "*.md" },
  callback = function()
    -- 获取当前文件的完整路径
    local file_path = vim.fn.expand('%:p')
    -- 构建要执行的命令
    local command = "add_space -w " .. vim.fn.shellescape(file_path)
    -- 执行外部命令
    vim.fn.system(command)
    -- 重新加载当前缓冲区
    vim.cmd('edit')
  end,
})
