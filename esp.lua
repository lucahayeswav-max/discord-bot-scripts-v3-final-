local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createBox(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = Vector3.new(4, 6, 1)
    box.Color3 = Color3.new(1, 0, 0) -- red
    box.Transparency = 0.5
    box.Parent = hrp
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createBox(player)
    end
end

print("ESP loaded.")