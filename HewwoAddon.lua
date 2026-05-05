print("Hewwo Addon loaded")
HewwoAddon = HewwoAddon or {}

if not MyAddonDB then
    MyAddonDB = {}
end

local mainFrame = CreateFrame(
"Frame", "MyAddonMainFrame", UIParent, "BasicFrameTemplateWithInset"
)


mainFrame:SetSize(500, 350)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0,0)
mainFrame.title = mainFrame:CreateFontString("HewwoAddonMainFrame", "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5 , -3)
mainFrame.title:SetText("HewwoAddon")

-- Content

mainFrame.playerName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.playerName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -35)
mainFrame.playerName:SetText("Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")")

mainFrame.totalSuccessfulCasts = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.totalSuccessfulCasts:SetPoint("TOPLEFT", mainFrame.playerName, "BOTTOMLEFT", 0, -10)
mainFrame.totalSuccessfulCasts:SetText("Total Casts: " .. (MyAddonDB.successfulCasts or 0))

mainFrame.totalCurrency = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.totalCurrency:SetPoint("TOPLEFT", mainFrame.totalSuccessfulCasts, "BOTTOMLEFT", 0, -10)
mainFrame.totalCurrency:SetText("Gold: " .. (MyAddonDB.gold or 0) .. " Silver: ".. (MyAddonDB.silver or 0) .. " Copper: " .. (MyAddonDB.copper or 0))

-- Hidden on load
-- mainFrame:Hide()

-- Make Interactive
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
mainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)


mainFrame:SetScript("OnShow", function(self)
    PlaySound(808)
    mainFrame.totalSuccessfulCasts:SetText("Total Casts: " .. (MyAddonDB.successfulCasts or 0))
    mainFrame.totalCurrency:SetText("Gold: " .. (MyAddonDB.gold or 0) .. " Silver: ".. (MyAddonDB.silver or 0) .. " Copper: " .. (MyAddonDB.copper or 0))
end)
mainFrame:SetScript("OnHide", function(self)
    PlaySound(808)
end)

-- Register Commands
SLASH_HEWWOADDON1 = "/hewwoaddon"
SLASH_HEWWOADDON2 = "/hewwo"
SlashCmdList["HEWWOADDON"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end


-- Make Escapeable
tinsert(UISpecialFrames, mainFrame:GetName())

-- Spell Cast Counter

local elf = CreateFrame("Frame", "MyAddonEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED"  and MyAddonDB.settingsKeys.enableCastTracking then
        local unitTarget = ...
        if unitTarget == "player" then
            MyAddonDB.successfulCasts = (MyAddonDB.successfulCasts or 0) + 1
            mainFrame.totalSuccessfulCasts:SetText("Total Casts: " .. MyAddonDB.successfulCasts)
        end
    elseif event == "CHAT_MSG_MONEY" and MyAddonDB.settingsKeys.enableCurrencyTracking then
        local msg = ...
        local gold = tonumber(string.match(msg, "(%d+) Gold")) or 0
        local silver = tonumber(string.match(msg, "(%d+) Silver")) or 0
        local copper = tonumber(string.match(msg, "(%d+) Copper")) or 0

        MyAddonDB.gold = (MyAddonDB.gold or 0) + gold
        MyAddonDB.silver = (MyAddonDB.silver or 0) + silver
        MyAddonDB.copper = (MyAddonDB.copper or 0) + copper

        if MyAddonDB.copper >= 100 then
            MyAddonDB.silver = MyAddonDB.silver + math.floor(MyAddonDB.copper / 100)
            MyAddonDB.copper = MyAddonDB.copper % 100
        end
          
        if MyAddonDB.silver >= 100 then
            MyAddonDB.gold = MyAddonDB.gold + math.floor(MyAddonDB.silver / 100)
            MyAddonDB.silver = MyAddonDB.silver % 100
        end
    end

    if mainFrame:IsShown() then
        mainFrame.totalPlayerKills:SetText("Total Kills: " .. (MyAddonDB.kills or "0"))
        mainFrame.totalCurrency:SetText("Gold: " .. (MyAddonDB.gold or "0") .. " Silver: " .. (MyAddonDB.silver or "0") .. " Copper: " .. (MyAddonDB.copper or "0"))
    end
end

elf:SetScript("OnEvent", eventHandler)
elf:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
elf:RegisterEvent("CHAT_MSG_MONEY")


function HewwoAddon:ToggleMainFrame() 
    if not mainFrame:IsShown() then 
        mainFrame:Show()
    else
        mainFrame:Hide()
    end
end 