return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			{ "s1n7ax/nvim-window-picker", version = "2.*" },
		},
		cmd = "Neotree",
		event = "VimEnter",
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorador: toggle" },
			{ "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Explorador: toggle", mode = { "n", "i" } },
			{ "<leader>f", "<cmd>Neotree focus<cr>", desc = "Explorador: enfocar" },
		},
		opts = {
			close_if_last_window = true,
			filesystem = {
				follow_current_file = { enabled = true },
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)
			vim.cmd("Neotree show")
		end,
	},
}
