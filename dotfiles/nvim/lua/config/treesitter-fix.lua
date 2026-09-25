local orig_get_range = vim.treesitter.get_range
vim.treesitter.get_range = function(node, source, metadata)
	local ok, result = pcall(orig_get_range, node, source, metadata)
	if ok then
		return result
	end
	return { 0, 0, 0, 0, 0, 0 }
end
