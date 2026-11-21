do
  local function run(argv, ...)
    local command = vim.list_extend(vim.list_extend({}, argv), { ... })
    local result = vim.system(command, { text = true }):wait(2000)
    if result.code == 0 then
      return ((result.stdout or ""):gsub("\n$", ""))
    end
    local err = vim.trim(result.stderr or "")
    return nil, err ~= "" and err or (argv[1] .. " exited with status " .. result.code)
  end

  local function json(argv, ...)
    local out, err = run(argv, ...)
    if not out then
      return nil, err
    end
    local ok, decoded = pcall(vim.json.decode, out, { luanil = { object = true } })
    if ok and type(decoded) == "table" then
      return decoded
    end
    return nil, "Invalid Rex response"
  end

  local function opencode_process(name)
    return name == "opencode" or name == ".opencode2-wrapped" or name == ".opencode2-wrap"
  end

  local function tmux_backend()
    local socket, pid, index = (vim.env.TMUX or ""):match("^(.+),(%d+),(%d+)$")
    local origin = vim.env.TMUX_PANE or ""
    if not socket or not origin:match("^%%%d+$") or vim.fn.executable("tmux") ~= 1 then
      return
    end

    local argv = { "tmux", "-S", socket }
    local session = "$" .. index
    local format = "#{pid}\t#{session_id}\t#{window_id}\t#{pane_id}\t#{pane_pid}\t#{pane_dead}"
    local out = run(argv, "list-panes", "-s", "-t", session .. ":", "-F", format)
    local panes = {}
    for line in (out or ""):gmatch("[^\n]+") do
      local server, sid, wid, id, child, dead =
        line:match("^(%d+)\t(%$%d+)\t(@%d+)\t(%%%d+)\t(%d+)\t([01])$")
      if server == pid and sid == session then
        panes[id] = { window = wid, child = child, dead = dead == "1" }
      end
    end
    if not panes[origin] or panes[origin].dead then
      return
    end
    panes[origin] = nil

    return {
      scope = vim.env.TMUX,
      panes = panes,
      running = function(id, cwd)
        local info = run(argv, "display-message", "-p", "-t", id,
          "#{pid}\t#{session_id}\t#{pane_id}\t#{pane_current_command}\t#{alternate_on}\t#{pane_in_mode}\t#{pane_current_path}")
        local server, sid, found, command, alt, mode, path =
          (info or ""):match("^(%d+)\t(%$%d+)\t(%%%d+)\t([^\t]+)\t([01])\t(%d+)\t(.+)$")
        return server == pid and sid == session and found == id
          and alt == "1" and mode == "0" and opencode_process(command)
          and vim.uv.fs_realpath(path) == cwd
      end,
      start = function(cwd)
        -- tmux expands formats in -c, even though we pass the path as an argv element.
        local path = cwd:gsub("#", "##")
        local result, err = run(argv, "split-window", "-h", "-d", "-p", "38", "-t", origin, "-P",
          "-F", "#{pane_id}\t#{pane_pid}", "-c", path, "--", "exec opencode")
        local id, child = (result or ""):match("^(%%%d+)\t(%d+)$")
        return id and { id = id, child = child }, err
      end,
      focus = function(id)
        local pane = panes[id]
        if pane then
          return run(argv, "select-window", "-t", session .. ":" .. pane.window, ";", "select-pane", "-t", id)
        end
        return run(argv, "select-pane", "-t", id) -- Newly split in the origin window.
      end,
      prefix = function(id)
        return run(argv, "send-keys", "-t", id, "C-x")
      end,
      close = function(id)
        return run(argv, "kill-pane", "-t", id)
      end,
    }
  end

  local function rex_backend()
    local session, origin = vim.env.REX_SESSION or "", vim.env.REX_BLOCK or ""
    if not session:match("^session:[%x-]+$") or not origin:match("^block:[%x-]+$") then
      return
    end
    local argv = { "rex", "--autostart=false" }
    local endpoint = vim.env.REX_SERVER
    if endpoint and endpoint ~= "" then
      if not endpoint:match("^unix:///") then
        return nil, "Rex pane controls require a local Unix socket"
      end
      vim.list_extend(argv, { "-S", endpoint })
    end
    if vim.fn.executable("rex") ~= 1 then
      return nil, "Rex CLI not found"
    end
    local identity, err = json(argv, "whoami", "--json")
    if not identity then
      return nil, err
    end
    if not identity.host_id or not (identity.endpoint or ""):match("^unix:///") then
      return nil, "Rex pane controls require a local Unix socket"
    end

    argv = { "rex", "--autostart=false", "-S", identity.endpoint }
    local terminal = "com.superlogical.terminal"
    local listing
    listing, err = json(argv, "block", "ls", "-s", session, "--json")
    if not listing then
      return nil, err
    end
    local panes = {}
    for _, block in ipairs(listing.blocks or {}) do
      if block.placement == "placed" and block.creator_name == terminal and block.host_id == identity.host_id
        and (block.block_id or ""):match("^block:[%x-]+$")
      then
        panes[block.block_id] = {}
      end
    end
    if not panes[origin] then
      return nil, "The originating Rex terminal is not on this host"
    end
    panes[origin] = nil

    return {
      scope = identity.endpoint .. "\n" .. identity.host_id .. "\n" .. session,
      panes = panes,
      running = function(id, cwd)
        local process = json(argv, "block", "call", "-s", session, "-b", id, "process")
        local fg = process and process.foreground
        if fg and (opencode_process(fg.name) or opencode_process(vim.fs.basename(fg.invoked_path or "")))
          and fg.cwd and vim.uv.fs_realpath(fg.cwd) == cwd
        then
          local modes = json(argv, "block", "call", "-s", session, "-b", id, "modes")
          return modes and modes.screen == "alternate"
        end
      end,
      start = function(cwd)
        -- Rex's macOS login(1) path ignores command and cwd. Run the login shell explicitly.
        local args = vim.json.encode({
          anchor_id = origin,
          direction = "horizontal",
          side = "after",
          ratio = 0.62,
          focus = false,
          layout = { block = { flavor = terminal .. ".shell", options = {
            cwd = cwd, shell = "none", login = false,
            command = { vim.env.SHELL or "/bin/sh", "-lic", "exec opencode" },
          } } },
        })
        local result, start_err = json(argv, "api", "call", "-s", session, "session.new_split", args)
        local id = result and result.block_ids and result.block_ids[1]
        return id and id:match("^block:[%x-]+$") and { id = id }, start_err
      end,
      focus = function(id)
        return run(argv, "focus", "-s", session, id)
      end,
      prefix = function(id)
        return run(argv, "send-key", "-s", session, "-b", id, "ctrl+x")
      end,
      close = function(id)
        return run(argv, "block", "close", "-s", session, id)
      end,
    }
  end

  local opts = require("opencode.config").opts
  opts.ask.snacks.win.footer_keys = false
  local default_start = opts.server.start
  local owned = {}

  local function target(backend, id, cwd, starting)
    if id and (starting or backend.running(id, cwd)) then
      return id
    end
    local match
    for pane, info in pairs(backend.panes) do
      if pane ~= id and not info.dead and backend.running(pane, cwd) then
        if match then
          return -- More than one candidate; do not guess.
        end
        match = pane
      end
    end
    return match
  end

  local function require_success(result, err)
    if not result then
      error(err and err ~= "" and err or "Could not control OpenCode pane", 0)
    end
    return result
  end

  local function control(action)
    local backend, err = tmux_backend()
    if not backend then
      backend, err = rex_backend()
    end
    if err then
      error(err, 0)
    elseif not backend then
      if action == "start" or action == "focus" then
        default_start()
      end
      return
    end

    local cwd = vim.uv.fs_realpath(vim.fn.getcwd())
    if not cwd then
      error("Cannot resolve the current directory", 0)
    end
    local key = backend.scope .. "\n" .. cwd
    local entry = owned[key]
    local info = entry and backend.panes[entry.id]
    local id = info and info.child == entry.child and entry.id or nil
    if action == "close" then
      if id then
        require_success(backend.close(id))
      end
      owned[key] = nil
      return
    end

    local starting = id and not info.dead and vim.uv.now() - entry.started < 2000
    local pane = target(backend, id, cwd, starting)
    if not pane then
      entry = require_success(backend.start(cwd))
      entry.started = vim.uv.now()
      owned[key] = entry
      pane, starting = entry.id, true
    end
    if action == "start" then
      return
    end

    -- On a cold start, wait briefly for the TUI before sending any input.
    if action == "prefix" and starting then
      vim.wait(1500, function()
        return backend.running(pane, cwd)
      end, 100)
    end
    require_success(backend.focus(pane))
    if action == "prefix" then
      if backend.running(pane, cwd) then
        require_success(backend.prefix(pane))
      else
        error("OpenCode TUI is not ready for its leader key", 0)
      end
    end
  end

  opts.server.start = function()
    control("start")
  end

  local function map(mode, lhs, action, desc)
    vim.keymap.set(mode, lhs, function()
      local ok, err = pcall(control, action)
      if not ok then
        vim.notify(err, vim.log.levels.WARN, { title = "opencode.nvim" })
      end
    end, { silent = true, desc = desc })
  end

  map("n", "<leader>as", "focus", "Start or Focus OpenCode Pane")
  map("n", "<leader>aK", "close", "Close Owned OpenCode Pane")
  if (vim.env.TMUX_PANE or "") ~= "" or (vim.env.REX_BLOCK or "") ~= "" then
    map({ "n", "x" }, "<C-x>", "prefix", "Forward OpenCode Leader")
  end
end
