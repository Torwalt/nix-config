function Map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command,
                            {noremap = true, silent = true})
end

function NMap(shortcut, command) Map('n', shortcut, command) end

require('telescope').setup {
    defaults = {
        vimgrep_arguments = {
            'rg', '--with-filename', '--line-number', '--column',
            '--smart-case', '-uu'
        }
    }
}

NMap("<leader>ff",
     [[<Cmd>lua require('telescope.builtin').find_files({hidden = true})<CR>]])
NMap("<leader>fw", [[<Cmd>lua require('telescope.builtin').live_grep()<CR>]])
NMap("<leader>fb", [[<Cmd>lua require('telescope.builtin').buffers({ sort_lastused = true, ignore_current_buffer = true })<CR>]])
