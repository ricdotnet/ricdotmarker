local W = {}

Window = nil

W.create_window = function()
  -- get the editor's max width and height
  local win_width = vim.api.nvim_win_get_width(0)
  local win_height = vim.api.nvim_win_get_height(0)

  local min_width = 60
  local min_height = 10

  local col = math.floor(((vim.o.columns - min_width) / 2) - 1)

  -- print("w: " .. win_width .. " h: " .. win_height)
  print((vim.o.columns - min_width) / 2 .. " " .. win_width)

  if (win_width < 70) then
    -- min_width = math.floor(win_width * 0.9) - 2
    min_width = win_width - 10
    col = 6
  end

  if (win_height < 30) then
    min_height = math.floor(win_height * 0.9) - 2
  end

  -- local borderchars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
  local borderchars = RicdotmarkerConfig.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  local popup = require("plenary.popup")

  -- settings for the fzf window
  local opts = {
    title = RicdotmarkerConfig.title or "ricdotmarker",
    line = math.floor(((vim.o.lines - min_height) / 2) - 1),
    col = col,
    minwidth = min_width,
    minheight = min_height,
    borderchars = borderchars,
  }

  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_id = popup.create(bufnr, opts)

  Window = win_id

  vim.api.nvim_win_set_option(win_id, "number", true)

  return {
    bufnr = bufnr,
    win_id = win_id,
  }
end

W.close_window = function()
  vim.api.nvim_win_close(Window, true)
  vim.cmd("set modifiable")

  Window = nil
end

return W
