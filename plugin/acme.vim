" Prevent loading Acme-nvim twice
if exists("g:loaded_acme")
	finish
endif

command! -nargs=0 AcmeExec lua require("acme").exec()
command! -nargs=0 AcmeTagline lua require("acme").tagline()

let g:loaded_acme = 1
