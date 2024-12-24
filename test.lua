

local M = {}

-- -- -- -- -- -- M.create_comment_lines = function(lines, comment_prefix)
--   for idx, line in ipairs(lines) do
--      print('before comment: ',line)
        lines[idx] = comment_prefix:format(line)
        print('after comment: ', lines[idx])nvim_out_write
    end
    return lines
end
