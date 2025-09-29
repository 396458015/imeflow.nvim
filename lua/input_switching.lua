local M = {}
-- ╭────────────────────────────────────────────────────────-─╮
-- │ opts 说明：                                              │
-- │ • path    : im-select 可执行文件路径(仅文件名或完整路径) │
-- │ • enable  : 开启或关闭(true/false)                       │
-- │ • mapping : 自定义Toggle快捷键                           │
-- │ • 命令模式: "ImeflowToggle", "ImeflowStatus"             │
-- ╰────────────────────────────────────────────────────────-─╯

M.config = {}
M.enabled = true -- 总开关状态

function M.setup(opts)
  opts = opts or {}
  M.config = opts

  -- 初始启用状态由 opts.enabled 决定，默认 true
  if opts.enabled ~= nil then
    M.enabled = opts.enabled
  end

  -- 如果用户配置了快捷键，则绑定
  if opts.mapping then
    vim.keymap.set("n", opts.mapping, function()
      M.toggle()
    end, { desc = "Toggle imeflow.nvim" })
  end

  -- 注册命令 :ImeflowToggle
  vim.api.nvim_create_user_command("ImeflowToggle", function()
    M.toggle()
  end, { desc = "Toggle imeflow.nvim enable/disable" })

  -- 注册命令 :ImeflowStatus
  vim.api.nvim_create_user_command("ImeflowStatus", function()
    M.status()
  end, { desc = "Show imeflow.nvim current status" })

  -- 初次应用
  M.apply()
end

-- 应用 autocmd
function M.apply()
  local opts = M.config

  -- 获取当前插件所在目录，自动拼接 im-select.exe 路径
  local plugin_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
  local root_dir = vim.fs.dirname(plugin_dir:sub(1, #plugin_dir - 1))
  local default_path = root_dir .. "/im-select.exe"
  local exe = opts.path or default_path

  local silent_prefix = (opts.silent == false) and "!" or "silent !"

  local codes = vim.tbl_extend("force", {
    VimEnter    = "1033",
    InsertEnter = "2052",
    InsertLeave = "1033",
    VimLeave    = "1033",
  }, opts.codes or {})

  local enable = vim.tbl_extend("force", {
    VimEnter    = true,
    InsertEnter = true,
    InsertLeave = true,
    VimLeave    = true,
  }, opts)

  -- 如果总开关关掉，全部禁用
  if not M.enabled then
    enable = { VimEnter=false, InsertEnter=false, InsertLeave=false, VimLeave=false }
  end

  local defs = {}
  local function add(evt)
    if enable[evt] then
      table.insert(defs, { evt, "*",
        string.format('%s"%s" %s', silent_prefix, exe, codes[evt])
      })
    end
  end

  add("VimEnter")
  add("InsertEnter")
  add("InsertLeave")
  add("VimLeave")

  -- 清空再重建
  vim.api.nvim_create_augroup("input_switching", { clear = true })
  for _, d in ipairs(defs) do
    vim.api.nvim_create_autocmd(d[1], {
      pattern = d[2],
      command = d[3],
      group = "input_switching",
    })
  end

  vim.notify("imeflow.nvim " .. (M.enabled and "enabled" or "disabled"))
end

-- toggle 开关
function M.toggle()
  M.enabled = not M.enabled
  M.apply()
end

-- 查询状态，包括总开关和每个事件状态
function M.status()
  local opts = M.config
  local enable = vim.tbl_extend("force", {
    VimEnter    = true,
    InsertEnter = true,
    InsertLeave = true,
    VimLeave    = true,
  }, opts)

  if not M.enabled then
    enable = { VimEnter=false, InsertEnter=false, InsertLeave=false, VimLeave=false }
  end

  local status_table = {
    enabled      = M.enabled,
    VimEnter     = enable.VimEnter,
    InsertEnter  = enable.InsertEnter,
    InsertLeave  = enable.InsertLeave,
    VimLeave     = enable.VimLeave,
  }

  local msg = string.format(
    "imeflow.nvim status:\n  Global: %s\n  VimEnter: %s\n  InsertEnter: %s\n  InsertLeave: %s\n  VimLeave: %s",
    (status_table.enabled and "ENABLED ✅" or "DISABLED ❌"),
    (status_table.VimEnter and "ON" or "OFF"),
    (status_table.InsertEnter and "ON" or "OFF"),
    (status_table.InsertLeave and "ON" or "OFF"),
    (status_table.VimLeave and "ON" or "OFF")
  )
  vim.notify(msg, vim.log.levels.INFO)

  return status_table
end

return M
