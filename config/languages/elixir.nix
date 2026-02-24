{
  vim.languages.elixir = {
    enable = true;
    elixir-tools.enable = false;
    lsp.enable = false;
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
