ktempRoomContentsLine = matches[2]

if ktempRoomContentsLine == "" then
  --Found and empty line, exit room contents capture
  disableTrigger("KRoomContents")
end

if ktempRoomContentsLine ~= "" and not (string.match(ktempRoomContentsLine, "%[Exits: (.*)%]") or (string.match(ktempRoomContentsLine, "has arrived."))) then
  --table.insert(tempRoomContents, tempRoomContentsLine)
  ktempRoomContents[ktempRoomContentsLine] = {}
  ktempRoomContents[ktempRoomContentsLine][1] = os.time()
  ktempRoomContents[ktempRoomContentsLine][2] = 1
end


-- ^(?!.*has arrived.).*$ in regex to not match has arrived string?
