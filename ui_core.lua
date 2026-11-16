local part1=loadstring(game:HttpGet("https://raw.githubusercontent.com/lucahayeswav-max/discord-bot-scripts-v3-final-/main/ui_part1.lua"))()
local part2=loadstring(game:HttpGet("https://raw.githubusercontent.com/lucahayeswav-max/discord-bot-scripts-v3-final-/main/ui_part2.lua"))()
local UILib={}
UILib.Theme=part1.Theme
UILib.Presets={Purple=Color3.fromRGB(145,75,255),Crimson=Color3.fromRGB(255,50,80),Blue=Color3.fromRGB(50,150,255),Green=Color3.fromRGB(50,255,100),Dark=Color3.fromRGB(100,100,100)}
UILib.MakeSection=part1.MakeSection
UILib.MakeToggle=part2.MakeToggle
UILib.MakeSlider=part2.MakeSlider
UILib.MakeBtn=part2.MakeBtn
return UILib