-- NOVAHUB Mobile UI v2 | Fly fixed + Speed Slider
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Core State
local States = { ESP = false, Aimbot = false, Fly = false }
local CurrentSpeed = 16
local ESPObjects = {}
local Connections = {}

-- Cleanup
local oldGui = game:GetService("CoreGui"):FindFirstChild("NOVAHUB")
if oldGui then oldGui:Destroy() end
for _, c in pairs(Connections) do if c then c:Disconnect() end end
table.clear(Connections)

-- 1. Build the GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NOVAHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(180, 0, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
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

-- Toggle Helper
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
        btn.TextColor3 = States[name] and Color3.fromRGB(180, 0, 255) or Color3.fromRGB(200, 200, 200)
        btn.BackgroundColor3 = States[name] and Color3.fromRGB(45, 25, 55) or Color3.fromRGB(30, 30, 30)
    end)
end

createToggle("ESP", 55)
createToggle("Aimbot", 105)
createToggle("Fly", 155)

-- 2. Speed Slider
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -30, 0, 20)
SpeedLabel.Position = UDim2.new(0, 15, 0, 210)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, -30, 0, 10)
SliderBg.Position = UDim2.new(0, 15, 0, 240)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SliderBg.Parent = MainFrame
local SliderBgCorner = Instance.new("UICorner")
SliderBgCorner.CornerRadius = UDim.new(0, 5)
SliderBgCorner.Parent = SliderBg

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
SliderFill.Parent = SliderBg
local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 5)
SliderFillCorner.Parent = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 20, 0, 20)
SliderKnob.Position = UDim2.new(0, -10, 0.5, -10)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Parent = SliderBg
local SliderKnobCorner = Instance.new("UICorner")
SliderKnobCorner.CornerRadius = UDim.new(1, 0)
SliderKnobCorner.Parent = SliderKnob

local isDragging = false
local function updateSlider(input)
    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
    SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
    CurrentSpeed = math.floor(16 + (pos * (400 - 16))) -- Min 16, Max 400
    SpeedLabel.Text = "Speed: " .. CurrentSpeed
end

SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        updateSlider(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- 3. Logic Loops
-- ESP
table.insert(Connections, RunService.Heartbeat:Connect(function()
    for _, obj in pairs(ESPObjects) do if obj then obj:Destroy() end end
    table.clear(ESPObjects)
    if not States.ESP then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Adornee = player.Character.HumanoidRootPart
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Size = Vector3.new(4, 6, 1)
            box.Color3 = Color3.new(1, 0, 0)
            box.Transparency = 0.5
            box.Parent = player.Character.HumanoidRootPart
            table.insert(ESPObjects, box)
        end
    end
end))

-- Speed
table.insert(Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = CurrentSpeed
    end
end))

-- Fly (Mobile friendly hover)
local flyBodyVelocity = nil
table.insert(Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if States.Fly and hrp then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBodyVelocity.Parent = hrp
        end
        -- Hover up slightly, keeping forward momentum if the player moves
        local moveDir = char.Humanoid.MoveDirection
        flyBodyVelocity.Velocity = Vector3.new(moveDir.X * 50, 20, moveDir.Z * 50)
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
    end
end))

-- Aimbot
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if States.Aimbot then
        local closest, shortestDist = nil, math.huge
        local center = Camera.ViewportSize / 2

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist and dist < 250 then
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
end))