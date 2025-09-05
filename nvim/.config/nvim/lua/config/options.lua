local opt = vim.opt

--==========================--
-- UI & Colors
--==========================--
opt.termguicolors = true      -- enable 24-bit RGB colors in TUI
opt.background = "dark"       -- prefer dark variant for dual-tone themes
opt.signcolumn = "yes"        -- always show sign column to avoid text shifting
opt.number = true             -- show absolute line numbers
opt.relativenumber = true     -- show relative numbers for motions
opt.cursorline = true         -- highlight the current line
opt.wrap = false              -- do not wrap long lines
opt.winborder = 'rounded'     -- set the default border for all floating windows

--==========================--
-- Encoding
--==========================--
opt.encoding = "utf-8"        -- default internal encoding
opt.fileencoding = "utf-8"    -- encoding used when writing files

--==========================--
-- Indentation & Tabs
--==========================--
opt.tabstop = 2               -- visual width of a <Tab> (in spaces)
opt.softtabstop = 2
opt.shiftwidth = 2            -- spaces used for each step of (auto)indent
opt.expandtab = true          -- convert typed <Tab> to spaces
opt.autoindent = true         -- copy indent from current line when starting a new one
opt.smartindent = true        -- smarter autoindenting for new lines

--==========================--
-- Backspace behavior
--==========================--
opt.backspace = "indent,eol,start" -- allow backspace over indent, line breaks, and insert start

--==========================--
-- Clipboard
--==========================--
opt.clipboard = "unnamedplus" -- use system clipboard for all yank/paste

--==========================--
-- Window Splits
--==========================--
opt.splitright = true         -- vertical splits open to the right
opt.splitbelow = true         -- horizontal splits open below

--==========================--
-- Search
--==========================--
opt.hlsearch = true           -- highlight all matches of last search
opt.incsearch = true          -- show matches while typing the search
opt.ignorecase = true         -- ignore case when searching
opt.smartcase = true          -- if you include mixed case in your search, assumes you want case-sensitive

--==========================--
-- Files
--==========================--
opt.swapfile = false          -- disable swapfile creation

--==========================--
-- Whitespace Rendering
--==========================--
-- opt.list = true                               -- show invisible characters (tabs/trailing spaces/eol)
-- opt.listchars = "tab:>-,trail:-,lead:·,eol:¬" -- how to draw invisible characters

--==========================--
-- Yank Feedback
--==========================--
-- Highlight yanked text briefly to confirm the action
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 1000 }) -- use IncSearch group; fade after 1000ms
  end,
})

