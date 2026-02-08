local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChild("Humanoid")
local RootPart = Character:FindFirstChild("HumanoidRootPart")

local MainPlot = workspace.Plots:FindFirstChild(LocalPlayer:GetAttribute("PlotName"))

local shoptable = {}

for _, v in ipairs(game:GetService("ReplicatedStorage").Assets.Placements:GetChildren()) do
	table.insert(shoptable, v.Name)
end

--[[-----------------------------------------------------------------------------------------
										User Interface
]]-------------------------------------------------------------------------------------------


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()

local Options = Library.Options

local MainWindow = Library:CreateWindow({
    Title = "Build A Pet Factory",
    Footer = "version: v0.1",
    NotifySide = "Right",
	Resizable = false,
})

local Tabs = {
	HomeTab = MainWindow:AddTab("Home", "house"),
	AutomationTab = MainWindow:AddTab("Automation", "chart-spline"),
    UserInterfaceSettings = MainWindow:AddTab("UI Settings", "settings"),
}


--[[-----------------------------------------------------------------------------------------
										Home Tab
]]-------------------------------------------------------------------------------------------

local currentTime = 0

local UserBox = Tabs.HomeTab:AddLeftGroupbox("User", "user-round")
local CreditBox = Tabs.HomeTab:AddRightGroupbox("Credits", "copyright")

local UserPhoto = UserBox:AddImage("UserPhoto", {
    Image = "http://www.roblox.com/asset/?id=135666356081915",
    Height = 200,
})

local UserPhotoSize = Enum.ThumbnailSize.Size420x420
local UserPhotoType = Enum.ThumbnailType.HeadShot
local UserImage = game.Players:GetUserThumbnailAsync(LocalPlayer.UserId, UserPhotoType, UserPhotoSize)

UserPhoto:SetImage(UserImage)

UserBox:AddLabel("Welcome <b>".. LocalPlayer.Name .. "</b>, Have fun with o_8uzi's [🧸] Build A Pet Factory Script!", true)

UserBox:AddDivider()

local UptimeLabel = UserBox:AddLabel("Uptime : 00:00:00", true)

CreditBox:AddLabel("[<font color=\"rgb(73, 230, 133)\">@o_8uzi</font>] Main Developer / Scripter", true)

CreditBox:AddDivider()

CreditBox:AddButton("Copy Discord Link", function()
    setclipboard("https://discord.gg/2pMVqDQBzC")
end)

local function formatTime(currentTime)
	local hours = math.floor(currentTime / 3600)
	local minutes = math.floor((currentTime - (hours * 3600))/60)
	local seconds = (currentTime - (hours * 3600) - (minutes * 60))
	local format = "%02d:%02d:%02d"
	return format:format(hours, minutes, seconds)
end

local function startTimer(currentTime)
	while true do
		currentTime += 1
		UptimeLabel:SetText("Uptime : ".. formatTime(currentTime))
		task.wait(1)
	end
end

-- RNAODM IDFK

local UIMenu = Tabs.UserInterfaceSettings:AddLeftGroupbox("Menu", "wrench")

UIMenu:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})

UIMenu:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})

UIMenu:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

UIMenu:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

UIMenu:AddDivider()
UIMenu:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

UIMenu:AddButton("Unload", function()
	Library:Unload()
end)


--[[-----------------------------------------------------------------------------------------
										Automation Tab
]]-------------------------------------------------------------------------------------------


local ShopBox = Tabs.AutomationTab:AddRightGroupbox("Shop", "store")
local PlotBox = Tabs.AutomationTab:AddLeftGroupbox("Plot", "grid-2x2")
local RebirthBox = Tabs.AutomationTab:AddLeftGroupbox("Rebirths", "trophy")

local AutoBuyShop = false
local CashDelay = 10
local AutoCollectCash = false
local AutoRebirth = false
local AutoCollectBoxes = false

local SBToggle = ShopBox:AddToggle("ShopToggle", {
	Text = "Auto Buy Shop",
	Default = false,
})

local CollectCashToggle = PlotBox:AddToggle("CollectCashToggle", {
	Text = "Auto Collect Cash",
	Default = false,
})

local RebirthToggle = RebirthBox:AddToggle("CollectCashToggle", {
	Text = "Auto Rebirth",
	Default = false,
})


RebirthToggle:OnChanged(function(state)
    AutoRebirth = state
end)

SBToggle:OnChanged(function(state)
    AutoBuyShop = state
end)

CollectCashToggle:OnChanged(function(state)
    AutoCollectCash = state
end)

local DelaySlider1 = PlotBox:AddSlider("DelaySlider1", {
    Text = "Delay",
    Default = 10,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = true,
})

Options.DelaySlider1:OnChanged(function(value)
    CashDelay = value
end)

PlotBox:AddDivider()

local PetToggle = PlotBox:AddToggle("ShopToggle", {
	Text = "Auto Pet Collecters",
	Default = false,
})

PetToggle:OnChanged(function(state)
    AutoCollectBoxes = state
end)

local ShopDropdown = ShopBox:AddDropdown("MyDropdown", {
    Values = {  },
    Default = nil,
    Multi = true,
    Text = "Items to Buy",
})

for _, v in ipairs(shoptable) do
	ShopDropdown:AddValues(v)
end

local AutoBuyShopDebounce = false

task.spawn(function()
	while task.wait() do
		if AutoBuyShop then
			if AutoBuyShopDebounce == false then
				AutoBuyShopDebounce = true
				for key, value in next, Options.MyDropdown.Value do
					if AutoBuyShop == false then
						break
					end
					local args = {
						key
					}
					game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PurchaseBuilding"):FireServer(unpack(args))
				end
				AutoBuyShopDebounce = false
				task.wait(0.2)
			end
		end
	end
end)

task.spawn(function()
	while task.wait() do
		if AutoCollectCash then
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CollectCash"):FireServer()
			task.wait(CashDelay)
		end
	end
end)

task.spawn(function()
	while task.wait() do
		if AutoRebirth then
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Rebirth"):FireServer()
		end
			task.wait(1)
	end
end)

task.spawn(function()
	while task.wait() do
		if AutoCollectBoxes then
			for _, v in ipairs(workspace.Plots.Plot3.Placements:GetChildren()) do
				if v:FindFirstChildOfClass("ProximityPrompt") then
					local Prox = v:FindFirstChildOfClass("ProximityPrompt")
					if Prox:FindFirstChild("CollectorBillboardGui") then
						Prox.MaxActivationDistance = 9e9
						Prox.Exclusivity = "AlwaysShow"
						fireproximityprompt(Prox)
					end
				end
			end
		end
	end
end)

--[[-----------------------------------------------------------------------------------------
										Scripting
]]-------------------------------------------------------------------------------------------


SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.UserInterfaceSettings)
SaveManager:LoadAutoloadConfig()

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs.UserInterfaceSettings)
ThemeManager:LoadDefault()

startTimer(0)
