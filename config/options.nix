{
  vim = {
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
      ignorecase = true;
      smartcase = true;

      # Editing
      timeoutlen = 300;
      linebreak = true;
      whichwrap = "<,>,[,],h,l,b,s";


      # Splitting
      splitbelow = true;
      splitright = true;

      # Don't use system clipboard by default
      clipboard = "";

      # Undo
      undofile = true;
      undolevels = 10000;
      swapfile = false;
      backup = false;

      # Disable folding by default
      foldlevel = 99;
      foldlevelstart = -1;

      # File Handling
      encoding = "utf-8";
      fileencoding = "utf-8";
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
