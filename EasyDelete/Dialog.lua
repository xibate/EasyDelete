local _, ns = ...

--The delete dialog, shown in place of the game's popup: the item with its icon, quality and stack size, and Delete and
--Cancel. Enter deletes, Escape, Cancel or x put the item back. It closes by itself when the item leaves the cursor

local theme = ns.theme
local WIDTH = 380
local ICON = 36
--Space on the left for the accent bar, and the height of the buttons below the rule
local LEFT = 20
local FOOTER = 48

local GetInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
local GetIcon = C_Item and C_Item.GetItemIconByID or GetItemIcon
local GetQualityColor = C_Item and C_Item.GetItemQualityColor or GetItemQualityColor

local dialog

--How many items are in the stack on the cursor, when the game can tell
local function CursorStackCount()
    if not (C_Cursor and C_Cursor.GetCursorItem and C_Item and C_Item.GetStackCount) then
        return
    end
    local ok, count = pcall(function()
        local location = C_Cursor.GetCursorItem()
        if location and location:IsValid() then
            return C_Item.GetStackCount(location)
        end
    end)
    return ok and count or nil
end

--The item on the cursor: its link, name, icon, quality and stack size. name and quality are the ones the game's delete
--event gave, when it did
function ns:CursorItem(name, quality)
    local kind, itemID, link = GetCursorInfo()
    if kind ~= "item" then
        return
    end
    local infoName, _, infoQuality, _, _, _, _, _, _, icon = GetInfo(link or itemID)
    return {
        link = link,
        name = name or infoName or link or "",
        quality = quality or infoQuality,
        icon = icon or (itemID and GetIcon(itemID)) or 134400,
        count = CursorStackCount()
    }
end

local function PlayDialogSound(sound)
    if SOUNDKIT and SOUNDKIT[sound] then
        PlaySound(SOUNDKIT[sound])
    end
end

--Deletes the item, or puts it back where it came from, and closes the dialog
local function Finish(deleteIt)
    dialog.resolved = true
    if not dialog.preview then
        if deleteIt and CursorHasItem() then
            DeleteCursorItem()
        else
            ClearCursor()
        end
    end
    dialog:Hide()
end

local function CreateDialog()
    dialog = CreateFrame("Frame", "EasyDeleteDialog", UIParent)
    dialog:SetSize(WIDTH, 140)
    dialog:SetPoint("TOP", 0, -135)
    dialog:SetFrameStrata("DIALOG")
    dialog:SetToplevel(true)
    dialog:SetClampedToScreen(true)
    dialog:EnableMouse(true)
    dialog:SetMovable(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:Hide()
    --Escape closes it, which puts the item back
    table.insert(UISpecialFrames, "EasyDeleteDialog")
    ns:Fill(dialog, theme.window)
    ns:Border(dialog, theme.border)
    --The accent colour down the left side
    local bar = dialog:CreateTexture(nil, "ARTWORK")
    bar:SetWidth(3)
    bar:SetPoint("TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMLEFT", 1, 1)
    bar:SetColorTexture(ns:GetAccent())

    dialog.title = ns:Text(dialog, 14)
    dialog.title:SetPoint("TOPLEFT", LEFT, -15)
    dialog.title:SetText(ns.L.title)
    local close = ns:Button(dialog, "x", 22, 22, function() Finish(false) end)
    close:SetPoint("TOPRIGHT", -10, -10)

    --The item: its icon with the stack size, its name in its quality's colour and the quality below it. Hover it for
    --the item's tooltip
    local item = CreateFrame("Frame", nil, dialog)
    item:SetHeight(ICON)
    item:SetPoint("TOPLEFT", LEFT, -42)
    item:SetPoint("TOPRIGHT", -14, -42)
    local iconFrame = CreateFrame("Frame", nil, item)
    iconFrame:SetSize(ICON, ICON)
    iconFrame:SetPoint("LEFT")
    dialog.setIconBorder = ns:Border(iconFrame, theme.borderStrong)
    dialog.icon = iconFrame:CreateTexture(nil, "ARTWORK")
    dialog.icon:SetPoint("TOPLEFT", 1, -1)
    dialog.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    dialog.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    dialog.count = ns:Text(iconFrame, 11, theme.text, "RIGHT")
    dialog.count:SetFont(ns:GetFont(), 11, "OUTLINE")
    dialog.count:SetPoint("BOTTOMRIGHT", -2, 2)
    dialog.name = ns:Text(item, 13)
    dialog.name:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT", 10, -3)
    dialog.name:SetPoint("RIGHT", item, "RIGHT", 0, 0)
    dialog.details = ns:Text(item, 11, theme.dim)
    dialog.details:SetPoint("BOTTOMLEFT", iconFrame, "BOTTOMRIGHT", 10, 3)
    dialog.details:SetPoint("RIGHT", item, "RIGHT", 0, 0)
    item:EnableMouse(true)
    item:SetScript("OnEnter", function(self)
        if dialog.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(dialog.link)
            GameTooltip:Show()
        end
    end)
    item:SetScript("OnLeave", function() GameTooltip:Hide() end)

    --For quest items: deleting one can also abandon its quest
    dialog.warning = ns:Text(dialog, 11, theme.warning)
    dialog.warning:SetPoint("TOPLEFT", item, "BOTTOMLEFT", 0, -10)
    dialog.warning:SetWidth(WIDTH - LEFT - 14)
    dialog.warning:SetWordWrap(true)
    dialog.warning:SetText(ns.L.questWarning)

    --A thin rule, then the key hint, Cancel and a solid Delete
    local rule = dialog:CreateTexture(nil, "ARTWORK")
    rule:SetHeight(1)
    rule:SetPoint("BOTTOMLEFT", LEFT, FOOTER)
    rule:SetPoint("BOTTOMRIGHT", -14, FOOTER)
    rule:SetColorTexture(1, 1, 1, 0.08)
    dialog.delete = ns:Button(dialog, DELETE or "Delete", 100, 26, function() Finish(true) end, 'solid')
    dialog.delete:SetPoint("BOTTOMRIGHT", -14, 12)
    dialog.cancel = ns:Button(dialog, CANCEL or "Cancel", 72, 26, function() Finish(false) end, 'plain')
    dialog.cancel:SetPoint("RIGHT", dialog.delete, "LEFT", -8, 0)
    dialog.hint = ns:Text(dialog, 10, theme.section)
    dialog.hint:SetPoint("LEFT", dialog, "BOTTOMLEFT", LEFT, 25)
    dialog.hint:SetPoint("RIGHT", dialog.cancel, "LEFT", -8, 0)
    dialog.hint:SetWordWrap(true)
    dialog.hint:SetText(ns.L.hint)

    --The game can take the item off the cursor, like when it is put back in the bags
    dialog:SetScript("OnUpdate", function(self)
        if not self.preview and not CursorHasItem() then
            self.resolved = true
            self:Hide()
        end
    end)
    --No sound when it shows: the game's popup already played one before the dialog took its place
    dialog:SetScript("OnShow", function(self)
        --Enter deletes. The other keys go on to the game, so you can still move. Keys can't be set up in combat, but
        --then the game's popup is used anyway
        local keys = self.SetPropagateKeyboardInput and not InCombatLockdown()
        self:EnableKeyboard(keys and true or false)
        if keys then
            self:SetPropagateKeyboardInput(true)
        end
    end)
    dialog:SetScript("OnKeyDown", function(self, key)
        if InCombatLockdown() then
            return
        end
        if key == "ENTER" or key == "NUMPADENTER" then
            self:SetPropagateKeyboardInput(false)
            Finish(true)
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    --Closed some other way than Delete or Cancel, like Escape: the item goes back
    dialog:SetScript("OnHide", function(self)
        PlayDialogSound("IG_MAINMENU_CLOSE")
        GameTooltip:Hide()
        if not self.resolved and not self.preview then
            ClearCursor()
        end
        self.preview = nil
    end)
end

--Fills the dialog with the item and sizes it, with room for the quest warning when it shows
local function Paint(item, quest)
    local r, g, b = 1, 1, 1
    if item.quality and GetQualityColor then
        local qr, qg, qb = GetQualityColor(item.quality)
        if qr then
            r, g, b = qr, qg, qb
        end
    end
    dialog.link = item.link
    dialog.icon:SetTexture(item.icon)
    dialog.setIconBorder(r, g, b, 0.9)
    dialog.name:SetText(item.name)
    dialog.name:SetTextColor(r, g, b, 1)
    dialog.count:SetText(item.count and item.count > 1 and tostring(item.count) or "")
    local details = {}
    local qualityName = item.quality and _G["ITEM_QUALITY" .. item.quality .. "_DESC"]
    if qualityName then
        table.insert(details, qualityName)
    end
    if quest then
        table.insert(details, ITEM_BIND_QUEST or "Quest Item")
    end
    dialog.details:SetText(table.concat(details, "  ·  "))
    dialog.warning:SetShown(quest and true or false)
    local warning = quest and (dialog.warning:GetStringHeight() or 14) + 10 or 0
    dialog:SetHeight(42 + ICON + warning + 14 + FOOTER)
end

--Shows the dialog for the item on the cursor, or updates it when it already shows. name and quality come from the
--game's delete event and can be left out. Returns false when there is no item on the cursor
function ns:ShowDialog(name, quality, quest)
    local item = ns:CursorItem(name, quality)
    if not item then
        return false
    end
    if not dialog then
        CreateDialog()
    end
    dialog.resolved = false
    dialog.preview = nil
    Paint(item, quest)
    dialog:Show()
    return true
end

--The dialog with an item that isn't on the cursor, to see what it looks like. Its buttons only close it
function ns:PreviewDialog()
    if not dialog then
        CreateDialog()
    elseif dialog:IsShown() and not dialog.preview then
        return
    end
    dialog.resolved = false
    dialog.preview = true
    Paint({
        name = ns.L.previewItem,
        quality = 5,
        icon = "Interface\\Icons\\INV_Sword_39"
    }, false)
    dialog:Show()
end

--Closes the dialog when it shows a preview
function ns:ClosePreview()
    if dialog and dialog:IsShown() and dialog.preview then
        dialog.resolved = true
        dialog:Hide()
    end
end

function ns:IsDialogShown()
    return dialog ~= nil and dialog:IsShown()
end

--Puts the item back and closes the dialog, like Cancel
function ns:CancelDialog()
    if ns:IsDialogShown() then
        Finish(false)
    end
end

--For tests
function ns:GetDialog()
    return dialog
end
