local frame = CreateFrame("Frame", "WarlockandDKPetReminderFrame", UIParent)
local SUMMON_SPELL_IDS = {
	["WARLOCK"] = 688,
	["DEATHKNIGHT"] = 46584,
}
local CLASSES = { ["WARLOCK"] = true, ["DEATHKNIGHT"] = true }
local GRIMOIRE_OF_SACRIFICE = 196099
local UPDATE_DEBOUNCE = 0.15
local _updatePending = false

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER", frame, "CENTER", 0, 0)
text:SetText("NO PET")
text:SetTextColor(1, 0.4, 0, 1)
text:SetFont("Fonts\\FRIZQT__.TTF", 38, "OUTLINE")
frame:SetSize(200, 30)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
frame:Hide()

local function IsPetOnPassive()
	if not UnitExists("pet") or not PetHasActionBar() then
		return false
	end
	for slot = 1, 10 do
		local name, _, isToken, isActive = GetPetActionInfo(slot)
		if isToken and name == "PET_MODE_PASSIVE" and isActive then
			return true
		end
	end
	return false
end

local function GetReminderStatus()
	if IsMounted() then
		return nil
	end

	local _, class = UnitClass("player")
	if not CLASSES[class] then
		return false
	end

	local specIndex = GetSpecialization()
	local specID = specIndex and select(1, GetSpecializationInfo(specIndex))
	if class == "DEATHKNIGHT" and specID ~= 252 then
		return false
	end

	local spellID = SUMMON_SPELL_IDS[class]
	if not C_SpellBook.IsSpellKnown(spellID) then
		return false
	end

	if UnitExists("pet") then
		if IsPetOnPassive() then
			return "PET PASSIVE"
		end
		return nil
	end

	local sacrificeAura = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID(GRIMOIRE_OF_SACRIFICE)
	if sacrificeAura then
		return nil
	end

	return "NO PET"
end

local function UpdateDisplay()
	_updatePending = false
	local statusText = GetReminderStatus()
	if statusText then
		text:SetText(statusText)
		frame:Show()
	else
		frame:Hide()
	end
end

local function QueueUpdate()
	if _updatePending then
		return
	end
	_updatePending = true
	C_Timer.After(UPDATE_DEBOUNCE, UpdateDisplay)
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_PET")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PET_BAR_UPDATE")
frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
frame:SetScript("OnEvent", function(_, event, unit)
	if event == "UNIT_PET" and unit ~= "player" then
		return
	end
	QueueUpdate()
end)
