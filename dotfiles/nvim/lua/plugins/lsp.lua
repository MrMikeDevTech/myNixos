return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "saghen/blink.cmp" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = capabilities })

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			vim.lsp.config("nil_ls", {
				settings = {
					["nil"] = {
						formatting = { command = { "nixfmt" } },
					},
				},
			})

			local eslint_error_notified = {}
			vim.lsp.config("eslint", {
				settings = {
					workingDirectory = { mode = "auto" },
				},
				handlers = {
					["textDocument/diagnostic"] = function(err, result, ctx, config)
						if err then
							local key = ctx.bufnr .. ":" .. tostring(err.message)
							if not eslint_error_notified[key] then
								eslint_error_notified[key] = true
								vim.notify("eslint: " .. tostring(err.message), vim.log.levels.WARN, { title = "LSP" })
							end
							return
						end
						return vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
					end,
				},
			})

			local function tsdk_valido(dir)
				return dir and dir ~= "" and vim.fn.filereadable(dir .. "/tsserverlibrary.js") == 1
			end

			vim.lsp.config("astro", {
				before_init = function(_, config)
					local tsdk = require("lspconfig.util").get_typescript_server_path(config.root_dir)
					if not tsdk_valido(tsdk) then
						tsdk = vim.env.NVIM_TSDK
					end
					config.init_options = config.init_options or {}
					config.init_options.typescript = config.init_options.typescript or {}
					config.init_options.typescript.tsdk = tsdk
				end,
			})

			vim.lsp.enable({
				"gopls",
				"clangd",
				"ts_ls",
				"astro",
				"pyright",
				"ruff",
				"lua_ls",
				"nil_ls",
				"taplo",
				"jsonls",
				"html",
				"cssls",
				"eslint",
				"tinymist",
				"prismals",
				"marksman",
				"tailwindcss",
				"yamlls",
				"bashls",
				"dockerls",
				"docker_compose_language_service",
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
				callback = function(event)
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
					end

					map("n", "gd", vim.lsp.buf.definition, "LSP: ir a definición")
					map("n", "gr", vim.lsp.buf.references, "LSP: referencias")
					map("n", "K", vim.lsp.buf.hover, "LSP: hover")
					map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: renombrar")
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
					map("n", "[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, "Diagnóstico anterior")
					map("n", "]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, "Diagnóstico siguiente")
				end,
			})
		end,
	},
}
