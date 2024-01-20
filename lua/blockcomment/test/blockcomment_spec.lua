local blockcomment = require("blockcomment.init")

local function create_buffer(contents, extension)
    local test_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(test_bufnr, 0, -1, false, contents)

    vim.api.nvim_buf_set_option(test_bufnr, "filetype", extension)
    vim.api.nvim_set_current_buf(test_bufnr)

    blockcomment.buffer = test_bufnr

    return test_bufnr
end

describe("comment lines e2e", function()
    it("should comment the lines", function()
        local test_contents = { "line 1", "line 2", "line 3" }
        local test_buffer = create_buffer(test_contents, "lua")

        blockcomment.process_lines(1, 3)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "-- line 1", "-- line 2", "-- line 3" }, result)
    end)

    it("should comment single line", function()
        local test_contents = { "line 1", "line 2", "line 3" }
        local test_buffer = create_buffer(test_contents, "go")

        blockcomment.process_lines(2, 2)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "line 1", "// line 2", "line 3" }, result)
    end)

    it("should not comment empty lines", function()
        local test_contents = { "line 1", "", "line 3" }
        local test_buffer = create_buffer(test_contents, "go")

        blockcomment.process_lines(1, 3)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "// line 1", "", "// line 3" }, result)
    end)

    it("should ignore out of range line number", function()
        local test_contents = { "line 1", "line 2", "line 3" }
        local test_buffer = create_buffer(test_contents, "go")

        blockcomment.process_lines(2, 20)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "line 1", "// line 2", "// line 3" }, result)
    end)
end)

describe("uncomment lines e2e", function()
    it("should uncomment the lines", function()
        local test_contents = { "// line 1", "// line 2", "// line 3" }
        local test_buffer = create_buffer(test_contents, "go")

        blockcomment.process_lines(1, 3)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "line 1", "line 2", "line 3" }, result)
    end)

    it("should ignore empty lines", function()
        local test_contents = { "-- line 1", "", "-- line 3" }
        local test_buffer = create_buffer(test_contents, "lua")

        blockcomment.process_lines(1, 3)

        local result = vim.api.nvim_buf_get_lines(test_buffer, 0, -1, true)

        assert.are.same({ "line 1", "", "line 3" }, result)
    end)
end)
