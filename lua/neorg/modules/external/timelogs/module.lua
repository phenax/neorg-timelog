require('neorg.modules.base')

local utils = require('neorg.modules.external.timelogs.utils')

local namespace = 'external.timelogs'
local EVENT_INSERT = namespace .. 'insert'

local module = neorg.modules.create(namespace)

module.config.public = {
  time_format = '%Y-%m-%d %H:%M:%S',
}

module.setup = function()
  return {
    requires = {
      'core.neorgcmd',
      -- 'core.tempus',
    },
  }
end

module.load = function()
  module.required['core.neorgcmd'].add_commands_from_table({
    ['insert-timelog'] = {
      args = 1,
      condition = 'norg',
      name = EVENT_INSERT,
    },
  })
end

local query = vim.treesitter.query.parse("norg", [[
  (ranged_verbatim_tag
    name:(tag_name (word)@_tag (#eq? @_tag "timelog"))
    (tag_parameters (tag_param)@timelog-name)
    content: (ranged_verbatim_tag_content)? @timelog-content
    (ranged_verbatim_tag_end)@timelog-end
  ) @timelog-tag
]])

module.private = {
  insert_time = function(match_name)
    local bufnr = vim.fn.bufnr('%')
    local root = utils.get_root_node(bufnr, vim.opt.ft:get())

    for _pat, match, _meta in query:iter_matches(root, bufnr, 0, -1) do
      local timelog_name = ""
      local timelog_node = nil

      for id, node in pairs(match) do
        local captureName = query.captures[id]
        local node = match[id]
        if captureName == "timelog-name" then
          timelog_name = vim.treesitter.get_node_text(node, bufnr)
        elseif captureName == "timelog-end" then
          timelog_node = node
        end
      end

      if match_name == "*" or timelog_name == match_name then
        local row, col, _ = timelog_node:start()
        local indent = string.rep(" ", col)
        local text = os.date("- " .. module.config.public.time_format, os.time())
        vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { text, indent })
      end
    end
  end,
}

module.on_event = function(event)
  local event_name = event.split_type[2]

  if event_name == EVENT_INSERT then
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
