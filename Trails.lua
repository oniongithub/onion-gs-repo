local localPlayer, origin, velocity, eyes, vector, trailCache, screenSize = entity.get_local_player(), nil, nil, nil, require("vector"), {}, client.screen_size()

local controls = {
    trail = ui.new_checkbox("Lua", "A", "Trail Enabled"),
    frame = ui.new_checkbox("Lua", "A", "Trail Wireframe"),
    color = ui.new_color_picker("Lua", "A", "Trail Color", 255, 255, 255),
    segments = ui.new_slider("Lua", "A", "Trail Segments", 2, 150, 25),
    distance = ui.new_slider("Lua", "A", "Trail Segment Distance", 2, 150, 25),
    width = ui.new_slider("Lua", "A", "Trail Width", 2, 100, 10),
    randomWidth = ui.new_checkbox("Lua", "A", "Randomize Width"),
}

function client.trace(skip, pos1, pos2)
    local function numberDifference(x, y, fraction)
        local difference = math.abs(x - y)
        if (x > y) then
            return x - difference * fraction
        else
            return x + difference * fraction
        end
    end

    local fraction, hitEnt = client.trace_line(skip, pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z)
    local pos4 = vector(numberDifference(pos1.x, pos2.x, fraction), numberDifference(pos1.y, pos2.y, fraction), numberDifference(pos1.z, pos2.z, fraction))

    return {fraction = fraction, entity = hitEnt, point = pos4}
end

function client.to_radian(number)
    return number * (math.pi / 180)
end

client.set_event_callback("paint_ui", function()
    localPlayer = entity.get_local_player()
    screenSize = vector(client.screen_size())

    if (ui.get(controls.trail)) then
        if (localPlayer and entity.is_alive(localPlayer)) then
            if (trailCache and #trailCache > 0) then
                local lastPos1, lastPos2
                local r, g, b, a = ui.get(controls.color)
                for i = 1, #trailCache do
                    local pos1, pos2 = vector(renderer.world_to_screen(trailCache[i].pos1:unpack())), vector(renderer.world_to_screen(trailCache[i].pos2:unpack()))

                    if (pos1.x ~= 0 and pos1.y ~= 0 and pos2.x ~= 0 and pos2.y ~= 0) then
                        if (lastPos1 and lastPos2) then
                            renderer.triangle(pos1.x, pos1.y, pos2.x, pos2.y, lastPos1.x, lastPos1.y, r, g, b, a)
                            renderer.triangle(lastPos1.x, lastPos1.y, pos2.x, pos2.y, lastPos2.x, lastPos2.y, r, g, b, a)

                            if (ui.get(controls.frame)) then
                                renderer.line(pos1.x, pos1.y, pos2.x, pos2.y, r, g, b, 255)

                                renderer.line(pos1.x, pos1.y, lastPos1.x, lastPos1.y, r, g, b, 255)
                                renderer.line(pos1.x, pos1.y, lastPos2.x, lastPos2.y, r, g, b, 255)
                                renderer.line(pos2.x, pos2.y, lastPos1.x, lastPos1.y, r, g, b, 255)
                                renderer.line(pos2.x, pos2.y, lastPos2.x, lastPos2.y, r, g, b, 255)

                                renderer.line(lastPos2.x, lastPos2.y, lastPos1.x, lastPos1.y, r, g, b, 255)
                            end

                            lastPos1, lastPos2 = pos1, pos2
                        else
                            lastPos1, lastPos2 = pos1, pos2
                        end
                    end
                end
            end
        else
            trailCache = {}
        end
    else
        trailCache = {}
    end
end)

client.set_event_callback("setup_command", function()
    if (ui.get(controls.trail)) then
        if (localPlayer and entity.is_alive(localPlayer)) then
            origin = vector(entity.get_origin(localPlayer))
            velocity = vector(entity.get_prop(localPlayer, "m_vecVelocity"))
            eyes = vector(client.camera_angles())
            
            if (origin and velocity and eyes and trailCache) then
                local width, segments, distance = ui.get(controls.width) / 2, ui.get(controls.segments), ui.get(controls.distance)
                if (ui.get(controls.randomWidth)) then width = math.random(1, 50) end
                
                if (#trailCache <= 0 or trailCache[#trailCache].origin:dist2d(origin) > distance) then
                    local trace3 = client.trace(localPlayer, origin, vector(origin.x, origin.y, origin.z - 1000))
                    local pos1 = vector(origin.x + width * math.cos(client.to_radian(eyes.y - 90)), origin.y + width * math.sin(client.to_radian(eyes.y - 90)), trace3.point.z)
                    local pos2 = vector(origin.x + width * math.cos(client.to_radian(eyes.y + 90)), origin.y + width * math.sin(client.to_radian(eyes.y + 90)), trace3.point.z)
                    
                    if (#trailCache >= segments) then
                        local removed = #trailCache - segments + 1

                        for i = 1, removed do
                            table.remove(trailCache, 1)
                        end
                    end

                    table.insert(trailCache, {origin = origin, pos1 = pos1, pos2 = pos2})
                end
            end
        end
    end
end)

client.set_event_callback("player_death", function(e)
    local ent = client.userid_to_entindex(e.userid)

    if (ent == localPlayer) then
        trailCache = {}
    end
end)

client.set_event_callback("player_connect_full", function(e)
    local ent = client.userid_to_entindex(e.userid)

    if (ent == localPlayer) then
        trailCache = {}
    end
end)

client.set_event_callback("round_start", function()
    trailCache = {}
end)