potDB = potDB or {}

local potionID = {
  245916, -- Fleeting Mana pot r2
  241301, -- Lightfused Mana pot r1
  241300, -- Lightfused Mana Pot r2
  -- 
}

local rankAtlas = {
  [1] = "Professions-ChatIcon-Quality-12-Tier1",
  [2] = "Professions-ChatIcon-Quality-12-Tier2",
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

local powerPotionID = {
  { id = 245898, role = "HEALER" },
  { id = 241293, role = "DAMAGER" }, -- Draught of Rampant Abandon(Feral)
}

local function powerPotionInBag()
  local currentRole = GetSpecializationRole(GetSpecialization())
  for _, entry in ipairs(powerPotionID) do
    if entry.role == currentRole then
      for bagID = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
          local itemID = C_Container.GetContainerItemID(bagID, slotID)
          if itemID == entry.id then
            return bagID, slotID
          end
        end
      end
    end
  end
  return nil
end

local function GetCraftedRank(bagID, slotID)
  local link = C_Container.GetContainerItemLink(bagID, slotID)
  if not link then return nil end
  local tier = link:match("Professions%-ChatIcon%-Quality%-%d+%-Tier(%d+)")
  return tier and tonumber(tier) or nil
end


local function IsHealer()
  local role = GetSpecializationRole(GetSpecialization())
  return role == "HEALER"
end

local function UpdatePotionFrame()
  if not IsHealer() then
    pot:Hide()
    return
  end
  local bagID, slotID, itemID = potionInBag()
  if bagID and slotID then
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if info and info.iconFileID then
      pot.icon:SetTexture(info.iconFileID)
      local start, duration = C_Container.GetContainerItemCooldown(bagID, slotID)
      if start and duration then
        pot.cooldown:SetCooldown(start, duration)
      end
      if info.stackCount and info.stackCount > 1 then
        pot.count:SetText(info.stackCount)
        pot.count:Show()
      else
        pot.count:Hide()
      end
      local rank = GetCraftedRank(bagID, slotID)
      local atlas = rankAtlas[rank]
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
  if IsHealer() then
    hPot:Hide()
    return
  end
  local bagID, slotID = hPotionInBag()
  if bagID and slotID then
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if info and info.iconFileID then
      hPot.icon:SetTexture(info.iconFileID)
      local start, duration = C_Container.GetContainerItemCooldown(bagID, slotID)
      if start and duration then
        hPot.cooldown:SetCooldown(start, duration)
      end
      if info.stackCount and info.stackCount > 1 then
        hPot.count:SetText(info.stackCount)
        hPot.count:Show()
      else
        hPot.count:Hide()
      end
      local rank = GetCraftedRank(bagID, slotID)
      local atlas = rankAtlas[rank]
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

local function UpdatePowerPotionFrame()
  local bagID, slotID = powerPotionInBag()
  if bagID and slotID then
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if info and info.iconFileID then
      poPot.icon:SetTexture(info.iconFileID)
      local start, duration = C_Container.GetContainerItemCooldown(bagID, slotID)
      if start and duration then
        poPot.cooldown:SetCooldown(start, duration)
      end
      if info.stackCount and info.stackCount > 1 then
        poPot.count:SetText(info.stackCount)
        poPot.count:Show()
      else
        poPot.count:Hide()
      end
      local rank = GetCraftedRank(bagID, slotID)
      local atlas = rankAtlas[rank]
      if atlas then
        poPot.rank:SetAtlas(atlas)
        poPot.rank:Show()
      else
        poPot.rank:Hide()
      end
      poPot:Show()
      return
    end
  end
  poPot:Hide()
end

-- Table instead of else statements --
function UpdateConsumeLayout()
  local visible1 = pot:IsShown()
  local visible2 = hStone:IsShown()
  local visible3 = hPot:IsShown()
  local visible4 = poPot:IsShown()

  local stack = {}
  if visible1 then table.insert(stack, pot) end
  if visible3 then table.insert(stack, hPot) end
  if visible4 then table.insert(stack, poPot) end
  if visible2 then table.insert(stack, hStone) end

  for i, frame in ipairs(stack) do
    frame:ClearAllPoints()
    if i == 1 then
      frame:SetPoint("TOP", potionFrame, "TOP", 0, 0)
    else
      frame:SetPoint("TOP", stack[i - 1], "BOTTOM", 0, 0)
    end
  end
end
-- Pot Frame 
potionFrame = CreateFrame("Frame", "pot", UIParent)
potionFrame:SetSize(40, 100)
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
pot.rank:SetSize(16, 16)
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
hPot.rank:SetSize(16, 16)
hPot.rank:SetPoint("TOPLEFT", hPot, "TOPLEFT", -6, 6)
hPot.rank:Hide()

hStone = CreateFrame("Frame", nil, potionFrame)
hStone:SetSize(40, 40)
hStone:SetPoint("TOP", hPot, "BOTTOM", 0, 0)
hStone.icon = hStone:CreateTexture(nil, "ARTWORK")
hStone.icon:SetAllPoints()
hStone.cooldown = CreateFrame("Cooldown", nil, hStone, "CooldownFrameTemplate")
hStone.cooldown:SetAllPoints()

poPot = CreateFrame("Frame", nil, potionFrame)
poPot:SetSize(40, 40)
poPot:SetPoint("RIGHT", hPot, "LEFT", 0, 0)
poPot.icon = poPot:CreateTexture(nil, "ARTWORK")
poPot.icon:SetAllPoints()
poPot.cooldown = CreateFrame("Cooldown", nil, poPot, "CooldownFrameTemplate")
poPot.cooldown:SetAllPoints()
poPot.count = poPot:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
poPot.count:SetPoint("BOTTOMRIGHT", poPot, "BOTTOMRIGHT", 0, 2)
poPot.count:Hide()
poPot.rank = poPot:CreateTexture(nil, "OVERLAY")
poPot.rank:SetSize(16, 16)
poPot.rank:SetPoint("TOPLEFT", poPot, "TOPLEFT", -6, 6)
poPot.rank:Hide()

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
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
    UpdatePowerPotionFrame(potionFrame)
    UpdateConsumeLayout()

  elseif event == "PLAYER_EQUIPMENT_CHANGED"
    or event == "BAG_UPDATE"
    or event == "BAG_UPDATE_COOLDOWN"
    or event == "PLAYER_REGEN_ENABLED"
    or event == "PLAYER_REGEN_DISABLED"
    or event == "PLAYER_SPECIALIZATION_CHANGED" then
    UpdatePotionFrame(potionFrame)
    UpdateHealthStoneFrame(potionFrame)
    UpdateHealthPotionFrame(potionFrame)
    UpdateConsumeLayout(potionFrame)
    UpdatePowerPotionFrame(potionFrame)
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
    conG:AddButton(poPot, GetMasqueData(poPot))
  end
end)
