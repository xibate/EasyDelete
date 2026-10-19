local folder, ns = ...

--Easy Delete: deleting an item takes one click. The game's delete popup, which asks to type DELETE for rare and better
--items, is replaced by the addon's own dialog (Dialog.lua). With the game's popup picked as the style (Options.lua),
--and always in combat, the game's popup shows instead, with DELETE filled in and no line asking to type it

local L = ns.L

--The game's delete popups, and whether they are for a quest item
local DELETE_POPUPS = {
    DELETE_ITEM = false,
    DELETE_GOOD_ITEM = false,
    DELETE_QUEST_ITEM = true,
    DELETE_GOOD_QUEST_ITEM = true
}
local PREVIEW_POPUP = "EASYDELETE_PREVIEW"

local function Print(message)
    print("|cffc7292eEasy Delete|r " .. message)
end

local function UseDialog()
    return ns:GetStyle() == 'dialog' and not InCombatLockdown()
end

--The last delete event the game sent, for the item's quality and whether it is a quest item
local lastEvent

local function FreshEvent()
    return lastEvent and lastEvent.time == GetTime() and lastEvent or nil
end

local function PopupEditBox(popup)
    return popup.GetEditBox and popup:GetEditBox() or popup.editBox
end

--The game's popup made easy: DELETE typed in, so Yes works, and the text box hidden. The question loses its line about
--typing DELETE, so it reads like the game's popup for common items, and the buttons move up into the text box's place.
--question is that shorter text, by default the game's own for the popup (DELETE_ITEM for DELETE_GOOD_ITEM)
local links = {}
local function EasePopup(which, item, question)
    local popup = StaticPopup_FindVisible and StaticPopup_FindVisible(which)
    if not popup then
        return
    end
    local editBox = PopupEditBox(popup)
    local yes = popup.GetButton1 and popup:GetButton1() or popup.button1
    if not (editBox and yes and editBox:IsShown()) then
        return
    end
    editBox:SetText(DELETE_ITEM_CONFIRM_STRING or "DELETE")
    editBox:Hide()
    yes:Enable()
    item = item or select(3, GetCursorInfo())
    question = question or _G[(which:gsub("_GOOD", ""))]
    local text, buttons = popup.Text, popup.ButtonContainer
    if text and buttons and item and type(question) == 'string' then
        text:SetFormattedText(question, item)
        --The game's own spacing between the text and the buttons
        buttons:ClearAllPoints()
        buttons:SetPoint("TOP", text, "BOTTOM", 0, -9)
        if popup.Layout then
            popup:Layout()
        end
        if links[popup] then
            links[popup]:Hide()
        end
        return
    end
    --A popup without those parts keeps its text, with the item's link where the text box was
    local link = links[popup]
    if not link then
        link = popup:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        popup:HookScript("OnHide", function() link:Hide() end)
        links[popup] = link
    end
    link:ClearAllPoints()
    link:SetPoint("CENTER", editBox)
    link:SetText(item or "")
    link:Show()
end

--Runs after the game shows any popup. A delete popup is swapped for the dialog, or made easy
local function OnPopupShown(which, itemName)
    local quest = DELETE_POPUPS[which]
    if quest == nil then
        return
    end
    --Another addon may have dealt with the popup first, like closing it for a dialog of its own. Then Easy Delete
    --leaves it alone, so there are never two dialogs
    local popup = StaticPopup_FindVisible and StaticPopup_FindVisible(which)
    if StaticPopup_FindVisible and not popup then
        return
    end
    --An addon that fills in DELETE as well isn't needed next to Easy Delete. The settings page says so
    local editBox = popup and PopupEditBox(popup)
    if editBox and editBox:IsShown() and (editBox:GetText() or "") ~= "" then
        ns.otherHelperSeen = true
    end
    if UseDialog() then
        local event = FreshEvent()
        if ns:ShowDialog(itemName, event and event.quality, quest or (event and event.questWarn == 1)) then
            StaticPopup_Hide(which)
        end
    else
        EasePopup(which)
    end
end

--Shows a style without deleting anything: the dialog with an example item, or the game's popup made easy
function ns:PreviewStyle(style)
    if style == 'classic' then
        ns:ClosePreview()
        if not StaticPopupDialogs[PREVIEW_POPUP] then
            StaticPopupDialogs[PREVIEW_POPUP] = {
                text = DELETE_GOOD_ITEM or "Do you want to destroy %s?",
                button1 = YES,
                button2 = NO,
                hasEditBox = 1,
                maxLetters = 32,
                timeout = 0,
                whileDead = 1,
                hideOnEscape = 1
            }
        end
        local link = "|cffff8000[" .. L.previewItem .. "]|r"
        StaticPopup_Show(PREVIEW_POPUP, link)
        EasePopup(PREVIEW_POPUP, link, DELETE_ITEM)
    else
        if StaticPopupDialogs[PREVIEW_POPUP] then
            StaticPopup_Hide(PREVIEW_POPUP)
        end
        ns:PreviewDialog()
    end
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("DELETE_ITEM_CONFIRM")
addon:RegisterEvent("PLAYER_REGEN_DISABLED")
addon:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... == folder then
            EasyDeleteDB = EasyDeleteDB or {}
            hooksecurefunc("StaticPopup_Show", OnPopupShown)
            ns:AddSettingsPage()
        end
    elseif event == "PLAYER_LOGIN" then
        --The first time, once the game has loaded, ask which style to use
        if not ns:HasPickedStyle() then
            C_Timer.After(3, function()
                if not ns:HasPickedStyle() then
                    ns:OpenOptions(true)
                end
            end)
        end
    elseif event == "DELETE_ITEM_CONFIRM" then
        --The game may show its popup before or after this, so the dialog takes the event's details when it already shows
        local itemName, quality, _, questWarn = ...
        lastEvent = { time = GetTime(), quality = quality, questWarn = questWarn }
        if ns:IsDialogShown() and not ns:GetDialog().preview then
            ns:ShowDialog(itemName, quality, questWarn == 1 or nil)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        --The game restricts addons in combat, so the dialog isn't used there and the item goes back
        if ns:IsDialogShown() and not ns:GetDialog().preview then
            ns:CancelDialog()
            Print(L.combat)
        end
    end
end)

SLASH_EASYDELETE1 = "/easydelete"
SLASH_EASYDELETE2 = "/edel"
SlashCmdList.EASYDELETE = function(message)
    local command = (message or ""):match("^%s*(%S*)"):lower()
    if command == 'classic' or command == 'dialog' then
        ns:SetStyle(command)
        Print(command == 'classic' and L.usingClassic or L.usingDialog)
    elseif command == 'preview' then
        ns:PreviewStyle('dialog')
    elseif command == 'help' then
        Print(L.help)
    else
        ns:ToggleOptions()
    end
end
