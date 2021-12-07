local acme = {}
local BO = vim.bo
local WO = vim.wo
local A = vim.api
local F = vim.fn

local function GetVSel()
	local vStart = {F.line('v'), F.col('v')}
	local vEnd = A.nvim_win_get_cursor(0)
	local lines = A.nvim_buf_get_lines(0, vStart[1]-1, vEnd[1], false)

	lines[1] = string.sub(lines[1], vStart[2])
	lines[#lines] = string.sub(lines[#lines], 1, vEnd[2]-vStart[2]+2)

	return F.join(lines)
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

local function Switch(expr, cases)
	local run = cases[expr] or cases["default"]

--	if (type(run) == "function") then return run() end
	return run
end

function acme.execSh(cmd)
	local buf = F.systemlist(cmd)

	if (vim.v.shell_error ~= 0) then
		return false
	end

	buf[#buf+1] = ""
	buf[#buf+1] = "Command '"..cmd.."' exited with status code "..vim.v.shell_error

	MakeTmpBuf("Shell command output", buf)

	return true
end

function acme.execVim(cmd)
	local ok, output = pcall(A.nvim_exec, cmd, true)
	if ok then
		if (#output > 0) then
			MakeTmpBuf("Vimscript command output", F.split(output, "\n"))
		end
	end
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

	F.appendbufline(b, 0, ":e | :wa :wqa :qa! :/ . |")
	A.nvim_command("0")
end

function acme.exec()
	local sel

	if (vim.fn.mode() == "v") then
		sel = GetVSel()
	else
		sel = vim.fn.expand("<cword>")
	end

	if (sel == nil) then
		A.nvim_err_writeln("Acme: No selection")
		return
	end

	local e = ( Switch (sel:sub(1,1), {
		[":"] = {acme.execVim, 2};
		["!"] = {acme.execVim, 2};
		default = {acme.execSh, 1};
	}) )

	e[1] (sel:sub(e[2]))
end

return acme
