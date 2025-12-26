local kmapcmd = matches[2]

local kmaparray = string.split(kmapcmd)

local object = kmaparray[1]

-- object is map for these essentially, so these are more like actions
if object == "start" then
    map.start_mapping(args)
elseif object == "stop" then
    raiseEvent("mapStop")
    raiseEvent("sysSpeedwalkStopped")
elseif object == "help" then
    local args = table.concat(kmaparray, " ", 2, table.size(kmaparray))
    map.show_help(args)
elseif object == "save" then
    if saveMap(getMudletHomeDir() .. "/kmapdata/map.dat") and saveJsonMap(getMudletHomeDir() .. "/kmapdata/kmap.json") then
        map.log("Map saved.\n", "INFO")
    else
        map.log("Error.  Map NOT saved.\n", "ERROR")
    end
end

if object == "area" then
    local action = kmaparray[2]
    local args = table.concat(kmaparray, " ", 3, table.size(kmaparray))
    if action == "get" then
        enableTrigger("KArea Capture Data")
        send("area "..args)
    elseif action == "del" then
        map.deleteArea(args, true)
    elseif action == "list" then
        map.echoAreaList()
    elseif action == "create" then
        -- area add <area name> - will create a new area and automatically give it an ID.

        local t = getAreaTable(); local tr = {}; for k,v in pairs(t) do tr[v] = k end
        local newid = table.maxn(tr) + 1

        setAreaName( newid, args )
        map.log(string.format("Created new area %s (%d), but shouldn't you use the area command?", args, newid), "INFO")
        centerview(map.currentRoom)
    end
    map.log("Unkown "..object.." command.", "ERROR")
end

if object == "loglevel" then
    local action = kmaparray[2]
    local args = table.concat(kmaparray, " ", 3, table.size(kmaparray))
    if action == "show" then
        map.log("Log level is: "..LOG_LEVELNAMES[map.configs.loglevel], "INFO")
    elseif action == "set" then
        if table.contains(LOG_LEVELNAMES, string.upper(args)) then
            map.setConfigs("loglevel", LOG_LEVELS[string.upper(args)])
        else
            map.log("Log level must be one of "..table.concat(LOG_LEVELNAMES, " "), "ERROR")
        end
    end
    map.log("Unkown "..object.." command.", "ERROR")
end

if object == "room" then
    local action = kmaparray[2]
    local args = table.concat(kmaparray, " ", 3, table.size(kmaparray))
    if action == "show" then
        if args == "" then args = nil end
        map.echoRoomList(args or getRoomArea(map.currentRoom))
    elseif action == "find" then
        map.roomFind(args)
    elseif action == "look" then
        map.roomLook(args)
    elseif action == "merge" then
        map.merge_rooms()
    elseif action == "mergedn" then
        map.merge_daynight_rooms()
    elseif action == "area" then
        map.set_area(args)
    end
    map.log("Unkown "..object.." command.", "ERROR")
end

if object == "move" then
    local action = kmaparray[2]
    local args = table.concat(kmaparray, " ", 3, table.size(kmaparray))
    if action == "show" then
        map.show_moves()
    elseif action == "clear" then
        map.clear_moves()
    end
    map.log("Unkown "..object.." command.", "ERROR")
end