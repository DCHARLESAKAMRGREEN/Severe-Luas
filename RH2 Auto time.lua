local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetChildren()[1]
local power = player.Backpack.ActionValues.Power

local ShotAdjustments = {
    [100] = 69.5 - 9.15, [95] = 69.5 - 8.25, [90] = 69.5 - 8, 
    [85] = 69.5 - 9, [80] = 69.5 - 8, [75] = 69.5 - 7,
    [70] = 69.5 - 6, [65] = 69.5 - 5.75, [60] = 69.5 - 5.15,
    [55] = 69.5 - 3.8, [50] = 69.5 - 3.45, [45] = 69.5 - 3.25,
    [40] = 69.5 - 2.925, [35] = 69.5 - 1, [30] = 69.5 - 0.35,
    [20] = 68 - 0
}

local LayupAdjustments = {
    [100] = 66.8165 - 9.15, [95] = 66.8165 - 8.65, [90] = 66.8165 - 8.15, 
    [85] = 66.8165 - 7.65, [80] = 66.8165 - 7, [75] = 66.8165 - 6.5,
    [70] = 66.8165 - 6, [65] = 66.8165 - 5.75, [60] = 66.8165 - 5.15,
    [55] = 66.8165 - 3.8, [50] = 66.8165 - 3.45, [45] = 66.8165 - 3.25,
    [40] = 66.8165 - 2.925, [35] = 66.8165 - 1, [30] = 66.8165 - 0.35,
    [20] = 68 - 0.1
}

local function getPowerValue(ping, pingTable)
    local sortedThresholds = {}
    for threshold in pairs(pingTable) do
        table.insert(sortedThresholds, threshold)
    end
    table.sort(sortedThresholds, function(a, b) return a > b end)

    for _, threshold in ipairs(sortedThresholds) do
        if ping >= threshold then
            return pingTable[threshold]
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
