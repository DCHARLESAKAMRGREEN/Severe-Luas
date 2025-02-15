local workspace = findservice(Game, "Workspace")
local player = getlocalplayer()
local character = getname(player)
local threshold = 1

local adjustments = {
    [75] = 0.5735,
    [62] = 0.6375,
    [51] = 0.71,
    [44] = 0.7495,
    [36] = 0.7875
}

local adjustmentstable = {}
for k in pairs(adjustments) do
    table.insert(adjustmentstable, k)
end
table.sort(adjustmentstable, function(a, b) return a > b end)

local function getadjustments(ping)
    for _, value in ipairs(adjustmentstable) do
        if ping > value then
            return adjustments[value]
        end
    end
end

local function Calculations()
    while true do
        local ping = getping()
        if ping then
            local value = getadjustments(ping)
            if value then
                threshold = value
            end
        end
        wait(0.1)
    end
end

local function ShotMeter(path)
    local properties = findfirstchild(path, "Properties")
    if not properties then return end

    local shotmeter = findfirstchild(properties, "ShotMeter")
    if not shotmeter then return end

    while true do
        local shotvalue = getvalue(shotmeter)
        if typeof(shotvalue) == "number" and shotvalue ~= 2 and shotvalue >= threshold then
            keyrelease(0x45)
        end
        wait()
    end
end

local function Rescan()
    local lastpath
    while true do
        local path = findfirstchild(workspace, character)
        if path and path ~= lastpath then
            lastpath = path
            spawn(function() ShotMeter(path) end)
        end
        wait(1)
    end
end

spawn(Calculations)
spawn(Rescan)