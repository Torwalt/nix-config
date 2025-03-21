function nbufmap(shortcut, command, bufnr)
    vim.keymap.set('n', shortcut, command, { noremap = true, silent = true, buffer = bufnr })
end

function map(mode, shortcut, command)
    vim.keymap.set(mode, shortcut, command, { noremap = true, silent = true })
end

function nmap(shortcut, command) map('n', shortcut, command) end
