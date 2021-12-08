# acme-nvim
Keyboard oriented Acme style editing for Neovim

Add this plugin with:

+ Paq: Add `"Bowuigi/acme-nvim"` to the plugins table
+ Vim-plug: `Plug 'Bowuigi/acme-nvim'`
+ Packer: `use 'Bowuigi/acme-nvim'` or add `"Bowuigi/acme-nvim"` to the plugins table

## What does it do?

It exposes the following functions and commands:

+ `acme.exec` or `:AcmeExec`: If the user is on visual mode then execute the selection, otherwise execute the current word.
+ `acme.tagline` or `:AcmeTagline`: Toggle the editable tagline used for writing commands or other useful stuff
+ `acme.mark` or `:AcmeMark`: Mark a selection to pass it to a command

"Execute" means checking the selection and acting accordingly, acme-nvim checks the first character of the selected text:

+ `:` Executes a Neovim command or Vimscript
+ `<` Executes a shell command overwriting the text marked with `AcmeMark` (Or `acme.mark`) with the command's output
+ `>` Executes a shell command passing the text marked with `:AcmeMark` (Or `acme.mark`) as standard input
+ `|` Executes a shell command passing the text marked with `:AcmeMark` (Or `acme.mark`) as standard input and overwriting the text inside the mark with the command's output
+ Everything else executes a shell command normally

## Example bindings

Use the
+ `Enter` in Normal or Visual mode to execute commands
+ `<leader>` + `Enter` to execute the current line
+ `<leader>` + `t` keys to toggle the Tagline
+ `<leader>` + `m` keys to mark the visual selection (for use with `|`, `<`, `>`)

```vim
nnoremap <CR> <Cmd>AcmeExec<CR>
vnoremap <CR> <Cmd>AcmeExec<CR>
nnoremap <leader><CR> V<Cmd>AcmeExec<CR>
nnoremap <leader>t <Cmd>AcmeTagline<CR>
nnoremap <leader>m <Cmd>AcmeMark<CR>
```
