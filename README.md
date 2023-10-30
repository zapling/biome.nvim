# biome.nvim

**DEPRECATED: Use a real formatter like `conform.nvim` that handles the diff correctly.**

Biome (previously rome) helper utils for nvim

## Install

```lua
-- lazy.nvim
require('lazy').setup({{
    'zapling/biome.nvim',
    dependencies = {'nvim-lua/plenary.nvim'}
}})
```

## Usage

Use setup to register `:BiomeFormat` command.

```lua
require('biome').setup()
```

Runs `biome format` on the buffer content, replace buffer content with output.

```lua
require('biome').format_file()
```

Same as `format_file()` but checks if the formatter has been disabled
via the `biome.json` configuration file.

```lua
require('biome').format_on_save()
```
