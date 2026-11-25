BagsBar:Hide()
hooksecurefunc(BagsBar, "Show", function(self)
	self:Hide()
end)
hooksecurefunc(BagsBar, "SetShown", function(self, shown)
	if shown then
		self:Hide()
	end
end)
