local function OnRoleCheckShow()
	if not AursQoLDB.autoRoleCheck then return end
	CompleteLFGRoleCheck(true)
	print("AutoQueue: Rolecheck Accepted")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("LFG_ROLE_CHECK_SHOW")
frame:SetScript("OnEvent", OnRoleCheckShow)
