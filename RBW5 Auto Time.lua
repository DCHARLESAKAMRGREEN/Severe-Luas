local Workspace = findservice(Game, "Workspace")
local Player = getlocalplayer()
local Character = getname(Player)
local Threshold = 1

local Adjustments = {
    {Ping = 85, Value = 0.5345},
    {Ping = 75, Value = 0.5735},
    {Ping = 62, Value = 0.6375},
    {Ping = 51, Value = 0.7065},
    {Ping = 40, Value = 0.7435},
    {Ping = 25, Value = 0.7715}
}

table.sort(Adjustments, function(a, b) return a.Ping > b.Ping end)

local getping = getping
local getvalue = getvalue
local typeof = typeof

local function GetAdjustments(Ping)
    for i = 1, #Adjustments do
        if Ping > Adjustments[i].Ping then
            return Adjustments[i].Value
        end
    end
end

local function Calculations()
    while true do
        local Ping = getping()
        if Ping then
            local Value = GetAdjustments(Ping)
            if Value then
                Threshold = Value
            end
        end
        wait(0.1)
    end
end

local function ShotMeter()
    local ShotMeter = findfirstchild(findfirstchild(findfirstchild(Workspace, Character), "Properties"), "ShotMeter")

    while true do
        local ShotValue = getvalue(ShotMeter)
        if typeof(ShotValue) == "number" and ShotValue ~= 2 and ShotValue >= Threshold then
            keyrelease(0x45)
        end
        wait(0)
    end
end

spawn(Calculations)
ShotMeter()
