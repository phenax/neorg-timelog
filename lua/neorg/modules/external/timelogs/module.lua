require('neorg.modules.base')

local utils = require('neorg.modules.external.timelogs.utils')

local namespace = 'external.timelogs'
local EVENT_INSERT = namespace .. 'insert'

local module = neorg.modules.create(namespace)

module.setup = function ()
  return {
    requires = {
      'core.neorgcmd',
      -- 'core.tempus',
    }
  }
end

module.config.public = {
  timeFormat = '- %Y-%m-%d, %H:%M:%S'
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

local query = vim.treesitter.query.parse("norg", [[
  (ranged_verbatim_tag
    name:(tag_name (word)@_tag (#eq? @_tag "timelog"))
    (tag_parameters (tag_param)@timelog-name)
    (ranged_verbatim_tag_end)@timelog-end
  ) @timelog-tag
]])

module.private = {
  insert_time = function(matchName)
    local bufnr = vim.fn.bufnr('%')
    local root = utils.get_root_node(bufnr, vim.opt.ft:get())

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

      if matchName == "*" or timelogName == matchName then
        local row, col, _ = timelogNode:start()
        local indent = string.rep(" ", col)
        local text = os.date(module.config.public.timeFormat, os.time())
        vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { text, indent })
      end
    end
  end,
}

module.on_event = function (event)
  if event.split_type[2] == EVENT_INSERT then
    local name = event.content[1]
    module.private.insert_time(name)
  end
end

module.events.subscribed = {
  ['core.neorgcmd'] = {
    [EVENT_INSERT] = true
  }
}

return module
