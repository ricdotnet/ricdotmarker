local utils = require("ricdotmarker.utils")
local w = require("ricdotmarker.window")

local M = {}

RicdotmarkerConfig = {}
Marks = {}

M.setup = function(config)
  local ok, _ = pcall(require, "plenary")
  if not ok then
    return print("Ricdotmarker needs plenary to work")
  end

  if (config) then
    RicdotmarkerConfig = config
  end

  vim.keymap.set(
    "n",
    "<Leader>rdm",
    ":lua require('ricdotmarker').open_window()<CR>",
    { silent = true }
  )
  vim.keymap.set(
    "n",
    "<Leader>mf",
    ":lua require('ricdotmarker').mark_file()<CR>",
    { silent = true }
  )
  vim.keymap.set(
    "n",
    "<Leader>umf",
    ":lua require('ricdotmarker').unmark_file()<CR>",
    { silent = true }
  )
  vim.keymap.set(
    "n",
    "<Leader>ml",
    ":lua require('ricdotmarker').mark_line()<CR>",
    { silent = true }
  )

  vim.api.nvim_create_user_command('Rdm', function(opts)
    if (opts.args == "mark") then
      M.mark_file()
    end

    if (opts.args == "unmark") then
      M.unmark_file()
    end
  end, { nargs = 1 })
end

M.mark_file = function()
  local buf = M.is_marked()

  local filename = vim.fn.expand("%:t")
  local icon = utils.get_icon(filename)

  if (buf == nil) then
    return print("This is not a buffer that you can mark")
  end

  if (buf.ismarked) then
    return print("This buffer is already marked")
  end

  table.insert(Marks, { display_name = utils.relative_path(buf.name), filename = buf.name, icon = icon })
  print("Buffer marked.")
end

-- TODO: refactor with some utils... also good for other functions too
M.unmark_file = function()
  local buf = M.is_marked()

  if (buf == nil) then
    return print("This buffer has not been marked yet")
  end

  if (not buf.ismarked) then
    return print("This buffer is not marked")
  end
  local idx = utils.get_index(Marks, buf.name, "filename")

  if (idx == -1) then
    return print("You did not select a valid buffer")
  end

  table.remove(Marks, idx)
  print("Buffer unmarked")
end

M.mark_line = function()
  print("marking line")
end

M.is_marked = function()
  -- local bufname = vim.api.nvim_buf_get_name(0)
  local bufname = vim.fn.expand("%")
  local ismarked = false

  if (bufname == "." or bufname == "" or bufname == nil) then
    return nil
  end

  for _, mark in ipairs(Marks) do
    if (mark.filename == bufname) then
      ismarked = true
      break
    end
  end

  return {
    name = bufname,
    ismarked = ismarked,
  }
end

M.open_buffer = function()
  local line = vim.fn.line('.')
  local mark = Marks[line]

  if (not mark or mark == nil or mark == "") then
    return print("Cannot open a non marked buffer")
  end

  if (mark.line and mark.col) then
    return print("navigate to line and col of a file")
  end

  local bufnr = vim.fn.bufnr(mark.filename)

  w.close_window()

  vim.api.nvim_set_current_buf(bufnr)
end

M.open_window = function()
  local buf = w.create_window()
  local bufnr = buf["bufnr"]

  local marks = {}
  for _, mark in ipairs(Marks) do
    table.insert(marks, "> " .. mark.icon .. " " .. mark.display_name)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, #marks - 2, false, marks)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "ricdotmarker")

  -- set default keymaps
  if (RicdotmarkerConfig.keymaps == nil) then
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<ESC>",
      ":lua require('ricdotmarker.window').close_window()<CR>",
      { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<CR>",
      ":lua require('ricdotmarker').open_buffer()<CR>",
      { silent = true }
    )
  end

  vim.cmd("set nomodifiable")
  vim.cmd(
    "autocmd BufLeave <buffer> ++nested ++once lua require('ricdotmarker.window').close_window()"
  )
end

return M
