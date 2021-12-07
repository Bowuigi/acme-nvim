local acme = {}
local BO = vim.bo
local WO = vim.wo
local A = vim.api
local F = vim.fn

local function GetVSel()
	local vStart = {F.line('v'), F.col('v')}
	local vEnd = A.nvim_win_get_cursor(0)
	local lines = A.nvim_buf_get_lines(0, vStart[1]-1, vEnd[1], false)

	vim.notify(vim.inspect(vStart))
	vim.notify(vim.inspect(vEnd))
	vim.notify(vim.inspect(lines))

	lines[1] = string.sub(lines[1], vStart[2])
	lines[#lines] = string.sub(lines[#lines], 1, vEnd[2]-vStart[2]+2)

	vim.notify(vim.inspect(lines))
	return F.join(lines)
end

function acme.tagline()
	local title = "Tagline"

	local w = F.bufwinid(title)
	if (w > 0) then
		A.nvim_win_close(w, false)
		return
	end

	A.nvim_command("top new")
	local b = A.nvim_get_current_buf()

	A.nvim_buf_set_name(b, title)

	BO.buftype = "nofile"
	BO.bufhidden = "wipe"
	WO.winfixheight = true
	A.nvim_command("resize 1")

	F.appendbufline(b, 0, "Get | Del Look . |")
	A.nvim_command("0")
end

local function MakeTmpBuf(title, content)
	local w = F.bufwinid(title)
	if (w > 0) then
		A.nvim_win_close(w, false)
	end

	A.nvim_command("botright new")
	local b = A.nvim_get_current_buf()
	A.nvim_buf_set_name(b, title)
	BO.buftype = "nofile"
	BO.bufhidden = "wipe"
	F.appendbufline(b,0, content)
end

local function ExecSH(cmd)
	local buf = F.systemlist(cmd)
	buf[#buf+1] = ""
	buf[#buf+1] = "Command '"..cmd.."' exited with status code "..vim.v.shell_error
	MakeTmpBuf("Shell command output", buf)
end

function acme.exec()
	local sel

	if (vim.fn.mode() == "v") then
		sel = GetVSel()
	else
		sel = vim.fn.expand("<cword>")
	end

	if (sel == nil) then
		A.nvim_err_writeln("No selection")
		return
	end

	ExecSH(sel)
end

return acme
