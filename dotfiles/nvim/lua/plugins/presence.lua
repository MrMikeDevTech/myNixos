return {
	{
		"andweeb/presence.nvim",
		lazy = false,
		opts = {
			neovim_image_text = "Editando en Neovim",
			editing_text = "Editando %s",
			workspace_text = "En %s",
			reading_text = "Leyendo %s",
			show_time = true,
		},
		config = function(_, opts)
			require("presence").setup(opts)
		end,
	},
}
