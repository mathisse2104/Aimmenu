RegisterCommand('aimmenu', function()
    if not LocalPlayer.state.useCustomAimAnims then
        lib.notify({
            title = 'Aimmenu',
            description = 'First, use /aimtoggle to enable custom aim animations.',
            type = 'error'
        })
        return
    end

    local options = {
        { label = 'Default', value = 'default' },
        { label = 'Gang', value = 'gang' },
        { label = 'Hillbilly', value = 'hillbilly' }
    }

    local input = lib.inputDialog('Kies Aim Stijl', {
        {
            type = 'select',
            label = 'Aim Style',
            description = 'Choose what your new aim style is',
            options = options,
            required = true,
            default = 'default'
        }
    })

    if input then
        local selectedAnim = input[1]
        ExecuteCommand("aim " .. selectedAnim)

        lib.notify({
            title = 'You have adjusted your aim',
            description = 'New aim style: ' .. selectedAnim,
            type = 'success'
        })
    end
end, false)
