local handCamera, active = nil, false

local function disableCamera()
    RenderScriptCams(false, true, Config.Settings["Wait"], false, false)

    SetTimeout(Config.Settings["Wait"] * 2, function()
        if handCamera ~= nil and not active then
            SetCamActive(handCamera, false)
            DestroyCam(handCamera)
            handCamera = nil
        end
    end)

    active = false
end

local function setCameraLook()
    local ped = PlayerPedId()
    local cameraCoords = GetGameplayCamCoord()
    local cameraRotation = GetGameplayCamRot(2)
    local gameplayCamFov = GetGameplayCamFov()

    local coordsRelativeToPlayer = GetOffsetFromEntityGivenWorldCoords(ped, cameraCoords.x, cameraCoords.y, cameraCoords.z)
    local leftShoulderCoords = GetOffsetFromEntityInWorldCoords(ped, coordsRelativeToPlayer.x, coordsRelativeToPlayer.y, coordsRelativeToPlayer.z)

    SetCamCoord(handCamera, leftShoulderCoords.x, leftShoulderCoords.y, leftShoulderCoords.z)
    SetCamRot(handCamera, cameraRotation.x, cameraRotation.y, cameraRotation.z, 2)
    AttachCamToEntity(handCamera, ped, coordsRelativeToPlayer.x - Config.Settings["Range"], coordsRelativeToPlayer.y, coordsRelativeToPlayer.z, true)
    SetCamFov(handCamera, gameplayCamFov)

    ShowHudComponentThisFrame(14)
end

local function toggleCamera()
    if not active then
        if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then return end

        if handCamera ~= nil then
            SetCamActive(handCamera, false)
            DestroyCam(handCamera)
            handCamera = nil
        end

        handCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(handCamera, true)
        RenderScriptCams(true, true, Config.Settings["Wait"], false, false)
        
        if not DoesCamExist(handCamera) then
            return disableCamera()
        end

        active = true
        setCameraLook()
    else
        SetCamAffectsAiming(handCamera, true)
        disableCamera()
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if active then
            if GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) then
                toggleCamera()
            else
                setCameraLook()
            end
        else
            Citizen.Wait(Config.Settings["Wait"])
        end
    end
end)

RegisterKeyMapping(Config.Command["Command"], Config.Command["KeyMapping"]["Description"] 'keyboard', Config.Command["KeyMapping"]["Key"])

RegisterCommand(Config.Command["Command"], function()
    toggleCamera()
end)