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

-- Function to toggle window maximization
function toggle_window_maximize()
  if window_maximized then
    -- Restore equal sizing
    vim.cmd('wincmd =')
    window_maximized = false
  else
    -- Maximize current window
    vim.cmd('wincmd _')
    vim.cmd('wincmd |')
    window_maximized = true
  end
end

nmap('<leader>zz', toggle_window_maximize)
