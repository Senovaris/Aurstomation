local function OnMerchantShow()
	if not AursQoLDB.autoRepair then return end

	local totalSellValue = 0
            for bag = 0, 4 do
                for slot = 1, C_Container.GetContainerNumSlots(bag) do
                    local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                    if itemInfo then
                        local quality = itemInfo.quality
                        if quality == Enum.ItemQuality.Poor then
                            local itemLink = itemInfo.hyperlink
                            local vendorPrice = select(11, GetItemInfo(itemLink)) or 0
                            local count = itemInfo.stackCount or 1
                            local itemValue = vendorPrice * count
                            C_Container.UseContainerItem(bag, slot)
                            totalSellValue = totalSellValue + itemValue
                        end
                    end
                end
            end
            if totalSellValue > 0 then
                print("Auto sold junk for " .. GetCoinTextureString(totalSellValue))
            else
                print("No junk items to sell")
            end
        end

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", OnMerchantShow)
