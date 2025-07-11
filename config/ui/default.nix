{lib, ...}: let
  inherit (lib.nvim.dag) entryBefore;
in {
  imports = [
    ./borders.nix
    ./bufferline.nix
    ./dashboard.nix
    ./folding.nix
    ./lualine.nix
    ./mini.icons.nix
    ./noice.nix
    ./smartcolumn.nix
  ];

  vim.luaConfigRC.ui-utils = entryBefore ["lazyConfigs"] ''
    local libui = {}

    libui.root = function(width)
      local root = Snacks.git.get_root() or vim.uv.cwd()
      local path = vim.fn.fnamemodify(root, ":~")
      path = libui.pathshorten(path, width)
      return path
    end

    libui.pathshorten = function(path, width, prefix)
      if prefix and path:sub(1, #prefix) == prefix then
        path = path:sub(#prefix + 2) -- extra character to remove '/'
      end

      if not width then
        return path
      end

      if #path > width then
        path = vim.fn.pathshorten(path)
      end

      if #path > width then
        local head = vim.fn.fnamemodify(path, ":h")
        local tail = vim.fn.fnamemodify(path, ":t")
        if head and tail then
          tail = tail:sub(-(width - #head - 2))
          path = head .. "/…" .. tail
        end
      end

      return path
    end
  '';
}
