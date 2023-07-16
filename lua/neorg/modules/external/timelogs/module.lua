require('neorg.modules.base')

local namespace = 'external.timelogs'
local EVENT_INSERT = namespace .. 'insert'
local TAG_NAME = 'timelogs'

local module = neorg.modules.create(namespace)

module.setup = function ()
  return {
    requires = {
      'core.neorgcmd'
    }
  }
end

module.config.public = {
  -- timeFormat = 'YYYY-MM-DD'
}

function module.load()
  print("Module loaded")

  module.required['core.neorgcmd'].add_commands_from_table({
    ['insert-log'] = {
      args = 1,
      condition = 'norg',
      name = EVENT_INSERT
    }
  })
end

function get_root_node(bufnr, ft)
  local parser = vim.treesitter.get_parser(bufnr, ft)
  return parser:parse()[1]:root()
end

local query = vim.treesitter.query.parse("norg", [[
  (ranged_verbatim_tag
    name:(tag_name (word)@_tag (#eq? @_tag "timelogs"))
    (tag_parameters (tag_param)@timelog-name)
    content: (ranged_verbatim_tag_content)?@timelog-content
    (ranged_verbatim_tag_end)@timelog-end
  ) @timelog-tag
]])


module.on_event = function (event)
  if event.split_type[2] == EVENT_INSERT then
    print("Inserting")

    local name = event.content[1]

    local bufnr = vim.fn.bufnr('%')
    local ft = vim.opt.ft:get()

    local root = get_root_node(bufnr, ft)

    for _pattern, match, metadata in query:iter_matches(root, bufnr, 0, -1) do
      local timelogName = ""
      local timelogNode = nil

      for id, node in pairs(match) do
        local captureName = query.captures[id]
        local node = match[id]
        if captureName == "timelog-name" then
          timelogName = vim.treesitter.get_node_text(node, bufnr)
        elseif captureName == "timelog-end" then
          timelogNode = node
        end
      end

      print("timelog ::" .. timelogName)
      print(timelogNode)

      if timelogName == name then
        local row, col, _ = timelogNode:start()
        local indent = string.rep(" ", col)
        vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { "hello world", indent })
      end
    end
  end
end

module.events.subscribed = {
  ['core.neorgcmd'] = {
    [EVENT_INSERT] = true
  }
}

return module
