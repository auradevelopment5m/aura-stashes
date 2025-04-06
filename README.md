### Aura-Stashes Description

Aura-Stashes is a comprehensive stash management system for your FiveM server, offering seamless integration with multiple frameworks and inventory systems. This resource allows server administrators and authorized players to create, manage, and access custom stashes throughout the map with an intuitive user interface. With support for personal stashes, job restrictions, and precise placement controls, Aura-Stashes provides unparalleled flexibility and security for all your storage needs.

# Aura-Stashes

A powerful and flexible stash management system for FiveM servers.

## Features

- **Multi-Framework Support**: Compatible with ESX, QB Core, and QBX Core frameworks
- **Multi-Inventory Support**: Works with ox_inventory, qb-inventory, and ps-inventory
- **User-Friendly Interface**: Sleek and intuitive UI for creating and managing stashes
- **Advanced Customization**: Configure stash ID, label, slots, weight, and access permissions
- **Security Options**: Restrict stashes to specific citizen IDs or job roles with grade requirements
- **Precise Placement**: Advanced raycast system with detailed controls for perfect stash positioning
- **Performance Optimized**: Well-organized and optimized code for minimal resource usage

## Dependencies

- ox_lib
- One of the following frameworks:
  - ESX
  - QB Core
  - QBX Core
- One of the following inventory systems:
  - ox_inventory
  - qb-inventory
  - ps-inventory

## Installation

1. Ensure you have the required dependencies installed
2. Download the latest release of Aura-Stashes
3. Extract the files to your server's resources folder
4. Add `ensure aura-stashes` to your server.cfg
5. Restart your server

## Usage

### Creating a Stash

1. Use the command `/createstash` to open the stash creation interface
2. Fill in the required information:
   - **Stash ID**: A unique identifier (lowercase, no spaces, e.g., `police_stash1`)
   - **Stash Label**: The display name for the stash
   - **Slots**: Number of inventory slots
   - **Weight**: Maximum weight capacity
   - **Personal Stash**: Toggle to restrict access to a specific citizen ID
   - **Job Access**: Restrict access to specific jobs and grades
3. Click "Set Zone" to place the stash in the world
4. Use the following controls to adjust the zone:
   - **↑/↓ Arrows**: Increase/decrease height
   - **←/→ Arrows**: Increase/decrease width
   - **Z/X Keys**: Increase/decrease length
   - **Mouse Scroll**: Rotate the box
   - **Left Mouse Click**: Freeze/unfreeze the box
   - **Enter**: Confirm placement
   - **Escape**: Cancel placement
5. Click "Create Stash" to finalize

### Managing Stashes

Use the command `/activestashes` to view all currently active stashes on the server.

## Permissions

By default, anybody can create stashes. You can configure permissions in the config.lua file to set `Config.AdminOnly = true`.

## Configuration

The config.lua file allows you to customize various aspects of Aura-Stashes:

```lua
Config = {}

Config.Command = 'createstash'
Config.AdminOnly = false
Config.Debug = false

Config.DefaultStash = {
  slots = 30,
  maxWeight = 100000,
}

Config.Target = {
  enabled = true,
  distance = 2.0,
  width = 1.0,
  length = 1.0,
  height = 1.0,
  drawSprite = true,
  sprite = {
      name = 'box',
      color = {r = 0, g = 122, b = 255, a = 100}
  }
}
```

## Commands

- `/createstash` - Opens the stash creation interface
- `/activestashes` - Shows all active stashes on the server

## Support

For support, please join our Discord server: https://discord.gg/2q8ZBSWPv7

## License

See the LICENSE file for details.
