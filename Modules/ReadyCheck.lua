local readyCheckText
local blinkTimer

local frame = CreateFrame("Frame", "ReadyCheckFrame", UIParent)
frame:SetSize(200, 40)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

readyCheckText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
readyCheckText:SetPoint("CENTER", frame, "CENTER", 0, 0)
local font = readyCheckText:GetFont()
readyCheckText:SetFont(font, 40, "OUTLINE THIN")
readyCheckText:SetText("> CHECK TALENTS AND GEAR <")
readyCheckText:SetTextColor(1, 1, 1, 1)
readyCheckText:Hide()

frame:RegisterEvent("READY_CHECK")
frame:SetScript("OnEvent", function(_, event)
	if event == "READY_CHECK" then
		readyCheckText:Show()
		if blinkTimer then
			blinkTimer:Cancel()
		end
		local visible = true
		blinkTimer = C_Timer.NewTicker(0.2, function()
			if visible then
				readyCheckText:SetAlpha(0.7)
			else
				readyCheckText:SetAlpha(1)
			end
			visible = not visible
		end)
		C_Timer.After(8, function()
			if blinkTimer then
				blinkTimer:Cancel()
			end
			readyCheckText:SetAlpha(1)
			readyCheckText:Hide()
		end)
	end
end)
