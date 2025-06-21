local Path = require 'plenary.path'

local U = {}

U.project_dir = function()
  return vim.loop.cwd()
end

U.get_index = function(list, value, key)
  local idx = -1
  for i, element in ipairs(list) do
    if key ~= nil then
      if element[key] == value then
        idx = i
      end
    else
      if element == value then
        idx = i
        break
      end
    end
  end

  return idx
end

U.get_icon = function(filename)
  local icon = ''

  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if ok then
    icon = devicons.get_icon(filename)
  end

  return icon
end

U.relative_path = function(file)
  return Path:new(file):make_relative(U.project_dir())
end

return U
