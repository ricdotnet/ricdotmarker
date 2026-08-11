local utils = require 'ricdotmarker.utils'
local w = require 'ricdotmarker.window'

local M = {}

RicdotmarkerConfig = {}
Marks = {}

M.setup = function(config)
  local ok, _ = pcall(require, 'plenary')
  if not ok then
    return print 'ricdotmarker needs plenary to work'
  end

  if config then
    RicdotmarkerConfig = config
  end

  vim.keymap.set('n', '<leader>mo', ':lua require("ricdotmarker").open_window()<Enter>', { silent = true })
  vim.keymap.set('n', '<leader>mm', ':lua require("ricdotmarker").mark_buffer()<Enter>', { silent = true })
  vim.keymap.set('n', '<leader>mu', ':lua require("ricdotmarker").unmark_buffer()<Enter>', { silent = true })
  vim.keymap.set('n', '<leader>ml', ':lua require("ricdotmarker").mark_line()<Enter>', { silent = true })

  vim.api.nvim_create_user_command('Rdm', function(opts)
    if opts.args == 'mark' then
      M.mark_buffer()
    end

    if opts.args == 'unmark' then
      M.unmark_buffer()
    end
  end, { nargs = 1 })
end

M.mark_buffer = function()
  local buf = M.is_marked()

  local filename = vim.fn.expand '%:t'
  local icon = utils.get_icon(filename)

  if buf == nil then
    return print 'this is not a buffer that you can mark'
  end

  if buf.ismarked then
    return print 'this buffer is already marked'
  end

  table.insert(Marks, { display_name = utils.relative_path(buf.name), filename = buf.name, icon = icon })
  print 'buffer marked'
end

-- TODO: refactor with some utils... also good for other functions too
M.unmark_buffer = function()
  local buf = M.is_marked()

  if buf == nil then
    return print 'this buffer has not been marked yet'
  end

  if not buf.ismarked then
    return print 'this buffer is not marked'
  end
  local idx = utils.get_index(Marks, buf.name, 'filename')

  if idx == -1 then
    return print 'you did not select a valid buffer'
  end

  table.remove(Marks, idx)
  print 'buffer unmarked'
end

M.mark_line = function()
  print 'marking line'
end

M.is_marked = function()
  -- local bufname = vim.api.nvim_buf_get_name(0)
  local bufname = vim.fn.expand '%'
  local ismarked = false

  if bufname == '.' or bufname == '' or bufname == nil then
    return nil
  end

  for _, mark in ipairs(Marks) do
    if mark.filename == bufname then
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
  local line = vim.fn.line '.'
  local mark = Marks[line]

  if not mark or mark == nil or mark == '' then
    return print 'cannot open a non marked buffer'
  end

  if mark.line and mark.col then
    return print 'navigate to line and col of a file'
  end

  local bufnr = vim.fn.bufnr(mark.filename)

  w.close_window()

  vim.api.nvim_set_current_buf(bufnr)
end

M.open_window = function()
  local buf = w.create_window()
  local bufnr = buf['bufnr']

  vim.keymap.set('n', '<Left>', '<Nop>')
  vim.keymap.set('n', '<Right>', '<Nop>')

  -- set default keymaps
  if RicdotmarkerConfig.keymaps == nil then
    vim.api.nvim_buf_set_keymap(
      bufnr,
      'n',
      'q',
      ':lua require("ricdotmarker.window").close_window()<Enter>',
      { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      bufnr,
      'n',
      '<ESC>',
      ':lua require("ricdotmarker.window").close_window()<Enter>',
      { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      bufnr,
      'n',
      '<Enter>',
      ':lua require("ricdotmarker").open_buffer()<Enter>',
      { silent = true }
    )
  end

  local marks = {}

  for _, mark in ipairs(Marks) do
    local icon = mark.icon or '#'
    table.insert(marks, '> ' .. icon .. ' ' .. mark.display_name)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, marks)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'ricdotmarker')

  for row, mark in ipairs(Marks) do
    local icon = mark.icon or '#'

    vim.api.nvim_buf_add_highlight(bufnr, -1, 'Comment', row - 1, 0, 2)
    vim.api.nvim_buf_add_highlight(bufnr, -1, 'Special', row - 1, 2, 2 + #icon)
    vim.api.nvim_buf_add_highlight(bufnr, -1, 'Normal', row - 1, 3 + #icon, -1)
  end

  vim.cmd 'set nomodifiable'
  vim.cmd 'autocmd BufLeave <buffer> ++nested ++once lua require("ricdotmarker.window").close_window()'
end

return M
