local W = {}

Window = nil

W.create_window = function()
  -- get the editor's max width and height
  local win_width = vim.api.nvim_win_get_width(0)
  local win_height = vim.api.nvim_win_get_height(0)
  
  if (win_width < 150) then
    
  end
  
  if (win_height > 50) then
    
  end
  
  local min_width = 100
  local min_height = 30
  -- local borderchars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
  local borderchars = RicdotmarkerConfig.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

  local popup = require("plenary.popup")
  
  -- settings for the fzf window
  local opts = {
    title = RicdotmarkerConfig.title or "ricdotmarker",
    line = math.floor(((vim.o.lines - min_height) / 2) - 1),
    col = math.floor(((vim.o.columns - min_width) / 2) - 1),
    minwidth = min_width,
    minheight = min_height,
    borderchars = borderchars,
  }
  
  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_id = popup.create(bufnr, opts)
  
  Window = win_id
  
  return {
    bufnr = bufnr,
    win_id = win_id,
  }
end

W.close_window = function()
  vim.api.nvim_win_close(Window, true)

  Window = nil
end

return W
