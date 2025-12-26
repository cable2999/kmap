direction = matches[2]
if matches[3] then exitdesc[direction] = matches[3] end
selectString(matches[2], 1)
fg("white")
setBold(true)

exitdesc_match = exitdesc[direction]

if direction_highlights[exitdesc_match] then
  selectString(exitdesc_match, 1)
  fg(direction_highlights[exitdesc_match])
  setBold(true)
  resetFormat()
end

if map.mapping and map.currentRoom then
  if exitdesc[direction] ~= "Nothing special there." then
    --map.echo("Adding lookdesc"..direction.." to roomUserData "..tostring(map.currentRoom), true)
    storedlookdesc, errMsg = getRoomUserData(map.currentRoom, "lookdesc"..direction, true)
    -- See if we already have a stored description for this direction and if it matches.
    if storedlookdesc ~= nil then
        if storedlookdesc ~= exitdesc[direction] then
            map.echo("Stored lookdesc"..direction.." in "..tostring(map.currentRoom).." not match.  In wrong room?", true)
        end
    else
        setRoomUserData(map.currentRoom, "lookdesc"..direction, exitdesc[direction])
    end
  end
end