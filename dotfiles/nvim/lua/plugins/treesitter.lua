return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "nix", "bash", "json", "jsonc", "toml", "yaml",
          "markdown", "markdown_inline", "go", "gomod", "c", "cpp",
          "python", "javascript", "typescript", "tsx", "astro",
          "html", "css", "vim", "vimdoc", "typst", "prisma", "dockerfile",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
