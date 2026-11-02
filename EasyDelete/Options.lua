local folder, ns = ...

--Picking the delete style: Easy Delete's dialog or the game's popup with DELETE filled in. The two styles show as cards,
--in a window that opens the first time the addon runs and with /easydelete, and on the addon's page in the game's
--settings (Options > AddOns > Easy Delete). Clicking a card uses that style straight away

local theme = ns.theme
local L = ns.L
local CARD_W, CARD_H = 220, 118
local GAP = 12
local MEDIA = "Interface\\AddOns\\EasyDelete\\Media\\"

--'dialog' or 'classic'. Before a style was picked the dialog is used
function ns:GetStyle()
    return EasyDeleteDB and EasyDeleteDB.style or 'dialog'
end

function ns:HasPickedStyle()
    return EasyDeleteDB ~= nil and EasyDeleteDB.style ~= nil
end

local choosers = {}

function ns:SetStyle(style)
    EasyDeleteDB.style = style
    if style == 'classic' then
        ns:CancelDialog()
    end
    for _, chooser in ipairs(choosers) do
        chooser:Refresh()
    end
end

--A style to pick: a dot and the style's name, what it does, and Preview. Selected, it has the accent colour
local function StyleCard(parent, style, title, text, onPreview)
    local card = CreateFrame("Button", nil, parent)
    card:SetSize(CARD_W, CARD_H)
    card.style = style
    card.fill = ns:Fill(card, theme.well)
    card.setBorder = ns:Border(card, theme.borderStrong)
    card.bar = card:CreateTexture(nil, "ARTWORK")
    card.bar:SetWidth(2)
    card.bar:SetPoint("TOPLEFT", 1, -1)
    card.bar:SetPoint("BOTTOMLEFT", 1, 1)
    local radio = CreateFrame("Frame", nil, card)
    radio:SetSize(14, 14)
    radio:SetPoint("TOPLEFT", 12, -12)
    ns:Fill(radio, theme.input)
    card.setRadioBorder = ns:Border(radio, theme.borderStrong)
    card.dot = radio:CreateTexture(nil, "ARTWORK")
    card.dot:SetPoint("TOPLEFT", 3, -3)
    card.dot:SetPoint("BOTTOMRIGHT", -3, 3)
    card.title = ns:Text(card, 13)
    card.title:SetPoint("LEFT", radio, "RIGHT", 8, 0)
    card.title:SetPoint("RIGHT", card, "RIGHT", -12, 0)
    card.title:SetText(title)
    card.text = ns:Text(card, 11, theme.dim)
    card.text:SetPoint("TOPLEFT", 12, -36)
    card.text:SetWidth(CARD_W - 24)
    card.text:SetWordWrap(true)
    card.text:SetJustifyV("TOP")
    card.text:SetText(text)
    card.preview = ns:Button(card, L.preview, 80, 22, onPreview)
    card.preview:SetPoint("BOTTOMLEFT", 12, 12)
    local function Paint(hover)
        local r, g, b = ns:GetAccent()
        if card.selected then
            card.fill:SetColorTexture(r, g, b, 0.08)
            card.setBorder(r, g, b, 0.8)
            card.setRadioBorder(r, g, b, 0.8)
            card.dot:SetColorTexture(r, g, b, 1)
            card.dot:Show()
            card.bar:SetColorTexture(r, g, b, 1)
            card.bar:Show()
            card.title:SetTextColor(1, 1, 1, 1)
        else
            card.fill:SetColorTexture(1, 1, 1, hover and 0.04 or 0.02)
            card.setBorder(1, 1, 1, hover and 0.3 or 0.12)
            card.setRadioBorder(ns.Color(theme.borderStrong))
            card.dot:Hide()
            card.bar:Hide()
            card.title:SetTextColor(1, 1, 1, hover and 0.9 or 0.7)
        end
    end
    function card:SetSelected(selected)
        self.selected = selected
        Paint(false)
    end
    card:SetScript("OnEnter", function() Paint(true) end)
    card:SetScript("OnLeave", function() Paint(false) end)
    card:SetScript("OnClick", function() ns:SetStyle(style) end)
    return card
end

--The two style cards side by side
function ns:StyleChooser(parent)
    local chooser = CreateFrame("Frame", nil, parent)
    chooser:SetSize(2 * CARD_W + GAP, CARD_H)
    chooser.cards = {
        StyleCard(chooser, 'dialog', L.dialogTitle, L.dialogText, function() ns:PreviewStyle('dialog') end),
        StyleCard(chooser, 'classic', L.classicTitle, L.classicText, function() ns:PreviewStyle('classic') end)
    }
    chooser.cards[1]:SetPoint("TOPLEFT")
    chooser.cards[2]:SetPoint("TOPLEFT", CARD_W + GAP, 0)
    function chooser:Refresh()
        local style = ns:GetStyle()
        for _, card in ipairs(self.cards) do
            card:SetSelected(card.style == style)
        end
    end
    chooser:Refresh()
    table.insert(choosers, chooser)
    return chooser
end

------------------------------------------------------------------------------------------------------------------------
-- The window: the first time the addon runs, and with /easydelete
------------------------------------------------------------------------------------------------------------------------

local window

local function CreateWindow()
    local width = 2 * CARD_W + GAP + 28
    window = CreateFrame("Frame", "EasyDeleteOptions", UIParent)
    window:SetSize(width, 96 + CARD_H + 56)
    window:SetPoint("CENTER", 0, 60)
    window:SetFrameStrata("DIALOG")
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:Hide()
    table.insert(UISpecialFrames, "EasyDeleteOptions")
    ns:Fill(window, theme.window)
    ns:Border(window, theme.border)
    local strip = window:CreateTexture(nil, "ARTWORK")
    strip:SetHeight(2)
    strip:SetPoint("TOPLEFT", 1, -1)
    strip:SetPoint("TOPRIGHT", -1, -1)
    strip:SetColorTexture(ns:GetAccent())
    local logo = window:CreateTexture(nil, "ARTWORK")
    logo:SetSize(20, 20)
    logo:SetPoint("TOPLEFT", 14, -12)
    logo:SetTexture(MEDIA .. "Icon")
    local name = ns:Text(window, 14)
    name:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    name:SetText("Easy Delete")
    name:SetTextColor(ns:GetAccent())
    local close = ns:Button(window, "x", 22, 22, function() window:Hide() end)
    close:SetPoint("TOPRIGHT", -10, -10)
    window.heading = ns:Text(window, 13)
    window.heading:SetPoint("TOPLEFT", 14, -46)
    window.text = ns:Text(window, 11, theme.dim)
    window.text:SetPoint("TOPLEFT", window.heading, "BOTTOMLEFT", 0, -6)
    window.text:SetWidth(width - 28)
    window.text:SetWordWrap(true)
    window.text:SetText(L.chooseText)
    window.chooser = ns:StyleChooser(window)
    window.chooser:SetPoint("TOPLEFT", 14, -96)
    local done = ns:Button(window, L.done, 96, 26, function() window:Hide() end, true)
    done:SetPoint("BOTTOMRIGHT", -14, 14)
    local hint = ns:Text(window, 10, theme.section)
    hint:SetPoint("LEFT", window, "BOTTOMLEFT", 14, 27)
    hint:SetPoint("RIGHT", done, "LEFT", -8, 0)
    --Two lines next to Done when it doesn't fit on one, instead of being cut off
    hint:SetWordWrap(true)
    hint:SetText(L.settingsHint)
    window.hint = hint
    --However it closes, the style that shows as picked is the one used from now on
    window:SetScript("OnHide", function()
        if not ns:HasPickedStyle() then
            ns:SetStyle(ns:GetStyle())
        end
    end)
end

--Opens the window, with a welcome the first time
function ns:OpenOptions(firstRun)
    if not window then
        CreateWindow()
    end
    window.heading:SetText(firstRun and L.welcome or L.options)
    window.chooser:Refresh()
    window:Show()
end

function ns:ToggleOptions()
    if window and window:IsShown() then
        window:Hide()
    else
        ns:OpenOptions(false)
    end
end

--For tests
function ns:GetOptionsWindow()
    return window
end

------------------------------------------------------------------------------------------------------------------------
-- The addon's page in the game's settings
------------------------------------------------------------------------------------------------------------------------

local GetMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

function ns:AddSettingsPage()
    if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then
        return
    end
    local panel = CreateFrame("Frame")
    local logo = panel:CreateTexture(nil, "ARTWORK")
    logo:SetSize(24, 24)
    logo:SetPoint("TOPLEFT", 16, -16)
    logo:SetTexture(MEDIA .. "Icon")
    local name = ns:Text(panel, 16)
    name:SetPoint("LEFT", logo, "RIGHT", 10, 0)
    name:SetText("Easy Delete")
    local version = ns:Text(panel, 11, theme.dim)
    version:SetPoint("LEFT", name, "RIGHT", 8, -1)
    version:SetText(GetMetadata and GetMetadata(folder, "Version") or "")
    local section = ns:SectionLabel(panel, L.styleSection)
    section:SetPoint("TOPLEFT", 16, -60)
    local text = ns:Text(panel, 11, theme.dim)
    text:SetPoint("TOPLEFT", section, "BOTTOMLEFT", 0, -6)
    text:SetWidth(2 * CARD_W + GAP)
    text:SetWordWrap(true)
    text:SetText(L.chooseText)
    local chooser = ns:StyleChooser(panel)
    chooser:SetPoint("TOPLEFT", 16, -96)
    local commands = ns:Text(panel, 11, theme.dim)
    commands:SetPoint("TOPLEFT", chooser, "BOTTOMLEFT", 0, -16)
    commands:SetWidth(2 * CARD_W + GAP)
    commands:SetWordWrap(true)
    commands:SetText(L.commands)
    local other = ns:Text(panel, 11, theme.warning)
    other:SetPoint("TOPLEFT", commands, "BOTTOMLEFT", 0, -10)
    other:SetWidth(2 * CARD_W + GAP)
    other:SetWordWrap(true)
    other:SetText(L.otherAddon)
    panel.chooser, panel.other = chooser, other
    panel:SetScript("OnShow", function()
        chooser:Refresh()
        other:SetShown(ns.otherHelperSeen == true)
    end)
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Easy Delete")
    Settings.RegisterAddOnCategory(category)
end
