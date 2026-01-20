

local PlaceId = game.PlaceId
local HttpService = game:GetService("HttpService")


local MapScripts = {
    [77747658251236] = function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/zazazawX/SSS/main/uploads/lumedev_sailor.lua'))()
    end,


    [86730176697132] = function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/zazazawX/SSS/main/uploads/lumedev_volt.lua'))()
    end,

}


local function RunScriptByMap()
    if MapScripts[PlaceId] then
        local success, err = pcall(MapScripts[PlaceId])
        if not success then
            warn("เกิดข้อผิดพลาดในการรันสคริปต์: " .. tostring(err))
        end
    else
        print("ไม่พบสคริปต์เฉพาะสำหรับแมพไอดี: " .. PlaceId)
        print("กำลังรันสคริปต์พื้นฐาน (Universal Script)...")
        
    end
end


RunScriptByMap()
