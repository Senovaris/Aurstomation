-- CooldownManagerInit.lua - Initialize the Cooldown Manager system
-- Loads after Core.lua and sets up the system

local ADDON_NAME = "Aurs_Toolkit"

-- Create event frame
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")

local function InitializeCooldownManager()
  -- Initialize saved variables structure
  AursQoLDB = AursQoLDB or {}

  if not AursQoLDB.cooldownManagerEnabled then
    return
  end

  -- Set defaults if not present - ALL ENABLED BY DEFAULT
  if AursQoLDB.cooldownManager_centerBuffIcons == nil then
    AursQoLDB.cooldownManager_centerBuffIcons = true
  end
  if AursQoLDB.cooldownManager_alignBuffBars == nil then
    AursQoLDB.cooldownManager_alignBuffBars = true
  end
  if AursQoLDB.cooldownManager_alignBuffBars_growFromDirection == nil then
    AursQoLDB.cooldownManager_alignBuffBars_growFromDirection = "BOTTOM"
  end
  if AursQoLDB.cooldownManager_alignBuffBarsToBottom == nil then
    AursQoLDB.cooldownManager_alignBuffBarsToBottom = true
  end
  if AursQoLDB.cooldownManager_centerEssential == nil then
    AursQoLDB.cooldownManager_centerEssential = true
  end
  if AursQoLDB.cooldownManager_centerEssential_growFromDirection == nil then
    AursQoLDB.cooldownManager_centerEssential_growFromDirection = "TOP"
  end
  if AursQoLDB.cooldownManager_centerUtility == nil then
    AursQoLDB.cooldownManager_centerUtility = true
  end
  if AursQoLDB.cooldownManager_centerUtility_growFromDirection == nil then
    AursQoLDB.cooldownManager_centerUtility_growFromDirection = "TOP"
  end

  -- Start the cooldown manager silently
  if AursToolkit and AursToolkit.CooldownManager then
    -- Small delay to let cooldown viewers initialize
    C_Timer.After(1, function()
      AursToolkit.CooldownManager.Initialize()
    end)
  end
end

initFrame:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_LOGIN" then
    InitializeCooldownManager()
    self:UnregisterEvent("PLAYER_LOGIN")
  end
end)
