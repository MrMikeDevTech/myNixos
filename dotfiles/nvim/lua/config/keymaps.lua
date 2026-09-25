vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Guardar" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Cerrar" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Guardar" })

map("n", "<C-z>", "u", { desc = "Deshacer" })
map("i", "<C-z>", "<cmd>undo<cr>", { desc = "Deshacer" })
map("n", "<C-S-z>", "<C-r>", { desc = "Rehacer" })
map("i", "<C-S-z>", "<cmd>redo<cr>", { desc = "Rehacer" })

map("n", "<C-a>", "ggVG", { desc = "Seleccionar todo" })
map("i", "<C-a>", "<cmd>normal! ggVG<cr>", { desc = "Seleccionar todo" })

map("v", "<C-S-x>", "d", { desc = "Cortar selección" })
map("n", "<C-S-x>", "dd", { desc = "Cortar línea" })

map("n", "<C-Left>", "b", { desc = "Palabra anterior" })
map("n", "<C-Right>", "w", { desc = "Palabra siguiente" })
map("i", "<C-Left>", "<cmd>normal! b<cr>", { desc = "Palabra anterior" })
map("i", "<C-Right>", "<cmd>normal! w<cr>", { desc = "Palabra siguiente" })

map("n", "<S-Left>", "v<Left>", { desc = "Seleccionar: izquierda" })
map("n", "<S-Right>", "v<Right>", { desc = "Seleccionar: derecha" })
map("v", "<S-Left>", "<Left>", { desc = "Seleccionar: izquierda" })
map("v", "<S-Right>", "<Right>", { desc = "Seleccionar: derecha" })
map("i", "<S-Left>", "<cmd>normal! v<Left><cr>", { desc = "Seleccionar: izquierda" })
map("i", "<S-Right>", "<cmd>normal! v<Right><cr>", { desc = "Seleccionar: derecha" })

map("n", "<C-S-Left>", "vb", { desc = "Seleccionar palabra: izquierda" })
map("n", "<C-S-Right>", "vw", { desc = "Seleccionar palabra: derecha" })
map("v", "<C-S-Left>", "b", { desc = "Seleccionar palabra: izquierda" })
map("v", "<C-S-Right>", "w", { desc = "Seleccionar palabra: derecha" })
map("i", "<C-S-Left>", "<cmd>normal! vb<cr>", { desc = "Seleccionar palabra: izquierda" })
map("i", "<C-S-Right>", "<cmd>normal! vw<cr>", { desc = "Seleccionar palabra: derecha" })
