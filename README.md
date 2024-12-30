# FiveM Engine Toggle Script
Simple script to engable users to toggle their engines on or off using a /eng command.

This FiveM resource adds a simple engine toggle system that allows players to turn their vehicle engines on or off using the /eng command. The script includes configurable options for enhanced flexibility.

### Features
- Toggle Engine State: Players can turn their vehicle engine on or off with a single command.
- Driver Restriction (Configurable): Optionally restrict engine toggling to the driver only.
- Control Blocking (Configurable): Prevent acceleration and braking if the engine is off.

### Installation
- Download this repository into your FiveM server's resources folder
- Add the resource to your server.cfg
- ensure engine-toggle

### Configuration
- The resource includes a config.lua file for customization
- ToggleEngineDriverOnly: Set to true to restrict the /eng command to the driver, or false to allow all passengers to use it.
- BlockControlsIfEngineOff: Set to true to disable acceleration and braking when the engine is off, or false to leave controls unaffected.

### Usage
- Use /eng in-game to toggle your vehicle's engine on or off.
- Tested with the latest FiveM framework.
- Requires no additional dependencies.
