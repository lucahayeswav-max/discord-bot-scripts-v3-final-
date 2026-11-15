-- NOVAHUB Mobile UI | Built for @6qq99
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Core State
local States = { ESP = false, Aimbot = false, Fly = false, Speed = false }
local ESPObjects = {}
local FlyConnection = nil
local AimConnection = nil

-- Cleanup old GUI if re-executing
local oldGui = coreGui and coreGui:FindFirstChild("NOVAHUB") or game:GetService("CoreGui"):FindFirstChild("NOVAHUB")
if oldGui then oldGui:Destroy() end

-- 1. Build the GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NOVAHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0) -- Left side, out of the way for mobile
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(180, 0, 255) -- Neon Purple
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NOVAHUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Parent = MainFrame

local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -30, 0, 1)
TitleLine.Position = UDim2.new(0, 15, 0, 40)
TitleLine.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleLine.Parent = MainFrame

-- Helper to create buttons
local function createToggle(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
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
        if States[name] then
            btn.Text = name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(180, 0, 255)
            btn.BackgroundColor3 = Color3.fromRGB(45, 25, 55)
        else
            btn.Text = name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end
    end)
    return btn
end

createToggle("ESP", 55)
createToggle("Aimbot", 105)
createToggle("Fly", 155)
createToggle("Speed", 205)

-- 2. ESP Logic
local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj then obj:Destroy() end
    end
    table.clear(ESPObjects)
end

local function updateESP()
    clearESP()
    if not States.ESP then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "NOVA_ESP"
                box.Adornee = char.HumanoidRootPart
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Size = Vector3.new(4, 6, 1)
                box.Color3 = Color3.new(1, 0, 0)
                box.Transparency = 0.5
                box.Parent = char.HumanoidRootPart
                table.insert(ESPObjects, box)
            end
        end
    end
end
RunService.Heartbeat:Connect(updateESP)

-- 3. Fly Logic (Mobile friendly)
local function getVelocity()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

if FlyConnection then FlyConnection:Disconnect() end
FlyConnection = RunService.RenderStepped:Connect(function()
    if States.Fly then
        local hrp = getVelocity()
        if hrp then
            local moveDir = workspace.CurrentCamera.CFrame.LookVector * (UserInputService:GetFocusedTextBox() and 0 or 1)
            -- Basic hover fly
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then hrp.Velocity = Vector3.new(hrp.Velocity.X, -50, hrp.Velocity.Z) end
        end
    end
end)

-- 4. Speed Logic
if SpeedConnection then SpeedConnection:Disconnect() end
SpeedConnection = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = States.Speed and 50 or 16
    end
end)

-- 5. Aimbot Logic (Camera Lock / Mouse Lock)
if AimConnection then AimConnection:Disconnect() end
AimConnection = RunService.RenderStepped:Connect(function()
    if States.Aimbot then
        local closest = nil
        local shortestDist = math.huge
        local center = Camera.ViewportSize / 2

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist and dist < 200 then -- 200 pixel FOV
                        shortestDist = dist
                        closest = hrp
                    end
                end
            end
        end

        if closest then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closest.Position)
        end
    end
end)