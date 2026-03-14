return {
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    event = { "BufWritePre", "BufReadPost" },
    opts = {
      formatters_by_ft = {
        xml = { "xmllint" },
      },
    },
  },
}
