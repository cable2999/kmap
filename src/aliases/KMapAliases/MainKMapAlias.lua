local kmapcmd = matches[2]

local kmaparray = string.split(kmaparray)

local object = kmaparray[1]

if object == "area" then
    local action = kmaparray[2]
    if action == "getall" then
        enableTrigger("KArea Capture Data")
        send("area all")
    end
end
