local M = {}

-- We can end up cleaning up and reading into a table and storing line number, 
-- then we read buffer once and can comment or uncomment after we figure out what

M.uncomment_lines = function(from, to)
    local current_buf = vim.fn.bufnr()

    local comment_string =
        vim.api.nvim_buf_get_option(current_buf, "commentstring")
    if comment_string == "" then
        print(
            "ERROR: Unable to determine comment characters for the current buffer"
        )
        return
    end

    local cleaned_comment_string = comment_string:gsub("%%s", "")

    local current_lines =
        vim.api.nvim_buf_get_lines(current_buf, from - 1, to, false)

    local is_block_commented = true
    for _, line_contents in ipairs(current_lines) do
        local is_commented =
            line_contents:match("^%s*" .. vim.pesc(cleaned_comment_string)) ~= nil
            or line_contents == ""

        if not is_commented then
            is_block_commented = false
            break
        end
    end

    local no_comment_pattern = "^%s*" .. vim.pesc(cleaned_comment_string)

    if is_block_commented then
        for i, line_contents in ipairs(current_lines) do
            -- Remove comments from the line
            local line_without_comments = line_contents:gsub(no_comment_pattern, "")
            vim.api.nvim_buf_set_lines(current_buf, from - 1 + i - 1, from - 1 + i, false, { line_without_comments })
        end
    end
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
        vim.api.nvim_buf_get_lines(current_buf, from - 1, to, false)

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


return M

