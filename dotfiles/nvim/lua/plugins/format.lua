return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = "ConformInfo",
		opts = {
			formatters_by_ft = {
				go = { "gofmt" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				javascript = { "prettier", "eslint_d" },
				javascriptreact = { "prettier", "eslint_d" },
				typescript = { "prettier", "eslint_d" },
				typescriptreact = { "prettier", "eslint_d" },
				astro = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
				yaml = { "prettier" },
				python = { "ruff_format" },
				lua = { "stylua" },
				nix = { "nixfmt" },
				toml = { "taplo" },
			},
			format_on_save = function(bufnr)
				local conform = require("conform")
				local formatters = conform.list_formatters_for_buffer(bufnr)
				for _, name in ipairs(formatters) do
					if conform.get_formatter_info(name, bufnr).available then
						return { lsp_format = "fallback", timeout_ms = 1000 }
					end
				end
				return nil
			end,
		},
	},
}
