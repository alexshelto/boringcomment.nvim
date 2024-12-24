local M = {}

--- Comments visual section, driver method used by keymap
-- This function takes line positions of a visual block and calls process lines
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

--- Comments for normal mode, driver method used by keymap
-- This function takes current line position and calls process lines
M.comment_current_line = function()
    local start_line_num = vim.fn.line(".")
    local end_line_num = start_line_num + 1

    M.process_lines(start_line_num, end_line_num)
end

---process the lines, comment or uncomment the line numbers
---@param start_line_num number the start line number to comment from
---@param end_line_num number the end line number to comment to
M.process_lines = function(start_line_num, end_line_num)
    local current_buf = vim.api.nvim_get_current_buf()

    local comment_prefix =
        vim.api.nvim_buf_get_option(current_buf, "commentstring")
    local cleaned_comment_prefix = comment_prefix:gsub("%%s", "") -- Removes special chars

    -- Pull lines from buffer
    local lines = vim.api.nvim_buf_get_lines(
        current_buf,
        start_line_num - 1,
        end_line_num - 1,
        false
    )

    -- Determine if lines are already commented (every line starts with a comment) if not we comment
    local is_commented = M.is_already_commented(lines, cleaned_comment_prefix)

    local replace_lines

    if is_commented then
        replace_lines = M.create_uncomment_lines(lines, cleaned_comment_prefix)
    else
        replace_lines = M.create_comment_lines(lines, comment_prefix)
    end

    vim.api.nvim_buf_set_lines(
        current_buf,
        start_line_num - 1, -- (-1) back to 0 based index
        end_line_num - 1,
        false,
        replace_lines
    )
end

---Create uncomment lines: If selected lines are already commented, return uncommented
---@param lines table[string] lines from buffer with comment string
---@param cleaned_comment_prefix string comment string to remove from lines
---@return table[string] of uncommented lines
M.create_uncomment_lines = function(lines, cleaned_comment_prefix)
    local uncomment_pattern = "^%s*" .. vim.pesc(cleaned_comment_prefix)
    for idx, line in ipairs(lines) do
        -- Handle line with only comment symbol
        if line == M.trim(cleaned_comment_prefix) then
            lines[idx] = ""
        else
            lines[idx] = line:gsub(uncomment_pattern, "")
        end
    end
    return lines
end

---Create comment lines: If selected lines are not commented, return commented
---@param lines table[string] lines from buffer
---@param cleaned_comment_prefix string comment string to add to lines
---@return table[string] of commented lines
M.create_comment_lines = function(lines, comment_prefix)
    for idx, line in ipairs(lines) do
        lines[idx] = comment_prefix:format(line)
    end
    return lines
end

---Determine if lines are already commented
---@param lines table[string] lines from buffer
---@param comment_prefix string
---@return boolean
M.is_already_commented = function(lines, comment_prefix)
    local cleaned_comment_string = comment_prefix:gsub("%%s", "")

    for _, line in ipairs(lines) do
        local is_commented = line:match(
            "^%s*" .. vim.pesc(cleaned_comment_string)
        ) ~= nil or line == "" or line == cleaned_comment_string

        -- Additional check for exact match of the comment string (e.g., "--" alone)
        if not is_commented and line ~= M.trim(cleaned_comment_string) then
            return false
        end
    end
    return true
end

-- Trim function to remove leading and trailing spaces
M.trim = function(str)
    return str:match("^%s*(.-)%s*$")
end

return M
