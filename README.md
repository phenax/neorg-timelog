# neorg-timelog [WIP]
Neorg module to allow logging time


## Install

#### For [packer](https://github.com/wbthomason/packer.nvim) users -
```lua
  use {
    'nvim-neorg/neorg',
    -- ...
    requires = {
      -- ...
      {'phenax/neorg-timelog'},
    }
  }
```


#### Config
```lua
require('neorg').setup {
  load = {
    -- ...
    ['external.timelog'] = {
      config = {
        time_format = '%Y-%m-%d %H:%M:%S', -- Default config
      }
    }
  },
}
```


## Usage
* Add an empty `@timelog` data tag with a name
```neorg
@timelog routine
@end
```
* Run `:Neorg insert-timelog routine` to update timelog with the name `routine`
* Run `:Neorg insert-timelog *` to update all timelogs in buffer

