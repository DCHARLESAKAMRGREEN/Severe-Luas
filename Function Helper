-- <Offsets>
local Data = JSONDecode(httpget("https://offsets.ntgetwritewatch.workers.dev/offsets.json"))
local Offsets = {}
for k,v in pairs(Data) do
    if string.sub(v,1,2) == "0x" then
        Offsets[k] = v
    end
end

-- <Primitive>
Primitive = {
    Offset = Offsets.Primitive,
    Get = function(Userdata)
        return pointer_to_user_data(getmemoryvalue(Userdata, Primitive.Offset, "qword"))
    end
}

-- // Part

-- <Anchored>
getanchored = function(Part)
    local Primitive = Primitive.Get(Part)
    return getmemoryvalue(Primitive, Offsets.Anchored, "bool")
end

setanchored = function(Part, Value)
    local Primitive = Primitive.Get(Part)
    setmemoryvalue(Primitive, Offsets.Anchored, "bool", Value)
end

-- <Part Size>
getpartsize = function(Part)
    local Primitive = Primitive.Get(Part)
    local SizeX = getmemoryvalue(Primitive, Offsets.PartSize, "float")
    local SizeY = getmemoryvalue(Primitive, Offsets.PartSize + 0x4, "float")
    local SizeZ = getmemoryvalue(Primitive, Offsets.PartSize + 0x8, "float")
    return {X = SizeX, Y = SizeY, Z = SizeZ}
end

setpartsize = function(Part, Size)
    local Primitive = Primitive.Get(Part)
    setmemoryvalue(Primitive, Offsets.PartSize, "float", Size.X)
    setmemoryvalue(Primitive, Offsets.PartSize + 0x4, "float", Size.Y)
    setmemoryvalue(Primitive, Offsets.PartSize + 0x8, "float", Size.Z)
end

-- <Material>
local Materials = {
    [2311] = "Rubber",
    [2310] = "Plaster",
    [2309] = "Leather",
    [2308] = "RoofShingles",
    [2307] = "ClayRoofTiles",
    [2306] = "CeramicTiles",
    [2305] = "Carpet",
    [2304] = "Cardboard",
    [2048] = "Water",
    [1792] = "Air",
    [1584] = "ForceField",
    [1568] = "Glass",
    [1552] = "Glacier",
    [1536] = "Ice",
    [1392] = "Salt",
    [1376] = "Asphalt",
    [1360] = "Ground",
    [1344] = "Mud",
    [1328] = "Snow",
    [1312] = "Fabric",
    [1296] = "Sand",
    [1284] = "LeafyGrass",
    [1280] = "Grass",
    [912] = "Sandstone",
    [864] = "Pebble",
    [880] = "Cobblestone",
    [896] = "Rock",
    [848] = "Brick",
    [836] = "Pavement",
    [832] = "Granite",
    [820] = "Limestone",
    [816] = "Concrete",
    [804] = "CrackedLava",
    [800] = "Slate",
    [788] = "Basalt",
    [784] = "Marble",
    [528] = "WoodPlanks",
    [512] = "Wood",
    [1088] = "Metal",
    [1072] = "Foil",
    [1056] = "DiamondPlate",
    [1040] = "CorrodedMetal",
    [288] = "Neon",
    [272] = "SmoothPlastic",
    [256] = "Plastic"
}

getmaterial = function(Part)
    local Primitive = Primitive.Get(Part)
    local Material = getmemoryvalue(Primitive, Offsets.MaterialType, "dword")
    return Materials[Material] or Material
end

setmaterial = function(Part, MaterialName)
    local Material
    for type,name in pairs(Materials) do
        if name:lower() == MaterialName:lower() then
            Material = type
            break
        end
    end
    
    if Material then
        local Primitive = Primitive.Get(Part)
        setmemoryvalue(Primitive, Offsets.MaterialType, "dword", Material)
    end
end

-- //Humanoid

-- <Rig Type>
getrigtype = function(Humanoid)
    local RigType = getmemoryvalue(Humanoid, Offsets.RigType, "dword")
    return RigType == 1 and "R15" or "R6"
end

-- <Hip Height>
gethipheight = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.HipHeight, "float")
end

sethipheight = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.HipHeight, "float", Value)
end

-- <Jump Power>
getjumppower = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.JumpPower, "float")
end

setjumppower = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.JumpPower, "float", Value)
end

-- <Walk Speed>
getwalkspeed = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.WalkSpeed, "float")
end

setwalkspeed = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.WalkSpeed, "float", Value)
end

getwalkspeedcheck = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.WalkSpeedCheck, "float")
end

setwalkspeedcheck = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.WalkSpeedCheck, "float", Value)
end

-- <Max Slope Angle>
getmaxslopeangle = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.MaxSlopeAngle, "float")
end

setmaxslopeangle = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.MaxSlopeAngle, "float", Value)
end

-- <Sit>
getsit = function(Humanoid)
    local Sit = {
        [1099511628033] = "False",
        [282574488338689] = "True"
    }
    return Sit[getmemoryvalue(Humanoid, Offsets.Sit, "qword")]
end

setsit = function(Humanoid, Value)
    local Sit = {
        ["False"] = 1099511628033,
        ["True"] = 282574488338689
    }
    setmemoryvalue(Humanoid, Offsets.Sit, "qword", Sit[Value])
end

-- // Camera

-- <Camera Type>
local CameraTypes = {
    [0] = "Fixed",
    [1] = "Attach",
    [2] = "Watch",
    [3] = "Track",
    [4] = "Follow",
    [5] = "Custom",
    [6] = "Scriptable",
    [7] = "Orbital",
    [8] = "Num"
}

getcameratype = function(Camera)
    local CameraType = getmemoryvalue(Camera, Offsets.CameraType, "dword")
    return CameraTypes[CameraType] or CameraType
end

setcameratype = function(Camera, TypeName)
    local CameraType
    for type,name in pairs(CameraTypes) do
        if name:lower() == TypeName:lower() then
            CameraType = type
            break
        end
    end
    
    if CameraType then
        setmemoryvalue(Camera, Offsets.CameraType, "dword", CameraType)
    end
end

-- <FOV>
setfov = function(Camera, Float)
    Float = math.clamp(Float, 1, 180)
    local Fov = Float / 57.2958
    setmemoryvalue(Camera, Offsets.FOV, "float", Fov)
end

-- // Frame

-- <Frame Position>
getframeposition = function(Frame)
    return {
        X = getmemoryvalue(Frame, Offsets.FramePositionX, "float"),
        Y = getmemoryvalue(Frame, Offsets.FramePositionY, "float")
    }
end

setframeposition = function(Frame, Position)
    setmemoryvalue(Frame, Offsets.FramePositionX, "float", Position.X)
    setmemoryvalue(Frame, Offsets.FramePositionY, "float", Position.Y)
end

-- <Frame Offset>
getframeoffset = function(Frame)
    return {
        X = getmemoryvalue(Frame, 0x3AC, "dword"),
        Y = getmemoryvalue(Frame, 0x3B4, "dword")
    }
end

setframeoffset = function(Frame, Offset)
    setmemoryvalue(Frame, 0x3AC, "dword", Offset.X)
    setmemoryvalue(Frame, 0x3B4, "dword", Offset.Y)
end

-- <Frame Rotation>
getframerotation = function(Frame)
    return getmemoryvalue(Frame, Offsets.FrameRotation, "float")
end

setframerotation = function(Frame, Rotation)
    setmemoryvalue(Frame, Offsets.FrameRotation, "float", Rotation)
end

-- <Frame Size>
getframesize = function(Frame)
    return {
        X = getmemoryvalue(Frame, Offsets.FrameSizeX, "float"),
        Y = getmemoryvalue(Frame, Offsets.FrameSizeY, "float")
    }
end

setframesize = function(Frame, Size)
    setmemoryvalue(Frame, Offsets.FrameSizeX, "float", Size.X)
    setmemoryvalue(Frame, Offsets.FrameSizeY, "float", Size.Y)
end

-- // Team

-- <Team Color>
local TeamColors = {
    [1] = "White",
    [2] = "Grey",
    [3] = "Light yellow",
    [5] = "Brick yellow",
    [6] = "Light green (Mint)",
    [9] = "Light reddish violet",
    [11] = "Pastel Blue",
    [12] = "Light orange brown",
    [18] = "Nougat",
    [21] = "Bright blue",
    [22] = "Bright red",
    [23] = "Dark stone grey",
    [24] = "Light stone grey",
    [25] = "Light blue",
    [26] = "Black",
    [28] = "Dark green",
    [29] = "Medium green",
    [36] = "Lime green",
    [37] = "Sand blue",
    [38] = "Sand violet",
    [39] = "Medium orange",
    [40] = "Sand yellow",
    [41] = "Earth blue",
    [42] = "Earth green",
    [43] = "Tr. Fluorescent Red",
    [44] = "Medium blue",
    [45] = "Tr. Fluorescent Blue",
    [47] = "Tr. Fluorescent Yellow",
    [48] = "Tr. Fluorescent Green",
    [100] = "Bright orange",
    [101] = "Bright bluish green",
    [102] = "Bright yellow",
    [103] = "Bright reddish violet",
    [104] = "Bright blue-violet",
    [105] = "Br. yellowish orange",
    [106] = "Bright green",
    [107] = "Bright reddish orange",
    [108] = "Bright red",
    [110] = "Bright violet",
    [111] = "Bright yellowish green",
    [112] = "Bright reddish violet",
    [113] = "Light orange",
    [115] = "Cool yellow",
    [116] = "Dove blue",
    [118] = "Medium lilac",
    [119] = "Slime green",
    [120] = "Medium blue",
    [121] = "Medium green",
    [123] = "Light reddish violet",
    [124] = "Light orange brown",
    [125] = "Nougat",
    [126] = "Bright blue",
    [127] = "Bright reddish violet",
    [128] = "Light orange",
    [131] = "Sand violet",
    [133] = "Medium violet",
    [134] = "Tr. Mediun blue",
    [135] = "Tr. Light blue",
    [136] = "Tr. Bright green",
    [137] = "Tr. Bright orange",
    [138] = "Tr. Bright violet",
    [140] = "Tr. Yellow",
    [141] = "Earth green",
    [143] = "Tr. Fluorescent Red",
    [145] = "Dark stone grey",
    [146] = "Medium stone grey",
    [147] = "Light stone grey",
    [148] = "Light stone grey",
    [150] = "Institutional white",
    [151] = "Mid gray",
    [153] = "Really black",
    [154] = "Really red",
    [155] = "Deep orange",
    [156] = "Alder",
    [157] = "Dusty Rose",
    [158] = "Olive",
    [168] = "Sand blue",
    [176] = "Sand violet",
    [178] = "Medium orange",
    [179] = "Sand yellow",
    [180] = "Earth blue",
    [190] = "Earth green",
    [194] = "Medium stone grey",
    [199] = "Dark stone grey",
    [208] = "Light stone grey",
    [209] = "Light stone grey",
    [216] = "Institutional white",
    [217] = "Mid gray",
    [218] = "Really black",
    [219] = "Really red",
    [220] = "Deep orange",
    [221] = "Alder",
    [222] = "Dusty Rose",
    [223] = "Olive",
    [1001] = "Dark stone grey",
    [1002] = "Medium stone grey",
    [1003] = "Light stone grey",
    [1004] = "Really black",
    [1005] = "Really red",
    [1006] = "Deep orange",
    [1007] = "Alder",
    [1008] = "Dusty Rose",
    [1009] = "Olive",
    [1010] = "New Yeller",
    [1011] = "Really blue",
    [1012] = "Deep blue",
    [1013] = "Cyan",
    [1014] = "Light blue",
    [1015] = "Lime green",
    [1016] = "Pink",
    [1017] = "Gold",
    [1018] = "Pastel Blue-Green",
    [1019] = "Medium stone grey",
    [1020] = "Camo",
    [1021] = "Grime",
    [1022] = "Lavender",
    [1023] = "Pastel Light Blue",
    [1024] = "Pastel Orange",
    [1025] = "Pastel Violet",
    [1026] = "Pastel Blue",
    [1027] = "Pastel Green",
    [1028] = "Pastel Yellow",
    [1029] = "Pastel Brown",
    [1030] = "Royal purple",
    [1031] = "Hot pink",
    [1032] = "Really blue"
}

getteamcolor = function(Team)
    local Color = getmemoryvalue(Team, Offsets.TeamColor, "dword")
    return TeamColors[Color] or Color
end

-- <Proximity Prompt>
getproximityprompt = function(ProximityPrompt)
    return getmemoryvalue(ProximityPrompt, Offsets.ProximityPromptEnabled, "bool")
end

setproximityprompt = function(ProximityPrompt, Value)
    setmemoryvalue(ProximityPrompt, Offsets.ProximityPromptEnabled, "bool", Value)
end

getproximitypromptholdduration = function(ProximityPrompt)
    return getmemoryvalue(ProximityPrompt, Offsets.ProximityPromptHoldDuraction, "float")
end

setproximitypromptholdduration = function(ProximityPrompt, Value)
    setmemoryvalue(ProximityPrompt, Offsets.ProximityPromptHoldDuraction, "float", Value)
end

getproximitypromptmaxdistance = function(ProximityPrompt)
    return getmemoryvalue(ProximityPrompt, Offsets.ProximityPromptMaxActivationDistance, "float")
end

setproximitypromptmaxdistance = function(ProximityPrompt, Value)
    setmemoryvalue(ProximityPrompt, Offsets.ProximityPromptMaxActivationDistance, "float", Value)
end

-- <Name>
setname = function(Instance, Name)
    setmemoryvalue(pointer_to_user_data(getmemoryvalue(Instance, Offsets.Name, "qword")), 0x0, "string", Name)
end

-- // Lighting

-- <Fog>
getfogend = function(Lighting)
    return getmemoryvalue(Lighting, Offsets.FogEnd, "float")
end

setfogend = function(Lighting, Value)
    setmemoryvalue(Lighting, Offsets.FogEnd, "float", Value)
end

getfogstart = function(Lighting)
    return getmemoryvalue(Lighting, Offsets.FogStart, "float")
end

setfogstart = function(Lighting, Value)
    setmemoryvalue(Lighting, Offsets.FogStart, "float", Value)
end

getfogcolor = function(Lighting)
    return {
        R = getmemoryvalue(Lighting, Offsets.FogColor, "float") * 255,
        G = getmemoryvalue(Lighting, Offsets.FogColor + 0x4, "float") * 255,
        B = getmemoryvalue(Lighting, Offsets.FogColor + 0x8, "float") * 255
    }
end

setfogcolor = function(Lighting, Color)
    setmemoryvalue(Lighting, Offsets.FogColor, "float", Color.R / 255)
    setmemoryvalue(Lighting, Offsets.FogColor + 0x4, "float", Color.G / 255)
    setmemoryvalue(Lighting, Offsets.FogColor + 0x8, "float", Color.B / 255)
end

-- <Outdoor Ambient>
getoutdoorambient = function(Lighting)
    return {
        R = getmemoryvalue(Lighting, Offsets.OutdoorAmbient, "float") * 255,
        G = getmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x4, "float") * 255,
        B = getmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x8, "float") * 255
    }
end

setoutdoorambient = function(Lighting, Color)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient, "float", Color.R / 255)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x4, "float", Color.G / 255)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x8, "float", Color.B / 255)
end

-- <Clock Time>
getclocktime = function(Lighting)
    local Time = getmemoryvalue(Lighting, Offsets.ClockTime, "qword")
    local Hours = math.floor(Time / 3600000000)
    local Minutes = math.floor((Time % 3600000000) / 60000000)
    local Seconds = math.floor((Time % 60000000) / 1000000)
    return string.format("%02d:%02d:%02d", Hours, Minutes, Seconds)
end

setclocktime = function(Lighting, Time)
    local Hours, Minutes, Seconds = string.match(Time, "(%d+):(%d+):(%d+)")
    local Time = (tonumber(Hours) * 3600000000) + (tonumber(Minutes) * 60000000) + (tonumber(Seconds) * 1000000)
    setmemoryvalue(Lighting, Offsets.ClockTime, "qword", Time)
end

-- // Tool
-- <Tool Grip Position>
gettoolgripposition = function(Tool)
    return {
        X = getmemoryvalue(Tool, Offsets.Tool_Grip_Position, "float"),
        Y = getmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x4, "float"),
        Z = getmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x8, "float")
    }
end

settoolgripposition = function(Tool, Position)
    setmemoryvalue(Tool, Offsets.Tool_Grip_Position, "float", Position.X)
    setmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x4, "float", Position.Y)
    setmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x8, "float", Position.Z)
end

-- <Sound>
getsoundid = function(Sound)
    return getmemoryvalue(Sound, Offsets.SoundId, "qword")
end

-- <Animation>
getanimationid = function(Animation)
    return getmemoryvalue(Animation, Offsets.AnimationId, "qword")
end
