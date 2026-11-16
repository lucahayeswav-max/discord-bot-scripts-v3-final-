local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local CoreGui=game:GetService("CoreGui")
local LP=Players.LocalPlayer

local UILib = {}

UILib.Theme={Bg=Color3.fromRGB(12,10,18),Panel=Color3.fromRGB(22,18,30),Accent=Color3.fromRGB(145,75,255),Text=Color3.fromRGB(255,255,255),Muted=Color3.fromRGB(150,150,160),Off=Color3.fromRGB(50,45,60),Border=Color3.fromRGB(80,50,120),Glass=Color3.fromRGB(30,25,40)}
UILib.Presets={Purple=Color3.fromRGB(145,75,255),Crimson=Color3.fromRGB(255,50,80),Blue=Color3.fromRGB(50,150,255),Green=Color3.fromRGB(50,255,100),Dark=Color3.fromRGB(100,100,100)}

function UILib.MakeSection(parent,title,x,y,w,h)
    local T=UILib.Theme
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.fromOffset(w,h)
    f.Position=UDim2.fromOffset(x,y)
    f.BackgroundColor3=T.Panel
    f.BackgroundTransparency=0.2
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke",f)
    s.Color=T.Border
    s.Thickness=1
    if title~="" then
        local t=Instance.new("TextLabel",f)
        t.Size=UDim2.new(1,-20,0,25)
        t.Position=UDim2.fromOffset(15,10)
        t.BackgroundTransparency=1
        t.Text=title
        t.TextColor3=T.Text
        t.Font=Enum.Font.GothamBold
        t.TextSize=14
        t.TextXAlignment=Enum.TextXAlignment.Left
    end
    return f
end

function UILib.MakeToggle(parent,text,y,cb)
    local T=UILib.Theme
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-30,0,25)
    row.Position=UDim2.fromOffset(15,y)
    row.BackgroundTransparency=1
    local l=Instance.new("TextLabel",row)
    l.Size=UDim2.new(1,-40,1,0)
    l.BackgroundTransparency=1
    l.Text=text
    l.TextColor3=T.Text
    l.Font=Enum.Font.Gotham
    l.TextSize=13
    l.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.fromOffset(36,20)
    btn.Position=UDim2.new(1,-36,0.5,-10)
    btn.BackgroundColor3=T.Off
    btn.Text=""
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame",btn)
    dot.Size=UDim2.fromOffset(16,16)
    dot.Position=UDim2.fromOffset(2,2)
    dot.BackgroundColor3=T.Text
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local st=false
    btn.MouseButton1Click:Connect(function()
        st=not st
        TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=st and T.Accent or T.Off}):Play()
        TweenService:Create(dot,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-18,0,2) or UDim2.fromOffset(2,2)}):Play()
        cb(st)
    end)
end

function UILib.MakeSlider(parent,text,y,min,max,def,cb)
    local T=UILib.Theme
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,-30,0,40)
    f.Position=UDim2.fromOffset(15,y)
    f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,0,20)
    l.BackgroundTransparency=1
    l.Text=text..": "..def
    l.TextColor3=T.Text
    l.Font=Enum.Font.Gotham
    l.TextSize=12
    l.TextXAlignment=Enum.TextXAlignment.Left
    local bg=Instance.new("Frame",f)
    bg.Size=UDim2.new(1,0,0,4)
    bg.Position=UDim2.fromOffset(0,25)
    bg.BackgroundColor3=T.Off
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",bg)
    fill.Size=UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3=T.Accent
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",bg)
    knob.Size=UDim2.fromOffset(12,12)
    knob.Position=UDim2.new((def-min)/(max-min),-6,0.5,-6)
    knob.BackgroundColor3=T.Text
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local dr=false
    local function upd(i)
        local p=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
        fill.Size=UDim2.new(p,0,1,0)
        knob.Position=UDim2.new(p,-6,0.5,-6)
        local v=math.floor(min+(p*(max-min)))
        l.Text=text..": "..v
        cb(v)
    end
    bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true;upd(i) end end)
    UserInputService.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
end

function UILib.MakeBtn(parent,text,y,cb)
    local T=UILib.Theme
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,-30,0,35)
    b.Position=UDim2.fromOffset(15,y)
    b.BackgroundColor3=T.Accent
    b.Text=text
    b.TextColor3=T.Text
    b.Font=Enum.Font.GothamBold
    b.TextSize=13
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(cb)
end

return UILib