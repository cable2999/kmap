if map.mapping and map.currentRoom and opendir ~= nil and opendir ~= "" then
  local dir = map.anytoshort(opendir)
  setDoor(map.currentRoom, dir, 3)
  map.echo("Creating locked door in direction "..dir.."\n", true)
end

opendir = ""