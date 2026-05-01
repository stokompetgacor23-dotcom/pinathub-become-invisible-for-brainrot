repeat task.wait() until game:IsLoaded()

-- =======================================================
-- PINATHUB | LUCKY BLOCK COLLECTOR
-- =======================================================

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================
-- EXECUTOR COMPATIBILITY
-- ============================================
local function noop() end
local get_hui = gethui or (syn and syn.gethui) or noop
local set_clipboard = setclipboard or (syn and syn.setclipboard) or noop
local fire_prox_prompt = fireproximityprompt or (syn and syn.fireproximityprompt) or noop

-- ============================================
-- PLAYER VARIABLES
-- ============================================
local player = LocalPlayer
local UIS = UserInputService

-- Safe Parent
local SafeParent = (pcall(function() return gethui() end) and gethui()) or player:WaitForChild("PlayerGui")

-- Hapus UI lama jika ada
local existingGui = SafeParent:FindFirstChild("PINATHUB_LUCKY")
if existingGui then 
    existingGui:Destroy() 
end

-- ============================================
-- AUTO FARM VARIABLES
-- ============================================
local AutoFarm = false
local AutoCollectMoney = false
local AutoRebirth = false
local SelectedZone = "1"
local CollectAmount = "1"
local SelectedShopItem = "👻 Invisible Time (1)"
local InfiniteJumpEnabled = false
local WalkSpeedValue = 16
local JumpPowerValue = 50

-- Safe Zone CFrame
local SafeZoneCFrame = CFrame.new(3.83587933, 5.00753117, 27.4547634, -0.936105371, 2.6624198e-08, 0.351719618, 1.02398463e-08, 1, -4.84437628e-08, -0.351719618, -4.17469117e-08, -0.936105371)

-- Shop Options Map
local shopOptionsMap = {
    ["👻 Invisible Time (1)"] = function() 
        local success, result = pcall(function()
            return ReplicatedStorage.Library.Knit.Knit.Services.InvisibleService.RF.TryPurchase:InvokeServer(1)
        end)
        return success
    end,
    ["👻 Invisible Time (5)"] = function() 
        local success, result = pcall(function()
            return ReplicatedStorage.Library.Knit.Knit.Services.InvisibleService.RF.TryPurchase:InvokeServer(5)
        end)
        return success
    end,
    ["👻 Invisible Time (10)"] = function() 
        local success, result = pcall(function()
            return ReplicatedStorage.Library.Knit.Knit.Services.InvisibleService.RF.TryPurchase:InvokeServer(10)
        end)
        return success
    end,
    ["⚡ Speed Up (1)"] = function() 
        local success, result = pcall(function()
            return ReplicatedStorage.Library.Knit.Knit.Services.SpeedService.RF.TryPurchase:InvokeServer(1)
        end)
        return success
    end,
    ["⚡ Speed Up (5)"] = function() 
        local success, result = pcall(function()
            return ReplicatedStorage.Library.Knit.Knit.Services.SpeedService.RF.TryPurchase:InvokeServer(5)
        end)
        return success
    end,
    ["⚡ Speed Up (10)"] = function() 
        local success, result = pcall(function()
            return ReplicatedStorage.Library.Knit.Knit.Services.SpeedService.RF.TryPurchase:InvokeServer(10)
        end)
        return success
    end,
    ["🎒 Carry Upgrade"] = function() 
        local success, result = pcall(function()
            return ReplicatedStorage.Library.Knit.Knit.Services.CarryService.RF.TryUpgrade:InvokeServer()
        end)
        return success
    end,
}

local shopOptionsList = {
    "👻 Invisible Time (1)", 
    "👻 Invisible Time (5)", 
    "👻 Invisible Time (10)",
    "⚡ Speed Up (1)", 
    "⚡ Speed Up (5)", 
    "⚡ Speed Up (10)",
    "🎒 Carry Upgrade"
}

local zoneList = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"}
local amountList = {"1", "2", "3"}

-- ============================================
-- LOGO LAUNCHER PINATHUB
-- ============================================
local logoGui = Instance.new("ScreenGui")
logoGui.Name = "PinatHubLogo"
logoGui.ResetOnSpawn = false
logoGui.Parent = player:WaitForChild("PlayerGui", 5)

local logoButton = Instance.new("ImageButton")
logoButton.Name = "LogoButton"
logoButton.Size = UDim2.new(0, 60, 0, 60)
logoButton.Position = UDim2.new(0.5, -30, 0.5, -30)
logoButton.BackgroundTransparency = 1
logoButton.Image = "rbxassetid://118264723961739"
logoButton.ImageColor3 = Color3.fromRGB(180, 0, 255)
logoButton.ScaleType = Enum.ScaleType.Fit
logoButton.Parent = logoGui

local uiCornerLogo = Instance.new("UICorner")
uiCornerLogo.CornerRadius = UDim.new(1, 0)
uiCornerLogo.Parent = logoButton

local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)})
local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})

logoButton.MouseEnter:Connect(function() 
    hoverTween:Play() 
end)

logoButton.MouseLeave:Connect(function() 
    unhoverTween:Play() 
end)

local dragging = false
local dragInput, dragStart, startPos

logoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = logoButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

logoButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        logoButton.Position = newPos
    end
end)

-- ============================================
-- LOAD WINDUI
-- ============================================
local WindUI = loadstring(game:HttpGet('https://github.com/Footagesus/WindUI/releases/latest/download/main.lua'))()

local window = WindUI:CreateWindow({
    Title = "PinatHub",
    Author = "@viunze on tiktok",
    Folder = "pinathub",
    Size = UDim2.fromOffset(500, 500),
    Transparent = false,
    Theme = "Dark",
    IsOpenButtonEnabled = false,
    User = {Enabled = true, Anonymous = true},
    SideBarWidth = 150,
})

local guiVisible = true
logoButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    if window then
        pcall(function()
            if guiVisible then
                window:Open()
            else
                window:Minimize()
            end
        end)
    end
end)

-- Create Tabs
local tabs = {
    main = window:Tab({Title = "Main", Icon = "sword"}),
    collect = window:Tab({Title = "Collect", Icon = "dollar-sign"}),
    shop = window:Tab({Title = "Shop", Icon = "shopping-cart"}),
    community = window:Tab({Title = "Community", Icon = "users"}),
    settings = window:Tab({Title = "Settings", Icon = "settings"}),
}

-- ============================================
-- MAIN TAB
-- ============================================
local mainSection = tabs.main:Section({Title = "Zone Settings"})

mainSection:Dropdown({
    Title = "🌍 Select Zone",
    Values = zoneList,
    Default = "1",
    Callback = function(value)
        SelectedZone = value
    end,
})

mainSection:Dropdown({
    Title = "📦 Items per Warp",
    Values = amountList,
    Default = "1",
    Callback = function(value)
        CollectAmount = value
    end,
})

mainSection:Toggle({
    Title = "🚀 Auto Farm Zone",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoFarm = state
    end,
})

-- ============================================
-- COLLECT TAB
-- ============================================
local collectSection = tabs.collect:Section({Title = "Auto Collection"})

collectSection:Toggle({
    Title = "💸 Auto Collect Money",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoCollectMoney = state
    end,
})

collectSection:Toggle({
    Title = "🔄 Auto Rebirth",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoRebirth = state
    end,
})

-- ============================================
-- SHOP TAB
-- ============================================
local shopSection = tabs.shop:Section({Title = "Item Shop"})

shopSection:Dropdown({
    Title = "🛒 Select Item",
    Values = shopOptionsList,
    Default = "👻 Invisible Time (1)",
    Callback = function(value)
        SelectedShopItem = value
    end,
})

shopSection:Button({
    Title = "💳 BUY SELECTED ITEM",
    Callback = function()
        if shopOptionsMap[SelectedShopItem] then
            pcall(function()
                shopOptionsMap[SelectedShopItem]()
                window:Notify("Shop", "Purchase attempted: " .. SelectedShopItem, 2)
            end)
        end
    end,
})

-- ============================================
-- COMMUNITY TAB
-- ============================================
local communitySection = tabs.community:Section({Title = "Join Community"})

communitySection:Button({
    Title = "📱 WhatsApp Group",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://chat.whatsapp.com/I8hG44FLgrRAwQcS3lvEft")
            window:Notify("Copied!", "WhatsApp link copied to clipboard!", 2)
        end
    end,
})

communitySection:Button({
    Title = "💬 Discord Server",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://discord.gg/eDbaHKEf7G")
            window:Notify("Copied!", "Discord link copied to clipboard!", 2)
        end
    end,
})

communitySection:Button({
    Title = "🎵 TikTok @viunze",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://tiktok.com/@viunze")
            window:Notify("Copied!", "TikTok profile copied!", 2)
        end
    end,
})

-- ============================================
-- SETTINGS TAB
-- ============================================

-- Movement Section
local movementSection = tabs.settings:Section({Title = "Movement"})

movementSection:Slider({
    Title = "Walk Speed",
    Value = {Min = 16, Max = 250, Default = 16, Decimals = 0},
    Callback = function(value)
        WalkSpeedValue = value
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = value
            end
        end
    end,
})

movementSection:Slider({
    Title = "Jump Power",
    Value = {Min = 0, Max = 500, Default = 50, Decimals = 0},
    Callback = function(value)
        JumpPowerValue = value
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = value
                hum.UseJumpPower = true
            end
        end
    end,
})

movementSection:Toggle({
    Title = "Infinite Jump",
    Type = "Checkbox",
    Value = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
    end,
})

-- Infinite Jump Logic
UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState("Jumping")
            end
        end
    end
end)

movementSection:Divider()

-- Character Section
local characterSection = tabs.settings:Section({Title = "Character"})

characterSection:Button({
    Title = "Reset Character (6s Cooldown)",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            window:Notify("Reset", "Character reset!", 2)
        end
    end,
})

characterSection:Divider()

-- Utilities Section
local utilitySection = tabs.settings:Section({Title = "Utilities"})

local noclipActive = false
utilitySection:Toggle({
    Title = "Noclip",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        noclipActive = state
        if state then
            task.spawn(function()
                while noclipActive do
                    local char = player.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                pcall(function() part.CanCollide = false end)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

local antiAFKActive = false
utilitySection:Toggle({
    Title = "Anti-AFK",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        antiAFKActive = state
        if state then
            task.spawn(function()
                while antiAFKActive do
                    task.wait(60)
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)
        end
    end,
})

utilitySection:Divider()

-- Server Section
local serverSection = tabs.settings:Section({Title = "Server"})

serverSection:Button({
    Title = "Server Hop",
    Callback = function()
        local req = syn and syn.request or http_request or request or httprequest
        local servers = {}
        local placeId = game.PlaceId
        
        if req then
            local cursor = ""
            for i = 1, 3 do
                local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
                if cursor ~= "" then
                    url = url .. "&cursor=" .. cursor
                end
                local ok, response = pcall(req, { Url = url, Method = "GET" })
                if not ok or not response or not response.Body then break end
                local ok2, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
                if not ok2 or not data or not data.data then break end
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                local nextCursor = data.nextPageCursor
                if not nextCursor or nextCursor == "" or nextCursor == "null" then break end
                cursor = tostring(nextCursor)
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
        else
            TeleportService:Teleport(placeId, player)
        end
        window:Notify("Server Hop", "Joining new server...", 2)
    end,
})

serverSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
        window:Notify("Rejoin", "Rejoining server...", 2)
    end,
})

-- ============================================
-- AUTO FARM LOGIC
-- ============================================

-- Auto Farm Zone
task.spawn(function()
    while task.wait(0.1) do
        if AutoFarm then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local mapStage = workspace:FindFirstChild("__MAP")
                local stages = mapStage and mapStage:FindFirstChild("Stages")
                local zoneData = stages and stages:FindFirstChild(tostring(SelectedZone))
                local zonePart = zoneData and zoneData:FindFirstChild("Zone")
                
                if hrp and zonePart then
                    hrp.CFrame = zonePart.CFrame
                    task.wait(0.15)
                    
                    local casches = workspace:FindFirstChild("CASCHES")
                    local itemsFolder = casches and casches:FindFirstChild("SPAWNED_ITEMS")
                    local targetAmount = tonumber(CollectAmount) or 1
                    local collectedCount = 0

                    if itemsFolder then
                        for _, item in pairs(itemsFolder:GetChildren()) do
                            if not AutoFarm then break end
                            
                            local targetPart = nil
                            if item:IsA("BasePart") then
                                targetPart = item
                            else
                                targetPart = item:FindFirstChildWhichIsA("BasePart", true)
                            end
                            
                            if targetPart then
                                local distanceToZone = (targetPart.Position - zonePart.Position).Magnitude
                                
                                if distanceToZone < 150 then
                                    hrp.CFrame = targetPart.CFrame * CFrame.new(0, 2, 0)
                                    task.wait(0.1)
                                    
                                    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt then
                                        prompt.RequiresLineOfSight = false 
                                        fire_prox_prompt(prompt)
                                        task.wait(0.05)
                                        fire_prox_prompt(prompt)
                                    else
                                        firetouchinterest(hrp, targetPart, 0)
                                        firetouchinterest(hrp, targetPart, 1)
                                    end
                                    
                                    task.wait(0.2)
                                    collectedCount = collectedCount + 1 
                                    
                                    if collectedCount >= targetAmount then
                                        break 
                                    end
                                end
                            end
                        end
                    end
                    
                    if collectedCount > 0 then
                        hrp.CFrame = SafeZoneCFrame
                        task.wait(0.3)
                    end
                end
            end)
        end
    end
end)

-- Auto Collect Money
task.spawn(function()
    while task.wait(2) do 
        if AutoCollectMoney then
            pcall(function()
                local library = ReplicatedStorage:FindFirstChild("Library", true)
                local knit = library and library:FindFirstChild("Knit", true)
                local slotService = knit and knit:FindFirstChild("Services") and knit.Services:FindFirstChild("SlotService")
                local rf = slotService and slotService:FindFirstChild("RF") and slotService.RF:FindFirstChild("TryCollectCurrency")
                
                if rf then
                    for i = 1, 40 do
                        rf:InvokeServer(tostring(i))
                    end
                end
            end)
        end
    end
end)

-- Auto Rebirth
task.spawn(function()
    while task.wait(5) do 
        if AutoRebirth then
            pcall(function()
                local library = ReplicatedStorage:FindFirstChild("Library", true)
                local knit = library and library:FindFirstChild("Knit", true)
                local rebirthService = knit and knit:FindFirstChild("Services") and knit.Services:FindFirstChild("RebirthService")
                local rf = rebirthService and rebirthService:FindFirstChild("RF") and rebirthService.RF:FindFirstChild("TryRebirth")
                
                if rf then
                    rf:InvokeServer()
                end
            end)
        end
    end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.5)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = WalkSpeedValue
            hum.JumpPower = JumpPowerValue
            hum.UseJumpPower = true
        end
    end)
end)

-- ============================================
-- INITIAL NOTIFICATION
-- ============================================
task.wait(1)
window:Notify("PinatHub", "Lucky Block Collector Loaded!", 3)
window:Open()
