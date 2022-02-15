local ffi = require("ffi");
local drawEnabled = ui.new_checkbox("Lua", "B", "Drawing Enabled");
local drawStartNewKeybind = ui.new_hotkey("Lua", "B", "Start New Line");
local drawAddKeybind = ui.new_hotkey("Lua", "B", "Add Point");
local drawNextName = ui.new_textbox("Lua", "B", "Drawing Name");
local drawCancelKeybind = ui.new_hotkey("Lua", "B", "Cancel Drawing");
local drawingTable = database.read("drawingDatabase");
local drawList;
if (drawingTable ~= nil and #drawingTable > 0) then
    drawList = ui.new_listbox("Lua", "B", "Drawing List", drawingTable);
else
    drawList = ui.new_listbox("Lua", "B", "Drawing List", "");
end

-- credits to sapphyrus for clipboard stuff
local native_GetClipboardTextCount = vtable_bind("vgui2.dll", "VGUI_System010", 7, "int(__thiscall*)(void*)")
local native_SetClipboardText = vtable_bind("vgui2.dll", "VGUI_System010", 9, "void(__thiscall*)(void*, const char*, int)")
local native_GetClipboardText = vtable_bind("vgui2.dll", "VGUI_System010", 11, "int(__thiscall*)(void*, int, const char*, int)")
local new_char_arr = ffi.typeof("char[?]")

local function getClipboard()
	local len = native_GetClipboardTextCount()

	if len > 0 then
		local char_arr = new_char_arr(len)
		native_GetClipboardText(0, char_arr, len)
		return ffi.string(char_arr, len-1)
	end

    return "";
end

local function setClipboard(text)
	text = tostring(text)
	native_SetClipboardText(text, string.len(text))
end

local viewDist = 10000;

local function degToRad(deg)
    return deg * math.pi / 180;
end

local function fromAng(x, y, z)
    return { x = math.cos(degToRad(x)) * math.cos(degToRad(y)), y = math.cos(degToRad(x)) * math.sin(degToRad(y)), z = -1 * math.sin(degToRad(x)) };
end

local saveTable = {};
local saved = false;
local start = false;

client.set_event_callback("paint", function()
    if (ui.get(drawEnabled)) then
        local camP, camY, camR = client.camera_angles();
        local eyeX, eyeY, eyeZ = client.camera_position();
        local cam = fromAng(camP, camY, camR);

        local crosshairLocation = { x = eyeX + cam.x * viewDist, y = eyeY + cam.y * viewDist, z = eyeZ + cam.z * viewDist };
        local percent = client.trace_line(entity.get_local_player(), eyeX, eyeY, eyeZ, crosshairLocation.x, crosshairLocation.y, crosshairLocation.z);
        local crosshairLocation = { x = eyeX + cam.x * (viewDist * percent), y = eyeY + cam.y * (viewDist * percent), z = eyeZ + cam.z * (viewDist * percent) };

        renderer.line(x, y, x2, y2, 255, 255, 255, 255)

        if (ui.get(drawAddKeybind)) then
            if (not saved) then
                table.insert(saveTable, { x = crosshairLocation.x, y = crosshairLocation.y, z = crosshairLocation.z });
                saved = true;
            end
        else
            saved = false;
        end

        if (ui.get(drawStartNewKeybind)) then
            if (not start) then
                table.insert(saveTable, { x = "" });
                start = true;
            end
        else
            start = false;
        end

        if (ui.get(drawCancelKeybind)) then
            saveTable = {};
        end

        if (#saveTable > 0) then
            for i = 1, #saveTable do
                if (i ~= #saveTable) then
                    if (type(saveTable[i + 1].x) ~= "string" and type(saveTable[i].x) ~= "string") then
                        local x, y = renderer.world_to_screen(saveTable[i].x, saveTable[i].y, saveTable[i].z)
                        local x2, y2 = renderer.world_to_screen(saveTable[i + 1].x, saveTable[i + 1].y, saveTable[i + 1].z)
                        renderer.line(x, y, x2, y2, 255, 255, 255, 255)
                    end
                end
            end
        end
    end
end);

local function tableClone(org)
    return { table.unpack(org) };
end

local function addDrawing()
    if (ui.get(drawNextName) ~= "") then
        if (#saveTable > 1) then
            database.write(ui.get(drawNextName), saveTable);
            local val = database.read("drawingDatabase");
            if (val == nil) then val = {}; end
            table.insert(val, ui.get(drawNextName));
            database.write("drawingDatabase", val);

            client.reload_active_scripts();
        end
    end
end

local function deleteDrawing()
    local val = database.read("drawingDatabase");

    if (val ~= nil and ui.get(drawList) ~= nil and #val >= ui.get(drawList) + 1) then
        local selected = drawingTable[ui.get(drawList) + 1];
        for i = 1, #val do
            if (val[i] == selected) then
                table.remove(val, i);
            end
        end

        database.write("drawingDatabase", val);
        database.write(selected, {});

        client.reload_active_scripts();
    end
end

local function saveDrawing()
    local val = database.read("drawingDatabase");

    if (val ~= nil and ui.get(drawList) ~= nil and #val >= ui.get(drawList) + 1) then
        if (#saveTable > 1) then
            database.write(drawingTable[ui.get(drawList) + 1], saveTable);
        end
    end
end

local function loadDrawing()
    local val = database.read("drawingDatabase");
    if (val ~= nil and ui.get(drawList) ~= nil and #val >= ui.get(drawList) + 1) then
        local newTable = database.read(drawingTable[ui.get(drawList) + 1]);
        saveTable = tableClone(newTable);
    end
end

local function importDrawing()
    local clipboardText = getClipboard();
    saveTable = {};

    for line in clipboardText:gmatch("[^\n]+") do -- sisoft
        local pos = {};
        for point in line:gmatch("[^,]+") do
            table.insert(pos, point);
        end

        if (type(pos) == "table") then
            table.insert(saveTable, { x = tonumber(pos[1]), y = tonumber(pos[2]), z = tonumber(pos[3]) });
        end
    end
end

local function exportDrawing()
    if (#saveTable > 1) then
        local saveText = "";

        for i = 1, #saveTable do
            if (saveText == "") then
                saveText = saveTable[i].x .. "," .. saveTable[i].y .. "," .. saveTable[i].z
            else
                saveText = saveText .. "\n" .. saveTable[i].x .. "," .. saveTable[i].y .. "," .. saveTable[i].z
            end
        end

        if (saveText ~= "") then
            setClipboard(saveText);
        end
    end
end

local drawLoad = ui.new_button("Lua", "B", "Load Drawing", loadDrawing);
local drawSave = ui.new_button("Lua", "B", "Save Drawing", saveDrawing);
local drawAdd = ui.new_button("Lua", "B", "Add Drawing", addDrawing);
local drawDelete = ui.new_button("Lua", "B", "Delete Drawing", deleteDrawing);
local drawImport = ui.new_button("Lua", "B", "Import Drawing", importDrawing);
local drawExport = ui.new_button("Lua", "B", "Export Drawing", exportDrawing);