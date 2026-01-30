return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local dotnet = require("easy-dotnet")
    dotnet.setup()
    vim.keymap.set("n", "<F5>", function()
      dotnet.debug_profile(
        "--property:DontBuildClientScripts=true --property:consoleLoggerParameters=PerformanceSummary"
      )
    end)
  end,
}
