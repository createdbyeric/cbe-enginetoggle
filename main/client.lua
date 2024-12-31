local isInVehicle = false
local currentVehicle = nil
local engineRunning = false
local vehicleEngineStates = {} -- Table to save engine states for vehicles

local EXIT_KEY = 23 -- Default F key
local isHoldingKey = false
local holdStartTime = 0

RegisterCommand("eng", function()
    local playerPed = PlayerPedId()

if IsPedInAnyVehicle(playerPed, false) then
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    -- Driver-only enforcement
    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
        return -- Only the driver can toggle the engine
    end

    -- Toggle engine state based on configuration
    if DoesEntityExist(vehicle) and (not Config.ToggleEngineDriverOnly or GetPedInVehicleSeat(vehicle, -1) == playerPed) then
        engineRunning = not engineRunning
        SetVehicleEngineOn(vehicle, engineRunning, false, true)
        -- Ensure engine state is maintained properly to prevent flickering
        if Config.SaveEngineState then
            vehicleEngineStates[VehToNet(vehicle)] = {
                state = engineRunning,
                playerId = GetPlayerServerId(NetworkGetEntityOwner(vehicle))
            } -- Save the state with ownership
        end
    end
end
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100) -- Reduced frequency for state monitoring

    local playerPed = PlayerPedId()
    local isInAnyVehicle = IsPedInAnyVehicle(playerPed, false)

    if not isInVehicle and isInAnyVehicle then
        currentVehicle = GetVehiclePedIsIn(playerPed)
        isInVehicle = true

        if Config.SaveEngineState then
            -- Restore engine state if it exists, otherwise use current state
            local netId = VehToNet(currentVehicle)
            if vehicleEngineStates[netId] ~= nil and vehicleEngineStates[netId].playerId == GetPlayerServerId(NetworkGetEntityOwner(currentVehicle)) then
                engineRunning = vehicleEngineStates[netId].state
            elseif not GetIsVehicleEngineRunning(currentVehicle) then
                engineRunning = false -- Default to off if current state is off
            else
                engineRunning = true -- Respect the current running state
            end

            -- Enforce initial engine state
            SetVehicleEngineOn(currentVehicle, engineRunning, false, true)
        end
    elseif isInVehicle and not isInAnyVehicle then
        if currentVehicle then
            -- Maintain the engine state without toggling
            SetVehicleEngineOn(currentVehicle, engineRunning, true, false)

            -- Save engine state on exit if SaveEngineState is enabled
            if Config.SaveEngineState then
                local netId = VehToNet(currentVehicle)
                vehicleEngineStates[netId] = {
                    state = engineRunning,
                    playerId = GetPlayerServerId(NetworkGetEntityOwner(currentVehicle))
                }
            end
        end

        -- Reset tracking variables
        isInVehicle = false
        currentVehicle = nil
    end
end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Run every frame for responsiveness

    if isInVehicle and currentVehicle and not engineRunning and Config.BlockControlsIfEngineOff then
        local controlsToBlock = {71, 72, 59} -- Accelerate, Brake, Turn Left/Right
        for _, control in ipairs(controlsToBlock) do
            DisableControlAction(0, control, true)
        end
    end

    -- Handle exit logic
    if IsControlPressed(0, EXIT_KEY) or (Config.AllowLongPressExit and Config.LongPressDuration) then
        if IsControlPressed(0, EXIT_KEY) and not isHoldingKey then
            isHoldingKey = true
            holdStartTime = GetGameTimer()
        elseif isHoldingKey and Config.LongPressDuration and GetGameTimer() - holdStartTime >= Config.LongPressDuration then
            -- Long press or normal press detected
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                -- Maintain the current engine state when exiting
                SetVehicleEngineOn(vehicle, engineRunning, true, false)

                -- Handle door open if configured
                TaskLeaveVehicle(PlayerPedId(), vehicle, 256)
            end

            -- Reset holding state
            Citizen.Wait(50) -- Debounce before resetting
            isHoldingKey = false
        end
    else
        -- Reset holding state if the key is released
        isHoldingKey = false
    end
end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Cleanup every 10 seconds

    for netId, state in pairs(vehicleEngineStates) do
        if not NetworkDoesNetworkIdExist(netId) then
            vehicleEngineStates[netId] = nil
        end
    end
end
end)
