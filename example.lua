
function add_rtp(path)
  vim.o.runtimepath =
    vim.o.runtimepath .. ',' .. vim.fn.expand('$HOME/.local/share/nvim/site/pack/packer/start/' .. path)
end

vim.o.runtimepath = vim.o.runtimepath .. ',' .. '~/dev/projects/nvim-neorg-timelogs/'
add_rtp('plenary.nvim')
add_rtp('nvim-treesitter')
add_rtp('neorg')

---

require('neorg').setup {
  load = {
    ['core.defaults'] = {},
    ['external.timelogs'] = {}
  },
}

vim.cmd [[ e ./test.norg ]]
vim.cmd [[ set filetype=norg ]]

-- vim.cmd [[Neorg insert-timelog routine]]
