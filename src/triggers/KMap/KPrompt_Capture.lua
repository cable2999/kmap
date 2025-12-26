disableTrigger("KArea Capture Data")
disableTrigger("KRoomContents")
disableTrigger("KLook Here Capture")
disableTrigger("KExit Name")

if klookherecap ~= nil and klookherepcap ~= "" and klookherecap ~= [[]] then
    if not string.match(klookherecap, "You do not see that here.") or klookhereadd then
        if map.mapping and map.currentRoom then
            setRoomUserData(map.currentRoom, "look here "..klookherekeyword , klookherecap)
            map.echo("Creating RoomUserData entry for look here "..klookherekeyword.."\n", true)
        end
    end
    if string.match(klookherecap, "You do not see that here.") then
        if map.mapping and map.currentRoom and klookhereclear then
            if clearRoomUserDataItem(map.currentRoom, "look here "..klookherekeyword) then
                map.echo("Clearing entry for look here "..klookherekeyword.."\n", true)
            end
        end
    end
end

klookherecap = [[]]
klookhereadd = false
klookhereclear = false

if map.mapping and map.currentRoom and kobviousexitscapturemade then
    local kobviousexitscomperr = false
    storedkobstring, errMsg = getRoomUserData(map.currentRoom, "kobviousexits", true)
    -- See if we have already stored the obvious exit data.
    if storedkobstring ~= nil then
        storedkob = yajl.to_value(storedkobstring)
        if table.size(kobviousexits) >= table.size(storedkob) then
            for k, v in pairs(kobviousexits) do
                if not kobviousexits[k] == storedkob[k] and storedkob[k] ~= nil then
                    kobviousexitscomperr = true
                    map.echo("Obvious exit "..k.." does not match stored value.  Wrong room?", true)
                end
            end
        else
            map.echo("Fewer exits visible now than in stored obvious exits.  Open a door or wait for daytime. Doing nothing.", true, true)
            kobviousexitscomperr = true
        end
    end
    if not kobviousexitscomperr then
        setRoomUserData(map.currentRoom, "kobviousexits", yajl.to_string(kobviousexits))
        map.echo("Storing obvious exits for "..tostring(map.currentRoom)..": "..map.currentName, true)
    end
end

kobviousexitscapturemade = false


kprevious_moves = kcurrent_moves
kcurrent_moves = tonumber(matches[6])
kmovediff = kprevious_moves - kcurrent_moves

--This part relies on execution order to be after CFGUI Invisible Prompt Capture.
kinout = indoor

-- Sets the complexTerrain and protected status
kcomplexTerrain = string.lower(civilized)
kcomplexTerrain = string.trim(kcomplexTerrain)

if kcomplexTerrain:sub(1, #"protected ") == "protected " then
  kprot = "true"
  kcomplexTerrain = kcomplexTerrain.gsub(kcomplexTerrain, "protected ", "")
  if string.match(kcomplexTerrain, "graveyard") then
    kgraveyard = true
    --cecho("graveyard")
    kcomplexTerrain = kcomplexTerrain.gsub(kcomplexTerrain, " graveyard", "")
  end
else
  kprot = "false"
end

--Most of these we aren't using, so staying commented out for now.
--kweather = weather
--kmoon = moon_phase
--kcharpos = char_position
--kdrunk = drunk
--There are more here, but we're not using them, so leaving out for now.



--disableTrigger("KPrompt Capture")
if knewroom then
  --raiseEvent("onNewRoom",exitDirections or "")
  raiseEvent("konNewRoom", kroomName, kroomSimpleTerrain, kroomDesc, kroomDescExtra, kexit_directions, ktempRoomContents, kcomplexTerrain, kinout, kprot)
  knewroom = false
end
