local panel = CreateFrame("Frame", "AursQoLPanel", UIParent, BackdropTemplateMixin and "BackdropTemplate")
panel:SetSize(300, 250)
panel:SetPoint("CENTER")
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetClampedToScreen(true)
panel:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
panel:SetBackdropColor(0, 0, 0, 0.9)
panel:Hide()

panel:SetScript("OnShow", function()
  repairCheck:SetChecked(AursQoL.autoRepair)
  guildRepairCheck:SetChecked(AursQoLDB.useGuildRepair)
  sellCheck:SetChecked(AursQoLDB.autoSellJunk)
  roleCheck:SetChecked(AursQoLDB.autoRoleCheck)
  cooldownManagerCheck:SetChecked(AursQoLDB.cooldownManagerEnabled)
end)

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("Options")

local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function()
  panel:Hide()
end)

local repairCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
repairCheck:SetPoint("TOPLEFT", 20, -50)
repairCheck.text = repairCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
repairCheck.text:SetPoint("LEFT", repairCheck, "RIGHT", 5, 0)
repairCheck.text:SetText("Auto Repair")
repairCheck:SetChecked(AursQoLDB.autoRepair)
repairCheck:SetScript("OnClick", function(self)
  AursQoLDB.autoRepair = self:GetChecked()
end)

local guildRepairCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
guildRepairCheck:SetPoint("TOPLEFT", 20, -80)
guildRepairCheck.text = guildRepairCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
guildRepairCheck.text:SetPoint("LEFT", guildRepairCheck, "RIGHT", 5, 0)
guildRepairCheck.text:SetText("Use Guild Repairs")
guildRepairCheck:SetChecked(AursQoLDB.useGuildRepair)
guildRepairCheck:SetScript("OnClick", function(self)
  AursQoLDB.useGuildRepair = self:GetChecked()
end)

local sellCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
sellCheck:SetPoint("TOPLEFT", 20, -110)
sellCheck.text = sellCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sellCheck.text:SetPoint("LEFT", sellCheck, "RIGHT", 5, 0)
sellCheck.text:SetText("Auto Sell Junk")
sellCheck:SetChecked(AursQoLDB.autoSellJunk)
sellCheck:SetScript("OnClick", function(self)
  AursQoLDB.autoSellJunk = self:GetChecked()
end)
local roleCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
roleCheck:SetPoint("TOPLEFT", 20, -140)
roleCheck.text = roleCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
roleCheck.text:SetPoint("LEFT", roleCheck, "RIGHT", 5, 0)
roleCheck.text:SetText("Auto Role Check")
roleCheck:SetChecked(AursQoLDB.autoRoleCheck)
roleCheck:SetScript("OnClick", function(self)
  AursQoLDB.autoRoleCheck = self:GetChecked()
end)

-- local cooldownManager = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
-- cooldownManager:SetPoint("TOPLEFT", 20, -170)
-- cooldownManager.text = cooldownManager:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- cooldownManager.text:SetPoint("LEFT", cooldownManager, "RIGHT", 5, 0)
-- cooldownManager.text:SetText("Center Cooldown Manager Icons")
-- cooldownManager:SetChecked(AursQoLDB.cooldownManagerEnabled)
-- cooldownManager:SetScript("OnClick", function(self)
  --   AursQoLDB.cooldownManagerEnabled = self:GetChecked()
  -- 
  --   StaticPopupDialogs["AURSTOMATION_RELOAD"] = {
    --     text = "Cooldown Manager options changed. Reload UI now?",
    --     button1 = "Reload",
    --     button2 = "Reload later",
    --     OnAccept = function()
      --       ReloadUI()
      --     end,
      --     timeout = 0,
      --     whileDead = true,
      --     hideOnEscape = false, 
      --     preferredIndex = 3,
      --   }
      --   StaticPopup_Show("AURSTOMATION_RELOAD")
      -- end)

      panel:SetScript("OnDragStart", panel.StartMoving)
      panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

      SLASH_AURSQOL1 = "/aurs"
      SlashCmdList["AURSQOL"] = function()
        panel:SetShown(not panel:IsShown())
      end

      panel:SetScript("OnShow", function()
        repairCheck:SetChecked(AursQoLDB.autoRepair)
        guildRepairCheck:SetChecked(AursQoLDB.useGuildRepair)
        sellCheck:SetChecked(AursQoLDB.autoSellJunk)
        roleCheck:SetChecked(AursQoLDB.autoRoleCheck)
        cooldownManagerCheck:SetChecked(AursQoLDB.cooldownManagerEnabled)
      end)
