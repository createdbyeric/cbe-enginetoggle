## About This Script (Revamped for Version 1.1.2)
This FiveM script provides a fully optimized and immersive experience for vehicle engine management, packed with new features and improvements to enhance gameplay. Designed with performance, customization, and realism in mind, it’s an ideal addition to any server.

### Features
- Engine Toggle (/eng)
- Toggle the vehicle engine on or off using the /eng command.
- Configurable to allow only the driver to control the engine state.
- Engine State Persistence
- Automatically saves the engine state when exiting a vehicle.
- Restores the exact engine state when re-entering the same vehicle for seamless continuity.
- Engine Always-On Option
- Option to keep the engine running after exiting the vehicle.
- Prevents unintended engine shutdowns, maintaining immersion during roleplay scenarios.
- Improved Control Blocking
- Disables acceleration, braking, and turning controls when the engine is off.
- Ensures realistic engine-off behavior and prevents accidental auto-starts.
- Long Press Exit: Hold the exit key (`F` by default) to leave the vehicle with the door open. Configurable hold duration, offering flexibility to server administrators.
- Enhanced Performance
- Optimized resource usage with restructured threads and reduced frame impact.
- Vehicle state monitoring and cleanup run at strategic intervals to ensure smooth gameplay.
- Periodic Cleanup of Engine States
- Automatically removes outdated or invalid vehicle state data every 10 seconds.
- Keeps memory usage low and server performance high.

### Configuration Options
All features can be customized in the config.lua file:

- `ToggleEngineDriverOnly:` Restrict engine toggling to the driver.

- `BlockControlsIfEngineOff:` Disable driving controls when the engine is off.

- `SaveEngineState:` Save and restore engine states automatically.

- `EngineAlwaysOn:` Keep the engine running when a player exits the vehicle.

- `AllowLongPressExit:` Enable or disable the long-press exit feature.

- `LongPressDuration:` Set the duration (in milliseconds) required to trigger the long-press action.

### Usage

Toggle Engine:
- Use the /eng command in the chat to turn the engine on or off.

Long Press Exit:
- Hold the exit key (F by default) for a configurable duration to exit the vehicle with the door open.

## Known Bugs
Vehicle Turn Off on Exit:
- In some cases, the vehicle may unintentionally turn off when the player exits.
  
Vehicle Light Flickering:
- The vehicle's lights may briefly flicker on and off during exit.

### Planned Features

Configurable Seat Shuffle:
- Add a configuration option to enable or disable seat shuffling for better roleplay immersion.

Engine on Long Press Exit:
- Introduce a setting to allow the engine to remain running only when the exit key is long pressed.

Start/Stop Feature:
- Add a command-based start/stop engine toggle with player-adjustable configurations.

OneSync Support:
- Ensure full compatibility with OneSync servers for better network synchronization.

Code Restructuring and Performance Fixes:
- Underline further performance enhancements and code refactoring for improved efficiency and maintainability.


This script prioritizes performance, immersion, and flexibility, making it an invaluable tool for any FiveM server. Fully customizable to suit your server's needs, it ensures a superior vehicle engine control experience for your players! �✨
