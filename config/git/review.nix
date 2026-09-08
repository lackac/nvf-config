{ pkgs, ... }:
{
  vim = {
    startPlugins = [ "nui-nvim" ];

    lazy.plugins = {
      "codediff.nvim" = {
        package = pkgs.vimPlugins.codediff-nvim;
        cmd = [ "CodeDiff" ];
        beforeSetup = ''
          vim.env.CODEDIFF_WATCHER_PATH = "${pkgs.codediff-watcher}/bin/codediff-watcher"
        '';
        setupModule = "codediff";
      };

      "review.nvim" = {
        package = pkgs.vimPlugins.review-nvim;
        cmd = [ "Review" ];
        setupModule = "review";
        keys = [
          {
            mode = "n";
            key = "<leader>gr";
            action = "<cmd>Review<cr>";
            desc = "Review Changes";
          }
          {
            mode = "n";
            key = "<leader>gR";
            action = "<cmd>Review commits<cr>";
            desc = "Review Commits";
          }
        ];
      };
    };
  };
}
