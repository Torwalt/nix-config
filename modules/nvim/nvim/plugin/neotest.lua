local goconf = {
  go_test_args = {
    "-v",
  },
  runner = "gotestsum"
}

require("neotest").setup({
    adapters = {
        require("neotest-golang")(goconf)
    }
})
