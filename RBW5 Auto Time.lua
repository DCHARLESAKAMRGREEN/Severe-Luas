if getgameid() ~= 5462326700 then return end

local Threshold = 1

local Adjustments = {
    {Ping = 100, Value = 0.6515},
    {Ping = 90, Value = 0.6653},
    {Ping = 80, Value = 0.6960}, 
    {Ping = 70, Value = 0.7240},
    {Ping = 60, Value = 0.7430},
    {Ping = 50, Value = 0.8075},
    {Ping = 40, Value = 0.8365},
    {Ping = 25, Value = 0.86226}
}

table.sort(Adjustments, function(A, B) return A.Ping > B.Ping end)

local Name
local Character
local Properties
local ShotMeter

thread.create("Rescan", function()
    while true do
        local Player = getlocalplayer()
        if Player then
            Name = getname(Player)
        else
            Name = nil
            Character = nil
            Properties = nil
            ShotMeter = nil
            wait(1)
            continue
        end

        if not Character and Name then
            Character = findfirstchild(Workspace, Name)
            if not Character then
                wait(1)
                continue
            end
        end

        if Character and not Properties then
            Properties = findfirstchild(Character, "Properties")
            if not Properties then
                wait(1)
                continue
            end
        end

        if Properties and not ShotMeter then
            ShotMeter = findfirstchild(Properties, "ShotMeter")
            if not ShotMeter then
                wait(1)
                continue
            end
        end

        if not (Name and Character and Properties and ShotMeter) then
            if not findfirstchild(Workspace, Name) then
                Character = nil
                Properties = nil
                ShotMeter = nil
            end
        end

        wait(0.5)
    end
end)

thread.create("Ping", function()
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
        wait()
    end
end)

thread.create("Autotime", function()
    while true do
        if ShotMeter then
            local ShotValue = getvalue(ShotMeter)
            if ShotValue and ShotValue ~= 2 and ShotValue >= Threshold then
                keyrelease(0x45)
            end
        end
        wait()
    end
end)
