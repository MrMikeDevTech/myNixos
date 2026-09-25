local signs = {
	[vim.diagnostic.severity.ERROR] = " ",
	[vim.diagnostic.severity.WARN] = " ",
	[vim.diagnostic.severity.INFO] = " ",
	[vim.diagnostic.severity.HINT] = "󰌵 ",
}

vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "■", source = "if_many" },
	virtual_lines = false,
	signs = { text = signs },
	underline = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = "if_many", header = "", prefix = "" },
})

local function toggle_modo()
	local cfg = vim.diagnostic.config()
	local a_lineas = not cfg.virtual_lines
	vim.diagnostic.config({
		virtual_lines = a_lineas and { current_line = false } or false,
		virtual_text = (not a_lineas) and { spacing = 2, prefix = "■", source = "if_many" } or false,
	})
	vim.notify("Diagnósticos: " .. (a_lineas and "líneas completas" or "texto en línea"))
end

local function toggle_encendido()
	local on = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not on)
	vim.notify("Diagnósticos " .. (on and "desactivados" or "activados"))
end

local map = vim.keymap.set
map("n", "<leader>dl", toggle_modo, { desc = "Diagnósticos: cambiar modo de vista" })
map("n", "<leader>dt", toggle_encendido, { desc = "Diagnósticos: activar/desactivar" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Diagnósticos: ver mensaje completo" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnósticos: listar en loclist" })
