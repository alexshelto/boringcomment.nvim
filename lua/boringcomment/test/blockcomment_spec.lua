local boringcomment = require("boringcomment.commenter")

-- Create a temporary buffer with given lines
local function create_temp_buffer(lines)
    local buf = vim.api.nvim_create_buf(false, true) -- Create a scratch buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "filetype", "lua")
    return buf
end

-- Get all lines from a buffer
local function get_buffer_lines(buf)
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

describe("comment lines e2e", function()
    it("single line comment", function()
        local buf = create_temp_buffer({ "line 1" })
        vim.api.nvim_set_current_buf(buf) -- Set buffer as active

        boringcomment.process_lines(1, 2) -- Comment the first line

        local result = get_buffer_lines(buf)
        assert.are.same({ "-- line 1" }, result)

        -- Ensure buffer cleanup
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("multi line comment", function()
        local buf = create_temp_buffer({ "line 1", "line 2", "line 3" })
        vim.api.nvim_set_current_buf(buf) -- Set buffer as active

        boringcomment.process_lines(1, 4) -- Comment the first line

        local result = get_buffer_lines(buf)
        assert.are.same({ "-- line 1", "-- line 2", "-- line 3" }, result)

        -- Ensure buffer cleanup
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("includes empty line", function()
        local buf = create_temp_buffer({ "line 1", "", "line 3" })
        vim.api.nvim_set_current_buf(buf) -- Set buffer as active

        boringcomment.process_lines(1, 4) -- Comment the first line

        local result = get_buffer_lines(buf)
        assert.are.same({ "-- line 1", "-- ", "-- line 3" }, result)

        -- Ensure buffer cleanup
        vim.api.nvim_buf_delete(buf, { force = true })
    end)
end)

describe("uncomment lines e2e", function()
    it("should ignore empty lines", function()
        local buf = create_temp_buffer({ "-- line 1", "", "-- line 3" })
        vim.api.nvim_set_current_buf(buf) -- Set buffer as active

        boringcomment.process_lines(1, 4)

        local result = get_buffer_lines(buf)
        assert.are.same({ "line 1", "", "line 3" }, result)

        -- Ensure buffer cleanup
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("should uncomment", function()
        local buf =
            create_temp_buffer({ "-- line 1", "-- line 2", "-- line 3" })
        vim.api.nvim_set_current_buf(buf) -- Set buffer as active

        boringcomment.process_lines(1, 4)

        local result = get_buffer_lines(buf)
        assert.are.same({ "line 1", "line 2", "line 3" }, result)

        -- Ensure buffer cleanup
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("uncomment commented empty line", function()
        local buf = create_temp_buffer({ "--", "-- line 2", "--" })
        vim.api.nvim_set_current_buf(buf) -- Set buffer as active

        boringcomment.process_lines(1, 4)

        local result = get_buffer_lines(buf)
        assert.are.same({ "", "line 2", "" }, result)

        -- Ensure buffer cleanup
        vim.api.nvim_buf_delete(buf, { force = true })
    end)
end)

describe("is commented", function()
    local current_buf = vim.api.nvim_get_current_buf()

    it("should say is commented", function()
        local comment_prefix =
            vim.api.nvim_buf_get_option(current_buf, "commentstring")

        local lines = { "-- line 1", "-- line 2", "-- line 3" }

        local result = boringcomment.is_already_commented(lines, comment_prefix)

        assert.are.same(result, true)
    end)

    it("should ignore empty lines", function()
        local comment_prefix =
            vim.api.nvim_buf_get_option(current_buf, "commentstring")

        local lines = { "-- line 1", "", "-- line 3" }

        local result = boringcomment.is_already_commented(lines, comment_prefix)

        assert.are.same(result, true)
    end)

    it("should catch commented empty lines", function()
        local comment_prefix =
            vim.api.nvim_buf_get_option(current_buf, "commentstring")

        local lines = { "-- ", "--" }

        local result = boringcomment.is_already_commented(lines, comment_prefix)

        assert.are.same(result, true)
    end)
end)

-- [[

-- The bellow case is failint

--
--         boringcomment.process_lines(test_buffer, 1, 3)
--

-- ]]
