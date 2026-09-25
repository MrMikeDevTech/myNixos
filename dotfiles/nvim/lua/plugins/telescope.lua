return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>tf", "<cmd>Telescope find_files<cr>", desc = "Buscar archivos" },
      { "<leader>tg", "<cmd>Telescope live_grep<cr>", desc = "Buscar texto" },
      { "<leader>tb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>th", "<cmd>Telescope help_tags<cr>", desc = "Ayuda" },
    },
  },
}
