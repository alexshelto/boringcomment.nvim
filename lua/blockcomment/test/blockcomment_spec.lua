local blockcomment = require("blockcomment.init")

local function create_buffer(contents, extension)
    local test_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(test_bufnr, 0, -1, false, contents)

    vim.api.nvim_buf_set_option(test_bufnr, "filetype", extension)
    vim.api.nvim_set_current_buf(test_bufnr)

    return test_bufnr
end

describe("gets comment string", function()
    it("lua", function()
        local test_contents = { "line 1", "line 2", "line 3" }
        local test_buffer = create_buffer(test_contents, "go")
        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        local comment_string = blockcomment.get_comment_string()

        assert.are.same(comment_string, "// %s")
    end)
end)

describe("commenting out lines", function()
    it("should comment the lines", function()
        local test_contents = { "line 1", "line 2", "line 3" }
        local test_buffer = create_buffer(test_contents, "lua")

        blockcomment.comment_lines(1, 3)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "-- line 1", "-- line 2", "-- line 3" }, result)
    end)

    it("should not comment empty lines", function()
        local test_contents = { "line 1", "", "line 3" }
        local test_buffer = create_buffer(test_contents, "go")

        blockcomment.comment_lines(1, 3)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "// line 1", "", "// line 3" }, result)
    end)
end)
