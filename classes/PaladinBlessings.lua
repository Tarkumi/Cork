
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end


local Cork = Cork
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local blist = {npc = true, vehicle = true}

local MIGHT, _, MIGHTICON = GetSpellInfo(19740)
local WISDOM, _, WISDOMICON = GetSpellInfo(19742)
local SANC, _, SANCICON = GetSpellInfo(20911)
local KINGS, _, KINGSICON = GetSpellInfo(20217)
local GMIGHT, GWISDOM, GSANC, GKINGS = GetSpellInfo(25782), GetSpellInfo(25898), GetSpellInfo(25899), GetSpellInfo(25894)


local blessings = {[MIGHT] = GMIGHT, [WISDOM] = GWISDOM, [SANC] = GSANC, [KINGS] = GKINGS}
local icons = {[MIGHT] = MIGHTICON, [WISDOM] = WISDOMICON, [SANC] = SANCICON, [KINGS] = KINGSICON}
local known = {}
for blessing,greater in pairs(blessings) do known[blessing], known[greater] = GetSpellInfo(blessing), GetSpellInfo(greater) end


local function RefreshKnownSpells()
	for blessing,greater in pairs(blessings) do -- Refresh in case the player has learned this since login
		if known[blessing] == nil then known[blessing] = GetSpellInfo(blessing) end
		if known[greater] == nil then known[greater] = GetSpellInfo(greater) end
	end
end


local function HasMyBlessing(unit)
	for blessing,greater in pairs(blessings) do
		local name, _, _, _, _, _, _, isMine = UnitAura(unit, greater)
		if name and isMine then return true end
		local name, _, _, _, _, _, _, isMine = UnitAura(unit, blessing)
		if name and isMine then return true end
	end
end


local defaults = Cork.defaultspc
defaults["Blessings-enabled"] = true
defaults["Blessings-PRIEST"] = WISDOM
defaults["Blessings-SHAMAN"] = WISDOM
defaults["Blessings-MAGE"] = WISDOM
defaults["Blessings-WARLOCK"] = WISDOM
defaults["Blessings-DRUID"] = WISDOM
defaults["Blessings-PALADIN"] = MIGHT
defaults["Blessings-HUNTER"] = MIGHT
defaults["Blessings-ROGUE"] = MIGHT
defaults["Blessings-WARRIOR"] = MIGHT
defaults["Blessings-DEATHKNIGHT"] = MIGHT


local dataobj = ldb:NewDataObject("Cork Blessings", {type = "cork"})


local function Test(unit)
	if not Cork.dbpc["Blessings-enabled"] or blist[unit] or
		not UnitExists(unit) or (UnitIsPlayer(unit) and not UnitIsConnected(unit))
		or Cork.petunits[unit]
		or (unit ~= "player" and UnitIsUnit(unit, "player"))
		or (unit == "target" and (not UnitIsPlayer(unit) or UnitIsEnemy("player", unit)))
		or (unit == "focus" and not UnitCanAssist("player", unit)) then return end

	if not HasMyBlessing(unit) then
		local _, class = UnitClass(unit)
		local spell = Cork.dbpc["Blessings-"..class]
		local icon = icons[spell]
		return IconLine(icon, UnitName(unit), class)
	end
end
ae.RegisterEvent("Cork Blessings", "UNIT_AURA", function(event, unit) dataobj[unit] = Test(unit) end)
ae.RegisterEvent("Cork Blessings", "PARTY_MEMBERS_CHANGED", function() for i=1,4 do dataobj["party"..i], dataobj["partypet"..i] = Test("party"..i), Test("partypet"..i) end end)
ae.RegisterEvent("Cork Blessings", "RAID_ROSTER_UPDATE", function() for i=1,40 do dataobj["raid"..i], dataobj["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end end)
ae.RegisterEvent("Cork Blessings", "UNIT_PET", function(event, unit) dataobj[Cork.petmappings[unit]] = Test(Cork.petmappings[unit]) end)
ae.RegisterEvent("Cork Blessings", "PLAYER_TARGET_CHANGED", function() dataobj.target = Test("target") end)
ae.RegisterEvent("Cork Blessings", "PLAYER_FOCUS_CHANGED", function() dataobj.focus = Test("focus") end)


function dataobj:Scan()
	self.target, self.focus= Test("target"), Test("focus")
	self.player, self.pet = Test("player"), Test("pet")
	for i=1,GetNumPartyMembers() do self["party"..i], self["partypet"..i] = Test("party"..i), Test("partypet"..i) end
	for i=1,GetNumRaidMembers() do self["raid"..i], self["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end
end


function dataobj:CorkIt(frame)
	RefreshKnownSpells()
	for unit in ldb:pairs(self) do
		if not Cork.keyblist[unit] then
			local _, class = UnitClass(unit)
			local spell = Cork.dbpc["Blessings-"..class]
			local greater = blessings[spell]
			if known[greater] and SpellCastableOnUnit(greater, unit) then return frame:SetManyAttributes("type1", "spell", "spell", greater, "unit", unit) end
			if known[spell] and SpellCastableOnUnit(spell, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", unit) end
		end
	end
end


----------------------
--      Config      --
----------------------

local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")

local frame = CreateFrame("Frame", nil, UIParent)
frame.name = "Blessings"
frame.parent = "Cork"
frame:Hide()

frame:SetScript("OnShow", function()
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork - Blessings", "These settings are saved on a per-char basis.")

	local enabled = tekcheck.new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	enabled.tiptext = "Toggle this module."
	local checksound = enabled:GetScript("OnClick")
	enabled:SetScript("OnClick", function(self)
		checksound(self)
		Cork.dbpc["Blessings-enabled"] = not Cork.dbpc["Blessings-enabled"]
		dataobj:Scan()
	end)


	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 24, 2, 4
	local BUFFS = {SANC, KINGS, WISDOM, MIGHT}

	local function OnClick(self)
		Cork.dbpc["Blessings-"..self.token] = self.buff
		for _,butt in pairs(self.buffbuttons) do butt:SetChecked(butt == self) end
		dataobj:Scan()
	end

	local rows, anchor = {}
	for _,token in pairs(CLASS_SORT_ORDER) do
		local class = Cork.classnames[token]

		local row = CreateFrame("Frame", nil, frame)
		if not anchor then row:SetPoint("TOP", enabled, "BOTTOM", 0, -16)
		else row:SetPoint("TOP", anchor, "BOTTOM", 0, -ROWGAP) end
		row:SetPoint("LEFT", EDGEGAP, 0)
		row:SetPoint("RIGHT", -EDGEGAP, 0)
		row:SetHeight(ROWHEIGHT)
		rows[token], anchor = row, row


		local name = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		name:SetPoint("LEFT", 4, 0)
		name:SetText("|cff".. Cork.colors[token].. class)

		local lasticon
		row.buffbuttons = {}
		for i,buff in ipairs(BUFFS) do
			local butt = CreateFrame("CheckButton", nil, row)
			butt:SetWidth(ROWHEIGHT) butt:SetHeight(ROWHEIGHT)

			local tex = butt:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints()
			tex:SetTexture(icons[buff])
			butt.icon = tex

			butt:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
			butt:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
			butt:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")

			if not lasticon then butt:SetPoint("RIGHT", -ROWGAP, 0)
			else butt:SetPoint("RIGHT", lasticon, "LEFT", -ROWGAP, 0) end

			butt.token, butt.buff, butt.buffbuttons = token, buff, row.buffbuttons
			butt:SetScript("OnClick", OnClick)

			row.buffbuttons[buff], lasticon = butt, butt
		end
	end

	local function Update(self)
		RefreshKnownSpells()
		enabled:SetChecked(Cork.dbpc["Blessings-enabled"])

		for token,row in pairs(rows) do
			for buff,butt in pairs(row.buffbuttons) do
				butt:SetChecked(Cork.dbpc["Blessings-"..token] == buff)
				if known[buff] then
					butt:Enable()
					butt.icon:SetVertexColor(1.0, 1.0, 1.0)
				else
					butt:Disable()
					butt.icon:SetVertexColor(0.4, 0.4, 0.4)
				end
			end
		end
	end

	frame:SetScript("OnShow", Update)
	Update(frame)
end)

InterfaceOptions_AddCategory(frame)

