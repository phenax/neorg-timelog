local utils = {}

function utils.get_root_node(bufnr, ft)
  local parser = vim.treesitter.get_parser(bufnr, ft)
  return parser:parse()[1]:root()
end

return utils

