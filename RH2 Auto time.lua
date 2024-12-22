local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetChildren()[1]
local power = player.Backpack.ActionValues.Power

local ShotAdjustments = {
    [100] = 69.5 - 9.25, [95] = 69.5 - 8.75, [90] = 69.5 - 8, 
    [85] = 69.5 - 7.25, [80] = 69.5 - 7, [75] = 69.5 - 6.85,
    [70] = 69.5 - 6.35, [65] = 69.5 - 5.5, [60] = 69.5 - 5.35,
    [55] = 69.5 - 4.15, [50] = 69.5 - 3.95, [45] = 69.5 - 3.45,
    [40] = 69.5 - 3.25, [35] = 69.5 - 0.5, [30] = 69.5 - 0.25
}

local LayupAdjustments = {
    [100] = 66.815 - 12.5, [95] = 66.815 - 11.75, [90] = 66.815 - 11,
    [85] = 66.815 - 10.25, [80] = 66.815 - 10, [75] = 66.815 - 9.85,
    [70] = 66.815 - 9.35, [65] = 66.815 - 8.5, [60] = 66.815 - 8.35,
    [55] = 66.815 - 7.15, [50] = 66.815 - 6.95, [45] = 66.815 - 6.45,
    [40] = 66.815 - 6.25, [35] = 66.815 - 4.5, [30] = 66.815 - 4.25
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