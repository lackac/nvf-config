do
	local tmux = {
		pane_id = nil,
	}

	local function trim(value)
		local cleaned = (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
		return cleaned
	end

	local function helper_port()
		if vim.fn.executable("opencode-session") ~= 1 then
			return nil
		end

		local proc = vim.system({ "opencode-session", "--print-port" }, { text = true }):wait()
		if proc.code ~= 0 then
			return nil
		end

		local resolved = tonumber(trim(proc.stdout))
		if not resolved or resolved <= 0 then
			return nil
		end

		return resolved
	end

	local fallback_port = 47000
	local port = tonumber(vim.env.OPENCODE_PORT) or helper_port() or fallback_port
	local cmd = "opencode --port " .. port

	function tmux.in_session()
		return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
	end

	function tmux.run(args)
		if vim.fn.executable("tmux") ~= 1 then
			return false, "", "tmux executable not found"
		end

		local proc = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
		return proc.code == 0, proc.stdout or "", proc.stderr or ""
	end

	function tmux.pane_pid(pane_id)
		local ok, out = tmux.run({ "display-message", "-p", "-t", pane_id, "#{pane_pid}" })
		if not ok then
			return nil
		end

		local pid = tonumber(trim(out))
		if not pid or pid <= 0 then
			return nil
		end

		return pid
	end

	function tmux.kill_process_group(pid)
		if not pid or pid <= 0 then
			return false
		end

		local proc = vim.system({ "kill", "-TERM", "-" .. tostring(pid) }, { text = true }):wait()
		return proc.code == 0
	end

	function tmux.orphan_pids_for_port()
		local pids = {}
		local proc = vim.system({ "ps", "-axo", "pid=,tty=,command=" }, { text = true }):wait()
		if proc.code ~= 0 then
			return pids
		end

		local port_string = tostring(port)
		for line in (proc.stdout or ""):gmatch("[^\r\n]+") do
			local pid_text, tty, command = line:match("^%s*(%d+)%s+(%S+)%s+(.+)$")
			if pid_text and tty and command then
				local executable = command:match("^%s*(%S+)")
				local has_port = command:match("%-%-port%s+" .. port_string .. "%s")
					or command:match("%-%-port%s+" .. port_string .. "$")
					or command:match("%-%-port=" .. port_string .. "%s")
					or command:match("%-%-port=" .. port_string .. "$")
				local no_tty = tty:match("^%?+$") ~= nil

				if no_tty and has_port and executable and executable:match("opencode$") then
					table.insert(pids, tonumber(pid_text))
				end
			end
		end

		return pids
	end

	function tmux.stop_orphans()
		local count = 0
		for _, pid in ipairs(tmux.orphan_pids_for_port()) do
			local proc = vim.system({ "kill", "-TERM", tostring(pid) }, { text = true }):wait()
			if proc.code == 0 then
				count = count + 1
			end
		end
		return count
	end

	function tmux.get_pane_id()
		if tmux.pane_id then
			local ok = select(1, tmux.run({ "list-panes", "-t", tmux.pane_id }))
			if ok then
				return tmux.pane_id
			end
			tmux.pane_id = nil
		end

		if not tmux.in_session() then
			return nil
		end

		local ok, out = tmux.run({
			"list-panes",
			"-s",
			"-F",
			"#{pane_id}\t#{pane_current_command}\t#{pane_start_command}",
		})
		if not ok then
			return nil
		end

		local port_pattern = "--port%s+" .. port
		for line in out:gmatch("[^\r\n]+") do
			local pane_id, pane_cmd, pane_start = line:match("([^\t]+)\t([^\t]*)\t(.*)")
			if
				pane_id
				and pane_start:match(port_pattern)
				and (pane_cmd == "opencode" or pane_start:match("opencode"))
			then
				tmux.pane_id = pane_id
				return pane_id
			end
		end

		return nil
	end

	function tmux.focus_pane(pane_id)
		local ok_window, window_id = tmux.run({ "display-message", "-p", "-t", pane_id, "#{window_id}" })
		if ok_window then
			local target_window = trim(window_id)
			if target_window ~= "" then
				tmux.run({ "select-window", "-t", target_window })
			end
		end
		tmux.run({ "select-pane", "-t", pane_id })
	end

	function tmux.start()
		if not tmux.in_session() then
			vim.notify("Not in tmux; unable to manage OpenCode pane.", vim.log.levels.WARN, { title = "opencode.nvim" })
			return
		end

		local pane_id = tmux.get_pane_id()
		if pane_id then
			return
		end

		tmux.stop_orphans()

		local ok, out, err = tmux.run({
			"split-window",
			"-h",
			"-d",
			"-p",
			"38",
			"-P",
			"-F",
			"#{pane_id}",
			"-c",
			vim.fn.getcwd(),
			cmd,
		})
		if not ok then
			vim.notify(
				"Failed to start OpenCode tmux pane:\n" .. err,
				vim.log.levels.ERROR,
				{ title = "opencode.nvim" }
			)
			return
		end

		tmux.pane_id = trim(out)
		if tmux.pane_id ~= "" then
			tmux.run({ "set-option", "-t", tmux.pane_id, "-p", "allow-passthrough", "off" })
		end
	end

	function tmux.stop()
		local pane_id = tmux.get_pane_id()
		if pane_id then
			local pid = tmux.pane_pid(pane_id)
			if pid then
				tmux.kill_process_group(pid)
			end

			tmux.run({ "kill-pane", "-t", pane_id })
			tmux.pane_id = nil
		end

		tmux.stop_orphans()
	end

	function tmux.toggle()
		local pane_id = tmux.get_pane_id()
		if not pane_id then
			tmux.start()
			pane_id = tmux.get_pane_id()
			if not pane_id then
				return
			end
			tmux.focus_pane(pane_id)
			return
		end

		local ok, active = tmux.run({ "display-message", "-p", "#{pane_id}" })
		if ok and trim(active) == pane_id then
			tmux.run({ "last-pane" })
		else
			tmux.focus_pane(pane_id)
		end
	end

	function tmux.send_prefix()
		local pane_id = tmux.get_pane_id()
		if not pane_id then
			tmux.start()
			pane_id = tmux.get_pane_id()
			if not pane_id then
				return
			end
		end

		tmux.focus_pane(pane_id)
		tmux.run({ "send-keys", "-t", pane_id, "C-x" })
	end

	function tmux.send_tab()
		local pane_id = tmux.get_pane_id()
		if not pane_id then
			tmux.start()
			pane_id = tmux.get_pane_id()
			if not pane_id then
				return
			end
		end

		tmux.focus_pane(pane_id)
		tmux.run({ "send-keys", "-t", pane_id, "Tab" })
	end

	function tmux.start_and_focus()
		tmux.start()
		local pane_id = tmux.get_pane_id()
		if pane_id then
			tmux.focus_pane(pane_id)
		end
	end

	vim.g.opencode_opts = {
		ask = {
			snacks = {
				win = {
					footer_keys = false,
				},
			},
		},
		server = {
			port = port,
			start = tmux.start,
			stop = tmux.stop,
			toggle = tmux.toggle,
			send_prefix = tmux.send_prefix,
			send_tab = tmux.send_tab,
			start_focus = tmux.start_and_focus,
		},
	}
end
