local map = vim.keymap.set

-- Set space as my leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Disable the space key
map({ "n", "v" }, "<Space>", "<Nop>", { expr = true, silent = true })

-- Better split navigation
map(
  { "i", "n" },
  "<M-h>",
  "<C-w>h",
  { desc = "Go to left window", remap = true }
)
map(
  { "i", "n" },
  "<M-j>",
  "<C-w>j",
  { desc = "Go to lower window", remap = true }
)
map(
  { "i", "n" },
  "<M-k>",
  "<C-w>k",
  { desc = "Go to upper window", remap = true }
)
map(
  { "i", "n" },
  "<M-l>",
  "<C-w>l",
  { desc = "Go to right window", remap = true }
)

-- Quit neovim
map("n", "<leader>qq", vim.cmd.qa, { desc = "Quit neovim" })

-- Quick write
map("n", "<leader>w", vim.cmd.w, { desc = "Save the current file" })

-- Resize splits with arrow keys
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map(
  "n",
  "<C-Left>",
  "<cmd>vertical resize -2<CR>",
  { desc = "Decrease window width" }
)
map(
  "n",
  "<C-Right>",
  "<cmd>vertical resize +2<CR>",
  { desc = "Increase window width" }
)

-- Open lazy.nvim
map("n", "<leader>l", vim.cmd.Lazy, { desc = "Open lazy.nvim" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- move selected block
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map(
  "n",
  "n",
  "'Nn'[v:searchforward].'zv'",
  { expr = true, desc = "Next search result" }
)
map(
  { "x", "o" },
  "n",
  "'Nn'[v:searchforward]",
  { expr = true, desc = "Next search result" }
)
map(
  "n",
  "N",
  "'nN'[v:searchforward].'zv'",
  { expr = true, desc = "Previous search result" }
)
map(
  { "x", "o" },
  "N",
  "'nN'[v:searchforward]",
  { expr = true, desc = "Previous search result" }
)

-- Switch to other buffer/tabs
-- map("n", "<TAB>", ":tabnext<CR>")
map("n", "<S-TAB>", ":tabprevious<CR>")
map("n", "<leader>tn", ":tabnew<cr>")
map("n", "<leader>tc", ":tabclose<cr>")
map("n", "<leader>bd", ":bd<CR>")

-- Better up/down
map(
  { "n", "x" },
  "j",
  'v:count == 0 ? "gj" : "j"',
  { desc = "Down", expr = true, silent = true }
)
map(
  { "n", "x" },
  "k",
  'v:count == 0 ? "gk" : "k"',
  { desc = "Up", expr = true, silent = true }
)

-- Add undo breakpoints
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")

-- Do not copy anything with x or c
map({ "n", "v" }, "x", '"_x', { silent = true })
map({ "n", "v" }, "c", '"_c', { silent = true })

-- Only cut with dd when the line contains something

---@return string
map("n", "dd", function()
  if vim.fn.getline(".") == "" then
    return '"_dd'
  end
  return "dd"
end, { expr = true })

-- Add a blank line above current line
map("n", "=", "mzO<Esc>`z", { desc = "Blank line above", silent = true })
map("n", "_", "mzo<Esc>`z", { desc = "Blank line below", silent = true })

-- Terminal mappings
map("t", "<M-h>", "<cmd>wincmd h<CR>", { desc = "Go to left window" })
map("t", "<M-j>", "<cmd>wincmd j<CR>", { desc = "Go to lower window" })
map("t", "<M-k>", "<cmd>wincmd k<CR>", { desc = "Go to upper window" })
map("t", "<M-l>", "<cmd>wincmd l<CR>", { desc = "Go to right window" })
map("t", "<M-q>", "<C-\\><C-n>", { desc = "i" })

-- Spell checking

map("n", "<M>s", ":setlocal spell! spelllang=en_us,de_de<cr>")
map("n", "<M>s?", "z=")

-- Quickly open a buffer for scribble
map("n", "<leader>n", ":e ~/buffer<cr>")
map("n", "<leader>ns", ":e ~/buffer.gpg<cr>")
