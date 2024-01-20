local M = {}

M.buffer = nil

M.is_buffer_set = function()
    return M.buffer ~= nil
end

M.get_buffer = function()
    if not M.is_buffer_set() then
        print("Error: Current buffer is not set.")
    end
    return M.buffer
end

M.set_buffer = function(buffer)
    M.buffer = buffer
end

M.process_lines = function(from, to)
    local current_buf = M.get_buffer()
    if not current_buf then
        print("Error: Current buffer is not set.")
        return
    end

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

    local code_is_commented =
        M.is_already_commented(current_lines, cleaned_comment_string)

    if code_is_commented == true then
        M.uncomment_lines(from, current_lines, comment_string)
    else
        M.comment_lines(from, current_lines, comment_string)
    end
end

M.is_already_commented = function(lines, comment_prefix)
    for _, line in ipairs(lines) do
        local is_commented = line:match("^%s*" .. vim.pesc(comment_prefix))
                ~= nil
            or line == ""

        if not is_commented then
            return false
        end
    end
    return true
end

M.is_line_commented = function(line)
    local current_buf = M.buffer
    if not current_buf then
        print("Error: Current buffer is not set.")
        return
    end

    local comment_string =
        vim.api.nvim_buf_get_option(current_buf, "commentstring")

    local cleaned_comment_string = comment_string:gsub("%%s", "")
    return line:match("^%s*" .. vim.pesc(cleaned_comment_string)) ~= nil
        or line == ""
end

M.uncomment_lines = function(from, lines, comment_string)
    local current_buf = M.get_buffer()
    if not current_buf then
        print("Error: Couldnt get buffer")
        return false
    end

    local cleaned_comment_string = comment_string:gsub("%%s", "")

    local no_comment_pattern = "^%s*" .. vim.pesc(cleaned_comment_string)

    for i, line in ipairs(lines) do
        local line_without_comments = line:gsub(no_comment_pattern, "")
        vim.api.nvim_buf_set_lines(
            current_buf,
            from - 1 + i - 1,
            from - 1 + i,
            false,
            { line_without_comments }
        )
    end
end

M.comment_lines = function(from, lines, comment_string)
    local current_buf = M.get_buffer()
    if not current_buf then
        print("Error: Couldnt get buffer")
        return false
    end

    for i, line in ipairs(lines) do
        if line ~= "" then
            vim.api.nvim_buf_set_lines(
                current_buf,
                from - 1 + i - 1,
                from - 1 + i,
                false,
                { comment_string:format(line) }
            )
        end
    end
end

return M
