{
  vim = {
    languages.lua.enable = true;

    lsp.servers.lua-language-server.settings = {
      Lua.diagnostics.globals = [ "vim" ];
    };

    formatter.conform-nvim.setupOpts.formatters.stylua.prepend_args = [
      "--indent-type"
      "Spaces"
      "--indent-width"
      "2"
    ];
  };
}
