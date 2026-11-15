-- NOVAHUB: Blox Fruits UI Clone
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Cleanup
local oldGui = CoreGui:FindFirstChild("NOVAHUB")
if oldGui then oldGui:Destroy() end

-- Theme (Matching the picture exactly)
local Theme = {
    Bg = Color3.fromRGB(24, 24, 27),          -- Dark grey background
    SidebarBg = Color3.fromRGB(18, 18, 20),   -- Slightly darker sidebar
    PanelBg = Color3.fromRGB(33, 33, 36),     -- Section blocks / Buttons
    Accent = Color3.fromRGB(138, 43, 226),    -- Purple accent
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(170, 170, 170),
    ToggleOff = Color3.fromRGB(75, 75, 80),
    Line = Color3.fromRGB(50, 50, 55)
}

-- 1. Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NOVAHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 650, 0, 400)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Theme.Accent
Stroke.Thickness = 1.5

-- Window Dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 2. Top Bar & Header
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1

-- Crown Icon (using Text label with emoji for simplicity without external images)
local Crown = Instance.new("TextLabel", TopBar)
Crown.Size = UDim2.new(0, 30, 0, 30)
Crown.Position = UDim2.new(0, 20, 0.5, -15)
Crown.BackgroundTransparency = 1
Crown.Text = "👑"
Crown.TextColor3 = Theme.Accent
Crown.TextSize = 24

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.Position = UDim2.new(0, 55, 0.5, -10)
Title.BackgroundTransparency = 1
Title.Text = "NOVAHUB"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", TopBar)
SubTitle.Size = UDim2.new(0, 200, 0, 15)
SubTitle.Position = UDim2.new(0, 55, 0.5, 5)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Script Hub"
SubTitle.TextColor3 = Theme.Accent
SubTitle.Font = Enum.Font.GothamSemibold
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Min/Max/Close buttons
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Accent
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "−"
MinBtn.TextColor3 = Theme.Accent
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18

-- 3. Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Theme.SidebarBg
Sidebar.BorderSizePixel = 0

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -160, 1, -40)
ContentArea.Position = UDim2.new(0, 160, 0, 40)
ContentArea.BackgroundTransparency = 1

-- 4. Sidebar Tabs Builder
local Tabs = {"Home", "Farming", "Combat", "Teleport", "Shop", "Misc", "Settings"}
local TabIcons = {"⌂", "⚙", "⚔", "💎", "👕", "★", "⚙"} -- Text icons matching the picture
local TabButtons = {}
local Pages = {}

local function createSidebarTab(name, iconText, yPos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Theme.Bg
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0.5, -15)
    icon.BackgroundTransparency = 1
    icon.Text = iconText
    icon.TextColor3 = Theme.Accent
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 40, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Theme.SubText
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Page frame
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, -40, 1, -20)
    page.Position = UDim2.new(0, 20, 0, 10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.Visible = false
    page.Name = name
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    table.insert(TabButtons, btn)
    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(TabButtons) do
            b.BackgroundTransparency = 1
            b:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("TextLabel") -- dummy to break scope
            b:GetChildren()[2].TextColor3 = Theme.SubText -- Label
        end
        for _, p in pairs(Pages) do p.Visible = false end
        
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Theme.PanelBg
        btn:GetChildren()[2].TextColor3 = Theme.Accent
        page.Visible = true
    end)
end

for i, tabName in ipairs(Tabs) do
    createSidebarTab(tabName, TabIcons[i], (i - 1) * 45 + 10)
end

-- 5. UI Elements
local function createSection(parent, title, yPos)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = Theme.PanelBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 4, 0, 16)
    accent.Position = UDim2.new(0, 15, 0.5, -8)
    accent.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 30, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return frame
end

local function createToggle(parent, text, yPos, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Theme.PanelBg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("TextButton", frame)
    switch.Size = UDim2.new(0, 40, 0, 22)
    switch.Position = UDim2.new(1, -55, 0.5, -11)
    switch.BackgroundColor3 = default and Theme.Accent or Theme.ToggleOff
    switch.Text = ""
    switch.AutoButtonColor = false
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Theme.Text
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = default
    switch.MouseButton1Click:Connect(function()
        state = not state
        local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(switch, tween, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}):Play()
        TweenService:Create(circle, tween, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        callback(state)
    end)
end

local function createDropdown(parent, text, options, yPos, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Theme.PanelBg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -150, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local dropBtn = Instance.new("TextButton", frame)
    dropBtn.Size = UDim2.new(0, 120, 0, 30)
    dropBtn.Position = UDim2.new(1, -135, 0.5, -15)
    dropBtn.BackgroundColor3 = Theme.Bg
    dropBtn.Text = options[1]
    dropBtn.TextColor3 = Theme.Text
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.TextSize = 13
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)

    local isOpen = false
    local dropMenu = Instance.new("Frame", frame)
    dropMenu.Size = UDim2.new(0, 120, 0, #options * 30)
    dropMenu.Position = UDim2.new(1, -135, 1, 0)
    dropMenu.BackgroundColor3 = Theme.SidebarBg
    dropMenu.Visible = false
    dropMenu.ZIndex = 10
    Instance.new("UICorner", dropMenu).CornerRadius = UDim.new(0, 4)

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropMenu)
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = opt
        optBtn.TextColor3 = Theme.SubText
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 13
        optBtn.ZIndex = 11
        
        optBtn.MouseEnter:Connect(function() optBtn.TextColor3 = Theme.Text end)
        optBtn.MouseLeave:Connect(function() optBtn.TextColor3 = Theme.SubText end)
        optBtn.MouseButton1Click:Connect(function()
            dropBtn.Text = opt
            dropMenu.Visible = false
            isOpen = false
            callback(opt)
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropMenu.Visible = isOpen
    end)
end

-- 6. Build Content Pages
-- Home
local Home = Pages["Home"]
createSection(Home, "Welcome!", 0)
local welcomeDesc = Instance.new("TextLabel", Home)
welcomeDesc.Size = UDim2.new(1, -20, 0, 40)
welcomeDesc.Position = UDim2.new(0, 10, 0, 55)
welcomeDesc.BackgroundTransparency = 1
welcomeDesc.Text = "Enjoy your time in Blox Fruits! 👑"
welcomeDesc.TextColor3 = Theme.SubText
welcomeDesc.Font = Enum.Font.Gotham
welcomeDesc.TextSize = 14
welcomeDesc.TextXAlignment = Enum.TextXAlignment.Left

-- Farming
local Farm = Pages["Farming"]
createSection(Farm, "Farming", 0)
createToggle(Farm, "Auto Farm", 55, false, function(s) print("Auto Farm:", s) end)
createDropdown(Farm, "Select Method", {"Level", "Boss", "Chest"}, 110, function(opt) print("Method:", opt) end)
createToggle(Farm, "Auto Set Spawn", 165, false, function(s) print("Auto Set Spawn:", s) end)

-- Combat
local Combat = Pages["Combat"]
createSection(Combat, "Combat", 0)
createToggle(Combat, "Auto Bounty", 55, false, function(s) print("Auto Bounty:", s) end)
createToggle(Combat, "Auto Sword", 110, false, function(s) print("Auto Sword:", s) end)
createToggle(Combat, "Auto Gun", 165, false, function(s) print("Auto Gun:", s) end)

-- Teleport, Shop, Misc
local Teleport = Pages["Teleport"]
createSection(Teleport, "Teleport", 0)

local Shop = Pages["Shop"]
createSection(Shop, "Shop", 0)

local Misc = Pages["Misc"]
createSection(Misc, "Misc", 0)

-- Settings
local Settings = Pages["Settings"]
createSection(Settings, "Settings", 0)
createToggle(Settings, "Auto Stats", 55, false, function(s) print("Auto Stats:", s) end)

-- Auto-size pages
for _, page in pairs(Pages) do
    page.CanvasSize = UDim2.new(0, 0, 0, #page:GetChildren() * 60 + 50)
end

-- Initial Tab Active State (Home)
TabButtons[1].BackgroundTransparency = 0
TabButtons[1].BackgroundColor3 = Theme.PanelBg
TabButtons[1]:GetChildren()[2].TextColor3 = Theme.Accent
Pages["Home"].Visible = true