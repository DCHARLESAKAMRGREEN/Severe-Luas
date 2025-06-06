local Character = waitforchild(Workspace, getname(getlocalplayer()))
local Threshold = 1

local Adjustments = {
    {Ping = 100, Value = 0.6495},
    {Ping = 91, Value = 0.6640},
    {Ping = 80, Value = 0.6945}, 
    {Ping = 70, Value = 0.7205},
    {Ping = 62, Value = 0.7390},
    {Ping = 51, Value = 0.7985},
    {Ping = 40, Value = 0.8340},
    {Ping = 25, Value = 0.8625}
}

table.sort(Adjustments, function(a, b) return a.Ping > b.Ping end)

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
