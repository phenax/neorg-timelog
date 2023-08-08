local neorg = require('neorg.core')

local utils = require('neorg.modules.external.timelog.utils')

local namespace = 'external.timelog'
local EVENT_INSERT_LOG = namespace .. 'insert-log'
local EVENT_EXPORT = namespace .. 'export'

local module = neorg.modules.create(namespace)

module.config.public = {
  time_format = '%Y-%m-%d %H:%M:%S',
}

module.setup = function()
  return {
    success = true,
    requires = {
      'core.neorgcmd',
      -- 'core.tempus',
    },
  }
end

module.load = function()
  module.required['core.neorgcmd'].add_commands_from_table({
    ['timelog'] = {
      args = 1,
      condition = 'norg',

      subcommands = {
        insert = {
          args = 1,
          name = EVENT_INSERT_LOG,
        },
        export = {
          args = 1,
          name = EVENT_EXPORT,
        },
      },
    },
  })
end

local query = vim.treesitter.query.parse("norg", [[
  (ranged_verbatim_tag
    name:(tag_name (word)@_tag (#eq? @_tag "timelog"))
    (tag_parameters (tag_param)@timelog-name)?
    content: (ranged_verbatim_tag_content)? @timelog-content
    (ranged_verbatim_tag_end)@timelog-end
  ) @timelog-tag
]])

module.private = {
  foreach_timelog = function(bufnr, callback)
    local root = utils.get_root_node(bufnr, "norg")

    for _pat, match, _meta in query:iter_matches(root, bufnr, 0, -1) do
      local timelog_name = ""
      local timelog_contents = ""
      local timelog_end_node = nil

      for id, node in pairs(match) do
        local captureName = query.captures[id]
        local node = match[id]
        if captureName == "timelog-name" then
          timelog_name = vim.treesitter.get_node_text(node, bufnr)
        elseif captureName == "timelog-content" then
          timelog_contents = vim.treesitter.get_node_text(node, bufnr)
        elseif captureName == "timelog-end" then
          timelog_end_node = node
        end
      end

      callback({
        name = timelog_name,
        contents = timelog_contents,
        end_node = timelog_end_node,
      })
    end
  end,

  insert_time = function(bufnr, match_name)
    module.private.foreach_timelog(bufnr, function(l)
      if match_name == "*" or l.name == match_name then
        local row, col, _ = l.end_node:start()

        local indent = string.rep(" ", col)
        local text = os.date(module.config.public.time_format, os.time())

        vim.api.nvim_buf_set_text(bufnr, row, col, row, col, { text, indent })
      end
    end)
  end,

  export_logs = function(bufnr, outfile)
    local data = module.public.get_all_logs(bufnr)
    local json_str = vim.json.encode(data)
    local fd = vim.loop.fs_open(outfile, "w", 438)
    vim.loop.fs_write(fd, json_str)
  end,
}

module.public = {
  get_all_logs = function(bufnr)
    local result = {}

    module.private.foreach_timelog(bufnr, function(l)
      local items = utils.split_string(l.contents, "\n")
      for i, item in ipairs(items) do
        items[i] = item:match( "^%s*(.-)%s*$" ) -- Trim whitespace
      end

      result[l.name] = items
    end)

    return result
  end,
}

module.on_event = function(event)
  local event_name = event.split_type[2]
  local bufnr = event.buffer

  if event_name == EVENT_INSERT_LOG then
    local name = event.content[1]
    module.private.insert_time(bufnr, name)
  elseif event_name == EVENT_EXPORT then
    local outfile = event.content[1]
    module.private.export_logs(bufnr, outfile)
  end
end

module.events.subscribed = {
  ['core.neorgcmd'] = {
    [EVENT_INSERT_LOG] = true,
    [EVENT_EXPORT] = true,
  },
}

return module
