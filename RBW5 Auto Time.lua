local Workspace = findservice(Game, "Workspace")
local Player = getlocalplayer()
local Character = getname(Player)
local Threshold = 1

local Adjustments = {
    {Ping = 95, Value = 0.4500},
    {Ping = 85, Value = 0.5400},
    {Ping = 70, Value = 0.5675},
    {Ping = 62, Value = 0.6185},
    {Ping = 52, Value = 0.6950},
    {Ping = 40, Value = 0.7295},
    {Ping = 25, Value = 0.7495}
}

table.sort(Adjustments, function(a, b) return a.Ping > b.Ping end)

local Properties = findfirstchild(findfirstchild(Workspace, Character), "Properties")
local ShotMeter = findfirstchild(Properties, "ShotMeter")

while true do
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
    if typeof(ShotValue) == "number" and ShotValue ~= 2 and ShotValue >= Threshold then
        keyrelease(0x45)
    end

    wait()
end
