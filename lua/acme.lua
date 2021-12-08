local acme = {}
local BO = vim.bo
local WO = vim.wo
local A = vim.api
local F = vim.fn
acme.markStart = {0,0}
acme.markEnd = {0,0}
acme.markText = ""

-- Convert a list of items into a single string, kinda like vim.fn.join but that adds newlines instead of nothing
local function TJoin(t)
	local s = ""
	for i=1, #t do
		if (i == 1) then
			s = s..tostring(t[i])
		else
			s = s.."\n"..tostring(t[i])
		end
	end
	return s
end

-- Get the visual ('v' mode) selection
local function GetVSel()
	-- Get the position where Visual mode started and finished
	local vStart = {F.line('v'), F.col('v')}
	local vEnd = {F.line('.'), F.col('.')}

	-- Fix range being backwards
	if (vEnd[1] < vStart[1]) then
		vEnd, vStart = vStart, vEnd
	elseif (vEnd[1] == vStart[1] and vEnd[2] < vStart[2]) then
		vEnd, vStart = vStart, vEnd
	end

	-- Use the position to get what is in those lines
	local lines = A.nvim_buf_get_lines(0, vStart[1]-1, vEnd[1], false)

	lines[1] = string.sub(lines[1], vStart[2])
	lines[#lines] = string.sub(lines[#lines], 1, vEnd[2]-vStart[2]+1)

	-- Return it all as a nicely formatted string
	return TJoin(lines)
end

-- Get the Visual Line ('V' mode) selection
local function GetVLineSel()
	-- Get the position where Visual Line mode started and finished
	local vStart = F.line('v')
	local vEnd = F.line('.')

	-- Fix range being backwards
	if (vEnd < vStart) then
		vEnd, vStart = vStart, vEnd
	end

	-- Use the position to get what is in those lines
	local lines = A.nvim_buf_get_lines(0, vStart-1, vEnd, false)

	-- Return it all as a nicely formatted string
	return TJoin(lines)
end

-- Make a temporal buffer to show data to the user
local function MakeTmpBuf(title, content)
	local w = F.bufwinid(title)

	-- Close the buffer if it already exists, wiping it
	if (w > 0) then
		A.nvim_win_close(w, false)
	end

	-- Create a new buffer and set the settings to allow edit (but not save), get wiped on closing, put the title and append the content
	A.nvim_command("botright new")
	local b = A.nvim_get_current_buf()
	A.nvim_buf_set_name(b, title)
	BO.buftype = "nofile"
	BO.bufhidden = "wipe"
	F.appendbufline(b,0, content)
end

-- Generic Switch statement, but improved
local function Switch(expr)
	return function(cases)
		-- Get the selected case or the default one
		local run = cases[expr] or cases["default"]

		-- Run it if it is a function, otherwise just return it
		if (type(run) == "function") then return run() end
		return run
	end
end

function acme.mark()
	-- Get the position where Visual mode started and finished
	local vStart = {F.line('v'), F.col('v')}
	local vEnd = {F.line('.'), F.col('.')}

	-- Fix range being backwards
	if (vEnd[1] < vStart[1]) then
		vEnd, vStart = vStart, vEnd
	elseif (vEnd[1] == vStart[1] and vEnd[2] < vStart[2]) then
		vEnd, vStart = vStart, vEnd
	end

	-- Use the position to get what is in those lines
	local lines = A.nvim_buf_get_lines(0, vStart[1]-1, vEnd[1], false)

	if (F.mode() == "v") then
		lines[1] = string.sub(lines[1], vStart[2])
		lines[#lines] = string.sub(lines[#lines], 1, vEnd[2]-vStart[2]+1)
	end

	-- Save the region and the text for use with '|', '<' and '>'
	acme.markStart = vStart
	acme.markEnd = vEnd
	acme.markText = TJoin(lines)
end

-- Execute shell commands
function acme.execSh(cmd)
	local input, output, buf

	Switch (cmd:sub(1,1)) {
		["|"] = function()
			input = acme.markText
			output =  F.systemlist("echo "..F.shellescape(input).." | "..cmd:sub(2))
			output[#output+1] = ""
			A.nvim_buf_set_text(0, acme.markStart[1]-1, acme.markStart[2]-1, acme.markEnd[1], acme.markEnd[2]-1, output)
		end,
		["<"] = function()
			output =  F.systemlist(cmd:sub(2))
			output[#output+1] = ""
			A.nvim_buf_set_text(0, acme.markStart[1]-1, acme.markStart[2]-1, acme.markEnd[1], acme.markEnd[2]-1, output)
		end,
		[">"] = function()
			input = acme.markText
			output =  F.systemlist("echo "..F.shellescape(input).." | "..cmd:sub(2))
			output[#output+1] = ""
		end,
		default = function()
			output = F.systemlist(cmd)
		end
	}

	buf = output

	-- Append exit status info
	buf[#buf+1] = "Command '"..cmd.."' exited with status code "..vim.v.shell_error

	-- Show data to the user
	MakeTmpBuf("Shell command output", buf)
end

-- Execute Vimscript code, showing the data written to the user if any
function acme.execVim(cmd)
	-- Since executing Vimscript gives Lua errors, we need a pcall to make sure it doesn't give one
	local ok, output = pcall(A.nvim_exec, cmd, true)

	-- Show the output if everything went right and if the command has output
	-- Otherwise, show the error message
	if ok then
		if (#output > 0) then
			MakeTmpBuf("Vimscript command output", F.split(output, "\n"))
		end
	else
		A.nvim_err_writeln("Acme: Error while executing Vimscript, "..output)
	end
end

-- Toggle the editable tagline
function acme.tagline()
	local title = "Tagline"

	-- Close the window if it already exists
	local w = F.bufwinid(title)
	if (w > 0) then
		A.nvim_win_close(w, false)
		return
	end

	-- Create a window and get its buffer
	A.nvim_command("top new")
	local b = A.nvim_get_current_buf()

	--- Window settings, the tagline is just a "no saving", "wipe on hide", "height 1" buffer with a title
	A.nvim_buf_set_name(b, title)

	BO.buftype = "nofile"
	BO.bufhidden = "wipe"
	WO.winfixheight = true
	A.nvim_command("resize 1")

	-- Append commands to the tagline to serve as useful examples
	F.appendbufline(b, 0, ":e | :wa :wqa :qa! :/ . |")
	A.nvim_command("0")
end

-- Execute the selection (or the current word if on normal mode) either as a shell command or as a Neovim command
function acme.exec()
	local sel = ""

	-- Get selection or word depending on the mode
	sel = Switch (vim.fn.mode()) {
		v = function() return GetVSel() end;
		V = function() return GetVLineSel() end;
		default = function() return vim.fn.expand("<cexpr>") end;
	}

	-- Detect no selection
	if (sel == nil) then
		A.nvim_err_writeln("Acme: No selection")
		return
	end

	-- Detect what to execute and execute it
	local e = Switch (sel:sub(1,1)) {
		[":"] = {acme.execVim, 2};
		["!"] = {acme.execVim, 2};
		default = {acme.execSh, 1};
	}

	e[1] (sel:sub(e[2]))
end

return acme
