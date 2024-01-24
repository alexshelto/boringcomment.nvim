# boringcomment.nvim

![output](https://github.com/alexshelto/boringcomment.nvim/assets/39957709/14fa1a3c-2440-4538-9d23-aa342fa2b7f4)


## What Is boringcomment?
`boringcomment.nvim` is simply a way to comment & uncomment multiple lines of code in visual mode at once, and single lines in normal mode. Yep thats kinda it


## Instalation
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'alexshelto/boringcomment.nvim'
```

Using [LazyVim](https://github.com/LazyVim/LazyVim)
```lua
return {
  {
    "alexshelto/boringcomment.nvim",
  },
}
```

## Usage
Using Lua:
```lua
local boringcomment = require("boringcomment.commenter")

vim.keymap.set('x', "<leader>/", function()
    boringcomment.comment_visual_selection()
end)

vim.keymap.set('n', "<leader>/", function ()
    boringcomment.comment_current_line()
end)
```
