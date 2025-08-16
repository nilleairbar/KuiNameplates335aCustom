--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
-- Frame element creation/update functions
-- Backported by: Kader at https://github.com/bkader
]]
local addon = LibStub("AceAddon-3.0"):GetAddon("KuiNameplates")
local kui = LibStub("Kui-1.0")

local side_coords = {
	left = {0, .04, 0, 1},
	right = {.96, 1, 0, 1},
	top = {.05, .95, 0, .24},
	bottom = {.05, .95, .76, 1}
}

local function ScanUnitTooltip2ndLine(unit)
	CreateFrame("GameTooltip", "ScanningGameTooltip", nil, "GameTooltipTemplate")
    ScanningGameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")  
	ScanningGameTooltip:ClearLines()
	ScanningGameTooltip:SetUnit(unit)                       -- Set the tooltip to the specified unit
    ScanningGameTooltip:Show()

    local i=1
    while _G["ScanningGameTooltipTextLeft" .. i] do
        local text = _G["ScanningGameTooltipTextLeft" .. i]:GetText()
        if text and text ~= "" then print(text) end
        i = i + 1
    end

--[[ 	local output1			                    -- Show the tooltip
    -- Check if the second line exists
    local secondLineText = _G["ScanningGameTooltipTextLeft2"]:GetText()
	if secondLineText and text ~= "" then
		if not string.match(secondLineText, "Level") then  -- Get the second line text
			output1 = secondLineText
		end						-- Output the second line text to the chat
    end                       -- Output the tooltip text to the chat
 ]]
	GameTooltip:Hide()                              -- Hide the tooltip after scanning

	return output1
end

------------------------------------------------------------------ Background --
function addon:CreateBackground(frame, f)
	-- frame glow
	f.bg = {sides = {}}

	-- solid background
	f.bg.fill = f:CreateTexture(nil, "ARTWORK", nil, 1)
	f.bg.fill:SetTexture(kui.m.t.solid)
	f.bg.fill:SetVertexColor(0, 0, 0, .8)

	-- create frame glow sides
	-- not using frame backdrop as it seems to cause a lot of lag on frames
	-- which update very often (such as nameplates)
	for side, coords in pairs(side_coords) do
		f.bg.sides[side] = f:CreateTexture(nil, "ARTWORK", nil, 0)
		side = f.bg.sides[side]

		side:SetTexture("Interface\\AddOns\\Kui_Nameplates\\Media\\FrameGlow")
		side:SetTexCoord(unpack(coords))
	end

	local of = self.sizes.frame.bgOffset + 1

	f.bg.sides.top:SetPoint("BOTTOMLEFT", f.bg.fill, "TOPLEFT", 1, -1)
	f.bg.sides.top:SetPoint("BOTTOMRIGHT", f.bg.fill, "TOPRIGHT", -1, -1)
	f.bg.sides.top:SetHeight(of)

	f.bg.sides.bottom:SetPoint("TOPLEFT", f.bg.fill, "BOTTOMLEFT", 1, 1)
	f.bg.sides.bottom:SetPoint("TOPRIGHT", f.bg.fill, "BOTTOMRIGHT", -1, 1)
	f.bg.sides.bottom:SetHeight(of)

	f.bg.sides.left:SetPoint("TOPRIGHT", f.bg.sides.top, "TOPLEFT")
	f.bg.sides.left:SetPoint("BOTTOMRIGHT", f.bg.sides.bottom, "BOTTOMLEFT")
	f.bg.sides.left:SetWidth(of)

	f.bg.sides.right:SetPoint("TOPLEFT", f.bg.sides.top, "TOPRIGHT")
	f.bg.sides.right:SetPoint("BOTTOMLEFT", f.bg.sides.bottom, "BOTTOMRIGHT")
	f.bg.sides.right:SetWidth(of)

	function f.bg:SetVertexColor(r, g, b, a)
		for _, side in pairs(self.sides) do
			side:SetVertexColor(r, g, b, a)
		end
	end
	function f.bg:Hide()
		self.fill:Hide()
		for _, side in pairs(self.sides) do
			side:Hide()
		end
	end
	function f.bg:Show()
		self.fill:Show()
		for _, side in pairs(self.sides) do
			side:Show()
		end
	end
end
function addon:UpdateBackground(f, trivial)
	f.bg.fill:ClearAllPoints()

	if trivial then
		-- switch to trivial sizes
		f.bg.fill:SetSize(self.sizes.frame.twidth, self.sizes.frame.theight)
		f.bg.fill:SetPoint("BOTTOMLEFT", f.x, f.y)
	elseif not trivial then
		-- switch back to normal sizes
		f.bg.fill:SetSize(self.sizes.frame.width, self.sizes.frame.height)
		f.bg.fill:SetPoint("BOTTOMLEFT", f.x, f.y)
	end
end
------------------------------------------------------------------ Health bar --
function addon:CreateHealthBar(frame, f)
	f.health = CreateFrame("StatusBar", nil, f)
	f.health:SetFrameLevel(1)
	f.health:SetStatusBarTexture(addon.bartexture)
	f.health.percent = 100

	f.health:GetStatusBarTexture():SetDrawLayer("ARTWORK", -8)

	if self.SetValueSmooth then
		f.health.OrigSetValue = f.health.SetValue
		f.health.SetValue = self.SetValueSmooth
	elseif self.CutawayBar then
		self.CutawayBar(f.health)
	end
end

function addon:CreateHealthBarBorder(frame, f)
	f.healthbarBorder = CreateFrame("Frame", nil, f)
	f.healthbarBorder:SetPoint("CENTER", f.health, 0, 0)
	f.healthbarBorder:SetSize(160, 20)

	f.healthbarBorder.tex = f.healthbarBorder:CreateTexture()
	f.healthbarBorder.tex:SetDrawLayer("OVERLAY")
	f.healthbarBorder.tex:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\borders\\healthbar")
	f.healthbarBorder.tex:SetAllPoints()
	f.healthbarBorder.tex:SetSize(160, 20)
	f.healthbarBorder.tex:SetVertexColor(0.75, 0.6, 0, 1)
end

function addon:UpdateHealthBar(f, trivial)
	f.health:ClearAllPoints()

	if trivial then
		f.health:SetSize(self.sizes.frame.twidth - 2, self.sizes.frame.theight - 2)
	elseif not trivial then
		f.health:SetSize(self.sizes.frame.width - 2, self.sizes.frame.height - 2)
	end

	f.health:SetPoint("BOTTOMLEFT", f.x + 1, f.y + 1)
end
------------------------------------------------------------------- PowerBar --
--[[ function addon:CreatePowerBar(frame, f)
	f.powerbar = CreateFrame("StatusBar", nil, f)
	f.powerbar:SetFrameLevel(1)
	f.powerbar:SetStatusBarTexture(addon.bartexture)

	f.powerbar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -8)

	if self.SetValueSmooth then
		f.powerbar.OrigSetValue = f.powerbar.SetValue
		f.powerbar.SetValue = self.SetValueSmooth
	elseif self.CutawayBar then
		self.CutawayBar(f.powerbar)
	end
end

function addon:CreatePowerBarBorder(frame, f)
	f.powerbarBorder = CreateFrame("Frame", nil, I)
	f.powerbarBorder:SetPoint("CENTER", f.healthbarBorder, 0, -20)
	f.powerbarBorder:SetSize(160, 20)

	f.powerbarBorder.tex = f.powerbarBorder:CreateTexture()
	f.powerbarBorder.tex:SetDrawLayer("OVERLAY")
	f.powerbarBorder.tex:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\borders\\powerbar")
	f.powerbarBorder.tex:SetAllPoints()
	f.powerbarBorder.tex:SetSize(160, 20)
	f.powerbarBorder.tex:SetVertexColor(0.75, 0.6, 0, 1)
end ]]

function addon:UpdatePowerBar(f, trivial)
	f.power:ClearAllPoints()

	if trivial then
		f.power:SetSize(self.sizes.frame.twidth / 2 - 2, self.sizes.frame.theight / 2 - 2)
	elseif not trivial then
		f.power:SetSize(self.sizes.frame.width / 2 - 2, self.sizes.frame.height / 2 - 2)
	end

	f.power:SetPoint("BOTTOMLEFT", f.x + 1, f.y + 1)
end

------------------------------------------------------------------- Highlight --
function addon:CreateHighlight(frame, f)
	if not self.db.profile.general.highlight then
		return
	end

	f.highlight = f.overlay:CreateTexture(nil, "ARTWORK")
	f.highlight:SetTexture(addon.bartexture)
	f.highlight:SetAllPoints(f.health)

	f.highlight:SetVertexColor(1, 1, 1)
	f.highlight:SetBlendMode("ADD")
	f.highlight:SetAlpha(.4)
	f.highlight:Hide()
end
----------------------------------------------------------------- Health text --
function addon:CreateHealthText(frame, f)
	f.health.p = f:CreateFontString(f.overlay, {
		font = self.font,
		size = "health",
		alpha = 1,
		outline = "OUTLINE"
	})

	f.health.p:SetHeight(10)
	f.health.p:SetJustifyH("RIGHT")
	f.health.p:SetJustifyV("MIDDLE")
	f.health.p.osize = "health" -- original font size used to update/restore

	f.health.p:SetTextColor(0.9, 0.85, 0, 1)

	if self.db.profile.hp.text.mouseover then
		f.health.p:Hide()
	end
end
function addon:UpdateHealthText(f, trivial)
	if trivial then
		f.health.p:Hide()
	else
		if not self.db.profile.hp.text.mouseover then
			f.health.p:Show()
		end

		local anch2, anch1 = self.db.profile.text.healthanchorpoint or "BOTTOMRIGHT", ""

		if anch2:find("BOTTOM") then
			anch1 = "TOP"
			f.health.p:SetJustifyV("BOTTOM")
		elseif anch2:find("TOP") then
			anch1 = "BOTTOM"
			f.health.p:SetJustifyV("TOP")
		else
			f.health.p:SetJustifyV("MIDDLE")
		end

		if anch2:find("LEFT") then
			anch1 = anch1 .. "LEFT"
			f.health.p:SetJustifyH("LEFT")
		elseif anch2:find("RIGHT") then
			anch1 = anch1 .. "RIGHT"
			f.health.p:SetJustifyH("RIGHT")
		end

		f.health.p:ClearAllPoints()
		f.health.p:SetPoint(anch1, f.health, anch2, self.db.profile.text.healthoffsetx or 0, self.db.profile.text.healthoffsety or 0)
	end
end
------------------------------------------------------------------ Level text --

function addon:CreateLevelBorder(frame, f)
	if not f.level then
		return
	end
	f.levelBorder = CreateFrame("Frame", nil, f.healthbarBorder)
	f.levelBorder:SetPoint("RIGHT", f.healthbarBorder, 22, 0)
	f.levelBorder:SetSize(40, 40)
	--f.levelBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	f.levelBorder:SetBackdrop({bgFile = kui.m.t.solid,

                                edgeFile = "",
                                tile = false,
                                insets = { left = 10, right = 10, top = 12, bottom = 12}})
	f.levelBorder:SetBackdropColor(0.25, 0.1, 0, 1)

	f.levelBorder.tex = f.levelBorder:CreateTexture()
	f.levelBorder.tex:SetDrawLayer("OVERLAY")
	f.levelBorder.tex:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\borders\\level")
	--f.levelBorder.tex:SetPoint("RIGHT", f.healthbarBorder)
	f.levelBorder.tex:SetAllPoints()
	f.levelBorder.tex:SetSize(40, 40)
	f.levelBorder.tex:SetVertexColor(f.healthbarBorder.tex:GetVertexColor())
end

function addon:CreatePortrait(frame, f)
	f.portrait2 = CreateFrame("Frame", nil, f.healthbarBorder)
	f.portrait2:SetPoint("LEFT", f.healthbarBorder, -22, 0)
	f.portrait2:SetSize(40, 40)

	f.portrait2.tex = f.portrait2:CreateTexture()
	f.portrait2.tex:SetDrawLayer("ARTWORK")
	--print(f.portrait2.tex:GetDrawLayer())
	f.portrait2.tex:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\borders\\portrait")
	f.portrait2.tex:SetAllPoints()
	f.portrait2.tex:SetSize(40, 40)
	f.portrait2.tex:SetVertexColor(f.healthbarBorder.tex:GetVertexColor())

	f.portrait = CreateFrame("Frame", nil, f.portrait2)
	f.portrait:SetPoint("CENTER", f.portrait2, 0, 0)
	f.portrait:SetSize(22,22)

	f.portrait.tex = f.portrait:CreateTexture()
	f.portrait.tex:SetSize(22,22)
	f.portrait.tex:SetAllPoints(f.portrait)
	f.portrait.tex:SetDrawLayer("BACKGROUND")
	f.portrait.tex:SetBlendMode("ALPHAKEY")
	SetPortraitTexture(f.portrait.tex, "nameplate1")

	f.portrait.tex:Show()
end

function addon:CreateElite(frame, f)
	f.elite = CreateFrame("Frame", nil, f.healthbarBorder)
	f.elite:SetPoint("LEFT", f.healthbarBorder, -36, -1)
	f.elite:SetSize(60,60)

	f.elite.tex = f.elite:CreateTexture()
	f.elite.tex:SetDrawLayer("OVERLAY", 2)
	f.elite.tex:SetAllPoints()
	f.elite.tex:SetSize(60, 60)
	f.elite.tex:Hide()
end

function addon:UpdateElite(frame, f, status)
	local texture
	if status == "boss" then
		texture = "Interface\\AddOns\\ClassicPlatesPlus\\media\\classifications\\worldboss"
		f.elite.tex:Show()
	elseif status == "elite" then
		texture = "Interface\\AddOns\\ClassicPlatesPlus\\media\\classifications\\elite"
				f.elite.tex:Show()
	elseif status == "rare" then
		texture = "Interface\\AddOns\\ClassicPlatesPlus\\media\\classifications\\rare"
		f.elite.tex:Show()
	else 
		texture = ""
		f.elite.tex:Hide()
	end
	f.elite.tex:SetTexture(texture)
end

function addon:UpdatePortrait(frame, f, unit)
	--f.portrait.tex:Show()
	--print("Portraits updating!")
	SetPortraitTexture(f.portrait.tex, "nameplate1")
end

function addon:CreateLevel(frame, f)
	if not f.level then
		return
	end

	f.level = f:CreateFontString(f.level, {
		reset = true,
		font = self.font,
		size = "level",
		alpha = 1,
		outline = "OUTLINE"
	})

	f.level:SetParent(f.levelBorder)
	f.level:SetAllPoints(f.levelBorder)
	f.level:SetJustifyH("MIDDLE")
	f.level:SetJustifyV("MIDDLE")
	f.level:SetHeight(13)
	f.level:ClearAllPoints()
	f.level.osize = "level" -- original font size used to update/restore

	if self.db.profile.text.level then
		f.level.enabled = true
	end
end
function addon:UpdateLevel(f, trivial)
	if trivial then
		f.level:Hide()
		f.levelBorder:Hide()
	else
		--hide all the stuff for anchoring the level to anything but the border
--[[ 		local anch2, anch1 = self.db.profile.text.levelanchorpoint or "BOTTOMLEFT", ""

		if anch2:find("BOTTOM") then
			f.level:SetJustifyV("BOTTOM")
			anch1 = "TOP"
		elseif anch2:find("TOP") then
			f.level:SetJustifyV("TOP")
			anch1 = "BOTTOM"
		else
			f.level:SetJustifyV("MIDDLE")
		end

		if anch2:find("LEFT") then
			anch1 = anch1 .. "LEFT"
			f.level:SetJustifyH("LEFT")
		elseif anch2:find("RIGHT") then
			anch1 = anch1 .. "RIGHT"
			f.level:SetJustifyH("RIGHT")
		end ]]

		f.level:ClearAllPoints()
		f.level:SetPoint("CENTER", f.levelBorder, "CENTER", 1, 1)
	end
end
------------------------------------------------------------------- Name text --
function addon:CreateName(frame, f)
	f.name = f:CreateFontString(f.overlay, {
		font = self.font,
		size = "name",
		outline = "OUTLINE"
	})

	f.name.osize = "name" -- original font size used to update/restore
	f.name:SetHeight(10)
end
function addon:CreateOccupation(frame, f, unit)
	f.occupation = f:CreateFontString(f.overlay, {
	font = self.font,
	size = "small",
	outline = "OUTLINE"
	})

	f.occupation.osize = "small" -- original font size used to update/restore
	f.occupation:SetHeight(10)

	f.occupation:ClearAllPoints()
	f.occupation:SetWidth(0)

	f.occupation:SetPoint("TOP", f.name, "BOTTOM", 0, -4)
	f.occupation:SetTextColor(0.75,0.75,0.75,1)
	--addon:UpdateOccupation(f, unit)
end
function addon:UpdateName(f, trivial)
	f.name:ClearAllPoints()
	f.name:SetWidth(0)

	local r, g, b = f.oldHealth:GetStatusBarColor()
	if g > 0.9 and r == 0 and b == 0 then 
			r, g, b = unpack(self.db.profile.hp.reactioncolours.friendlycol)
		elseif r > 0.9 and g == 0 and b == 0 then
			-- enemy NPC
			f.friend = nil
			r, g, b = unpack(self.db.profile.hp.reactioncolours.hatedcol)
		elseif (r + g) > 1.8 and b == 0 then
			-- neutral NPC
			f.friend = nil
			r, g, b = unpack(self.db.profile.hp.reactioncolours.neutralcol)
		elseif r < 0.6 and (r + g) == (r + b) then
			-- tapped NPC
			-- keep previous self.friend value
			f.tapped = true
			r, g, b = unpack(self.db.profile.hp.reactioncolours.tappedcol)
		else
			-- enemy player, use default UI colour
			f.friend = nil
			f.player = true
		end
	f.name:SetVertexColor(r,g,b)

	local anch2, anch1 = self.db.profile.text.nameanchorpoint or "TOP", ""
	if anch2 == "BOTTOM" then
		anch1 = "TOP"
		f.name:SetJustifyV("TOP")
		f.name:SetJustifyH("CENTER")
	elseif anch2 == "TOP" then
		anch1 = "BOTTOM"
		f.name:SetJustifyV("BOTTOM")
		f.name:SetJustifyH("CENTER")
	elseif anch2 == "LEFT" then
		anch1 = "RIGHT"
		f.name:SetJustifyV("MIDDLE")
		f.name:SetJustifyH("RIGHT")
	elseif anch2 == "RIGHT" then
		anch1 = "LEFT"
		f.name:SetJustifyV("MIDDLE")
		f.name:SetJustifyH("LEFT")
	end

	f.name:SetPoint(anch1, f.health, anch2, self.db.profile.text.nameoffsetx or 2.5, self.db.profile.text.nameoffsety or 0)
	if trivial then
		f.name:SetWidth(addon.sizes.frame.twidth * 2)
	else
		f.name:SetWidth(addon.sizes.frame.width * 2)
	end
end

function addon:UpdateOccupation(f, unit)
	if f.occupation:GetText() == nil then
		local occupation = ScanUnitTooltip2ndLine(unit)
		if occupation ~= nil then
			f.occupation:SetText('<'..occupation..'>')
				if GetGuildInfo("player") == occupation then
					f.occupation:SetTextColor(0.2,0.5,0.9,1)

				end
			f.occupation:Show()
		end
	end
end
----------------------------------------------------------------- Target glow --
function addon:CreateTargetGlow(f)
	f.targetGlow = f.health:CreateTexture(nil, "BACKGROUND")
	f.targetGlow:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\highlights\\healthbar")
	--f.targetGlow:SetTexCoord(0, .593, 0, .875)
	f.targetGlow:SetPoint("CENTER", f.health, "CENTER", 0, 0)
	f.targetGlow:SetVertexColor(unpack(self.db.profile.general.targetglowcolour))
	f.targetGlow:SetSize(160,40)
	f.targetGlow:Hide()
	f.targetGlowLevel = f.levelBorder:CreateTexture(nil, "BACKGROUND")
	f.targetGlowLevel:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\highlights\\level")
	--f.targetGlow:SetTexCoord(0, .593, 0, .875)
	f.targetGlowLevel:SetPoint("CENTER", f.levelBorder, "CENTER", 0, 0)
	f.targetGlowLevel:SetVertexColor(unpack(self.db.profile.general.targetglowcolour))
	f.targetGlowLevel:SetSize(40,40)
	f.targetGlowLevel:Hide()
	f.targetGlowPortrait = f.portrait2:CreateTexture(nil, "BACKGROUND")
	f.targetGlowPortrait:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\highlights\\portrait")
	--f.targetGlow:SetTexCoord(0, .593, 0, .875)
	f.targetGlowPortrait:SetPoint("CENTER", f.portrait2, "CENTER", 0, 0)
	f.targetGlowPortrait:SetVertexColor(unpack(self.db.profile.general.targetglowcolour))
	f.targetGlowPortrait:SetSize(40,40)
	f.targetGlowPortrait:Hide()
end
function addon:UpdateTargetGlow(f, trivial)
	if not f.targetGlow then
		return
	end
	if trivial then
		f.targetGlow:SetSize(self.sizes.tex.ttargetGlowW, self.sizes.tex.targetGlowH)
	else
		f.targetGlow:SetSize(self.sizes.tex.targetGlowW, self.sizes.tex.targetGlowH)
		f.targetGlowPortrait:SetSize(self.sizes.tex.targetGlowW * 0.25, self.sizes.tex.targetGlowH)
	end
end
-- raid icon ###################################################################
local PositionRaidIcon = {
	function(f) return f.icon:SetPoint("RIGHT", f.portrait2, "LEFT", 0, 0) end,
	function(f) return f.icon:SetPoint("BOTTOM", f.portrait2, "TOP", 0, 0) end,
	function(f) return f.icon:SetPoint("CENTER", f.portrait2, "CENTER", -1, 0) end,
	function(f) return f.icon:SetPoint("TOP", f.portrait2, "BOTTOM", 0, 0) end
}

function addon:UpdateRaidIcon(f)
	f.icon:SetParent(f.overlay)
	f.icon:SetDrawLayer("OVERLAY")
	f.icon:SetSize(addon.sizes.tex.raidicon, addon.sizes.tex.raidicon)

	f.icon:ClearAllPoints()
	if PositionRaidIcon[addon.db.profile.general.raidicon_side] then
		PositionRaidIcon[addon.db.profile.general.raidicon_side](f)
	else
		PositionRaidIcon[3](f)
	end
end