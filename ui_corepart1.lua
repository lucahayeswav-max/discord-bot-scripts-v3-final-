local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local CoreGui=game:GetService("CoreGui")
local LP=Players.LocalPlayer
local UILib={}
UILib.Theme={Bg=Color3.fromRGB(12,10,18),Panel=Color3.fromRGB(22,18,30),Accent=Color3.fromRGB(145,75,255),Text=Color3.fromRGB(255,255,255),Muted=Color3.fromRGB(150,150,160),Off=Color3.fromRGB(50,45,60),Border=Color3.fromRGB(80,50,120),Glass=Color3.fromRGB(30,25,40)}
function UILib.MakeSection(parent,title,x,y,w,h)
    local f=Instance.new("Frame",parent); f.Size=UDim2.fromOffset(w,h); f.Position=UDim2.fromOffset(x,y); f.BackgroundColor3=UILib.Theme.Panel; f.BackgroundTransparency=0.2
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10); local s=Instance.new("UIStroke",f); s.Color=UILib.Theme.Border; s.Thickness=1
    if title~="" then local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-20,0,25); l.Position=UDim2.fromOffset(15,10); l.BackgroundTransparency=1; l.Text=title; l.TextColor3=UILib.Theme.Text; l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left end
    return f
end
return UILib