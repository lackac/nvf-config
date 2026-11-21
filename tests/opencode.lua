local function test()
  local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), vim.inspect({ actual = actual, expected = expected }))
  end
  local function mapping(key, mode)
    return vim.fn.maparg(key, mode or "n", false, true).callback
  end
  local function press(key)
    local callback = assert(mapping(key), "Missing mapping " .. key)
    callback()
  end
  local opts = require("opencode.config").opts
  eq(opts.ask.snacks.win.footer_keys, false)
  eq(opts.server.url, nil)
  eq(opts.server.connect, true)
  eq(opts.server.stop, nil)
  eq(opts.server.toggle, nil)
  for _, key in ipairs({ "<leader>al", "<leader>a<Tab>", "<leader>aS" }) do
    eq(mapping(key), nil)
  end
  local plugin = require("opencode")
  for _, case in ipairs({
    { "<leader>aa", "ask", { "@this: " } },
    { "<leader>a.", "select", {} },
    { "<leader>ax", "prompt", { "explain" } },
  }) do
    local calls = 0
    plugin[case[2]] = function(...)
      calls = calls + 1
      eq({ ... }, case[3])
    end
    assert(mapping(case[1], "x"))
    press(case[1])
    eq(calls, 1)
  end
  assert(mapping("<C-x>", "x"))

  local cwd = vim.uv.fs_realpath(vim.fn.getcwd())
  cwd = cwd .. "/project with spaces '#{pid}'"
  vim.fn.mkdir(cwd, "p")
  vim.api.nvim_set_current_dir(cwd)

  local actions, notices = {}, {}
  local function action(...)
    table.insert(actions, { ... })
  end
  local function expect(...)
    eq(actions, { ... })
    eq(notices, {})
    actions = {}
  end
  vim.notify = function(message)
    table.insert(notices, message)
  end
  vim.fn.executable = function()
    return 1
  end
  local wait = vim.wait
  vim.wait = function(_, condition)
    return condition()
  end

  local session, origin, other, owned = "session:ab", "block:aa", "block:bb", "block:cc"
  local endpoint = "unix:///test/rex.sock"
  local terminal = "com.superlogical.terminal"
  local foreground, blocks, screens = {}, {}, {}
  local function rex_block(id, host, placement)
    blocks[id] = { block_id = id, creator_name = terminal, host_id = host, placement = placement or "placed" }
  end
  rex_block(origin, "local")
  rex_block(other, "local")
  rex_block("block:de", "remote")
  rex_block("block:df", "local", "detached")
  rex_block("block:dd", "local")
  rex_block("block:da", "local")
  foreground[other] = { name = "opencode", cwd = cwd }
  foreground["block:dd"] = { name = "opencode", cwd = "/elsewhere" }
  foreground["block:da"] = { name = "opencode", cwd = cwd }
  screens[other] = "alternate"
  screens["block:da"] = "primary"
  local function rex(args)
    eq(args[2], "--autostart=false")
    eq(args[3], "-S")
    eq(args[4], endpoint)
    local cmd = args[5]
    if cmd == "whoami" then
      eq(args[6], "--json")
      return { endpoint = endpoint, host_id = "local" }
    elseif cmd == "block" then
      eq(args[7], "-s")
      eq(args[8], session)
      if args[6] == "ls" then
        return { blocks = vim.tbl_values(blocks) }
      elseif args[6] == "call" then
        local id = args[10]
        assert(id ~= origin and id ~= "block:de" and id ~= "block:df", "Inspected out-of-scope block")
        if args[11] == "process" then
          return { foreground = foreground[id] }
        end
        eq(args[11], "modes")
        return { screen = screens[id] }
      elseif args[6] == "close" then
        action("rex-close", args[9])
        blocks[args[9]] = nil
        return ""
      end
    elseif cmd == "api" then
      eq(vim.list_slice(args, 6, 9), { "call", "-s", session, "session.new_split" })
      eq(vim.json.decode(args[10]), {
        anchor_id = origin,
        direction = "horizontal",
        side = "after",
        ratio = 0.62,
        focus = false,
        layout = { block = { flavor = terminal .. ".shell", options = {
          cwd = cwd, shell = "none", login = false, command = { "/bin/zsh", "-lic", "exec opencode" },
        } } },
      })
      action("rex-start")
      rex_block(owned, "local")
      foreground[owned] = { name = ".opencode2-wrapped", cwd = cwd }
      screens[owned] = "alternate"
      return { block_ids = { owned } }
    elseif cmd == "focus" then
      eq(vim.list_slice(args, 6, 7), { "-s", session })
      action("rex-focus", args[8])
      return ""
    elseif cmd == "send-key" then
      eq(vim.list_slice(args, 6, 11), { "-s", session, "-b", args[9], "ctrl+x" })
      action("rex-prefix", args[9])
      return ""
    end
    error("Unexpected Rex command: " .. vim.inspect(args))
  end

  local tmux_panes = {}
  local tmux_pid = 321
  local tmux_ready = true
  local function tmux_pane(id, fields)
    tmux_panes[id] = vim.tbl_extend("force", { session = "$4", window = "@5", child = "123", dead = "0" }, fields)
  end
  tmux_pane("%1", {})
  tmux_pane("%2", { command = "opencode", screen = "1", cwd = cwd, window = "@7" })
  tmux_pane("%3", { command = "opencode", screen = "1", cwd = cwd, session = "$6" })
  tmux_pane("%4", { command = "opencode", screen = "1", cwd = "/elsewhere" })
  tmux_pane("%5", { command = "opencode", screen = "0", cwd = cwd })
  local function tmux(args)
    eq(vim.list_slice(args, 2, 3), { "-S", "/test/tmux,socket" })
    local cmd = args[4]
    if cmd == "list-panes" then
      eq(vim.list_slice(args, 5, 8), { "-s", "-t", "$4:", "-F" })
      local lines = {}
      for id, pane in pairs(tmux_panes) do
        table.insert(lines, table.concat({ tmux_pid, pane.session, pane.window, id, pane.child, pane.dead }, "\t"))
      end
      return table.concat(lines, "\n")
    elseif cmd == "display-message" then
      local id = args[7]
      assert(id ~= "%3" and id ~= "%1", "Inspected out-of-scope pane")
      local pane = tmux_panes[id]
      return table.concat({ tmux_pid, pane.session, id, pane.command or "", pane.screen or "0", "0", pane.cwd or "-" }, "\t")
    elseif cmd == "split-window" then
      eq(vim.list_slice(args, 5), {
        "-h", "-d", "-p", "38", "-t", "%1", "-P", "-F", "#{pane_id}\t#{pane_pid}",
        "-c", (cwd:gsub("#", "##")), "--", "exec opencode",
      })
      action("tmux-start")
      tmux_pane("%6", { command = ".opencode2-wrap", screen = tmux_ready and "1" or "0", cwd = cwd, child = "456" })
      return "%6\t456"
    elseif cmd == "select-window" then
      eq(vim.list_slice(args, 7, 9), { ";", "select-pane", "-t" })
      action("tmux-focus", args[6], args[10])
      return ""
    elseif cmd == "select-pane" then
      action("tmux-focus", args[6])
      return ""
    elseif cmd == "send-keys" then
      eq(args[7], "C-x")
      action("tmux-prefix", args[6])
      return ""
    elseif cmd == "kill-pane" then
      action("tmux-close", args[6])
      tmux_panes[args[6]] = nil
      return ""
    end
    error("Unexpected tmux command: " .. vim.inspect(args))
  end

  local mux
  vim.system = function(args)
    eq(args[1], mux)
    local out = (mux == "rex" and rex or tmux)(args)
    return { wait = function() return { code = 0, stdout = type(out) == "table" and vim.json.encode(out) or out } end }
  end
  vim.env.SHELL = "/bin/zsh"
  vim.env.REX_SERVER = endpoint
  mux = "rex"
  opts.server.start()
  expect()
  press("<leader>as")
  expect({ "rex-focus", other })
  press("<C-x>")
  expect({ "rex-focus", other }, { "rex-prefix", other })
  press("<leader>aK")
  expect()

  -- Two verified matches are ambiguous; start beside the origin instead.
  screens["block:da"] = "alternate"
  press("<leader>as")
  expect({ "rex-start" }, { "rex-focus", owned })
  press("<leader>aK")
  expect({ "rex-close", owned })
  press("<leader>aK")
  expect()
  screens["block:da"] = "primary"

  vim.env.REX_SERVER = "https://another-host"
  press("<leader>as")
  eq(actions, {})
  assert(notices[1]:find("local Unix socket", 1, true))
  notices = {}
  vim.env.REX_SERVER = endpoint

  -- Invalid tmux falls back to Rex; a valid nested tmux does not call Rex.
  vim.env.TMUX, vim.env.TMUX_PANE = "/test/tmux,socket,321,4", "invalid"
  press("<leader>as")
  expect({ "rex-focus", other })
  mux, vim.env.TMUX_PANE = "tmux", "%1"
  press("<leader>as")
  expect({ "tmux-focus", "$4:@7", "%2" })
  press("<leader>aK")
  expect()
  press("<C-x>")
  expect({ "tmux-focus", "$4:@7", "%2" }, { "tmux-prefix", "%2" })
  tmux_panes["%2"] = nil
  opts.server.start()
  expect({ "tmux-start" })
  press("<leader>as")
  expect({ "tmux-focus", "$4:@5", "%6" })
  press("<leader>aK")
  expect({ "tmux-close", "%6" })

  vim.env.REX_SESSION, vim.env.REX_BLOCK, vim.env.REX_SERVER = nil, nil, nil
  press("<C-x>")
  expect({ "tmux-start" }, { "tmux-focus", "%6" }, { "tmux-prefix", "%6" })
  tmux_panes["%6"].child = "999" -- respawned pane is no longer owned
  press("<leader>aK")
  expect()
  tmux_panes["%6"] = nil
  tmux_ready = false
  press("<C-x>")
  eq(actions, { { "tmux-start" }, { "tmux-focus", "%6" } })
  assert(notices[1]:find("not ready", 1, true))
  actions, notices = {}, {}

  vim.env.TMUX, vim.env.TMUX_PANE = nil, nil
  mux = nil
  press("<leader>aK")
  press("<C-x>")
  expect()
  vim.wait = wait
  -- Exercise the real pinned standalone start without launching OpenCode.
  local original_cmd = vim.cmd
  vim.cmd = function(cmd)
    eq(cmd, "vsplit term://opencode | wincmd p")
    action("standalone-start")
  end
  opts.server.start()
  press("<leader>as")
  vim.cmd = original_cmd
  expect({ "standalone-start" }, { "standalone-start" })
  print("opencode: Rex, tmux, nesting, owned close, native leader and plugin mappings passed")
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
