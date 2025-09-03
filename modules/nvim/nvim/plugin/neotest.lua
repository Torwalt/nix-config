local goconf = {
    go_test_args = { "-v", "-tags=integration" },
    go_list_args = { "-tags=integration" },
    dap_go_opts = { delve = { build_flags = { "-tags=integration" } } },
    runner = "gotestsum",
    testify_enabled = true,
}

require("neotest").setup({
    adapters = {
        require("neotest-golang")(goconf), require('rustaceanvim.neotest')
    }
})

local function run_test_and_open_debug()
    require('neotest').run.run({ suite = false, strategy = 'dap' })
    require('dap').repl.toggle(nil, 'vsplit')
    vim.cmd("wincmd p")
end

nmap("<leader>dt", run_test_and_open_debug)
