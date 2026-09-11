-- Fill this in yourself: [npcID] = "Spec Name"
-- Get NPC IDs from Wowhead's encounter journal pages, e.g.
--   https://www.wowhead.com/npc=258557 -> the "npc=" number is the ID.
-- Make sure it's the boss's own unit, not an add/mechanic NPC summoned during the fight.
local BossSpecs = {
	[243167] = "Affliction", -- Example Boss Name
	[243168] = "Demonology", -- Example Boss Name
}

local ALERT_COOLDOWN = 15 -- seconds, per npcID, so re-targeting doesn't spam you
local lastAlertTime = {}

local function GetNPCIDFromGUID(guid)
	if not guid then
		return nil
	end
	local unitType, _, _, _, _, npcID = strsplit("-", guid)
	if unitType == "Creature" or unitType == "Vehicle" then
		return tonumber(npcID)
	end
	return nil
end

local function CheckTarget()
	if not UnitExists("target") then
		return
	end

	local npcID = GetNPCIDFromGUID(UnitGUID("target"))
	if not npcID then
		return
	end

	local requiredSpec = BossSpecs[npcID]
	if not requiredSpec then
		return
	end

	local specIndex = GetSpecialization()
	local currentSpec = specIndex and select(2, GetSpecializationInfo(specIndex))

	if currentSpec and currentSpec:lower() == requiredSpec:lower() then
		return -- already the right spec, stay quiet
	end

	local now = GetTime()
	if lastAlertTime[npcID] and (now - lastAlertTime[npcID]) < ALERT_COOLDOWN then
		return
	end
	lastAlertTime[npcID] = now

	local message = "Change to " .. requiredSpec:upper() .. "!"
	print("|cffff6600SpecSwapReminder:|r " .. message)
	PlaySound(SOUNDKIT.RAID_WARNING, "Master")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_TARGET_CHANGED" then
		CheckTarget()
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		table.wipe(lastAlertTime) -- swapped specs, so allow an immediate re-check
	end
end)
