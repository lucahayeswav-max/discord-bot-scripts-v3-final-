-- NOVAHUB: Blox Fruits Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Core State
local States = { KillAura = false, AutoStats = false, FastAttack = false }
local Config = { AttackRange = 30, AttackSpeed = 0.1 }
local Connections = {}

-- Cleanup
local oldGui = game:GetService("CoreGui"):FindFirstChild("NOVAHUB")
if oldGui then oldGui:Destroy() end
for _, c in pairs(Connections) do if c then c:Disconnect() end end
table.clear(Connections)

-- 1. Build the GUI (NOVAHUB)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NOVAHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 260)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 150, 255) -- Blox Fruits Blue
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NOVAHUB | Blox Fruits"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Parent = MainFrame

local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -30, 0, 1)
TitleLine.Position = UDim2.new(0, 15, 0, 40)
TitleLine.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleLine.Parent = MainFrame

local function createToggle(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 40)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = MainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        States[name] = not States[name]
        btn.Text = name .. (States[name] and ": ON" or ": OFF")
        btn.TextColor3 = States[name] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(200, 200, 200)
        btn.BackgroundColor3 = States[name] and Color3.fromRGB(20, 40, 60) or Color3.fromRGB(30, 30, 30)
    end)
end

createToggle("KillAura", 55)
createToggle("AutoStats", 105)
createToggle("FastAttack", 155)

-- 2. Logic
-- Blox Fruits Character Names (adjust if the game updates)
local EnemyNames = {"Bandit", "Monkey", "Gorilla", "Pirate", "Brute", "Boss"}

-- Kill Aura
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not States.KillAura then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            -- Blox Fruits specific enemy folder
            if v:FindFirstChild("Humanoid") then
                local dist = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if dist <= Config.AttackRange then
                    -- Basic tool activation for melee
                    if char:FindFirstChildOfClass("Tool") then
                        char:FindFirstChildOfClass("Tool"):Activate()
                    else
                        VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
                        VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                    end
                end
            end
        end
    end
end))

-- Fast Attack
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not States.FastAttack then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Tool") then
        -- Spams melee tool activation
        pcall(function()
            char:FindFirstChildOfClass("Tool"):Activate()
        end)
        task.wait(Config.AttackSpeed)
    end
end))

-- Auto Stats (Melee / Defense / Sword)
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not States.AutoStats then return end
    local args = {
        [1] = "AddPoint",
        [2] = "Melee" -- Change to "Defense", "Sword", "Gun", "Blox Fruit" as needed
    }
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
    task.wait(0.5) -- Prevent remote spam kick
end))

print("NOVAHUB Blox Fruits loaded.")