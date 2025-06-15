local Threshold = 1

local Adjustments = {
    {Ping = 100, Value = 0.6515},
    {Ping = 90, Value = 0.6653},
    {Ping = 80, Value = 0.6960}, 
    {Ping = 70, Value = 0.7235},
    {Ping = 60, Value = 0.7423},
    {Ping = 50, Value = 0.7983},
    {Ping = 40, Value = 0.8350},
    {Ping = 25, Value = 0.86226}
}

table.sort(Adjustments, function(a, b) return a.Ping > b.Ping end)

local Character = waitforchild(Workspace, getname(getlocalplayer()))
local Properties = waitforchild(Character, "Properties")
local ShotMeter = waitforchild(Properties, "ShotMeter")

while true do
    local Ping = getping()
    if Ping then
        for i = 1, #Adjustments do
            if Ping > Adjustments[i].Ping then
                Threshold = Adjustments[i].Value
                break
            end
        end
        wait()
    end

    local ShotValue = getvalue(ShotMeter)
    if ShotValue ~= 2 and ShotValue >= Threshold then
        keyrelease(0x45)
    end

    wait()
end
