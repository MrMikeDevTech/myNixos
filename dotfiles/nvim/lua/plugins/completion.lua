return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "1.*",
		opts = {
			keymap = {
				preset = "default",
			},
			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					treesitter_highlighting = false,
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
	},
}
