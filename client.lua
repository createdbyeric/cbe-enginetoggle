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
        Citizen.Wait(0)

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
                if not engineRunning and Config.BlockControlsIfEngineOff then
                    DisableControlAction(2, 71, true) -- Disable accelerator to prevent auto-start
                end
            end
        elseif isInVehicle and not isInAnyVehicle then
            if currentVehicle then
                if Config.EngineAlwaysOn and engineRunning then
                    -- Keep the engine running after exit
                    SetVehicleEngineOn(currentVehicle, true, true, false)
                else
                    -- Save engine state on exit if SaveEngineState is enabled
                    if Config.SaveEngineState then
                        local netId = VehToNet(currentVehicle)
                        vehicleEngineStates[netId] = {
                            state = engineRunning,
                            playerId = GetPlayerServerId(NetworkGetEntityOwner(currentVehicle))
                        }
                    end
                    -- Ensure engine turns off if toggled off
                    SetVehicleEngineOn(currentVehicle, false, true, false)
                end
            end

            -- Reset tracking variables
            isInVehicle = false
            currentVehicle = nil
        end

        if isInVehicle and currentVehicle and not engineRunning and Config.BlockControlsIfEngineOff then
            -- Block acceleration and brake if engine is off
            DisableControlAction(0, 71, true) -- INPUT_VEH_ACCELERATE
            DisableControlAction(0, 72, true) -- INPUT_VEH_BRAKE
        end

        if Config.AllowLongPressExit then
            if IsControlPressed(0, EXIT_KEY) then
                if not isHoldingKey then
                    isHoldingKey = true
                    holdStartTime = GetGameTimer()
                elseif isHoldingKey and GetGameTimer() - holdStartTime >= Config.LongPressDuration then
                    -- Long press detected
                    if IsPedInAnyVehicle(playerPed, false) then
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        TaskLeaveVehicle(playerPed, vehicle, 256) -- 256 flag leaves the door open
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

        -- Periodic cleanup of old or invalid vehicle states
        for netId, state in pairs(vehicleEngineStates) do
            if not NetworkDoesNetworkIdExist(netId) then
                vehicleEngineStates[netId] = nil
            end
        end
    end
end)