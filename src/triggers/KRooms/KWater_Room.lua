kroomName = multimatches[1][1]
--Set the Room Name

kroomSimpleTerrain = "water"

-- Initialize variables for next step
knewroom = true
-- Something to check in Prompt Capture so we don't have to enable/disable?
kroomDesc = [[]]
kobviousexits = {}

enableTrigger("KDescCap_begin")
enableTrigger("KPrompt Capture")
