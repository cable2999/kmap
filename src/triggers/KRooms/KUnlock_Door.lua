if map.mapping and map.currentRoom then
  setRoomUserData(map.currentRoom, matches[2], matches[3])
  map.echo("Creating RoomUserData entry for "..matches[2].." with key "..matches[3].."\n", true)
end