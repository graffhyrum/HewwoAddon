local settings = {
    {
        settingText = "Enable tracking of spell casts",
        settingKey = "enableCastTracking",
        settingTooltip = "While enabled, your spell casts will be tracked.",
    },
    {
        settingText = "Enable tracking of currency",
        settingKey = "enableCurrencyTracking",
        settingTooltip = "While enabled, your currency gained will be tracked.",
    }
}

local checkboxes = 0

local settingsFrame = CreateFrame("Frame", "MyAddonSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(500, 300)
settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 0,0)
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString("HewwoAddonSettingsFrame", "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("TOPLEFT", settingsFrame.TitleBg, "TOPLEFT", 5, -3)
settingsFrame.title:SetText("HewwoAddon Settings")
settingsFrame:Hide()
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)

settingsFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

SLASH_HEWWOSETTINGS1 = "/hs"
SlashCmdList["HEWWOSETTINGS"] = function()
    if settingsFrame:IsShown() then settingsFrame:Hide() else settingsFrame:Show() end
end

local function CreateCheckbox(checkboxText, key, checkboxTooltip) 
    local checkbox = CreateFrame("CheckButton", "MyAddonCheckboxID" .. checkboxes, settingsFrame, "UICheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30 + (checkboxes * -30))

    if MyAddonDB.settingsKeys[key] == nil then
        MyAddonDB.settingsKeys[key] = true 
    end

    checkbox:SetChecked(MyAddonDB.settingsKeys[key])

    checkbox:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)

    checkbox:SetScript("OnLeave", function(self) 
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self) 
        MyAddonDB.settingsKeys[key] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1

    return checkbox
end

local elFrame = CreateFrame("Frame", "MyAddonSettingsEventListenerFrame", UIParent)
elFrame:RegisterEvent("PLAYER_LOGIN")

elFrame:SetScript("OnEvent", function(self,event) 
    if event == "PLAYER_LOGIN" then
        if not MyAddonDB.settingsKeys then MyAddonDB.settingsKeys = {} end

        for _, setting in pairs(settings) do
            CreateCheckbox(setting.settingText, setting.settingKey, setting.settingTooltip)
        end
    end
end)

local addon = LibStub("AceAddon-3.0"):NewAddon("HewwoAddon")
HewwoAddonMinimapButton = LibStub("LibDBIcon-1.0", true)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("HewwoAddon", {
    type = "data source",
    text = "HewwoAddon",
icon = "Interface\\Icons\\inv_sword_48.blp",
    OnClick = function(self,btn) 
        if btn == "LeftButton" then HewwoAddon:ToggleMainFrame()
        elseif btn == "RightButton" then 
            if settingsFrame:IsShown() then settingsFrame:Hide() else settingsFrame:Show() end
        end
    end,
    OnTooltipShow = function(tooltip) 
        if not tooltip or not tooltip.AddLine then 
            return 
        end

        tooltip:AddLine("HewwoAddon\n\nLeft-click: Open HewwoAddon\nRight-click: Open HewwoAddon Settings", nil, nil, nil, nil)
    end,

})

function addon:OnInitialize() 
    self.db = LibStub("AceDB-3.0"):New("HewwoAddonMinimapPOS", {
        profile = {
            minimap = {
                hide = false
            }
        }
    })

    HewwoAddonMinimapButton:Register("HewwoAddon", miniButton, self.db.profile.minimap)
end

HewwoAddonMinimapButton:Show("HewwoAddon")