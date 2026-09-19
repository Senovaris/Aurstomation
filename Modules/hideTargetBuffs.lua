TargetFrame:UnregisterEvent("UNIT_AURA")
FocusFrame:UnregisterEvent("UNIT_AURA")

hooksecurefunc(FocusFrame.TargetFrameContent.TargetFrameContentContextual.Auras, "Show", function(self)
	self:Hide()
end)
hooksecurefunc(TargetFrame.TargetFrameContent.TargetFrameContentContextual.Auras, "Show", function(self)
	self:Hide()
end)

local function SpellBar_SetPoint(self)
	local meta = getmetatable(self).__index
	meta.ClearAllPoints(self)
	meta.SetPoint(self, "TOPLEFT", meta.GetParent(self), "BOTTOMLEFT", 43, -28)
end

hooksecurefunc(TargetFrame.spellbar, "SetPoint", SpellBar_SetPoint)
hooksecurefunc(FocusFrame.spellbar, "SetPoint", SpellBar_SetPoint)
