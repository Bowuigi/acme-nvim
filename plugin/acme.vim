" Prevent loading Acme-nvim twice
if exists("g:loaded_acme")
	finish
endif

command! -nargs=0 AcmeExec lua require("acme").exec()

let g:loaded_acme = 1
