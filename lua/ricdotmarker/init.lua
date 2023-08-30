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
    ":lua require('ricdotmarker.window').create_window()<CR>",
    { silent = true }
  )
  vim.keymap.set(
    "n",
    "<Leader>mm",
    ":lua require('ricdotmarker').mark()<CR>",
    { silent = true }
  )
end

M.mark = function()
  local buf = M.is_marked()
  
  if (buf.ismarked) then
    return print("This buffer is already marked")
  end

  table.insert(Marks, buf.name)
  print("Buffer marked.")
end

M.is_marked = function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local ismarked = false
  
  for _, mark in ipairs(Marks) do
    if (mark == bufname) then
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
  local filename = Marks[line]
  local bufnr = vim.fn.bufnr(filename)
  
  require("ricdotmarker.window").close_window()
  
  vim.api.nvim_set_current_buf(bufnr)
end

return M
