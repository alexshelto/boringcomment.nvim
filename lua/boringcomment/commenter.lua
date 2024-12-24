local M = {}

M.comment_visual_selection = function()
    local current_win = vim.api.nvim_get_current_win()
    local from = vim.fn.line("v", current_win)
    local to, _ = vim.api.nvim_win_get_cursor(current_win)

    local start_line_num = from
    local end_line_num = tonumber(to[1])

    if start_line_num > end_line_num then
        start_line_num, end_line_num = end_line_num, start_line_num
    end

    end_line_num = end_line_num + 1

    M.process_lines(start_line_num, end_line_num)
end


M.comment_current_line = function ()
    local start_line_num = vim.fn.line('.')
    local end_line_num = start_line_num + 1

    M.process_lines(start_line_num, end_line_num)
end

M.process_lines = function(start_line_num, end_line_num)
    local current_buf = vim.api.nvim_get_current_buf()

    local comment_prefix = vim.api.nvim_buf_get_option(current_buf, "commentstring")
    local cleaned_comment_prefix = comment_prefix:gsub("%%s", "") -- Removes special chars

    -- Pull lines out of buffer
    local lines = vim.api.nvim_buf_get_lines(current_buf, start_line_num-1, end_line_num-1, false)

    -- Determine if lines are already commented (every line starts with a comment) if not we comment
    local is_commented = M.is_already_commented(lines, cleaned_comment_prefix)

    local replace_lines -- lines that will contain comment or uncomment strings to replace

    if  is_commented then
        replace_lines = M.create_uncomment_lines(lines, cleaned_comment_prefix)
    else
        replace_lines = M.create_comment_lines(lines, comment_prefix)
    end

    vim.api.nvim_buf_set_lines(
        current_buf,
        start_line_num-1, -- (-1) back to 0 based index
        end_line_num-1,
        false,
        replace_lines
    )
end


M.create_uncomment_lines = function(lines, cleaned_comment_prefix)
    local uncomment_pattern = "^%s*" .. vim.pesc(cleaned_comment_prefix)
    for idx, line in ipairs(lines) do
        lines[idx] = line:gsub(uncomment_pattern, "")
    end
    return lines
end


M.create_comment_lines = function(lines, comment_prefix)
    for idx, line in ipairs(lines) do
        lines[idx] = comment_prefix:format(line)
    end
    return lines
end


M.is_already_commented = function(lines, comment_prefix)
    local cleaned_comment_string = comment_prefix:gsub("%%s", "")

    for _, line in ipairs(lines) do
        local is_commented = line:match("^%s*" .. vim.pesc(cleaned_comment_string))
                ~= nil
            or line == ""

        if not is_commented then
            return false
        end
    end
    return true
end


return M
