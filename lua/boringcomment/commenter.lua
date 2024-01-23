local M = {}

M.get_visual_line_numbers = function()
    local current_win = vim.api.nvim_get_current_win()
    local from = vim.fn.line("v", current_win)
    local to, _ = vim.api.nvim_win_get_cursor(current_win)

    return from, tonumber(to[1])
end

M.comment_visual_selection = function()
    local current_buf = vim.api.nvim_get_current_buf()
    local from, to = M.get_visual_line_numbers()
    M.process_lines(current_buf, math.min(from, to), math.max(from, to))
end

M.comment_current_line = function()
    local current_buf = vim.api.nvim_get_current_buf()
    local _, line_number = M.get_visual_line_numbers()
    M.process_lines(current_buf, line_number, line_number)
end

M.get_comment_string = function(current_buf)
    local comment_string =
        vim.api.nvim_buf_get_option(current_buf, "commentstring")

    if comment_string == "" then
        print(
            "ERROR: Unable to determine comment characters for the current buffer"
        )
        return nil
    end

    return comment_string
end

M.process_lines = function(current_buf, from, to)
    local comment_string = M.get_comment_string(current_buf)
    local cleaned_comment_string = comment_string:gsub("%%s", "")

    local current_lines =
        vim.api.nvim_buf_get_lines(current_buf, from - 1, to, false)

    if M.is_already_commented(current_lines, cleaned_comment_string) then
        M.uncomment_lines(
            current_buf,
            from,
            current_lines,
            cleaned_comment_string
        )
    else
        M.comment_lines(current_buf, from, current_lines, comment_string)
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

M.is_line_commented = function(line, cleaned_comment_string)
    return line:match("^%s*" .. vim.pesc(cleaned_comment_string)) ~= nil
        or line == ""
end

M.uncomment_lines = function(current_buf, from, lines, cleaned_comment_string)
    local no_comment_pattern = "^%s*" .. vim.pesc(cleaned_comment_string)

    local action = function(line)
        return line:gsub(no_comment_pattern, "")
    end

    M.apply_action_to_lines(current_buf, from, lines, action)
end

M.comment_lines = function(current_buf, from, lines, comment_string)
    local action = function(line)
        return comment_string:format(line)
    end

    M.apply_action_to_lines(current_buf, from, lines, action)
end

M.apply_action_to_lines = function(current_buf, from, lines, action)
    for i, line in ipairs(lines) do
        if line ~= "" then
            local processed_line = action(line)
            vim.api.nvim_buf_set_lines(
                current_buf,
                from - 1 + i - 1,
                from - 1 + i,
                false,
                { processed_line }
            )
        end
    end
end

return M
