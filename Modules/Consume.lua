potDB = potDB or {}

local potionID = {
  245916, -- Fleeting Mana pot r2
  241301, -- Lightfused Mana pot r1
  241300, -- Lightfused Mana Pot r2
}

local rankAtlas = {
  [2] = "Professions-ChatIcon-Quality-12-Tier1",
  [1] = "Professions-ChatIcon-Quality-12-Tier2",
}

local function potionInBag()
  for _, potID in ipairs(potionID) do
    for bagID = 0, 4 do
      local numSlots = C_Container.GetContainerNumSlots(bagID)
      for slotID = 1, numSlots do
        local itemID = C_Container.GetContainerItemID(bagID, slotID)
        if itemID == potID then
          return bagID, slotID, potID
        end
      end
    end
  end
  return nil
end

local hPotionID = {
  241305, -- Health pot r1
  241304, -- Health pot r2
}

local function hPotionInBag()
  for bagID = 0, 4 do
    local numSlots = C_Container.GetContainerNumSlots(bagID)
    for slotID = 1, numSlots do
      local itemID = C_Container.GetContainerItemID(bagID, slotID)
      if itemID then
        for _, potID in ipairs(hPotionID) do
          if itemID == potID then
            return bagID, slotID
          end
        end
      end
    end
  end
  return nil
end

local healthStoneIDs = {
  5509,   -- Healthstone
  5512,   -- Minor Healthstone
  224464, -- Demonic Healthstone
}

local function hasHealthStone()
  for bagID = 0, 4 do
    local numSlots = C_Container.GetContainerNumSlots(bagID)
    for slotID = 1, numSlots do
      local itemID = C_Container.GetContainerItemID(bagID, slotID)
      if itemID then
        for _, hsID in ipairs(healthStoneIDs) do
          if itemID == hsID then
            return bagID, slotID
          end
        end
      end
    end
  end
  return nil
end

local function UpdatePotionFrame()
  local bagID, slotID, itemID = potionInBag()
  if bagID and slotID then
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if info and info.iconFileID then
      pot.icon:SetTexture(info.iconFileID)
      local start, duration = C_Container.GetContainerItemCooldown(bagID, slotID)
      if start and duration then
        pot.cooldown:SetCooldown(start, duration)
      end
      pot:Show()
      -- Stack count
      if info.stackCount and info.stackCount > 1 then
        pot.count:SetText(info.stackCount)
        pot.count:Show()
      else
        pot.count:Hide()
      end
      local atlas = rankAtlas[info.quality]
      if atlas then
        pot.rank:SetAtlas(atlas)
        pot.rank:Show()
      else
        pot.rank:Hide()
      end
      pot:Show()
      return
    end
  end
  pot:Hide()
end

local function UpdateHealthPotionFrame()
  local bagID, slotID = hPotionInBag()
  if bagID and slotID then
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if info and info.iconFileID then
      hPot.icon:SetTexture(info.iconFileID)
      local start, duration = C_Container.GetContainerItemCooldown(bagID, slotID)
      if start and duration then
        hPot.cooldown:SetCooldown(start, duration)
      end
      hPot:Show()
      -- Stack count
      if info.stackCount and info.stackCount > 1 then
        hPot.count:SetText(info.stackCount)
        hPot.count:Show()
      else
        hPot.count:Hide()
      end
      local atlas = rankAtlas[info.quality]
      if atlas then
        hPot.rank:SetAtlas(atlas)
        hPot.rank:Show()
      else
        hPot.rank:Hide()
      end
      hPot:Show()
      return
    end
  end
  hPot:Hide()
end


local function UpdateHealthStoneFrame()
  local bagID, slotID = hasHealthStone()
  if bagID and slotID then
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if info and info.iconFileID then
      hStone.icon:SetTexture(info.iconFileID)
      local start, duration = C_Container.GetContainerItemCooldown(bagID, slotID)
      if start and duration then
        hStone.cooldown:SetCooldown(start, duration)
      end
      hStone:Show()
      return
    end
  end
  hStone:Hide()
end

function UpdateConsumeLayout()
  local visible1 = pot:IsShown()
  local visible2 = hStone:IsShown()
  local visible3 = hPot:IsShown()

  if visible1 and not visible2 then
    pot:ClearAllPoints()
    pot:SetPoint("TOP", potionFrame, "TOP", 0, 0)
  elseif visible2 and not visible1 then
    hStone:ClearAllPoints()
    hStone:SetPoint("TOP", potionFrame, "TOP", 0, 0)
  elseif visible3 and not visible1 and not visible2 then
    hPot:ClearAllPoints()
    hPot:SetPoint("TOP", potionFrame, "TOP", 0, 0)
  elseif visible1 and visible2 and not visible3 then
    pot:ClearAllPoints()
    pot:SetPoint("TOP", potionFrame, "TOP", 0, 0)
    hStone:ClearAllPoints()
    hStone:SetPoint("TOP", pot, "BOTTOM", 0, 0)
  elseif visible2 and visible3 and not visible1 then
    hPot:ClearAllPoints()
    hPot:SetPoint("TOP", potionFrame, "TOP", 0, 0)
    hStone:ClearAllPoints()
    hStone:SetPoint("TOP", hPot, "BOTTOM", 0, 0)
  elseif visible1 and visible3 and not visible2 then
    pot:ClearAllPoints()
    pot:SetPoint("TOP", potionFrame, "TOP", 0, 0)
    hPot:ClearAllPoints()
    hPot:SetPoint("TOP", pot, "BOTTOM", 0, 0)
  elseif visible1 and visible2 and visible3 then
    pot:SetPoint("TOP", potionFrame, "TOP", 0, 0)
    hPot:SetPoint("TOP", pot, "BOTTOM", 0, 0)
    hStone:SetPoint("TOP", hPot, "BOTTOM", 0, 0)
  end
end

-- Pot Frame 
potionFrame = CreateFrame("Frame", "pot", UIParent)
potionFrame:SetSize(40, 130)
potionFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
potionFrame:SetClampedToScreen(true)
potionFrame:Show()

pot = CreateFrame("Frame", nil, potionFrame)
pot:SetSize(40, 40)
pot:SetPoint("TOP", potionFrame, "TOP", 0, 0)
pot.icon = pot:CreateTexture(nil, "ARTWORK")
pot.icon:SetAllPoints()
pot.cooldown = CreateFrame("Cooldown", nil, pot, "CooldownFrameTemplate")
pot.cooldown:SetAllPoints()
pot.count = pot:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
pot.count:SetPoint("BOTTOMRIGHT", pot, "BOTTOMRIGHT", 0, 2)
pot.count:Hide()
pot.rank = pot:CreateTexture(nil, "OVERLAY")
pot.rank:SetSize(22, 22)
pot.rank:SetPoint("TOPLEFT", pot, "TOPLEFT", -6, 6)
pot.rank:Hide()

hPot = CreateFrame("Frame", nil, potionFrame)
hPot:SetSize(40, 40)
hPot:SetPoint("TOP", pot, "BOTTOM", 0, 0)
hPot.icon = hPot:CreateTexture(nil, "ARTWORK")
hPot.icon:SetAllPoints()
hPot.cooldown = CreateFrame("Cooldown", nil, hPot, "CooldownFrameTemplate")
hPot.cooldown:SetAllPoints()
hPot.count = hPot:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
hPot.count:SetPoint("BOTTOMRIGHT", hPot, "BOTTOMRIGHT", 0, 2)
hPot.count:Hide()
hPot.rank = hPot:CreateTexture(nil, "OVERLAY")
hPot.rank:SetSize(22, 22)
hPot.rank:SetPoint("TOPLEFT", hPot, "TOPLEFT", -6, 6)
hPot.rank:Hide()


hStone = CreateFrame("Frame", nil, potionFrame)
hStone:SetSize(40, 40)
hStone:SetPoint("TOP", hPot, "BOTTOM", 0, 0)
hStone.icon = hStone:CreateTexture(nil, "ARTWORK")
hStone.icon:SetAllPoints()
hStone.cooldown = CreateFrame("Cooldown", nil, hStone, "CooldownFrameTemplate")
hStone.cooldown:SetAllPoints()

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    local LEM = LibStub('LibEditMode')

    if LEM then
      local function onPositionChanged(frame, layoutName, point, x, y)
        if not potDB.layouts then
          potDB.layouts = {}
        end
        if not potDB.layouts[layoutName] then
          potDB.layouts[layoutName] = {}
        end
        potDB.layouts[layoutName].point = point
        potDB.layouts[layoutName].x = x
        potDB.layouts[layoutName].y = y
      end

      local defaultPosition = {
        point = "CENTER",
        x = 0,
        y = 0,
      }

      LEM:RegisterCallback('layout', function(layoutName)
        if not potDB.layouts then
          potDB.layouts = {}
        end
        if not potDB.layouts[layoutName] then
          potDB.layouts[layoutName] = {point = "CENTER", x = 0, y = 0}
        end

        potionFrame:ClearAllPoints()
        potionFrame:SetPoint(potDB.layouts[layoutName].point or "CENTER",
        UIParent,
        potDB.layouts[layoutName].point or "CENTER",
        potDB.layouts[layoutName].x or 0,
        potDB.layouts[layoutName].y or 0)
      end)
      LEM:AddFrame(potionFrame, onPositionChanged, defaultPosition)
    end
    UpdatePotionFrame(potionFrame)
    UpdateHealthPotionFrame(potionFrame)
    UpdateHealthStoneFrame(potionFrame)
    UpdateConsumeLayout()

  elseif event == "PLAYER_EQUIPMENT_CHANGED"
    or event == "BAG_UPDATE"
    or event == "BAG_UPDATE_COOLDOWN"
    or event == "PLAYER_REGEN_ENABLED"
    or event == "PLAYER_REGEN_DISABLED" then
    UpdatePotionFrame(potionFrame)
    UpdateHealthStoneFrame(potionFrame)
    UpdateHealthPotionFrame(potionFrame)
    UpdateConsumeLayout(potionFrame)
  end

  -- Added Masque Support --

  local function GetMasqueData(button)
    return {
      Icon = button.icon,
      Cooldown = button.cooldown,
      Border = button.border,
      Count = button.count,
    }
  end

  local Masque = LibStub("Masque", true)
  if Masque then
    local conG = Masque:Group("Aurstomation")
    conG:AddButton(pot, GetMasqueData(pot))
    conG:AddButton(hPot, GetMasqueData(hPot))
    conG:AddButton(hStone, GetMasqueData(hStone))
  end
end)
