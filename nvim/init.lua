-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.autoread = true
vim.opt.updatetime = 1000

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})


-- Key remaps
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })


-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true


-- Colours
vim.opt.termguicolors = true
require("catppuccin").setup({
  flavour = "mocha", -- latte, frappe, macchiato, mocha
})
vim.cmd.colorscheme("catppuccin")


-- File searching
require("telescope").setup({})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)


-- Within-file navigation
require("flash").setup({})
vim.keymap.set({ "n", "x", "o" }, "nj", function() require("flash").jump() end, { desc = "Flash" })


-- Surround
require("nvim-surround").setup({})


-- Treesitter syntax highlighting
require("nvim-treesitter").setup()

require("nvim-treesitter").install({
  "python",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "c",
  "cpp",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "python",
    "lua",
    "vim",
    "help",
    "c",
    "cpp",
  },
  callback = function()
    vim.treesitter.start()
  end,
})


-- Treesitter text objects
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@function.outer"] = "V",
      ["@class.outer"] = "V",
      ["@loop.outer"] = "V",
      ["@conditional.outer"] = "V",
    },
    include_surrounding_whitespace = false,
  },
})

local ts_select = require("nvim-treesitter-textobjects.select")

vim.keymap.set({ "x", "o" }, "af", function()
  ts_select.select_textobject("@function.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "if", function()
  ts_select.select_textobject("@function.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ac", function()
  ts_select.select_textobject("@class.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ic", function()
  ts_select.select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ap", function()
  ts_select.select_textobject("@parameter.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ip", function()
  ts_select.select_textobject("@parameter.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "al", function()
  ts_select.select_textobject("@loop.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "il", function()
  ts_select.select_textobject("@loop.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ai", function()
  ts_select.select_textobject("@conditional.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ii", function()
  ts_select.select_textobject("@conditional.inner", "textobjects")
end)


-- Language server
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }

vim.lsp.config("jedi", {
  cmd = { "jedi-language-server" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  },
  init_options = {
    diagnostics = {
      enable = false,
    },
    hover = {
      enable = false,
    },
    completion = {
      disableSnippets = true,
    },
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.signatureHelpProvider = false
    client.server_capabilities.referencesProvider = false
    client.server_capabilities.documentHighlightProvider = false
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.workspaceSymbolProvider = false
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.semanticTokensProvider = nil

    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
    })

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })

    vim.keymap.set("i", "<C-Space>", function()
      vim.lsp.completion.get()
    end, { buffer = bufnr })
  end,
})

vim.lsp.enable("jedi")


-- Programming config
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp"},
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
