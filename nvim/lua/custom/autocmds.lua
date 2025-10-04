vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "go.mod", "go.sum" },
	callback = function()
		for _, client in ipairs(vim.lsp.get_active_clients()) do
			if client.name == "gopls" then
				print("Restarting gopls after go.mod change...")
				vim.lsp.stop_client(client.id)
			end
		end
		vim.defer_fn(function()
			vim.cmd("edit")
		end, 500)
	end,
	desc = "Auto-restart gopls when Go modules change",
})
