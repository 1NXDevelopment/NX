-- loader


-- Version: 3.2

-- Instances:
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextButton = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local UICorner_2 = Instance.new("UICorner")
local TextButton_2 = Instance.new("TextButton")
local TextLabel_2 = Instance.new("TextLabel")
local UICorner_3 = Instance.new("UICorner")

local DragDetector = Instance.new("UIDragDetector")
DragDetector.Parent = Frame
DragDetector.ActivatedCursorIcon = "rbxassetid://0"
DragDetector.CursorIcon = "rbxassetid://0"
--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(5, 4, 43)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.402263373, 0, 0.302409649, 0)
Frame.Size = UDim2.new(0, 189, 0, 275)

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = Frame

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.0687830672, 0, 0.701818168, 0)
TextButton.Size = UDim2.new(0, 163, 0, 48)
TextButton.Font = Enum.Font.Roboto
TextButton.Text = "Load"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 20.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(5, 4, 43)
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Size = UDim2.new(0, 189, 0, 50)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "NX-Free - Loader"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 25.000
-- THE LOAD BUTTON LOGIC
TextButton.MouseButton1Click:Connect(function()
	-- 1. Get the script from your GitHub Raw link
	local scriptContent = game:HttpGet("https://raw.githubusercontent.com/1NXDevelopment/NX/refs/heads/main/loader.luau")

	-- 2. Delete the loader GUI so it's out of the way
	ScreenGui:Destroy()

	-- 3. Execute the script
	loadstring(scriptContent)()
end)

UICorner_2.CornerRadius = UDim.new(0, 9)
UICorner_2.Parent = TextLabel

TextButton_2.Parent = Frame
TextButton_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton_2.BorderSizePixel = 0
TextButton_2.Position = UDim2.new(0.0687830672, 0, 0.465454549, 0)
TextButton_2.Size = UDim2.new(0, 163, 0, 48)
TextButton_2.Font = Enum.Font.Roboto
TextButton_2.Text = "Discord"
TextButton_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_2.TextSize = 20.000
TextButton_2.MouseButton1Click:Connect(function()
	setclipboard("https://discord.gg/VrspbtA6Uw")
	TextLabel_2.Visible = true
	task.wait(3)
	TextLabel_2.Visible = false
end)

TextLabel_2.Parent = Frame
TextLabel_2.BackgroundColor3 = Color3.fromRGB(5, 4, 43)
TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Position = UDim2.new(0, 0, 0.876363635, 0)
TextLabel_2.Size = UDim2.new(0, 189, 0, 35)
TextLabel_2.Visible = false
TextLabel_2.Font = Enum.Font.SourceSans
TextLabel_2.Text = "Discord Copied to Clipboard"
TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.TextSize = 18.000

UICorner_3.CornerRadius = UDim.new(0, 9)
UICorner_3.Parent = TextLabel_2