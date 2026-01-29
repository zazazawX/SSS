-- กำหนดรายการไอดีแมพที่อนุญาต (สามารถเพิ่มได้เรื่อยๆ ในวงเล็บปีกกา)
local AllowedPlaceIds = {
    77747658251236, -- แมพหลัก
    75159314259063,
    99684056491472,
}

-- ฟังก์ชันตรวจสอบไอดี
local function CheckPlaceId()
    for _, id in ipairs(AllowedPlaceIds) do
        if game.PlaceId == id then
            return true -- เจอไอดีที่ตรงกัน อนุญาตให้รัน
        end
    end
    return false -- ไม่เจอไอดีนี้ในรายการ
end

-- ถ้าต้องการเปิดใช้งานระบบล็อคแมพ ให้ลบเครื่องหมาย -- ข้างหน้า 4 บรรทัดด้านล่างนี้ออก
if not CheckPlaceId() then
    warn("Unauthorized Game: Script Execution Terminated.")
    return -- หยุดการทำงานทันที
end


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local HttpService = game:GetService("HttpService")

-- บริการต่างๆ ของ Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer 

-- [NEW] Mobile Support Logic (ปรับขนาดจอ)
local WindowSize = UDim2.fromOffset(580, 460) -- ขนาดปกติสำหรับ PC
if UserInputService.TouchEnabled then
    WindowSize = UDim2.fromOffset(480, 320) -- ขนาดเล็กสำหรับมือถือ (ปรับให้เล็กลง)
end

-- [สำคัญ] ตั้งชื่อหน้าต่างใส่ตัวแปรไว้ เพื่อให้ปุ่ม Mobile ค้นหาเจอ
local WindowTitle = "[🌑Eminence Update👑] Sailor Piece Script " .. Fluent.Version

-- สร้างหน้าต่าง UI
local Window = Fluent:CreateWindow({
    Title = WindowTitle,
    SubTitle = "By.Lume Dev",
    TabWidth = 160,
    Size = WindowSize, -- ใช้ขนาดที่เราคำนวณไว้
    Theme = "Rose", 
    MinimizeKey = Enum.KeyCode.RightControl -- ใช้ปุ่มนี้ในการ เปิด/ปิด
})

-- [NEW] สร้างปุ่ม Toggle เมนู (แสดงผลทุกอุปกรณ์ PC/Mobile)
do -- ใช้ do...end block แทน if เพื่อให้ตัวแปร local ไม่ชนกันข้างนอก
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileToggleGUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 10000 
    
    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name = "FluentToggle"
    ToggleBtn.Active = true 
    ToggleBtn.Size = UDim2.fromOffset(50, 50)
    ToggleBtn.Position = UDim2.new(0.5, -25, 0, 10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleBtn.BackgroundTransparency = 0.3
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Image = "rbxassetid://3926305904" 
    ToggleBtn.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ToggleBtn

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = ToggleBtn
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = "MENU"
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 10
    TextLabel.ZIndex = 101
    TextLabel.Visible = true

    task.spawn(function()
        local imageLink = "https://img5.pic.in.th/file/secure-sv1/LOGO1f992f72d5a3be82.png"
        local fileName = "SailorLogo_v3.png"
        if writefile and getcustomasset and game.HttpGet then
            local success, result = pcall(function()
                local content = game:HttpGet(imageLink)
                writefile(fileName, content)
                return getcustomasset(fileName)
            end)
            if success and result and type(result) == "string" and result ~= "" then
                ToggleBtn.Image = result
                TextLabel.Visible = false
            end
        end
    end)
    
    -- [แก้ไข] การกดปุ่ม (Mobile Fix V14 - Targeted Wake-up)
    ToggleBtn.MouseButton1Click:Connect(function()
        ToggleBtn:TweenSize(UDim2.fromOffset(45, 45), "Out", "Quad", 0.1, true)
        task.wait(0.1)
        ToggleBtn:TweenSize(UDim2.fromOffset(50, 50), "Out", "Quad", 0.1, true)

        local foundAndSuccess = false
        
        -- ค้นหา GUI เป้าหมาย
        local locations = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
        for _, loc in pairs(locations) do
            if loc then
                for _, gui in pairs(loc:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Name ~= "MobileToggleGUI" then
                        -- 1. หา Main Frame ที่ถูกต้อง (ที่มี Title ของเรา)
                        local mainFrame = nil
                        local isTarget = false
                        
                        -- เช็คว่าเป็น Fluent GUI หรือไม่ โดยดูจาก Title ข้างใน
                        -- เราจะไม่ Loop ลึกเกินไปเพื่อกันแลค และไม่เปิด Dropdown มั่ว
                        for _, child in pairs(gui:GetChildren()) do
                            if child:IsA("Frame") then
                                -- เช็คว่าเป็น Frame หลักหรือไม่ (ปกติ Frame หลักจะใหญ่)
                                if child.Size.X.Offset > 100 or child.Size.Y.Offset > 100 then
                                     -- ลองหา Title ใน Frame นี้
                                     for _, desc in pairs(child:GetDescendants()) do
                                        if desc:IsA("TextLabel") and (string.find(desc.Text, "Sailor Piece") or string.find(desc.Text, "Fluent")) then
                                            mainFrame = child
                                            isTarget = true
                                            break
                                        end
                                     end
                                end
                            end
                            if isTarget then break end
                        end
                        
                        if isTarget and mainFrame then
                            -- เจอเป้าหมายแล้ว!
                            
                            if not gui.Enabled then
                                -- 1. ถ้าปิดอยู่ -> เปิด + บังคับโชว์เฉพาะ Main Frame
                                gui.Enabled = true
                                mainFrame.Visible = true
                                Fluent:Notify({ Title = "Menu", Content = "Opened", Duration = 1 })
                            else
                                -- 2. ถ้าเปิดอยู่ (Enabled=true)
                                if not mainFrame.Visible then
                                    -- ถ้า Main Frame ซ่อนอยู่ (พับจอ) -> บังคับโชว์เฉพาะ Main Frame
                                    mainFrame.Visible = true
                                    Fluent:Notify({ Title = "Menu", Content = "Restored", Duration = 1 })
                                else
                                    -- ถ้าเปิดอยู่และเห็น Main Frame -> สั่งปิด
                                    gui.Enabled = false
                                    Fluent:Notify({ Title = "Menu", Content = "Closed", Duration = 1 })
                                end
                            end
                            foundAndSuccess = true
                            break
                        end
                    end
                end
            end
            if foundAndSuccess then break end
        end

        -- Backup Plan: ถ้าหา UI ไม่เจอจริงๆ ให้ใช้ VIM กดปุ่มช่วย
        if not foundAndSuccess then
            pcall(function()
                if VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
                end
            end)
        end
    end)
    
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- สร้าง Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "user" }),
    AllQuest = Window:AddTab({ Title = "All Quest", Icon = "book" }), 
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
    Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "swords" }), -- Dedicated Dungeon Category
    Stats = Window:AddTab({ Title = "Stats", Icon = "list" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "component" }), -- Added Misc Tab
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- [NEW] State Tracking Variables (ตัวแปรเก็บสถานะจริงจาก Server)
local HakiState = { Active = false, HasAbility = false }
local ObsState = { Active = false, HasAbility = false }

--------------------------------------------------------------------------------
-- ฟังก์ชันสำหรับ Server (Hop/Rejoin/VIP)
--------------------------------------------------------------------------------

local function ServerHop()
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    else
        Fluent:Notify({ Title = "Server Hop", Content = "ไม่พบเซิร์ฟเวอร์อื่นที่เหมาะสม", Duration = 3 })
    end
end

local function RejoinServer()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

local function JoinByLink(link)
    if link == "" then
        Fluent:Notify({ Title = "Error", Content = "กรุณากรอกลิงก์เซิร์ฟเวอร์ก่อน", Duration = 3 })
        return 
    end
    
    -- แก้ไข: ดึงรหัส code จากลิงก์รูปแบบต่างๆ
    local code = link:match("code=([%w%-]+)") or link:match("privateServerLinkCode=([%w%-]+)")
    
    if code then
        Fluent:Notify({ Title = "Teleporting", Content = "กำลังเดินทางไปยังเซิร์ฟเวอร์ส่วนตัว...", Duration = 5 })
        
        -- แก้ไขวิธีวาร์ปสำหรับ Client:
        -- ใช้ TeleportService:Teleport โดยส่ง code เข้าไปในรูปแบบที่ระบบรองรับ
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, code, LocalPlayer)
        end)
        
        -- สำรอง: หากด้านบนไม่ทำงาน (ขึ้นกับตัวรัน) จะใช้วิธีนี้
        task.wait(1)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer, {["privateServerLinkCode"] = code})
        end)
    else
        Fluent:Notify({ Title = "Invalid Link", Content = "ลิงก์ไม่ถูกต้อง หรือไม่พบรหัสเข้าห้อง", Duration = 3 })
    end
end

--------------------------------------------------------------------------------
-- ส่วนจัดการ Config (Summon Bosses)
--------------------------------------------------------------------------------

local SummonBossConfig = {
    ["SaberBoss"] = {
        SummonArgs = "SaberBoss", 
        SpawnPosition = CFrame.new(828.112915, -0.397191525, -1130.7666, 0.819155693, 0, 0.573571265, 0, 1, 0, -0.573571265, 0, 0.819155693)
    },
    ["QinShiBoss"] = {
        SummonArgs = "QinShiBoss",
        SpawnPosition = CFrame.new(828.112915, -0.397191525, -1130.7666, 0.819155693, 0, 0.573571265, 0, 1, 0, -0.573571265, 0, 0.819155693) 
    }
}

--------------------------------------------------------------------------------
-- ส่วนจัดการ Config (Farm Modes & Locations)
--------------------------------------------------------------------------------

local TeleportLocations = {
    ["SnowIsland"] = CFrame.new(-223.847488, -1.80199099, -1062.93848, 0.92051065, 0, 0.390717506, 0, 1, 0, -0.390717506, 0, 0.92051065),
    ["ShibuyaStation"] = CFrame.new(1359.47205, 10.5156441, 249.582214, 0.978984475, -0, -0.203934819, 0, 1, -0, 0.203934819, 0, 0.978984475),
    ["SailorIsland"] = CFrame.new(235.137619, 3.10643435, 659.73407, 0.987685978, 0, 0.156449571, 0, 1, 0, -0.156449571, 0, 0.987685978),
    ["JungleIsland"] = CFrame.new(-446.587311, -3.56074214, 368.797546, 0.848060429, -0, -0.529899538, 0, 1, -0, 0.529899538, 0, 0.848060429),
    ["DesertIsland"] = CFrame.new(-768.975037, -2.13288236, -361.697754, 0.984812498, -0, -0.173621148, 0, 1, -0, 0.173621148, 0, 0.984812498),
    ["BossIsland"] = CFrame.new(667.690002, -1.53785121, -1125.21899, 0.819155693, 0, 0.573571265, 0, 1, 0, -0.573571265, 0, 0.819155693),
    ["StarterIsland"] = CFrame.new(-94.7449417, -1.98583961, -244.801849, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376),
    ["XmasIsland"] = CFrame.new(282.780884, -2.77514267, -1479.36353, 0.987658858, -0, -0.156620622, 0, 1, -0, 0.156620622, 0, 0.987658858),
    ["HuecoMundoIsland"] = CFrame.new(-482.868896, -2.05866098, 936.237061, 0.838688612, -0, -0.544611216, 0, 1, -0, 0.544611216, 0, 0.838688612),
    ["DungeonIsland"] = CFrame.new(1298, 4, -841, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

local FarmModes = {
    ["Level 1-10 (Thief)"] = {
        Mobs = {"Thief"}, 
        QuestNPC = "QuestNPC1",
        MapName = "SailorIsland"
    },
    ["Level 25 (Thief Boss)"] = {
        Mobs = {"ThiefBoss", "Thief Boss"},
        QuestNPC = "QuestNPC2",
        MapName = "SailorIsland"
    },
    ["Level 250 (Monkey)"] = {
        Mobs = {"Monkey"},
        QuestNPC = "QuestNPC3",
        MapName = "JungleIsland"
    },
    ["Level 500 (Monkey Boss)"] = {
        Mobs = {"MonkeyBoss", "Monkey Boss"},
        QuestNPC = "QuestNPC4",
        MapName = "JungleIsland"
    },
    ["Level 750 (Desert Bandit)"] = {
        Mobs = {"DesertBandit", "Desert Bandit"},
        QuestNPC = "QuestNPC5",
        MapName = "DesertIsland"
    },
    ["Level 1000 (Desert Boss)"] = {
        Mobs = {"DesertBoss", "Desert Boss"},
        QuestNPC = "QuestNPC6",
        MapName = "DesertIsland"
    },
    ["Level 1500 (Frost Rogue)"] = {
        Mobs = {"FrostRogue", "Frost Rogue"},
        QuestNPC = "QuestNPC7",
        MapName = "SnowIsland"
    },
    ["Level 2000 (Snow Boss)"] = {
        Mobs = {"SnowBoss", "Snow Boss"},
        QuestNPC = "QuestNPC8",
        MapName = "SnowIsland"
    },
    ["Level 3000 (Sorcerer)"] = {
        Mobs = {"Sorcerer"}, 
        QuestNPC = "QuestNPC9",
        MapName = "ShibuyaStation"
    },
    ["Level 4000 (Panda MiniBoss)"] = {
        Mobs = {"PandaMiniBoss", "Panda MiniBoss", "Panda Boss", "Panda"}, 
        QuestNPC = "QuestNPC10",
        MapName = "ShibuyaStation"
    },
    ["Level 5000 (Hollow)"] = {
        Mobs = {"Hollow", "Hollow"}, 
        QuestNPC = "QuestNPC11",
        MapName = "HuecoMundoIsland"
    }
}

local NPCLocations = {
    ["Dark Blade Quest"] = CFrame.new(-122.211426, 14.817399, -1174.63635, -0.421103358, 0.0198266618, -0.906795979, -0.0300569907, 0.99890697, 0.0357986763, 0.906514585, 0.0423304997, -0.420047164),
    ["Haki Trainer"] = CFrame.new(-487.659241, 23.6579151, -1336.01538, 0.92051065, 0, 0.390717506, 0, 1, 0, -0.390717506, 0, 0.92051065),
    ["Santa"] = CFrame.new(406.284241, -3.7726171, -1446.953, 0.163159549, 0, 0.986599863, 0, 1, 0, -0.986599863, 0, 0.163159549),
    ["RagnaBuyer"] = CFrame.new(92.6486816, -2.46826172, -1460.51953, -0.390527487, 0, 0.920591295, 0, 1, 0, -0.920591295, 0, -0.390527487),
    ["RagnaQuestlineBuff"] = CFrame.new(446.879944, 43.6973267, -1923.98523, -0.202871442, 0.0159231964, -0.979075968, -0.00936316326, 0.999790549, 0.0182002001, 0.979160726, 0.0128595475, -0.202679873),
    ["SummonBossNPC"] = CFrame.new(692.040527, -3.67419362, -1085.31812, -0.819156051, 0, -0.544611216, 0, 1, 0, 0.544611216, 0, -0.819156051),
    ["EnchantNPC"] = CFrame.new(1415.31274, 8.84003067, 7.40811729, -0.989795089, 0, 0.142497987, 0, 1, 0, -0.142497987, 0, -0.989795089),
    ["GojoNpc"] = CFrame.new(1741.59265, 157.300507, 514.805054, -0.305511117, 0.00515563227, -0.952174604, 0.0269237738, 0.999632299, -0.00322606321, 0.951807797, -0.0266217291, -0.305537581),
    ["SukunaNpc"] = CFrame.new(1325.80103, 162.85965, -34.6844749, 0.142420411, -0.0172595233, 0.989655793, -3.65991145e-05, 0.999847889, 0.0174425393, -0.989806235, -0.00252039498, 0.142398119),
    ["Jinwoo Npc"] = CFrame.new(91.2260056, 2.98423171, 1097.46631, -0.819854856, -0.00342408568, 0.572561085, -0.0105738947, 0.999902129, -0.00916113332, -0.572473705, -0.0135650001, -0.819810867),
    ["TitleNpc"] = CFrame.new(369.152405, 2.79983521, 783.487427, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
    ["Random Fruit (Gem)"] = CFrame.new(400.641937, 2.79983521, 752.175842, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
    ["Random Fruit (Coin)"] = CFrame.new(408.244568, 2.82981968, 802.734131, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
    ["StorageNpc"] = CFrame.new(329.949493, 2.94520569, 764.059326, 0.15644598, -0, -0.987686574, 0, 1, -0, 0.987686574, 0, 0.15644598),
    ["TraitsNpc"] = CFrame.new(337.284302, 2.79983521, 813.846558, 0.15644598, -0, -0.987686574, 0, 1, -0, 0.987686574, 0, 0.15644598),
    ["AizenNpc"] = CFrame.new(-346.134552, 12.9912338, 1402.1001, -0.510350227, 0, -0.859966636, 0, 1, 0, 0.859966636, 0, -0.510350227),
    ["AizenQuestBuff"] = CFrame.new(-892.005066, 24.7202606, 1229.99414, -0.173624277, 0, 0.984811902, 0, 1, 0, -0.984811902, 0, -0.173624277),
    ["ObservationBuyer"] = CFrame.new(-787.772278, 12.1339779, -540.441956, -0.984812617, 0, 0.173621148, 0, 1, 0, -0.173621148, 0, -0.984812617),
    ["ArtifactsUnlocker"] = CFrame.new(-430.236389, 1.77979147, -1179.23547, -0.92051065, 0, -0.390717506, 0, 1, 0, 0.390717506, 0, -0.390717506),
    ["YujiBuyerNPC"] = CFrame.new(1240.19263, 136.700775, 408.188354, -0.35190773, 0, 0.936034739, 0, 1, 0, -0.936034739, 0, -0.35190773),
    ["RerollStatNPC"] = CFrame.new(373.071747, 2.79983521, 810.098328, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
    ["Merchant"] = CFrame.new(368.817719, 2.79983521, 783.589844, -0.156446099, 0, 0.987686574, 0, 1, 0, -0.987686574, 0, -0.156446099),
    ["ShadowQuestlineBuff"]= CFrame.new(335.123474, 25.5055599, -377.073486, 0.690896153, -0.0138966013, -0.722820461, 0.000865913928, 0.999830425, -0.0183945931, 0.722953498, 0.0120828543, 0.690791011),
    ["CidBuyer"]= CFrame.new(1428.22986, 49.2211456, -976.904297, 0.906293869, 0.0733761713, -0.416230023, -4.76837158e-07, 0.984814584, 0.173609525, 0.422648191, -0.157341033, 0.892531395)
}

local BossLocations = {
    ["JinwooBoss"] = CFrame.new(311.442261, 7.59386587, 946.90509, -0.953600168, 0, -0.301075935, 0, 1, 0, 0.301075935, 0, -0.953600168),
    ["SukunaBoss"] = CFrame.new(1571.26672, 80.2205353, -34.1126976, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["GojoBoss"] = CFrame.new(1855.56628, 8.48613453, 341.594879, 0.999688804, -0, -0.0249451213, 0, 1, -0, 0.0249451213, 0, 0.999688804),
    ["AizenBoss"] = CFrame.new(-567.223083, 2.57872534, 1228.49036, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["YujiBoss"] = CFrame.new(1537.92871, 12.9861355, 226.108246, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

local WeaponGroups = {
    ["Combat"] = {
        "Combat" , "Gojo" , "Sukuna", "Qin Shi","Yuji"
    }, 
    ["Sword"] = { 
        "Katana", "Dark Blade", "Ragna", "Saber", "Jinwoo" , 'Aizen' , "Shadow"
    } 
}

local CurrentMode = "Level 1-10 (Thief)"
local CodeList = {
    "200KVISITS", "3000CCU", "3KLIKES", "QUESTBUGFIXSORRY",
    "UPDATE0.5", "TRAITS", "NEWYEAR", "CHRISTMAS", "RELEASE"
}

--------------------------------------------------------------------------------
-- ส่วนจัดการ Remote Events (Farm, Stats, Codes)
--------------------------------------------------------------------------------

local function AcceptQuest()
    local npcName = FarmModes[CurrentMode].QuestNPC
    local args = { npcName }
    local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept", 2)
    if remote then
        remote:FireServer(unpack(args))
    end
end

local function AbandonQuest()
    local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QuestAbandon", 2)
    if remote then
        remote:FireServer()
    end
end

local function RequestHit()
    local combatSystem = ReplicatedStorage:WaitForChild("CombatSystem", 5)
    if combatSystem then
        local remotes = combatSystem:WaitForChild("Remotes", 5)
        if remotes then
            local hitRemote = remotes:WaitForChild("RequestHit", 5)
            if hitRemote then
                hitRemote:FireServer()
            end
        end
    end
end

local function UpgradeStat(statName)
    local args = { statName, 999 }
    local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AllocateStat", 2)
    if remote then
        remote:FireServer(unpack(args))
    end
end

local function ResetStats()
    local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ResetStats", 2)
    if remote then
        remote:FireServer()
    end
end

local function RedeemCode(code)
    local args = { code }
    local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CodeRedeem")
    if remote then
        pcall(function()
            remote:InvokeServer(unpack(args))
        end)
    end
end

local function EquipWeapon(groupName)
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local targetWeapons = WeaponGroups[groupName] or {groupName}

    for _, name in ipairs(targetWeapons) do
        local equipped = LocalPlayer.Character:FindFirstChild(name)
        if equipped then return end 
    end

    if LocalPlayer:FindFirstChild("Backpack") then
        for _, name in ipairs(targetWeapons) do
            local tool = LocalPlayer.Backpack:FindFirstChild(name)
            if tool then
                humanoid:EquipTool(tool)
                return 
            end
        end
    end
end

local function TeleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

--------------------------------------------------------------------------------
-- ระบบ ESP (Main Tab)
--------------------------------------------------------------------------------
local ESP_Enabled = false
local ESP_Connections = {}

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local esp = root:FindFirstChild("FluentESP")
            
            if ESP_Enabled then
                if not esp then
                    esp = Instance.new("BillboardGui")
                    esp.Name = "FluentESP"
                    esp.Size = UDim2.new(0, 200, 0, 50)
                    esp.AlwaysOnTop = true
                    esp.StudsOffset = Vector3.new(0, 3.5, 0)
                    
                    local nameLabel = Instance.new("TextLabel", esp)
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.fromRGB(255, 105, 180) -- สีชมพู Rose
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
                    nameLabel.TextSize = 14
                    nameLabel.Font = Enum.Font.Bold
                    nameLabel.Name = "NameLabel"
                    
                    esp.Parent = root
                end
                
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    esp.NameLabel.Text = string.format("%s\n[%.0f m]", player.Name, dist)
                end
            else
                if esp then esp:Destroy() end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- UI Elements
--------------------------------------------------------------------------------

do
    -- >> Tab: Main <<
    
    -- [Group] Player Mods
    Tabs.Main:AddSection("Player Mods")
    
    local SpeedToggle = Tabs.Main:AddToggle("SpeedHack", {Title = "Speed Hack", Default = false })
    SpeedToggle:OnChanged(function()
        if not Options.SpeedHack.Value then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16 
            end
        end
    end)
    
    local JumpToggle = Tabs.Main:AddToggle("InfJump", {Title = "Infinity Jump", Default = false })
    local ESPToggle = Tabs.Main:AddToggle("EspPlayer", {Title = "ESP Player", Default = false })
    
    ESPToggle:OnChanged(function()
        ESP_Enabled = Options.EspPlayer.Value
    end)

    -- [Group] Redeem Codes
    Tabs.Main:AddSection("Redeem Codes")

    Tabs.Main:AddButton({
        Title = "Redeem All Codes",
        Description = "รับของรางวัลจากทุกโค้ด",
        Callback = function()
            for _, code in ipairs(CodeList) do
                task.spawn(function()
                    RedeemCode(code)
                end)
                task.wait(0.1) 
            end
            Fluent:Notify({ Title = "Success", Content = "Redeemed all codes!", Duration = 3 })
        end
    })

    -- [Group] Chests
    Tabs.Main:AddSection("Chests")
    Tabs.Main:AddToggle("AutoOpenChests", {Title = "Auto Open Chests", Default = false })
end

do
    -- >> Tab: All Quest <<
    Tabs.AllQuest:AddSection("Haki Quest")
    
    Tabs.AllQuest:AddParagraph({
        Title = "Auto Quest Haki",
        Content = "1. Teleport to Haki Teacher\n2. Press E\n3. Farm Thieves (Combat Only)"
    })

    local HakiQuestToggle = Tabs.AllQuest:AddToggle("AutoQuestHaki", {Title = "Auto Quest Haki", Default = false })
    local SkillZToggle = Tabs.AllQuest:AddToggle("UseSkillZHaki", {Title = "Use Skill Z", Default = false })
    local PunchToggle = Tabs.AllQuest:AddToggle("AutoPunchHaki", {Title = "Auto Punch", Default = false })
    
    -- Variables for logic
    local HakiState = "NPC"
    
    HakiQuestToggle:OnChanged(function()
        if not Options.AutoQuestHaki.Value then
            HakiState = "NPC" -- Reset logic when turned off
        end
    end)

    -- Logic Loop for Haki Quest
    task.spawn(function()
        local npcFrame = CFrame.new(-487.659241, 23.6579151, -1336.01538, 0.92051065, 0, 0.390717506, 0, 1, 0, -0.390717506, 0, 0.92051065)
        while true do
            task.wait()
            if Options.AutoQuestHaki.Value then
                pcall(function()
                    EquipWeapon("Combat") -- Force Combat
                    
                    if HakiState == "NPC" then
                        TeleportTo(npcFrame)
                        -- Check distance
                        if (LocalPlayer.Character.HumanoidRootPart.Position - npcFrame.Position).Magnitude < 10 then
                            task.wait(0.5)
                            -- Press E once
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(1)
                            Fluent:Notify({ Title = "Haki Quest", Content = "Quest Accepted! Starting Farm...", Duration = 3 })
                            HakiState = "Farm" -- Switch state to farm
                        end
                    elseif HakiState == "Farm" then
                        -- Find Closest Thief from the Config List (Smart Match)
                        local closestThief = nil
                        local minDst = math.huge
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        -- Define target names
                        local targetNames = FarmModes["Level 1-10 (Thief)"].Mobs
                        
                        if myRoot then
                             local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                             
                             for _, location in pairs(searchLocations) do
                                if location then
                                    for _, v in pairs(location:GetChildren()) do
                                        -- Smart Match Logic
                                        local isTarget = false
                                        for _, name in pairs(targetNames) do
                                            -- ค้นหาชื่อที่มี Thief แต่ไม่มีคำว่า Boss
                                            if string.find(v.Name, name) then
                                                if not string.find(name:lower(), "boss") and string.find(v.Name:lower(), "boss") then
                                                    isTarget = false -- ข้ามถ้าเราจะเอา Thief แต่ตัวที่เจอดันมีชื่อ Boss
                                                else
                                                    isTarget = true
                                                    break
                                                end
                                            end
                                        end

                                        if isTarget and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                            local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                            if dst < minDst then
                                                minDst = dst
                                                closestThief = v
                                            end
                                        end
                                    end
                                end
                             end
                        end
                        
                        if closestThief then
                            local tPos = closestThief.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            TeleportTo(CFrame.lookAt(tPos.Position, closestThief.HumanoidRootPart.Position))
                            RequestHit() 
                        end
                    end
                end)
            end
        end
    end)
    
    -- Logic Loop for Skill Z
    task.spawn(function()
        while true do
            task.wait(1)
            if Options.UseSkillZHaki.Value then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
            end
        end
    end)

    -- Logic Loop for Auto Punch (Combat Only)
    task.spawn(function()
        while true do
            task.wait(0.1)
            if Options.AutoPunchHaki.Value then
                 pcall(function()
                    EquipWeapon("Combat")
                    RequestHit()
                 end)
            end
        end
    end)

    -- Jinwoo Quest Section
    Tabs.AllQuest:AddSection("Jinwoo Quest")
    
    Tabs.AllQuest:AddParagraph({
        Title = "Auto Quest Jinwoo",
        Content = "1.Jinwoo questline : Take 10M damage, kill 750 NPCs, deal 100M damage, kill 35 players, kill Jinwoo Boss 15 times \n2. item :  2,500,000 Money + 7,500 Gems + 6x Abyss Eadge + 3x Dark Ring + 1x Shadow Heart."
    })

    local JinwooQuestToggle = Tabs.AllQuest:AddToggle("AutoQuestJinwoo", {Title = "Auto Quest Jinwoo", Default = false })
    local JinwooFarmMobsToggle = Tabs.AllQuest:AddToggle("AutoFarmJinwooMobs", {Title = "Kill 750 NPCs", Default = false }) 
    local JinwooKillPlayersToggle = Tabs.AllQuest:AddToggle("AutoKill35Players", {Title = "Auto Kill 35 Players", Default = false }) 
    local JinwooDummyToggle = Tabs.AllQuest:AddToggle("AutoDummyJinwoo", {Title = "Auto Farm Dummy", Default = false }) -- ฟังก์ชันใหม่ที่เพิ่มเข้ามาตามคำขอ
    
    local JinwooState = "NPC"
    
    JinwooQuestToggle:OnChanged(function()
        if not Options.AutoQuestJinwoo.Value then
            JinwooState = "NPC"
        end
    end)

    -- ระบบ Auto Farm Dummy (TrainingDummy)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoDummyJinwoo and Options.AutoDummyJinwoo.Value then
                pcall(function()
                    local dummy = nil
                    -- ค้นหา TrainingDummy ใน Workspace
                    local searchLocations = {Workspace, Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs"), Workspace:FindFirstChild("Mobs")}
                    for _, loc in pairs(searchLocations) do
                        if loc then
                            local found = loc:FindFirstChild("TrainingDummy")
                            if found and found:FindFirstChild("HumanoidRootPart") then
                                dummy = found
                                break
                            end
                        end
                    end

                    if dummy then
                        local targetRoot = dummy.HumanoidRootPart
                        local tPos = targetRoot.CFrame * CFrame.new(0, 0, 3.5)
                        
                        TeleportTo(tPos)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, targetRoot.Position)
                        
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                    end
                end)
            end
        end
    end)

    -- ระบบ Auto Kill Players (35 Players)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoKill35Players and Options.AutoKill35Players.Value then
                pcall(function()
                    local closestPlayer = nil
                    local minDistance = math.huge
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            -- เช็คว่าไม่ใช่ตัวเรา และไม่มี ForceField (อมตะตอนเกิด)
                            if not player.Character:FindFirstChildOfClass("ForceField") then
                                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if dist < minDistance then
                                    minDistance = dist
                                    closestPlayer = player
                                end
                            end
                        end
                    end

                    if closestPlayer then
                        local targetRoot = closestPlayer.Character.HumanoidRootPart
                        local tPos = targetRoot.CFrame * CFrame.new(0, 0, 3.5) -- อยู่หลังเป้าหมายเล็กน้อย
                        
                        TeleportTo(tPos)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, targetRoot.Position)
                        
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                        
                        -- ถ้าเป้าหมายตายแล้วให้รอสักครู่ก่อนหาคนใหม่
                        if closestPlayer.Character.Humanoid.Health <= 0 then
                            task.wait(0.5)
                        end
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        local jinwooNPCFrame = CFrame.new(91.2260056, 2.98423171, 1097.46631, -0.819854856, -0.00342408568, 0.572561085, -0.0105738947, 0.999902129, -0.00916113332, -0.572473705, -0.0135650001, -0.819810867)
        while true do
            task.wait()
            if Options.AutoQuestJinwoo.Value then
                pcall(function()
                    if JinwooState == "NPC" then
                        TeleportTo(jinwooNPCFrame)
                        if (LocalPlayer.Character.HumanoidRootPart.Position - jinwooNPCFrame.Position).Magnitude < 10 then
                            task.wait(0.5)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(1)
                            Fluent:Notify({ Title = "Jinwoo Quest", Content = "Quest Accepted! Farming Boss...", Duration = 3 })
                            JinwooState = "Boss"
                        end
                    elseif JinwooState == "Boss" then
                        -- Farm Jinwoo Boss
                        local targetName = "JinwooBoss"
                        local target = nil
                        
                        -- Reuse search logic or just define it here
                        local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        for _, loc in pairs(searchLocations) do
                            if loc then
                                local found = loc:FindFirstChild(targetName)
                                if found and found:FindFirstChild("Humanoid") and found.Humanoid.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
                                    target = found
                                    break
                                end
                            end
                        end

                        if target then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                                EquipWeapon(Options.SelectWeapon.Value)
                                RequestHit()
                            end
                        else
                            -- Teleport to spawn if not found (using BossLocations if available or hardcoded)
                            -- JinwooBoss location is in BossLocations table in the script
                            if BossLocations["JinwooBoss"] then
                                TeleportTo(BossLocations["JinwooBoss"])
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- New Logic for Jinwoo Mobs Farm (Lv1-4000)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoFarmJinwooMobs.Value then
                pcall(function()
                    local target = nil
                    local minDst = math.huge
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                    if myRoot then
                        -- Define all target names from FarmModes (Lv1-4000)
                        local targetNames = {}
                        for _, mode in pairs(FarmModes) do
                            for _, mobName in pairs(mode.Mobs) do
                                table.insert(targetNames, mobName)
                            end
                        end

                        local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        
                        for _, location in pairs(searchLocations) do
                            if location then
                                for _, v in pairs(location:GetChildren()) do
                                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                        for _, name in pairs(targetNames) do
                                            -- Smart Match
                                            if string.find(v.Name, name) then
                                                if not string.find(name:lower(), "boss") and string.find(v.Name:lower(), "boss") then
                                                    -- skip
                                                else
                                                    local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                                    if dst < minDst then
                                                        minDst = dst
                                                        target = v
                                                    end
                                                    break 
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if target then
                        local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                    end
                end)
            end
        end
    end)

    -- Sukuna Quest Section (Added Functionality similar to Jinwoo Quest)
    Tabs.AllQuest:AddSection("Sukuna Quest")
    
    Tabs.AllQuest:AddParagraph({
        Title = "Auto Quest Sukuna",
        Content = "1.Sukuna questline : Deal 25M damage, kill 25 players, kill Sukuna Boss 15 times.\n2. item :  1,250,000 Money + 5,000 Gems + 6x Cursed Finger + 3x Dismantle Fang + 1x Crimson Heart."
    })

    local SukunaQuestToggle = Tabs.AllQuest:AddToggle("AutoQuestSukuna", {Title = "Auto Quest Sukuna", Default = false })
    local SukunaKillPlayersToggle = Tabs.AllQuest:AddToggle("AutoKillPlayersSukuna", {Title = "Auto Kill Players (Sukuna)", Default = false })
    
    local SukunaState = "NPC"
    
    SukunaQuestToggle:OnChanged(function()
        if not Options.AutoQuestSukuna.Value then
            SukunaState = "NPC"
        end
    end)

    -- Logic: Auto Boss Sukuna
    task.spawn(function()
        local sukunaNPCFrame = NPCLocations["SukunaNpc"]
        while true do
            task.wait()
            if Options.AutoQuestSukuna.Value then
                pcall(function()
                    if SukunaState == "NPC" then
                        TeleportTo(sukunaNPCFrame)
                        if (LocalPlayer.Character.HumanoidRootPart.Position - sukunaNPCFrame.Position).Magnitude < 10 then
                            task.wait(0.5)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(1)
                            Fluent:Notify({ Title = "Sukuna Quest", Content = "Quest Accepted! Farming Boss...", Duration = 3 })
                            SukunaState = "Boss"
                        end
                    elseif SukunaState == "Boss" then
                        local targetName = "SukunaBoss"
                        local target = nil
                        local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        for _, loc in pairs(searchLocations) do
                            if loc then
                                local found = loc:FindFirstChild(targetName)
                                if found and found:FindFirstChild("Humanoid") and found.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
                                    target = found
                                    break
                                end
                            end
                        end
                        if target then
                            local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                            EquipWeapon(Options.SelectWeapon.Value)
                            RequestHit()
                        else
                            if BossLocations["SukunaBoss"] then
                                TeleportTo(BossLocations["SukunaBoss"])
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- Logic: Auto Kill Players (Sukuna)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoKillPlayersSukuna and Options.AutoKillPlayersSukuna.Value then
                pcall(function()
                    local closestPlayer = nil
                    local minDistance = math.huge
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            if not player.Character:FindFirstChildOfClass("ForceField") then
                                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if dist < minDistance then minDistance = dist; closestPlayer = player end
                            end
                        end
                    end
                    if closestPlayer then
                        local targetRoot = closestPlayer.Character.HumanoidRootPart
                        local tPos = targetRoot.CFrame * CFrame.new(0, 0, 3.5)
                        TeleportTo(tPos)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, targetRoot.Position)
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                        if closestPlayer.Character.Humanoid.Health <= 0 then task.wait(0.5) end
                    end
                end)
            end
        end
    end)

    -- Gojo Quest Section (New Functionality added like Jinwoo Quest)
    Tabs.AllQuest:AddSection("Gojo Quest")
    
    -- [แก้ไขบรรทัดที่ 1133] แก้ไข Tabs.AllParagraph เป็น Tabs.AllQuest:AddParagraph
    Tabs.AllQuest:AddParagraph({
        Title = "Auto Quest Gojo",
        Content = "1.Gojo questline : Kill 350 NPCs, use 350 abilities, kill Gojo Boss 15 times.\n2. item:  750,000 Money + 4,000 Gems + 6x Void Fragment + 3x Limitless Ring + 1x Infinity Core.."
    })

    local GojoQuestToggle = Tabs.AllQuest:AddToggle("AutoQuestGojo", {Title = "Auto Quest Gojo", Default = false })
    local GojoKillPlayersToggle = Tabs.AllQuest:AddToggle("AutoKillPlayersGojo", {Title = "Auto Kill Players (Gojo)", Default = false })
    local GojoDummyToggle = Tabs.AllQuest:AddToggle("AutoDummyGojo", {Title = "Auto Farm Dummy (Gojo)", Default = false })
    
    local GojoState = "NPC"
    
    GojoQuestToggle:OnChanged(function()
        if not Options.AutoQuestGojo.Value then
            GojoState = "NPC"
        end
    end)

    -- Logic: Auto Boss Gojo
    task.spawn(function()
        local gojoNPCFrame = NPCLocations["GojoNpc"]
        while true do
            task.wait()
            if Options.AutoQuestGojo.Value then
                pcall(function()
                    if GojoState == "NPC" then
                        TeleportTo(gojoNPCFrame)
                        if (LocalPlayer.Character.HumanoidRootPart.Position - gojoNPCFrame.Position).Magnitude < 10 then
                            task.wait(0.5)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(1)
                            Fluent:Notify({ Title = "Gojo Quest", Content = "Quest Accepted! Farming Boss...", Duration = 3 })
                            GojoState = "Boss"
                        end
                    elseif GojoState == "Boss" then
                        local targetName = "GojoBoss"
                        local target = nil
                        local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        for _, loc in pairs(searchLocations) do
                            if loc then
                                local found = loc:FindFirstChild(targetName)
                                if found and found:FindFirstChild("Humanoid") and found.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
                                    target = found
                                    break
                                end
                            end
                        end
                        if target then
                            local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                            EquipWeapon(Options.SelectWeapon.Value)
                            RequestHit()
                        else
                            if BossLocations["GojoBoss"] then
                                TeleportTo(BossLocations["GojoBoss"])
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- Logic: Auto Kill Players (Gojo)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoKillPlayersGojo and Options.AutoKillPlayersGojo.Value then
                pcall(function()
                    local closestPlayer = nil
                    local minDistance = math.huge
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Health > 0 then
                            if not player.Character:FindFirstChildOfClass("ForceField") then
                                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if dist < minDistance then minDistance = dist; closestPlayer = player end
                            end
                        end
                    end
                    if closestPlayer then
                        local targetRoot = closestPlayer.Character.HumanoidRootPart
                        local tPos = targetRoot.CFrame * CFrame.new(0, 0, 3.5)
                        TeleportTo(tPos)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, targetRoot.Position)
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                        if closestPlayer.Character.Humanoid.Health <= 0 then task.wait(0.5) end
                    end
                end)
            end
        end
    end)

    -- Logic: Auto Farm Dummy (Gojo)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoDummyGojo and Options.AutoDummyGojo.Value then
                pcall(function()
                    local dummy = nil
                    local searchLocations = {Workspace, Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs"), Workspace:FindFirstChild("Mobs")}
                    for _, loc in pairs(searchLocations) do
                        if loc then
                            local found = loc:FindFirstChild("TrainingDummy")
                            if found and found:FindFirstChild("HumanoidRootPart") then
                                dummy = found
                                break
                            end
                        end
                    end
                    if dummy then
                        local targetRoot = dummy.HumanoidRootPart
                        local tPos = targetRoot.CFrame * CFrame.new(0, 0, 3.5)
                        TeleportTo(tPos)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, targetRoot.Position)
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                    end
                end)
            end
        end
    end)

    -- Aizen Quest Section (New Functionality)
    Tabs.AllQuest:AddSection("Aizen Quest")
    
    Tabs.AllQuest:AddParagraph({
        Title = "Auto Quest Aizen",
        Content = "1. Questline Info... (Similar to others)\n2. Requires Aizen Boss Kill."
    })

    local AizenQuestToggle = Tabs.AllQuest:AddToggle("AutoQuestAizen", {Title = "Auto Quest Aizen", Default = false })
    local AizenKillPlayersToggle = Tabs.AllQuest:AddToggle("AutoKillPlayersAizen", {Title = "Auto Kill Players (Aizen)", Default = false })
    local AutoKillHollow250 = Tabs.AllQuest:AddToggle("AutoKillHollow250", {Title = "Auto Kill Hollow (Limit 250)", Default = false })
    
    local AizenState = "NPC"
    
    AizenQuestToggle:OnChanged(function()
        if not Options.AutoQuestAizen.Value then
            AizenState = "NPC"
        end
    end)

    -- Variable for Hollow Count
    local hollowCount = 0
    AutoKillHollow250:OnChanged(function()
        if Options.AutoKillHollow250.Value then
            hollowCount = 0
            Fluent:Notify({ Title = "Aizen Quest", Content = "Started killing Hollows. Progress: 0/250", Duration = 3 })
        end
    end)

    -- Logic: Auto Kill Hollow (Limit 250)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoKillHollow250.Value then
                -- Check Limit
                if hollowCount >= 250 then
                    Options.AutoKillHollow250:SetValue(false)
                    Fluent:Notify({ Title = "Aizen Quest", Content = "Completed! Killed 250 Hollows.", Duration = 5 })
                    continue
                end

                pcall(function()
                    local target = nil
                    local minDst = math.huge
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if myRoot then
                        local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        for _, loc in pairs(searchLocations) do
                             if loc then
                                for _, v in pairs(loc:GetChildren()) do
                                    -- Check name "Hollow" (Smart Match)
                                    if string.find(v.Name, "Hollow") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                        local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                        if dst < minDst then
                                            minDst = dst
                                            target = v
                                        end
                                    end
                                end
                             end
                        end
                    end

                    if target then
                        -- Attack logic loop for specific target to track death
                        local hum = target.Humanoid
                        repeat
                            if not Options.AutoKillHollow250.Value then break end
                            if not target or not target.Parent or hum.Health <= 0 then break end
                            
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                                EquipWeapon(Options.SelectWeapon.Value)
                                RequestHit()
                            end
                            task.wait()
                        until hum.Health <= 0 or not target.Parent

                        -- Increment count if dead
                        if hum.Health <= 0 then
                            hollowCount = hollowCount + 1
                            -- Notify every 10 kills
                             if hollowCount % 10 == 0 then
                                 Fluent:Notify({ Title = "Progress", Content = "Hollows Killed: " .. hollowCount .. "/250", Duration = 2 })
                             end
                        elseif not target.Parent then
                             -- Assume kill if parent removed while attacking
                             hollowCount = hollowCount + 1
                        end
                    else
                         -- Teleport to Hueco Mundo or Shibuya if not found (Using Shibuya as per config)
                         if TeleportLocations["HuecoMundoIsland"] then
                             TeleportTo(TeleportLocations["HuecoMundoIsland"])
                             task.wait(1)
                         end
                    end
                end)
            end
        end
    end)

    -- Logic: Auto Boss Aizen
    task.spawn(function()
        local aizenNPCFrame = NPCLocations["AizenNpc"]
        while true do
            task.wait()
            if Options.AutoQuestAizen.Value then
                pcall(function()
                    if AizenState == "NPC" then
                        if aizenNPCFrame then
                            TeleportTo(aizenNPCFrame)
                            if (LocalPlayer.Character.HumanoidRootPart.Position - aizenNPCFrame.Position).Magnitude < 10 then
                                task.wait(0.5)
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.1)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                task.wait(1)
                                Fluent:Notify({ Title = "Aizen Quest", Content = "Quest Accepted! Farming Boss...", Duration = 3 })
                                AizenState = "Boss"
                            end
                        else
                            warn("Aizen NPC Location not found!")
                        end
                    elseif AizenState == "Boss" then
                        local targetName = "AizenBoss"
                        local target = nil
                        local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        for _, loc in pairs(searchLocations) do
                            if loc then
                                local found = loc:FindFirstChild(targetName)
                                if found and found:FindFirstChild("Humanoid") and found.Humanoid.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
                                    target = found
                                    break
                                end
                            end
                        end
                        if target then
                            local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                            EquipWeapon(Options.SelectWeapon.Value)
                            RequestHit()
                        else
                            if BossLocations["AizenBoss"] then
                                TeleportTo(BossLocations["AizenBoss"])
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- Logic: Auto Kill Players (Aizen)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoKillPlayersAizen and Options.AutoKillPlayersAizen.Value then
                pcall(function()
                    local closestPlayer = nil
                    local minDistance = math.huge
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            if not player.Character:FindFirstChildOfClass("ForceField") then
                                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if dist < minDistance then minDistance = dist; closestPlayer = player end
                            end
                        end
                    end
                    if closestPlayer then
                        local targetRoot = closestPlayer.Character.HumanoidRootPart
                        local tPos = targetRoot.CFrame * CFrame.new(0, 0, 3.5)
                        TeleportTo(tPos)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, targetRoot.Position)
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                        if closestPlayer.Character.Humanoid.Health <= 0 then task.wait(0.5) end
                    end
                end)
            end
        end
    end)
end

do
    -- >> Tab: Auto Farm <<
    
    -- [Group] Weapon Settings (ใช้ AddSection แทน Paragraph)
    Tabs.AutoFarm:AddSection("Weapon Settings")
    
    local WeaponDropdown = Tabs.AutoFarm:AddDropdown("SelectWeapon", {
        Title = "Select Weapon (เลือกอาวุธ)",
        Values = {"Combat", "Sword"}, 
        Multi = false,
        Default = 1,
    })

    local AutoEquipToggle = Tabs.AutoFarm:AddToggle("AutoEquip", {Title = "Auto Equip (สวมใส่อัตโนมัติ)", Default = false })

    -- [NEW SECTION] AutoFarm No Quest
    Tabs.AutoFarm:AddSection("Auto Farm No Quest")
    
    local AutoFarmAllBosses = Tabs.AutoFarm:AddToggle("AutoFarmAllBosses", {Title = "Auto Farm All Boss", Default = false })
    local AutoFarmAllMobs = Tabs.AutoFarm:AddToggle("AutoFarmAllMobs", {Title = "Auto Farm All Mobs (ตีมอนทั้งหมด)", Default = false })

    -- [Group] Mob Settings
    Tabs.AutoFarm:AddSection("Mob Settings")

    local ModeDropdown = Tabs.AutoFarm:AddDropdown("FarmMode", {
        Title = "Select Monsters",
        Values = {
            "Level 1-10 (Thief)", 
            "Level 25 (Thief Boss)",
            "Level 250 (Monkey)",
            "Level 500 (Monkey Boss)",
            "Level 750 (Desert Bandit)",
            "Level 1000 (Desert Boss)",
            "Level 1500 (Frost Rogue)",
            "Level 2000 (Snow Boss)",
            "Level 3000 (Sorcerer)",
            "Level 4000 (Panda MiniBoss)",
            "Level 5000 (Hollow)"
        },
        Multi = false,
        Default = 1,
    })

    -- [แก้ไขบัค] เพิ่มเงื่อนไข if Options.AutoFarm.Value แล้วค่อย AbandonQuest เพื่อไม่ให้ยกเลิกเควสตอนเข้าเกม
    ModeDropdown:OnChanged(function(Value)
        CurrentMode = Value
        if Options.AutoFarm and Options.AutoFarm.Value then
            AbandonQuest()
        end
    end)

    local FarmToggle = Tabs.AutoFarm:AddToggle("AutoFarm", {Title = "Auto Farm (เริ่มฟาร์ม)", Default = false })

    FarmToggle:OnChanged(function()
        if Options.AutoFarm.Value then
            AbandonQuest()
            task.wait(0.5)
            AcceptQuest() 
        end
    end)

    -- [Group] Auto Farm Boss
    Tabs.AutoFarm:AddSection("Auto Farm Boss")

    local BossList = {"JinwooBoss", "SukunaBoss", "GojoBoss", "AizenBoss","YujiBoss"}
    local SelectedBosses = {}

    local BossDropdown = Tabs.AutoFarm:AddDropdown("SelectBoss", {
        Title = "Select Boss (Multi-Select)",
        Values = BossList,
        Multi = true,
        Default = {},
    })

    BossDropdown:OnChanged(function(Value)
        SelectedBosses = {}
        for val, state in pairs(Value) do
            if state then
                table.insert(SelectedBosses, val)
            end
        end
    end)

    local BossFarmToggle = Tabs.AutoFarm:AddToggle("AutoFarmBoss", {Title = "Auto Farm Boss", Default = false })

    -- Logic Loop for Auto Farm Boss
   task.spawn(function()
    local MainBossNames = {
        "JinwooBoss", "SukunaBoss", "GojoBoss", "AizenBoss", "YujiBoss", 
    }

    local IslandMobNames = {}
    for _, mode in pairs(FarmModes) do
        for _, mobName in pairs(mode.Mobs) do
            table.insert(IslandMobNames, mobName)
        end
    end

    local function IsMainBoss(name)
        for _, boss in ipairs(MainBossNames) do
            if string.find(name, boss) then return true end
        end
        return false
    end

    while true do
        task.wait()
        local target = nil
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if myRoot then
            local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
            
            -- Priority 1: All Bosses (Main Bosses Only)
            if Options.AutoFarmAllBosses.Value then
                for _, loc in pairs(folders) do
                    if loc then
                        for _, v in pairs(loc:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                if IsMainBoss(v.Name) then
                                    target = v
                                    break
                                end
                            end
                        end
                    end
                    if target then break end
                end
            end

            -- Priority 2: All Mobs (Island Mobs - Includes mini bosses in island list)
            if not target and Options.AutoFarmAllMobs.Value then
                local closestDist = math.huge
                for _, loc in pairs(folders) do
                    if loc then
                        for _, v in pairs(loc:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                if not Players:GetPlayerFromCharacter(v) then
                                    local isIslandMob = false
                                    for _, mobName in ipairs(IslandMobNames) do
                                        if string.find(v.Name, mobName) then
                                            isIslandMob = true
                                            break
                                        end
                                    end

                                    if isIslandMob then
                                        local d = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                        if d < closestDist then
                                            closestDist = d
                                            target = v
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if target then
                local hrp = target:FindFirstChild("HumanoidRootPart")
                local tPos = hrp.CFrame * CFrame.new(0, 0, 4)
                TeleportTo(CFrame.lookAt(tPos.Position, hrp.Position))
                EquipWeapon(Options.SelectWeapon.Value)
                RequestHit()
            end
        end
    end
end)
    
    -- [Group] Farm Boss Summon (Updated Feature)
    Tabs.AutoFarm:AddSection("Farm Boss Summon")
    
    local SummonBossList = {}
    for name, _ in pairs(SummonBossConfig) do table.insert(SummonBossList, name) end

    local SummonDropdown = Tabs.AutoFarm:AddDropdown("SelectSummonBoss", {
        Title = "Select Summon Boss",
        Values = SummonBossList,
        Multi = false,
        Default = 1,
    })

    local AutoSummonFarmToggle = Tabs.AutoFarm:AddToggle("AutoFarmSummonBoss", {Title = "Auto Farm Summon Boss (Summon & Kill)", Default = false })

    -- เพิ่มส่วนที่ขอ: Auto Haki (กด G)
    Tabs.AutoFarm:AddSection("Auto Haki")
    Tabs.AutoFarm:AddToggle("AutoHaki", {Title = "Auto Haki", Default = false })
    Tabs.AutoFarm:AddToggle("AutoObservationHaki", {Title = "Auto ObservationHaki", Default = false })

    -- Logic: Auto Farm Summon Boss (Combined Summon & Kill)
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoFarmSummonBoss.Value then
                pcall(function()
                    local selectedBossKey = Options.SelectSummonBoss.Value
                    local bossConfig = SummonBossConfig[selectedBossKey]

                    if bossConfig then
                        local target = nil
                        -- 1. Search for Selected Boss
                        local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        for _, loc in pairs(searchLocations) do
                            if loc then
                                local found = loc:FindFirstChild(selectedBossKey) -- ลองหาด้วยชื่อตรงๆก่อน
                                if found and found:FindFirstChild("Humanoid") and found.Humanoid.Health > 0 and found:FindFirstChild("HumanoidRootPart") then
                                    target = found
                                    break
                                end
                            end
                        end

                        if target then
                            -- 2. If Boss Found -> Kill it
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                                EquipWeapon(Options.SelectWeapon.Value)
                                RequestHit()
                            end
                        else
                            -- 3. If Boss Not Found -> Teleport to Summon Spot & Summon
                            TeleportTo(bossConfig.SpawnPosition)
                            
                            -- กดเสก (หน่วงเวลาเพื่อไม่ให้ Spam Remote เร็วเกินไป)
                            local args = { bossConfig.SummonArgs }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer(unpack(args))
                            task.wait(1.5) 
                        end
                    end
                end)
            end
        end
    end)
    
    -- [Group] Auto Skills (ระบบสกิลใหม่)
    Tabs.AutoFarm:AddSection("Auto Skills Config")
    
    -- Dropdown สำหรับเลือกสกิล (Multi Select)
    local SkillDropdown = Tabs.AutoFarm:AddDropdown("SelectSkills", {
        Title = "Select Skills (เลือกสกิล)",
        Values = {"Z", "X", "C", "V", "F"},
        Multi = true,
        Default = {"Z", "X", "C", "V", "F"}, -- เลือกทั้งหมดโดย Default
    })

    -- Toggle สำหรับเปิด/ปิดการใช้สกิล
    local AutoSkillsToggle = Tabs.AutoFarm:AddToggle("AutoUseSkills", {Title = "Auto Use Skills (เปิดใช้สกิล)", Default = false })
     Tabs.AutoFarm:AddButton({
        Title = "Pity Farm Boss Button",
        Callback = function()
            local TargetPlaceId = 77747658251236 

            if game.PlaceId ~= TargetPlaceId then
                warn("Unauthorized Game: Script Execution Terminated.")
                return 
            end

            local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
            local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
            local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
            local HttpService = game:GetService("HttpService")

            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local VirtualUser = game:GetService("VirtualUser")
            local CoreGui = game:GetService("CoreGui")
            local LocalPlayer = Players.LocalPlayer

            local WindowSize = UDim2.fromOffset(580, 460) 
            if UserInputService.TouchEnabled then
                WindowSize = UDim2.fromOffset(480, 320) 
            end

            local WindowTitle = "Sailor piece Pity Boss " .. Fluent.Version

            local Window = Fluent:CreateWindow({
                Title = WindowTitle,
                SubTitle = "By.Lume Dev",
                TabWidth = 160,
                Size = WindowSize,
                Theme = "Rose", 
                MinimizeKey = Enum.KeyCode.RightControl
            })

            -- [Mobile Toggle Button]
            do
                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "MobileToggleGUI"
                ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
                ScreenGui.ResetOnSpawn = false
                ScreenGui.DisplayOrder = 10000 
                
                local ToggleBtn = Instance.new("ImageButton")
                ToggleBtn.Name = "FluentToggle"
                ToggleBtn.Active = true 
                ToggleBtn.Size = UDim2.fromOffset(50, 50)
                ToggleBtn.Position = UDim2.new(0.5, -25, 0, 10)
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                ToggleBtn.BackgroundTransparency = 0.3
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Image = "rbxassetid://3926305904" 
                ToggleBtn.Parent = ScreenGui
                
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = ToggleBtn

                task.spawn(function()
                    local imageLink = "https://img5.pic.in.th/file/secure-sv1/LOGO1f992f72d5a3be82.png"
                    local fileName = "SailorLogo_v3.png"
                    if writefile and getcustomasset and game.HttpGet then
                        local success, result = pcall(function()
                            local content = game:HttpGet(imageLink)
                            writefile(fileName, content)
                            return getcustomasset(fileName)
                        end)
                        if success and result and type(result) == "string" and result ~= "" then
                            ToggleBtn.Image = result
                        end
                    end
                end)
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        if VirtualInputManager then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
                        end
                    end)
                end)
            end

            -- [Tabs]
            local Tabs = {
                Main = Window:AddTab({ Title = "Main", Icon = "user" }),
                AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
                Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
                Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
            }

            local Options = Fluent.Options
            local HakiState = { Active = false }
            local ObsState = { Active = false }

            --------------------------------------------------------------------------------
            -- Configs & Locations
            --------------------------------------------------------------------------------
            local SummonBossConfig = {
                ["SaberBoss"] = { SummonArgs = "SaberBoss", SpawnPosition = CFrame.new(828.11, -0.39, -1130.76) },
                ["QinShiBoss"] = { SummonArgs = "QinShiBoss", SpawnPosition = CFrame.new(828.11, -0.39, -1130.76) }
            }

            local BossLocations = {
                ["JinwooBoss"] = CFrame.new(311.442, 7.593, 946.905),
                ["SukunaBoss"] = CFrame.new(1571.266, 80.220, -34.112),
                ["GojoBoss"] = CFrame.new(1855.566, 8.486, 341.594),
                ["AizenBoss"] = CFrame.new(-567.223, 2.578, 1228.490),
                ["YujiBoss"] = CFrame.new(1537.928, 12.986, 226.108)
            }

            local NPCLocations = {
                ["Dark Blade Quest"] = CFrame.new(-122.211426, 14.817399, -1174.63635),
                ["Haki Trainer"] = CFrame.new(-487.659241, 23.6579151, -1336.01538),
                ["Santa"] = CFrame.new(406.284241, -3.7726171, -1446.953),
                ["RagnaBuyer"] = CFrame.new(92.6486816, -2.46826172, -1460.51953),
                ["RagnaQuestlineBuff"] = CFrame.new(446.879944, 43.6973267, -1923.98523),
                ["SummonBossNPC"] = CFrame.new(692.040527, -3.67419362, -1085.31812),
                ["EnchantNPC"] = CFrame.new(1415.31274, 8.84003067, 7.40811729),
                ["GojoNpc"] = CFrame.new(1741.59265, 157.300507, 514.805054),
                ["SukunaNpc"] = CFrame.new(1325.80103, 162.85965, -34.6844749),
                ["Jinwoo Npc"] = CFrame.new(91.2260056, 2.98423171, 1097.46631),
                ["TitleNpc"] = CFrame.new(369.152405, 2.79983521, 783.487427),
                ["Random Fruit (Gem)"] = CFrame.new(400.641937, 2.79983521, 752.175842),
                ["Random Fruit (Coin)"] = CFrame.new(408.244568, 2.82981968, 802.734131),
                ["StorageNpc"] = CFrame.new(329.949493, 2.94520569, 764.059326),
                ["TraitsNpc"] = CFrame.new(337.284302, 2.79983521, 813.846558),
                ["AizenNpc"] = CFrame.new(-346.134552, 12.9912338, 1402.1001),
                ["AizenQuestBuff"] = CFrame.new(-892.005066, 24.7202606, 1229.99414),
                ["ObservationBuyer"] = CFrame.new(-787.772278, 12.1339779, -540.441956),
                ["ArtifactsUnlocker"] = CFrame.new(-430.236389, 1.77979147, -1179.23547),
                ["YujiBuyerNPC"] = CFrame.new(1240.19263, 136.700775, 408.188354),
                ["RerollStatNPC"] = CFrame.new(373.071747, 2.79983521, 810.098328),
                ["Merchant"] = CFrame.new(368.817719, 2.79983521, 783.589844),
                
            }

            local TeleportLocations = {
                ["SnowIsland"] = CFrame.new(-223.847488, -1.80199099, -1062.93848),
                ["ShibuyaStation"] = CFrame.new(1359.47205, 10.5156441, 249.582214),
                ["SailorIsland"] = CFrame.new(235.137619, 3.10643435, 659.73407),
                ["JungleIsland"] = CFrame.new(-446.587311, -3.56074214, 368.797546),
                ["DesertIsland"] = CFrame.new(-768.975037, -2.13288236, -361.697754),
                ["BossIsland"] = CFrame.new(667.690002, -1.53785121, -1125.21899),
                ["StarterIsland"] = CFrame.new(-94.7449417, -1.98583961, -244.801849),
                ["XmasIsland"] = CFrame.new(282.780884, -2.77514267, -1479.36353),
                ["HuecoMundoIsland"] = CFrame.new(-482.868896, -2.05866098, 936.237061),
                ["DungeonIsland"] = CFrame.new(1298, 4, -841, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            }

            local WeaponGroups = {
                ["Combat"] = {"Combat", "Gojo", "Sukuna", "Qin Shi","Yuji"}, 
                ["Sword"] = {"Katana", "Dark Blade", "Ragna", "Saber", "Jinwoo", "Aizen","Shadow"} 
            }

            --------------------------------------------------------------------------------
            -- Helpers
            --------------------------------------------------------------------------------
            local function getCurrentPity()
                local pityVal = 0
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    local bossUI = playerGui and playerGui:FindFirstChild("BossUI")
                    local mainFrame = bossUI and bossUI:FindFirstChild("MainFrame")
                    local bossHPBar = mainFrame and mainFrame:FindFirstChild("BossHPBar")
                    local pityLabel = bossHPBar and bossHPBar:FindFirstChild("Pity")
                    
                    if pityLabel and pityLabel:IsA("TextLabel") then
                        local text = pityLabel.Text
                        local number = string.match(text, "%d+")
                        if number then
                            pityVal = tonumber(number)
                        end
                    end
                end)
                return pityVal
            end

            local function RequestHit()
                pcall(function()
                    local combatSystem = ReplicatedStorage:FindFirstChild("CombatSystem")
                    if combatSystem then
                        local remote = combatSystem:FindFirstChild("Remotes") and combatSystem.Remotes:FindFirstChild("RequestHit")
                        if remote then remote:FireServer() end
                    end
                end)
            end

            local function EquipWeapon(groupName)
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
                local targetWeapons = WeaponGroups[groupName] or {groupName}
                for _, name in ipairs(targetWeapons) do
                    if LocalPlayer.Character:FindFirstChild(name) then return end 
                end
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, name in ipairs(targetWeapons) do
                        local tool = backpack:FindFirstChild(name)
                        if tool then
                            LocalPlayer.Character.Humanoid:EquipTool(tool)
                            return 
                        end
                    end
                end
            end

            local function TeleportTo(cframe)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
                end
            end

            --------------------------------------------------------------------------------
            -- UI Sections
            --------------------------------------------------------------------------------
            Tabs.Main:AddSection("Player Mods")
            Tabs.Main:AddToggle("SpeedHack", {Title = "Speed Hack", Default = false })
            Tabs.Main:AddToggle("InfJump", {Title = "Infinity Jump", Default = false })
            Tabs.Main:AddToggle("EspPlayer", {Title = "ESP Player", Default = false })

            Tabs.AutoFarm:AddSection("Weapon Settings")
            Tabs.AutoFarm:AddDropdown("SelectWeapon", { Title = "Select Weapon", Values = {"Combat", "Sword"}, Default = 1 })
            Tabs.AutoFarm:AddToggle("AutoEquip", {Title = "Auto Equip", Default = false })

            -- [NEW SECTION] AutoFarm No Quest
            Tabs.AutoFarm:AddSection("Auto Farm No Quest")

            local AutoFarmAllBosses = Tabs.AutoFarm:AddToggle("AutoFarmAllBosses", {Title = "Auto Farm All Boss", Default = false })
            local AutoFarmAllMobs = Tabs.AutoFarm:AddToggle("AutoFarmAllMobs", {Title = "Auto Farm All Mobs", Default = false })

            Tabs.AutoFarm:AddSection("Select Boss")
            local SelectedBosses = {}
            local BossDropdown = Tabs.AutoFarm:AddDropdown("SelectBoss", {
                Title = "Select Boss",
                Values = {"JinwooBoss", "SukunaBoss", "GojoBoss","AizenBoss","YujiBoss"},
                Multi = true,
                Default = {},
            })
            BossDropdown:OnChanged(function(Value)
                SelectedBosses = {}
                for val, state in pairs(Value) do if state then table.insert(SelectedBosses, val) end end
            end)

            Tabs.AutoFarm:AddToggle("AutoFarmBoss", {Title = "Auto Farm Boss", Default = false })

            Tabs.AutoFarm:AddSection("Pity Summon Loop")
            local SummonBossList = {}
            for name, _ in pairs(SummonBossConfig) do table.insert(SummonBossList, name) end
            Tabs.AutoFarm:AddDropdown("SelectSummonBoss", { Title = "Select Summon Boss", Values = SummonBossList, Default = 1 })

            local PityLabel = Tabs.AutoFarm:AddParagraph({ Title = "Pity", Content = "Waiting for data..." })

            Tabs.AutoFarm:AddToggle("AutoFarmSummonBoss", {Title = "Auto Farm Pity", Default = false })

            Tabs.AutoFarm:AddSection("Utility")
            Tabs.AutoFarm:AddToggle("AutoHaki", {Title = "Auto Haki", Default = false })
            Tabs.AutoFarm:AddToggle("AutoObservationHaki", {Title = "Auto Observation Haki", Default = false })
            Tabs.AutoFarm:AddDropdown("SelectSkills", { Title = "Select Skills to Use", Values = {"Z", "X", "C", "V", "F"}, Multi = true, Default = {"Z", "X", "C", "V", "F"} })
            Tabs.AutoFarm:AddToggle("AutoUseSkills", {Title = "Auto Skills", Default = false })

            --------------------------------------------------------------------------------
            -- Teleport Logic UI
            --------------------------------------------------------------------------------
            Tabs.Teleport:AddSection("Islands")
            local IsList = {} for k,_ in pairs(TeleportLocations) do table.insert(IsList, k) end
            Tabs.Teleport:AddDropdown("SelIs", { Title = "Select Island", Values = IsList, Default = 1 })
            Tabs.Teleport:AddButton({ Title = "Teleport to Island", Callback = function() TeleportTo(TeleportLocations[Options.SelIs.Value]) end })

            Tabs.Teleport:AddSection("NPCs")
            local NpcList = {} for k,_ in pairs(NPCLocations) do table.insert(NpcList, k) end
            Tabs.Teleport:AddDropdown("SelNpc", { Title = "Select NPC", Values = NpcList, Default = 1 })
            Tabs.Teleport:AddButton({ Title = "Teleport to NPC", Callback = function() TeleportTo(NPCLocations[Options.SelNpc.Value]) end })

            --------------------------------------------------------------------------------
            -- [Logic] Improved Unified Cycle Loop (Fix Boss Switching)
            --------------------------------------------------------------------------------
            task.spawn(function()
                while true do
                    task.wait()
                    if Options.AutoFarmSummonBoss.Value then
                        local currentPity = getCurrentPity()
                        
                        -- Phase 1: Summon until UI Pity hits 24
                        if currentPity < 24 then
                            PityLabel:SetDesc("Status: Pity Farming (Summoning)\nUI Pity: " .. currentPity .. " / 24")
                            
                            local success, err = pcall(function()
                                local selectedBossKey = Options.SelectSummonBoss.Value
                                local bossConfig = SummonBossConfig[selectedBossKey]
                                local target = nil
                                local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                                
                                for _, loc in pairs(folders) do
                                    if loc and loc:FindFirstChild(selectedBossKey) then
                                        local b = loc[selectedBossKey]
                                        if b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then target = b; break end
                                    end
                                end

                                if target and target:FindFirstChild("HumanoidRootPart") then
                                    while target and target.Parent and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and Options.AutoFarmSummonBoss.Value do
                                        local hrp = target:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            TeleportTo(hrp.CFrame * CFrame.new(0, 0, 4))
                                            EquipWeapon(Options.SelectWeapon.Value)
                                            RequestHit()
                                        end
                                        task.wait()
                                    end
                                    task.wait(1) 
                                else
                                    if bossConfig then
                                        TeleportTo(bossConfig.SpawnPosition)
                                        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RequestSummonBoss")
                                        if remote then remote:FireServer(bossConfig.SummonArgs) end
                                    end
                                    task.wait(2)
                                end
                            end)
                            if not success then warn("Cycle Phase 1 Error: " .. tostring(err)) task.wait(1) end

                        -- Phase 2: Kill ONE Main Boss, then Reset
                        else
                            PityLabel:SetDesc("Status: Pity reached 24! Hunting Targets...\nUI Pity: " .. currentPity)
                            Fluent:Notify({ Title = "Target Mode", Content = "Pity 24 แล้ว! กำลังไปกวาดล้างบอสหลัก 1 ตัว...", Duration = 3 })
                            
                            local bossTable = SelectedBosses or {}
                            local killedABoss = false

                            if #bossTable > 0 then
                                -- สแกนหาบอสจนกว่าจะเจอ 1 ตัว (ใส่ลูปครอบเพื่อให้มั่นใจว่าไม่ข้ามไป Reset ทันที)
                                local huntingTimer = 0
                                while huntingTimer < 15 and not killedABoss and Options.AutoFarmSummonBoss.Value do
                                    for _, bossName in ipairs(bossTable) do
                                        if killedABoss then break end
                                        
                                        PityLabel:SetDesc("Status: Hunting " .. bossName .. " (Waiting/Scanning)\nTime: " .. huntingTimer .. "s")
                                        
                                        local mainTarget = nil
                                        local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                                        
                                        -- 1. เช็คว่ามีตัวอยู่ไหม
                                        for _, loc in pairs(folders) do
                                            if loc and loc:FindFirstChild(bossName) then
                                                local b = loc[bossName]
                                                if b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then mainTarget = b; break end
                                            end
                                        end

                                        -- 2. ถ้าไม่เจอ วาร์ปไปเช็คจุดเกิด (สำคัญมากเผื่อบอสยังไม่โหลด)
                                        if not mainTarget and BossLocations[bossName] then
                                            TeleportTo(BossLocations[bossName])
                                            task.wait(1.5)
                                            for _, loc in pairs(folders) do
                                                if loc and loc:FindFirstChild(bossName) then
                                                    local b = loc[bossName]
                                                    if b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then mainTarget = b; break end
                                                end
                                            end
                                        end

                                        -- 3. ถ้าเจอบอส ให้ตีจนตาย
                                        if mainTarget and mainTarget:FindFirstChild("HumanoidRootPart") then
                                            PityLabel:SetDesc("Status: Killing " .. bossName .. " (Target Found!)")
                                            while mainTarget and mainTarget.Parent and mainTarget:FindFirstChild("Humanoid") and mainTarget.Humanoid.Health > 0 and Options.AutoFarmSummonBoss.Value do
                                                local hrp = mainTarget:FindFirstChild("HumanoidRootPart")
                                                if hrp then
                                                    TeleportTo(hrp.CFrame * CFrame.new(0, 0, 4))
                                                    EquipWeapon(Options.SelectWeapon.Value)
                                                    RequestHit()
                                                end
                                                task.wait()
                                            end
                                            killedABoss = true 
                                            task.wait(1.5)
                                        end
                                    end
                                    
                                    if not killedABoss then
                                        task.wait(1)
                                        huntingTimer = huntingTimer + 1
                                    end
                                end
                            else
                                PityLabel:SetDesc("Error: No Targets Selected! Please select bosses in Target Setting.")
                                task.wait(2)
                            end

                            -- [Phase 2.5] Reset Phase: Kill the Summon Boss (ตัวที่ 25) เพื่อรีเซ็ตวงจรกลับเป็น 0
                            PityLabel:SetDesc("Status: Resetting Cycle (Killing 25th Boss to 0)")
                            Fluent:Notify({ Title = "Reset Phase", Content = "ภารกิจบอสหลักเสร็จสิ้น! กำลังรีเซ็ต Pity กลับเป็น 0...", Duration = 3 })
                            
                            local resetDone = false
                            while not resetDone and Options.AutoFarmSummonBoss.Value do
                                local selectedBossKey = Options.SelectSummonBoss.Value
                                local bossConfig = SummonBossConfig[selectedBossKey]
                                local target = nil
                                local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                                
                                for _, loc in pairs(folders) do
                                    if loc and loc:FindFirstChild(selectedBossKey) then
                                        local b = loc[selectedBossKey]
                                        if b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then target = b; break end
                                    end
                                end

                                if target and target:FindFirstChild("HumanoidRootPart") then
                                    while target and target.Parent and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and Options.AutoFarmSummonBoss.Value do
                                        local hrp = target:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            TeleportTo(hrp.CFrame * CFrame.new(0, 0, 4))
                                            EquipWeapon(Options.SelectWeapon.Value)
                                            RequestHit()
                                        end
                                        task.wait()
                                    end
                                    task.wait(2.5) -- รอ UI Game Reset จริงๆ
                                    if getCurrentPity() < 24 then
                                        resetDone = true
                                    end
                                else
                                    if bossConfig then
                                        TeleportTo(bossConfig.SpawnPosition)
                                        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RequestSummonBoss")
                                        if remote then remote:FireServer(bossConfig.SummonArgs) end
                                    end
                                    task.wait(2)
                                end
                            end

                            Fluent:Notify({ Title = "Cycle Restart", Content = "Pity รีเซ็ตแล้ว! เริ่มฟาร์มรอบใหม่...", Duration = 3 })
                            task.wait(1)
                        end
                    end
                end
            end)

            -- Stand-alone Loop
            task.spawn(function()
                while true do
                    task.wait()
                    if Options.AutoFarmBoss.Value then
                        local bossTable = SelectedBosses or {}
                        for _, bossName in ipairs(bossTable) do
                            if not Options.AutoFarmBoss.Value then break end
                            local target = nil
                            local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                            for _, loc in pairs(folders) do
                                if loc and loc:FindFirstChild(bossName) then
                                    local b = loc[bossName]
                                    if b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then target = b; break end
                                end
                            end
                            if target and target:FindFirstChild("HumanoidRootPart") then
                                while target and target.Parent and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and Options.AutoFarmBoss.Value do
                                    local hrp = target:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        TeleportTo(hrp.CFrame * CFrame.new(0, 0, 4))
                                        EquipWeapon(Options.SelectWeapon.Value)
                                        RequestHit()
                                    end
                                    task.wait()
                                end
                            else
                                if BossLocations[bossName] then TeleportTo(BossLocations[bossName]) end
                                task.wait(2)
                            end
                        end
                    end
                end
            end)

            --------------------------------------------------------------------------------
            -- Logic: Auto Farm No Quest (Priority: Boss > Mobs)
            --------------------------------------------------------------------------------
            task.spawn(function()
                local AllBossNames = {
                    "JinwooBoss", "SukunaBoss", "GojoBoss", "AizenBoss", "YujiBoss",
                }

                local function IsBoss(name)
                    for _, boss in ipairs(AllBossNames) do
                        if string.find(name, boss) then return true end
                    end
                    if string.find(name:lower(), "boss") then return true end
                    return false
                end

                while true do
                    task.wait()
                    
                    local target = nil
                    local hitBoss = false
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if myRoot then
                        local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                        
                        -- Priority 1: Check for Bosses if Toggle is ON
                        if Options.AutoFarmAllBosses.Value then
                            for _, loc in pairs(folders) do
                                if loc then
                                    for _, v in pairs(loc:GetChildren()) do
                                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                            if IsBoss(v.Name) then
                                                target = v
                                                hitBoss = true
                                                break
                                            end
                                        end
                                    end
                                end
                                if target then break end
                            end
                        end

                        -- Priority 2: If no boss found (or boss toggle off), check for Mobs if Mob Toggle is ON
                        if not target and Options.AutoFarmAllMobs.Value then
                            local closestDist = math.huge
                            for _, loc in pairs(folders) do
                                if loc then
                                    for _, v in pairs(loc:GetChildren()) do
                                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                            -- Filter out players
                                            if not Players:GetPlayerFromCharacter(v) then
                                                -- Should we skip bosses here? Ideally yes, to let Priority 1 handle bosses
                                                -- But if Boss Toggle is OFF, maybe we want to hit bosses as mobs?
                                                -- Let's stick to strict priority: This phase targets anything that is alive.
                                                local d = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                                if d < closestDist then
                                                    closestDist = d
                                                    target = v
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        -- Execution
                        if target then
                            local hrp = target:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local tPos = hrp.CFrame * CFrame.new(0, 0, 4)
                                TeleportTo(CFrame.lookAt(tPos.Position, hrp.Position))
                                EquipWeapon(Options.SelectWeapon.Value)
                                RequestHit()
                            end
                        end
                    end
                end
            end)

            SaveManager:LoadAutoloadConfig()
            Fluent:Notify({ Title = "By.Lume.Dev Loaded", Content = "[🌑Eminence Update👑] Sailor Piece Script Loaded!", Duration = 5 })

        end -- ปิด Callback function
    }) -- ปิด AddButton
end -- ปิด do block ของ Auto Farm

-- Stand-alone Loop
task.spawn(function()
    while true do
        task.wait()
        if Options.AutoFarmBoss.Value then
            local bossTable = SelectedBosses or {}
            for _, bossName in ipairs(bossTable) do
                if not Options.AutoFarmBoss.Value then break end
                local target = nil
                local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                for _, loc in pairs(folders) do
                    if loc and loc:FindFirstChild(bossName) then
                        local b = loc[bossName]
                        if b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then target = b; break end
                    end
                end
                if target and target:FindFirstChild("HumanoidRootPart") then
                    while target and target.Parent and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and Options.AutoFarmBoss.Value do
                        local hrp = target:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            TeleportTo(hrp.CFrame * CFrame.new(0, 0, 4))
                            EquipWeapon(Options.SelectWeapon.Value)
                            RequestHit()
                        end
                        task.wait()
                    end
                else
                    if BossLocations[bossName] then TeleportTo(BossLocations[bossName]) end
                    task.wait(2)
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- Logic: Auto Farm No Quest (Priority: Boss > Mobs)
--------------------------------------------------------------------------------
task.spawn(function()
    local AllBossNames = {
        "JinwooBoss", "SukunaBoss", "GojoBoss", "AizenBoss", "YujiBoss", 
    }

    local function IsBoss(name)
        for _, boss in ipairs(AllBossNames) do
            if string.find(name, boss) then return true end
        end
        if string.find(name:lower(), "boss") then return true end
        return false
    end

    while true do
        task.wait()
        
        local target = nil
        local hitBoss = false
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if myRoot then
            local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
            
            -- Priority 1: Check for Bosses if Toggle is ON
            if Options.AutoFarmAllBosses.Value then
                for _, loc in pairs(folders) do
                    if loc then
                        for _, v in pairs(loc:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                if IsBoss(v.Name) then
                                    target = v
                                    hitBoss = true
                                    break
                                end
                            end
                        end
                    end
                    if target then break end
                end
            end

            -- Priority 2: If no boss found (or boss toggle off), check for Mobs if Mob Toggle is ON
            if not target and Options.AutoFarmAllMobs.Value then
                local closestDist = math.huge
                for _, loc in pairs(folders) do
                    if loc then
                        for _, v in pairs(loc:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                -- Filter out players
                                if not Players:GetPlayerFromCharacter(v) then
                                    -- Should we skip bosses here? Ideally yes, to let Priority 1 handle bosses
                                    -- But if Boss Toggle is OFF, maybe we want to hit bosses as mobs?
                                    -- Let's stick to strict priority: This phase targets anything that is alive.
                                    local d = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                    if d < closestDist then
                                        closestDist = d
                                        target = v
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Execution
            if target then
                local hrp = target:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local tPos = hrp.CFrame * CFrame.new(0, 0, 4)
                    TeleportTo(CFrame.lookAt(tPos.Position, hrp.Position))
                    EquipWeapon(Options.SelectWeapon.Value)
                    RequestHit()
                end
            end
        end
    end
end)

do
    -- >> Tab: Dungeon << (SEPARATE CATEGORY)

    -- Config Position Jigsaw
    local JigsawLocations = {
        ["Jigsaw #1"] = CFrame.new(89.9129028, 8.48682785, -136.653168, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376),
        ["Jigsaw #2"] = CFrame.new(-396.155457, -0.644790649, 510.067932, 0.369634688, 0.120474108, -0.921333969, -0.264767796, 0.96410799, 0.0198437124, 0.890656054, 0.236604616, 0.388265431),
        ["Jigsaw #3"] = CFrame.new(-1130.33484, 5.37958527, -319.808472, -0.0325621367, -0.207822829, 0.977624476, 0.0831362903, 0.974190116, 0.209861815, -0.996006191, 0.0881095827, -0.0144441128),
        ["Jigsaw #4"] = CFrame.new(-303.355286, -2.38616896, -1271.50928, 0.92051065, 0, 0.390717506, 0, 1, 0, -0.390717506, 0, 0.92051065),
        ["Jigsaw #5"] = CFrame.new(1717.1012, 138.38591, -27.2578392, 0.989420116, 0.00180168322, -0.145067453, -0.00181423908, 0.999998331, 4.57420974e-05, 0.145067304, 0.000217928886, 0.989421785),
        ["Jigsaw #6"] = CFrame.new(-685.611206, 98.1761932, 1335.40051, 0.325435102, 0.00925869402, -0.945519149, -0.0284054689, 0.999596477, 1.14431605e-05, 0.94513768, 0.0268541873, 0.325566828)
    }

    Tabs.Dungeon:AddSection("Dungeon Portal")

    local SelectedDungeon = "CidDungeon"
    local DungeonDropdown = Tabs.Dungeon:AddDropdown("SelectDungeon", {
        Title = "Select Dungeon (เลือกดันเจี้ยน)",
        Values = {"CidDungeon", "RuneDungeon"},
        Multi = false,
        Default = 1,
    })
    DungeonDropdown:OnChanged(function(Value) SelectedDungeon = Value end)

    local JoinDungeonToggle = Tabs.Dungeon:AddToggle("AutoJoinDungeon", {Title = "Auto Join Dungeon", Default = false })
    local JoinTeamToggle = Tabs.Dungeon:AddToggle("AutoJoinTeam", {Title = "Auto Join Team (เข้าทีมอัตโนมัติ)", Default = false })

    Tabs.Dungeon:AddSection("Dungeon Options")
    local AutoRetryToggle = Tabs.Dungeon:AddToggle("AutoRetryDungeon", {Title = "Auto Retry", Default = false })

    Tabs.Dungeon:AddSection("Dungeon Wave Vote")

    local SelectedDifficulty = "Extreme"
    local DifficultyDropdown = Tabs.Dungeon:AddDropdown("SelectDifficulty", {
        Title = "Select Difficulty",
        Values = {"Extreme", "Easy", "Medium", "Hard"},
        Multi = false,
        Default = 1,
    })
    DifficultyDropdown:OnChanged(function(Value) SelectedDifficulty = Value end)

    local AutoVoteDifficultyToggle = Tabs.Dungeon:AddToggle("AutoVoteDifficulty", {Title = "Auto Vote Difficulty", Default = false })
    local StartKillToggle = Tabs.Dungeon:AddToggle("StartKillDungeon", {Title = "Start Kill", Default = false })

    Tabs.Dungeon:AddSection("Jigsaw Teleport")
    local SelectedJigsaw = "Jigsaw #1"
    local JigsawDropdown = Tabs.Dungeon:AddDropdown("SelectJigsaw", {
        Title = "Select Jigsaw",
        Values = {"Jigsaw #1", "Jigsaw #2", "Jigsaw #3", "Jigsaw #4", "Jigsaw #5", "Jigsaw #6"},
        Multi = false,
        Default = 1,
    })
    JigsawDropdown:OnChanged(function(Value) SelectedJigsaw = Value end)

    Tabs.Dungeon:AddButton({
        Title = "Teleport to Jigsaw",
        Callback = function()
            if JigsawLocations[SelectedJigsaw] then
                TeleportTo(JigsawLocations[SelectedJigsaw])
            end
        end
    })

    -- Dungeon Logic Loops
    task.spawn(function() -- Auto Join Loop
        while true do
            task.wait(2)
            if Options.AutoJoinDungeon.Value then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestDungeonPortal"):FireServer(SelectedDungeon)
                end)
            end
        end
    end)

    task.spawn(function() -- Auto Join Team Loop
        local teamCFrame = CFrame.new(1434.00439, 4.45256138, -932.597717, -0.406715393, 0, 0.913554907, 0, 1, 0, -0.913554907, 0, -0.406715393)
        while true do
            task.wait(0.5)
            if Options.AutoJoinTeam and Options.AutoJoinTeam.Value then
                pcall(function()
                    TeleportTo(teamCFrame)
                    -- Simulate holding E
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                end)
            end
        end
    end)

    task.spawn(function() -- Auto Retry Loop
        while true do
            task.wait(2)
            if Options.AutoRetryDungeon and Options.AutoRetryDungeon.Value then
                pcall(function()
                    local args = { "sponsor" }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveReplayVote"):FireServer(unpack(args))
                end)
            end
        end
    end)

    task.spawn(function() -- Auto Vote Loop
        while true do
            task.wait(1)
            if Options.AutoVoteDifficulty.Value then
                pcall(function()
                    local args = { SelectedDifficulty }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveVote"):FireServer(unpack(args))
                end)
            end
        end
    end)

    -- Auto Kill Dungeon NPCs & Boss Logic
    task.spawn(function()
        while true do
            task.wait()
            if Options.StartKillDungeon and Options.StartKillDungeon.Value then
                pcall(function()
                    local target = nil
                    local minDst = math.huge
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not myRoot then return end

                    -- รายชื่อเป้าหมาย
                    local targetNames = {"DungeonNPC", "ShadowBoss"}
                    
                    -- ค้นหาในตำแหน่งที่เป็นไปได้ทั้งหมด
                    local folders = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                    
                    for _, loc in pairs(folders) do
                        if loc then
                            for _, v in pairs(loc:GetChildren()) do
                                local isTarget = false
                                -- ตรวจสอบว่าชื่อตรงกับเป้าหมายหรือไม่ (ใช้ exact name หรือ pattern)
                                for _, name in ipairs(targetNames) do
                                    if v.Name == name or string.find(v.Name, name) then
                                        isTarget = true
                                        break
                                    end
                                end

                                if isTarget and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                    local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                    if dst < minDst then
                                        minDst = dst
                                        target = v
                                    end
                                end
                            end
                        end
                    end

                    if target then
                        -- โจมตี
                        local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                        TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                        EquipWeapon(Options.SelectWeapon.Value)
                        RequestHit()
                    end
                end)
            end
        end
    end)
end

do
    -- >> Tab: Stats <<
    
    Tabs.Stats:AddSection("Stats Upgrade")
    
    Tabs.Stats:AddToggle("AutoMelee", {Title = "Auto Melee", Default = false })
    Tabs.Stats:AddToggle("AutoDefense", {Title = "Auto Defense", Default = false })
    Tabs.Stats:AddToggle("AutoSword", {Title = "Auto Sword", Default = false })
    Tabs.Stats:AddToggle("AutoPower", {Title = "Auto Power (Fruit)", Default = false })

    Tabs.Stats:AddSection("Stats Manage")

    Tabs.Stats:AddButton({
        Title = "Reset Stats (รีเซ็ตค่าพลัง)",
        Description = "คืนค่า Stat ทั้งหมด",
        Callback = function()
            ResetStats()
            Fluent:Notify({ Title = "Success", Content = "Stats have been reset.", Duration = 3 })
        end
    })
end

do
    -- >> Tab: Teleport <<
    
    -- [Group] Island
    Tabs.Teleport:AddSection("Teleport to Island")
    
    local selectedLocation = "SnowIsland"
    local TeleportDropdown = Tabs.Teleport:AddDropdown("SelectIsland", {
        Title = "Select Island",
        Values = { "SnowIsland", "ShibuyaStation", "SailorIsland", "JungleIsland", "DesertIsland", "BossIsland", "XmasIsland","StarterIsland" , "HuecoMundoIsland","DungeonIsland" },
        Multi = false,
        Default = 1,
    })
    TeleportDropdown:OnChanged(function(Value) selectedLocation = Value end)
    Tabs.Teleport:AddButton({
        Title = "Teleport Island",
        Description = "วาร์ปไปยังเกาะที่เลือก",
        Callback = function()
            if TeleportLocations[selectedLocation] then TeleportTo(TeleportLocations[selectedLocation]) end
        end
    })

    -- [Group] NPC
    Tabs.Teleport:AddSection("Teleport to NPC")
    
    local selectedNPC = "Dark Blade Quest"
    local NPCDropdown = Tabs.Teleport:AddDropdown("SelectNPC", {
        Title = "Select Npc",
        Values = { "Dark Blade Quest", "Haki Trainer", "Santa", "RagnaBuyer", "RagnaQuestlineBuff", "SummonBossNPC", "EnchantNPC", "GojoNpc", "SukunaNpc", "Jinwoo Npc", "TitleNpc", "Random Fruit (Gem)", "Random Fruit (Coin)", "StorageNpc", "TraitsNpc","AizenNpc","AizenQuestBuff","ObservationBuyer","ArtifactsUnlocker","YujiBuyerNPC" ,"RerollStatNPC" ,"Merchant","CidBuyer"},
        Multi = false,
        Default = 1,
    })
    
    NPCDropdown:OnChanged(function(Value)
        selectedNPC = Value
    end)
    Tabs.Teleport:AddButton({
        Title = "Teleport NPC",
        Description = "วาร์ปไปหา NPC ที่เลือก",
        Callback = function()
            if NPCLocations[selectedNPC] then TeleportTo(NPCLocations[selectedNPC]) end
        end
    })
end

do
    -- >> Tab: Misc <<
    Tabs.Misc:AddSection("Open Gui")

    local GuiMap = {
        ["Artifacts UI"] = {GuiName = "ArtifactsUI", FrameName = "ArtifactsMainFrame"},
        ["TraitReroll UI"] = {GuiName = "TraitRerollUI", FrameName = "MainFrame"},
        ["Enchant UI"] = {GuiName = "EnchantUI", FrameName = "MainFrame"},
        ["Exchange UI"] = {GuiName = "ExchangeUI", FrameName = "MainFrame"},
        ["Merchant UI"] = {GuiName = "MerchantUI", FrameName = "MainFrame"},
        ["RerollStats UI"] = {GuiName = "RerollStatsUI", FrameName = "MainFrame"},
        ["Storage UI"] = {GuiName = "StorageUI", FrameName = "MainFrame"},
        ["RerollStats UI"] = {GuiName = "RerollStatsUI", FrameName = "MainFrame"},
        ["Teleport UI"] = {GuiName = "TeleportUI", FrameName = "MainFrame"},
        ["Titles UI"] = {GuiName = "TitlesUI", FrameName = "MainFrame"},
        ["DungeonTeleport UI"] = {GuiName = "DungeonTeleportUI", FrameName = "MainFrame"},
        
        -- Can add more later if known, e.g., "Saber UI", etc.
    }
    
    local GuiKeys = {"None"}
    for k, v in pairs(GuiMap) do table.insert(GuiKeys, k) end

    local GuiDropdown = Tabs.Misc:AddDropdown("MiscGuiOpener", {
        Title = "Open GUI (เปิดหน้าต่างเกม)",
        Values = GuiKeys,
        Multi = false,
        Default = 1,
    })

    GuiDropdown:OnChanged(function(Value)
        -- 1. Reset/Close all managed GUIs to prevent overlap or ensure clean state
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui then
            for _, info in pairs(GuiMap) do
                local gui = PlayerGui:FindFirstChild(info.GuiName)
                if gui then
                    local frame = gui:FindFirstChild(info.FrameName)
                    if frame then
                        frame.Visible = false
                    end
                end
            end
        end

        -- 2. Open Selected
        if Value ~= "None" and PlayerGui then
            local info = GuiMap[Value]
            if info then
                local gui = PlayerGui:FindFirstChild(info.GuiName)
                if gui then
                    local frame = gui:FindFirstChild(info.FrameName)
                    if frame then
                        frame.Visible = true
                        Fluent:Notify({Title = "GUI Manager", Content = "Opened: " .. Value, Duration = 2})
                    end
                end
            end
        end
    end)
end

do
    -- >> Tab: Settings <<
    
    -- [Group] Webhook
    Tabs.Settings:AddSection("Webhook Settings")

    -- ประกาศฟังก์ชัน SendWebhook ไว้ตรงนี้เพื่อให้มั่นใจว่าเรียกใช้ได้แน่นอน
    local function SendWebhook(url, embedData)
        local success, body = pcall(function()
            local HttpService = game:GetService("HttpService")
            return HttpService:JSONEncode({["embeds"] = {embedData}})
        end)
        
        if not success or not url or url == "" then return end
        
        local headers = {["Content-Type"] = "application/json"}
        
        if request then
            request({Url = url, Method = "POST", Headers = headers, Body = body})
        elseif http_request then
            http_request({Url = url, Method = "POST", Headers = headers, Body = body})
        elseif syn and syn.request then
            syn.request({Url = url, Method = "POST", Headers = headers, Body = body})
        end
    end

    -- ฟังก์ชันจัดรูปแบบตัวเลข (ใส่ลูกน้ำ)
    local function formatNumber(n)
        return tostring(n):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    end

    local WebhookURL = ""
    local WebhookInput = Tabs.Settings:AddInput("WebhookURL", {
        Title = "Webhook URL",
        Default = "",
        Placeholder = "https://discord.com/api/webhooks/...",
        Numeric = false,
        Finished = true,
        Callback = function(Value)
            WebhookURL = Value
        end
    })

    local WebhookToggle = Tabs.Settings:AddToggle("EnableWebhook", {Title = "Enable Webhook Notification", Default = false })
    
    Tabs.Settings:AddButton({
        Title = "Test Webhook",
        Description = "ส่งข้อความทดสอบเพื่อเช็คว่า Webhook ทำงานหรือไม่",
        Callback = function()
            if WebhookURL == "" then
                Fluent:Notify({ Title = "Error", Content = "Please enter a Webhook URL first!", Duration = 3 })
                return
            end
            
            local embed = {
                ["title"] = "🎮 [🌑Eminence Update👑]Sailor Piece Script Script - By.Mamypoko",
                ["description"] = "✅ Webhook is working correctly!\n\n**User:** ||" .. LocalPlayer.Name .. "||\n**ID:** " .. LocalPlayer.UserId,
                ["color"] = 65280,
                ["thumbnail"] = {
                    ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
                },
                ["footer"] = { ["text"] = "[🌑Eminence Update👑]Sailor Piece Script Script - By.Mamypoko • " .. os.date("%H:%M:%S") },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
            
            -- เรียกใช้ผ่าน pcall เพื่อไม่ให้ UI ค้างถ้าเน็ตมีปัญหา
            task.spawn(function()
                SendWebhook(WebhookURL, embed)
            end)
            
            Fluent:Notify({ Title = "Sent", Content = "Test message sent! Check Discord.", Duration = 3 })
        end
    })
    
    -- Helper to get stats safely from Data folder
    local function getStat(name)
        local player = Players.LocalPlayer
        if not player then return 0 end

        -- ลองหาใน Data folder ก่อน (ตามที่คุณแจ้ง)
        local dataFolder = player:FindFirstChild("Data")
        if dataFolder then
            local valueObj = dataFolder:FindFirstChild(name)
            if valueObj then
                return valueObj.Value
            end
        end

        -- ถ้าไม่เจอ ลองหาใน leaderstats เผื่อไว้
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local valueObj = leaderstats:FindFirstChild(name)
            if valueObj then
                return valueObj.Value
            end
        end
        
        return 0
    end

    -- Variables for Webhook tracking
    local LastLevel = -1
    local LastMoney = -1
    local LastGems = -1
    local LastItems = {}
    
    -- Webhook Loop
    task.spawn(function()
        while true do
            task.wait(10) -- ปรับเป็นเช็คทุกๆ 10 วินาที เพื่อไม่ให้ Spam เกินไป
            if Options.EnableWebhook.Value and WebhookURL ~= "" then
                local success, err = pcall(function()
                    local currentLevel = getStat("Level")
                    local currentMoney = getStat("Money") 
                    local currentGems = getStat("Gems")
                    
                    -- Initialize if first run (ตั้งค่าเริ่มต้น)
                    if LastLevel == -1 then
                        LastLevel = currentLevel
                        LastMoney = currentMoney
                        LastGems = currentGems
                        
                        -- จดจำไอเท็มที่มีอยู่แล้ว
                        if LocalPlayer:FindFirstChild("Backpack") then
                            for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                                LastItems[item.Name] = true
                            end
                        end
                        if LocalPlayer.Character then
                            for _, item in pairs(LocalPlayer.Character:GetChildren()) do
                                if item:IsA("Tool") then
                                    LastItems[item.Name] = true
                                end
                            end
                        end
                        return -- จบการทำงานรอบแรก
                    end

                    -- คำนวณส่วนต่าง
                    local gainedLevel = currentLevel - LastLevel
                    local gainedMoney = currentMoney - LastMoney
                    local gainedGems = currentGems - LastGems
                    
                    -- เช็คไอเท็มใหม่
                    local newItemsFound = {}
                    
                    local function checkItem(item)
                        if not LastItems[item.Name] then
                            table.insert(newItemsFound, item.Name)
                            LastItems[item.Name] = true
                        end
                    end

                    if LocalPlayer:FindFirstChild("Backpack") then
                        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                            checkItem(item)
                        end
                    end
                    if LocalPlayer.Character then
                        for _, item in pairs(LocalPlayer.Character:GetChildren()) do
                            if item:IsA("Tool") then
                                checkItem(item)
                            end
                        end
                    end

                    -- ส่ง Webhook ถ้ามีค่าเพิ่มขึ้น หรือมีของใหม่
                    if gainedLevel > 0 or gainedMoney > 0 or gainedGems > 0 or #newItemsFound > 0 then
                        local fields = {}
                        
                        -- Status Field (รวม Level, Money, Gems ปัจจุบัน)
                        local statusValue = string.format(
                            "👤 **Level:** %s\n💰 **Money:** %s\n💎 **Gems:** %s",
                            formatNumber(currentLevel),
                            formatNumber(currentMoney),
                            formatNumber(currentGems)
                        )
                        table.insert(fields, { name = "📊 Current Status", value = statusValue, inline = false })
                        
                        -- Gains Field (สิ่งที่ได้เพิ่ม)
                        local gainsText = ""
                        if gainedLevel > 0 then gainsText = gainsText .. "🆙 + " .. formatNumber(getStat("Level") - LastLevel) .. " Levels\n" end
                        if gainedMoney > 0 then gainsText = gainsText .. "💰 + " .. formatNumber(getStat("Money") - LastMoney) .. " Money\n" end
                        if gainedGems > 0 then gainsText = gainsText .. "💎 + " .. formatNumber(getStat("Gems") - LastGems) .. " Gems\n" end
                        
                        if gainsText ~= "" then
                            table.insert(fields, { name = "📈 Gained", value = gainsText, inline = false })
                        end

                        -- New Items Field
                        if #newItemsFound > 0 then
                            local itemsText = ""
                            for _, name in ipairs(newItemsFound) do
                                itemsText = itemsText .. "• " .. name .. "\n"
                            end
                            table.insert(fields, { name = "🎒 New Items", value = itemsText, inline = false })
                        end

                        local embed = {
                            ["title"] = "🌊 [🌑Eminence Update👑]Sailor Piece Script - By.Mamypoko",
                            ["url"] = "https://www.roblox.com/games/17450164673/Sailor-Piece", -- ตัวอย่างลิงก์เกม
                            ["color"] = 65280, -- Green
                            ["thumbnail"] = {
                                ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
                            },
                            ["fields"] = fields,
                            ["footer"] = { 
                                ["text"] = "[🌑Eminence Update👑]Sailor Piece Script Script - By.Mamypoko • " .. os.date("%H:%M:%S"),
                                ["icon_url"] = "https://cdn.discordapp.com/embed/avatars/0.png"
                            },
                            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
                        }
                        
                        SendWebhook(WebhookURL, embed)
                        
                        -- อัปเดตค่าล่าสุด
                        LastLevel = currentLevel
                        LastMoney = currentMoney
                        LastGems = currentGems
                    end
                    
                    -- Sync ค่าล่าสุดเสมอ (กันกรณีใช้เงินแล้วค่าลดลง)
                    if currentMoney < LastMoney then LastMoney = currentMoney end
                    if currentGems < LastGems then LastGems = currentGems end
                end)

                if not success then
                    warn("[Webhook Error]: " .. tostring(err))
                end
            end
        end
    end)
    
    -- [Group] Server Management (เพิ่มใหม่ตามคำขอ)
    Tabs.Settings:AddSection("Server Management")

    local VIPLinkInput = Tabs.Settings:AddInput("VIPServerLink", {
        Title = "VIP Server Link (ลิงก์ห้องส่วนตัว)",
        Default = "",
        Placeholder = "วางลิงก์ที่นี่...",
        Numeric = false,
        Finished = false,
        Callback = function() end
    })

    Tabs.Settings:AddButton({
        Title = "Join VIP Server (จอยห้องส่วนตัว)",
        Description = "เชื่อมต่อเข้าสู่เซิร์ฟเวอร์ตามลิงก์ที่กรอกไว้",
        Callback = function()
            JoinByLink(Options.VIPServerLink.Value)
        end
    })

    Tabs.Settings:AddButton({
        Title = "Server Hop (ย้ายเซิร์ฟเวอร์)",
        Description = "ย้ายไปเล่นที่ห้องอื่นแบบสุ่ม",
        Callback = function()
            ServerHop()
        end
    })

    Tabs.Settings:AddButton({
        Title = "Rejoin Server (เข้าห้องเดิมใหม่)",
        Description = "เชื่อมต่อกลับเข้าเซิร์ฟเวอร์เดิมนี้อีกครั้ง",
        Callback = function()
            RejoinServer()
        end
    })

    -- [Group] Miscellaneous (Anti AFK)
    Tabs.Settings:AddSection("Miscellaneous")
    
    local AntiAFKToggle = Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti AFK", Default = true })
    
    AntiAFKToggle:OnChanged(function()
        if Options.AntiAFK.Value then
            Fluent:Notify({Title = "Anti AFK", Content = "Enabled", Duration = 2})
        else
            Fluent:Notify({Title = "Anti AFK", Content = "Disabled", Duration = 2})
        end
    end)
    
    -- Anti AFK Logic
    LocalPlayer.Idled:Connect(function()
        if Options.AntiAFK.Value then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

--------------------------------------------------------------------------------
-- Logic Loop (อยู่ท้ายสุด เพื่อไม่ให้ Webhook ขวางการทำงานของส่วนอื่น)
--------------------------------------------------------------------------------

-- [NEW] Setup Listeners for Accurate Status Tracking
-- Function to start listening to Remotes
local function SetupHakiListeners()
    local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
    if not Remotes then return end

    local HakiRemote = Remotes:WaitForChild("HakiRemote", 5)
    local ObsRemote = Remotes:WaitForChild("ObservationHakiRemote", 5)

    -- Listen for Buso Haki Updates
    if HakiRemote then
        HakiRemote.OnClientEvent:Connect(function(action, data)
            if action == "Status" and type(data) == "table" then
                HakiState.Active = data.isActive or false
            end
        end)
    end

    -- Listen for Observation Haki Updates
    if ObsRemote then
        ObsRemote.OnClientEvent:Connect(function(action, data)
            if action == "Activated" then
                ObsState.Active = true
            elseif action == "Deactivated" then
                ObsState.Active = false
            elseif action == "Status" and type(data) == "table" then
                ObsState.Active = data.isActive or false
            end
        end)
    end
end

-- Call Setup immediately
task.spawn(SetupHakiListeners)

-- System: Auto Open Chests (Added Logic)
task.spawn(function()
    local chests = {"Common Chest", "Rare Chest", "Epic Chest", "Mythical Chest"}
    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UseItem")
    while true do
        task.wait(1)
        if Options.AutoOpenChests.Value then
            pcall(function()
                for _, chestName in pairs(chests) do
                    -- Fire the remote directly as requested
                    remote:FireServer("Use", chestName, 1)
                end
            end)
        end
    end
end)

-- System: Auto All Skills Loop (New Logic with Dropdown)
task.spawn(function()
    while true do
        task.wait(0.5) -- ความเร็วในการกดสกิล
        if Options.AutoUseSkills.Value then
            pcall(function()
                local selectedSkills = Options.SelectSkills.Value
                
                -- ตรวจสอบและกดสกิลตามลำดับ
                local skillOrder = {"Z", "X", "C", "V"}
                
                for _, key in ipairs(skillOrder) do
                    -- ใน Fluent Multi Dropdown, Value จะเป็น Table { ["Z"] = true, ["X"] = false }
                    if selectedSkills[key] then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                        task.wait(0.1) -- เว้นระยะสักนิดระหว่างสกิล
                    end
                end
            end)
        end
    end
end)

-- System: Auto Equip Loop
task.spawn(function()
    while true do
        task.wait()
        if Options.AutoEquip.Value then
            pcall(function() EquipWeapon(Options.SelectWeapon.Value) end)
        end
    end
end)

-- System: Speed Hack Loop
task.spawn(function()
    while true do
        task.wait()
        if Options.SpeedHack.Value then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 130
            end
        end
    end
end)

-- System: Infinity Jump
UserInputService.JumpRequest:Connect(function()
    if Options.InfJump.Value then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end
end)

-- System: ESP Loop (แก้ไขใหม่)
task.spawn(function()
    while true do
        task.wait(0.1) -- อัปเดตไวขึ้นเพื่อความลื่นไหล
        UpdateESP()
    end
end)

-- System: Target Finder
local function GetTargetMonster()
    local closestTarget = nil
    local shortestDistance = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not myRoot then return nil end

    local targetMobsList = FarmModes[CurrentMode].Mobs
    
    -- Search in all likely locations
    local searchLocations = {Workspace}
    if Workspace:FindFirstChild("Enemies") then table.insert(searchLocations, Workspace.Enemies) end
    if Workspace:FindFirstChild("Mobs") then table.insert(searchLocations, Workspace.Mobs) end
    if Workspace:FindFirstChild("NPCs") then table.insert(searchLocations, Workspace.NPCs) end
    if Workspace:FindFirstChild("Npcs") then table.insert(searchLocations, Workspace.Npcs) end -- Added specific check for mixed case

    for _, location in pairs(searchLocations) do
        for _, child in pairs(location:GetChildren()) do
            -- Smart Match Logic:
            -- ค้นหาชื่อมอนสเตอร์ที่มีคำที่กำหนด แต่กรองเอา "Boss" ออกถ้าเราไม่ได้เลือกฟาร์มบอส
            local isTarget = false
            for _, name in pairs(targetMobsList) do
                if string.find(child.Name, name) then 
                    -- ถ้าชื่อเป้าหมายไม่มีคำว่า "Boss" แต่ตัวที่เจอดันมีคำว่า "Boss" ให้ข้ามไป
                    if not string.find(name:lower(), "boss") and string.find(child.Name:lower(), "boss") then
                        isTarget = false
                    else
                        isTarget = true
                        break
                    end
                end
            end

            if isTarget then
                local humanoid = child:FindFirstChild("Humanoid")
                local root = child:FindFirstChild("HumanoidRootPart")
                if humanoid and root and humanoid.Health > 0 then
                    local distance = (myRoot.Position - root.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = child
                    end
                end
            end
        end
    end
    return closestTarget
end

-- System: Auto Farm Loop
task.spawn(function()
    while true do
        task.wait() 
        if Options.AutoFarm.Value then
            pcall(function()
                local target = GetTargetMonster()
                if target then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetCFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(
                            LocalPlayer.Character.HumanoidRootPart.Position,
                            target.HumanoidRootPart.Position
                        )
                    end
                    RequestHit()
                else
                    -- Teleport to Map if Target Not Found (StreamingEnabled Fix)
                    local mapName = FarmModes[CurrentMode].MapName
                    if mapName and TeleportLocations[mapName] then
                        -- Check distance to map center to avoid constant teleporting
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - TeleportLocations[mapName].Position).Magnitude
                            if dist > 500 then -- Only teleport if far away
                                TeleportTo(TeleportLocations[mapName])
                                task.wait(1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- System: Auto Quest Loop
task.spawn(function()
    while true do
        task.wait(3)
        if Options.AutoFarm.Value then
            pcall(function() AcceptQuest() end)
        end
    end
end)

-- System: Auto Stats Loop
task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            if Options.AutoMelee.Value then UpgradeStat("Melee") end
            if Options.AutoDefense.Value then UpgradeStat("Defense") end
            if Options.AutoSword.Value then UpgradeStat("Sword") end
            if Options.AutoPower.Value then UpgradeStat("Power") end
        end)
    end
end)

-- Logic: Auto Haki (G) (Improved with Server Listener)
task.spawn(function()
    while task.wait(1) do
        if Options.AutoHaki.Value then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    -- 1. ขอ Status ล่าสุดจาก Server เพื่อความชัวร์
                    local hakiRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("HakiRemote")
                    if hakiRemote then
                        hakiRemote:FireServer("GetStatus")
                    end
                    
                    -- 2. รอแป๊บนึงให้ Listener อัปเดตตัวแปร HakiState
                    task.wait(0.2) 

                    -- 3. ถ้า Server บอกว่าปิดอยู่ -> สั่งเปิด
                    if not HakiState.Active then
                        if hakiRemote then
                            hakiRemote:FireServer("Toggle")
                            -- กันรัว: รอ 2 วินาทีเพื่อให้สถานะอัปเดต
                            task.wait(2)
                        end
                    end
                end
            end)
        end
    end
end)

-- Task 2: Auto Observation (Kenbunshoku) (Improved with Server Listener)
task.spawn(function()
    while task.wait(1) do
        if Options.AutoObservationHaki.Value then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    -- 1. ขอ Status
                    local obsRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("ObservationHakiRemote")
                    if obsRemote then
                        -- สังเกตอาจไม่มี GetStatus แยก หรือใช้ชื่ออื่น ลองยิง Toggle ถ้ามั่นใจว่าปิดอยู่
                        -- แต่โชคดีที่เรามี Listener คอยฟัง Activated/Deactivated อยู่แล้ว
                    end

                    -- 2. ถ้า Server บอกว่าปิดอยู่ -> สั่งเปิด
                    if not ObsState.Active then
                        if obsRemote then
                            obsRemote:FireServer("Toggle")
                            task.wait(2)
                        end
                    end
                end
            end)
        end
    end
end)

--------------------------------------------------------------------------------
-- Settings (Configuration Manager & Auto Load)
--------------------------------------------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("SailorPiece_Mamypoko") -- Unique Folder for this script
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)

-- Auto Load Config (เปิดการทำงานส่วนนี้เพื่อให้ Save ค่าอัตโนมัติ)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({ Title = "By.Lume.Dev Loaded", Content = "[🌑Eminence Update👑] Sailor Piece Script Loaded!", Duration = 5 })