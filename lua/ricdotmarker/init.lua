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
  local icon = ""
  
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if (ok) then
    local filename = vim.fn.expand("%:t")
    icon = devicons.get_icon(filename)
  end
  
  if (buf.name == "noname") then
    return print("Nothing to mark here")
  end

  if (buf.ismarked) then
    return print("This buffer is already marked")
  end

  table.insert(Marks, { filename = buf.name, icon = icon })
  print("Buffer marked.")
end

-- TODO: refactor with some utils... also good for other functions too
M.unmark_file = function()
  local buf = M.is_marked()
  
  if (buf.name == "noname") then
    return print("Nothing to unmark here")
  end
  
  if (not buf.ismarked) then
    return print("This buffer is not marked")
  end
  
  local idx = nil
  for i, mark in ipairs(Marks) do
    if (mark.filename == buf.name) then
      idx = i
      break
    end
  end
  
  if (idx == nil) then
    return print("This buffer does not exist??????")
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
    return {
      name = "noname", -- TODO: find something better for this
    }
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
    return print("Cannot open a non selected buffer")
  end

  if (mark.line and mark.col) then
    return print("navigate to line and col of a file")
  end

  local bufnr = vim.fn.bufnr(mark.filename)

  require("ricdotmarker.window").close_window()

  vim.api.nvim_set_current_buf(bufnr)
end

M.open_window = function()
  local buf = require("ricdotmarker.window").create_window()
  local bufnr = buf["bufnr"]

  local marks = {}
  for _, mark in ipairs(Marks) do
    table.insert(marks, mark.icon .. " " .. mark.filename)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, marks)
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

  vim.cmd(
    "autocmd BufLeave <buffer> ++nested ++once lua require('ricdotmarker.window').close_window()"
  )
end

return M
