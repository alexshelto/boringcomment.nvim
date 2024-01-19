local M = {}

M.hello = function()
    print("Hello World")
end

M.block_comment_lines = function(from, to)
    local current_buf = vim.api.nvim_get_current_buf()

    local comment_string = vim.api.nvim_buf_get_option(current_buf, "commentstring")
    if comment_string == "" then
        print("Unable to determine comment characters for the current buffer")
        return
    end

    local current_lines = vim.api.nvim_buf_get_lines(current_buf, from-1, to, true)

    local line_number = from

    for _, line_contents in ipairs(current_lines) do
        print(string.format("# %d | %s", line_number, line_contents))
        local commented_line = string.format("-- %s",line_contents)

        vim.api.nvim_buf_set_lines(
            current_buf,
            line_number -1,
            line_number,
            false,
            {commented_line:format(line_contents)}
        )
        line_number = line_number + 1
    end
end


-- Script


M.block_comment_lines(8,9)

return M


