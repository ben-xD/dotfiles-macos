return {
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    keys = {
      { "<Leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Copy git link" },
      { "<Leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link in browser" },
    },
    opts = {},
  },
}
