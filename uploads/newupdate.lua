repeat wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
Workspace = cloneref(game:GetService("Workspace"))
Players = cloneref(game:GetService("Players"))
PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
HttpService = cloneref(game:GetService("HttpService"))
TweenService = cloneref(game:GetService("TweenService"))
UserInputService = cloneref(game:GetService("UserInputService"))
CoreGui = cloneref(game:GetService("CoreGui"))
RunService = cloneref(game:GetService("RunService"))

-- ===================== CONFIGURATION =====================
-- [[ ใส่ Service ID ของ PandaAuth ตรงนี้ ]]
local PandaServiceID = "lumedevkid" 

-- ===================== GAME LIST =====================
-- ใส่ ID เกมที่ต้องการให้รันได้ที่นี่ (ใส่ได้ทั้ง PlaceId หรือ GameId)
local ListGame = {
	["77747658251236"] = { link = "https://www.roblox.com/th/games/77747658251236/Sailor-Piece", keyless = false },
	-- ["ID_GAME_OTHER"] = { ... }
}

-- ===================== UI LIBRARY HELPERS =====================
local UI = {}
function UI:Create(class, properties)
	local instance = Instance.new(class)
	for k, v in pairs(properties) do
		instance[k] = v
	end
	return instance
end

function UI:AddCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

function UI:AddStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

function UI:AddGradient(instance, colors, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colors)
	gradient.Rotation = rotation or 0
	gradient.Parent = instance
	return gradient
end

function UI:AddShadow(parent)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadow.Size = UDim2.new(1, 40, 1, 40)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Image = "rbxassetid://6015897843" -- Common shadow asset
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Parent = parent
	return shadow
end

-- ===================== PANDA AUTH V2.5 LIBRARY =====================
local PandaV2 = {}
do
	local CONFIG = { serviceId = PandaServiceID, autoSave = true, debug = false }
	local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
	
	local function log(...) if CONFIG.debug then print("[PandaV2.5]", ...) end end

	local function getHWID()
		local hwid = nil
		if gethwid then pcall(function() hwid = gethwid() end) end
		if not hwid then
			local player = Players.LocalPlayer
			local exec = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "unknown"
			hwid = "P_" .. tostring(player.UserId) .. "_" .. exec
		end
		return hwid
	end

	function PandaV2.validate(key, serviceId)
		if not httpRequest then return false, "No HTTP function" end
		serviceId = serviceId or CONFIG.serviceId
		local hwid = getHWID()
		local url = string.format("https://pandadevelopment.net/v2_validation?service=%s&key=%s&hwid=%s", serviceId, key, hwid)
		
		local success, response = pcall(function()
			return httpRequest({Url = url, Method = "GET"})
		end)

		if not success or not response or not response.Body then return false, "Connection Failed" end
		
		local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
		if not decodeSuccess then return false, "Invalid JSON" end

		if data.V2_Authentication == "success" then
			return true, data
		else
			return false, data.V2_Authentication or "Invalid Key"
		end
	end

	function PandaV2.getLink(serviceId)
		serviceId = serviceId or CONFIG.serviceId
		return "https://pandadevelopment.net/getkey?service=" .. serviceId .. "&hwid=" .. getHWID()
	end
end
-- ===============================================================

-- ===================== MAIN LOGIC =====================
local executor_name = (getexecutorname and getexecutorname()) or "unknown"

-- ตรวจสอบ ID เกม (รองรับทั้ง PlaceId และ UniverseId)
local place_id = tostring(game.PlaceId)
local universe_id = tostring(game.GameId)

-- เช็คว่ามี Config ของเกมนี้ในตารางไหม
local game_cfg = ListGame[place_id] or ListGame[universe_id]

-- [[ จุดสำคัญ: ถ้าไม่มี Config (เกมไม่ตรง) ให้หยุดการทำงานทันที ]]
if not game_cfg then
	warn("Lume.Dev: This game is not supported. Script stopped.")
	return -- หยุดรันสคริปต์ตรงนี้ UI จะไม่ขึ้น
end

if CoreGui:FindFirstChild("LumeDev_KeySystem") then
	CoreGui.LumeDev_KeySystem:Destroy()
end

-- Optimization for certain executors
for _, exec in ipairs({"Xeno", "Solara"}) do
	if string.find(executor_name, exec) then
		workspace:SetAttribute("low", true)
		break
	end
end

function Task()
	local status, res1, res2 = pcall(function()
		
		-- Keyless Check
		if game_cfg.keyless then
			-- [[ LOAD SCRIPT HERE IF KEYLESS ]]
			return 
		end

		local Task = {}
		local v1 = {}
		local variables = {}

		-- String Helpers
		v1.__index = v1
		local v_u_3 = buffer and buffer.tostring or function(b) return tostring(b) end
		local v_u_4 = buffer and buffer.fromstring or function(s) return s end
		function v1.revert(p6) return v_u_4(p6) end
		function v1.convert(p51) return v_u_3(p51) end

		-- Setup ScreenGui
		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "LumeDev_KeySystem"
		ScreenGui.IgnoreGuiInset = true
		ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		
		if get_ui then ScreenGui.Parent = get_ui()
		elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = CoreGui
		else ScreenGui.Parent = CoreGui end

		-- Setup Notification GUI
		local NotificationGUI = Instance.new("ScreenGui")
		NotificationGUI.Name = "LumeDev_Notifications"
		NotificationGUI.Parent = ScreenGui.Parent -- Same parent as main gui
		
		local Container = UI:Create("Frame", {
			Name = "Container",
			Parent = NotificationGUI,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -20, 0, 50),
			Size = UDim2.fromOffset(300, 600),
			BackgroundTransparency = 1
		})
		
		local Layout = Instance.new("UIListLayout")
		Layout.Parent = Container
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 10)
		Layout.VerticalAlignment = Enum.VerticalAlignment.Top
		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

		local function NotifyCustom(title, content, duration)
			duration = duration or 5
			
			local NotifFrame = UI:Create("Frame", {
				Parent = Container,
				Size = UDim2.fromOffset(280, 80),
				BackgroundColor3 = Color3.fromRGB(18, 18, 20),
				BorderSizePixel = 0,
				BackgroundTransparency = 0.05
			})
			UI:AddCorner(NotifFrame, 8)
			UI:AddStroke(NotifFrame, Color3.fromRGB(60, 60, 80), 1)
			UI:AddShadow(NotifFrame) -- Add Shadow for depth

			-- Accent Line (RED THEME)
			local Accent = UI:Create("Frame", {
				Parent = NotifFrame,
				Size = UDim2.new(0, 4, 1, 0),
				BackgroundColor3 = Color3.fromRGB(231, 76, 60), -- Red
				BorderSizePixel = 0
			})
			UI:AddCorner(Accent, 4)

			local TitleLabel = UI:Create("TextLabel", {
				Parent = NotifFrame,
				Size = UDim2.new(1, -20, 0, 25),
				Position = UDim2.new(0, 15, 0, 8),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local DescLabel = UI:Create("TextLabel", {
				Parent = NotifFrame,
				Size = UDim2.new(1, -20, 0, 40),
				Position = UDim2.new(0, 15, 0, 32),
				BackgroundTransparency = 1,
				Text = content,
				TextColor3 = Color3.fromRGB(180, 180, 180),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top
			})

			-- Animation
			NotifFrame.Position = UDim2.new(1, 50, 0, 0) -- Start off screen
			TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 0, 0) -- Relative to layout
			}):Play()

			task.delay(duration, function()
				TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0) -- Shrink
				}):Play()
				TweenService:Create(TitleLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
				TweenService:Create(DescLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
				TweenService:Create(Accent, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
				task.wait(0.5)
				NotifFrame:Destroy()
			end)
		end

		local function DraggFunction(Frame)
			local dragToggle, dragInput, dragStart, startPos
			local function updateInput(input)
				local delta = input.Position - dragStart
				TweenService:Create(Frame, TweenInfo.new(0.1), {
					Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				}):Play()
			end
			Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragToggle = true
					dragStart = input.Position
					startPos = Frame.Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragToggle = false
						end
					end)
				end
			end)
			Frame.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if input == dragInput and dragToggle then
					updateInput(input)
				end
			end)
		end

		local function RandomName(b) return string.rep("x", b) end -- Simplified
		local jas = "VerifyAuth"
		local coppy = setclipboard or toclipboard or function(t) print("Clipboard:", t) end

		local function Notification(Type, Message)
			NotifyCustom(Type, Message, 5)
		end

		local function DeleteFile(File)
			if isfile(File) then delfile(File) end
		end

		-- Verify Logic
		variables[jas] = function(key, file_directory)
			if type(key) ~= "buffer" then return nil end
			local cleaned_key = v1.convert(key):gsub("%s", "")
			
			local success, result = PandaV2.validate(cleaned_key, PandaServiceID)
			
			if success then
				if ScreenGui then ScreenGui:Destroy() end
				if NotificationGUI then NotificationGUI:Destroy() end

				-- Save Key Logic
				pcall(function()
					writefile(file_directory, cleaned_key)
				end)

				script_key = cleaned_key
				
				-- STANDARD NOTIFICATION (since our custom UI is gone)
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "LumeDev",
					Text = "Key Verified! Loading script...",
					Duration = 5
				})
				
				-- [[ IMPORTANT: LOAD YOUR ACTUAL SCRIPT HERE ]]
				-- ใส่ Script ของคุณตรงนี้ครับ หรือใส่ loadstring ก็ได้

           -- ตรวจสอบ ID ของเกม ([🎄Christmas❄️]Sailor Piece Script ID: 17450164673)
-- [แก้ไข] ปิดการเช็ค ID ชั่วคราวเพื่อให้แน่ใจว่าสคริปต์รันได้
if game.PlaceId ~= 77747658251236 then 
    warn("[🎄Christmas❄️]Sailor Piece Script Script: Unauthorized Game ID")
    -- return 
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
local LocalPlayer = Players.LocalPlayer

-- [NEW] Mobile Support Logic (ปรับขนาดจอ)
local WindowSize = UDim2.fromOffset(580, 460) -- ขนาดปกติสำหรับ PC
if UserInputService.TouchEnabled then
    WindowSize = UDim2.fromOffset(480, 320) -- ขนาดเล็กสำหรับมือถือ (ปรับให้เล็กลง)
end

-- [สำคัญ] ตั้งชื่อหน้าต่างใส่ตัวแปรไว้ เพื่อให้ปุ่ม Mobile ค้นหาเจอ
local WindowTitle = "[🗡️Bleach & Ragnarok👑] Sailor Piece Script " .. Fluent.Version

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
    Stats = Window:AddTab({ Title = "Stats", Icon = "list" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- [NEW] State Tracking Variables (ตัวแปรเก็บสถานะจริงจาก Server)
local HakiState = { Active = false, HasAbility = false }
local ObsState = { Active = false, HasAbility = false }

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
    ["HuecoMundoIsland"] = CFrame.new(-482.868896, -2.05866098, 936.237061, 0.838688612, -0, -0.544611216, 0, 1, -0, 0.544611216, 0, 0.838688612)
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
    ["SummonBossNPC"] = CFrame.new(692.040527, -3.67419362, -1085.31812, -0.819156051, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, -0.819156051),
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
    ["ArtifactsUnlocker"] = CFrame.new(-430.236389, 1.77979147, -1179.23547, -0.92051065, 0, -0.390717506, 0, 1, 0, 0.390717506, 0, -0.92051065)
}

local BossLocations = {
    ["JinwooBoss"] = CFrame.new(311.442261, 7.59386587, 946.90509, -0.953600168, 0, -0.301075935, 0, 1, 0, 0.301075935, 0, -0.953600168),
    ["SukunaBoss"] = CFrame.new(1571.26672, 80.2205353, -34.1126976, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["GojoBoss"] = CFrame.new(1855.56628, 8.48613453, 341.594879, 0.999688804, -0, -0.0249451213, 0, 1, -0, 0.0249451213, 0, 0.999688804),
    ["RagnaBoss"] = CFrame.new(340.000092, 2.61343861, -1688.00024, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["AizenBoss"] = CFrame.new(-567.223083, 2.57872534, 1228.49036, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

local WeaponGroups = {
    ["Combat"] = {
        "Combat" , "Gojo" , "Sukuna", "Qin Shi"
    }, 
    ["Sword"] = { 
        "Katana", "Dark Blade", "Ragna", "Saber", "Jinwoo" , 'Aizen'
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

    -- Ragna Quest Section
    Tabs.AllQuest:AddSection("Ragna Quest")
    
    Tabs.AllQuest:AddParagraph({
        Title = "Auto Quest Ragna",
        Content = "1.Kill 750 npcs, 2. deal 400m, 3. kill 50 players, 4. take 100m dmg, 5. kill 20 ragnas.."
    })

    local RagnaQuestToggle = Tabs.AllQuest:AddToggle("AutoQuestRagna", {Title = "Auto Quest Ragna", Default = false })
    local RagnaFarmMobsToggle = Tabs.AllQuest:AddToggle("AutoFarmRagnaMobs", {Title = "Kill 750 NPCs (Ragna)", Default = false }) 
    local RagnaKillPlayersToggle = Tabs.AllQuest:AddToggle("AutoKillPlayersRagna", {Title = "Auto Kill Players (Ragna)", Default = false }) 
    local RagnaDummyToggle = Tabs.AllQuest:AddToggle("AutoDummyRagna", {Title = "Auto Farm Dummy (Ragna)", Default = false })
    
    local RagnaState = "NPC"
    
    RagnaQuestToggle:OnChanged(function()
        if not Options.AutoQuestRagna.Value then
            RagnaState = "NPC"
        end
    end)

    -- ระบบ Auto Farm Dummy (TrainingDummy) - Ragna
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoDummyRagna and Options.AutoDummyRagna.Value then
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

    -- ระบบ Auto Kill Players - Ragna
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoKillPlayersRagna and Options.AutoKillPlayersRagna.Value then
                pcall(function()
                    local closestPlayer = nil
                    local minDistance = math.huge
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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

    -- ระบบ Auto Quest / Boss - Ragna
    task.spawn(function()
        local ragnaNPCFrame = NPCLocations["RagnaQuestlineBuff"]
        while true do
            task.wait()
            if Options.AutoQuestRagna and Options.AutoQuestRagna.Value then
                pcall(function()
                    if RagnaState == "NPC" then
                        TeleportTo(ragnaNPCFrame)
                        if (LocalPlayer.Character.HumanoidRootPart.Position - ragnaNPCFrame.Position).Magnitude < 10 then
                            task.wait(0.5)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(1)
                            Fluent:Notify({ Title = "Ragna Quest", Content = "Quest Accepted! Farming Boss...", Duration = 3 })
                            RagnaState = "Boss"
                        end
                    elseif RagnaState == "Boss" then
                        local targetName = "RagnaBoss"
                        local target = nil
                        local searchLocations = {Workspace, Workspace:FindFirstChild("EnEnemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
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
                            if BossLocations["RagnaBoss"] then
                                TeleportTo(BossLocations["RagnaBoss"])
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- Mobs Farm - Ragna
    task.spawn(function()
        while true do
            task.wait()
            if Options.AutoFarmRagnaMobs and Options.AutoFarmRagnaMobs.Value then
                pcall(function()
                    local target = nil
                    local minDst = math.huge
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        local targetNames = {}
                        for _, mode in pairs(FarmModes) do
                            for _, mobName in pairs(mode.Mobs) do table.insert(targetNames, mobName) end
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
                                                    -- Skip
                                                else
                                                    local dst = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                                                    if dst < minDst then minDst = dst; target = v end
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

    ModeDropdown:OnChanged(function(Value)
        CurrentMode = Value
        AbandonQuest()
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

    local BossList = {"JinwooBoss", "SukunaBoss", "GojoBoss", "RagnaBoss","AizenBoss"}
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
        while true do
            task.wait()
            if Options.AutoFarmBoss.Value then
                pcall(function()
                    
                    -- Iterate through selected bosses
                    for _, bossName in ipairs(SelectedBosses) do
                        if not Options.AutoFarmBoss.Value then break end
                        
                        -- 1. Teleport to Boss Spawn Location first (StreamingEnabled Fix)
                        if BossLocations[bossName] then
                            TeleportTo(BossLocations[bossName])
                            -- Wait for boss to stream in/spawn
                            task.wait(1) 
                        end

                        -- 2. Search for Boss
                        local target = nil
                        -- Search logic in all possible folders
                         local searchLocations = {Workspace, Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("Npcs")}
                         
                         for _, location in pairs(searchLocations) do
                            if location then
                                -- Check direct child
                                if location:FindFirstChild(bossName) then
                                    local v = location[bossName]
                                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                        target = v
                                        break
                                    end
                                end
                                -- Fallback loop if exact name not found directly
                                for _, v in pairs(location:GetChildren()) do
                                    if (v.Name == bossName) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                        target = v
                                        break
                                    end
                                end
                            end
                            if target then break end
                         end

                        -- 3. Farm if found
                        if target then
                            -- Teleport and Attack until dead or toggled off
                            while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and Options.AutoFarmBoss.Value do
                                local tPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                TeleportTo(CFrame.lookAt(tPos.Position, target.HumanoidRootPart.Position))
                                EquipWeapon(Options.SelectWeapon.Value)
                                RequestHit()
                                task.wait()
                            end
                        else
                             -- If not found (dead or not spawned), wait a bit then move to next boss
                            task.wait(0.5)
                        end
                    end
                end)
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
        Values = {"Z", "X", "C", "V"},
        Multi = true,
        Default = {"Z", "X", "C", "V"}, -- เลือกทั้งหมดโดย Default
    })

    -- Toggle สำหรับเปิด/ปิดการใช้สกิล
    local AutoSkillsToggle = Tabs.AutoFarm:AddToggle("AutoUseSkills", {Title = "Auto Use Skills (เปิดใช้สกิล)", Default = false })
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
        Values = { "SnowIsland", "ShibuyaStation", "SailorIsland", "JungleIsland", "DesertIsland", "BossIsland", "XmasIsland","StarterIsland" , "HuecoMundoIsland" },
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
        Values = { "Dark Blade Quest", "Haki Trainer", "Santa", "RagnaBuyer", "RagnaQuestlineBuff", "SummonBossNPC", "EnchantNPC", "GojoNpc", "SukunaNpc", "Jinwoo Npc", "TitleNpc", "Random Fruit (Gem)", "Random Fruit (Coin)", "StorageNpc", "TraitsNpc","AizenNpc","AizenQuestBuff","ObservationBuyer","ArtifactsUnlocker" },
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
                ["title"] = "🎮 [🎄Christmas❄️]Sailor Piece Script Script - By.Mamypoko",
                ["description"] = "✅ Webhook is working correctly!\n\n**User:** ||" .. LocalPlayer.Name .. "||\n**ID:** " .. LocalPlayer.UserId,
                ["color"] = 65280,
                ["thumbnail"] = {
                    ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
                },
                ["footer"] = { ["text"] = "[🎄Christmas❄️]Sailor Piece Script Script - By.Mamypoko • " .. os.date("%H:%M:%S") },
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
                        if gainedLevel > 0 then gainsText = gainsText .. "🆙 + " .. formatNumber(gainedLevel) .. " Levels\n" end
                        if gainedMoney > 0 then gainsText = gainsText .. "💰 + " .. formatNumber(gainedMoney) .. " Money\n" end
                        if gainedGems > 0 then gainsText = gainsText .. "💎 + " .. formatNumber(gainedGems) .. " Gems\n" end
                        
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
                            ["title"] = "🌊 [🎄Christmas❄️]Sailor Piece Script - By.Mamypoko",
                            ["url"] = "https://www.roblox.com/games/17450164673/Sailor-Piece", -- ตัวอย่างลิงก์เกม
                            ["color"] = 65280, -- Green
                            ["thumbnail"] = {
                                ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
                            },
                            ["fields"] = fields,
                            ["footer"] = { 
                                ["text"] = "[🎄Christmas❄️]Sailor Piece Script Script - By.Mamypoko • " .. os.date("%H:%M:%S"),
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
    
    -- [Group] Miscellaneous (Anti AFK) - ADDED HERE
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

Fluent:Notify({ Title = "By.Lume.Dev Loaded", Content = "[🗡️Bleach & Ragnarok👑] Sailor Piece Script Loaded!", Duration = 5 })
				
				print("KEY VERIFIED. LOADING HUB...")
				
				-- ตัวอย่าง:
				-- loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/hub.lua"))()

				return true
			else
				Notification("Error", "Invalid Key: " .. tostring(result))
				DeleteFile(file_directory)
				return nil
			end
		end

		-------------------------------------------------------------------------------
		-- PREMIUM UI CONSTRUCTION
		-------------------------------------------------------------------------------
		function Task:Window(config)
			config.DisplayName = config.DisplayName or "LumeDev"
			config.Discord = config.Discord or ""
			config.File = config.File or "LumeDev_key.txt"
			
			-- [[ Auto-Login System: Check key BEFORE creating UI ]]
			if isfile(config.File) then
				local saved_key = readfile(config.File)
				if saved_key then
					-- Attempt to verify silently
					-- Note: variables[jas] returns true if valid and automatically destroys UI/Loads script
					local valid = variables[jas](v1.revert(saved_key), config.File)
					if valid then
						return {} -- Return empty object, skip UI creation entirely
					end
				end
			end
			-- [[ End Auto-Login Logic ]]
			
			local panda_link = PandaV2.getLink(PandaServiceID)

			-- MAIN FRAME (Widened for better proportion)
			local MainFrame = UI:Create("Frame", {
				Name = "MainFrame",
				Parent = ScreenGui,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(500, 280),
				BackgroundColor3 = Color3.fromRGB(18, 18, 20),
				BorderSizePixel = 0,
				ClipsDescendants = false -- Allow shadow to show
			})
			UI:AddCorner(MainFrame, 16)
			UI:AddStroke(MainFrame, Color3.fromRGB(45, 45, 50), 1)
			UI:AddShadow(MainFrame) -- The "Depth" effect

			-- TOP BAR
			local TopBar = UI:Create("Frame", {
				Parent = MainFrame,
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
			})
			
			-- Divider Line
			local Divider = UI:Create("Frame", {
				Parent = TopBar,
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(35, 35, 40),
				BorderSizePixel = 0
			})

			local Title = UI:Create("TextLabel", {
				Parent = TopBar,
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, 24, 0, 0),
				BackgroundTransparency = 1,
				Text = config.DisplayName,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			-- Title Gradient (RED THEME)
			UI:AddGradient(Title, {
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 50))
			})

			local CloseButton = UI:Create("TextButton", {
				Parent = TopBar,
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(1, -40, 0.5, -15),
				BackgroundTransparency = 1,
				Text = "×",
				TextColor3 = Color3.fromRGB(120, 120, 130),
				Font = Enum.Font.Gotham,
				TextSize = 28
			})
			
			CloseButton.MouseEnter:Connect(function() 
				TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
			end)
			CloseButton.MouseLeave:Connect(function() 
				TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(120, 120, 130)}):Play()
			end)
			CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

			-- CONTENT AREA
			local Content = UI:Create("Frame", {
				Parent = MainFrame,
				Size = UDim2.new(1, -48, 1, -80),
				Position = UDim2.new(0, 24, 0, 70),
				BackgroundTransparency = 1
			})

			-- Subtext Instructions
			local Instr = UI:Create("TextLabel", {
				Parent = Content,
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 0, -5),
				BackgroundTransparency = 1,
				Text = "Please enter your access key below to continue.",
				TextColor3 = Color3.fromRGB(100, 100, 110),
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			-- Input Box Container (Stylish)
			local InputContainer = UI:Create("Frame", {
				Parent = Content,
				Size = UDim2.new(1, 0, 0, 50),
				Position = UDim2.new(0, 0, 0, 25),
				BackgroundColor3 = Color3.fromRGB(12, 12, 14),
			})
			UI:AddCorner(InputContainer, 10)
			local InputStroke = UI:AddStroke(InputContainer, Color3.fromRGB(40, 40, 45), 1)

			local Keybox = UI:Create("TextBox", {
				Parent = InputContainer,
				Size = UDim2.new(1, -30, 1, 0),
				Position = UDim2.new(0, 15, 0, 0),
				BackgroundTransparency = 1,
				Text = "",
				PlaceholderText = "Paste key here...",
				PlaceholderColor3 = Color3.fromRGB(70, 70, 80),
				TextColor3 = Color3.fromRGB(220, 220, 220),
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				ClearTextOnFocus = false
			})

			-- Focus Animation (RED THEME)
			Keybox.Focused:Connect(function()
				TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(231, 76, 60), Transparency = 0}):Play()
			end)
			Keybox.FocusLost:Connect(function()
				TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(40, 40, 45)}):Play()
			end)

			-- BUTTONS AREA
			local ButtonGrid = UI:Create("Frame", {
				Parent = Content,
				Size = UDim2.new(1, 0, 0, 45),
				Position = UDim2.new(0, 0, 0, 95), -- Spaced further down
				BackgroundTransparency = 1
			})
			
			local UIList = Instance.new("UIListLayout")
			UIList.Parent = ButtonGrid
			UIList.FillDirection = Enum.FillDirection.Horizontal
			UIList.SortOrder = Enum.SortOrder.LayoutOrder
			UIList.Padding = UDim.new(0, 12)

			-- Helper to create styled buttons
			local function CreateButton(text, color, order, callback)
				local Btn = UI:Create("TextButton", {
					Parent = ButtonGrid,
					Size = UDim2.new(0.333, -8, 1, 0), -- Perfectly split into 3
					BackgroundColor3 = Color3.fromRGB(25, 25, 28),
					Text = text,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					LayoutOrder = order,
					AutoButtonColor = false
				})
				UI:AddCorner(Btn, 8)
				local BtnStroke = UI:AddStroke(Btn, Color3.fromRGB(50, 50, 55), 1)
				
				-- Hover Effects
				Btn.MouseEnter:Connect(function()
					TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
					TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
					TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
				end)
				Btn.MouseLeave:Connect(function()
					TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 28)}):Play()
					TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
					TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
				end)
				
				Btn.MouseButton1Click:Connect(callback)
				return Btn
			end

			-- Add Buttons
			CreateButton("GET KEY", Color3.fromRGB(46, 204, 113), 1, function()
				coppy(panda_link)
				Notification("Link Copied", "Get Key link copied to clipboard")
			end)
			
			CreateButton("DISCORD", Color3.fromRGB(88, 101, 242), 2, function()
				coppy(config.Discord)
				Notification("Link Copied", "Discord link copied to clipboard")
			end)
			
			-- LOGIN BUTTON (RED THEME)
			CreateButton("LOGIN", Color3.fromRGB(192, 57, 43), 3, function()
				if Keybox.Text ~= "" then
					local btn = ButtonGrid:GetChildren()[3] -- Access self (Login btn)
					btn.Text = "..."
					variables[jas](v1.revert(Keybox.Text), config.File)
					btn.Text = "LOGIN"
				else
					Notification("Input Error", "Please enter a key first")
				end
			end)

			-- FOOTER STATUS
			local StatusContainer = UI:Create("Frame", {
				Parent = MainFrame,
				Size = UDim2.new(1, -48, 0, 20),
				Position = UDim2.new(0, 24, 1, -30),
				BackgroundTransparency = 1
			})

			local StatusText = UI:Create("TextLabel", {
				Parent = StatusContainer,
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "Protected by PandaAuth",
				TextColor3 = Color3.fromRGB(70, 70, 80),
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local VersionText = UI:Create("TextLabel", {
				Parent = StatusContainer,
				Size = UDim2.new(0.5, 0, 1, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = "v1.0.5",
				TextColor3 = Color3.fromRGB(50, 50, 60),
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Right
			})

			-- Window Dragging
			DraggFunction(MainFrame)
			
			-- Entrance Animation (Fade + Scale Up)
			MainFrame.Size = UDim2.fromOffset(480, 260) -- Slightly smaller start
			MainFrame.BackgroundTransparency = 1
			for _,v in pairs(MainFrame:GetDescendants()) do
				if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
					v.TextTransparency = 1
				elseif v:IsA("UIStroke") then
					v.Transparency = 1
				elseif v:IsA("ImageLabel") then
					v.ImageTransparency = 1
				end
			end

			-- Play Animation
			TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(500, 280),
				BackgroundTransparency = 0
			}):Play()
			
			for _,v in pairs(MainFrame:GetDescendants()) do
				if v:IsA("TextLabel") or v:IsA("TextButton") then
					TweenService:Create(v, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				elseif v:IsA("TextBox") then
					TweenService:Create(v, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				elseif v:IsA("UIStroke") then
					TweenService:Create(v, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
				elseif v:IsA("ImageLabel") and v.Name == "Shadow" then
					TweenService:Create(v, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0.5}):Play()
				end
			end
		end
		return Task
	end)
	if not status then
		warn("UI Failed: " .. tostring(res1))
	else
		return res1
	end
end

local Task = Task()

-- Run the Window
Task:Window({
	File = "Lumedev/savedkey.txt",
	Discord = "https://discord.gg/Zk7f9w4DcD",
	DisplayName = "Lume.Dev"
})


-- Load Loading Screen
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = gethui and gethui() or game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = 35 }):Play()

local gui = Instance.new("ScreenGui")
gui.Name = "Lume.DevLoaderRed" -- เปลี่ยนชื่อนิดหน่อยให้รู้ว่าเป็นเวอร์ชั่นสีแดง
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local root = Instance.new("Frame")
root.Size = UDim2.new(1, 0, 1, 0)
root.BackgroundTransparency = 1
root.Parent = gui

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
-- [[ แก้ไขจุดที่ 1: เปลี่ยนสีพื้นหลังเป็นสีแดงเข้ม ]] --
bg.BackgroundColor3 = Color3.fromRGB(45, 5, 10) -- โทนสีแดงเลือดหมูเข้ม
--------------------------------------------------
bg.BackgroundTransparency = 1
bg.ZIndex = 0
bg.Parent = root
TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.18 }):Play()

local TITLE = "Lume Dev"
local labels = {}
local spacing = 48

local function fadeOut()
    for _, lbl in ipairs(labels) do
        TweenService:Create(lbl, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
            TextTransparency = 1,
            TextStrokeTransparency = 1,
            TextSize = 22
        }):Play()
    end
    TweenService:Create(bg, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blur, TweenInfo.new(0.2), { Size = 0 }):Play()
    task.wait(0.25)
    gui:Destroy()
    blur:Destroy()
end

for i = 1, #TITLE do
    local char = TITLE:sub(i, i)
    local lbl = Instance.new("TextLabel")
    lbl.Text = char
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีพื้นฐานเป็นขาว (เพื่อให้ Gradient ทำงานได้ดี)
    lbl.TextTransparency = 1
    lbl.TextStrokeTransparency = 1
    lbl.TextSize = 44
    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Position = UDim2.new(0.5, (i - (#TITLE / 2 + 0.5)) * spacing, 0.5, 0)
    lbl.BackgroundTransparency = 1
    lbl.Parent = root

    local grad = Instance.new("UIGradient")
    -- [[ แก้ไขจุดที่ 2: เปลี่ยนสีไล่ระดับของตัวอักษรเป็นโทนแดง ]] --
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 30, 30)), -- สีเริ่ม: แดงสด
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))   -- สีจบ: ขาว (เพื่อให้ดูสว่าง)
    })
    ---------------------------------------------------------
    grad.Rotation = -45
    grad.Parent = lbl

    -- Animation การปรากฏตัว (เด้งขยายแล้วหดลงเล็กน้อย)
    TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { -- เพิ่มเวลาเล็กน้อยเพื่อให้เห็น effect ชัดขึ้น
        TextTransparency = 0,
        TextStrokeTransparency = 0.5,
        TextSize = 68
    }):Play()

    TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        TextSize = 54
    }):Play()

    table.insert(labels, lbl)
    task.wait(0.09) -- เวลาหน่วงระหว่างตัวอักษร
end

task.wait(1) -- เพิ่มเวลาค้างหน้านี้ไว้นิดหน่อยก่อนจะหายไป (ของเดิมมันหายไปทันทีที่โหลดเสร็จ)
fadeOut()