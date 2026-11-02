local _, ns = ...

--Look of the dialog, the same as Crescendo's windows: dark warm panels, faint 1px borders, dimmed white text and one
--accent colour, in the style of EllesmereUI. The accent is red, because the dialog destroys things. With EllesmereUI
--installed its font is used, so the dialog matches the rest of the UI
local theme = {
    window = { 0.069, 0.058, 0.047, 0.97 },
    panel = { 0.089, 0.080, 0.072, 1 },
    well = { 0.030, 0.023, 0.018, 0.6 },
    input = { 0.103, 0.095, 0.088, 0.9 },
    border = { 1, 1, 1, 0.06 },
    borderStrong = { 1, 1, 1, 0.22 },
    text = { 1, 1, 1, 0.9 },
    dim = { 1, 1, 1, 0.53 },
    section = { 1, 1, 1, 0.41 },
    warning = { 1, 0.75, 0.3, 1 },
    accent = { 0.78, 0.16, 0.18 }
}
ns.theme = theme

local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"

function ns:GetAccent()
    return theme.accent[1], theme.accent[2], theme.accent[3]
end

function ns:GetFont()
    local eui = _G.EllesmereUI
    if type(eui) == 'table' and type(eui.GetFontPath) == 'function' then
        local ok, path = pcall(eui.GetFontPath)
        if ok and type(path) == 'string' then
            return path
        end
    end
    return DEFAULT_FONT
end

local function Color(color, alpha)
    return color[1], color[2], color[3], alpha or color[4] or 1
end
ns.Color = Color

--A solid colour filling a frame
function ns:Fill(frame, color, layer)
    local texture = frame:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetColorTexture(Color(color))
    texture:SetAllPoints()
    return texture
end

--A 1px border around a frame, made of four textures so it stays sharp. Returns a function that recolours it
function ns:Border(frame, color)
    local edges = {}
    local function Edge(pointA, pointB, horizontal)
        local edge = frame:CreateTexture(nil, "BORDER")
        edge:SetPoint(pointA)
        edge:SetPoint(pointB)
        if horizontal then
            edge:SetHeight(1)
        else
            edge:SetWidth(1)
        end
        table.insert(edges, edge)
    end
    Edge("TOPLEFT", "TOPRIGHT", true)
    Edge("BOTTOMLEFT", "BOTTOMRIGHT", true)
    Edge("TOPLEFT", "BOTTOMLEFT", false)
    Edge("TOPRIGHT", "BOTTOMRIGHT", false)
    local function SetColor(r, g, b, a)
        for _, edge in ipairs(edges) do
            edge:SetColorTexture(r, g, b, a)
        end
    end
    SetColor(Color(color or theme.border))
    return SetColor
end

function ns:Text(parent, size, color, justify)
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:SetFont(ns:GetFont(), size or 12, "")
    text:SetShadowColor(0, 0, 0, 0.8)
    text:SetShadowOffset(1, -1)
    text:SetTextColor(Color(color or theme.text))
    text:SetJustifyH(justify or "LEFT")
    text:SetWordWrap(false)
    return text
end

--A small upper case section label
function ns:SectionLabel(parent, label)
    local text = ns:Text(parent, 10, theme.section)
    text:SetText(label:upper())
    return text
end

--A flat button with a faint border that lights up on hover. 'accent' gives it the accent colour, 'solid' fills it with
--the accent colour with white text, 'plain' has no fill or border until it is hovered
function ns:Button(parent, label, width, height, onClick, accent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height or 24)
    local background = ns:Fill(button, theme.panel)
    local setBorder = ns:Border(button, theme.borderStrong)
    button.label = ns:Text(button, 11, theme.text, "CENTER")
    button.label:SetPoint("CENTER")
    button.label:SetText(label)
    local function Paint(hover)
        if accent == 'solid' then
            local r, g, b = ns:GetAccent()
            background:SetColorTexture(r, g, b, hover and 1 or 0.9)
            setBorder(r, g, b, 1)
            button.label:SetTextColor(1, 1, 1, hover and 1 or 0.95)
            return
        elseif accent == 'plain' then
            background:SetColorTexture(1, 1, 1, hover and 0.06 or 0)
            setBorder(1, 1, 1, 0)
        elseif accent then
            local r, g, b = ns:GetAccent()
            background:SetColorTexture(r, g, b, hover and 0.32 or 0.2)
            setBorder(r, g, b, hover and 0.9 or 0.6)
        else
            background:SetColorTexture(Color(theme.panel, hover and 0.95 or 0.65))
            setBorder(1, 1, 1, hover and 0.35 or 0.2)
        end
        button.label:SetTextColor(1, 1, 1, hover and 1 or 0.75)
    end
    Paint(false)
    button:SetScript("OnEnter", function() Paint(true) end)
    button:SetScript("OnLeave", function() Paint(false) end)
    button:SetScript("OnClick", function(self)
        if onClick then
            onClick(self)
        end
    end)
    return button
end
