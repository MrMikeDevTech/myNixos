return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			notifier = {
				enabled = true,
			},
			dashboard = {
				enabled = true,
				preset = {
					header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
					keys = {
						{ icon = " ", key = "f", desc = "Buscar archivo", action = ":Telescope find_files" },
						{ icon = " ", key = "n", desc = "Archivo nuevo", action = ":ene | startinsert" },
						{ icon = " ", key = "g", desc = "Buscar texto", action = ":Telescope live_grep" },
						{ icon = " ", key = "r", desc = "Recientes", action = ":Telescope oldfiles" },
						{ icon = " ", key = "c", desc = "Config", action = ":e ~/myNixos/dotfiles/nvim/init.lua" },
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Salir", action = ":qa" },
					},
				},
			},
		},
	},
}
