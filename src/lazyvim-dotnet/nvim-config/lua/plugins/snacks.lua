return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
          exclude = { "**/node_modules/*", "**/bin/*", "**/obj/*" },
        },
        files = {
          hidden = true,
          ignored = true,
          exclude = { "**/node_modules/*", "**/bin/*", "**/obj/*" },
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = { "**/node_modules/*", "**/bin/*", "**/obj/*" },
        },
        grep_word = {
          hidden = true,
          ignored = true,
          exclude = { "**/node_modules/*", "**/bin/*", "**/obj/*" },
        },
        grep_buffers = {
          hidden = true,
          ignored = true,
          exclude = { "**/node_modules/*", "**/bin/*", "**/obj/*" },
        },
      },
    },
  },
}
