local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetChildren()[1]
local power = player.Backpack.ActionValues.Power

while true do
    local pressedKeys = getpressedkeys()
    local ping = getping()
    local powerValue

    if table.find(pressedKeys, "E") or table.find(pressedKeys, "Space") then
        if ping >= 100 then
            powerValue = 69.5 - 10.5
        elseif ping >= 95 then
            powerValue = 69.5 - 10
        elseif ping >= 90 then
            powerValue = 69.5 - 9.5
        elseif ping >= 85 then
            powerValue = 69.5 - 8.5
        elseif ping >= 80 then
            powerValue = 69.5 - 7.5
        elseif ping >= 75 then
            powerValue = 69.5 - 6.5
        elseif ping >= 70 then
            powerValue = 69.5 - 6.25
        elseif ping >= 65 then
            powerValue = 69.5 - 5.5
        elseif ping >= 60 then
            powerValue = 69.5 - 5.25
        elseif ping >= 55 then
            powerValue = 69.5 - 4.45
        elseif ping >= 50 then
            powerValue = 69.5 - 4.15
        elseif ping >= 45 then
            powerValue = 69.5 - 3.45
        elseif ping >= 40 then
            powerValue = 69.5 - 3.25
        elseif ping >= 35 then
            powerValue = 69.5 - 0.5
        elseif ping >= 30 then
            powerValue = 69.5 - 0.25
        end

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
