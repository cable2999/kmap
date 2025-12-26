local kmapcmd = matches[2]

local kmaparray = string.split(kmapcmd)

local object = kmaparray[1]

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
    end
    if action == "start" then
        map.start_mapping(args)
    end
    if action == "stop" then
        raiseEvent("mapStop")
        raiseEvent("sysSpeedwalkStopped")
    end
end
