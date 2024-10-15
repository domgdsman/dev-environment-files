local wezterm = require("wezterm")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end


-- OS dependent constants

local is_darwin <const> = wezterm.target_triple:find("darwin") ~= nil
local is_linux <const> = wezterm.target_triple:find("linux") ~= nil
local is_windows <const> = wezterm.target_triple:find("windows") ~=nil


-- General settings

config.check_for_updates = true

config.window_close_confirmation = "NeverPrompt"

config.enable_tab_bar = false
config.enable_scroll_bar = false

config.hyperlink_rules = wezterm.default_hyperlink_rules()

config.max_fps = 120


-- Keybinds

local ctrl_key <const> = is_darwin and "CMD" or "CTRL"

config.keys = {
	-- Window management
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.ToggleFullScreen,
	},
	-- Copy & paste
	{
		key = "v",
		mods = ctrl_key,
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		key = "v",
		mods = ctrl_key,
		action = wezterm.action.PasteFrom("PrimarySelection"),
	},
	-- Delete
	{
		key = "Backspace",
		mods = ctrl_key,
		action = wezterm.action({
			SendString = "\x15", -- This sends the ASCII control character for "Ctrl + U", which typically deletes the whole line in many terminal applications.
		}),
	},
	{
		key = "Backspace",
		mods = "ALT",
		action = wezterm.action({
			SendString = "\x1b\x7f", -- This sends the escape sequence for "Alt + Backspace", which typically deletes the last word in many terminal applications.
		}),
	},
	-- Navigate
	{
		key = "LeftArrow",
		mods = ctrl_key,
		action = wezterm.action({
			SendString = "\x01", -- This sends the ASCII control character for "Ctrl + A", which typically moves the cursor to the beginning of the line in many terminal applications.
		}),
	},
	{
		key = "RightArrow",
		mods = ctrl_key,
		action = wezterm.action({
			SendString = "\x05", -- This sends the ASCII control character for "Ctrl + E", which typically moves the cursor to the end of the line in many terminal applications.
		}),
	},
	{
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action({
			SendString = "\x1bb", -- This sends the escape sequence for "Alt + b", which typically moves the cursor to the beginning of the previous word in many terminal applications.
		}),
	},
	{
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action({
			SendString = "\x1bf", -- This sends the escape sequence for "Alt + f", which typically moves the cursor to the beginning of the next word in many terminal applications.
		}),
	},
}

-- Windows-specific controls
if is_windows then
	-- Exit
	table.insert(config.keys, {
		key = "F4",
		mods = "ALT",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	})
	-- Solve duplicate keybind on CTRL + C
	table.insert(config.keys, {
		key = "c",
		mods = ctrl_key,
		action = wezterm.action_callback(
			function(window, pane) -- This copies to clipboard if there are mouse highlights, else default behavior for CTRL + C
				local selection = window:get_selection_text_for_pane(pane)
				if selection and #selection > 0 then
					window:copy_to_clipboard(selection)
					window:perform_action(wezterm.action.ClearSelection, pane) -- Clear the selection after copying
				else
					window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
				end
			end
		),
	})
end

config.mouse_bindings = {
	-- Copy & paste
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}


-- Terminal emulation & WSL2

if is_windows then
	local wsl_domains = wezterm.default_wsl_domains()
	
	for idx, dom in ipairs(wsl_domains) do
		if dom.name == "WSL:ubuntu2204" then
			dom.default_prog = { "zsh", "-c", "source .profile && exec zsh -i" }
		end
	end
	config.wsl_domains = wsl_domains
	config.default_domain = "WSL:ubuntu2204"
end


-- Layout & style

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16

config.initial_rows = 32
config.initial_cols = 120

config.window_background_opacity = 0.8

config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

return config
