local acme = {}
local A = vim.api
local F = vim.fn
local BO = vim.bo

local function GetVSel()
	local vStart = A.nvim_buf_get_mark(0,'<')
	local vEnd = A.nvim_buf_get_mark(0,'>')
	local lines = A.nvim_buf_get_lines(0, vStart[1], vEnd[1], false)
	return lines:sub(vStart[1], -vEnd[1])
end

local function MakeTagline()
	A.nvim_command("top new")
	A.nvim_buf_set_name(0,"Tagline")
	BO.buftype = "nofile"
	BO.statusline = "%{''}"
	BO.bufhidden = "wipe"
	BO.winfixheight = true
	A.nvim_command("resize 1")
	F.appendbuf(0, "Get | Del Look . |")
end

local function MakeTmpBuf(title, content)
	A.nvim_command("botright new")
	A.nvim_buf_set_name(0, title)
	BO.buftype = "nofile"
	BO.bufhidden = "wipe"
	F.appendbuf(0, content)
end

function acme.exec_sh(cmd)
	MakeTmpBuf("Shell command output", F.system(cmd))
end

function acme.exec()
	local sel

	if (vim.fn.mode() == "v") then
		sel = GetVSel()
	else
		sel = vim.fn.expand("<cword>")
	end

	vim.notify(vim.fn.mode().." "..sel)
end

return acme
