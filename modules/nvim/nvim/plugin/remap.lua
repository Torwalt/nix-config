nmap("<leader>bb", "<c-^><cr>")
nmap("<leader>h", ":wincmd h<cr>")
nmap("<leader>l", ":wincmd l<cr>")
nmap("<leader>j", ":wincmd j<cr>")
nmap("<leader>k", ":wincmd k<cr>")
nmap("<leader>E", ":Explore<cr>")
nmap("<Esc>", "<C-\\><C-n>")
nmap("<leader>jf", ":%!jq .<cr>")
nmap("<leader>s", ":update<cr>")

local window_maximized = false
local original_statusline_color = nil

-- Function to toggle window maximization
function toggle_window_maximize()
  -- Store original statusline color if we haven't already
  if original_statusline_color == nil then
    -- Get current statusline highlight information
    local statusline_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
    original_statusline_color = {
      fg = statusline_hl.fg,
      bg = statusline_hl.bg
    }
  end

  if window_maximized then
    -- Restore equal sizing
    vim.cmd('wincmd =')
    window_maximized = false

    -- Restore original statusline color
    if original_statusline_color.bg then
      vim.api.nvim_set_hl(0, "StatusLine", {
        fg = original_statusline_color.fg,
        bg = original_statusline_color.bg
      })
    end
  else
    -- Maximize current window
    vim.cmd('wincmd _')
    vim.cmd('wincmd |')
    window_maximized = true

    -- Set a distinctive color for statusline in maximized mode
    -- Using a bright color like orange to make it obvious
    vim.api.nvim_set_hl(0, "StatusLine", {
      fg = "#282828", -- dark text
      bg = "#fe8019"  -- bright orange background
    })
  end
end

nmap('<leader>zz', toggle_window_maximize)
