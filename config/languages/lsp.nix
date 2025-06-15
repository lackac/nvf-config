{
  vim.lsp = {
    enable = true;

    formatOnSave = true;
    inlayHints.enable = true;

    otter-nvim = {
      enable = true;
      mappings = {
        toggle = "<leader>uo";
      };
    };

    trouble = {
      enable = true;
      mappings = {
        workspaceDiagnostics = "<leader>xx";
        documentDiagnostics = "<leader>xX";
        lspReferences = "<leader>cS";
        quickfix = "<leader>xQ";
        locList = "<leader>xL";
        symbols = "<leader>cs";
      };
    };

    mappings = {
      # borrow mappings from LazyVim
      goToDeclaration = "gD";
      goToDefinition = "gd";
      goToType = "gy";
      listImplementations = "gI";
      listReferences = "gr";
      nextDiagnostic = null;
      previousDiagnostic = null;
      openDiagnosticFloat = null;
      documentHighlight = null;
      listDocumentSymbols = null;
      addWorkspaceFolder = null;
      removeWorkspaceFolder = null;
      listWorkspaceFolders = null;
      listWorkspaceSymbols = null;
      hover = "K";
      signatureHelp = "gK";
      renameSymbol = "<leader>cr";
      codeAction = "<leader>ca";
      format = null;
      toggleFormatOnSave = null;
    };
  };
}
