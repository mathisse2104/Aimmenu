local DATA_AIM <const> = lib.load("data.aim")

local animations = {
    default = `Default`,
    gang = `Gang1H`,
    hillbilly = `Hillbilly`
}

-- Set aim animation
local function setAimAnim(anim)
    if type(anim) ~= "string" then return end
    anim = anim:lower()
    if not animations[anim] then return end
    LocalPlayer.state:set("weaponAnimOverride", anim, true)
end

-- Apply animations to others via statebag
AddStateBagChangeHandler("weaponAnimOverride", nil, function(bagName, key, value, reserved, replicated)
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 or replicated or not value then return end
    SetWeaponAnimationOverride(GetPlayerPed(ply), animations[value] or `Default`)
end)

-- Apply to your own ped after cache
lib.onCache("ped", function()
    local anim = LocalPlayer.state.weaponAnimOverride
    if anim then
        setAimAnim(anim)
    end
end)

-- /aim command register
if DATA_AIM.command then
    RegisterCommand(DATA_AIM.command, function(source, args)
        if not args[1] then
            lib.notify({
                title = "Gebruik",
                description = "Voer een animatie in: gang | hillbilly | default",
                type = "error"
            })
            return
        end
        setAimAnim(args[1])
    end, false)

    TriggerEvent("chat:addSuggestion", ("/%s"):format(DATA_AIM.command), "Weapon aim animation", {
        { name = "animation", help = "gang | hillbilly | default" }
    })
end

-- Set start animation if needed
if DATA_AIM.default then
    setAimAnim(DATA_AIM.default)
end

-- Exports
exports("setAimAnim", setAimAnim)
exports("getAimAnim", function()
    return LocalPlayer.state.weaponAnimOverride or "default"
end)

-- Default: custom aim anims OFF
LocalPlayer.state:set("useCustomAimAnims", false, true)

-- Always hide crosshair
CreateThread(function()
    while true do
        Wait(0)
        HideHudComponentThisFrame(14)
    end
end)

--Camera handling thread
local aiming = false

CreateThread(function()
    while true do
        Wait(0)

        local isAiming = IsPlayerFreeAiming(PlayerId())
        local aimPressed = IsControlPressed(0, 25)

        if LocalPlayer.state.useCustomAimAnims then
-- CUSTOM ON = ANIMATIONS ACTIVE, ALWAYS THIRD PERSON
            if isAiming and GetFollowPedCamViewMode() == 4 then
                SetFollowPedCamViewMode(1)
            end
        else
-- CUSTOM OFF = STANDARD ANIMATION, LOCK ON FIRST PERSON
            if aimPressed then
                if GetFollowPedCamViewMode() ~= 4 then
                    SetFollowPedCamViewMode(4)
                end
                aiming = true
            elseif aiming then
                SetFollowPedCamViewMode(1)
                aiming = false
            end
        end
    end
end)

-- /aimtoggle command
RegisterCommand("aimtoggle", function()
    local current = LocalPlayer.state.useCustomAimAnims
    local newState = not current
    LocalPlayer.state:set("useCustomAimAnims", newState, true)

    if newState then
        lib.notify({
            title = "Aim Modus",
            description = "Custom aim animations enabled (third person only)",
            type = "success"
        })
    else
        lib.notify({
            title = "Aim Modus",
            description = "Default animation active (first person only)",
            type = "info"
        })
        -- Terug naar default anim
        setAimAnim("default")
    end
end, false)
