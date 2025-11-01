return {
  {
    "stevearc/conform.nvim",
    build = function()
      local cmd = "bun i -g fmt_svelte stylus-supremacy"
      vim.fn.system(cmd)
      print("conform.nvim: installed fmt_svelte & stylus-supremacy")
    end,
    init = function()
      local augroup = vim.api.nvim_create_augroup("FormatAfterSaveCustom", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup,
        pattern = { "*.svelte", "*.styl" },
        callback = function(args)
          require("conform").format({
            bufnr = args.buf,
            async = true,
            lsp_fallback = true,
          })
        end,
      })
    end,
    opts = function(_, opts)
      opts.formatters.fmt_svelte = {
        command = "bun",
        args = { "x", "fmt_svelte", "$FILENAME" },
      }
      opts.formatters_by_ft.svelte = { "fmt_svelte" }

      opts.formatters.stylus_supremacy = {
        command = "stylus-supremacy",
        args = function(ctx)
          local config_filename = "supremacy.yml"
          local fallback_config = vim.fn.expand("~/.config/" .. config_filename)

          local found_config = vim.fs.find(config_filename, {
            upward = true,
            path = ctx.filename,
            type = "file",
          })

          local config_path
          if found_config and #found_config > 0 then
            config_path = found_config[1]
          else
            config_path = fallback_config
          end

          if vim.fn.filereadable(config_path) == 1 then
            return { "format", "--options", config_path, "$FILENAME" }
          else
            return { "format", "$FILENAME" }
          end
        end,
      }

      opts.formatters_by_ft.stylus = { "stylus_supremacy" }
    end,
    ft = { "svelte", "stylus" },
  },
}
