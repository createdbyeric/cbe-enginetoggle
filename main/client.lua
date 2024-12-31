local isInVehicle = false
local currentVehicle = nil
local engineRunning = false
local vehicleEngineStates = {} -- Table to save engine states for vehicles

local EXIT_KEY = 23 -- Default F key

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
            currentVehicle = GetVehiclePedIsIn(playerPed, false)
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

        -- Handle exit logic
        if IsControlPressed(0, EXIT_KEY) then
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                -- Ensure engine state remains consistent
                if engineRunning then
                    SetVehicleEngineOn(vehicle, true, true, false) -- Maintain the engine state
                end

                -- Default behavior: Close the door immediately
                TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Cleanup every 10 seconds

        for netId, state in pairs(vehicleEngineStates) do
            local vehicle = NetToVeh(netId)
            if not DoesEntityExist(vehicle) or not NetworkDoesNetworkIdExist(netId) then
                vehicleEngineStates[netId] = nil
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Run every frame for responsiveness

        -- Block controls when engine is off
        if isInVehicle and currentVehicle and not engineRunning and Config.BlockControlsIfEngineOff then
            local controlsToBlock = {71, 72, 59, 63, 64} -- Accelerate, Brake, Turn Left/Right, Steer Left/Right
            for _, control in ipairs(controlsToBlock) do
                DisableControlAction(0, control, true)
            end
        end
    end
end)

local holdKeyStartTime = 0
local isKeyHeld = false
local isEnteringVehicle = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10) -- Throttle for key-holding checks

        local ped = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(ped, false)

        if Config.EnableHoldToLeaveDoorOpen then
            -- Key holding logic
            if IsControlPressed(0, EXIT_KEY) then
                if not isKeyHeld then
                    holdKeyStartTime = GetGameTimer()
                    isKeyHeld = true
                elseif GetGameTimer() - holdKeyStartTime > 250 and isInVehicle then
                    local vehicle = GetVehiclePedIsIn(ped, false)

                    -- Ensure engine remains on and leave door open
                    if vehicle and GetIsVehicleEngineRunning(vehicle) then
                        SetVehicleEngineOn(vehicle, true, true, false)
                        SetVehicleDoorOpen(vehicle, 0, false, false) -- Open driver's door
                    end
                end
            else
                isKeyHeld = false -- Reset key holding state
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100) -- Throttle for re-entry checks

        local ped = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(ped, false)

        -- Handle door closure on re-entry
        if not isEnteringVehicle and isInVehicle then
            isEnteringVehicle = true
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle then
                Citizen.Wait(200) -- Allow entry animation
                SetVehicleDoorShut(vehicle, 0, false) -- Close driver's door
            end
        elseif isEnteringVehicle and not isInVehicle then
            isEnteringVehicle = false -- Reset state when exiting the vehicle
        end
    end
end)

-- OneSync compatibility for engine state syncing
RegisterNetEvent("updateVehicleEngineState")
AddEventHandler("updateVehicleEngineState", function(netId, state)
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle, -1) then -- Ensure valid vehicle and no driver
        SetVehicleEngineOn(vehicle, state, false, true)
        engineRunning = state
    else-- Debug log
    end
end)
