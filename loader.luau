local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

-- [FOLDER & PATH SETUP]
local BaseFolder = "NX-Free"
local ConfigFolder = BaseFolder .. "/configs"
local AutoLoadFile = BaseFolder .. "/autoload.txt"

if not isfolder(BaseFolder) then makefolder(BaseFolder) end
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

-- Configuration Defaults
local Config = {
    Enabled = false,
    WallCheck = false,
    FOV = 400,
    Sensitivity = 0.85, 
    Smoothing = 0.2, 
    ShowFOV = false,
    TouchID = 123,
    MaxSwipeDist = 1200, 
    MaxDistance = 1000,
    BreakThreshold = 50,
    PredictionAmount = 1.5,
    Deadzone = 2,
    HitSound = false,
    RageMode = false,
    LootDelay = 0.5,
    -- Screen Size / Aim Origin Fix
    AimOriginX = 0.82, -- Default X ratio
    AimOriginY = 0.28, -- Default Y ratio
    -- ESP Config
    ESPEnabled = false,
    Skeletons = false,
    Boxes = false,
    Names = false,
    Tracers = false,
    HeadDots = false,
    Health = false,
    Chams = false, 
    -- Crosshair Config
    CrosshairEnabled = false,
    CrosshairURL = "http://www.roblox.com/asset/?id=6031289529",
    CrosshairSize = 50,
    CrosshairSpin = false,
    CrosshairSpinSpeed = 100,
    CrosshairColor = {0, 0, 255} 
}

-- [ENHANCED CONFIG MANAGER LOGIC]
local function GetConfigList()
    local files = listfiles(ConfigFolder)
    local names = {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            table.insert(names, file:match("([^/]+)%.json$") or file:match("([^%\\]+)%.json$"))
        end
    end
    return names
end

local function SaveConfig(name)
    if not name or name == "" then return end
    local path = ConfigFolder .. "/" .. name .. ".json"
    local success, data = pcall(function()
        return HttpService:JSONEncode(Config)
    end)
    if success then 
        writefile(path, data) 
    end
end

local function LoadConfig(name)
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if success then
            for i, v in pairs(data) do 
                Config[i] = v 
            end
            return true
        end
    end
    return false
end

-- UI Window
local Window = Rayfield:CreateWindow({Name = "NX-Free", LoadingTitle = "NX-Free. Made for mobile.", Theme = "AmberGlow"})

local function InitialLoad()
    if isfile(AutoLoadFile) then
        local autoName = readfile(AutoLoadFile)
        LoadConfig(autoName)
    end
end
InitialLoad()

local HitSound = Instance.new("Sound")
HitSound.SoundId = "rbxassetid://8766809464"
HitSound.Volume = 2
local PlayerHealthCache = {}

local ScreenGui = Instance.new("ScreenGui")
local FOVFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
ScreenGui.Name = "SkyAssistVisuals"
ScreenGui.IgnoreGuiInset = true 
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- [WATERMARK]
local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "NX-Watermark"
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.DisplayOrder = 2147483647
WatermarkGui.Parent = CoreGui or (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local WatermarkMain = Instance.new("Frame")
WatermarkMain.Name = "Background"
WatermarkMain.Parent = WatermarkGui
WatermarkMain.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
WatermarkMain.BackgroundTransparency = 0.15
WatermarkMain.BorderSizePixel = 0
WatermarkMain.Position = UDim2.new(0, 15, 0, 15)
WatermarkMain.Size = UDim2.new(0, 0, 0, 26)
WatermarkMain.AutomaticSize = Enum.AutomaticSize.X

local W_UICorner = Instance.new("UICorner")
W_UICorner.CornerRadius = UDim.new(0, 4)
W_UICorner.Parent = WatermarkMain

local W_UIStroke = Instance.new("UIStroke")
W_UIStroke.Color = Color3.fromRGB(40, 40, 45)
W_UIStroke.Thickness = 1
W_UIStroke.Parent = WatermarkMain

local AccentLine = Instance.new("Frame")
AccentLine.Name = "Accent"
AccentLine.Parent = WatermarkMain
AccentLine.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
AccentLine.BorderSizePixel = 0
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 0)

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(0, 4)
AccentCorner.Parent = AccentLine

local W_UIPadding = Instance.new("UIPadding")
W_UIPadding.PaddingLeft = UDim.new(0, 10)
W_UIPadding.PaddingRight = UDim.new(0, 10)
W_UIPadding.Parent = WatermarkMain

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Parent = WatermarkMain
WatermarkText.BackgroundTransparency = 1
WatermarkText.Position = UDim2.new(0, 0, 0, 2)
WatermarkText.Size = UDim2.new(1, 0, 1, -2)
WatermarkText.Font = Enum.Font.GothamSemibold
WatermarkText.Text = "NX-Free  |  Loading..."
WatermarkText.TextColor3 = Color3.fromRGB(230, 230, 230)
WatermarkText.TextSize = 13
WatermarkText.AutomaticSize = Enum.AutomaticSize.X

task.spawn(function()
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 1 then
            local fps = frameCount
            frameCount = 0
            lastTime = tick()
            local ping = tostring(math.round(LocalPlayer:GetNetworkPing() * 1000))
            WatermarkText.Text = string.format("NX-Free  |  %s  |  %d FPS  |  %sms", LocalPlayer.Name, fps, ping)
        end
    end)
end)

FOVFrame.Name = "Circle"
FOVFrame.Parent = ScreenGui
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1 
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
FOVFrame.Visible = Config.ShowFOV
UIStroke.Parent = FOVFrame
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.5
UICorner.CornerRadius = UDim.new(1, 0) 
UICorner.Parent = FOVFrame

local CrosshairImage = Instance.new("ImageLabel")
CrosshairImage.Parent = ScreenGui
CrosshairImage.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairImage.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairImage.BackgroundTransparency = 1
CrosshairImage.Image = Config.CrosshairURL
CrosshairImage.Size = UDim2.new(0, Config.CrosshairSize, 0, Config.CrosshairSize)
CrosshairImage.Visible = Config.CrosshairEnabled

local StarLines = {}
for i = 1, 6 do
    StarLines[i] = Drawing.new("Line")
    StarLines[i].Thickness = 2
    StarLines[i].Transparency = 1
    StarLines[i].Visible = false
end

-- [FUNCTION: SET VISUAL AIM ORIGIN]
local function OpenOriginSelector()
    local SelectorGui = Instance.new("ScreenGui")
    SelectorGui.Name = "OriginSelector"
    SelectorGui.IgnoreGuiInset = true
    SelectorGui.Parent = CoreGui or (gethui and gethui())
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    MainFrame.BackgroundTransparency = 0.5
    MainFrame.Active = true
    MainFrame.Parent = SelectorGui
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, 0, 0, 50)
    InfoLabel.Position = UDim2.new(0, 0, 0.4, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "CLICK/TAP WHERE YOU WANT AIMBOT TO AIM FROM\n(Usually an empty area of your screen)"
    InfoLabel.TextColor3 = Color3.new(1, 1, 1)
    InfoLabel.Font = Enum.Font.GothamBold
    InfoLabel.TextSize = 20
    InfoLabel.Parent = MainFrame

    local Connection
    Connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local screenSize = Camera.ViewportSize
            Config.AimOriginX = pos.X / screenSize.X
            Config.AimOriginY = pos.Y / screenSize.Y
            
            Rayfield:Notify({
                Title = "Origin Set",
                Content = "Aimbot will now aim from this screen position.",
                Duration = 3
            })
            
            Connection:Disconnect()
            SelectorGui:Destroy()
        end
    end)
end

-- [TABS]
local MainTab = Window:CreateTab("Aimbot", 4483362458)
local RageTab = Window:CreateTab("Rage", 4483362458)
local ESPTab = Window:CreateTab("Visuals", 4483362458)
local SettingsTab = Window:CreateTab("Crosshair", 4483362458)
local ConfigTab = Window:CreateTab("Configs", 4483362458)

-- Aimbot UI
local TglAimbot = MainTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = Config.Enabled, Callback = function(v) Config.Enabled = v end})
local TglHitSound = MainTab:CreateToggle({Name = "Hit Sound (Pop)", CurrentValue = Config.HitSound, Callback = function(v) Config.HitSound = v end})
local TglWallCheck = MainTab:CreateToggle({Name = "Wall Check", CurrentValue = Config.WallCheck, Callback = function(v) Config.WallCheck = v end})
local TglShowFOV = MainTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = Config.ShowFOV, Callback = function(v) Config.ShowFOV = v; FOVFrame.Visible = v end})
local SldAimSpeed = MainTab:CreateSlider({Name = "Aim Speed", Range = {0.1, 2}, Increment = 0.05, CurrentValue = Config.Sensitivity, Callback = function(v) Config.Sensitivity = v end})
local SldSmoothing = MainTab:CreateSlider({Name = "Smoothing", Range = {0.05, 1}, Increment = 0.05, CurrentValue = Config.Smoothing, Callback = function(v) Config.Smoothing = v end})
local SldFOV = MainTab:CreateSlider({Name = "FOV Radius", Range = {50, 800}, Increment = 10, CurrentValue = Config.FOV, Callback = function(v) Config.FOV = v; FOVFrame.Size = UDim2.new(0, v * 2, 0, v * 2) end})

MainTab:CreateSection("Screen Compatibility")
MainTab:CreateButton({
    Name = "Set Aim Origin (Screen Size Fix)",
    Callback = function()
        OpenOriginSelector()
    end,
})

-- Rage UI
local TglRage = RageTab:CreateToggle({Name = "Enable Rage (FFA + Look Down)", CurrentValue = Config.RageMode, Callback = function(v) 
    Config.RageMode = v; 
    FOVFrame.Size = v and UDim2.new(0, 4000, 0, 4000) or UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
end})
local SldLootDelay = RageTab:CreateSlider({Name = "Loot Pickup Delay", Range = {0.1, 2}, Increment = 0.1, CurrentValue = Config.LootDelay, Callback = function(v) Config.LootDelay = v end})

-- Visuals UI
local TglESP = ESPTab:CreateToggle({Name = "Master ESP", CurrentValue = Config.ESPEnabled, Callback = function(v) Config.ESPEnabled = v end})
local TglChams = ESPTab:CreateToggle({Name = "Chams (Wallhack)", CurrentValue = Config.Chams, Callback = function(v) Config.Chams = v end})
local TglSkeletons = ESPTab:CreateToggle({Name = "Skeletons", CurrentValue = Config.Skeletons, Callback = function(v) Config.Skeletons = v end})
local TglBoxes = ESPTab:CreateToggle({Name = "Boxes", CurrentValue = Config.Boxes, Callback = function(v) Config.Boxes = v end})
local TglHealth = ESPTab:CreateToggle({Name = "Health Bar", CurrentValue = Config.Health, Callback = function(v) Config.Health = v end})
local TglNames = ESPTab:CreateToggle({Name = "Names", CurrentValue = Config.Names, Callback = function(v) Config.Names = v end})

-- Crosshair UI
local TglCrosshair = SettingsTab:CreateToggle({Name = "Enable Crosshair", CurrentValue = Config.CrosshairEnabled, Callback = function(v) Config.CrosshairEnabled = v; CrosshairImage.Visible = v end})
local InpCrosshairURL = SettingsTab:CreateInput({Name = "Crosshair Link", PlaceholderText = "Paste PNG Link or ID", CurrentValue = Config.CrosshairURL, Callback = function(v) Config.CrosshairURL = v; CrosshairImage.Image = v end})
local SldCrosshairSize = SettingsTab:CreateSlider({Name = "Crosshair Size", Range = {10, 150}, Increment = 5, CurrentValue = Config.CrosshairSize, Callback = function(v) Config.CrosshairSize = v; CrosshairImage.Size = UDim2.new(0, v, 0, v) end})
local TglCrosshairSpin = SettingsTab:CreateToggle({Name = "Spin Crosshair", CurrentValue = Config.CrosshairSpin, Callback = function(v) Config.CrosshairSpin = v end})
local SldCrosshairSpinSpeed = SettingsTab:CreateSlider({Name = "Spin Speed", Range = {10, 500}, Increment = 10, CurrentValue = Config.CrosshairSpinSpeed, Callback = function(v) Config.CrosshairSpinSpeed = v end})

local function UpdateUI()
    TglAimbot:Set(Config.Enabled)
    TglHitSound:Set(Config.HitSound)
    TglWallCheck:Set(Config.WallCheck)
    TglShowFOV:Set(Config.ShowFOV)
    SldAimSpeed:Set(Config.Sensitivity)
    SldSmoothing:Set(Config.Smoothing)
    SldFOV:Set(Config.FOV)
    TglRage:Set(Config.RageMode)
    SldLootDelay:Set(Config.LootDelay)
    TglESP:Set(Config.ESPEnabled)
    TglSkeletons:Set(Config.Skeletons)
    TglChams:Set(Config.Chams)
    TglBoxes:Set(Config.Boxes)
    TglHealth:Set(Config.Health)
    TglNames:Set(Config.Names)
    TglCrosshair:Set(Config.CrosshairEnabled)
    SldCrosshairSize:Set(Config.CrosshairSize)
    TglCrosshairSpin:Set(Config.CrosshairSpin)
    SldCrosshairSpinSpeed:Set(Config.CrosshairSpinSpeed)
end

-- [CONFIG TAB LOGIC]
local SelectedConfig = ""
local ConfigDropdown = ConfigTab:CreateDropdown({
    Name = "Select Config",
    Options = GetConfigList(),
    CurrentOption = "",
    Callback = function(Option)
        SelectedConfig = type(Option) == "table" and Option[1] or Option
    end,
})

ConfigTab:CreateInput({
    Name = "New Config Name",
    PlaceholderText = "Type name here...",
    Callback = function(v) SelectedConfig = v end,
})

ConfigTab:CreateButton({
    Name = "Save/Create Config",
    Callback = function()
        if SelectedConfig ~= "" then
            SaveConfig(SelectedConfig)
            ConfigDropdown:Refresh(GetConfigList(), true)
            Rayfield:Notify({Title = "Config Saved", Content = "Saved to: " .. SelectedConfig, Duration = 2})
        end
    end,
})

ConfigTab:CreateButton({
    Name = "Load Selected Config",
    Callback = function()
        if SelectedConfig ~= "" then
            if LoadConfig(SelectedConfig) then
                UpdateUI()
                Rayfield:Notify({Title = "Config Loaded", Content = "Loaded: " .. SelectedConfig, Duration = 3})
            end
        end
    end,
})

-- [ESP & VISUALS LOGIC]
local ESP_Objects = {}
local function CreateDrawing(Type, Properties) 
    local Obj = Drawing.new(Type)
    for i, v in pairs(Properties) do Obj[i] = v end 
    return Obj 
end

local function RemoveESP(Player)
    if ESP_Objects[Player] then 
        for _, Obj in pairs(ESP_Objects[Player]) do 
            if type(Obj) == "table" then 
                for _, sub in pairs(Obj) do sub:Remove() end 
            elseif typeof(Obj) == "Instance" then
                Obj:Destroy()
            else 
                Obj:Remove() 
            end 
        end 
        ESP_Objects[Player] = nil 
    end
    PlayerHealthCache[Player] = nil
end
Players.PlayerRemoving:Connect(RemoveESP)

local function NewESP(Player)
    local SkeletonLines = {}
    for i=1, 15 do SkeletonLines[i] = CreateDrawing("Line", {Color = Color3.new(1,1,1), Thickness = 1, Visible = false}) end
    
    local CornerLines = {}
    for i = 1, 8 do CornerLines[i] = CreateDrawing("Line", {Color = Color3.new(1,1,1), Thickness = 2, Visible = false}) end
    
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "IronChams_" .. Player.Name
    Highlight.FillColor = Color3.fromRGB(0, 200, 255)
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.Enabled = false
    Highlight.Parent = ScreenGui 

    ESP_Objects[Player] = {
        BoxCorners = CornerLines,
        HealthOutline = CreateDrawing("Square", {Color = Color3.new(0,0,0), Thickness = 1, Filled = true, Visible = false, Transparency = 0.5}),
        HealthBar = CreateDrawing("Square", {Color = Color3.new(1,1,1), Thickness = 1, Filled = true, Visible = false}),
        Name = CreateDrawing("Text", {Color = Color3.new(1,1,1), Size = 14, Center = true, Outline = true, Visible = false}),
        Tracer = CreateDrawing("Line", {Color = Color3.new(1,1,1), Thickness = 1, Visible = false}),
        Highlight = Highlight,
        Skeleton = SkeletonLines
    }
end

-- Aimbot & Movement Logic
local LockedPlayer = nil
local lastPos = {}
local smoothedDelta = Vector2.new(0, 0)
local isSwiping = false
local currentOffset = Vector2.new(0, 0)
local startPos = Vector2.new(0, 0)
local lastKillCFrame = nil
local lootTimer = 0

-- Updated to use configurable ratios
local function getSafeZone() 
    local size = Camera.ViewportSize 
    return Vector2.new(size.X * Config.AimOriginX, size.Y * Config.AimOriginY) 
end

local function getVisiblePart(model)
    local parts = {model:FindFirstChild("Head"), model:FindFirstChild("HumanoidRootPart"), model:FindFirstChild("UpperTorso")}
    if Config.RageMode or not Config.WallCheck then return parts[1] end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    for _, part in pairs(parts) do
        if part then
            local res = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
            if res and res.Instance:IsDescendantOf(model) then return part end
        end
    end
    return nil
end

local function getTarget(dt)
    if not Config.Enabled and not Config.RageMode then LockedPlayer = nil return nil end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then LockedPlayer = nil return nil end
    if lootTimer > 0 then lootTimer = lootTimer - dt return nil end
    
    if LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("Humanoid") then
        local tChar = LockedPlayer.Character
        local targetPart = getVisiblePart(tChar)
        if tChar.Humanoid.Health > 0 and targetPart and (char.Head.Position - targetPart.Position).Magnitude <= Config.MaxDistance then
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen or Config.RageMode then
                local velocity = (targetPart.Position - (lastPos[LockedPlayer.UserId] or targetPart.Position))
                lastPos[LockedPlayer.UserId] = targetPart.Position
                local predictPos = Camera:WorldToViewportPoint(targetPart.Position + (velocity * Config.PredictionAmount))
                return Vector2.new(predictPos.X, predictPos.Y)
            end
        elseif Config.RageMode and tChar.Humanoid.Health <= 0 then
            lootTimer = Config.LootDelay
            if tChar:FindFirstChild("HumanoidRootPart") then lastKillCFrame = tChar.HumanoidRootPart.CFrame end
        end
    end
    
    LockedPlayer = nil
    local closestMagnitude = Config.MaxDistance
    local bestTargetPos = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character.Humanoid.Health > 0 then
            local targetPart = getVisiblePart(p.Character)
            if targetPart then
                local dist = (char.Head.Position - targetPart.Position).Magnitude
                if dist < closestMagnitude then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if Config.RageMode or (onScreen and (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude < Config.FOV) then
                        closestMagnitude = dist; LockedPlayer = p; bestTargetPos = Vector2.new(pos.X, pos.Y)
                    end
                end
            end
        end
    end
    return bestTargetPos
end

-- RenderStepped Logic
RunService.RenderStepped:Connect(function(dt)
    if Config.CrosshairEnabled then
        if Config.CrosshairSpin then CrosshairImage.Rotation = CrosshairImage.Rotation + (Config.CrosshairSpinSpeed * dt) end
        local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local r = Config.CrosshairSize / 2
        local rot = Config.CrosshairSpin and (tick() * (Config.CrosshairSpinSpeed / 50)) or 0
        local function getPt(angle) local a = math.rad(angle) + rot return Center + Vector2.new(math.cos(a) * r, math.sin(a) * r) end
        local p1,p2,p3,p4,p5,p6 = getPt(-90),getPt(30),getPt(150),getPt(90),getPt(-30),getPt(-150)
        local lines = {{p1,p2},{p2,p3},{p3,p1},{p4,p5},{p5,p6},{p6,p4}}
        for i, pts in ipairs(lines) do
            StarLines[i].From = pts[1]; StarLines[i].To = pts[2]; StarLines[i].Visible = true; StarLines[i].Color = Color3.fromRGB(unpack(Config.CrosshairColor))
        end
    else
        for _,l in pairs(StarLines) do l.Visible = false end
    end

    if Config.RageMode then
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            if lootTimer > 0 and lastKillCFrame then
                myChar.HumanoidRootPart.CFrame = lastKillCFrame * CFrame.new(0, 5, 0)
            elseif LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = LockedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local Char, Objects = p.Character, ESP_Objects[p]
        local Hum = Char and Char:FindFirstChild("Humanoid")
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")

        if Hum and Root then
            local currentHealth = Hum.Health
            if PlayerHealthCache[p] and currentHealth < PlayerHealthCache[p] then
                if Config.HitSound and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Config.RageMode) then
                    if LockedPlayer == p then SoundService:PlayLocalSound(HitSound) end
                end
            end
            PlayerHealthCache[p] = currentHealth
        end
        
        if not Config.ESPEnabled or not Char or not Root or not Hum or Hum.Health <= 0 then
            if Objects then 
                for _, obj in pairs(Objects) do 
                    if type(obj) == "table" then for _, v in pairs(obj) do v.Visible = false end 
                    elseif typeof(obj) == "Instance" then obj.Enabled = false
                    else obj.Visible = false end 
                end 
            end
            continue
        end

        if not Objects then NewESP(p); Objects = ESP_Objects[p] end
        
        if Config.Chams then
            if Objects.Highlight.Adornee ~= Char then
                Objects.Highlight.Adornee = Char
            end
            Objects.Highlight.Enabled = true
        else
            Objects.Highlight.Enabled = false
        end

        local TopPos, OnScreenTop = Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 3.5, 0))
        local BottomPos, OnScreenBot = Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, -4.5, 0))
        local Distance = (Camera.CFrame.Position - Root.Position).Magnitude
        
        if (OnScreenTop or OnScreenBot) and Distance < Config.MaxDistance then
            local Height = math.clamp(math.abs(TopPos.Y - BottomPos.Y), 10, 2000)
            local Width = Height / 1.6 
            local BoxPos = Vector2.new(TopPos.X - Width/2, TopPos.Y)
            
            if Config.Skeletons then
                local function Connect(p1, p2, line)
                    local part1, part2 = Char:FindFirstChild(p1), Char:FindFirstChild(p2)
                    if part1 and part2 then
                        local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                        local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                        if vis1 and vis2 then
                            line.From = Vector2.new(pos1.X, pos1.Y); line.To = Vector2.new(pos2.X, pos2.Y); line.Visible = true
                            return
                        end
                    end
                    line.Visible = false
                end
                Connect("Head", "UpperTorso", Objects.Skeleton[1]); Connect("UpperTorso", "LowerTorso", Objects.Skeleton[2])
                Connect("UpperTorso", "LeftUpperArm", Objects.Skeleton[3]); Connect("LeftUpperArm", "LeftLowerArm", Objects.Skeleton[4])
                Connect("UpperTorso", "RightUpperArm", Objects.Skeleton[5]); Connect("RightUpperArm", "RightLowerArm", Objects.Skeleton[6])
                Connect("LowerTorso", "LeftUpperLeg", Objects.Skeleton[7]); Connect("LeftUpperLeg", "LeftLowerLeg", Objects.Skeleton[8])
                Connect("LowerTorso", "RightUpperLeg", Objects.Skeleton[9]); Connect("RightUpperLeg", "RightLowerLeg", Objects.Skeleton[10])
            else
                for _,l in pairs(Objects.Skeleton) do l.Visible = false end
            end

            if Config.Boxes then
                local L = math.clamp(Width / 3, 2, math.min(Width / 2.1, Height / 2.1)) 
                local X, Y, W, H = BoxPos.X, BoxPos.Y, Width, Height
                local corners = {{X,Y,X+L,Y}, {X,Y,X,Y+L}, {X+W,Y,X+W-L,Y}, {X+W,Y,X+W,Y+L}, {X,Y+H,X+L,Y+H}, {X,Y+H,X,Y+H-L}, {X+W,Y+H,X+W-L,Y+H}, {X+W,Y+H,X+W,Y+H-L}}
                for i, v in ipairs(corners) do 
                    Objects.BoxCorners[i].From = Vector2.new(v[1],v[2])
                    Objects.BoxCorners[i].To = Vector2.new(v[3],v[4])
                    Objects.BoxCorners[i].Visible = true 
                end
            else 
                for i=1,8 do Objects.BoxCorners[i].Visible = false end 
            end
            
            if Config.Health then
                Objects.HealthBar.Visible = true; Objects.HealthOutline.Visible = true
                local Pct = math.clamp(Hum.Health/Hum.MaxHealth,0,1)
                Objects.HealthOutline.Size = Vector2.new(4, Height); Objects.HealthOutline.Position = Vector2.new(BoxPos.X - 6, BoxPos.Y)
                Objects.HealthBar.Size = Vector2.new(2, Height * Pct); Objects.HealthBar.Position = Vector2.new(BoxPos.X - 5, BoxPos.Y + (Height * (1-Pct)))
                Objects.HealthBar.Color = Color3.fromHSV(Pct * 0.3, 1, 1)
            end
            if Config.Names then Objects.Name.Visible = true; Objects.Name.Text = p.Name.." ["..math.floor(Distance).."m]"; Objects.Name.Position = Vector2.new(TopPos.X, BoxPos.Y - 20) end
        else 
            for _,o in pairs(Objects) do if type(o) == "table" then for _,v in pairs(o) do v.Visible = false end elseif typeof(o) == "Instance" then o.Enabled = false else o.Visible = false end end 
        end
    end
end)

-- AIMBOT LOOP
RunService.RenderStepped:Connect(function(dt)
    local target = getTarget(dt); local origin = getSafeZone()
    if target then
        local rawDelta = (target - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
        local sens = Config.RageMode and 4.0 or Config.Sensitivity 
        local smooth = Config.RageMode and 0.9 or Config.Smoothing
        rawDelta = (rawDelta * sens) * (dt * 60)
        if Config.RageMode then rawDelta = rawDelta + Vector2.new(0, 3000) end
        local step = Config.RageMode and 1500 or math.clamp(rawDelta.Magnitude * 0.5, 15, 45)
        smoothedDelta = smoothedDelta:Lerp(Vector2.new(math.clamp(rawDelta.X, -step, step), math.clamp(rawDelta.Y, -step, step)), smooth)
        if not isSwiping then VirtualInputManager:SendTouchEvent(Config.TouchID, 0, origin.X, origin.Y); isSwiping = true; currentOffset = Vector2.new(0,0); startPos = origin end
        currentOffset = currentOffset + smoothedDelta
        VirtualInputManager:SendTouchEvent(Config.TouchID, 1, startPos.X + currentOffset.X, startPos.Y + currentOffset.Y)
        if currentOffset.Magnitude > Config.MaxSwipeDist then 
            VirtualInputManager:SendTouchEvent(Config.TouchID, 2, startPos.X+currentOffset.X, startPos.Y+currentOffset.Y); isSwiping = false 
        end
    elseif isSwiping then
        VirtualInputManager:SendTouchEvent(Config.TouchID, 2, startPos.X+currentOffset.X, startPos.Y+currentOffset.Y); isSwiping = false; currentOffset = Vector2.new(0,0); smoothedDelta = Vector2.new(0,0)
    end
end)
