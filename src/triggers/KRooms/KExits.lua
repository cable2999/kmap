kexitDirections = matches[2]
-- raiseEvent("onNewRoom",matches[2] or "")

kexit_directions = {north = {"closed", false}, south = {"closed", false}, east = {"closed", false}, west = {"closed", false}, down = { "closed", false}, up = {"closed", false}, none = {"closed", false}}

for exit in (kexitDirections):gmatch("%s*([%S]*)%s*") do
  if exit ~= nil and exit ~= "" then
    local direction_key = exit
    if string.match(exit, "%[") and string.match(exit, "%]") then
      direction_key = string.match(exit, "%[(%a+)]")
      kexit_directions[direction_key][1] = "closed"
      kexit_directions[direction_key][2] = true
    elseif string.match(exit, "{") and string.match(exit, "}") then
      direction_key = string.match(exit, "{(%a+)}")
      kexit_directions[direction_key][1] = "hidden"
      kexit_directions[direction_key][2] = true
    else
      kexit_directions[direction_key][1] = "open"
      kexit_directions[direction_key][2] = true
    end
  end
end

updateCompass()
-- raiseEvent("onNewRoom",matches[2] or "")
disableTrigger("KDescCap_begin")
disableTrigger("KExits")

ktempRoomContents = {}

enableTrigger("KRoomContents")
