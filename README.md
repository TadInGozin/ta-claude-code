# ta-claude-code

TaTa's AI depository - A Claude Code Plugin Marketplace.

## Overview

This repository serves as a **Claude Code Plugin Marketplace**, providing a centralized place to discover, install, and manage Claude Code plugins.

## Usage

### Add this Marketplace

To add this marketplace to your Claude Code installation:

```bash
# Using GitHub (recommended)
/plugin marketplace add TadInGozin/ta-claude-code

# Or using Git URL
/plugin marketplace add https://github.com/TadInGozin/ta-claude-code.git
```

### Install Plugins

Once the marketplace is added, you can install plugins from it:

```bash
# Install a specific plugin
/plugin install plugin-name@ta-claude-code

# Browse available plugins
/plugin
```

### Verify Installation

```bash
# List all marketplaces
/plugin marketplace list

# Browse plugins from this marketplace
/plugin
```

## Available Plugins

| Plugin Name | Description | Version |
|-------------|-------------|---------|
| *Coming soon* | Stay tuned for plugins! | - |

## Adding a Plugin

To add a new plugin to this marketplace:

1. Create your plugin in the `plugins/` directory
2. Update `.claude-plugin/marketplace.json` to include your plugin entry
3. Submit a pull request

### Plugin Entry Example

```json
{
  "name": "my-plugin",
  "source": "./plugins/my-plugin",
  "description": "Description of your plugin",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

## Marketplace Structure

```
ta-claude-code/
├── .claude-plugin/
│   └── marketplace.json    # Marketplace configuration
├── plugins/                 # Plugin directory
│   └── (your plugins here)
├── LICENSE
└── README.md
```

## Documentation

For more information about Claude Code plugins and marketplaces, see:

- [Plugin Marketplaces Documentation](https://code.claude.com/docs/en/plugin-marketplaces)
- [Creating Plugins](https://code.claude.com/docs/en/plugins)

## License

See [LICENSE](./LICENSE) for details.
