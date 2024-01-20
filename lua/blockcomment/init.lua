-- TODO: dont comment empty lines

local M = {}

M.get_comment_string = function()
    local current_buf = vim.fn.bufnr()

    local comment_string =
        vim.api.nvim_buf_get_option(current_buf, "commentstring")
    if comment_string == "" then
        print(
            "ERROR: Unable to determine comment characters for the current buffer"
        )
        return ""
    end
    return comment_string
end

M.comment_lines = function(from, to)
    local current_buf = vim.fn.bufnr()

    local comment_string =
        vim.api.nvim_buf_get_option(current_buf, "commentstring")
    if comment_string == "" then
        print(
            "ERROR: Unable to determine comment characters for the current buffer"
        )
        return
    end

    local current_lines =
        vim.api.nvim_buf_get_lines(current_buf, from - 1, to, true)

    local line_number = from

    for _, line_contents in ipairs(current_lines) do
        if line_contents ~= "" then
            vim.api.nvim_buf_set_lines(
                current_buf,
                line_number - 1,
                line_number,
                false,
                { comment_string:format(line_contents) }
            )
        end

        line_number = line_number + 1
    end
end

-- Script

M.comment_lines(8, 9)

return M
