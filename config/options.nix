{
  vim = {
    lineNumberMode = "relNumber";
    searchCase = "smart";
    preventJunkFiles = true;
    undoFile.enable = true;

    options = {
      # 2-space indents
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      autoindent = true;
      smartindent = true;
      breakindent = false;

      # Searching
      hlsearch = true;
      incsearch = true;

      # Editing
      timeoutlen = 300;
      linebreak = true;
      whichwrap = "<,>,[,],h,l,b,s";

      # Splitting
      splitbelow = true;
      splitright = true;

      # Don't use system clipboard by default
      clipboard = "";

      # Disable folding by default
      foldlevel = 99;
      foldlevelstart = -1;

      # Terminal title
      title = true;
      titlestring = ''nvim - %{expand("%:~")}'';

      # Display
      cursorline = true;
      scrolloff = 4;
      sidescrolloff = 8;
      fillchars = "eob: ";
      listchars = "tab:▸ ,trail:·,extends:>,precedes:<";
      showbreak = "↳";
      termguicolors = true;
    };
  };
}
