oexitdir = string.lower(string.trim(matches[2]))
oexitname = matches[3]

--cecho("\n"..oexitdir..":"..oexitname.."\n")

if oexitname ~= "Too dark to tell" then
  kobviousexits[oexitdir] = oexitname
  kobviousexitscapturemade = true
end
