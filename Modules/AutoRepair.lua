local function OnMerchantShow()
	if not AursQoLDB.autoRepair then
		return
	end
	if CanMerchantRepair() then
		local cost = GetRepairAllCost()
		if cost > 0 then
			local canUseGuild = CanGuildBankRepair()
			if AursQoLDB.useGuilDRepair and canUseGuild then
				RepairAllItems(true)
				print("Auto repaired for " .. GetCoinTextureString(cost) .. " (using guild funds)")
			else
				RepairAllItems()
				print("Auto repaired for " .. GetCoinTextureString(cost))
			end
		else
			print("No Repairs needed")
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", OnMerchantShow)
