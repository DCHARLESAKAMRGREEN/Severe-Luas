local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetChildren()[1]
local power = player.Backpack.ActionValues.Power

local ShotAdjustments = {
    [100] = 69.5 - 9.15, [95] = 69.5 - 8.65, [90] = 69.5 - 8.15, 
    [85] = 69.5 - 7.645 [80] = 69.5 - 7.15, [75] = 69.5 - 6.5,
    [70] = 69.5 - 6, [65] = 69.5 - 5.65, [60] = 69.5 - 4.95,
    [55] = 69.5 - 4.15, [50] = 69.5 - 3.75, [45] = 69.5 - 2.95,
    [40] = 69.5 - 2.75, [35] = 69 - 0, [30] = 69 - 0
}

local LayupAdjustments = {
    [100] = 66.8165 - 9.15, [95] = 66.8165 - 8.65, [90] = 66.8165 - 8.15, 
    [85] = 66.8165 - 7.65, [80] = 66.8165 - 7.15, [75] = 66.8165 - 6.5,
    [70] = 66.8165 - 6, [65] = 66.8165 - 5.65, [60] = 66.8165 - 4.95,
    [55] = 66.8165 - 4.15, [50] = 66.8165 - 3.75, [45] = 66.8165 - 2.95,
    [40] = 66.8165 - 2.75, [35] = 66.8165 - 0, [30] = 66.8165 - 0
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
