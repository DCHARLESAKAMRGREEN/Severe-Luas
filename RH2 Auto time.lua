local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetChildren()[1]
local power = player.Backpack.ActionValues.Power

local ShotAdjustments = {
    [100] = 69.5 - 26, [95] = 69.5 - 24, [90] = 69.5 - 22, 
    [85] = 69.5 - 19, [80] = 69.5 - 17, [75] = 69.5 - 15,
    [70] = 69.5 - 14, [65] = 69.5 - 8.35, [60] = 69.5 - 7.45,
    [55] = 69.5 - 4.25, [50] = 69.5 - 3.75, [45] = 69.5 - 3.1,
    [40] = 69.5 - 3, [35] = 69 - 0, [30] = 69 - 0
}

local LayupAdjustments = {
    [100] = 66.8165 - 26, [95] = 66.8165 - 24, [90] = 66.8165 - 22, 
    [85] = 66.8165 - 19, [80] = 66.8165 - 17, [75] = 66.8165 - 15,
    [70] = 66.8165 - 14, [65] = 66.8165 - 8.35, [60] = 66.8165 - 7.45,
    [55] = 66.8165 - 4.25, [50] = 66.8165 - 3.75, [45] = 66.8165 - 3.15,
    [40] = 66.8165 - 3, [35] = 66.8165 - 0, [30] = 66.8165 - 0
}

local function getPowerValue(ping, pingTable)
    for threshold, value in pairs(pingTable) do
        if ping >= threshold then
            return value
        end
    end
    return pingTable[30]
end

while true do
    local pressedKeys = getpressedkeys()
    local ping = getping()

    local powerValue
    if table.find(pressedKeys, "Shift") and table.find(pressedKeys, "W") then
        powerValue = getPowerValue(ping, LayupAdjustments)
    else
        powerValue = getPowerValue(ping, ShotAdjustments)
    end

    if table.find(pressedKeys, "E") or table.find(pressedKeys, "Space") then
        if power.Value >= powerValue then
            if table.find(pressedKeys, "E") then
                keyrelease(0x45)
            end

            if table.find(pressedKeys, "Space") then
                keyrelease(0x20)
            end
        end
    end

    wait()
end
