----------------------------------------
Outfitter.OutfitBar = {}
----------------------------------------

Outfitter.OutfitBar.UniqueNameIndex = 1
Outfitter.OutfitBar.SettingsKey = "OutfitBar"
Outfitter.OutfitBar.ShowSettingKey = "ShowOutfitBar"
Outfitter.OutfitBar.BarNamePrefix = "OutfitterOutfitBar"
Outfitter.OutfitBar.DefaultPosition = {
	RelativePoint = "TOPLEFT",
	x = 200,
	y = -200,
}

Outfitter.OutfitBar.cWildcardIcon = 134400

Outfitter.OutfitBar.cDefaultScriptIcons =
{
	ArgentDawn = "INV_Jewelry_Talisman_07",
	Riding = 132261,
	Fishing = 136245,
	Swimming = 136148,
	City = 135022,
	Battleground = 1376041,
	AB = 1376041,
	AV = 1376041,
	WSG = 1376041,
	EotS = 1376041,
	Arena = 1376041,
	Battle = 132355,
	Defensive = 132341,
	Berserker = 132347,
	Bear = 132276,
	Cat = 132115,
	Aquatic = 132144,
	Flight = 132144,
	Travel = 132144,
	Moonkin = 136096,
	Tree = 136041,
	Prowl = 132089,
	Stealth = 132320,
	Shadowform = 136200,
	GhostWolf = 136095,
	Cheetah = 132242,
	Wild = 136074,
	Feigning = 132293,
	Evocate = 136075,
	Solo = 132132,
	LOW_HEALTH = 132293,
	HAS_BUFF = 135826,
	Dining = 134062,
	Spirit = 135934,
	Caster = 135157,
	HERBALISM = 136246,
	MINING = 134708,
	SKINNING = 134366,
	LOCKPICKING = 136058,
	COOKING = 133971,

	[Outfitter.cNakedOutfit] = 237360,
}

function Outfitter.OutfitBar:GetBarSettings()
	self.Settings = self.Settings or Outfitter.Settings
	local settingsKey = self.SettingsKey or "OutfitBar"
	if not self.Settings[settingsKey] then
		self.Settings[settingsKey] = {}
	end
	return self.Settings[settingsKey]
end

function Outfitter.OutfitBar:GetDisplayCategoryOrder()
	return {"Complete"}
end

function Outfitter.OutfitBar:IsBarEnabled()
	local settings = self:GetBarSettings()
	return settings[self.ShowSettingKey or "ShowOutfitBar"] == true
end

function Outfitter.OutfitBar:Construct()
	self.Settings = Outfitter.Settings
	local settings = self:GetBarSettings()

	-- Set the default position if it's missing. Copy values so each bar owns
	-- its own SavedVariables position table.
	if not settings.Position then
		settings.Position = {
			RelativePoint = self.DefaultPosition.RelativePoint,
			x = self.DefaultPosition.x,
			y = self.DefaultPosition.y,
		}
	end

	if self.Initialized
	or not self.CanInitialize
	or not self:IsBarEnabled() then
		return
	end

	if Outfitter.LBF and not Outfitter.LBFGroup then
		Outfitter.LBFGroup = Outfitter.LBF:Group("Outfitter")
		Outfitter.LBF:RegisterSkinCallback("Outfitter", Outfitter.LBFSkinCallback, Outfitter)
		if self.Settings.LBFSettings then
			Outfitter.LBFGroup:Skin(self.Settings.LBFSettings.SkinID, self.Settings.LBFSettings.Gloss, self.Settings.LBFSettings.Backdrop, self.Settings.LBFSettings.Colors)
		end
	end

	self.Bars = {}

	self.DragBar1 = Outfitter.OutfitBar._DragBar:New(self)
	self.DragBar2 = Outfitter.OutfitBar._DragBar:New(self)

	self:SetScale(settings.Scale or 1) -- This also sets the position

	Outfitter:RegisterOutfitEvent("WEAR_OUTFIT", function () self:ChangedOutfits() end)
	Outfitter:RegisterOutfitEvent("UNWEAR_OUTFIT", function () self:ChangedOutfits() end)
	Outfitter:RegisterOutfitEvent("ADD_OUTFIT", function () self:ChangedOutfits() end)
	Outfitter:RegisterOutfitEvent("DELETE_OUTFIT", function () self:ChangedOutfits() end)
	Outfitter:RegisterOutfitEvent("EDIT_OUTFIT", function () self:ChangedOutfits() end)
	Outfitter.EventLib:RegisterEvent("PET_BATTLE_OPENING_START", self.PetBattleStarted, self)
	Outfitter.EventLib:RegisterEvent("PET_BATTLE_OVER", self.PetBattleFinished, self)
	self.Initialized = true

	self:Show()
end

function Outfitter.OutfitBar:InitializeSettings()
	self.Settings = Outfitter.Settings
	
	self.Settings.OutfitBar =
	{
		ShowOutfitBar = false,
		Position = self.DefaultPosition
	}
end

function Outfitter.OutfitBar:ResetPosition()
	-- Set the position to the default
	local settings = self:GetBarSettings()
	settings.Position = {RelativePoint = self.DefaultPosition.RelativePoint, x = self.DefaultPosition.x, y = self.DefaultPosition.y}

	-- If the bar has been initialized then update it to reflect the new position
	if self.Initialized then
		self:UpdateBars2()
	end
end

function Outfitter.OutfitBar:UpdateDragBarOrientation()
	self.DragBar1:SetVerticalOrientation(self:GetBarSettings().Vertical)
	self.DragBar2:SetVerticalOrientation(self:GetBarSettings().Vertical)
end

function Outfitter.OutfitBar:Show()
	if not self.Initialized then
		self:Construct()
	end
	
	if self.IsShown then
		return
	end
	
	self.IsShown = true

	self.DragBar1:Show()
	self.DragBar2:Show()
	self:ChangedOutfits()
end

function Outfitter.OutfitBar:Hide()
	if not self.IsShown then
		return
	end
	
	self.IsShown = false
	
	self.DragBar1:Hide()
	self.DragBar2:Hide()
	
	for vIndex = 1, #self.Bars do
		self.Bars[vIndex]:Hide()
	end
end

function Outfitter.OutfitBar:AdjustAlpha()
	if not self.Initialized then
		return
	end
	
	local settings = self:GetBarSettings()
	self:SetAlpha(Outfitter.InCombat and settings.CombatAlpha or settings.Alpha or 1)
end

function Outfitter.OutfitBar:SetAlpha(pAlpha)
	if self.LockedAlpha then
		pAlpha = self.LockedAlpha
	end
	
	for vIndex = 1, #self.Bars do
		self.Bars[vIndex]:SetAlpha(pAlpha)
	end
end

function Outfitter.OutfitBar:SetLockedAlpha(pAlpha)
	self.LockedAlpha = pAlpha
	self:AdjustAlpha()
end

function Outfitter.OutfitBar:ShowBackground(pShow)
	for vIndex = 1, #self.Bars do
		self.Bars[vIndex]:ShowBackground(pShow)
	end
end

function Outfitter.OutfitBar:SetScale(pScale)
	local settings = self:GetBarSettings()
	settings.Scale = pScale
	self.DragBar1:SetScale(pScale)
	self.DragBar2:SetScale(pScale)
	
	for vIndex = 1, #self.Bars do
		self.Bars[vIndex]:SetScale(pScale)
	end
	
	self:UpdateBars2()
end

function Outfitter.OutfitBar:DragBar_OnClick(button)
	if button == "RightButton" then
		if not self.SettingsDialog then
			self.SettingsDialog = Outfitter.OutfitBar._SettingsDialog:New(self)
		end
		
		if self.SettingsDialog:IsVisible() then
			self.SettingsDialog:HideDialog()
		else
			self.SettingsDialog:ShowDialog()
		end
	elseif self.SettingsDialog then
		self.SettingsDialog:HideDialog()
	end
end
	
function Outfitter.OutfitBar:SetShowOutfitBar(pShowBar)
	self:GetBarSettings().ShowOutfitBar = pShowBar
	
	if pShowBar then
		self:Show()
	else
		self:Hide()
	end
end

function Outfitter.OutfitBar:GetOutfitSettings(pOutfit)
	if not pOutfit.OutfitBar then
		pOutfit.OutfitBar = {}
	end
	
	return pOutfit.OutfitBar
end

function Outfitter.OutfitBar:IsOutfitEnabled(pOutfit)
	return not self:GetOutfitSettings(pOutfit).Hide
end

function Outfitter.OutfitBar:GetCurrentSpecializationID()
	local specializationIndex = GetSpecialization()
	if not specializationIndex then
		return nil
	end

	local specializationID = GetSpecializationInfo(specializationIndex)
	return specializationID
end

function Outfitter.OutfitBar:UsesAllSpecializations(pOutfit)
	local specializations = self:GetOutfitSettings(pOutfit).Specializations
	return not specializations or not next(specializations)
end

function Outfitter.OutfitBar:IsSpecializationSelected(pOutfit, specializationID)
	local specializations = self:GetOutfitSettings(pOutfit).Specializations
	return specializations and specializations[specializationID] == true or false
end

function Outfitter.OutfitBar:SetAllSpecializations(pOutfit)
	local settings = self:GetOutfitSettings(pOutfit)
	settings.Specializations = nil
	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitBar:SetSpecializationSelected(pOutfit, specializationID, selected)
	local settings = self:GetOutfitSettings(pOutfit)

	if selected then
		if not settings.Specializations then
			settings.Specializations = {}
		end
		settings.Specializations[specializationID] = true
	elseif settings.Specializations then
		settings.Specializations[specializationID] = nil
		if not next(settings.Specializations) then
			settings.Specializations = nil
		end
	end

	Outfitter:OutfitSettingsChanged(pOutfit)
end

function Outfitter.OutfitBar:MatchesCurrentSpecialization(pOutfit)
	local specializations = self:GetOutfitSettings(pOutfit).Specializations
	if not specializations or not next(specializations) then
		return true
	end

	local specializationID = self:GetCurrentSpecializationID()
	if not specializationID then
		-- Login/reload can briefly have no specialization data; keep icons visible
		-- until the next talent/spec event refreshes the bar.
		return true
	end

	return specializations[specializationID] == true
end

function Outfitter.OutfitBar:IsOutfitShown(pOutfit)
	return self:IsOutfitEnabled(pOutfit) and self:MatchesCurrentSpecialization(pOutfit)
end

function Outfitter.OutfitBar:StartFrameFades(pForceDragBars)
	local settings = self:GetBarSettings()
	if pForceDragBars or not settings.LockPosition then
		UIFrameFadeOut(self.DragBar1, 0.3, 1, 0)
		UIFrameFadeOut(self.DragBar2, 0.3, 1, 0)
	end
	
	if settings.Alpha and settings.Alpha ~= 1 then
		for vIndex = 1, #self.Bars do
			UIFrameFadeOut(self.Bars[vIndex], 0.5, 1, settings.Alpha)
		end
	end
end

function Outfitter.OutfitBar:StopFrameFades(pForceDragBars)
	local settings = self:GetBarSettings()
	if pForceDragBars or not settings.LockPosition then
		UIFrameFadeRemoveFrame(self.DragBar1)
		UIFrameFadeRemoveFrame(self.DragBar2)
	end
	
	for vIndex = 1, #self.Bars do
		UIFrameFadeRemoveFrame(self.Bars[vIndex])
	end
end

function Outfitter.OutfitBar:ShowDragBars(pForceShow)
	local settings = self:GetBarSettings()
	if pForceShow or not settings.LockPosition then
		self.DragBar1:SetAlpha(1)
		self.DragBar2:SetAlpha(1)
	end
	
	self:StopFrameFades(pForceShow)
	self:SetLockedAlpha(1)
end

function Outfitter.OutfitBar:HideDragBars(pForceHide)	
	self.LockedAlpha = nil
	self:StartFrameFades(pForceHide)
end

function Outfitter.OutfitBar:PositionChanged()
	local settings = self:GetBarSettings()
	if not settings.Position then
		settings.Position = {}
	end

	-- A bar can exist with no matching outfits. In that state there is no
	-- button frame from which to calculate a new anchor.
	if not self.Bars or #self.Bars == 0 or not self.Bars[1]:IsShown() then
		return
	end

	local vBarScale = self.Bars[1]:GetEffectiveScale()

	local vUIScale = UIParent:GetEffectiveScale()
	local vUILeft = UIParent:GetLeft() * vUIScale
	local vUIRight = UIParent:GetRight() * vUIScale
	local vUITop = UIParent:GetTop() * vUIScale
	local vUIBottom = UIParent:GetBottom() * vUIScale

	local vTopLeftBar = self.DidStackBackwards and self.Bars[#self.Bars] or self.Bars[1]
	local vBottomRightBar = self.DidStackBackwards and self.Bars[1] or self.Bars[#self.Bars]

	local vBarLeft = vTopLeftBar:GetLeft() * vBarScale
	local vBarRight = vBottomRightBar:GetRight() * vBarScale
	local vBarTop = vTopLeftBar:GetTop() * vBarScale
	local vBarBottom = vBottomRightBar:GetBottom() * vBarScale

	local vIsAnchorBottom = 0.5 * (vBarTop + vBarBottom) < 0.5 * (vUITop + vUIBottom)
	local vIsAnchorRight = 0.5 * (vBarLeft + vBarRight) < 0.5 * (vUILeft + vUIRight)

	if vIsAnchorBottom then
		settings.Position.RelativePoint = "BOTTOM"
		settings.Position.y = vBarBottom - vUIBottom
	else
		settings.Position.RelativePoint = "TOP"
		settings.Position.y = vBarTop - vUITop
	end

	if vIsAnchorRight then
		settings.Position.RelativePoint = settings.Position.RelativePoint.."LEFT"
		settings.Position.x = vBarLeft - vUILeft
	else
		settings.Position.RelativePoint = settings.Position.RelativePoint.."RIGHT"
		settings.Position.x = vBarRight - vUIRight
	end
end

function Outfitter.OutfitBar:NewBar(pNumColumns, pNumRows)
	local vName = (self.BarNamePrefix or "OutfitterOutfitBar")..self.UniqueNameIndex

	self.UniqueNameIndex = self.UniqueNameIndex + 1

	local vBar = CreateFrame("Frame", vName)

	Outfitter.InitializeFrame(vBar, Outfitter._ButtonBar, self._Bar)

	vBar:Construct(vName, pNumColumns, pNumRows, self)
	local settings = self:GetBarSettings()
	vBar:SetScale(settings.Scale or 1)
	vBar:ShowBackground(not settings.HideBackground)

	return vBar
end

function Outfitter.OutfitBar:GetDefaultIcons(pOutfit)
	local iconIDs = {}
	local usedIconIDs = {}

	-- See if the script has a default icon
	local iconID = Outfitter.OutfitBar.cDefaultScriptIcons[pOutfit.ScriptID]
	if iconID then
		table.insert(iconIDs, iconID)
		usedIconIDs[iconID] = true
	end
	
	-- See if the optimization has a default icon
	iconID = Outfitter.OutfitBar.cDefaultScriptIcons[pOutfit.StatID]
	if iconID and not usedIconIDs[iconID] then
		table.insert(iconIDs, iconID)
	end
	
	-- See if the name has a default icon
	iconID = Outfitter.OutfitBar.cDefaultScriptIcons[pOutfit:GetName()]
	if iconID and not usedIconIDs[iconID] then
		table.insert(iconIDs, iconID)
	end
	
	-- Done
	return iconIDs
end

function Outfitter.OutfitBar:GetOutfitTexture(pOutfit)
	if not pOutfit then
		return 132662
	end
	
	-- If the icon specifies the texture then just use it
	local vTexture = pOutfit:GetIcon()
	if vTexture then
		return vTexture
	end
	
	-- See if the outfit has a default icon
	local vIcons = self:GetDefaultIcons(pOutfit)
	if #vIcons > 0 then
		return vIcons[1]
	end
	
	-- If it's a single-item outfit, use that item as the icon
	local vOutfitItem
	local vItems = pOutfit:GetItems()
	for vInventorySlot, vItem in pairs(vItems) do
		if not vOutfitItem then
			vOutfitItem = vItem
		else
			vOutfitItem = nil
			break
		end
	end
	
	if vOutfitItem then
		local vTexture = GetItemIcon(vOutfitItem.Code)
		
		if vTexture then
			return vTexture
		end
	end
	
	-- Use a plain icon
	return 132662
end

function Outfitter.OutfitBar:GetCursorTexture()
	local vType, vParam1, vParam2 = GetCursorInfo()
		
	if not vType then
		return
	end
	
	if vType == "spell" then
		return GetSpellTexture(vParam1, vParam2)
	
	elseif vType == "item" then
		for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
			local	vSlotID = Outfitter.cSlotIDs[vInventorySlot]
			local	vItemLink = Outfitter:GetInventorySlotIDLink(vSlotID)
			
			if vItemLink == vParam2 then
				return GetInventoryItemTexture("player", vSlotID)
			end
		end
		
		local	vNumBags, vFirstBagIndex = Outfitter:GetNumBags()
		
		for vBagIndex = vFirstBagIndex, vNumBags do
			local vNumBagSlots = GetContainerNumSlots(vBagIndex)
			
			for vBagSlotIndex = 1, vNumBagSlots do
				local vItemLink = GetContainerItemLink(vBagIndex, vBagSlotIndex)
				
				if vItemLink == vParam2 then
					local vTexture = GetContainerItemInfo(vBagIndex, vBagSlotIndex)
					
					return vTexture
				end
			end
		end
	else
		Outfitter:DebugMessage("OutfitBar: Unknown cursor type %s param1 %s param2 %s", vType, vParam1 or "nil", vParam2 or "nil")
	end
end

function Outfitter.OutfitBar:ChangedOutfits()
	self:UpdateBars()
end

function Outfitter.OutfitBar:PetBattleStarted()
	self:Hide()
end

function Outfitter.OutfitBar:PetBattleFinished()
	if self:IsBarEnabled() then
		self:Show()
	end
end

function Outfitter.OutfitBar:UpdateBars()
	if not self.IsShown then
		return
	end
	
	-- Use a delayed task to update the bar to ensure performance
	-- is not affected when there are multiple outfits being changed
	-- simultaneously
	
	Outfitter.SchedulerLib:ScheduleUniqueTask(0.01, self.UpdateBars2, self)
end

function Outfitter.OutfitBar:xor(a, b)
	return (a or b) and not (a and b)
end

function Outfitter.OutfitBar:UpdateBars2()
	Outfitter.SchedulerLib:UnscheduleTask(self.UpdateBars2, self)
	
	-- Update the title bar orientation
	
	self:UpdateDragBarOrientation()
	
	--
	
	local settings = self:GetBarSettings()
	local vIsAnchorBottom = string.sub(settings.Position.RelativePoint, 1, 6) == "BOTTOM"
	local vIsAnchorRight = string.sub(settings.Position.RelativePoint, -5) == "RIGHT"
	local vStackBackwards = (settings.Vertical and vIsAnchorBottom)
	                     or (not settings.Vertical and vIsAnchorRight)
	
	local vDragBarAnchor = (self:xor(settings.Vertical, vIsAnchorBottom) and "BOTTOM" or "TOP")..
	                       (self:xor(settings.Vertical, vIsAnchorRight) and "LEFT" or "RIGHT")
	
	self.DidStackBackwards = vStackBackwards
	
	--
	
	self.DragBar1:ClearAllPoints()
	
	self.DragBar1:SetPoint(
			vDragBarAnchor,
			UIParent,
			settings.Position.RelativePoint,
			settings.Position.x / self.DragBar1:GetEffectiveScale(),
			settings.Position.y / self.DragBar1:GetEffectiveScale())
	
	-- Update the bars
	
	local vBarIndex = 1
	local vPreviousBar = self.DragBar1
	
	local vCategoryOrder = self:GetDisplayCategoryOrder()
	
	if vStackBackwards then
		for vCategoryIndex = #vCategoryOrder, 1, -1 do
			local vCategoryID = vCategoryOrder[vCategoryIndex]
			
			if self:UpdateBar(vBarIndex, vCategoryID) then
				local vBar = self.Bars[vBarIndex]
				
				vBar:ClearAllPoints()
				
				if settings.Vertical then
					vBar:SetPoint("BOTTOMLEFT", vPreviousBar, "TOPLEFT")
				else
					vBar:SetPoint("TOPRIGHT", vPreviousBar, "TOPLEFT")
				end
				
				vAnchorOffsetX, vAnchorOffsetY = nil, nil
							
				vBar:Show()
				
				vBarIndex = vBarIndex + 1
				vPreviousBar = vBar
			end
		end
		
		self.DragBar2:ClearAllPoints()
		if settings.Vertical then
			self.DragBar2:SetPoint("BOTTOMLEFT", vPreviousBar, "TOPLEFT")
		else
			self.DragBar2:SetPoint("TOPRIGHT", vPreviousBar, "TOPLEFT")
		end
	else
		for vCategoryIndex, vCategoryID in ipairs(vCategoryOrder) do
			if self:UpdateBar(vBarIndex, vCategoryID) then
				local vBar = self.Bars[vBarIndex]
				
				vBar:ClearAllPoints()
				
				if settings.Vertical then
					vBar:SetPoint("TOPLEFT", vPreviousBar, "BOTTOMLEFT")
				else
					vBar:SetPoint("TOPLEFT", vPreviousBar, "TOPRIGHT")
				end
				
				vAnchorOffsetX, vAnchorOffsetY = nil, nil
				
				vBar:Show()
				
				vBarIndex = vBarIndex + 1
				vPreviousBar = vBar
			end
		end
		
		self.DragBar2:ClearAllPoints()
		if settings.Vertical then
			self.DragBar2:SetPoint("TOPLEFT", vPreviousBar, "BOTTOMLEFT", 0, 6)
		else
			self.DragBar2:SetPoint("TOPLEFT", vPreviousBar, "TOPRIGHT", -1, 0)
		end
	end

	-- Hide unused bars
	
	for vIndex = vBarIndex, #self.Bars do
		self.Bars[vIndex]:Hide()
	end
	
	-- Fudge the drag bars so they look nice against the edges of the frame
	
	local vBar1OffsetX, vBar1OffsetY = 0, 0
	local vBar2OffsetX, vBar2OffsetY = 0, 0
	
	if settings.Vertical then
		if vIsAnchorBottom then
			vBar1OffsetY = 4
			vBar2OffsetY = 1
		else
			vBar1OffsetY = 1
			vBar2OffsetY = -2
		end
	else
		if vIsAnchorRight then
			vBar1OffsetX = -1
			vBar2OffsetX = -2
		else
			vBar1OffsetX = -2
		end
	end
	
	self.DragBar1:SetTextureOffset(vBar1OffsetX, vBar1OffsetY)
	self.DragBar2:SetTextureOffset(vBar2OffsetX, vBar2OffsetY)
end

function Outfitter.OutfitBar:AnchorDragBar(pBar)
	pBar:ClearAllPoints()
	local settings = self:GetBarSettings()

	pBar:SetPoint(
			settings.Position.RelativePoint,
			UIParent,
			settings.Position.RelativePoint,
			settings.Position.x / self.DragBar1:GetEffectiveScale(),
			settings.Position.y / self.DragBar1:GetEffectiveScale())
end

function Outfitter.OutfitBar:UpdateBar(pBarIndex, pCategoryID)
	local vOutfits = Outfitter:GetOutfitsByCategoryID(pCategoryID)
	
	if not vOutfits then
		return false
	end
	
	local vNumShown = 0
	
	for vOutfitIndex, vOutfit in ipairs(vOutfits) do
		if self:IsOutfitShown(vOutfit) then
			vNumShown = vNumShown + 1
		end
	end
	
	if vNumShown == 0 then
		return false
	end
	
	local vBar = self.Bars[pBarIndex]
	local vNumColumns, vNumRows
	
	if self:GetBarSettings().Vertical then
		vNumColumns = 1
		vNumRows = vNumShown
	else
		vNumColumns = vNumShown
		vNumRows = 1
	end
	
	if not vBar then
		vBar = self:NewBar(vNumColumns, vNumRows)
		table.insert(self.Bars, vBar)
	else
		vBar:SetDimensions(vNumColumns, vNumRows)
	end

	local vScale = self:GetBarSettings().Scale or 1
	vBar:SetScale(vScale)
	vBar.CategoryID = pCategoryID
	
	local vButtonIndex = 1
	
	for vOutfitIndex, vOutfit in ipairs(vOutfits) do
		if self:IsOutfitShown(vOutfit) then
			vBar:SetButtonOutfit(vButtonIndex, vOutfit)
			vButtonIndex = vButtonIndex + 1
		end
	end
	
	return true
end

----------------------------------------
Outfitter.OutfitBar._Bar = {}
----------------------------------------

function Outfitter.OutfitBar._Bar:Construct(pName, pNumColumns, pNumRows, pOwnerBar)
	self.OwnerBar = pOwnerBar or Outfitter.OutfitBar
	Outfitter._ButtonBar.Construct(self, pName, pNumColumns, pNumRows, Outfitter.OutfitBar._Button, "ActionButtonTemplate")
	
	self:SetScript("OnEnter", function () self.OwnerBar:ShowDragBars() end)
	self:SetScript("OnLeave", function () self.OwnerBar:HideDragBars() end)
end

function Outfitter.OutfitBar._Bar:SetButtonOutfit(pButtonIndex, pOutfit)
	local vButton = self:GetIndexedButton(pButtonIndex)
	
	if not vButton then
		return
	end
	
	vButton:SetOutfit(pOutfit)
end

function Outfitter.OutfitBar._Bar:Update()
	for vIndex = 1, self.NumButtons do
		self:GetIndexedButton(vIndex):Update()
	end
end

----------------------------------------
Outfitter.OutfitBar._Button = {}
----------------------------------------

Outfitter.OutfitBar._Button.Widgets =
{
	"Icon",
}

function Outfitter.OutfitBar._Button:Construct()
	self:SetWidth(Outfitter.Style.ButtonBar.ButtonWidth)
	self:SetHeight(Outfitter.Style.ButtonBar.ButtonHeight)
	
	self:SetScript("OnClick", function (button, ...) button:OnClick(...) end)
	self:SetScript("OnEnter", function (button, ...) button:OnEnter(...) end)
	self:SetScript("OnLeave", function (button, ...) button:OnLeave(...) end)
	
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	
	if Outfitter.LBFGroup then
		Outfitter.LBFGroup:AddButton(self)
	end
end

function Outfitter.OutfitBar._Button:SetOutfit(pOutfit)
	self.Outfit = pOutfit
	self:Update()
end

function Outfitter.OutfitBar._Button:Update()
	local vTexture = Outfitter.OutfitBar:GetOutfitTexture(self.Outfit)

	self.Widgets.Icon:SetTexture(vTexture)
	
	if Outfitter:WearingOutfit(self.Outfit) then
		self:SetChecked(true)
		self.Widgets.Icon:SetVertexColor(1, 1, 1)
	else
		self:SetChecked(false)
		self.Widgets.Icon:SetVertexColor(0.9, 0.9, 0.9)
	end
end

function Outfitter.OutfitBar._Button:OnClick(pMouseButton)
	if pMouseButton == "LeftButton" then
		local vType, vParam1, vParam2 = GetCursorInfo()
			
		if vType then
			-- Set the icon if they're holding an item and
			-- the alt key is down
			
			if IsAltKeyDown() then
				local vTexture = Outfitter.OutfitBar:GetCursorTexture()
				
				if vTexture then
					if not self.Outfit.OutfitBar then
						self.Outfit.OutfitBar = {}
					end
					
					self.Outfit:SetIcon(vTexture)
					self:Update()
					ClearCursor()
				end
			
			-- Otherwise create an outfit from the item being held
			
			elseif vType == "item" then
				local vItem = Outfitter:GetItemInfoFromLink(vParam2)
				
				if not vItem then
					Outfitter:ErrorMessage("Outfitter.OutfitBar: Couldn't get information about the item being dropped")
					return
				end
				
				if not vItem.ItemSlotName then
					Outfitter:ErrorMessage("Outfitter.OutfitBar: Couldn't make an outfit from "..vItem.Name.." because it isn't equippable")
					return
				end
				
				-- Create a new outfit containing the item and equip it
				
				local vOutfit = Outfitter:NewEmptyOutfit(vItem.Name)
				
				vOutfit:AddItem(vItem.ItemSlotName, vItem)
				Outfitter:AddOutfit(vOutfit)
				Outfitter:WearOutfit(vOutfit)
			end
		
		-- If there are no modifiers down, then just equip or unequip the outfit
		
		else
			Outfitter.HasHWEvent = true
			if self.Outfit.CategoryID == "Complete"
			or not Outfitter:WearingOutfit(self.Outfit) then
				Outfitter:WearOutfit(self.Outfit)
			else
				Outfitter:RemoveOutfit(self.Outfit)
			end
			Outfitter.HasHWEvent = false
		end
	else -- if pButton == "RightButton" then
		-- If the menu is already up then hide it
		if self.menuFrame then
			self.menuFrame:Hide()
			return
		end

		-- Create the menu
		local items = Outfitter:New(Outfitter.UIElementsLib._DropDownMenuItems, function ()
			Outfitter.SchedulerLib:ScheduleTask(0.2, function () self.menuFrame:Hide() end)
		end)
		Outfitter:AddOutfitMenu(items, self.Outfit)
		
		-- Get the cursor's position
		local cursorX, cursorY = GetCursorPosition()
		local uiScale = UIParent:GetScale()
		cursorX = cursorX / uiScale
		cursorY = cursorY / uiScale

		-- Get the nearest and opposite edges
		local nearestVert, nearestHoriz, oppositeVert, oppositeHoriz = Outfitter:GetNearestFrameEdgesFromCoordinates(UIParent, cursorX, cursorY)
		local anchorPoint = nearestVert..nearestHoriz
		local relativePoint = oppositeVert..nearestHoriz

		-- Show the menu
		self.menuFrame = LibStub("LibDropdownMC-1.0"):OpenAce3Menu(items)
		self.menuFrame:SetPoint(anchorPoint, self, relativePoint, 0, 0)
		self.menuFrame.cleanup = function ()
			self.menuFrame = nil
			self:Update()
		end
	end
end

function Outfitter.OutfitBar._Button:OnEnter()
	local	vMissingItems, vBankedItems = Outfitter:GetInventoryCache():GetMissingItems(self.Outfit)
	
	Outfitter:ShowOutfitTooltip(self.Outfit, self, vMissingItems, vBankedItems, true)
	
	local ownerBar = self:GetParent().OwnerBar or Outfitter.OutfitBar
	ownerBar:ShowDragBars()
end

function Outfitter.OutfitBar._Button:OnLeave()
	GameTooltip:Hide()
	local ownerBar = self:GetParent().OwnerBar or Outfitter.OutfitBar
	ownerBar:HideDragBars()
end

----------------------------------------
Outfitter.OutfitBar._ChooseIconDialog = {}
----------------------------------------

Outfitter.OutfitBar._ChooseIconDialog.Widgets =
{
	"ScrollFrame",
	"IconSetMenu",
	"FilterEditBox",
	"Title"
}

function Outfitter.OutfitBar._ChooseIconDialog:Construct()
	-- Create the icon buttons
	
	self.IconButtons = {}
	self.NumRows = 5
	self.NumColumns = 6
	
	local vPrevRowFirstButton
	
	for vRow = 1, self.NumRows do
		local vPrevButton
		
		for vColumn = 1, self.NumColumns do
			local vButton = self:NewIconButton()
			
			table.insert(self.IconButtons, vButton)
			
			if vPrevButton then
				vButton:SetPoint("LEFT", vPrevButton, "RIGHT", 10, 0)
			else
				if vPrevRowFirstButton then
					vButton:SetPoint("TOPLEFT", vPrevRowFirstButton, "BOTTOMLEFT", 0, -8)
				else
					vButton:SetPoint("TOPLEFT", self.Widgets.ScrollFrame, "TOPLEFT", 0, 0)
				end
				
				vPrevRowFirstButton = vButton
			end
			
			vPrevButton = vButton
		end
	end
	
	-- Hook into the UIMenus list when the dialog is up to capture the escape key presses
	
	self:SetScript("OnShow", function(self)
		Outfitter:BeginMenu(self)
	end)
	
	self:SetScript("OnHide", function(self)
		Outfitter:EndMenu(self)
		
		if self.Outfit then
			self:Close()
		end
	end)

	-- Icon sets
	self.iconSets = {
		{id = "Recommend", name = Outfitter.cSuggestedIcons},
		{id = "Spellbook", name = Outfitter.cSpellbookIcons},
		{id = "Inventory", name = Outfitter.cYourItemIcons},
		{id = "All", name = Outfitter.cEveryIcon},
		{id = "Items", name = Outfitter.cItemIcons},
		{id = "Abilities", name = Outfitter.cAbilityIcons},
	}

	-- Set the default icon set
	self.IconSetID = self.iconSets[1].id
end

function Outfitter.OutfitBar._ChooseIconDialog:Open(pOutfit)
	self.Outfit = pOutfit
	self.SelectedTexture = self.Outfit:GetIcon()
	
	if not self.SelectedTexture then
		self.SelectedTexture = Outfitter.OutfitBar.cWildcardIcon
	end
	
	self.Widgets.Title:SetText(string.format(Outfitter.cChooseIconTitle, pOutfit:GetName()))
	self.Widgets.FilterEditBox:SetText("")
	self:SetIconSetID(self.IconSetID)
	
	self:Show()
end

function Outfitter.OutfitBar._ChooseIconDialog:Save()
	if self.SelectedTexture == Outfitter.OutfitBar.cWildcardIcon then
		self.Outfit:SetIcon(nil)
	else
		self.Outfit:SetIcon(self.SelectedTexture)
	end
	
	Outfitter:DispatchOutfitEvent("EDIT_OUTFIT", self.Outfit:GetName(), self.Outfit)
end

function Outfitter.OutfitBar._ChooseIconDialog:Close()
	if self.TextureSet and self.TextureSet.Deactivate then
		self.TextureSet:Deactivate()
		self.TextureSet = nil
	end
	
	self.Outfit = nil
	self:Hide()
end

function Outfitter.OutfitBar._ChooseIconDialog:SetIconSetID(pIconSetID)
	self.IconSetID = pIconSetID
	self.TextureList = nil
	
	-- Find the name
	for _, iconSet in ipairs(self.iconSets) do
		if iconSet.id == pIconSetID then
			self.Widgets.IconSetMenu:SetCurrentValueText(iconSet.name)
			break
		end
	end

	self:SetIconFilter(self.Widgets.FilterEditBox:GetText())
end

function Outfitter.OutfitBar._ChooseIconDialog:SetIconFilter(pText)
	local vTextureSet = Outfitter.OutfitBar.TextureSets[self.IconSetID]
	
	-- Activate the set if it's changing
	
	if vTextureSet ~= self.TextureSet then
		if self.TextureSet and self.TextureSet.Deactivate then
			self.TextureSet:Deactivate()
		end
		
		self.TextureSet = vTextureSet
		
		if self.TextureSet.Activate then
			self.TextureSet:Activate(self.Outfit)
		end
	end
	
	--
	
	if pText and pText ~= "" then
		self.DisplayTextureSet = Outfitter.OutfitBar.TextureSets.Filtered
		self.DisplayTextureSet:SetFilter(vTextureSet, pText)
	else
		if self.DisplayTextureSet == Outfitter.OutfitBar.TextureSets.Filtered then
			self.DisplayTextureSet:Deactivate()
		end
		
		self.DisplayTextureSet = self.TextureSet
	end
	
	self:UpdateIcons()
end

function Outfitter.OutfitBar._ChooseIconDialog:SetSelectedTexture(pTexture)
	self.SelectedTexture = pTexture
	
	self:UpdateIcons()
end

function Outfitter.OutfitBar._ChooseIconDialog:UpdateIcons()
	local vNumTextures = self.DisplayTextureSet:GetNumTextures()
	
	FauxScrollFrame_Update(self.Widgets.ScrollFrame, ceil(vNumTextures / self.NumColumns), self.NumRows, 36)
	
	local vScrollOffset = FauxScrollFrame_GetOffset(self.Widgets.ScrollFrame)
	local vTextureIndex = 1 + vScrollOffset * self.NumColumns
	
	for _, vIconButton in ipairs(self.IconButtons) do
		if vTextureIndex <= vNumTextures then
			local vTexture = self.DisplayTextureSet:GetIndexedTexture(vTextureIndex)
			
			if vTexture == self.SelectedTexture then
				vIconButton:SetChecked(true)
			else
				vIconButton:SetChecked(false)
			end
			
			vIconButton.Texture = vTexture
			vIconButton.Widgets.Icon:SetTexture(vTexture)
			vIconButton:Show()
			
			vTextureIndex = vTextureIndex + 1
		else
			vIconButton:Hide()
		end
	end
end

function Outfitter.OutfitBar._ChooseIconDialog:NewIconButton()
	local vButtonName = "OutfitterChooseIconDialogButton"..#self.IconButtons
	local vButton = CreateFrame("CheckButton", vButtonName, self, "ActionButtonTemplate")
	
	Outfitter.InitializeFrame(vButton, Outfitter.OutfitBar._IconButton)
	vButton:Construct()
	
	vButton:SetFrameLevel(self:GetFrameLevel() + 1)
	vButton:SetParent(self)
	
	vButton:Enable()
	vButton:Show()

	return vButton
end

function Outfitter.OutfitBar._ChooseIconDialog:GetIconSetMenuItems(menu)
	for _, iconSet in ipairs(self.iconSets) do
		menu:AddToggle(iconSet.name, function ()
				return self.IconSetID == iconSet.id
			end, function (menu, value)
				self:SetIconSetID(iconSet.id)
			end)
	end
end

----------------------------------------
Outfitter.OutfitBar._IconButton = {}
----------------------------------------

Outfitter.OutfitBar._IconButton.Widgets =
{
	"Icon",
	"Flash",
	"HotKey",
	"Count",
	"Name",
	"Border",
	"Cooldown",
	"NormalTexture",
}

function Outfitter.OutfitBar._IconButton:Construct()
	self:EnableMouse(true)
	
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", self.OnLeave)
	self:SetScript("OnClick", self.OnClick)
end

function Outfitter.OutfitBar._IconButton:OnEnter()
	local vTextureName
	
	if self.Texture == Outfitter.OutfitBar.cWildcardIcon then
		vTextureName = Outfitter.cOutfitterDecides
	else
		vTextureName = self.Texture
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine(Outfitter:ConvertTextureIDToString(vTextureName))
	GameTooltip:Show()
end

function Outfitter.OutfitBar._IconButton:OnLeave()
	GameTooltip:Hide()
end

function Outfitter.OutfitBar._IconButton:OnClick()
	self:GetParent():SetSelectedTexture(self.Texture)
end

----------------------------------------
Outfitter.OutfitBar.TextureSets = {}
----------------------------------------

----------------------------------------
Outfitter.OutfitBar.TextureSets.Recommend = {}
----------------------------------------

function Outfitter.OutfitBar.TextureSets.Recommend:Activate(outfit)
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
	local usedIconIDs = {}

	-- Add the wildcard item
	table.insert(self.TextureList, Outfitter.OutfitBar.cWildcardIcon)
	
	-- Add each equipped item
	local items = outfit:GetItems()
	for _, outfitItem in pairs(items) do
		local item = Outfitter:GetInventoryCache():FindItemOrAlt(outfitItem)
		if item and item.Texture and not usedIconIDs[item.Texture] then
			table.insert(self.TextureList, item.Texture)
			usedIconIDs[item.Texture] = true
		end
	end
	
	-- Add any default icons
	local iconIDs = Outfitter.OutfitBar:GetDefaultIcons(outfit)
	for _, iconID in ipairs(iconIDs) do
		if not usedIconIDs[iconID] then
			table.insert(self.TextureList, iconID)
			usedIconIDs[iconID] = true
		end
	end
end

function Outfitter.OutfitBar.TextureSets.Recommend:Deactivate()
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
end

function Outfitter.OutfitBar.TextureSets.Recommend:GetNumTextures()
	return #self.TextureList
end

function Outfitter.OutfitBar.TextureSets.Recommend:GetIndexedTexture(pIndex)
	return self.TextureList[pIndex]
end

----------------------------------------
Outfitter.OutfitBar.TextureSets.All = {}
----------------------------------------

function Outfitter.OutfitBar.TextureSets.All:GetNumTextures()
	if not self.icons then
		self.icons = {}
		GetMacroItemIcons(self.icons)
		GetMacroIcons(self.icons)
	end
	return #self.icons
end

function Outfitter.OutfitBar.TextureSets.All:GetIndexedTexture(pIndex)
	return self.icons[pIndex]
end

----------------------------------------
Outfitter.OutfitBar.TextureSets.Items = {}
----------------------------------------

function Outfitter.OutfitBar.TextureSets.Items:GetNumTextures()
	if not self.icons then
		self.icons = {}
		GetMacroItemIcons(self.icons)
	end
	return #self.icons
end

function Outfitter.OutfitBar.TextureSets.Items:GetIndexedTexture(pIndex)
	return self.icons[pIndex]
end

----------------------------------------
Outfitter.OutfitBar.TextureSets.Abilities = {}
----------------------------------------

function Outfitter.OutfitBar.TextureSets.Abilities:GetNumTextures()
	if not self.icons then
		self.icons = {}
		GetMacroIcons(self.icons)
	end
	return #self.icons
end

function Outfitter.OutfitBar.TextureSets.Abilities:GetIndexedTexture(pIndex)
	return self.icons[pIndex]
end

----------------------------------------
Outfitter.OutfitBar.TextureSets.Spellbook = {}
----------------------------------------

function Outfitter.OutfitBar.TextureSets.Spellbook:Activate()
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
	
	-- Always include the wildcard icon
	table.insert(self.TextureList, Outfitter.OutfitBar.cWildcardIcon)
	
	-- Only insert each texture once
	local usedIconIDs = {}
	
	-- Insert the profession icons
	local professions = {GetProfessions()}
	for _, professionID in ipairs(professions) do
		local name, iconID = GetProfessionInfo(professionID)
		if not usedIconIDs[iconID] then
			table.insert(self.TextureList, iconID)
			usedIconIDs[iconID] = true
		end
	end

	-- Insert the spellbook category icons together
	for tabIndex = 1, MAX_SKILLLINE_TABS do
		local	categoryName, categoryIconID, categoryOffset, categoryNumSpells = GetSpellTabInfo(tabIndex)
		
		if not categoryName then
			break
		end
		
		if categoryIconID and not usedIconIDs[categoryIconID] then
			table.insert(self.TextureList, categoryIconID)
			usedIconIDs[categoryIconID] = true
		end
	end
	
	-- Now insert the icons from each category
	for tabIndex = 1, MAX_SKILLLINE_TABS do
		local	categoryName, categoryIconID, categoryOffset, categoryNumSpells = GetSpellTabInfo(tabIndex)
		
		if not categoryName then
			break
		end
		
		for spellIndex = categoryOffset + 1, categoryOffset + categoryNumSpells do
			local spellIconID = GetSpellTexture(spellIndex, BOOKTYPE_SPELL)
			
			if spellIconID and not usedIconIDs[spellIconID] then
				table.insert(self.TextureList, spellIconID)
				usedIconIDs[spellIconID] = true
			end
		end
	end
end

function Outfitter.OutfitBar.TextureSets.Spellbook:Deactivate()
	-- Wipe the list so the memory doesn't linger
	
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
end

function Outfitter.OutfitBar.TextureSets.Spellbook:GetNumTextures()
	return #self.TextureList
end

function Outfitter.OutfitBar.TextureSets.Spellbook:GetIndexedTexture(pIndex)
	return self.TextureList[pIndex]
end

----------------------------------------
Outfitter.OutfitBar.TextureSets.Inventory = {}
----------------------------------------

function Outfitter.OutfitBar.TextureSets.Inventory:Activate()
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
	
	table.insert(self.TextureList, Outfitter.OutfitBar.cWildcardIcon)
	
	local vUsedTextures = {}
	
	for _, vInventorySlot in ipairs(Outfitter.cSlotNames) do
		local	vSlotID = Outfitter.cSlotIDs[vInventorySlot]
		local	vItemLink = Outfitter:GetInventorySlotIDLink(vSlotID)
		
		if vItemLink == vParam2 then
			local vTexture = GetInventoryItemTexture("player", vSlotID)
			
			if vTexture and not vUsedTextures[vTexture] then
				table.insert(self.TextureList, vTexture)
				vUsedTextures[vTexture] = true
			end
		end
	end
	
	--
	
	local vNumBags, vFirstBagIndex = Outfitter:GetNumBags()
	
	for vBagIndex = vFirstBagIndex, vNumBags do
		local	vNumBagSlots = GetContainerNumSlots(vBagIndex)
		
		if vNumBagSlots > 0 then
			for vSlotIndex = 1, vNumBagSlots do
				local vTexture = GetContainerItemInfo(vBagIndex, vSlotIndex)
				
				if vTexture and not vUsedTextures[vTexture] then
					table.insert(self.TextureList, vTexture)
					vUsedTextures[vTexture] = true
				end
			end
		end
	end
end

function Outfitter.OutfitBar.TextureSets.Inventory:Deactivate()
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
end

function Outfitter.OutfitBar.TextureSets.Inventory:GetNumTextures()
	return #self.TextureList
end

function Outfitter.OutfitBar.TextureSets.Inventory:GetIndexedTexture(pIndex)
	return self.TextureList[pIndex]
end

----------------------------------------
Outfitter.OutfitBar.TextureSets.Filtered = {}
----------------------------------------

function Outfitter.OutfitBar.TextureSets.Filtered:Deactivate()
	-- Wipe the list so the memory doesn't linger
	
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
end

function Outfitter.OutfitBar.TextureSets.Filtered:SetFilter(pTextureSet, pFilter)
	self.TextureSet = pTextureSet
	self.Filter = strlower(pFilter)
	
	self.TextureList = Outfitter:RecycleTable(self.TextureList)
	
	local vNumTextures = self.TextureSet:GetNumTextures()
	
	for vIndex = 1, vNumTextures do
		local vTexture = self.TextureSet:GetIndexedTexture(vIndex)
		local vTextureString = Outfitter:ConvertTextureIDToString(vTexture)
		
		if strfind(strlower(vTextureString), self.Filter) then
			table.insert(self.TextureList, vTexture)
		end
	end
end

function Outfitter.OutfitBar.TextureSets.Filtered:GetNumTextures()
	return #self.TextureList
end

function Outfitter.OutfitBar.TextureSets.Filtered:GetIndexedTexture(pIndex)
	return self.TextureList[pIndex]
end

----------------------------------------
-- Independent accessory/trinket bar
----------------------------------------

Outfitter.AccessoryBar =
{
	SettingsKey = "AccessoryBar",
	ShowSettingKey = "ShowAccessoryBar",
	BarNamePrefix = "OutfitterAccessoryBar",
	UniqueNameIndex = 1,
	DefaultPosition = {RelativePoint = "TOPLEFT", x = 200, y = -260},

	-- IMPORTANT: mutable controller state must be owned by this table.
	-- Leaving these absent would make __index fall through to OutfitBar and
	-- cause both controllers to share runtime state after OutfitBar initializes.
	Settings = false,
	Initialized = false,
	CanInitialize = false,
	IsShown = false,
	Bars = {},
	DragBar1 = false,
	DragBar2 = false,
	SettingsDialog = false,
	LockedAlpha = false,
	DidStackBackwards = false,
}
setmetatable(Outfitter.AccessoryBar, {__index = Outfitter.OutfitBar})

function Outfitter.AccessoryBar:InitializeSettings()
	self.Settings = Outfitter.Settings
	self.Settings.AccessoryBar =
	{
		ShowAccessoryBar = true,
		Position = {
			RelativePoint = self.DefaultPosition.RelativePoint,
			x = self.DefaultPosition.x,
			y = self.DefaultPosition.y,
		},
		Scale = 1.00,
	}
end

function Outfitter.AccessoryBar:GetDisplayCategoryOrder()
	return {"TrinketSet"}
end

function Outfitter.AccessoryBar:Construct()
	self.Settings = Outfitter.Settings
	local settings = self:GetBarSettings()
	if settings.Scale == nil then settings.Scale = 1.00 end
	if settings.Alpha == nil then settings.Alpha = 1 end
	if settings.CombatAlpha == nil then settings.CombatAlpha = 1 end
	if settings.Vertical == nil then settings.Vertical = false end
	return Outfitter.OutfitBar.Construct(self)
end

function Outfitter.AccessoryBar:SetShowAccessoryBar(pShowBar)
	self:GetBarSettings().ShowAccessoryBar = pShowBar

	if pShowBar then
		self:Show()
	else
		self:Hide()
	end
end

-- AccessoryBar uses the same settings-dialog implementation as OutfitBar,
-- but the dialog is bound to this controller so scale/alpha/orientation/lock/
-- background settings remain fully independent.
function Outfitter.AccessoryBar:DragBar_OnClick(button)
	return Outfitter.OutfitBar.DragBar_OnClick(self, button)
end

Outfitter:RegisterOutfitEvent("OUTFITTER_INIT", function ()
	Outfitter.OutfitBar.CanInitialize = true
	Outfitter.OutfitBar:Construct()
	Outfitter.AccessoryBar.CanInitialize = true
	Outfitter.AccessoryBar:Construct()
	OutfitterChooseIconDialog:Construct()
end)

----------------------------------------
Outfitter.OutfitBar._SettingsDialog = {}
----------------------------------------

function Outfitter.OutfitBar._SettingsDialog:New(pOwnerBar)
	local vOwnerBar = pOwnerBar or Outfitter.OutfitBar
	local vDialogName
	if vOwnerBar.SettingsKey == "AccessoryBar" then
		vDialogName = "AccessoryBarSettingsDialog"
	else
		vDialogName = "OutfitBarSettingsDialog"
	end

	local vSettingsDialog = CreateFrame("Frame", vDialogName, UIParent)

	Outfitter:ConstructFrame(vSettingsDialog, self)
	vSettingsDialog.OwnerBar = vOwnerBar

	return vSettingsDialog
end

function Outfitter.OutfitBar._SettingsDialog:Construct()
	self:SetFrameStrata("DIALOG")

	self:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 3, right = 3, top = 3, bottom = 3}})

	self:SetBackdropBorderColor(0.75, 0.75, 0.75)
	self:SetBackdropColor(0, 0, 0, 0.9)
	self:SetAlpha(1)

	self:SetScript("OnShow", function (self) self:OnShow() end)
	self:SetScript("OnHide", function (self) self:OnHide() end)
	self:SetScript("OnUpdate", function (self) self:OnUpdate() end)

	self:SetWidth(180)
	self:SetHeight(245)

	self.SizeSlider = self:NewSlider(Outfitter.cOutfitBarSizeLabel, 0.5, 1.5, Outfitter.cOutfitBarSmallSizeLabel, Outfitter.cOutfitBarLargeSizeLabel, self.SizeSlider_OnValueChanged)
	self.SizeSlider:SetPoint("TOP", self, "TOP", 0, -27)

	self.AlphaSlider = self:NewSlider(Outfitter.cOutfitBarAlphaLabel, 0, 1, nil, nil, self.AlphaSlider_OnValueChanged)
	self.AlphaSlider:SetPoint("TOPLEFT", self.SizeSlider, "BOTTOMLEFT", 0, -30)

	self.CombatAlphaSlider = self:NewSlider(Outfitter.cOutfitBarCombatAlphaLabel, 0, 1, nil, nil, self.CombatAlphaSlider_OnValueChanged)
	self.CombatAlphaSlider:SetPoint("TOPLEFT", self.AlphaSlider, "BOTTOMLEFT", 0, -30)

	self.VerticalCheckbutton = self:NewCheckbutton(Outfitter.cOutfitBarVerticalLabel, self.VerticalCheckbutton_OnClick)
	self.VerticalCheckbutton:SetPoint("TOPLEFT", self.CombatAlphaSlider, "BOTTOMLEFT", -5, -15)

	self.LockPositionCheckbutton = self:NewCheckbutton(Outfitter.cOutfitBarLockPositionLabel, self.LockPositionCheckbutton_OnClick)
	self.LockPositionCheckbutton:SetPoint("TOPLEFT", self.VerticalCheckbutton, "BOTTOMLEFT", 0, 7)

	self.HideBackgroundCheckbutton = self:NewCheckbutton(Outfitter.cOutfitBarHideBackgroundLabel, self.HideBackgroundCheckbutton_OnClick)
	self.HideBackgroundCheckbutton:SetPoint("TOPLEFT", self.LockPositionCheckbutton, "BOTTOMLEFT", 0, 7)

	self:Hide() -- Hidden by default
end

function Outfitter.OutfitBar._SettingsDialog:ShowDialog()
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	local vSettings = vBar:GetBarSettings()

	self.DisableUpdates = true
	self.SizeSlider:SetValue(vSettings.Scale or 1)
	self.AlphaSlider:SetValue(vSettings.Alpha or 1)
	self.CombatAlphaSlider:SetValue(vSettings.CombatAlpha or 1)
	self.VerticalCheckbutton:SetChecked(vSettings.Vertical)
	self.LockPositionCheckbutton:SetChecked(vSettings.LockPosition)
	self.HideBackgroundCheckbutton:SetChecked(vSettings.HideBackground)
	self.DisableUpdates = false

	-- Put the dialog under the cursor
	local cursorX, cursorY = GetCursorPosition()
	local uiScale = UIParent:GetScale()
	cursorX = cursorX / uiScale
	cursorY = cursorY / uiScale
	local anchorPoint = Outfitter:GetScreenQuadrantFromCoordinates(cursorX, cursorY)

	self:ClearAllPoints()
	self:SetPoint(anchorPoint, UIParent, "BOTTOMLEFT", cursorX, cursorY)
	self:Show()
end

function Outfitter.OutfitBar._SettingsDialog:HideDialog()
	self:Hide()
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	vBar:AdjustAlpha()
	return true
end

function Outfitter.OutfitBar._SettingsDialog:OnShow()
	-- Capture the button state which opened the dialog so the opening click
	-- doesn't immediately count as an outside click on the next frame.
	self.LeftMouseDown = IsMouseButtonDown("LeftButton")
	self.RightMouseDown = IsMouseButtonDown("RightButton")

	Outfitter:BeginMenu(self)
end

function Outfitter.OutfitBar._SettingsDialog:OnHide()
	Outfitter:EndMenu(self)
	self.LeftMouseDown = nil
	self.RightMouseDown = nil

	local vBar = self.OwnerBar or Outfitter.OutfitBar
	vBar:AdjustAlpha()
end

function Outfitter.OutfitBar._SettingsDialog:OnUpdate()
	local vLeftMouseDown = IsMouseButtonDown("LeftButton")
	local vRightMouseDown = IsMouseButtonDown("RightButton")

	local vNewMouseDown = (vLeftMouseDown and not self.LeftMouseDown)
	                 or (vRightMouseDown and not self.RightMouseDown)

	self.LeftMouseDown = vLeftMouseDown
	self.RightMouseDown = vRightMouseDown

	if vNewMouseDown
	and not Outfitter.CursorInFrame(self) then
		self:HideDialog()
	end
end

----------------------------------------
-- Notifications
----------------------------------------

function Outfitter.OutfitBar._SettingsDialog:SizeSlider_OnValueChanged()
	if self.DisableUpdates then return end
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	local vSettings = vBar:GetBarSettings()
	vSettings.Scale = self.SizeSlider:GetValue()
	if vBar == Outfitter.AccessoryBar then
		vSettings.UserScaleConfigured = true
	end
	vBar:SetScale(vSettings.Scale)
	vBar:SetAlpha(1)
end

function Outfitter.OutfitBar._SettingsDialog:AlphaSlider_OnValueChanged()
	if self.DisableUpdates then return end
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	local vSettings = vBar:GetBarSettings()
	vSettings.Alpha = self.AlphaSlider:GetValue()
	vBar:SetAlpha(vSettings.Alpha)
end

function Outfitter.OutfitBar._SettingsDialog:CombatAlphaSlider_OnValueChanged()
	if self.DisableUpdates then return end
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	local vSettings = vBar:GetBarSettings()
	vSettings.CombatAlpha = self.CombatAlphaSlider:GetValue()
	vBar:SetAlpha(vSettings.CombatAlpha)
end

function Outfitter.OutfitBar._SettingsDialog:VerticalCheckbutton_OnClick()
	if self.DisableUpdates then return end
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	local vSettings = vBar:GetBarSettings()
	vSettings.Vertical = not vSettings.Vertical
	self.VerticalCheckbutton:SetChecked(vSettings.Vertical)
	vBar:AdjustAlpha()
	vBar:ChangedOutfits()
end

function Outfitter.OutfitBar._SettingsDialog:LockPositionCheckbutton_OnClick()
	if self.DisableUpdates then return end
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	local vSettings = vBar:GetBarSettings()
	vSettings.LockPosition = not vSettings.LockPosition
	self.LockPositionCheckbutton:SetChecked(vSettings.LockPosition)
	vBar:AdjustAlpha()
end

function Outfitter.OutfitBar._SettingsDialog:HideBackgroundCheckbutton_OnClick()
	if self.DisableUpdates then return end
	local vBar = self.OwnerBar or Outfitter.OutfitBar
	local vSettings = vBar:GetBarSettings()
	vSettings.HideBackground = not vSettings.HideBackground
	self.HideBackgroundCheckbutton:SetChecked(vSettings.HideBackground)
	vBar:ShowBackground(not vSettings.HideBackground)
end

----------------------------------------
-- Slider
----------------------------------------

Outfitter.OutfitBar._SettingsDialog.SliderCount = 0

function Outfitter.OutfitBar._SettingsDialog:NewSlider(pTitle, pMinValue, pMaxValue, pLowText, pHighText, pOnValueChangedFunc)
	-- Generate a name
	
	Outfitter.OutfitBar._SettingsDialog.SliderCount = Outfitter.OutfitBar._SettingsDialog.SliderCount + 1
	
	local vName = "OutfitBarSettingsDialogSlider"..Outfitter.OutfitBar._SettingsDialog.SliderCount
	
	-- Create the slider
	
	local vSlider = CreateFrame("Slider", vName, self, "OptionsSliderTemplate")
	
	vSlider.OnValueChangedFunc = pOnValueChangedFunc
	
	vSlider:SetMinMaxValues(pMinValue, pMaxValue)
	vSlider:SetScript("OnValueChanged", self.Slider_OnValueChanged)
	
	vSlider.Text = getglobal(vName.."Text")
	vSlider.LowText = getglobal(vName.."Low")
	vSlider.HighText = getglobal(vName.."High")
	
	vSlider.Text:SetText(pTitle)
	
	if pLowText then
		vSlider.LowText:SetText(pLowText)
		vSlider.HighText:SetText(pHighText)
	end
	
	return vSlider
end

function Outfitter.OutfitBar._SettingsDialog.Slider_OnValueChanged(self)
	self.OnValueChangedFunc(self:GetParent())
end

----------------------------------------
-- Checkbutton
----------------------------------------

Outfitter.OutfitBar._SettingsDialog.CheckbuttonCount = 0

function Outfitter.OutfitBar._SettingsDialog:NewCheckbutton(pTitle, pOnClickFunction)
	-- Generate a name
	
	Outfitter.OutfitBar._SettingsDialog.CheckbuttonCount = Outfitter.OutfitBar._SettingsDialog.CheckbuttonCount + 1
	
	local vName = "OutfitBarSettingsDialogCheckbuttom"..Outfitter.OutfitBar._SettingsDialog.CheckbuttonCount
	
	-- Create the button
	
	local vCheckbutton = CreateFrame("Checkbutton", vName, self, "OutfitterCheckboxTemplate")
	
	vCheckbutton.OnClickFunction = pOnClickFunction
	vCheckbutton:SetScript("OnClick", self.Checkbutton_OnClick)
	vCheckbutton.Text = getglobal(vName.."Text")
	vCheckbutton.Text:SetText(pTitle)

	return vCheckbutton
end

function Outfitter.OutfitBar._SettingsDialog.Checkbutton_OnClick(self)
	self.OnClickFunction(self:GetParent())
end

----------------------------------------
Outfitter.OutfitBar._DragBar = {}
----------------------------------------

function Outfitter.OutfitBar._DragBar:New(pOutfitBar)
	local vDragBar = CreateFrame("Button")
	
	Outfitter:ConstructFrame(vDragBar, self, pOutfitBar)
	
	return vDragBar
end

function Outfitter.OutfitBar._DragBar:Construct(pOutfitBar)
	self.OutfitBar = pOutfitBar
	self.TextureOffsetX = 0
	self.TextureOffsetY = 0
	
	self:SetParent(UIParent)
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown")

	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetMovable(true)
	self:SetAlpha(0)
	
	self.DragTexture = self:CreateTexture(nil, "ARTWORK")
	
	self:SetScript("OnEnter", function (self) self.OutfitBar:ShowDragBars(true) end)
	self:SetScript("OnLeave", function (self) self.OutfitBar:HideDragBars(true) end)
	self:SetScript("OnDragStart", function (self) self:OnDragStart() end)
	self:SetScript("OnDragStop", function (self) self:OnDragStop() end)
	self:SetScript("OnMouseUp", function (self) self:OnDragStop() end)
	self:SetScript("OnMouseDown", function (self) self:OnMouseDown() end)
	self:SetScript("OnClick", function (self, button) self.OutfitBar:DragBar_OnClick(button) end)
end

function Outfitter.OutfitBar._DragBar:SetTextureOffset(pOffsetX, pOffsetY)
	self.TextureOffsetX = pOffsetX
	self.TextureOffsetY = pOffsetY
	
	self:SetVerticalOrientation(self.Vertical)
end

function Outfitter.OutfitBar._DragBar:OnMouseDown()
	Outfitter:FrameMouseDown(self.OutfitBar.DragBar1)
end

function Outfitter.OutfitBar._DragBar:OnDragStart()
	if not self.OutfitBar:GetBarSettings().LockPosition then
		Outfitter:StartMovingFrame(self.OutfitBar.DragBar1)
	else
		Outfitter:ErrorMessage(Outfitter.cPositionLockedError)
	end
end

function Outfitter.OutfitBar._DragBar:OnDragStop()
	if not self.OutfitBar:GetBarSettings().LockPosition then
		Outfitter:StopMovingFrame(self.OutfitBar.DragBar1)
		self.OutfitBar:PositionChanged()
	end
end

function Outfitter.OutfitBar._DragBar:SetVerticalOrientation(pVertical)
	self.Vertical = pVertical
	
	if pVertical then
		self:SetWidth(53)
		self:SetHeight(12)
		
		self.DragTexture:SetWidth(0)
		self.DragTexture:SetHeight(15)
		
		self.DragTexture:ClearAllPoints()
		self.DragTexture:SetPoint("TOPLEFT", self, "TOPLEFT", self.TextureOffsetX, self.TextureOffsetY)
		self.DragTexture:SetPoint("TOPRIGHT", self, "TOPRIGHT", self.TextureOffsetX - 3, self.TextureOffsetY)
		
		self.DragTexture:SetTexture("Interface\\Addons\\Outfitter\\Textures\\TopDragHandle")
		self.DragTexture:SetTexCoord(0, 0.78125, 0, 0.46875)
	else
		self:SetWidth(10)
		self:SetHeight(53)
		
		self.DragTexture:SetWidth(15)
		self.DragTexture:SetHeight(0)
		
		self.DragTexture:ClearAllPoints()
		self.DragTexture:SetPoint("TOPLEFT", self, "TOPLEFT", self.TextureOffsetX, self.TextureOffsetY - 1)
		self.DragTexture:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.TextureOffsetX, self.TextureOffsetY + 4)
		
		self.DragTexture:SetTexture("Interface\\Addons\\Outfitter\\Textures\\LeftDragHandle")
		self.DragTexture:SetTexCoord(0, 0.46875, 0, 0.75)
	end
end

function Outfitter:LBFSkinCallback(pSkinID, pGloss, pBackdrop, pGroup, pButton, pColors)
	if not self.Settings.LBFSettings then
		self.Settings.LBFSettings = {}
	end
	
	self.Settings.LBFSettings.SkinID = pSkinID
	self.Settings.LBFSettings.Gloss = pGloss
	self.Settings.LBFSettings.Backdrop = pBackdrop
	self.Settings.LBFSettings.Colors = pColors
end
