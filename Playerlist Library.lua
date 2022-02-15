local plistReference, plistGet, plistSet, plistControls = ui.reference("Players", "Players", "Player List"), plist.get, plist.set, {};

if (plistReference) then
    function plist.get(player, fieldname)
        local currentPlayer, value, pValue = ui.get(plistReference), nil, nil

        ui.set(plistReference, player)
        if (#plistControls > 0) then
            for i = 1, #plistControls do
                if (plistControls[i].name == string.lower(fieldname)) then
                    value = ui.get(plistControls[i].reference)
                    goto PastElse
                end
            end
        end

        pValue = plistGet(player, fieldname)
        if (type(pValue) ~= "nil") then
            value = pValue;
        end

        ::PastElse::

        ui.set(plistReference, currentPlayer)
        return value
    end

    function plist.set(player, fieldname, value)
        local currentPlayer = ui.get(plistReference)

        ui.set(plistReference, player)
        if (#plistControls > 0) then
            for i = 1, #plistControls do
                if (plistControls[i].name == string.lower(fieldname)) then
                    ui.set(plistControls[i].reference, value)
                    goto PastElse
                end
            end
        end

        pcall(function() pValue = plistSet(player, fieldname, value) end)

        ::PastElse::

        ui.set(plistReference, currentPlayer)
    end

    function plist.add_control(fieldname, control, default)
        table.insert(plistControls, {reference = control, cache = {}, default = default, name = string.lower(fieldname)})
        local tableIndex = #plistControls

        ui.set_callback(control, function()
            local controlValue = ui.get(control)
            local player = ui.get(plistReference)

            if (#plistControls[tableIndex].cache > 0) then
                for i = 1, #plistControls[tableIndex].cache do
                    if (plistControls[tableIndex].cache[i].entity == player) then
                        plistControls[tableIndex].cache[i].value = controlValue

                        goto PastElse
                    end
                end     
            end

            table.insert(plistControls[tableIndex].cache, {entity = player, value = controlValue})

            ::PastElse::
        end)
    end

    ui.set_callback(plistReference, function()
        local player = ui.get(plistReference)

        if (#plistControls > 0) then
            for i = 1, #plistControls do

                if (#plistControls[i].cache > 0) then
                    for f = 1, #plistControls[i].cache do
                        if (plistControls[i].cache[f].entity == player) then
                            ui.set(plistControls[i].reference, plistControls[i].cache[f].value)
                            goto PastElse
                        end
                    end
                end
                
                ui.set(plistControls[i].reference, plistControls[i].default)

                ::PastElse::
            end     
        end
    end)
end