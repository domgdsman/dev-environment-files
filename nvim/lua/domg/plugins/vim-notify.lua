return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	disable = true,
	config = function()
		vim.notify = require("notify")
	end,
}
