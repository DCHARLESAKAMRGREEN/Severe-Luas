local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetChildren()[1]
local power = player.Backpack.ActionValues.Power

local ShotAdjustments = {
    [100] = 69.5 - 9.25, [95] = 69.5 - 8.75, [90] = 69.5 - 8, 
    [85] = 69.5 - 7.25, [80] = 69.5 - 7, [75] = 69.5 - 6.85,
    [70] = 69.5 - 6.35, [65] = 69.5 - 5.5, [60] = 69.5 - 5.35,
    [55] = 69.5 - 4.05, [50] = 69.5 - 3.75, [45] = 69.5 - 2.8,
    [40] = 69.5 - 2.5, [35] = 69.5 - 0.25, [30] = 69.5 - 0.1
}

local LayupAdjustments = {
    [100] = 66.8165 - 12.5, [95] = 66.8165 - 11.75, [90] = 66.8165 - 11,
    [85] = 66.8165 - 10.25, [80] = 66.8165 - 10, [75] = 66.8165 - 9.85,
    [70] = 66.8165 - 9.35, [65] = 66.8165 - 8.5, [60] = 66.8165 - 8.35,
    [55] = 66.8165 - 7.15, [50] = 66.8165 - 6.95, [45] = 66.8165 - 6.45,
    [40] = 66.8165 - 6.25, [35] = 66.8165 - 4.5, [30] = 66.8165 - 4.25
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
