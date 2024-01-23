# boringcomment.nvim
![comment](https://github.com/alexshelto/boringcomment.nvim/assets/39957709/558d341a-2e4a-43a9-b8f3-af6575608635)


## What Is Telescope?
`boringcomment.nvim` is simply a way to comment & uncomment multiple lines of code in visual mode at once, and single lines in normal mode. Yep thats kinda it


## Instalation
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'alexshelto/boringcomment.nvim'
```

## Usage
Using Lua:
```lua
local blockcomment = require("blockcomment.commenter")

vim.keymap.set('x', "<leader>/", function()
    blockcomment.comment_visual_selection()
end)

vim.keymap.set('n', "<leader>/", function ()
    blockcomment.comment_current_line()
end)
```
