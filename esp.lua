-- NOVAHUB: Premium Blox Fruits UI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local States = { AutoStats = false, KillAura = false, FastAttack = false }
local Config = { AttackRange = 30, AttackSpeed = 0.1, StatTarget = "Melee" }
local Connections = {}

-- Cleanup
local oldGui = game:GetService("CoreGui"):FindFirstChild("NOVAHUB")
if oldGui then oldGui:Destroy() end
for _, c in pairs(Connections) do if c then c:Disconnect() end end
table.clear(Connections)

-- UI Colors
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Element = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(160, 0, 255), -- Purple
    ToggleOff = Color3.fromRGB(80, 80, 80),
    ToggleOn = Color3.fromRGB(160, 0, 255)
}

-- 1. Main GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NOVAHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 380)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Theme.Accent
UIStroke.Thickness = 1.5

-- Make Draggable
local dragging, dragInput, dragStart, startPos
local function makeDraggable(gui)
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainFrame)

-- Top Bar (Close Button)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Accent
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 5
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- 2. Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Cut off the right corners of sidebar for a flush look
local SidebarCover = Instance.new("Frame", Sidebar)
SidebarCover.Size = UDim2.new(0, 10, 1, 0)
SidebarCover.Position = UDim2.new(1, -10, 0, 0)
SidebarCover.BackgroundColor3 = Theme.Sidebar
SidebarCover.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, -20, 0, 60)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "NOVAHUB"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left

local SidebarContainer = Instance.new("ScrollingFrame", Sidebar)
SidebarContainer.Size = UDim2.new(1, 0, 1, -80)
SidebarContainer.Position = UDim2.new(0, 0, 0, 70)
SidebarContainer.BackgroundTransparency = 1
SidebarContainer.ScrollBarThickness = 0
SidebarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

-- 3. Content Area
local ContentArea = Instance.new("ScrollingFrame", MainFrame)
ContentArea.Size = UDim2.new(1, -180, 1, -40)
ContentArea.Position = UDim2.new(0, 170, 0, 30)
ContentArea.BackgroundTransparency = 1
ContentArea.ScrollBarThickness = 2
ContentArea.ScrollBarImageColor3 = Theme.Accent
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)

-- 4. UI Elements Framework
local function createTab(name, yPos, text)
    local btn = Instance.new("TextButton", SidebarContainer)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Theme.Background
    btn.BackgroundTransparency = 1
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.SubText
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2

    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.Visible = false
    page.Name = name

    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(SidebarContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundTransparency = 1
                child:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.SubText
            end
        end
        for _, child in pairs(ContentArea:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Theme.Element
        lbl.TextColor3 = Theme.Accent
        page.Visible = true
    end)
    return page
end

-- Section Header
local function createSection(page, title, yPos)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Theme.Sidebar
    frame.BackgroundTransparency = 0.5
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 10, 0.5, -8)
    accent.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return frame
end

-- Toggle Switch
local function createToggle(page, name, text, yPos, defaultState, callback)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 36, 0, 20)
    btn.Position = UDim2.new(1, -46, 0.5, -10)
    btn.BackgroundColor3 = defaultState and Theme.ToggleOn or Theme.ToggleOff
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Theme.Text
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = defaultState
    States[name] = state
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        States[name] = state
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(btn, tweenInfo, {BackgroundColor3 = Theme.ToggleOn}):Play()
            TweenService:Create(circle, tweenInfo, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            TweenService:Create(btn, tweenInfo, {BackgroundColor3 = Theme.ToggleOff}):Play()
            TweenService:Create(circle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        if callback then callback(state) end
    end)
end

-- Slider
local function createSlider(page, text, yPos, min, max, defaultVal, callback)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. defaultVal
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1, -20, 0, 6)
    bg.Position = UDim2.new(0, 10, 0, 30)
    bg.BackgroundColor3 = Theme.ToggleOff
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", bg)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((defaultVal - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        local val = math.floor(min + (pos * (max - min)))
        lbl.Text = text .. ": " .. val
        if callback then callback(val) end
    end

    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- 5. Constructing the Pages
local HomeTab = createTab("Home", 0, "Home")
createSection(HomeTab, "Welcome!", 10)
local welcomeDesc = Instance.new("TextLabel", HomeTab)
welcomeDesc.Size = UDim2.new(1, -20, 0, 40)
welcomeDesc.Position = UDim2.new(0, 10, 0, 50)
welcomeDesc.BackgroundTransparency = 1
welcomeDesc.Text = "Enjoy your time in Blox Fruits! (NOVAHUB Version)"
welcomeDesc.TextColor3 = Theme.SubText
welcomeDesc.Font = Enum.Font.Gotham
welcomeDesc.TextSize = 13
welcomeDesc.TextXAlignment = Enum.TextXAlignment.Left

local FarmTab = createTab("Farming", 50, "Farming")
createSection(FarmTab, "Farming", 10)
createToggle(FarmTab, "AutoFarm", "Auto Farm", 60, false)
createSlider(FarmTab, "Farm Range", 110, 10, 100, 30, function(v) Config.AttackRange = v end)

local CombatTab = createTab("Combat", 100, "Combat")
createSection(CombatTab, "Combat", 10)
createToggle(CombatTab, "KillAura", "Kill Aura", 60, false)
createToggle(CombatTab, "FastAttack", "Fast Attack", 110, false)
createSlider(CombatTab, "Attack Speed (x100)", 160, 1, 50, 10, function(v) Config.AttackSpeed = v / 100 end)

local TeleportTab = createTab("Teleport", 150, "Teleport")
createSection(TeleportTab, "Teleport", 10)

local ShopTab = createTab("Shop", 200, "Shop")
createSection(ShopTab, "Shop", 10)

local MiscTab = createTab("Misc", 250, "Misc")
createSection(MiscTab, "Misc", 10)

local SettingsTab = createTab("Settings", 300, "Settings")
createSection(SettingsTab, "Settings", 10)
createToggle(SettingsTab, "AutoStats", "Auto Stats", 60, false)

-- Auto-size Canvas
for _, page in pairs(ContentArea:GetChildren()) do
    if page:IsA("ScrollingFrame") then
        page.CanvasSize = UDim2.new(0, 0, 0, #page:GetChildren() * 60 + 20)
    end
end

-- 6. Logic Engine
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if States.AutoStats then
        local args = { [1] = "AddPoint", [2] = Config.StatTarget }
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args)) end)
        task.wait(0.4)
    end
end))

local function doMeleeAttack()
    local combatRemote = ReplicatedStorage:FindFirstChild("Combat")
    if combatRemote and combatRemote:FindFirstChild("RemoteEvent") then
        combatRemote.RemoteEvent:FireServer("Button1", true)
    end
end

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if States.FastAttack then
        doMeleeAttack()
        task.wait(Config.AttackSpeed)
    end
end))

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not States.KillAura then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if dist <= Config.AttackRange then doMeleeAttack() end
        end
    end
end))

-- Initial Tab Selection
HomeTabBtn = SidebarContainer:GetChildren()[1] -- gets first button
if HomeTabBtn then HomeTabBtn:GetChildren()[1].Text = "Home" end
-- Fire first click to activate
for _, btn in pairs(SidebarContainer:GetChildren()) do
    if btn:IsA("TextButton") and btn:FindFirstChild("TextLabel").Text == "Home" then
        btn.MouseButton1Click:Fire()
        break
    end
end

print("NOVAHUB Premium UI loaded.")