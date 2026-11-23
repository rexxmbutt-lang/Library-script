-- ============================================================
--  PegasusHub UI Library v1.0
--  Luau | Roblox Executor Script | loadstring-compatible
--  Tested: Delta, Codex, Arceus X, Vega X, Trigon (Android/iOS)
--           Synapse X, KRNL, Fluxus (Windows/Mac)
--  Usage:
--    local LammaHub = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--    local Window = LammaHub:CreateWindow({ Title = "Exclusive", Key = "none" })
--    local Tab = Window:CreateTab("Aimlock")
--    Tab:CreateToggle({ Name = "Aimlock", Default = false, Callback = function(v) end })
--    Tab:CreateSlider({ Name = "Max Distance", Min = 0, Max = 500, Default = 100, Callback = function(v) end })
-- ============================================================

local PegasusHub = {}
LammaHub.__index = LammaHub

-- ── Services ──────────────────────────────────────────────────
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui        = game:GetService("CoreGui")
local LocalPlayer    = Players.LocalPlayer

-- ── Executor Compat ───────────────────────────────────────────
-- gethui() preferred (Arceus, Delta, Codex, Trigon, Vega)
-- Fallback: CoreGui (Synapse, KRNL, Fluxus, iOS Executors)
local function GetGui()
    if syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent = CoreGui
        return sg
    elseif gethui then
        return gethui()
    else
        local sg = Instance.new("ScreenGui")
        sg.Parent = CoreGui
        return sg
    end
end

-- ── Theme ─────────────────────────────────────────────────────
local Theme = {
    Background   = Color3.fromRGB(18, 18, 22),
    Sidebar      = Color3.fromRGB(13, 13, 17),
    TopBar       = Color3.fromRGB(22, 22, 28),
    TabActive    = Color3.fromRGB(30, 30, 38),
    TabHover     = Color3.fromRGB(25, 25, 32),
    Accent       = Color3.fromRGB(0, 162, 255),
    AccentDim    = Color3.fromRGB(0, 100, 180),
    Text         = Color3.fromRGB(220, 220, 220),
    TextDim      = Color3.fromRGB(140, 140, 150),
    Border       = Color3.fromRGB(40, 40, 50),
    Toggle_On    = Color3.fromRGB(0, 162, 255),
    Toggle_Off   = Color3.fromRGB(50, 50, 60),
    Slider_Fill  = Color3.fromRGB(0, 162, 255),
    Slider_Back  = Color3.fromRGB(40, 40, 55),
    Dropdown_BG  = Color3.fromRGB(22, 22, 30),
    Input_BG     = Color3.fromRGB(25, 25, 33),
    Section      = Color3.fromRGB(13, 13, 17),
    White        = Color3.fromRGB(255, 255, 255),
}

-- ── Utilities ─────────────────────────────────────────────────
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── Window ────────────────────────────────────────────────────
function LammaHub:CreateWindow(config)
    config = config or {}
    local WinTitle = config.Title or "LammaHub"

    local ScreenGui = GetGui()
    ScreenGui.Name        = "LammaHub_" .. WinTitle
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    if ScreenGui.Parent ~= CoreGui and not gethui then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Root frame
    local Root = Create("Frame", {
        Name              = "Root",
        Size              = UDim2.new(0, 580, 0, 400),
        Position          = UDim2.new(0.5, -290, 0.5, -200),
        BackgroundColor3  = Theme.Background,
        BorderSizePixel   = 0,
        Parent            = ScreenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Root })
    Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Root })

    -- TopBar
    local TopBar = Create("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel  = 0,
        Parent           = Root,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TopBar })

    -- TopBar cover bottom corners
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    })

    -- Icon circle in topbar
    Create("Frame", {
        Size             = UDim2.new(0, 22, 0, 22),
        Position         = UDim2.new(0, 8, 0.5, -11),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    }).Parent = (function()
        local ic = Create("Frame", {
            Size             = UDim2.new(0, 22, 0, 22),
            Position         = UDim2.new(0, 8, 0.5, -11),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            Parent           = TopBar,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ic })
        return nil
    end)()

    Create("TextLabel", {
        Size             = UDim2.new(1, -50, 1, 0),
        Position         = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text             = WinTitle,
        TextColor3       = Theme.Text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = TopBar,
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -32, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Text             = "✕",
        TextColor3       = Theme.White,
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CloseBtn })
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    MakeDraggable(Root, TopBar)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 130, 1, -36),
        Position         = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        Parent           = Root,
    })

    -- Sidebar tab list
    local TabList = Create("ScrollingFrame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent           = Sidebar,
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 8),
        PaddingLeft   = UDim.new(0, 6),
        PaddingRight  = UDim.new(0, 6),
        Parent        = TabList,
    })
    Create("UIListLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Padding         = UDim.new(0, 4),
        Parent          = TabList,
    })

    -- Content area
    local ContentArea = Create("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -130, 1, -36),
        Position         = UDim2.new(0, 130, 0, 36),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        Parent           = Root,
    })

    -- Separator between sidebar and content
    Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = ContentArea,
    })

    -- ── Tab Pages holder ──────────────────────────────────────
    local Pages = {}
    local ActiveTab = nil

    local Window = {}

    -- ── CreateTab ─────────────────────────────────────────────
    function Window:CreateTab(tabName, layoutOrder)
        local Page = Create("ScrollingFrame", {
            Size             = UDim2.new(1, -1, 1, 0),
            Position         = UDim2.new(0, 1, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            Visible          = false,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent           = ContentArea,
        })
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent        = Page,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
            Parent    = Page,
        })

        -- Sidebar button
        local TabBtn = Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.TabHover,
            Text             = tabName,
            TextColor3       = Theme.TextDim,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 12,
            BorderSizePixel  = 0,
            LayoutOrder      = layoutOrder or 0,
            Parent           = TabList,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })

        local AccentLine = Create("Frame", {
            Size             = UDim2.new(0, 3, 0.7, 0),
            Position         = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            Visible          = false,
            Parent           = TabBtn,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = AccentLine })

        local function ActivateTab()
            if ActiveTab then
                ActiveTab.Page.Visible = false
                ActiveTab.Btn.BackgroundColor3 = Theme.TabHover
                ActiveTab.Btn.TextColor3       = Theme.TextDim
                ActiveTab.Line.Visible         = false
            end
            Page.Visible          = true
            TabBtn.BackgroundColor3 = Theme.TabActive
            TabBtn.TextColor3      = Theme.Text
            AccentLine.Visible    = true
            ActiveTab = { Page = Page, Btn = TabBtn, Line = AccentLine }
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)
        TabBtn.MouseEnter:Connect(function()
            if ActiveTab and ActiveTab.Page ~= Page then
                Tween(TabBtn, { BackgroundColor3 = Theme.TabActive }, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if ActiveTab and ActiveTab.Page ~= Page then
                Tween(TabBtn, { BackgroundColor3 = Theme.TabHover }, 0.1)
            end
        end)

        if not ActiveTab then ActivateTab() end

        -- ── Tab Elements ──────────────────────────────────────
        local Tab = {}

        -- Section Header
        function Tab:CreateSection(name)
            local SectionLbl = Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Text             = name,
                TextColor3       = Theme.TextDim,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 11,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Page,
            })
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel  = 0,
                Parent           = SectionLbl,
            })
        end

        -- Toggle
        function Tab:CreateToggle(config)
            config = config or {}
            local toggleState = config.Default or false
            local cb          = config.Callback or function() end

            local Row = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Input_BG,
                BorderSizePixel  = 0,
                Parent           = Page,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Row })

            Create("TextLabel", {
                Size             = UDim2.new(1, -60, 1, 0),
                Position         = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text             = config.Name or "Toggle",
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Row,
            })

            local Track = Create("Frame", {
                Size             = UDim2.new(0, 40, 0, 20),
                Position         = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = toggleState and Theme.Toggle_On or Theme.Toggle_Off,
                BorderSizePixel  = 0,
                Parent           = Row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

            local Knob = Create("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = toggleState
                    and UDim2.new(1, -17, 0.5, -7)
                    or  UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = Theme.White,
                BorderSizePixel  = 0,
                Parent           = Track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

            local ClickBtn = Create("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                Parent             = Row,
            })
            ClickBtn.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                Tween(Track, { BackgroundColor3 = toggleState and Theme.Toggle_On or Theme.Toggle_Off })
                Tween(Knob,  { Position = toggleState
                    and UDim2.new(1, -17, 0.5, -7)
                    or  UDim2.new(0, 3, 0.5, -7) })
                cb(toggleState)
            end)

            return { SetValue = function(_, v)
                toggleState = v
                Tween(Track, { BackgroundColor3 = v and Theme.Toggle_On or Theme.Toggle_Off })
                Tween(Knob,  { Position = v
                    and UDim2.new(1, -17, 0.5, -7)
                    or  UDim2.new(0, 3, 0.5, -7) })
                cb(v)
            end }
        end

        -- Slider
        function Tab:CreateSlider(config)
            config = config or {}
            local minV  = config.Min     or 0
            local maxV  = config.Max     or 100
            local curV  = config.Default or minV
            local cb    = config.Callback or function() end

            local Row = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Theme.Input_BG,
                BorderSizePixel  = 0,
                Parent           = Page,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Row })

            local NameLbl = Create("TextLabel", {
                Size             = UDim2.new(1, -60, 0, 20),
                Position         = UDim2.new(0, 10, 0, 6),
                BackgroundTransparency = 1,
                Text             = config.Name or "Slider",
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Row,
            })
            local ValLbl = Create("TextLabel", {
                Size             = UDim2.new(0, 50, 0, 20),
                Position         = UDim2.new(1, -58, 0, 6),
                BackgroundTransparency = 1,
                Text             = tostring(curV),
                TextColor3       = Theme.Accent,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Right,
                Parent           = Row,
            })

            local Track = Create("Frame", {
                Size             = UDim2.new(1, -20, 0, 6),
                Position         = UDim2.new(0, 10, 0, 34),
                BackgroundColor3 = Theme.Slider_Back,
                BorderSizePixel  = 0,
                Parent           = Row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

            local Fill = Create("Frame", {
                Size             = UDim2.new((curV - minV) / (maxV - minV), 0, 1, 0),
                BackgroundColor3 = Theme.Slider_Fill,
                BorderSizePixel  = 0,
                Parent           = Track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

            local Thumb = Create("Frame", {
                Size             = UDim2.new(0, 12, 0, 12),
                Position         = UDim2.new((curV - minV) / (maxV - minV), -6, 0.5, -6),
                BackgroundColor3 = Theme.White,
                BorderSizePixel  = 0,
                Parent           = Track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Thumb })

            local sliding = false
            local function UpdateSlider(input)
                local trackPos   = Track.AbsolutePosition
                local trackWidth = Track.AbsoluteSize.X
                local relX = math.clamp(input.Position.X - trackPos.X, 0, trackWidth)
                local pct  = relX / trackWidth
                curV = math.round(minV + pct * (maxV - minV))
                Fill.Size     = UDim2.new(pct, 0, 1, 0)
                Thumb.Position = UDim2.new(pct, -6, 0.5, -6)
                ValLbl.Text   = tostring(curV)
                cb(curV)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            return { SetValue = function(_, v)
                v = math.clamp(v, minV, maxV)
                local pct = (v - minV) / (maxV - minV)
                Fill.Size      = UDim2.new(pct, 0, 1, 0)
                Thumb.Position = UDim2.new(pct, -6, 0.5, -6)
                ValLbl.Text    = tostring(v)
                curV = v
                cb(v)
            end }
        end

        -- Dropdown
        function Tab:CreateDropdown(config)
            config = config or {}
            local options  = config.Options  or {}
            local selected = config.Default  or (options[1] or "Select")
            local cb       = config.Callback or function() end
            local open     = false

            local Wrapper = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                ClipsDescendants = false,
                BorderSizePixel  = 0,
                Parent           = Page,
            })

            local Header = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Input_BG,
                BorderSizePixel  = 0,
                Parent           = Wrapper,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Header })

            Create("TextLabel", {
                Size             = UDim2.new(0, 100, 1, 0),
                Position         = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text             = config.Name or "Dropdown",
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Header,
            })

            local SelLbl = Create("TextLabel", {
                Size             = UDim2.new(0, 120, 1, 0),
                Position         = UDim2.new(1, -155, 0, 0),
                BackgroundTransparency = 1,
                Text             = selected,
                TextColor3       = Theme.Accent,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Right,
                Parent           = Header,
            })

            Create("TextLabel", {
                Size             = UDim2.new(0, 20, 1, 0),
                Position         = UDim2.new(1, -28, 0, 0),
                BackgroundTransparency = 1,
                Text             = "▾",
                TextColor3       = Theme.TextDim,
                Font             = Enum.Font.GothamBold,
                TextSize         = 14,
                Parent           = Header,
            })

            local Dropdown = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                Position         = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Theme.Dropdown_BG,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                ZIndex           = 10,
                Parent           = Wrapper,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Dropdown })
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = Dropdown,
            })

            for _, opt in ipairs(options) do
                local OptBtn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Text             = opt,
                    TextColor3       = Theme.TextDim,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    ZIndex           = 11,
                    Parent           = Dropdown,
                })
                OptBtn.MouseEnter:Connect(function()
                    Tween(OptBtn, { BackgroundTransparency = 0.8 })
                    OptBtn.BackgroundColor3 = Theme.Accent
                end)
                OptBtn.MouseLeave:Connect(function()
                    Tween(OptBtn, { BackgroundTransparency = 1 })
                end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    SelLbl.Text = opt
                    open = false
                    Tween(Dropdown, { Size = UDim2.new(1, 0, 0, 0) })
                    Wrapper.Size = UDim2.new(1, 0, 0, 36)
                    cb(opt)
                end)
            end

            local HitBtn = Create("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                Parent             = Header,
            })
            HitBtn.MouseButton1Click:Connect(function()
                open = not open
                local targetH = open and (#options * 30) or 0
                Tween(Dropdown, { Size = UDim2.new(1, 0, 0, targetH) })
                Wrapper.Size = UDim2.new(1, 0, 0, 36 + (open and targetH + 2 or 0))
            end)

            return { SetValue = function(_, v)
                selected    = v
                SelLbl.Text = v
                cb(v)
            end }
        end

        -- Button
        function Tab:CreateButton(config)
            config = config or {}
            local cb = config.Callback or function() end

            local Btn = Create("TextButton", {
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Accent,
                Text             = config.Name or "Button",
                TextColor3       = Theme.White,
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 13,
                BorderSizePixel  = 0,
                Parent           = Page,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Btn })

            Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.AccentDim }) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.Accent }) end)
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, { BackgroundColor3 = Theme.AccentDim })
                task.delay(0.1, function()
                    Tween(Btn, { BackgroundColor3 = Theme.Accent })
                end)
                cb()
            end)
        end

        -- TextInput
        function Tab:CreateInput(config)
            config = config or {}
            local cb   = config.Callback   or function() end
            local live = config.LiveChange or false

            local Row = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Theme.Input_BG,
                BorderSizePixel  = 0,
                Parent           = Page,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Row })

            Create("TextLabel", {
                Size             = UDim2.new(1, -10, 0, 22),
                Position         = UDim2.new(0, 10, 0, 4),
                BackgroundTransparency = 1,
                Text             = config.Name or "Input",
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Row,
            })

            local Box = Create("TextBox", {
                Size             = UDim2.new(1, -20, 0, 22),
                Position         = UDim2.new(0, 10, 0, 26),
                BackgroundColor3 = Theme.Background,
                Text             = config.Default or "",
                PlaceholderText  = config.Placeholder or "...",
                TextColor3       = Theme.Text,
                PlaceholderColor3 = Theme.TextDim,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                BorderSizePixel  = 0,
                Parent           = Row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box })

            if live then
                Box:GetPropertyChangedSignal("Text"):Connect(function() cb(Box.Text) end)
            else
                Box.FocusLost:Connect(function() cb(Box.Text) end)
            end

            return { SetValue = function(_, v) Box.Text = v end }
        end

        -- ColorPicker (simple hex circle swatch row)
        function Tab:CreateColorPicker(config)
            config = config or {}
            local cb    = config.Callback or function() end
            local curC  = config.Default  or Color3.fromRGB(255, 255, 255)

            local Row = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Input_BG,
                BorderSizePixel  = 0,
                Parent           = Page,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Row })

            Create("TextLabel", {
                Size             = UDim2.new(1, -60, 1, 0),
                Position         = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text             = config.Name or "Color",
                TextColor3       = Theme.Text,
                Font             = Enum.Font.Gotham,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Row,
            })

            local Swatch = Create("Frame", {
                Size             = UDim2.new(0, 24, 0, 24),
                Position         = UDim2.new(1, -34, 0.5, -12),
                BackgroundColor3 = curC,
                BorderSizePixel  = 0,
                Parent           = Row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Swatch })
            Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Swatch })

            -- Basic palette popup (22 colors)
            local palette = {
                Color3.fromRGB(0,162,255), Color3.fromRGB(255,50,50),
                Color3.fromRGB(50,220,100), Color3.fromRGB(255,200,0),
                Color3.fromRGB(200,50,255), Color3.fromRGB(255,120,0),
                Color3.fromRGB(0,230,230), Color3.fromRGB(255,255,255),
                Color3.fromRGB(0,0,0), Color3.fromRGB(100,100,100),
            }

            local Popup = Create("Frame", {
                Size             = UDim2.new(0, 160, 0, 0),
                Position         = UDim2.new(1, -168, 1, 4),
                BackgroundColor3 = Theme.Dropdown_BG,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                ZIndex           = 20,
                Parent           = Row,
            })
            Create("UICorner",  { CornerRadius = UDim.new(0, 6), Parent = Popup })
            Create("UIGridLayout", {
                CellSize    = UDim2.new(0, 24, 0, 24),
                CellPaddingX = UDim.new(0, 4),
                CellPaddingY = UDim.new(0, 4),
                Parent      = Popup,
            })
            Create("UIPadding", {
                PaddingTop   = UDim.new(0, 4),
                PaddingLeft  = UDim.new(0, 4),
                Parent       = Popup,
            })

            for _, c in ipairs(palette) do
                local S = Create("TextButton", {
                    Size             = UDim2.new(0, 24, 0, 24),
                    BackgroundColor3 = c,
                    Text             = "",
                    BorderSizePixel  = 0,
                    ZIndex           = 21,
                    Parent           = Popup,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = S })
                S.MouseButton1Click:Connect(function()
                    curC = c
                    Swatch.BackgroundColor3 = c
                    Tween(Popup, { Size = UDim2.new(0, 160, 0, 0) })
                    cb(c)
                end)
            end

            local popupOpen = false
            local SwBtn = Create("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = 2,
                Parent             = Swatch,
            })
            SwBtn.MouseButton1Click:Connect(function()
                popupOpen = not popupOpen
                local rows = math.ceil(#palette / 5)
                local h    = popupOpen and (rows * 28 + 8) or 0
                Tween(Popup, { Size = UDim2.new(0, 160, 0, h) })
            end)

            return { SetValue = function(_, c)
                curC = c
                Swatch.BackgroundColor3 = c
                cb(c)
            end }
        end

        -- Label
        function Tab:CreateLabel(text)
            Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text             = text or "",
                TextColor3       = Theme.TextDim,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Page,
            })
        end

        return Tab
    end

    return Window
end

return Pegasushub
