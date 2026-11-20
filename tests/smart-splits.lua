local function test()
  local rex_calls, tmux_calls = {}, {}
  local rex_available = true
  local executable = vim.fn.executable
  vim.fn.executable = function(bin)
    if bin == 'rex' then
      return rex_available and 1 or 0
    end
    return executable(bin)
  end
  vim.system = function(cmd)
    assert(cmd[1] == 'rex', 'unexpected external command: ' .. vim.inspect(cmd))
    table.insert(rex_calls, cmd)
    return { wait = function() return { code = 0, stdout = '{"handled":true}' } end }
  end
  local tmux = require('smart-splits-backend-tmux.tmux')
  tmux.set_runner(function(cmd)
    table.insert(tmux_calls, cmd)
    return cmd[4] == 'list-panes' and '' or '0\n', 0
  end, function() return true end)

  -- Exercise nvf's real lazy setup and the configured Ctrl-arrow mappings.
  vim.api.nvim_exec_autocmds('User', { pattern = 'DeferredUIEnter' })
  local splits = require('smart-splits')
  local config = require('smart-splits.config')
  local backend = require('smart-splits.backend')
  local selector = config.mux.backend
  assert(type(selector) == 'function', 'smart-splits setup did not run')
  assert(#config.issues() == 0, vim.inspect(config.issues()))

  local function select(env)
    for _, key in ipairs({ 'TMUX', 'TMUX_PANE', 'REX_SESSION', 'REX_BLOCK' }) do
      vim.env[key] = env[key]
    end
    backend.reset()
    splits.setup({ mux = { backend = selector, warn_if_unusable = false }, log = { file = false } })
    local selected = backend.resolve()
    return selected and selected.name
  end

  assert(select({}) == nil)
  assert(#backend.report() == 0, 'outside a mux should not try any backends')
  assert(select({ TMUX = '', REX_SESSION = '', REX_BLOCK = '' }) == nil)
  assert(select({ REX_SESSION = 'session' }) == nil)
  assert(select({ REX_BLOCK = 'block' }) == nil)
  assert(select({ REX_SESSION = 'session', REX_BLOCK = 'block' }) == 'smart-splits-backend-rex')
  assert(backend.validate(require('smart-splits-backend-rex')) == nil)
  assert(backend.validate(require('smart-splits-backend-tmux')) == nil)

  local directions = {
    { key = '<C-Left>', direction = 'left', split = 'vsplit', start = 'l', target = 'h', tmux = '-L' },
    { key = '<C-Right>', direction = 'right', split = 'vsplit', start = 'h', target = 'l', tmux = '-R' },
    { key = '<C-Up>', direction = 'up', split = 'split', start = 'j', target = 'k', tmux = '-U' },
    { key = '<C-Down>', direction = 'down', split = 'split', start = 'k', target = 'j', tmux = '-D' },
  }
  for _, case in ipairs(directions) do
    vim.cmd.only()
    vim.cmd(case.split)
    vim.cmd('wincmd ' .. case.target)
    local target = vim.api.nvim_get_current_win()
    vim.cmd('wincmd ' .. case.start)
    local move = vim.fn.maparg(case.key, 'n', false, true).callback
    assert(type(move) == 'function', 'missing mapping: ' .. case.key)
    local before = #rex_calls
    move()
    assert(vim.api.nvim_get_current_win() == target, case.key .. ' should navigate inside Neovim')
    assert(#rex_calls == before, 'internal navigation should not call Rex')
    move()
    assert(#rex_calls == before + 1, case.key .. ' should hand off to Rex at the edge')
    local cmd = rex_calls[#rex_calls]
    assert(cmd[2] == 'do' and cmd[3] == '-e')
    assert(vim.tbl_contains(cmd, 'direction=' .. case.direction))
    assert(vim.tbl_contains(cmd, 'wrap=true'))
  end

  vim.cmd.only()
  splits.resize_right(3)
  assert(vim.tbl_contains(rex_calls[#rex_calls], 'amount=3'))
  assert(vim.tbl_contains(rex_calls[#rex_calls], 'block=block'))

  rex_available = false
  assert(select({ REX_SESSION = 'session', REX_BLOCK = 'block' }) == nil,
    'Rex without its CLI must fall back to Neovim')
  rex_available = true

  for _, env in ipairs({
    { TMUX = '/test/socket,1,0', TMUX_PANE = '%1' },
    { TMUX = '/test/socket,1,0', TMUX_PANE = '%1', REX_SESSION = 'session', REX_BLOCK = 'block' },
  }) do
    assert(select(env) == 'tmux', 'tmux must win, including when nested inside Rex')
    local before = #rex_calls
    for _, case in ipairs(directions) do
      vim.fn.maparg(case.key, 'n', false, true).callback()
      local cmd = tmux_calls[#tmux_calls]
      assert(cmd[1] == 'tmux' and cmd[2] == '-S' and cmd[3] == '/test/socket')
      assert(cmd[4] == 'select-pane' and cmd[5] == case.tmux)
    end
    assert(#rex_calls == before, 'tmux navigation must not call Rex')
  end

  assert(select({}) == nil)
  vim.cmd.vsplit()
  vim.cmd('wincmd h')
  local left = vim.api.nvim_get_current_win()
  vim.fn.maparg('<C-Right>', 'n', false, true).callback()
  assert(vim.api.nvim_get_current_win() ~= left, 'plain Neovim navigation must still work')
  print('smart-splits: Rex, tmux, nesting, Ctrl-arrows and plain Neovim passed')
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd('cquit 1')
else
  vim.cmd('qa!')
end
