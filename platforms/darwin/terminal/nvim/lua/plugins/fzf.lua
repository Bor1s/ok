return {
  {
    "ibhagwan/fzf-lua",
    config = function()
      -- calling "setup" is optional for customization
      require("fzf-lua").setup({
        winopts = {
          fullscreen = true,
        },
      })
    end,
  },
}
