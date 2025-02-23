local Workspace = findservice(Game, "Workspace")
local Player = getlocalplayer()
local Character = getname(Player)
local threshold = 1

local Adjustments = {
    [85] = 0.5075,
    [71] = 0.5375,
    [62] = 0.6205,
    [51] = 0.6795,
    [42] = 0.7055,
    [25] = 0.7525
}

local AdjustmentsTable = {}
for k in pairs(Adjustments) do
    table.insert(AdjustmentsTable, k)
end
table.sort(AdjustmentsTable, function(a, b) return a > b end)

local function GetAdjustments(ping)
    for _, value in ipairs(AdjustmentsTable) do
        if ping > value then
            return Adjustments[value]
        end
    end
end

local function Calculations()
    while true do
        local ping = getping()
        if ping then
            local value = GetAdjustments(ping)
            if value then
                threshold = value
            end
        end
        wait()
    end
end

local function ShotMeter()
    while true do
        local path = findfirstchild(Workspace, Character)
        local properties = findfirstchild(path, "Properties")
        local shotmeter = findfirstchild(properties, "ShotMeter")
        
        while true do
            local shotvalue = getvalue(shotmeter)
            if typeof(shotvalue) == "number" and shotvalue ~= 2 and shotvalue >= threshold then
                keyrelease(0x45)
            end
            wait()
        end
    end
end

spawn(Calculations)
spawn(ShotMeter)
