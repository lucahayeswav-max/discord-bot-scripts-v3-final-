-- NOVAHUB: Blox Fruits Premium (Tabs + Melee Combat + Config)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local States = { KillAura = false, AutoStats = false, FastAttack = false }
local Config = { AttackRange = 30, AttackSpeed = 0.1, StatTarget = "Melee" }
local Connections = {}

-- Cleanup
local oldGui = game:GetService("CoreGui"):FindFirstChild("NOVAHUB")
if oldGui then oldGui:Destroy() end
for _, c in pairs(Connections) do if c then c:Disconnect() end end
table.clear(Connections)

-- 1. UI Framework
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NOVAHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 340)
MainFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2

-- Header
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NOVAHUB | BLOX FRUITS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 15, 0, 0)

-- Tab Buttons Container
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, -30, 0, 30)
TabFrame.Position = UDim2.new(0, 15, 0, 45)
TabFrame.BackgroundTransparency = 1

local function createTabBtn(text, xPos)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0, 85, 1, 0)
    btn.Position = UDim2.new(0, xPos, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local HomeTabBtn = createTabBtn("Home", 0)
local CombatTabBtn = createTabBtn("Combat", 90)
local ConfigTabBtn = createTabBtn("Config", 180)

-- Content Container
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -30, 1, -90)
ContentFrame.Position = UDim2.new(0, 15, 0, 85)
ContentFrame.BackgroundTransparency = 1

-- Helper: Toggle Button
local function createToggle(parent, name, yPos, defaultState)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    btn.TextColor3 = defaultState and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    States[name] = defaultState
    btn.MouseButton1Click:Connect(function()
        States[name] = not States[name]
        btn.Text = name .. (States[name] and ": ON" or ": OFF")
        btn.TextColor3 = States[name] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(200, 200, 200)
        btn.BackgroundColor3 = States[name] and Color3.fromRGB(20, 40, 60) or Color3.fromRGB(30, 30, 30)
    end)
    return btn
end

-- Helper: Slider
local function createSlider(parent, text, yPos, min, max, defaultVal, callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. defaultVal
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", parent)
    bg.Size = UDim2.new(1, 0, 0, 8)
    bg.Position = UDim2.new(0, 0, 0, yPos + 25)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local knob = Instance.new("Frame", bg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultVal - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        local val = math.floor(min + (pos * (max - min)))
        label.Text = text .. ": " .. val
        callback(val)
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

-- 2. Build Tabs
local HomeTab = Instance.new("Frame", ContentFrame)
HomeTab.Size = UDim2.new(1, 0, 1, 0); HomeTab.BackgroundTransparency = 1
createToggle(HomeTab, "AutoStats", 0, false)

local CombatTab = Instance.new("Frame", ContentFrame)
CombatTab.Size = UDim2.new(1, 0, 1, 0); CombatTab.BackgroundTransparency = 1; CombatTab.Visible = false
createToggle(CombatTab, "FastAttack", 0, false)
createToggle(CombatTab, "KillAura", 50, false)

local ConfigTab = Instance.new("Frame", ContentFrame)
ConfigTab.Size = UDim2.new(1, 0, 1, 0); ConfigTab.BackgroundTransparency = 1; ConfigTab.Visible = false
createSlider(ConfigTab, "Attack Range", 0, 5, 100, Config.AttackRange, function(v) Config.AttackRange = v end)
createSlider(ConfigTab, "Attack Speed (x100)", 60, 1, 50, 10, function(v) Config.AttackSpeed = v / 100 end)

-- Tab Switching Logic
local function setTab(activeBtn, activeFrame)
    for _, b in pairs({HomeTabBtn, CombatTabBtn, ConfigTabBtn}) do
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    for _, f in pairs({HomeTab, CombatTab, ConfigTab}) do f.Visible = false end
    activeBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 60); activeBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
    activeFrame.Visible = true
end

HomeTabBtn.MouseButton1Click:Connect(function() setTab(HomeTabBtn, HomeTab) end)
CombatTabBtn.MouseButton1Click:Connect(function() setTab(CombatTabBtn, CombatTab) end)
ConfigTabBtn.MouseButton1Click:Connect(function() setTab(ConfigTabBtn, ConfigTab) end)
setTab(HomeTabBtn, HomeTab) -- Default tab

-- 3. Logic
-- Auto Stats
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not States.AutoStats then return end
    local args = { [1] = "AddPoint", [2] = Config.StatTarget }
    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args)) end)
    task.wait(0.4)
end))

-- Melee Combat Remote Helper
local function doMeleeAttack()
    local combatRemote = ReplicatedStorage:FindFirstChild("Combat")
    if combatRemote and combatRemote:FindFirstChild("RemoteEvent") then
        -- Spoofs a standard melee click hit
        combatRemote.RemoteEvent:FireServer("Button1", true)
    end
end

-- Fast Attack
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if States.FastAttack then
        doMeleeAttack()
        task.wait(Config.AttackSpeed)
    end
end))

-- Kill Aura
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not States.KillAura then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local dist = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if dist <= Config.AttackRange then
                doMeleeAttack()
            end
        end
    end
end))

print("NOVAHUB Premium loaded.")