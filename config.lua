Config = {
    -- Engine Controls
    ToggleEngineDriverOnly = true,  -- Only allow the driver to toggle the engine
    SaveEngineState = true,         -- Save and restore engine state when entering/exiting vehicles
    EngineAlwaysOn = true,         -- Keep the engine running after exiting the vehicle

    -- Input Blocking
    BlockControlsIfEngineOff = true,  -- Block acceleration and brake if the engine is off
    DisableWheelTurningWhenEngineOff = true, -- Block wheel turning when the engine is off

    -- Exit Features
    AllowLongPressExit = true,      -- Enable feature to leave the door open with a long press of the exit key
    LongPressDuration = 250        -- Duration (ms) to detect a long press for exiting the vehicle
}
