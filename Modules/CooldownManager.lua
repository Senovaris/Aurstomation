local ADDON_NAME = "Aurs_Toolkit"
AursToolkit = AursToolkit or {}
AursToolkit.CooldownManager = AursToolkit.CooldownManager or {}

local CooldownManager = AursToolkit.CooldownManager
local floor = math.floor
local abs = math.abs

-- Stop updates during Edit Mode
local STOP_CMC = false
if EventRegistry then
	EventRegistry:RegisterCallback("EditMode.Enter", function()
		STOP_CMC = true
	end)
	EventRegistry:RegisterCallback("EditMode.Exit", function()
		STOP_CMC = false
	end)
end

-- Utility function for pixel-perfect positioning
local function roundPixel(value)
	if not value then
		return 0
	end
	return floor(value + 0.5)
end

-- Force repaint flags
local forcedBuffsIconRepaint = 1
local forcedBuffsBarsRepaint = 1

local function ForceBuffIconRepaint()
	forcedBuffsIconRepaint = 2
end

local function ForceBuffBarsRepaint()
	forcedBuffsBarsRepaint = 2
end

-- Get visible buff icon frames
local function GetBuffIconFrames()
	if not BuffIconCooldownViewer then
		return {}
	end

	local visible = {}

	for _, child in ipairs({ BuffIconCooldownViewer:GetChildren() }) do
		if child then
			local hasIcon = child.icon or child.Icon
			local hasCooldown = child.cooldown or child.Cooldown

			if hasIcon or hasCooldown then
				if child:IsShown() then
					table.insert(visible, child)
				end
				if not child._atk_isHooked then
					child._atk_isHooked = true
					-- Hook to detect when icons change
					if child.OnActiveStateChanged then
						hooksecurefunc(child, "OnActiveStateChanged", ForceBuffIconRepaint)
					end
					if child.OnUnitAuraAddedEvent then
						hooksecurefunc(child, "OnUnitAuraAddedEvent", ForceBuffIconRepaint)
					end
					if child.OnUnitAuraRemovedEvent then
						hooksecurefunc(child, "OnUnitAuraRemovedEvent", ForceBuffIconRepaint)
					end
				end
			end
		end
	end

	table.sort(visible, function(a, b)
		return (a.layoutIndex or 0) < (b.layoutIndex or 0)
	end)

	return visible
end

-- Get visible buff bar frames
local function GetBuffBarFrames()
	if not BuffBarCooldownViewer then
		return {}
	end

	local frames = {}

	-- Try CooldownViewer API if present
	if BuffBarCooldownViewer.GetItemFrames then
		local ok, items = pcall(BuffBarCooldownViewer.GetItemFrames, BuffBarCooldownViewer)
		if ok and items then
			frames = items
		end
	end

	-- Fallback to raw children scan
	if #frames == 0 then
		local okc, children = pcall(BuffBarCooldownViewer.GetChildren, BuffBarCooldownViewer)
		if okc and children then
			for _, child in ipairs({ children }) do
				if child and child:IsObjectType("Frame") then
					table.insert(frames, child)
				end
			end
		end
	end

	local active = {}
	for _, frame in ipairs(frames) do
		if frame:IsShown() and frame:IsVisible() then
			table.insert(active, frame)
		end
		if not frame._atk_isHooked and (frame.icon or frame.Icon or frame.bar or frame.Bar) then
			frame._atk_isHooked = true
			if frame.OnActiveStateChanged then
				hooksecurefunc(frame, "OnActiveStateChanged", ForceBuffBarsRepaint)
			end
			if frame.OnUnitAuraAddedEvent then
				hooksecurefunc(frame, "OnUnitAuraAddedEvent", ForceBuffBarsRepaint)
			end
			if frame.OnUnitAuraRemovedEvent then
				hooksecurefunc(frame, "OnUnitAuraRemovedEvent", ForceBuffBarsRepaint)
			end
		end
	end

	table.sort(active, function(a, b)
		return (a.layoutIndex or 0) < (b.layoutIndex or 0)
	end)

	return active
end

-- State tracking for buff icons
local iconState = {
	lastCount = 0,
	lastFirstIconCenterX = -9999,
}

-- Update buff icon positions (center them horizontally)
function CooldownManager.UpdateIconsIfNeeded()
	if not BuffIconCooldownViewer or STOP_CMC then
		return
	end

	-- Check if feature is enabled
	local DB = AursQoLDB or {}
	if not DB.cooldownManager_centerBuffIcons then
		return
	end

	if forcedBuffsIconRepaint == 0 then
		return
	end

	local icons = GetBuffIconFrames()
	local count = #icons
	if count == 0 then
		return
	end

	local refIcon = icons[1]
	if not refIcon then
		return
	end

	local iconWidth = refIcon:GetWidth()
	local iconHeight = refIcon:GetHeight()
	local spacing = BuffIconCooldownViewer.childXPadding or 4

	local changed = false or (forcedBuffsIconRepaint > 0)
	if forcedBuffsIconRepaint > 0 then
		forcedBuffsIconRepaint = forcedBuffsIconRepaint - 1
	end

	if not changed then
		return
	end

	-- Calculate total width and center position
	local totalWidth = (count * iconWidth) + ((count - 1) * spacing)
	totalWidth = roundPixel(totalWidth)

	local startX = -totalWidth / 2 + iconWidth / 2
	startX = roundPixel(startX)

	-- Position each icon
	for i, icon in ipairs(icons) do
		local x = startX + (i - 1) * (iconWidth + spacing)
		x = roundPixel(x)
		icon:ClearAllPoints()
		icon:SetPoint("TOP", BuffIconCooldownViewer, "TOP", x, 0)
	end
end

-- State tracking for buff bars
local barState = {
	lastCount = 0,
	lastBarY = -9999,
}

-- Update buff bar positions (align them vertically)
function CooldownManager.UpdateBarsIfNeeded()
	if not BuffBarCooldownViewer or STOP_CMC then
		return
	end

	-- Check if feature is enabled
	local DB = AursQoLDB or {}
	if not DB.cooldownManager_alignBuffBars then
		return
	end

	local bars = GetBuffBarFrames()
	local count = #bars
	if count == 0 then
		return
	end

	local refBar = bars[1]
	if not refBar then
		return
	end

	local barWidth = refBar:GetWidth()
	local barHeight = refBar:GetHeight()
	local spacing = BuffBarCooldownViewer.childYPadding or 2

	if not barHeight or barHeight == 0 then
		return
	end

	local changed = false or (forcedBuffsBarsRepaint > 0)
	if forcedBuffsBarsRepaint > 0 then
		forcedBuffsBarsRepaint = forcedBuffsBarsRepaint - 1
	end

	if not changed and count ~= barState.lastCount then
		barState.lastCount = count
		changed = true
	end

	if not changed then
		return
	end

	-- Get grow direction
	local growFromDirection = DB.cooldownManager_alignBuffBars_growFromDirection or "BOTTOM"
	local alignToBottom = DB.cooldownManager_alignBuffBarsToBottom ~= false

	-- Calculate positions
	if alignToBottom then
		-- Align all bars to bottom, growing upward
		for i, bar in ipairs(bars) do
			local yOffset = (i - 1) * (barHeight + spacing)
			bar:ClearAllPoints()
			bar:SetPoint("BOTTOM", BuffBarCooldownViewer, "BOTTOM", 0, yOffset)
		end
	else
		-- Align based on grow direction
		if growFromDirection == "BOTTOM" then
			for i, bar in ipairs(bars) do
				local yOffset = -(i - 1) * (barHeight + spacing)
				bar:ClearAllPoints()
				bar:SetPoint("TOP", BuffBarCooldownViewer, "TOP", 0, yOffset)
			end
		else
			for i, bar in ipairs(bars) do
				local yOffset = (i - 1) * (barHeight + spacing)
				bar:ClearAllPoints()
				bar:SetPoint("BOTTOM", BuffBarCooldownViewer, "BOTTOM", 0, yOffset)
			end
		end
	end
end

-- Get all rows from a cooldown viewer (for multi-row layouts)
local function GetAllRows(viewer)
	if not viewer then
		return {}
	end

	local iconLimit = viewer.iconLimit or 0
	if iconLimit <= 0 then
		return {}
	end

	local all = {}
	for _, child in ipairs({ viewer:GetChildren() }) do
		if child and child:IsShown() then
			local hasIcon = child.icon or child.Icon
			local hasCooldown = child.cooldown or child.Cooldown
			if hasIcon or hasCooldown then
				table.insert(all, child)
			end
		end
	end

	if #all == 0 then
		return {}
	end

	table.sort(all, function(a, b)
		return (a.layoutIndex or 0) < (b.layoutIndex or 0)
	end)

	local rows = {}
	for i = 1, #all do
		local rowIndex = floor((i - 1) / iconLimit) + 1
		if not rows[rowIndex] then
			rows[rowIndex] = {}
		end
		table.insert(rows[rowIndex], all[i])
	end

	return rows
end

-- State tracking for Essential/Utility viewers
local viewerState = {
	["EssentialCooldownViewer"] = {
		lastFirstIconCenterX = -9999,
		lastLastIconCenterX = -9999,
		lastRowCount = 0,
		lastTotalIcons = 0,
		lastLayoutHash = 0,
		lastFirstIcon = nil,
		lastLastIcon = nil,
		lastNumChildren = 0,
	},
	["UtilityCooldownViewer"] = {
		lastFirstIconCenterX = -9999,
		lastLastIconCenterX = -9999,
		lastRowCount = 0,
		lastTotalIcons = 0,
		lastLayoutHash = 0,
		lastFirstIcon = nil,
		lastLastIcon = nil,
		lastNumChildren = 0,
	},
}

-- Center all rows in a cooldown viewer
local function CenterAllRows(viewer, fromDirection)
	if not viewer then
		return
	end

	local viewerName = viewer:GetName()
	local state = viewerState[viewerName]
	if not state then
		return
	end

	local isHorizontal = viewer.isHorizontal ~= false
	local iconDirection = viewer.iconDirection == 1 and "NORMAL" or "REVERSED"
	local iconLimit = viewer.iconLimit or 0

	if iconLimit <= 0 then
		return
	end

	-- Check if number of children changed
	local numChildren = viewer:GetNumChildren() or 0
	if numChildren <= iconLimit then
		return
	end

	local changed = false

	if numChildren ~= (state.lastNumChildren or 0) then
		state.lastNumChildren = numChildren
		changed = true
	end

	-- Check if cached anchor icons moved
	if not changed and state.lastFirstIcon and state.lastLastIcon then
		local firstIcon = state.lastFirstIcon
		local lastIcon = state.lastLastIcon

		if firstIcon:IsShown() and lastIcon:IsShown() then
			local firstCenterX = firstIcon:GetCenter()
			local lastCenterX = lastIcon:GetCenter()

			if firstCenterX and lastCenterX then
				local movedFirst = abs(firstCenterX - (state.lastFirstIconCenterX or firstCenterX)) > 1
				local movedLast = abs(lastCenterX - (state.lastLastIconCenterX or lastCenterX)) > 1
				if movedFirst or movedLast then
					state.lastFirstIconCenterX = firstCenterX
					state.lastLastIconCenterX = lastCenterX
					changed = true
				end
			end
		else
			changed = true
		end
	end

	if not changed then
		return
	end

	local padding
	if isHorizontal then
		padding = viewer.childXPadding or viewer.iconPadding or 0
	else
		padding = viewer.childYPadding or viewer.iconPadding or 0
	end

	local rows = GetAllRows(viewer)
	if #rows == 0 then
		return
	end

	local firstRow = rows[1]
	local lastRow = rows[#rows]
	local firstInFirstRow = firstRow[1]
	local lastInLastRow = lastRow[#lastRow]

	if not firstInFirstRow or not lastInLastRow then
		return
	end

	local w = firstInFirstRow:GetWidth()
	local h = firstInFirstRow:GetHeight()
	if not w or w == 0 or not h or h == 0 then
		return
	end

	-- Calculate layout hash to detect changes
	local totalIcons = 0
	local layoutHash = 0
	for i, row in ipairs(rows) do
		local rowSize = #row
		totalIcons = totalIcons + rowSize
		layoutHash = layoutHash + rowSize * (31 ^ i)
	end
	state.lastTotalIcons = totalIcons
	state.lastRowCount = #rows
	state.lastLayoutHash = layoutHash

	local rowOffsetModifier = fromDirection == "BOTTOM" and 1 or -1
	local iconDirectionModifier = iconDirection == "NORMAL" and 1 or -1

	for iRow, row in ipairs(rows) do
		if isHorizontal then
			local yOffset = (iRow - 1) * (h + padding) * rowOffsetModifier
			local rowPointAnchor = fromDirection == "BOTTOM" and "BOTTOM" or "TOP"
			local count = #row
			local totalWidth = (count * w) + ((count - 1) * padding)
			totalWidth = roundPixel(totalWidth)

			local startX = -totalWidth / 2 + w / 2
			startX = roundPixel(startX) * iconDirectionModifier

			for i, icon in ipairs(row) do
				local x = startX + (i - 1) * (w + padding) * iconDirectionModifier
				x = roundPixel(x)

				icon:ClearAllPoints()
				icon:SetPoint(rowPointAnchor, viewer, rowPointAnchor, x, yOffset)

				if iRow == 1 and i == 1 then
					state.lastFirstIconCenterX = icon:GetCenter()
					state.lastFirstIcon = icon
				end
				if iRow == #rows and i == #row then
					state.lastLastIconCenterX = icon:GetCenter()
					state.lastLastIcon = icon
				end
			end
		else
			local xOffset = (iRow - 1) * (w + padding) * rowOffsetModifier
			local rowPointAnchor = fromDirection == "BOTTOM" and "LEFT" or "RIGHT"
			local count = #row
			local totalHeight = (count * h) + ((count - 1) * padding)
			totalHeight = roundPixel(totalHeight)

			local startY = totalHeight / 2 - h / 2
			startY = roundPixel(startY) * iconDirectionModifier

			for i, icon in ipairs(row) do
				local y = startY - (i - 1) * (h + padding) * iconDirectionModifier
				y = roundPixel(y)

				icon:ClearAllPoints()
				icon:SetPoint(rowPointAnchor, viewer, rowPointAnchor, xOffset, y)

				if iRow == 1 and i == 1 then
					state.lastFirstIconCenterX = icon:GetCenter()
					state.lastFirstIcon = icon
				end
				if iRow == #rows and i == #row then
					state.lastLastIconCenterX = icon:GetCenter()
					state.lastLastIcon = icon
				end
			end
		end
	end
end

-- Update Essential Cooldown Viewer
function CooldownManager.UpdateEssentialIfNeeded()
	local DB = AursQoLDB or {}
	if not DB.cooldownManager_centerEssential or STOP_CMC then
		return
	end
	if not EssentialCooldownViewer then
		return
	end

	local growDirection = DB.cooldownManager_centerEssential_growFromDirection or "TOP"
	CenterAllRows(EssentialCooldownViewer, growDirection)
end

-- Update Utility Cooldown Viewer
function CooldownManager.UpdateUtilityIfNeeded()
	local DB = AursQoLDB or {}
	if not DB.cooldownManager_centerUtility or STOP_CMC then
		return
	end
	if not UtilityCooldownViewer then
		return
	end

	local growDirection = DB.cooldownManager_centerUtility_growFromDirection or "TOP"
	CenterAllRows(UtilityCooldownViewer, growDirection)
end

-- Force refresh all viewers
function CooldownManager.ForceRefreshAll()
	viewerState["EssentialCooldownViewer"].lastNumChildren = -1
	viewerState["UtilityCooldownViewer"].lastNumChildren = -1
	iconState.lastCount = -1
	barState.lastCount = -1
	forcedBuffsIconRepaint = 2
	forcedBuffsBarsRepaint = 2
end

-- Main update loop
local OnUpdate = function(_, elapsed)
	local DB = AursQoLDB or {}

	if DB.cooldownManager_centerBuffIcons then
		CooldownManager.UpdateIconsIfNeeded()
	end

	if DB.cooldownManager_alignBuffBars then
		CooldownManager.UpdateBarsIfNeeded()
	end

	if DB.cooldownManager_centerEssential then
		CooldownManager.UpdateEssentialIfNeeded()
	end

	if DB.cooldownManager_centerUtility then
		CooldownManager.UpdateUtilityIfNeeded()
	end
end

local cooldownManagerFrame = CreateFrame("FRAME")

-- Initialize the system
function CooldownManager.Initialize()
	cooldownManagerFrame:SetScript("OnUpdate", OnUpdate)
end

-- Export to global
_G.AursToolkit = AursToolkit
