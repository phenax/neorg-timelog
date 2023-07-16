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
      'phenax/neorg-timelog',
    }
  }
```


#### Config -
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
@timelog study
@end
```
* Run `:Neorg insert-timelog study` to update timelog with the name `study`
* Run `:Neorg insert-timelog *` to update all timelogs in buffer

