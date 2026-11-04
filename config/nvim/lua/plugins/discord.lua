return {
  {
    "vyfor/cord.nvim",
    opts = {
      editor = {
        client = "neovim",
        tooltip = "Nvim",
      },
      display = {
        show_time = true,
      },
      text = {
        -- Dynamically read our global variable which updates instantly on mode change
        editing = function()
          if vim.g.is_coding == true then
            return "Actively coding,"
          else
            return "Staring at syntax,"
          end
        end,
        viewing = "Staring at syntax,",
        workspace = "MIGHT JUST BE LARPING THO !",
      },
    },
    config = function(_, opts)
      -- Initialize default state
      vim.g.is_coding = false

      -- Initialize the plugin
      require("cord").setup(opts)

      -- Create precise mode hooks to update our flag variable
      local group = vim.api.nvim_create_augroup("CordDynamicStatus", { clear = true })

      vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function()
          vim.g.is_coding = true
        end,
      })

      vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        callback = function()
          vim.g.is_coding = false
        end,
      })
    end,
  },
}
