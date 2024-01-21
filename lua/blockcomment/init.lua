require("blockcomment.worker").set_buffer()

-- Set up an autocmd to trigger when the buffer changes
vim.api.nvim_create_autocmd("BufEnter",
    { callback = require('blockcomment.worker').set_buffer }
)

