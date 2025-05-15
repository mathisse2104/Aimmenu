-- Verwijderde versie zonder holster/unholster animaties
local USING_INVENTORY <const> = GetResourceState("ox_inventory"):find("start") and GetConvarInt("inventory:weaponanims", 1) ~= 1

if USING_INVENTORY then
    local items = exports.ox_inventory:Items()

    AddEventHandler("ox_inventory:usedItem", function(name, slotId, metadata)
        local data = items[name]
        if not data or not data.weapon or data.ammo then return end

        local ped = cache.ped
        GiveWeaponToPed(ped, data.hash, 0, false, true)
        SetCurrentPedWeapon(ped, data.hash, true)
    end)

    AddEventHandler("ox_inventory:currentWeapon", function(weapon)
        local hash = cache.weapon
        local ped = cache.ped
        if not hash or weapon then return end

        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    end)
else
    local _, weapon = GetCurrentPedWeapon(cache.ped, true)

    CreateThread(function()
        while true do
            local _, currentWeapon = GetCurrentPedWeapon(cache.ped, true)
            if currentWeapon ~= weapon then
                weapon = currentWeapon
            end
            Wait(0)
        end
    end)
end