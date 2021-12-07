# acme-nvim
Keyboard oriented Acme style editing for Neovim

Add this plugin with:

+ Paq: Add `"Bowuigi/acme-nvim"` to the plugins table
+ Vim-plug: `Plug 'Bowuigi/acme-nvim'`
+ Packer: `use 'Bowuigi/acme-nvim'` or add `"Bowuigi/acme-nvim"` to the plugins table

## What does it do?

It exposes two functions and two commands:

+ `acme.exec` or `:AcmeExec`: If the user is on visual mode then execute the selection, otherwise execute the current word.
+ `acme.tagline` or `:AcmeTagline`: Toggle the editable tagline used for writing commands or other useful stuff

"Execute" means checking the selection and acting accordingly, acme-nvim checks the first character of the selected text:

+ `:` Executes a Neovim command or Vimscript
+ Everything else executes a shell command

## Example bindings

Use the
+ `Enter` in Normal or Visual mode to execute commands
+ `<leader>` + `Enter` to execute the current line
+ `<leader>` + `t` keys to toggle the Tagline

```vim
nnoremap <CR> <Cmd>AcmeExec<CR>
vnoremap <CR> <Cmd>AcmeExec<CR>
nnoremap <leader><CR> V<Cmd>AcmeExec<CR>
nnoremap <leader>t <Cmd>AcmeTagline<CR>
```
