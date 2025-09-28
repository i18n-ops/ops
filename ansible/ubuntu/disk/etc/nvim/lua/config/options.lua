-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false

local opt = vim.opt

opt.laststatus = 0
opt.mouse = ""
opt.showcmd = true
opt.wildmenu = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.relativenumber = false
opt.clipboard = ""
opt.wrap = true -- 开启软换行
opt.linebreak = true -- 按单词换行，避免在单词中间断开
opt.conceallevel = 0
opt.spell = true
opt.spelllang = { "en", "cjk" }
opt.ignorecase = false
