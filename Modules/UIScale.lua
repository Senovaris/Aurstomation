local function SetUIScale()
	local width, height = GetPhysicalScreenSize()

	if height <= 1200 then
		UIParent:SetScale(0.71111111111)
	else
		UIParent:SetScale(0.53333333)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", SetUIScale)
