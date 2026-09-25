local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.undofile = true
opt.clipboard = "unnamedplus"
opt.updatetime = 250

vim.filetype.add({
	filename = {
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
	},
	pattern = {
		["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
	},
})

vim.api.nvim_create_autocmd("SwapExists", {
	callback = function()
		local pid = vim.fn.swapinfo(vim.v.swapname).pid
		if pid and pid > 0 and pid ~= vim.fn.getpid() then
			vim.fn.system({ "kill", "-0", tostring(pid) })
			if vim.v.shell_error ~= 0 then
				vim.v.swapchoice = "e"
			end
		end
	end,
})
