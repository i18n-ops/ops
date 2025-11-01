return {
  "folke/tokyonight.nvim",
  priority = 1000,
  opts = {
    style = "night",
    transparent = true,
    on_colors = function(colors)
      colors.bg = "#000000"
      colors.bg_dark = "#000000"
      colors.bg_float = "#000000"
      colors.bg_sidebar = "#000000"
    end,
    on_highlights = function(hl)
      hl.SnacksIndentScope = { fg = "#202020" }
      hl.SnacksDashboardDir = { fg = "#202020" }
      hl.CursorLine = { bg = "#102000" }
      hl.WinSeparator = { fg = "#003000" }

      hl.LspReferenceWrite = { bg = "#000000", fg = "#60d000" }
      hl.LspReferenceText = { bg = "#000000", fg = "#60d000" }
      hl.LspReferenceRead = { bg = "#000000", fg = "#60d000" }

      hl.CursorLineNr = { fg = "#ffff00", bg = "#202020" } -- 让行号颜色在光标行上更突出
      hl.Visual = { bg = "#303000", fg = "#90c000" }
      hl.Search = { bg = "#c0c000", fg = "#000000" }
      hl.Substitute = { bg = "#a0e000", fg = "#000000" }
      hl.Comment = { fg = "#777777" }
      hl.rustAttribute = { fg = "#339900" }
      hl.rustKeyword = { fg = "#228810" }
      hl.LspInlayHint = { bg = "#000000", fg = "#555555" }
      hl.DiagnosticUnnecessary = { fg = "#909090" }

      hl["@function.method.call"] = { fg = "#33aa00" }
      hl["@markup.raw.markdown_inline"] = { bg = "#000000", fg = "#00cc00" }
      hl["@spell.markdown"] = { fg = "#90aa50", underline = false }
      hl["@markup.link.markdown_inline"] = { fg = "#3399ff", underline = false }
      hl["@variable.builtin"] = { fg = "#00aa50" }
      hl["@lsp.type.property"] = { fg = "#338900" }
      hl["@character.special"] = { fg = "#335900" }
      hl["@lsp.type"] = { fg = "#20c020" }
      hl["@lsp.type.method"] = { fg = "#20c020" }
      hl["@lsp.type.typeAlias"] = { fg = "#20c020" }
      hl["@lsp.type.function"] = { fg = "#20c020" }
      hl["@lsp.typemod.typeAlias.defaultLibrary"] = { fg = "#20c020" }

      -- 类型和常量
      hl["@type"] = { fg = "#AEC13C" }
      hl["@type.builtin"] = { fg = "#0cc00a" }
      hl["@constant"] = { fg = "#2Ac008" }
      hl["@constructor"] = { fg = "#2A9008" }
      hl["@constant.builtin"] = { fg = "#506D06" }
      hl["@constant.macro"] = { fg = "#36aC04" }

      hl["@lsp.typemod.function.defaultLibrary"] = { fg = "#c0c020" }
      hl["@lsp.typemod.struct.defaultLibrary"] = { fg = "#c0c020" }
      hl["@lsp.typemod.method.defaultLibrary"] = { fg = "#c0c020" }
      hl["@lsp.typemod.macro.defaultLibrary"] = { fg = "#c0c020" }
      hl["@lsp.type"] = { fg = "#90c000" }
      hl["@lsp.type.parameter"] = { fg = "#90c000" }
      hl["@lsp.type.selfKeyword"] = { fg = "#00c020" }
      hl["@lsp.type.selfTypeKeyword"] = { fg = "#00c020" }
      hl["@lsp.type.interface"] = { fg = "#009020" }
      hl["@lsp.type.decorator"] = { fg = "#607020" }
      hl["@lsp.type.deriveHelper"] = { fg = "#607020" }
      hl["@lsp.type.typeParameter"] = { fg = "#60a020" }
      hl["@lsp.type.formatSpecifier"] = { fg = "#60c020" }
      hl["@lsp.type.lifetime"] = { fg = "#309020" }

      hl["@module"] = { fg = "#50a060" }
      hl["@keyword"] = { fg = "#309050" }
      hl["@keyword.function"] = { fg = "#00c000" }
      hl["@keyword.operator"] = { fg = "#42a500" }
      hl["@keyword.import"] = { fg = "#309030" }
      hl["@keyword.repeat"] = { fg = "#107500" }
      hl["@keyword.conditional"] = { fg = "#507500" }
      hl["@operator"] = { fg = "#30a30E" }

      -- 变量和函数
      hl["@variable"] = { fg = "#90c000" }
      hl["@variable.member"] = { fg = "#0A9E0A" }
      hl["@variable.parameter"] = { fg = "#5A8E5A" }
      hl["@function"] = { fg = "#90C09A" }
      hl["@function.call"] = { fg = "#30aD28" }
      hl["@function.macro"] = { fg = "#30c008" }

      -- 字符串和数字
      hl["@string"] = { fg = "#c09000" }
      hl["@number"] = { fg = "#739000" }

      -- 标点符号
      hl["@punctuation.bracket"] = { fg = "#006052" }
      hl["@punctuation.delimiter"] = { fg = "#42a200" }
      hl["@punctuation.special"] = { fg = "#429200" }

      hl["@tag"] = { fg = "#DEDE0D" }
      hl["@tag.attribute"] = { fg = "#EBEB0C" }
      hl["@tag.delimiter"] = { fg = "#F9F90A" }
    end,
  },
}
