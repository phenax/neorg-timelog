
function add_rtp(path)
  vim.o.runtimepath =
    vim.o.runtimepath .. ',' .. vim.fn.expand('$HOME/.local/share/nvim/site/pack/packer/start/' .. path)
end

print(vim.fn.getcwd())

vim.o.runtimepath = vim.o.runtimepath .. ',' .. vim.fn.getcwd()
add_rtp('plenary.nvim')
add_rtp('nvim-treesitter')
add_rtp('neorg')

---

require('neorg').setup {
  load = {
    ['core.defaults'] = {},
    ['external.timelog'] = {}
  },
}

vim.cmd [[ e ./example.norg ]]
vim.cmd [[ set filetype=norg ]]

-- vim.cmd [[Neorg insert-timelog routine]]
