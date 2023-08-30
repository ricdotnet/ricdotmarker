local W = {}

Window = nil

W.create_window = function()
  -- get the editor's max width and height
  local width = 100
  local height = 30
  -- local borderchars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
  local borderchars = RicdotmarkerConfig.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  local popup = require("plenary.popup")

  -- settings for the fzf window
  local opts = {
    title = RicdotmarkerConfig.title or "ricdotmarker",
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor(((vim.o.columns - width) / 2) - 1),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
  }
  
  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_id = popup.create(bufnr, opts)
  
  local marks = Marks
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, marks)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "ricdotmarker")
  
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
  
  Window = win_id
end

W.close_window = function()
  vim.api.nvim_win_close(Window, true)

  Window = nil
end

return W
