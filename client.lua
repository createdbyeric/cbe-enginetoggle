local isInVehicle = false
local currentVehicle = nil
local engineRunning = false

RegisterCommand("eng", function()
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        -- Toggle engine state based on configuration
        if DoesEntityExist(vehicle) and (not Config.ToggleEngineDriverOnly or GetPedInVehicleSeat(vehicle, -1) == playerPed) then
            engineRunning = not engineRunning
            SetVehicleEngineOn(vehicle, engineRunning, false, true)
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
            engineRunning = GetIsVehicleEngineRunning(currentVehicle)

            -- Enforce initial engine state
            SetVehicleEngineOn(currentVehicle, engineRunning, false, true)
        elseif isInVehicle and not isInAnyVehicle then
            isInVehicle = false
            currentVehicle = nil
        end

        if isInVehicle and currentVehicle and not engineRunning and Config.BlockControlsIfEngineOff then
            -- Block acceleration and brake if engine is off
            DisableControlAction(0, 71, true) -- INPUT_VEH_ACCELERATE
            DisableControlAction(0, 72, true) -- INPUT_VEH_BRAKE
        end
    end
end)