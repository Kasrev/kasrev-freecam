local isActive = false
local cam = nil
local camPos = vector3(0, 0, 0)
local camRot = vector3(0, 0, 0)
local rollAngle = 0.0
local speed = Config.MovementSpeed

local vDown = false
local vHoldStart = 0
local vHoldProcessed = false

local uiHidden = false

local Locale = Config.Locale == 'en' and {
    activated = 'Freecam: WASD move, R/F up/down, Q/E tilt, Scroll speed, Shift 3x',
    deactivated = 'Freecam closed',
    maxDist = 'Max distance reached, freecam closed',
} or {
    activated = 'Freecam: WASD hareket, R/F yukari/asagi, Q/E yatay kamera, Scroll hiz, Shift 3x',
    deactivated = 'Freecam kapatildi',
    maxDist = 'Maksimum mesafeye ulasildi, freecam kapatildi',
}

local function Notify(msg)
    SendNUIMessage({ type = 'toast', text = msg })
end

local function StopFreecam()
    if cam then
        RenderScriptCams(false, true, Config.CameraTransition, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
    isActive = false
    speed = Config.MovementSpeed
    rollAngle = 0.0
    isIdle = false

    DisplayRadar(true)
    FreezeEntityPosition(PlayerPedId(), false)

    uiHidden = false
    SendNUIMessage({ type = 'hide' })
    PlaySoundFrontend(-1, "Focus_Out", "HintCamSounds", true)
    Notify(Locale.deactivated)
end

local function StartFreecam(ped, coords)
    isActive = true
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    local heading = GetEntityHeading(ped)
    camPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 1.0)
    camRot = vector3(0.0, 0.0, heading)
    rollAngle = 0.0

    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    SetCamRot(cam, camRot.x, rollAngle, camRot.z)
    RenderScriptCams(true, true, Config.CameraTransition, true, true)

    DisplayRadar(false)
    FreezeEntityPosition(ped, true)

    SendNUIMessage({ type = 'show', locale = Config.Locale })
    PlaySoundFrontend(-1, "Focus_In", "HintCamSounds", true)
end

local function UpdateFreecam(ped, coords)
    local mx = GetDisabledControlNormal(0, 1) * Config.MouseSensitivity
    local my = GetDisabledControlNormal(0, 2) * Config.MouseSensitivity

    camRot = vector3(
        math.max(-89.0, math.min(89.0, camRot.x - my)),
        0.0,
        camRot.z - mx
    )

    if IsDisabledControlJustPressed(0, 15) then speed = math.min(10.0, speed + 0.3) end
    if IsDisabledControlJustPressed(0, 16) then speed = math.max(0.1, speed - 0.3) end

    local moveH = vector3(0, 0, 0)
    local moveV = 0.0
    local rz = math.rad(camRot.z)

    if IsDisabledControlPressed(0, 32) then moveH = moveH + vector3(-math.sin(rz), math.cos(rz), 0) end
    if IsDisabledControlPressed(0, 33) then moveH = moveH + vector3(math.sin(rz), -math.cos(rz), 0) end
    if IsDisabledControlPressed(0, 34) then moveH = moveH + vector3(-math.cos(rz), -math.sin(rz), 0) end
    if IsDisabledControlPressed(0, 35) then moveH = moveH + vector3(math.cos(rz), math.sin(rz), 0) end
    if IsDisabledControlPressed(0, 45) then moveV = 1.0 end
    if IsDisabledControlPressed(0, 23) then moveV = -1.0 end

    if IsDisabledControlPressed(0, 44) then rollAngle = rollAngle - 0.5 end
    if IsDisabledControlPressed(0, 51) then rollAngle = rollAngle + 0.5 end

    local currentSpeed = speed
    if IsDisabledControlPressed(0, 21) then currentSpeed = currentSpeed * 3.0 end

    local len = #(moveH)
    if len > 0 then
        moveH = moveH / len * currentSpeed
    end

    camPos = camPos + moveH + vector3(0, 0, moveV * Config.VerticalSpeed * currentSpeed)

    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    SetCamRot(cam, camRot.x, rollAngle, camRot.z)

    local dist = #(camPos - coords)
    SendNUIMessage({ type = 'update', distance = dist, speed = speed })

    if dist > Config.MaxDistance then
        Notify(Locale.maxDist)
        StopFreecam()
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        DisableControlAction(0, 0, true)
        DisableControlAction(0, 47, true)

        local vPressed = IsDisabledControlPressed(0, 0) or IsDisabledControlPressed(0, 47)

        if vPressed and not vDown then
            vDown = true
            vHoldStart = GetGameTimer()
            vHoldProcessed = false
        elseif not vPressed and vDown then
            vDown = false
            vHoldProcessed = false
        end

        if vDown and not vHoldProcessed and (GetGameTimer() - vHoldStart) >= Config.HoldTime then
            vHoldProcessed = true
            if isActive then
                StopFreecam()
            else
                StartFreecam(PlayerPedId(), GetEntityCoords(PlayerPedId()))
            end
        end

        if isActive then
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 36, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 51, true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            DisableControlAction(0, 21, true)

            if not (vDown and not vHoldProcessed) then
                UpdateFreecam(PlayerPedId(), GetEntityCoords(PlayerPedId()))
            end

        end
    end
end)

RegisterCommand('toggleui', function()
    if isActive then
        uiHidden = not uiHidden
        SendNUIMessage({ type = 'toggle_ui' })
    end
end, false)
RegisterKeyMapping('toggleui', 'Toggle Freecam UI', 'keyboard', 'n')
