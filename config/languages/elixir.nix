{
  pkgs,
  ...
}:
{
  vim.languages.elixir = {
    enable = true;
    elixir-tools.enable = false;
    format.enable = false;
    lsp.enable = false;
  };

  vim.formatter.conform-nvim = {
    enable = true;
    setupOpts = {
      formatters.mix.command = "${pkgs.beamPackages.elixir}/bin/mix";
      formatters_by_ft.elixir = [ "mix" ];
    };
  };

  vim.lsp.servers.expert = {
    cmd = [
      "/Users/lackac/Code/elixir-lang/expert/apps/expert/burrito_out/expert_darwin_arm64"
      "--stdio"
    ];
    root_markers = [
      "mix.exs"
      ".git"
    ];
    filetypes = [
      "elixir"
      "eelixir"
      "heex"
    ];
  };
}
