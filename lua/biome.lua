local Job = require('plenary.job')
local path = require('plenary.path')

-- exists in plenary but have unresolved bug where
-- the scanning get stuck on root
-- https://github.com/nvim-lua/plenary.nvim/pull/506
function find_upwards(filename)
  local folder = path:new(".")
  while folder:absolute() ~= path.root do
    local p = folder:joinpath(filename)
    if p:exists() then
      return p
    end

    local parent = folder:parent()

    if folder.filename == "/" and parent.filename == "/" then
        return ""
    end

    folder = parent
  end
  return ""
end

local M = {}

local format = function(text, filename)
    local formatter_output = nil
    Job:new({
        command = 'biome',
        args = {'format', '--stdin-file-path='..filename},
        writer = text,
        on_exit = function(result, exit_code)
            if exit_code ~= 0 then
                return
            end
            formatter_output = result:result()
        end,
    }):sync()
    return formatter_output
end

M.format_file = function()
    local bufnr = vim.fn.bufnr("%")
    local filename = vim.fn.expand('%')
    local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local buffer_content = table.concat(buffer_lines, '\n')

    local output = format(buffer_content, filename)
    if output ~= nil then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
    end
end

M.format_on_save = function()
    local cfg_path = find_upwards("biome.json")
    if cfg_path == "" then
        return
    end

    local cfg = vim.fn.json_decode(path:new(cfg_path):read())

    if cfg.formatter ~= nil and cfg.formatter.enabled == false  then
        return
    end

    M.format_file()
end

M.setup = function()
    vim.api.nvim_create_user_command('BiomeFormat', M.format_file, {})
end

return M
