descline = matches[2]

if descline == "" then
  -- cecho("\nNewline only here")
  disableTrigger("KDescCap_begin")
  enableTrigger("KDescCapExtra_begin")
else
  kroomDesc = kroomDesc..descline.."\n"
end

enableTrigger("KExits")

kroomDescExtra = {}

--tempRoomContents = [[]]
