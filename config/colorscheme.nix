{
  vim.theme = {
    enable = true;
    name = "solarized";
    style = "solarized-winter";
    extraConfig = ''
      if vim.fn.system("defaults read -g AppleInterfaceStyle") == "Dark\n" then
        vim.opt.background = "dark"
      else
        vim.opt.background = "light"
      end
    '';
  };
}
