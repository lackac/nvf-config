{
  config,
  lib,
  ...
}: let
  cfg = config.nvf-config;

  languageModules = [
    "elixir"
    "lua"
    "markdown"
    "nix"
    "ruby"
  ];

  extraLanguages = [
    "bash"
    "clang"
    "css"
    "gleam"
    "go"
    "html"
    "python"
    "rust"
    "sql"
    "terraform"
    "ts"
    "typst"
  ];

  languageImports = map (lang: ./${lang}.nix) languageModules;

  enabledExtraLanguages =
    if cfg.enabledLanguages == null
    then extraLanguages
    else builtins.filter (lang: builtins.elem lang cfg.enabledLanguages) extraLanguages;

  isEnabled = lang: cfg.enabledLanguages == null || builtins.elem lang cfg.enabledLanguages;

  languageEnableOverrides = lib.genAttrs languageModules (lang: {
    enable = lib.mkForce (isEnabled lang);
  });
in {
  imports =
    [
      ./diagnostics.nix
      ./treesitter.nix
      ./lsp.nix
    ]
    ++ languageImports;

  config = lib.mkMerge [
    {
      vim.languages = {
        enableTreesitter = true;
        enableFormat = true;
        enableExtraDiagnostics = true;
      };
    }

    (lib.mkIf (cfg.enabledLanguages != null) {
      vim.languages = languageEnableOverrides;
    })

    {
      vim.languages = lib.genAttrs enabledExtraLanguages (_: {
        enable = true;
      });
    }
  ];
}
