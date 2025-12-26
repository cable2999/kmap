local areaType = matches[2]
local areaLevels = matches[3]
local areaAuthor = matches[4]
local areaName = matches[5]
-- echo("Captured Area: ")
-- echo(areaName)
-- echo(areaAuthor)
-- echo(areaType)
-- echo(areaLevels)

local newId, err = addAreaName(areaName)

if newId == nil or newId < 1 or err then
  cecho("<red> That area name could not be added - error is: ".. err.."\n")
  cecho(newId)
else
  cecho("<green> Created new area with the ID of "..newId..".\n")
  setAreaUserData(newId, "Author", areaAuthor)
  setAreaUserData(newId, "Type", areaType)
  setAreaUserData(newId, "Levels", areaLevels)
end
