### About This Script

This FiveM script provides enhanced control over vehicle engines, offering players a more immersive and customizable experience. It includes the following features:

---

### **Features**
1. **Engine Toggle (`/eng`)**:
   - Players can toggle the vehicle engine state with a simple command.
   - Configurable to allow only the driver to toggle the engine.

2. **Engine State Persistence**:
   - Automatically saves the engine state when exiting a vehicle.
   - Restores the engine state when re-entering the same vehicle.

3. **Engine Always-On Mode**:
   - Option to keep the engine running after exiting the vehicle.
   - Prevents unintended engine shutdowns.

4. **Control Block for Engine Off**:
   - Disables acceleration and braking when the engine is off.
   - Prevents auto-start behavior for a more realistic experience.

5. **Long Press Exit**:
   - Players can hold the exit key to leave the vehicle with the door open.
   - Configurable hold duration for triggering the action.

6. **Efficient State Cleanup**:
   - Periodic removal of invalid or outdated vehicle state data.
   - Ensures optimized performance and memory usage.

---

### **Configuration Options**
All features are customizable via the `config.lua` file:
- **ToggleEngineDriverOnly**: Restrict engine toggling to the driver.
- **BlockControlsIfEngineOff**: Disable driving controls if the engine is off.
- **SaveEngineState**: Save and restore the engine state.
- **EngineAlwaysOn**: Keep the engine running when exiting the vehicle.
- **AllowLongPressExit**: Enable the long-press exit feature.
- **LongPressDuration**: Set the duration (in milliseconds) required to trigger the long-press action.

---

### **Usage**
1. **Engine Toggle**:
   - Use `/eng` in the chat to turn the vehicle engine on or off.
2. **Long Press Exit**:
   - Hold the exit key (`F` by default) to leave the vehicle with the door open.

---

### Upcoming Planned Features

1. **Configurable Engine Control on Long Press Exit**:
   - Add a new configuration option to allow the engine to remain running only when the player uses a long press of the exit key.
   - This will provide more precise control over engine behavior based on player interaction.

2. **Enable/Disable Seat Shuffle**:
   - Introduce a configurable option to toggle seat shuffling on or off.
   - Players can prevent automatic seat changes when entering or exiting a vehicle, enhancing roleplay realism. 

This script aims to enhance player immersion and control while maintaining optimal performance. Customize the settings in `config.lua` to fit your server's needs! 🚗✨
