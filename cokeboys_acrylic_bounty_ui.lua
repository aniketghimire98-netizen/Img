--[[
    Sovereign Aimbot v3 — Auto Bounty UI (Acrylic Style)

    HOW IT WORKS:
    - Loads after Cokeboys is already running in your executor
    - Patches CB_SESSION_INFO.bountyPanel to use Acrylic-style visuals
    - All original Cokeboys logic (refreshBountyText, refreshLayout, etc.) is untouched
    - Toggle "Show Bounty / Honor" in Cokeboys still controls visibility
    - Works on PC and Mobile

    USAGE:
    1. Execute Cokeboys script first (or include this at the bottom of it)
    2. Then execute this script
--]]

-- ============================================================
--  SOVEREIGN AIMBOT v3 — ACRYLIC BOUNTY UI OVERLAY
-- ============================================================

local SovereignBountyUI = {}

-- ── Acrylic Library loader ───────────────────────────────────
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/noowtf31-ui/Arcylic/refs/heads/main/src.lua.txt"
))()

-- ── Wait for Cokeboys to be ready ───────────────────────────
local function waitForCokeboys(timeout)
    local t = 0
    while t < (timeout or 30) do
        if CB_SESSION_INFO and CB_SESSION_INFO.bountyLabel then
            return true
        end
        task.wait(0.5)
        t = t + 0.5
    end
    return false
end

-- ── Colour helpers (match Cokeboys C table if present) ───────
local function getAccent()
    if _G and _G.C and _G.C.ACCENT then
        return _G.C.ACCENT
    end
    return Color3.fromRGB(255, 185, 30)  -- gold fallback
end

-- ── Build Acrylic-style wrapper around the bounty panel ──────
local function buildAcrylicBountyPanel()
    if not CB_SESSION_INFO or not CB_SESSION_INFO.bountyPanel then
        warn("[Sovereign Aimbot v3] CB_SESSION_INFO.bountyPanel not found. Make sure Cokeboys is running.")
        return
    end

    -- ── Acrylic Hub (used for notification API only) ──────────
    local hub = Library.new("Sovereign Aimbot v3", "SovereignAimbotV3")
    hub:SetToggleKey(Enum.KeyCode.RightControl) -- respect Cokeboys default key

    -- ── Grab references to existing Cokeboys objects ──────────
    local origPanel = CB_SESSION_INFO.bountyPanel
    local origLabel = CB_SESSION_INFO.bountyLabel
    local parentGui = CB_SESSION_INFO.gui  -- ScreenGui: CokeboysSessionInfo

    if not parentGui then
        warn("[Sovereign Aimbot v3] CB_SESSION_INFO.gui not found.")
        return
    end

    -- ── Hide the original bare label (replace visuals only) ───
    -- origPanel stays alive — Cokeboys uses it for .Visible/.Size/.Position
    origLabel.TextTransparency       = 1
    origLabel.TextStrokeTransparency = 1

    -- ── Acrylic card frame ────────────────────────────────────
    local card = Instance.new("Frame")
    card.Name                  = "SovereignBountyCard"
    card.BackgroundColor3      = Color3.fromRGB(12, 12, 18)
    card.BackgroundTransparency = 0.18
    card.BorderSizePixel       = 0
    card.ZIndex                = 200
    card.Parent                = parentGui

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent       = card

    -- Subtle border (UIStroke)
    local stroke = Instance.new("UIStroke")
    stroke.Color        = getAccent()
    stroke.Thickness    = 1.4
    stroke.Transparency = 0.55
    stroke.Parent       = card

    -- Accent top-bar
    local accentBar = Instance.new("Frame")
    accentBar.Name             = "AccentBar"
    accentBar.Size             = UDim2.new(1, 0, 0, 2)
    accentBar.Position         = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = getAccent()
    accentBar.BorderSizePixel  = 0
    accentBar.ZIndex           = 201
    accentBar.Parent           = card
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 8)
    barCorner.Parent       = accentBar

    -- Icon label (bounty / honor emoji)
    local icon = Instance.new("TextLabel")
    icon.Name                   = "Icon"
    icon.Size                   = UDim2.new(0, 22, 1, -4)
    icon.Position               = UDim2.new(0, 6, 0, 2)
    icon.BackgroundTransparency = 1
    icon.Text                   = "💰"
    icon.TextSize               = 12
    icon.Font                   = Enum.Font.GothamBold
    icon.TextXAlignment         = Enum.TextXAlignment.Center
    icon.TextYAlignment         = Enum.TextYAlignment.Center
    icon.ZIndex                 = 202
    icon.Parent                 = card

    -- Main styled text label
    local styledLabel = Instance.new("TextLabel")
    styledLabel.Name                   = "SovereignBountyText"
    styledLabel.Size                   = UDim2.new(1, -32, 1, -4)
    styledLabel.Position               = UDim2.new(0, 28, 0, 2)
    styledLabel.BackgroundTransparency = 1
    styledLabel.Font                   = Enum.Font.GothamMedium
    styledLabel.TextColor3             = Color3.fromRGB(240, 240, 240)
    styledLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    styledLabel.TextStrokeTransparency = 0.5
    styledLabel.TextSize               = 11
    styledLabel.TextXAlignment         = Enum.TextXAlignment.Right
    styledLabel.TextYAlignment         = Enum.TextYAlignment.Center
    styledLabel.RichText               = true
    styledLabel.ZIndex                 = 202
    styledLabel.Text                   = "BOUNTY  --"
    styledLabel.Parent                 = card

    -- Shadow frame (depth effect)
    local shadow = Instance.new("Frame")
    shadow.Name                  = "Shadow"
    shadow.Size                  = UDim2.new(1, 6, 1, 6)
    shadow.Position              = UDim2.new(0, -3, 0, 3)
    shadow.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.72
    shadow.BorderSizePixel       = 0
    shadow.ZIndex                = 199
    shadow.Parent                = card
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 10)
    shadowCorner.Parent       = shadow

    -- ── Keep card in sync with origPanel ──────────────────────
    local function syncCard()
        if not card.Parent then return end
        if not origPanel or not origPanel.Parent then return end

        local abs   = origPanel.AbsolutePosition
        local absSz = origPanel.AbsoluteSize

        card.Position = UDim2.fromOffset(abs.X - 4, abs.Y - 2)
        card.Size     = UDim2.fromOffset(absSz.X + 8, absSz.Y + 6)
        card.Visible  = origPanel.Visible

        -- Keep accent colours in sync with Cokeboys theme
        local accent = getAccent()
        stroke.Color               = accent
        accentBar.BackgroundColor3 = accent

        -- Mirror RichText from original label into styled label
        if origLabel and origLabel.Text ~= "" then
            styledLabel.Text = origLabel.Text

            -- Swap icon for marines
            if string.find(string.lower(origLabel.Text or ""), "honor") then
                icon.Text = "⚓"
            else
                icon.Text = "💰"
            end
        end
    end

    -- ── Patch CB_SESSION_INFO.refreshBountyText ───────────────
    local _origRefreshBounty = CB_SESSION_INFO.refreshBountyText
    CB_SESSION_INFO.refreshBountyText = function()
        if _origRefreshBounty then _origRefreshBounty() end
        if origLabel and styledLabel then
            styledLabel.Text     = origLabel.Text
            styledLabel.TextSize = origLabel.TextSize
        end
        syncCard()
    end

    -- ── Patch CB_SESSION_INFO.applyTextSize ───────────────────
    local _origApplySize = CB_SESSION_INFO.applyTextSize
    CB_SESSION_INFO.applyTextSize = function()
        if _origApplySize then _origApplySize() end
        if origLabel then
            styledLabel.TextSize = origLabel.TextSize
        end
        syncCard()
    end

    -- ── Patch CB_SESSION_INFO.refreshLayout ───────────────────
    local _origLayout = CB_SESSION_INFO.refreshLayout
    CB_SESSION_INFO.refreshLayout = function()
        if _origLayout then _origLayout() end
        task.defer(syncCard)
    end

    -- ── Continuous sync loop (catches visibility changes) ─────
    task.spawn(function()
        while card.Parent do
            task.wait(0.35)
            pcall(syncCard)
        end
    end)

    -- ── Initial sync ──────────────────────────────────────────
    task.delay(0.1, syncCard)

    -- ── Welcome notification ──────────────────────────────────
    hub:Notify({
        Title       = "Sovereign Aimbot v3",
        Description = "Bounty panel restyled! Enable via Cokeboys → Visuals → Show Bounty / Honor",
        Duration    = 4,
        Icon        = "rbxassetid://10709775704"
    })

    print("[Sovereign Aimbot v3] Acrylic-style bounty panel applied successfully.")
    SovereignBountyUI.card        = card
    SovereignBountyUI.styledLabel = styledLabel
    SovereignBountyUI.hub         = hub
end

-- ── Entry point ───────────────────────────────────────────────
task.spawn(function()
    local ready = waitForCokeboys(30)
    if not ready then
        warn("[Sovereign Aimbot v3] Timed out waiting for Cokeboys. Run Cokeboys first!")
        return
    end
    buildAcrylicBountyPanel()
end)

return SovereignBountyUI
