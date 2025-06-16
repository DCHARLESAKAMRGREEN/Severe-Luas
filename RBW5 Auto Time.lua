local Threshold = 1

local Adjustments = {
    {Ping = 100, Value = 0.6515},
    {Ping = 90, Value = 0.6653},
    {Ping = 80, Value = 0.6960}, 
    {Ping = 70, Value = 0.7240},
    {Ping = 60, Value = 0.7430},
    {Ping = 50, Value = 0.8070},
    {Ping = 40, Value = 0.8350},
    {Ping = 25, Value = 0.86226}
}

local function Rescan(Parent, Name)
    local Result
    repeat
        Result = findfirstchild(Parent, Name)
        wait(1)
    until Result
    return Result
end

table.sort(Adjustments, function(A, B) return A.Ping > B.Ping end)

local Player = getname(getlocalplayer())
local Character = Rescan(Workspace, Player)
local Properties = Rescan(Character, "Properties")
local ShotMeter = Rescan(Properties, "ShotMeter")

while true do
    if not Character then
        Character = Rescan(Workspace, Player)
        Properties = Rescan(Character, "Properties")
        ShotMeter = Rescan(Properties, "ShotMeter")
    end

    local Ping = getping()
    if Ping then
        for i = 1, #Adjustments do
            if Ping > Adjustments[i].Ping then
                Threshold = Adjustments[i].Value
                break
            end
        end
    end

    local ShotValue = getvalue(ShotMeter)
    if ShotValue and ShotValue ~= 2 and ShotValue >= Threshold then
        keyrelease(0x45)
    end

    wait()
end
