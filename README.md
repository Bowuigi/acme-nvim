# acme-nvim
Keyboard oriented Acme style editing for Neovim

Add this plugin with:

+ Paq: Add `"Bowuigi/acme-nvim"` to the plugins table
+ Vim-plug: `Plug 'Bowuigi/acme-nvim'`
+ Packer: `use 'Bowuigi/acme-nvim'`

## What does it do?

It exposes two functions and two commands:

+ `acme.exec` or `:AcmeExec`: If the user is on visual mode then execute the selection, otherwise execute the current word.
+ `acme.tagline` or `:AcmeTagline`: Toggle the editable tagline used for writing commands or other useful stuff

For now "execute" means execute as a shell command, but that might change soon

## Example bindings

```vim
nnoremap <CR> <Cmd>AcmeExec<CR>
vnoremap <CR> <Cmd>AcmeExec<CR>
nnoremap <leader>t <Cmd>AcmeTagline<CR>
```
