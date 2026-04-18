-- Cancels cinematics and movies if possible 
local f = CreateFrame("Frame")
f:RegisterEvent("PLAY_MOVIE")
f:RegisterEvent("CINEMATIC_START")
f:SetScript("OnEvent", function(_, event)
  if event == "PLAY_MOVIE" then
    if MovieFrame and MovieFrame:IsShown() then
      MovieFrame_StopMovie()
    end
  elseif event == "CINEMATIC_START" then
    if CinematicFrame_CancelCinematic then
      CinematicFrame_CancelCinematic()
    end
  end
end)

-- Sets difficulty to Mythic per automation
local autoDifficulty = CreateFrame("Frame")
autoDifficulty:RegisterEvent("PLAYER_LOGIN")
autoDifficulty:RegisterEvent("PLAYER_ENTERING_WORLD")
autoDifficulty:SetScript("OnEvent", function()
  if GetDungeonDifficultyID() ~= 23 then
    SetDungeonDifficultyID(23)
  end
end)

-- A cross on the center ish of the character
local crossFrame = CreateFrame("Frame", "Name", UIParent)
crossFrame:SetSize(40, 40)
crossFrame:Show()

local crossIcon = crossFrame:CreateTexture(nil, "ARTWORK")
crossIcon:SetPoint("CENTER", UIParent, "CENTER", 0, -15)
crossIcon:SetTexture("Interface\\AddOns\\Aurstomation\\Media\\Crosss.tga")
crossIcon:SetSize(45, 45)
crossIcon:SetAlpha(1)

-- Auto Accept Invites from friends and guildies {Taken from Dainton from the WowInterface Forums}
-- Auto Accept Invites from friends, BNet friends, and guildies
-- Updated for WoW Midnight (12.0)

local function StripRealm(name)
  return name and (name:match("^([^%-]+)") or name) or nil
end

local function IsFriend(name)
  local shortName = StripRealm(name)

  -- In-game friends
  for i = 1, C_FriendList.GetNumFriends() do
    local info = C_FriendList.GetFriendInfoByIndex(i)
    if info and StripRealm(info.name) == shortName then
      return true
    end
  end

  -- BattleNet friends (checks their active WoW character name)
  local numBNet = BNGetNumFriends()
  for i = 1, numBNet do
    local numAccounts = C_BattleNet.GetFriendNumGameAccounts(i)
    for j = 1, numAccounts do
      local gameInfo = C_BattleNet.GetFriendGameAccountInfo(i, j)
      if gameInfo and gameInfo.characterName and
        StripRealm(gameInfo.characterName) == shortName then
        return true
      end
    end
  end

  -- Guild members
  if IsInGuild() then
    for i = 1, GetNumGuildMembers() do
      local guildName = GetGuildRosterInfo(i)
      if guildName and StripRealm(guildName) == shortName then
        return true
      end
    end
  end

  return false
end

local f = CreateFrame("Frame")
f:RegisterEvent("PARTY_INVITE_REQUEST")
f:SetScript("OnEvent", function(self, event, name)
  if event == "PARTY_INVITE_REQUEST" then
    if IsFriend(name) then
      AcceptGroup()
      self:RegisterEvent("GROUP_ROSTER_UPDATE")
    end
  elseif event == "GROUP_ROSTER_UPDATE" then
    StaticPopup_Hide("PARTY_INVITE")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
  end
end)

-- Set "Current Expansion" filter automatically.
local expFilter = CreateFrame("Frame")
expFilter:RegisterEvent("AUCTION_HOUSE_SHOW")
expFilter:SetScript("OnEvent", function()
  C_Timer.After(0.1, function()
    local searchBar = AuctionHouseFrame and AuctionHouseFrame.SearchBar 
    if not searchBar or not searchBar:IsShown() then return end
    local filterButton = searchBar.FilterButton 
    if filterButton and filterButton.filters then
      filterButton.filters[Enum.AuctionHouseFilter.CurrentExpansionOnly] = true
    end
  end)
end)
