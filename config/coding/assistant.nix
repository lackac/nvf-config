{
  vim.assistant.avante-nvim = {
    enable = true;

    setupOpts = {
      provider = "claude";

      providers = {
        claude = {
          model = "claude-sonnet-4-20250514";
        };
      };
    };
  };
}
