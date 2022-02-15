local references = {
    dpi = ui.reference("Misc", "Settings", "DPI scale"),
}

--[[
    Base Modifications
--]]

local p = print
function print(...)
    local args = {...} local endString = ""

    if (type(args) == "table" and #args > 0) then
        for i = 1, #args do
            local isString, argString = pcall(function() return tostring(args[i]) end)

            if (isString) then
                if (i == 1) then
                    endString = argString
                else
                    endString = endString .. " " .. argString
                end
            end
        end
    end

    if (endString and endString ~= "") then
        p(endString)
    end
end

--[[
    Colors
--]]

local colors = {} colors.__index = colors

function color(r, g, b, a)
    if (type(r) ~= "number") then r = 255 end
    if (type(g) ~= "number") then g = 255 end
    if (type(b) ~= "number") then b = 255 end
    if (type(a) ~= "number") then a = 255 end

    return setmetatable({r = r, g = g, b = b, a = a}, colors)
end

--[[
    Vectors
--]]

local vectors = {} vectors.__index = vectors

function vector(x, y, z)
    if (type(x) ~= "number") then x = 0 end
    if (type(y) ~= "number") then y = 0 end
    if (type(z) ~= "number") then z = nil end

    return setmetatable({x = x, y = y, z = z}, vectors)
end

function vectors:print()
    if (self.z) then
        print(self.x, self.y, self.z)
    else
        print(self.x, self.y)
    end
end

function vectors:unpack()
    return self.x, self.y, self.z
end

function vectors:clear()
    self.x, self.y = 0, 0 if (self.z) then self.z = 0 end
end

function vectors:length2D()
    return math.sqrt(self.x^2 + self.y^2)
end

function vectors:length()
    if (self.z) then return math.sqrt(self.x^2 + self.y^2 + self.z^2) else return self:length2D() end
end

function vectors:dist2D(vec)
    return vector(vec.x - self.x, vec.y - self.y):length2D()
end

function vectors:dist(vec)
    if (self.z) then return vector(vec.x - self.x, vec.y - self.y, vec.z - self.z):length() else return self:dist2D(vec) end
end

function vectors:clamp(min, max)
    if (self.x > max) then self.x = max elseif (self.x < min) then self.x = min end
    if (self.y > max) then self.y = max elseif (self.y < min) then self.y = min end
    if (self.z) then if (self.z > max) then self.z = max elseif (self.z < min) then self.z = min end end
end

--[[
    Client Library Modifications
--]]

local clientFunctions = {
    trace_line = client.trace_line,
    camera_position = client.camera_position,
    eye_position = client.eye_position,
    screen_size = client.screen_size
}

function client.trace_line(skip, pos1, pos2)
    local p, h = clientFunctions.trace_line(skip, pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z)

    if (p and h) then
        local e = vector(vector1.x + (vector2.x - vector1.x * percent), vector1.y + (vector2.y - vector1.y * percent), vector1.z + (vector2.z - vector1.z * percent))
        if (e) then return { percent = percent, entity = h, point = e } end
    end
end

function client.get_dpi()
    local value = ui.get(reference.dpi):gsub('[%c%p%s]', '')

    if (pcall(function() tonumber(value) end)) then
        return tonumber(value) / 100
    else
        return 1
    end
end

function client.camera_position()
    return vector(clientFunctions.camera_position())
end

function client.eye_position()
    return vector(clientFunctions.eye_position())
end

function client.screen_size()
    return vector(clientFunctions.screen_size())
end

--[[
    Entity Library Modifications
--]]

local entityFunctions = {
    get_local_player = entity.get_local_player,
    get_all = entity.get_all,
    get_players = entity.get_players,
    get_classname = entity.get_classname,
    set_prop = entity.set_prop,
    get_prop = entity.get_prop,
    is_enemy = entity.is_enemy,
    is_alive = entity.is_alive,
    is_dormant = entity.is_dormant,
    get_player_name = entity.get_player_name,
    get_player_weapon = entity.get_player_weapon,
    hitbox_position = entity.hitbox_position,
    get_steam64 = entity.get_steam64,
    get_bounding_box = entity.get_bounding_box,
    get_origin = entity.get_origin,
    get_esp_data = entity.get_esp_data
}

local entities = {} entities.__index = entities

function entities:get_classname()
    return entityFunctions.get_classname(self.entity)
end

function entities:set_prop(prop, value, index)
    entityFunctions.set_prop(self.entity, prop, value, index)
end

function entities:get_prop(prop, index)
    return entityFunctions.get_prop(self.entity, prop, index)
end

function entities:is_enemy()
    return entityFunctions.is_enemy(self.entity)
end

function entities:is_alive()
    return entityFunctions.is_alive(self.entity)
end

function entities:is_dormant()
    return entityFunctions.is_dormant(self.entity)
end

function entities:get_player_name()
    return entityFunctions.get_player_name(self.entity)
end

function entities:get_player_weapon()
    return entityFunctions.get_player_weapon(self.entity)
end

function entities:hitbox_position(hitbox)
    return vector(entityFunctions.hitbox_position(self.entity, hitbox))
end

function entities:get_origin()
    return vector(entityFunctions.get_origin(self.entity))
end

function entities:get_steam64()
    return entityFunctions.get_steam64(self.entity)
end

function entities:get_esp_data()
    return entityFunctions.get_esp_data(self.entity)
end

function entities:get_bounding_box()
    return entityFunctions.get_bounding_box(self.entity)
end

function entity.get_local_player()
    return setmetatable({entity = entityFunctions.get_local_player()}, entities)
end

function entity.get_all(classname)
    return setmetatable({entity = entityFunctions.get_all(classname)}, entities)
end

function entity.get_players(team)
    return setmetatable({entity = entityFunctions.get_players(team)}, entities)
end

function entity.get_game_rules()
    return setmetatable({entity = entityFunctions.get_game_rules()}, entities)
end

function entity.get_player_resource()
    return setmetatable({entity = entityFunctions.get_player_resource()}, entities)
end

--[[
    Render Library Modifications
--]]

local renderFunctions = {
    text = renderer.text,
    measure_text = renderer.measure_text,
    rectangle = renderer.rectangle,
    line = renderer.line,
    gradient = renderer.gradient,
    circle = renderer.circle,
    circle_outline = renderer.circle_outline,
    triangle = renderer.triangle,
    world_to_screen = renderer.world_to_screen,
    indicator = renderer.indicator,
    texture = renderer.texture,
    load_svg = renderer.load_svg,
    load_png = renderer.load_png,
    load_jpg = renderer.load_jpg,
    load_rgba = renderer.load_rgba,
    blur = renderer.blur
}

function renderer.text(position, color, flags, max_width, ...)
    renderFunctions.text(position.x, position.y, color.r, color.g, color.b, color.a, flags, max_width, ...)
end

function renderer.measure_text(flags, ...)
    return vector(renderFunctions.measure_text(flags, ...))
end

function renderer.rectangle(position, size, color, radius)
    if (radius and radius > 0) then
        if (radius > size.x / 2) then radius = size.x / 2 end
        if (radius > size.y / 2) then radius = size.y / 2 end

        renderFunctions.rectangle(position.x, position.y + radius, size.x, size.y - radius * 2, color.r, color.g, color.b, color.a);
        renderFunctions.rectangle(position.x + radius, position.y, size.x - radius * 2, radius, color.r, color.g, color.b, color.a);
        renderFunctions.rectangle(position.x + radius, position.y + size.y - radius, size.x - radius * 2, radius, color.r, color.g, color.b, color.a);

        renderFunctions.circle(position.x + radius, position.y + radius, color.r, color.g, color.b, color.a, radius, 180, 0.25);
        renderFunctions.circle(position.x + size.x - radius, position.y + radius, color.r, color.g, color.b, color.a, radius, 90, 0.25);
        renderFunctions.circle(position.x + size.x - radius, position.y + size.y - radius, color.r, color.g, color.b, color.a, radius, 0, 0.25);
        renderFunctions.circle(position.x + radius, position.y + size.y - radius, color.r, color.g, color.b, color.a, radius, 270, 0.25);
    else
        renderFunctions.rectangle(position.x, position.y, size.x, size.y, color.r, color.g, color.b, color.a)
    end
end

function renderer.rectangle_outline(position, size, color, radius)
    if (radius and radius > 0) then
        if (radius > size.x / 2) then radius = size.x / 2 end
        if (radius > size.y / 2) then radius = size.y / 2 end

        renderFunctions.rectangle(position.x + radius, position.y, size.x - radius * 2, 1, color.r, color.g, color.b, color.a)
        renderFunctions.rectangle(position.x + radius, position.y + size.y - 1, size.x - radius * 2, 1, color.r, color.g, color.b, color.a)
        renderFunctions.rectangle(position.x, position.y + radius, 1, size.y - radius * 2, color.r, color.g, color.b, color.a)
        renderFunctions.rectangle(position.x + size.x - 1, position.y + radius, 1, size.y - radius * 2, color.r, color.g, color.b, color.a)

        renderFunctions.circle_outline(position.x + radius, position.y + radius, color.r, color.g, color.b, color.a, radius, 180, 0.25, 1);
        renderFunctions.circle_outline(position.x + size.x - radius, position.y + radius, color.r, color.g, color.b, color.a, radius, 270, 0.25, 1);
        renderFunctions.circle_outline(position.x + size.x - radius, position.y + size.y - radius, color.r, color.g, color.b, color.a, radius, 0, 0.25, 1);
        renderFunctions.circle_outline(position.x + radius, position.y + size.y - radius, color.r, color.g, color.b, color.a, radius, 90, 0.25, 1);
    else
        renderFunctions.rectangle(position.x, position.y, size.x, 1, color.r, color.g, color.b, color.a)
        renderFunctions.rectangle(position.x, position.y + size.y - 1, size.x, 1, color.r, color.g, color.b, color.a)

        renderFunctions.rectangle(position.x, position.y + 1, 1, size.y - 2, color.r, color.g, color.b, color.a)
        renderFunctions.rectangle(position.x + size.x - 1, position.y + 1, 1, size.y - 2, color.r, color.g, color.b, color.a)
    end
end

function renderer.line(position, position2, color)
    renderFunctions.line(position.x, position.y, position2.x, position2.y, color.r, color.g, color.b, color.a)
end

function renderer.gradient(position, size, color1, color2, horizontal)
    renderFunctions.gradient(position.x, position.y, size.x, size.y, color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, horizontal)
end

function renderer.circle(position, color, radius, start_degrees, percentage)
    renderFunctions.circle(position.x, position.y, color.r, color.g, color.b, color.a, radius, start_degrees, percentage)
end

function renderer.circle_outline(position, color, radius, start_degrees, percentage, thickness)
    renderFunctions.circle_outline(position.x, position.y, color.r, color.g, color.b, color.a, radius, start_degrees, percentage, thickness)
end

function renderer.triangle(position, position2, position3, color)
    renderFunctions.triangle(position.x, position.y, position2.x, position2.y, position3.x, position3.y, color.r, color.g, color.b, color.a)
end

function renderer.world_to_screen(position)
    if (type(position.x) == "number" and type(position.y) == "number" and type(position.z) == "number") then
        local vec = vector(renderFunctions.world_to_screen(position.x, position.y, position.z))

        if (vec.x == 0 and vec.y == 0) then
            return nil
        else
            return vec
        end
    else
        return nil
    end
end

function renderer.indicator(color, ...)
    renderFunctions.indicator(color.r, color.g, color.b, color.a, ...)
end

function renderer.texture(id, position, size, color, mode, ...)
    renderFunctions.texture(id, position.x, position.y, size.x, size.y, color.r, color.g, color.b, color.a, mode, ...)
end

function renderer.load_svg(contents, size, ...)
    renderFunctions.load_svg(contents, size.x, size.y, ...)
end

function renderer.load_png(contents, size, ...)
    renderFunctions.load_png(contents, size.x, size.y, ...)
end

function renderer.load_jpg(contents, size, ...)
    renderFunctions.load_jpg(contents, size.x, size.y, ...)
end

function renderer.load_rgba(contents, size, ...)
    renderFunctions.load_rgba(contents, size.x, size.y, ...)
end

function renderer.blur(position, size, opacity, blur_radius, ...)
    renderFunctions.blur(position.x, position.y, size.x, size.y, opacity, blur_radius, ...)
end

function renderer.circle_3d(position, col, radius, outline)
    local prevScreen, screenPos, step, addedRotation = vector(0, 0), vector(0, 0), math.pi * 2 / 72, (math.pi * 2 * radius) / 360
    local scrPos = renderer.world_to_screen(position)

    if (scrPos) then
        for rotation = 0, math.pi * 2, step do
            local pos = vector(radius * math.cos(rotation + 1) + position.x, radius * math.sin(rotation + 1) + position.y, position.z)
            screenPos = renderer.world_to_screen(pos)

            if (screenPos) then
                if (prevScreen.x ~= 0 and prevScreen.y ~= 0) then
                    renderer.triangle(screenPos, scrPos, prevScreen, col)
                    if (outline) then renderer.line(screenPos, prevScreen, color(col.r, col.g, col.b, 255)) end
                end

                prevScreen = screenPos
            end
        end
    end
end