local folder, ns = ...

--Easy Delete: deleting an item takes one click. The game's delete popup, which asks to type DELETE for rare and better
--items, is replaced by the addon's own dialog (Dialog.lua). In combat, or after /easydelete classic, the game's popup
--shows instead, with DELETE filled in and the item's link where the text box was

ns.L = {
    title = "Delete item",
    hint = "Enter deletes, Escape keeps it",
    questWarning = "Deleting it also abandons the quest it belongs to.",
    previewItem = "Thunderfury, Blessed Blade of the Windseeker",
    combat = "Combat started, so the item went back. Delete it again after the fight.",
    usingDialog = "Easy Delete uses its own delete dialog.",
    usingClassic = "Easy Delete uses the game's delete popup, with DELETE filled in.",
    help = "/easydelete dialog: use Easy Delete's dialog. /easydelete classic: use the game's popup. /easydelete preview: show the dialog without deleting anything."
}
local L = ns.L

--The game's delete popups, and whether they are for a quest item
local DELETE_POPUPS = {
    DELETE_ITEM = false,
    DELETE_GOOD_ITEM = false,
    DELETE_QUEST_ITEM = true,
    DELETE_GOOD_QUEST_ITEM = true
}

local function Print(message)
    print("|cffff594dEasy Delete|r " .. message)
end

local function UseDialog()
    return not (EasyDeleteDB and EasyDeleteDB.style == 'classic') and not InCombatLockdown()
end

--The last delete event the game sent, for the item's name, quality and whether it is a quest item
local lastEvent

local function QuestFromEvent()
    return lastEvent and lastEvent.time == GetTime() and lastEvent.questWarn == 1
end

--The game's popup made easy: DELETE typed in, so Yes works, and the item's link where the text box was
local links = {}
local function EasePopup(which)
    local popup = StaticPopup_FindVisible and StaticPopup_FindVisible(which)
    if not popup then
        return
    end
    local editBox = popup.GetEditBox and popup:GetEditBox() or popup.editBox
    local yes = popup.GetButton1 and popup:GetButton1() or popup.button1
    if not (editBox and yes and editBox:IsShown()) then
        return
    end
    editBox:SetText(DELETE_ITEM_CONFIRM_STRING or "DELETE")
    editBox:Hide()
    yes:Enable()
    local link = links[popup]
    if not link then
        link = popup:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        popup:HookScript("OnHide", function() link:Hide() end)
        links[popup] = link
    end
    link:ClearAllPoints()
    link:SetPoint("CENTER", editBox)
    link:SetText(select(3, GetCursorInfo()) or "")
    link:Show()
end

--Runs after the game shows any popup. A delete popup is swapped for the dialog, or made easy
local function OnPopupShown(which, itemName)
    local quest = DELETE_POPUPS[which]
    if quest == nil then
        return
    end
    if UseDialog() then
        local quality = lastEvent and lastEvent.time == GetTime() and lastEvent.quality or nil
        if ns:ShowDialog(itemName, quality, quest or QuestFromEvent()) then
            StaticPopup_Hide(which)
        end
    else
        EasePopup(which)
    end
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("DELETE_ITEM_CONFIRM")
addon:RegisterEvent("PLAYER_REGEN_DISABLED")
addon:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... == folder then
            EasyDeleteDB = EasyDeleteDB or {}
            hooksecurefunc("StaticPopup_Show", OnPopupShown)
        end
    elseif event == "DELETE_ITEM_CONFIRM" then
        --The game may show its popup before or after this, so the dialog takes the event's details when it already shows
        local itemName, quality, _, questWarn = ...
        lastEvent = { time = GetTime(), quality = quality, questWarn = questWarn }
        if ns:IsDialogShown() then
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
    if command == 'classic' then
        EasyDeleteDB.style = 'classic'
        ns:CancelDialog()
        Print(L.usingClassic)
    elseif command == 'dialog' then
        EasyDeleteDB.style = nil
        Print(L.usingDialog)
    elseif command == 'preview' then
        ns:PreviewDialog()
    else
        Print(EasyDeleteDB.style == 'classic' and L.usingClassic or L.usingDialog)
        Print(L.help)
    end
end
