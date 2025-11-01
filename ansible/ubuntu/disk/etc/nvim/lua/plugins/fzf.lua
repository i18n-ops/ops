return {
  "ibhagwan/fzf-lua",
  -- 使用 init 函数确保 autocmd 在启动时就绪
  init = function()
    -- 实时同步 oldfiles
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("SyncOldfilesForFzf", { clear = true }),
      pattern = "*",
      callback = function()
        -- 使用 wshada (非破坏性写入), 它会智能地合并历史记录, 而不是覆盖
        vim.cmd("wshada")
      end,
    })
  end,
  opts = {
    oldfiles = {
      include_current_session = true,
    },
  },
  keys = {
    {
      "<leader>r",
      function()
        -- 使用 rshada! (破坏性读取), 强制从磁盘加载最新最完整的历史
        vim.cmd("rshada!")
        require("fzf-lua").oldfiles()
      end,
      desc = "Recent Files",
    },
  },
}
