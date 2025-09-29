# imeflow.nvim

**Seamless IME switching for Neovim on Windows**  
Automatically switches to **Chinese IME** when entering Insert mode, and back to **English IME** when leaving it—no manual switching required.

---

## ✨ Features

- 🔄 **Automatic IME toggling**
  - `InsertEnter` → switches to Chinese (default: `2052`)
  - `InsertLeave`, `Normal`, `Visual`, `Command` → switches to English (default: `1033`)
- ⚙️ **Fully configurable**
  - Enable/disable all events with a single toggle
  - Enable or disable switching for individual events (`VimEnter`, `InsertEnter`, `InsertLeave`, `VimLeave`)
  - Customize IME language codes per event
  - Specify your own path to `im-select.exe`
- ⌨️ **Manual control**
  - Toggle with a custom key mapping (e.g. `<leader>ti`)
  - Or use the `:ImeflowToggle` command
- 🔎 **Status query**
  - Use `:ImeflowStatus` to show current state:
    - Global enable/disable
    - Individual event states (`VimEnter`, `InsertEnter`, `InsertLeave`, `VimLeave`)
- 🔍 **Zero-configuration path detection**
  - If `im-select.exe` is placed in the plugin directory, no path setup is needed
- 💤 **Supports lazy-loading**
  - Designed to load on first `InsertEnter` for performance
  - With lazy-loading, Neovim startup time can drop from ~100ms to ~50ms
- 🛠️ **Windows only**
  - This plugin targets Windows users exclusively

---

## 📦 Requirements

| Platform | Requirement                              |
| -------- | ---------------------------------------- |
| Windows  | [`im-select`](https://github.com/daipeihust/im-select) executable |
| Neovim   | 0.9 or newer (Lua API for `vim.fn` & `vim.api`) |

> **Tip:** `im-select.exe` is bundled inside the plugin if you use the default Lazy.nvim installation path.

---

## 🚀 Installation (Lazy.nvim)

```lua
{
  "396458015/imeflow.nvim",
  event = "InsertEnter",   -- Lazy-load the plugin when entering Insert mode for the first time
  opts = {
    -- path = "D:/tools/im-select.exe",  -- (Optional) Absolute path to im-select.exe if not using the default bundled one
    enable = true,          -- Start enabled (default: true)
    mapping = "<leader>ti", -- Optional toggle mapping

    -- Optional per-event enable/disable
    VimEnter    = true,    -- Switch to English input method when Neovim starts
    InsertEnter = true,    -- Switch to Chinese input method when entering Insert mode
    InsertLeave = true,    -- Switch back to English when leaving Insert mode
    VimLeave    = true,    -- Switch to English when exiting Neovim
  },
}
```

If you use your own `im-select.exe`

```lua
opts = {
  path = "C:/my-tools/im-select.exe",
  -- …other flags
}
```

---

## ⚡ Commands

:ImeflowToggle → Toggle the plugin (enabled/disabled)  
:ImeflowStatus → Show current plugin status including all events

---

## ⚠️ Note

This plugin relies on a custom helper function `nvim_create_augroups`.  
Make sure to define it in your `init.lua` before using the plugin:

```lua

local function nvim_create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        vim.api.nvim_command("augroup " .. group_name)
        vim.api.nvim_command("autocmd!")
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten { "autocmd", def }, " ")
            vim.api.nvim_command(command)
        end
        vim.api.nvim_command "augroup END"
    end
end
```

---

## 🙏 Special Thanks

Huge thanks to [im-select](https://github.com/daipeihust/im-select) for providing the core IME switching functionality used in this program.

