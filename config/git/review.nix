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

          local function set_codediff_highlights()
            local light = vim.o.background == "light"
            local palette = light
              and require("solarized.palette.solarized-light").solarized
              or require("solarized.palette").solarized

            vim.api.nvim_set_hl(0, "CodeDiffAdaptiveInsert", { bg = light and palette.mix_green or "#203f20" })
            vim.api.nvim_set_hl(0, "CodeDiffAdaptiveDelete", { bg = light and palette.mix_red or "#38262c" })

            if package.loaded["codediff.ui.highlights"] then
              require("codediff.ui.highlights").setup()
            end
          end

          set_codediff_highlights()

          vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("nvf_codediff_highlights", { clear = true }),
            callback = set_codediff_highlights,
          })
          vim.api.nvim_create_autocmd("OptionSet", {
            group = "nvf_codediff_highlights",
            pattern = "background",
            callback = set_codediff_highlights,
          })
        '';
        setupModule = "codediff";
        setupOpts.highlights = {
          line_insert = "CodeDiffAdaptiveInsert";
          line_delete = "CodeDiffAdaptiveDelete";
        };
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
