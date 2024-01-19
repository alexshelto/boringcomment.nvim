local M = {}

M.hello = function()
    print("Hello World")
end

M.block_comment_lines = function(from, to)
    print(string.format("You want to block comment from line: %d to: %d", from, to))

    local current_buf = vim.api.nvim_get_current_buf()

    local current_lines = vim.api.nvim_buf_get_lines(current_buf, from-1, to, true)

    local line_number = from

    for _, line_contents in ipairs(current_lines) do

        -- Debug 
        print(string.format("# %d | %s", line_number, line_contents))
        local commented_line = string.format("-- %s",line_contents)

        vim.api.nvim_buf_set_lines(
            current_buf,
            line_number -1,
            line_number,
            false,
            {commented_line}
        )
        line_number = line_number + 1
    end
end


M.block_comment_lines(8,9)

return M


