local wezterm = require("wezterm")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- OS dependent constants

local is_darwin <const> = wezterm.target_triple:find("darwin") ~= nil
local is_linux <const> = wezterm.target_triple:find("linux") ~= nil
local is_windows <const> = wezterm.target_triple:find("windows") ~= nil

-- General settings

config.check_for_updates = true

config.window_close_confirmation = "NeverPrompt"

config.enable_tab_bar = false
config.enable_scroll_bar = false
config.swallow_mouse_click_on_window_focus = true -- IMPORTANT: Do not propagate mouse click on window focus change

-- IMPORTANT: Inside tmux have to hold SHIFT key down when clicking on a link to open it in the browser
config.hyperlink_rules = {
	-- Matches: a URL in parens: (URL)
	{
		regex = "\\((\\w+://\\S+)\\)",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in brackets: [URL]
	{
		regex = "\\[(\\w+://\\S+)\\]",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in curly braces: {URL}
	{
		regex = "\\{(\\w+://\\S+)\\}",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in angle brackets: <URL>
	{
		regex = "<(\\w+://\\S+)>",
		format = "$1",
		highlight = 1,
	},
	-- Then handle URLs not wrapped in brackets
	{
		regex = "\\b\\w+://\\S+[/a-zA-Z0-9-]+", -- modified: removed `)` which was considered part of the URL
		format = "$0",
	},
	-- implicit mailto link
	{
		regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
		format = "mailto:$0",
	},
}

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
	{
		key = "B",
		mods = ctrl_key,
		action = wezterm.action.EmitEvent("toggle-opacity"),
	},
	-- Copy & paste
	{
		key = "v",
		mods = ctrl_key,
		action = wezterm.action.PasteFrom("Clipboard"),
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
	-- Define multiple key mappings
	local key_mappings = {
		-- Exit
		{ key = "F4", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	}

	-- Insert each key mapping into config.keys
	for _, mapping in ipairs(key_mappings) do
		table.insert(config.keys, mapping)
	end

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
		if dom.name == "WSL:Ubuntu-22.04" then
			dom.default_prog = { "zsh", "-c", "source .profile && exec zsh -i" }
		end
	end
	config.wsl_domains = wsl_domains
	config.default_domain = "WSL:Ubuntu-22.04"
end

-- Layout & style

config.font = wezterm.font("MesloLGS NF")
config.font_size = is_darwin and 14.0 or 12.0

config.initial_rows = 32
config.initial_cols = 120
config.window_background_opacity = 1.0

-- toggle window background opacity
wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.6
	else
		overrides.window_background_opacity = nil
	end
	window:set_config_overrides(overrides)
end)

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
