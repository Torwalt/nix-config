local goconf = {
    go_test_args = {"-v", "-tags=integration,clickhouse"},
    go_list_args = {"-tags=integration,clickhouse"},
    dap_go_opts = {delve = {build_flags = {"-tags=integration,clickhouse"}}},
    runner = "gotestsum"
}

require("neotest").setup({
    adapters = {
        require("neotest-golang")(goconf), require('rustaceanvim.neotest')
    }
})

local function run_test_and_open_debug()
    require('neotest').run.run({suite = false, strategy = 'dap'})
    require('dap').repl.toggle(nil, 'vsplit')
    vim.cmd("wincmd p")
end

nmap("<leader>dt", run_test_and_open_debug)
