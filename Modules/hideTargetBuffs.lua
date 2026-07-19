--  Doesn't need to be done, but saves some (not all) processing
TargetFrame:UnregisterEvent("UNIT_AURA")
FocusFrame:UnregisterEvent("UNIT_AURA")

local function ReleaseAllAuras(self)
	for obj in self.auraPools:EnumerateActive() do
		obj:Hide()
	end
	self.auraPools:ReleaseAll() --   Cleanup
end

hooksecurefunc(TargetFrame, "UpdateAuras", ReleaseAllAuras)
hooksecurefunc(FocusFrame, "UpdateAuras", ReleaseAllAuras)

local function SpellBar_SetPoint(self)
	local meta = getmetatable(self).__index --    Calls through self will trigger our hook, so we're making them through the metatable
	meta.ClearAllPoints(self)
	meta.SetPoint(self, "TOPLEFT", meta.GetParent(self), "BOTTOMLEFT", 43, -28)
end

hooksecurefunc(TargetFrame.spellbar, "SetPoint", SpellBar_SetPoint)
hooksecurefunc(FocusFrame.spellbar, "SetPoint", SpellBar_SetPoint)
