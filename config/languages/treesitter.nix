{pkgs, ...}: {
  vim.treesitter = {
    enable = true;

    autotagHtml = true;
    context = {
      enable = true;
      setupOpts = {
        mode = "cursor"; # or "topline"
        max_lines = 3;
      };
    };
    indent.enable = true;
    highlight.enable = true;
    incrementalSelection.enable = true;

    mappings.incrementalSelection = {
      incrementByNode = "<C-S>";
      decrementByNode = "<C-BS>";
      init = null;
      incrementByScope = null;
    };

    grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      # these are languages I might need to browse occasionally but don't need more support than a grammar
      asm
      beancount
      c
      c-sharp
      clojure
      cpp
      csv
      diff
      dockerfile
      editorconfig
      elm
      fish
      git_config
      gitcommit
      gitignore
      gleam
      go
      http
      java
      jinja
      jinja_inline
      jq
      json
      julia
      just
      kotlin
      latex
      ledger
      liquid
      make
      mermaid
      nginx
      objc
      ocaml
      perl
      php
      r
      rust
      scala
      sql
      svelte
      swift
      toml
      vue
      xml
      zig
    ];
  };
}
