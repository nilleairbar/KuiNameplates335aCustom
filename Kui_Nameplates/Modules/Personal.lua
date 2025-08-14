--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- Backported by: Kader at https://github.com/bkader
--
-- changes colour of health bars based on health percentage
]]
local addon = LibStub("AceAddon-3.0"):GetAddon("KuiNameplates")
local mod = addon:NewModule("PersonalPlate", addon.Prototype, "AceEvent-3.0")

mod.uiName = "Personal nameplate"

local powerType, currHealthPerc, currPowerPerc, widthHealth, widthPower

mod.personalFrame = CreateFrame("Frame", nil, UIParent)
mod.personalFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
mod.personalFrame:SetSize(300,200)

local function OnDeathEvent(self, event)
	if event == "PLAYER_DEAD" then
		mod.personalHealthText:SetText("Dead")
		mod.personalHealthText:SetVertexColor(1,1,1,1)
		mod.personalHealthPercText:Hide()
		mod.personalPowerText:Hide()
		mod.personalPowerPercText:Hide()
		mod.persHealthSpark:Hide()
		mod.persPowerSpark:Hide()
	elseif event == "PLAYER_UNGHOST" then
		mod.personalHealthText:SetText(tostring(UnitHealth("player")))
		mod.personalHealthText:SetVertexColor(0.9, 0.85, 0, 1)
		mod.personalHealthPercText:Show()
		mod.personalPowerText:Show()
		mod.personalPowerPercText:Show()
		mod.persHealthSpark:Show()
		mod.persPowerSpark:Show()
	end
end

local function PersonalBorder()
	mod.personalBorder = CreateFrame("Frame", nil, mod.personalFrame)
	mod.personalBorder:SetPoint("CENTER", mod.personalFrame, "CENTER", 0, 0)
	mod.personalBorder:SetSize(512, 256)

	mod.personalBorder.tex = mod.personalBorder:CreateTexture()
	mod.personalBorder.tex:SetDrawLayer("ARTWORK")
	mod.personalBorder.tex:SetTexture("Interface\\AddOns\\ClassicPlatesPlus\\media\\borders\\personal")
	mod.personalBorder.tex:SetPoint("CENTER", mod.personalBorder, "CENTER", 0, 0)
	mod.personalBorder.tex:SetSize(220, 110)
	mod.personalBorder.tex:SetVertexColor(0.75, 0.6, 0, 1)

	mod.personalBorder.bg = mod.personalBorder:CreateTexture(nil, "BACKGROUND", nil, 1)
	mod.personalBorder.bg:SetVertexColor(0, 0, 0, 1)
	mod.personalBorder.bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
	mod.personalBorder.bg:ClearAllPoints()
	mod.personalBorder.bg:SetPoint("CENTER", mod.personalBorder, "CENTER", 0, 10)
	mod.personalBorder.bg:SetSize(190,42)
	mod.personalBorder:RegisterEvent("PLAYER_DEAD")
	mod.personalBorder:RegisterEvent("PLAYER_UNGHOST")
	mod.personalBorder:SetScript("OnEvent", OnDeathEvent)
end

local function OnHealthEvent(self, event, unit)
	if unit == "player" then
		local currentValue = UnitHealth("player")
		mod.personalHealth:SetValue(currentValue)
		mod.personalHealthText:SetText(tostring(UnitHealth("player")))

		if self.SetValueSmooth then
		mod.personalHealth.OrigSetValue = mod.personalHealth.SetValue
		mod.personalHealth.SetValue = self.SetValueSmooth
		end

		currHealthPerc = 100 * UnitHealth("player") / UnitHealthMax("player")
		currHealthPerc = math.floor(currHealthPerc)
		mod.personalHealthPercText:SetText(currHealthPerc..'%')
		local xOffset = widthHealth * (currHealthPerc / 100)
		mod.persHealthSpark.tex:SetPoint("CENTER", mod.personalHealth, "LEFT", xOffset + 2, -2)
		if currHealthPerc == 100 then
			mod.persHealthSpark.tex:Hide()
		elseif currPowerPerc == 100 and currHealthPerc == 100 then
			mod.personalFrame:Hide()
		else
			mod.persHealthSpark.tex:Show()
		end
	end
end

local function CreateHealthText(f)
	mod.personalHealthText = mod.personalHealth:CreateFontString(nil, "OVERLAY")
	mod.personalHealthText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE") -- Font path, size, style
	mod.personalHealthText:SetTextColor(0.9, 0.85, 0, 1) -- RGB and Alpha (white color)

	mod.personalHealthText:SetText(tostring(UnitHealth("player")))
	mod.personalHealthText:SetJustifyH("CENTER")
	mod.personalHealthText:SetJustifyV("MIDDLE")

	mod.personalHealthText:SetPoint("CENTER", mod.personalHealth, "CENTER", 0, 1)
end

local function CreateHealthPercText(f)
	mod.personalHealthPercText = mod.personalHealth:CreateFontString(nil, "OVERLAY")
	mod.personalHealthPercText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Font path, size, style
	mod.personalHealthPercText:SetTextColor(0.9, 0.85, 0, 1) -- RGB and Alpha (white color)

	currHealthPerc = 100 * UnitHealth("player") / UnitHealthMax("player")
	currHealthPerc = math.floor(currHealthPerc)

	mod.personalHealthPercText:SetText(currHealthPerc..'%')
	mod.personalHealthPercText:SetJustifyH("LEFT")
	mod.personalHealthPercText:SetJustifyV("MIDDLE")
	mod.personalHealthPercText:SetPoint("LEFT", mod.personalHealth, "LEFT", 2, 1)
end

local function CreateHealthSpark(f)
	mod.persHealthSpark = CreateFrame("Frame", nil, mod.personalHealth)
	widthHealth = mod.personalHealth:GetWidth()
	local xOffset = widthHealth * (currHealthPerc / 100)
	mod.persHealthSpark.tex = mod.persHealthSpark:CreateTexture("BORDER")
	mod.persHealthSpark.tex:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	mod.persHealthSpark.tex:SetPoint("CENTER", mod.personalHealth, "LEFT", xOffset + 2, -2 )
	mod.persHealthSpark.tex:SetBlendMode("ADD")
	mod.persHealthSpark.tex:SetSize(30,60)
	mod.persHealthSpark.tex:SetVertexColor(0.2, 0.8, 0.15, 1)
	mod.persHealthSpark.tex:Hide()

	--local r,g,b = mod.personalHealth:GetVertexColor()
	--mod.persHealthSpark:SetColor(0.85, 0.7, 0, 1)
end

local function CreateHealthBar(f)
	mod.personalHealth = CreateFrame("StatusBar", nil, mod.personalFrame)
	mod.personalHealth:SetStatusBarTexture("interface\\targetingframe\\ui-statusbar")
    mod.personalHealth:SetPoint("TOPLEFT", mod.personalFrame, "TOPLEFT", 56 , -66)
    mod.personalHealth:SetPoint("TOPRIGHT", mod.personalFrame, "TOPRIGHT", -52 , -66)
    mod.personalHealth:SetPoint("BOTTOMLEFT", mod.personalFrame, "TOPLEFT", 56 , -98)
    mod.personalHealth:SetPoint("BOTTOMRIGHT", mod.personalFrame, "TOPRIGHT", -52 , -98)
    mod.personalHealth:SetMinMaxValues(0, UnitHealthMax("player"))
    mod.personalHealth:SetStatusBarColor(0.2, 0.6, 0.1, 1)

	if KuiNameplates.SetValueSmooth then
		mod.personalHealth.OrigSetValue = mod.personalHealth.SetValue
		mod.personalHealth.SetValue = KuiNameplates.SetValueSmooth
	end

	CreateHealthText()
	CreateHealthPercText()
	CreateHealthSpark()
	mod.personalHealth:GetStatusBarTexture():SetDrawLayer("BORDER", -8)
	mod.personalHealth:RegisterEvent("UNIT_HEALTH")
	mod.personalHealth:RegisterEvent("wa")
	mod.personalHealth:SetScript("OnEvent", OnHealthEvent)
end

local function OnPowerEvent(self, event, unit)
	if unit == "player" then
		local currentValue = UnitPower("player")
		mod.personalPower:SetValue(currentValue)

		mod.personalPowerText:SetText(tostring(UnitPower("player")))

		currPowerPerc = 100 * UnitPower("player") / UnitPowerMax("player")
		currPowerPerc = math.floor(currPowerPerc)
		mod.personalPowerPercText:SetText(currPowerPerc..'%')
		local xOffset = widthPower * (currPowerPerc / 100)
		mod.persPowerSpark.tex:SetPoint("CENTER", mod.personalPower, "LEFT", xOffset + 2, -2 )
		if currPowerPerc == 100 and currHealthPerc == 100 then
			mod.persPowerSpark.tex:Hide()
		else
			mod.persPowerSpark.tex:Show()
		end
	end
end

local function CreatePowerText(f)
	mod.personalPowerText = mod.personalPower:CreateFontString(nil, "OVERLAY")
	mod.personalPowerText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Font path, size, style
	mod.personalPowerText:SetTextColor(0.9, 0.85, 0, 1) -- RGB and Alpha (white color)

	mod.personalPowerText:SetText(tostring(UnitPower("player")))

	local width = mod.personalPowerText:GetStringWidth()
	mod.personalPowerText:SetPoint("CENTER", mod.personalPower, "CENTER", 0, -1)
end

local function CreateHealthPercText(f)
	mod.personalPowerPercText = mod.personalPower:CreateFontString(nil, "OVERLAY")
	mod.personalPowerPercText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Font path, size, style
	mod.personalPowerPercText:SetTextColor(0.9, 0.85, 0, 1) -- RGB and Alpha (white color)

	currPowerPerc = 100 * UnitPower("player") / UnitPowerMax("player")
	currPowerPerc = math.floor(currPowerPerc)

	mod.personalPowerPercText:SetText(currPowerPerc..'%')	
	mod.personalPowerPercText:SetPoint("LEFT", mod.personalPower, "LEFT", 2, -1)
end

local function CreatePowerSpark(f)
	mod.persPowerSpark = CreateFrame("Frame", nil, mod.personalPower)
	widthPower = mod.personalPower:GetWidth()
	local xOffset = widthPower * (currPowerPerc / 100)
	mod.persPowerSpark.tex = mod.persPowerSpark:CreateTexture("BORDER")
	mod.persPowerSpark.tex:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	mod.persPowerSpark.tex:SetPoint("CENTER", mod.personalPower, "LEFT", xOffset + 2, - 2)
	mod.persPowerSpark.tex:SetBlendMode("ADD")
	mod.persPowerSpark.tex:SetSize(20,40)
	mod.persPowerSpark.tex:SetVertexColor(0.4, 0.6, 1, 1)
	mod.persPowerSpark.tex:Hide()
end

local function CreatePowerBar(f)
	mod.personalPower = CreateFrame("StatusBar", nil, mod.personalFrame)
	mod.personalPower:SetStatusBarTexture("interface\\targetingframe\\ui-statusbar")
    --mod.personalHealth:SetSize(200,30)
    mod.personalPower:SetPoint("TOPLEFT", mod.personalFrame, "TOPLEFT", 56 , -94)
    mod.personalPower:SetPoint("TOPRIGHT", mod.personalFrame, "TOPRIGHT", -56 , -94)
    mod.personalPower:SetPoint("BOTTOMLEFT", mod.personalFrame, "TOPLEFT",  56, -110)
    mod.personalPower:SetPoint("BOTTOMRIGHT", mod.personalFrame, "TOPRIGHT", -56 , -110)
    mod.personalPower:SetMinMaxValues(0, UnitPowerMax("player"))
    mod.personalPower:SetStatusBarColor(0, 0, 1, 1)

	mod.personalPower.percent = 100
	CreatePowerText()
	CreateHealthPercText()
	CreatePowerSpark()
	mod.personalPower:GetStatusBarTexture():SetDrawLayer("BORDER", -9)
	mod.personalPower:RegisterEvent("UNIT_MANA")
	mod.personalPower:RegisterEvent("PLAYER_ENTERING_WORLD")
	mod.personalPower:SetScript("OnEvent", OnPowerEvent)
end

-- config hooks ################################################################
function mod:GetOptions()
	return {
		enabled = {
			type = "toggle",
			name = "Personal nameplate",
			desc = 'Creates a personal nameplate. You are also able to disable the default player frame.',
			width = "double",
			order = 10
		},
		colour = {
			type = "color",
			name = "Low health colour",
			desc = "The colour to use",
			order = 20
		}
	}
end
function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, {profile = {
		enabled = false,
		colour = {1, 1, .85}
	}})
    PlayerFrame:SetScript("OnEvent", nil)
    PlayerFrame:Hide()

    TargetFrame:SetScript("OnEvent", nil)
    TargetFrame:Hide()

    PersonalBorder()
    CreateHealthBar()
	--CreateHealthText()
    CreatePowerBar()
	addon:InitModuleOptions(self)

	if KuiNameplates.db.profile.hp.bar.animation == 2 then
		local f, smoothing, GetFramerate, min, max, abs = CreateFrame("Frame"), {}, GetFramerate, math.min, math.max, math.abs

		function self.SetValueSmooth(self, value)
			local _, maxv = KuiNameplates:GetMinMaxValues()
			if value == self:GetValue() or (self.prevMax and self.prevMax ~= maxv) then
				-- finished smoothing/max health updated
				smoothing[self] = nil
				self:OrigSetValue(value)
			else
				smoothing[self] = value
			end

			self.prevMax = maxv
		end

		f:SetScript("OnUpdate", function()
			local limit = 30 / GetFramerate()
			for bar, val in pairs(smoothing) do
			local cur = bar:GetValue()
			local new = cur + min((val - cur) / 3, max(val - cur, limit))

			if new ~= new then
				new = val
			end

				bar:OrigSetValue(new)

				if cur == val or abs(new - val) < .005 then
					bar:OrigSetValue(value)
					val = nil
				end
			end
		end)
	end

	LOW_HEALTH_COLOR = self.db.profile.colour
	PRIORITY = self.db.profile.over_tankmode and 15 or 5
	OVER_CLASSCOLOUR = self.db.profile.over_classcolour

	self:SetEnabledState(self.db.profile.enabled)
end
function mod:OnEnable()
	self:RegisterMessage("KuiNameplates_PostCreate", "PostCreate")
	self:RegisterMessage("KuiNameplates_PostShow", "PostShow")
end
function mod:OnDisable()
	self:UnregisterMessage("KuiNameplates_PostCreate", "PostCreate")
	self:UnregisterMessage("KuiNameplates_PostShow", "PostShow")
end