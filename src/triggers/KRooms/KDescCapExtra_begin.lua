descextraline = matches[2]

if string.match(descextraline, "%[Exits: (.*)%]") then
  disableTrigger("KDescCapExtra_begin")
end

if descextraline ~= "" and not string.match(descextraline, "%[Exits: (.*)%]") then 
  table.insert(kroomDescExtra, descextraline)
end

