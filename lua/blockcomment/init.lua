require("blockcomment.worker")

-- Set up an autocmd to trigger when the buffer changes
vim.cmd([[
  augroup BlockCommentAutocmd
    autocmd!
    autocmd BufEnter,WinEnter,FocusGained *
    lua require('blockcomment.worker').set_buffer(vim.api.nvim_get_current_buf())
  augroup END
]])
