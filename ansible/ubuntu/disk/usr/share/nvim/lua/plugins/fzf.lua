return {
  "ibhagwan/fzf-lua",
  opts = {
    oldfiles = {
      include_current_session = true,
    },
  },
  keys = {
    -- 将 <leader>r 设置为打开最近的文件
    {
      "<leader>r",
      function()
        require("fzf-lua").oldfiles()
      end,
      desc = "Recent Files",
    },
  },
}
