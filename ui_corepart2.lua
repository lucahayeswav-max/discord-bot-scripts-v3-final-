local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local UILib={}
UILib.Theme={Bg=Color3.fromRGB(12,10,18),Panel=Color3.fromRGB(22,18,30),Accent=Color3.fromRGB(145,75,255),Text=Color3.fromRGB(255,255,255),Muted=Color3.fromRGB(150,150,160),Off=Color3.fromRGB(50,45,60),Border=Color3.fromRGB(80,50,120),Glass=Color3.fromRGB(30,25,40)}
function UILib.MakeToggle(parent,text,y,cb)
    local r=Instance.new("Frame",parent); r.Size=UDim2.new(1,-30,0,25); r.Position=UDim2.fromOffset(15,y); r.BackgroundTransparency=1
    local l=Instance.new("TextLabel",r); l.Size=UDim2.new(1,-40,1,0); l.BackgroundTransparency=1; l.Text=text; l.TextColor3=UILib.Theme.Text; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    local b=Instance.new("TextButton",r); b.Size=UDim2.fromOffset(36,20); b.Position=UDim2.new(1,-36,0.5,-10); b.BackgroundColor3=UILib.Theme.Off; b.Text=""
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    local d=Instance.new("Frame",b); d.Size=UDim2.fromOffset(16,16); d.Position=UDim2.fromOffset(2,2); d.BackgroundColor3=UILib.Theme.Text; Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local st=false
    b.MouseButton1Click:Connect(function() st=not st TweenService:Create(b,TweenInfo.new(0.2),{BackgroundColor3=st and UILib.Theme.Accent or UILib.Theme.Off}):Play() TweenService:Create(d,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-18,0,2) or UDim2.fromOffset(2,2)}):Play() cb(st) end)
end
function UILib.MakeSlider(parent,text,y,min,max,def,cb)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,-30,0,40); f.Position=UDim2.fromOffset(15,y); f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,0,20); l.BackgroundTransparency=1; l.Text=text..": "..def; l.TextColor3=UILib.Theme.Text; l.Font=Enum.Font.Gotham; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left
    local bg=Instance.new("Frame",f); bg.Size=UDim2.new(1,0,0,4); bg.Position=UDim2.fromOffset(0,25); bg.BackgroundColor3=UILib.Theme.Off; Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local fl=Instance.new("Frame",bg); fl.Size=UDim2.new((def-min)/(max-min),0,1,0); fl.BackgroundColor3=UILib.Theme.Accent; Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame",bg); kn.Size=UDim2.fromOffset(12,12); kn.Position=UDim2.new((def-min)/(max-min),-6,0.5,-6); kn.BackgroundColor3=UILib.Theme.Text; Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local dr=false
    local function u(i) local pos=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1) fl.Size=UDim2.new(pos,0,1,0) kn.Position=UDim2.new(pos,-6,0.5,-6) local v=math.floor(min+(pos*(max-min))) l.Text=text..": "..v cb(v) end
    bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true;u(i) end end)
    UserInputService.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then u(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
end
function UILib.MakeBtn(parent,text,y,cb)
    local b=Instance.new("TextButton",parent); b.Size=UDim2.new(1,-30,0,35); b.Position=UDim2.fromOffset(15,y); b.BackgroundColor3=UILib.Theme.Accent; b.Text=text; b.TextColor3=UILib.Theme.Text; b.Font=Enum.Font.GothamBold; b.TextSize=13
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6); b.MouseButton1Click:Connect(cb)
end
return UILib