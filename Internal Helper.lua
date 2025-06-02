local Data = JSONDecode(httpget("https://offsets.ntgetwritewatch.workers.dev/offsets.json"))
local Offsets = {}
for k,v in pairs(Data) do
    if string.sub(v,1,2) == "0x" then
        Offsets[k] = v
    end
end

local Helper = {}

-- <Primitive>
Helper.Primitive = {
    Offset = Offsets.Primitive,
    Get = function(Userdata)
        return pointer_to_user_data(getmemoryvalue(Userdata, Helper.Primitive.Offset, "qword"))
    end
}

-- <Part>
Helper.getanchored = function(Part)
    local Primitive = Helper.Primitive.Get(Part)
    return getmemoryvalue(Primitive, Offsets.Anchored, "bool")
end

Helper.setanchored = function(Part, Value)
    local Primitive = Helper.Primitive.Get(Part)
    setmemoryvalue(Primitive, Offsets.Anchored, "bool", Value)
end

Helper.setpartsize = function(Part, Size)
    local Primitive = Helper.Primitive.Get(Part)
    setmemoryvalue(Primitive, Offsets.PartSize, "float", Size.X)
    setmemoryvalue(Primitive, Offsets.PartSize + 0x4, "float", Size.Y)
    setmemoryvalue(Primitive, Offsets.PartSize + 0x8, "float", Size.Z)
end

-- <Material>
Helper.Materials = {
    [2311] = "Rubber", [2310] = "Plaster", [2309] = "Leather", [2308] = "RoofShingles",
    [2307] = "ClayRoofTiles", [2306] = "CeramicTiles", [2305] = "Carpet", [2304] = "Cardboard",
    [2048] = "Water", [1792] = "Air", [1584] = "ForceField", [1568] = "Glass",
    [1552] = "Glacier", [1536] = "Ice", [1392] = "Salt", [1376] = "Asphalt",
    [1360] = "Ground", [1344] = "Mud", [1328] = "Snow", [1312] = "Fabric",
    [1296] = "Sand", [1284] = "LeafyGrass", [1280] = "Grass", [912] = "Sandstone",
    [864] = "Pebble", [880] = "Cobblestone", [896] = "Rock", [848] = "Brick",
    [836] = "Pavement", [832] = "Granite", [820] = "Limestone", [816] = "Concrete",
    [804] = "CrackedLava", [800] = "Slate", [788] = "Basalt", [784] = "Marble",
    [528] = "WoodPlanks", [512] = "Wood", [1088] = "Metal", [1072] = "Foil",
    [1056] = "DiamondPlate", [1040] = "CorrodedMetal", [288] = "Neon", [272] = "SmoothPlastic",
    [256] = "Plastic"
}

Helper.getmaterial = function(Part)
    local Primitive = Helper.Primitive.Get(Part)
    local Material = getmemoryvalue(Primitive, Offsets.MaterialType, "dword")
    return Helper.Materials[Material] or Material
end

Helper.setmaterial = function(Part, MaterialName)
    local Material
    for type,name in pairs(Helper.Materials) do
        if name:lower() == MaterialName:lower() then
            Material = type
            break
        end
    end
    if Material then
        local Primitive = Helper.Primitive.Get(Part)
        setmemoryvalue(Primitive, Offsets.MaterialType, "dword", Material)
    end
end

-- <Color>
Helper.BrickColors = {
    [0x00F3F3F2] = "White", [0x00A2A5A1] = "Grey", [0x0099E9F9] = "Light yellow", [0x009AC7D7] = "Brick yellow",
    [0x00B8DAC2] = "Light green (Mint)", [0x00C8BAE8] = "Light reddish violet", [0x00DBBB80] = "Pastel Blue", [0x004284CB] = "Light orange brown",
    [0x00698ECC] = "Nougat", [0x001C28C4] = "Bright red", [0x00A070C4] = "Med. reddish violet", [0x00AC690D] = "Bright blue",
    [0x0030CDF5] = "Bright yellow", [0x00324762] = "Earth orange", [0x00352A1B] = "Black", [0x006C6E6D] = "Dark grey",
    [0x00477F28] = "Dark green", [0x008CC4A1] = "Medium green", [0x009BCFF3] = "Lig. Yellowich orange", [0x004B974B] = "Bright green",
    [0x00355FA0] = "Dark orange", [0x00DECAC1] = "Light bluish violet", [0x00ECECEC] = "Transparent", [0x004B54CD] = "Tr. Red",
    [0x00F0DFC1] = "Tr. Lg blue", [0x00E8B67B] = "Tr. Blue", [0x008DF1F7] = "Tr. Yellow", [0x00E4D2B4] = "Light blue",
    [0x006C85D9] = "Tr. Flu. Reddish orange", [0x008DB684] = "Tr. Green", [0x0084F1F8] = "Tr. Flu. Green", [0x00DEE8EC] = "Phosph. White",
    [0x00B6C4EE] = "Light red", [0x007A86DA] = "Medium red", [0x00CA996E] = "Medium blue", [0x00B7C1C7] = "Light grey",
    [0x007C326B] = "Bright violet", [0x00409BE2] = "Br. yellowish orange", [0x004185DA] = "Bright orange", [0x009C8F00] = "Bright bluish green",
    [0x00435C68] = "Earth yellow", [0x00935443] = "Bright bluish violet", [0x00B1B7BF] = "Tr. Brown", [0x00AC7468] = "Medium bluish violet",
    [0x00C8ADE5] = "Tr. Medi. reddish violet", [0x003CD2C7] = "Med. yellowish green", [0x00AFA555] = "Med. bluish green", [0x00D5D7B7] = "Light bluish green",
    [0x0047BDA4] = "Br. yellowish green", [0x00A7E4D9] = "Lig. yellowish green", [0x0058ACE7] = "Med. yellowish orange", [0x004C6FD3] = "Br. reddish orange",
    [0x00783992] = "Bright reddish violet", [0x0092B8EA] = "Light orange", [0x00CBA5A5] = "Tr. Bright bluish violet", [0x0081BCDC] = "Gold",
    [0x00597AAE] = "Dark nougat", [0x00A8A39C] = "Silver", [0x003D73D5] = "Neon orange", [0x0056DDD8] = "Neon green",
    [0x009D8674] = "Sand blue", [0x00907C87] = "Sand violet", [0x006498E0] = "Medium orange", [0x00738A95] = "Sand yellow",
    [0x00563A20] = "Earth blue", [0x002D4627] = "Earth green", [0x00F7E2CF] = "Tr. Flu. Blue", [0x00A18879] = "Sand blue metallic",
    [0x00A38E95] = "Sand violet metallic", [0x00678793] = "Sand yellow metallic", [0x00575857] = "Dark grey metallic", [0x00321D16] = "Black metallic",
    [0x00ACA9AB] = "Light grey metallic", [0x00829078] = "Sand green", [0x00777995] = "Sand red", [0x002F2E7B] = "Dark red",
    [0x007BF6FF] = "Tr. Flu. Yellow", [0x00C2A4E1] = "Tr. Flu. Red", [0x00626C75] = "Gun metallic", [0x005B6997] = "Red flip/flop",
    [0x005584B4] = "Yellow flip/flop", [0x00888789] = "Silver flip/flop", [0x004BA9D7] = "Curry", [0x002ED6F9] = "Fire Yellow",
    [0x002DABE8] = "Flame yellowish orange", [0x00284069] = "Reddish brown", [0x002460CF] = "Flame reddish orange", [0x00A5A2A3] = "Medium stone grey",
    [0x00A46746] = "Royal blue", [0x008B4723] = "Dark Royal blue", [0x0085428E] = "Bright reddish lilac", [0x00625F63] = "Dark stone grey",
    [0x005D8A82] = "Lemon metalic", [0x00448EB0] = "Dark Curry", [0x00789570] = "Faded green", [0x00B5B579] = "Turquoise",
    [0x00E9C39F] = "Light Royal blue", [0x00B7816C] = "Medium Royal blue", [0x002A4C90] = "Rust", [0x00465C7C] = "Brown",
    [0x009F7096] = "Reddish lilac", [0x009B626B] = "Lilac", [0x00CEA9A7] = "Light lilac", [0x009862CD] = "Bright purple",
    [0x00C8ADE4] = "Light purple", [0x009590DC] = "Light pink", [0x00A0D5F0] = "Light brick yellow", [0x007FB8EB] = "Warm yellowish orange",
    [0x008DEAFD] = "Cool yellow", [0x00DDBB7D] = "Dove blue", [0x00752B34] = "Medium lilac", [0x00546D50] = "Slime green",
    [0x00695D5B] = "Smoky grey", [0x00B01000] = "Dark blue", [0x001D652C] = "Parsley green", [0x00AE7C52] = "Steel blue",
    [0x00825833] = "Storm blue", [0x00DC2A10] = "Lapis", [0x0085153D] = "Dark indigo", [0x00408E34] = "Sea green",
    [0x004C9A5B] = "Shamrock", [0x00ACA19F] = "Fossil", [0x00592259] = "Mulberry", [0x001D801F] = "Forest green",
    [0x00C0ADA9] = "Cadet blue", [0x00CF8909] = "Electric blue", [0x007B007B] = "Eggplant", [0x006B9C7C] = "Moss",
    [0x0085AB8A] = "Artichoke", [0x00B1C4B9] = "Sage green", [0x00D1CBCA] = "Ghost grey", [0x00DEDFDF] = "Quill grey",
    [0x00000097] = "Crimson", [0x00A6E5B1] = "Mint", [0x00DBC298] = "Baby blue", [0x00DC98FF] = "Carnation pink",
    [0x005959FF] = "Persimmon", [0x00000075] = "Maroon", [0x0038B8EF] = "Gold", [0x006DD9F8] = "Daisy orange",
    [0x00ECE7E7] = "Pearl", [0x00E4D4C7] = "Fog", [0x009494FF] = "Salmon", [0x006268BE] = "Terra Cotta",
    [0x00242456] = "Cocoa", [0x00C7E7F1] = "Wheat", [0x00BBF3FE] = "Buttermilk", [0x00D0B2E0] = "Mauve",
    [0x00BD90D4] = "Sunrise", [0x00555596] = "Tawny", [0x0096BED3] = "Cashmere", [0x00BCDCE2] = "Khaki",
    [0x00EAEAED] = "Lily white", [0x00DADAE9] = "Seashell", [0x003E3E88] = "Burgundy", [0x005D9BBC] = "Cork",
    [0x0078ACB7] = "Burlap", [0x00A3BFCA] = "Beige", [0x00B2B3BB] = "Oyster", [0x004B586C] = "Pine Cone",
    [0x004F84A0] = "Fawn brown", [0x00888995] = "Hurricane grey", [0x009EA8AB] = "Cloudy grey", [0x008394AF] = "Linen",
    [0x00666796] = "Copper", [0x00364256] = "Medium brown", [0x003F687E] = "Bronze", [0x005C6669] = "Flint",
    [0x00424C5A] = "Dark taupe", [0x0009396A] = "Burnt Sienna", [0x00F8F8F8] = "Institutional white", [0x00CDCDCD] = "Mid gray",
    [0x00111111] = "Really black", [0x000000FF] = "Really red", [0x0000B0FF] = "Deep orange", [0x00FF80B4] = "Alder",
    [0x004B4BA3] = "Dusty Rose", [0x0042BEC1] = "Olive", [0x0000FFFF] = "New Yeller", [0x00FF0000] = "Really blue",
    [0x00602000] = "Navy blue", [0x00B95421] = "Deep blue", [0x00ECAF04] = "Cyan", [0x000055AA] = "CGA brown",
    [0x00AA00AA] = "Magenta", [0x00CC66FF] = "Pink", [0x00D4EE12] = "Teal", [0x00FFFF00] = "Toothpaste",
    [0x0000FF00] = "Lime green", [0x00157D3A] = "Camo", [0x00648E7F] = "Grime", [0x009F5B8C] = "Lavender",
    [0x00FFDDAF] = "Pastel light blue", [0x00C9C9FF] = "Pastel orange", [0x00FFA7B1] = "Pastel violet", [0x00E9F39F] = "Pastel blue-green",
    [0x00CCFFCC] = "Pastel green", [0x00CCFFFF] = "Pastel yellow", [0x0099CCFF] = "Pastel brown", [0x00D12562] = "Royal purple",
    [0x00BF00FF] = "Hot pink"
}

Helper.getbrickcolor = function(Part)
    local Color = getmemoryvalue(Part, 0x1A8, "dword")
    return Helper.BrickColors[Color] or Color
end

Helper.setbrickcolor = function(Part, Color)
    for k,v in pairs(Helper.BrickColors) do
        if v == Color then
            setmemoryvalue(Part, 0x1A8, "dword", k)
            break
        end
    end
end

-- <Humanoid>
Helper.getrigtype = function(Humanoid)
    local RigType = getmemoryvalue(Humanoid, Offsets.RigType, "dword")
    return RigType == 1 and "R15" or "R6"
end

Helper.gethipheight = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.HipHeight, "float")
end

Helper.sethipheight = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.HipHeight, "float", Value)
end

Helper.getjumppower = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.JumpPower, "float")
end

Helper.setjumppower = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.JumpPower, "float", Value)
end

Helper.getwalkspeed = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.WalkSpeed, "float")
end

Helper.setwalkspeed = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.WalkSpeed, "float", Value)
end

Helper.getwalkspeedcheck = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.WalkSpeedCheck, "float")
end

Helper.setwalkspeedcheck = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.WalkSpeedCheck, "float", Value)
end

Helper.getmaxslopeangle = function(Humanoid)
    return getmemoryvalue(Humanoid, Offsets.MaxSlopeAngle, "float")
end

Helper.setmaxslopeangle = function(Humanoid, Value)
    setmemoryvalue(Humanoid, Offsets.MaxSlopeAngle, "float", Value)
end

Helper.getsit = function(Humanoid)
    local Sit = { [1099511628033] = "False", [282574488338689] = "True" }
    return Sit[getmemoryvalue(Humanoid, Offsets.Sit, "qword")]
end

Helper.setsit = function(Humanoid, Value)
    local Sit = { ["False"] = 1099511628033, ["True"] = 282574488338689 }
    setmemoryvalue(Humanoid, Offsets.Sit, "qword", Sit[Value])
end

-- <Camera>
Helper.CameraTypes = {
    [0] = "Fixed", [1] = "Attach", [2] = "Watch", [3] = "Track",
    [4] = "Follow", [5] = "Custom", [6] = "Scriptable", [7] = "Orbital", [8] = "Num"
}

Helper.getcameratype = function(Camera)
    local CameraType = getmemoryvalue(Camera, Offsets.CameraType, "dword")
    return Helper.CameraTypes[CameraType] or CameraType
end

Helper.setcameratype = function(Camera, TypeName)
    local CameraType
    for type,name in pairs(Helper.CameraTypes) do
        if name:lower() == TypeName:lower() then
            CameraType = type
            break
        end
    end
    if CameraType then
        setmemoryvalue(Camera, Offsets.CameraType, "dword", CameraType)
    end
end

Helper.setfov = function(Camera, Float)
    Float = math.clamp(Float, 1, 180)
    local Fov = Float / 57.2958
    setmemoryvalue(Camera, Offsets.FOV, "float", Fov)
end

-- <Frame>
Helper.getframeposition = function(Frame)
    return {
        X = getmemoryvalue(Frame, Offsets.FramePositionX, "float"),
        Y = getmemoryvalue(Frame, Offsets.FramePositionY, "float")
    }
end

Helper.setframeposition = function(Frame, Position)
    setmemoryvalue(Frame, Offsets.FramePositionX, "float", Position.X)
    setmemoryvalue(Frame, Offsets.FramePositionY, "float", Position.Y)
end

Helper.getframeoffset = function(Frame)
    return {
        X = getmemoryvalue(Frame, 0x3AC, "dword"),
        Y = getmemoryvalue(Frame, 0x3B4, "dword")
    }
end

Helper.setframeoffset = function(Frame, Offset)
    setmemoryvalue(Frame, 0x3AC, "dword", Offset.X)
    setmemoryvalue(Frame, 0x3B4, "dword", Offset.Y)
end

Helper.getframerotation = function(Frame)
    return getmemoryvalue(Frame, Offsets.FrameRotation, "float")
end

Helper.setframerotation = function(Frame, Rotation)
    setmemoryvalue(Frame, Offsets.FrameRotation, "float", Rotation)
end

Helper.getframesize = function(Frame)
    return {
        X = getmemoryvalue(Frame, Offsets.FrameSizeX, "float"),
        Y = getmemoryvalue(Frame, Offsets.FrameSizeY, "float")
    }
end

Helper.setframesize = function(Frame, Size)
    setmemoryvalue(Frame, Offsets.FrameSizeX, "float", Size.X)
    setmemoryvalue(Frame, Offsets.FrameSizeY, "float", Size.Y)
end

-- <Team>
Helper.TeamColors = {
    [1] = "White", [2] = "Grey", [3] = "Light yellow", [5] = "Brick yellow",
    [6] = "Light green (Mint)", [9] = "Light reddish violet", [11] = "Pastel Blue",
    [12] = "Light orange brown", [18] = "Nougat", [21] = "Bright blue",
    [22] = "Bright red", [23] = "Dark stone grey", [24] = "Light stone grey",
    [25] = "Light blue", [26] = "Black", [28] = "Dark green", [29] = "Medium green",
    [36] = "Lime green", [37] = "Sand blue", [38] = "Sand violet", [39] = "Medium orange",
    [40] = "Sand yellow", [41] = "Earth blue", [42] = "Earth green", [43] = "Tr. Fluorescent Red",
    [44] = "Medium blue", [45] = "Tr. Fluorescent Blue", [47] = "Tr. Fluorescent Yellow",
    [48] = "Tr. Fluorescent Green", [100] = "Bright orange", [101] = "Bright bluish green",
    [102] = "Bright yellow", [103] = "Bright reddish violet", [104] = "Bright blue-violet",
    [105] = "Br. yellowish orange", [106] = "Bright green", [107] = "Bright reddish orange",
    [108] = "Bright red", [110] = "Bright violet", [111] = "Bright yellowish green",
    [112] = "Bright reddish violet", [113] = "Light orange", [115] = "Cool yellow",
    [116] = "Dove blue", [118] = "Medium lilac", [119] = "Slime green", [120] = "Medium blue",
    [121] = "Medium green", [123] = "Light reddish violet", [124] = "Light orange brown",
    [125] = "Nougat", [126] = "Bright blue", [127] = "Bright reddish violet",
    [128] = "Light orange", [131] = "Sand violet", [133] = "Medium violet",
    [134] = "Tr. Mediun blue", [135] = "Tr. Light blue", [136] = "Tr. Bright green",
    [137] = "Tr. Bright orange", [138] = "Tr. Bright violet", [140] = "Tr. Yellow",
    [141] = "Earth green", [143] = "Tr. Fluorescent Red", [145] = "Dark stone grey",
    [146] = "Medium stone grey", [147] = "Light stone grey", [148] = "Light stone grey",
    [150] = "Institutional white", [151] = "Mid gray", [153] = "Really black",
    [154] = "Really red", [155] = "Deep orange", [156] = "Alder", [157] = "Dusty Rose",
    [158] = "Olive", [168] = "Sand blue", [176] = "Sand violet", [178] = "Medium orange",
    [179] = "Sand yellow", [180] = "Earth blue", [190] = "Earth green", [194] = "Medium stone grey",
    [199] = "Dark stone grey", [208] = "Light stone grey", [209] = "Light stone grey",
    [216] = "Institutional white", [217] = "Mid gray", [218] = "Really black",
    [219] = "Really red", [220] = "Deep orange", [221] = "Alder", [222] = "Dusty Rose",
    [223] = "Olive", [1001] = "Dark stone grey", [1002] = "Medium stone grey",
    [1003] = "Light stone grey", [1004] = "Really black", [1005] = "Really red",
    [1006] = "Deep orange", [1007] = "Alder", [1008] = "Dusty Rose", [1009] = "Olive",
    [1010] = "New Yeller", [1011] = "Really blue", [1012] = "Deep blue", [1013] = "Cyan",
    [1014] = "Light blue", [1015] = "Lime green", [1016] = "Pink", [1017] = "Gold",
    [1018] = "Pastel Blue-Green", [1019] = "Medium stone grey", [1020] = "Camo",
    [1021] = "Grime", [1022] = "Lavender", [1023] = "Pastel Light Blue", [1024] = "Pastel Orange",
    [1025] = "Pastel Violet", [1026] = "Pastel Blue", [1027] = "Pastel Green", [1028] = "Pastel Yellow",
    [1029] = "Pastel Brown", [1030] = "Royal purple", [1031] = "Hot pink", [1032] = "Really blue"
}

Helper.getteamcolor = function(Team)
    local ColorName = getmemoryvalue(Team, Offsets.TeamColor, "dword")
    return Helper.TeamColors[ColorName]
end

-- <Proximity Prompt>
Helper.getproximityprompt = function(ProximityPrompt)
    return getmemoryvalue(ProximityPrompt, Offsets.ProximityPromptEnabled, "bool")
end

Helper.setproximityprompt = function(ProximityPrompt, Value)
    setmemoryvalue(ProximityPrompt, Offsets.ProximityPromptEnabled, "bool", Value)
end

Helper.getproximitypromptholdduration = function(ProximityPrompt)
    return getmemoryvalue(ProximityPrompt, Offsets.ProximityPromptHoldDuraction, "float")
end

Helper.setproximitypromptholdduration = function(ProximityPrompt, Value)
    setmemoryvalue(ProximityPrompt, Offsets.ProximityPromptHoldDuraction, "float", Value)
end

Helper.getproximitypromptmaxdistance = function(ProximityPrompt)
    return getmemoryvalue(ProximityPrompt, Offsets.ProximityPromptMaxActivationDistance, "float")
end

Helper.setproximitypromptmaxdistance = function(ProximityPrompt, Value)
    setmemoryvalue(ProximityPrompt, Offsets.ProximityPromptMaxActivationDistance, "float", Value)
end

-- <Name>
Helper.setname = function(Instance, Name)
    setmemoryvalue(pointer_to_user_data(getmemoryvalue(Instance, Offsets.Name, "qword")), 0x0, "string", Name)
end

-- <Lighting>
Helper.getfogend = function(Lighting)
    return getmemoryvalue(Lighting, Offsets.FogEnd, "float")
end

Helper.setfogend = function(Lighting, Value)
    setmemoryvalue(Lighting, Offsets.FogEnd, "float", Value)
end

Helper.getfogstart = function(Lighting)
    return getmemoryvalue(Lighting, Offsets.FogStart, "float")
end

Helper.setfogstart = function(Lighting, Value)
    setmemoryvalue(Lighting, Offsets.FogStart, "float", Value)
end

Helper.getfogcolor = function(Lighting)
    return {
        R = getmemoryvalue(Lighting, Offsets.FogColor, "float") * 255,
        G = getmemoryvalue(Lighting, Offsets.FogColor + 0x4, "float") * 255,
        B = getmemoryvalue(Lighting, Offsets.FogColor + 0x8, "float") * 255
    }
end

Helper.setfogcolor = function(Lighting, Color)
    setmemoryvalue(Lighting, Offsets.FogColor, "float", Color.R / 255)
    setmemoryvalue(Lighting, Offsets.FogColor + 0x4, "float", Color.G / 255)
    setmemoryvalue(Lighting, Offsets.FogColor + 0x8, "float", Color.B / 255)
end

Helper.getoutdoorambient = function(Lighting)
    return {
        R = getmemoryvalue(Lighting, Offsets.OutdoorAmbient, "float") * 255,
        G = getmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x4, "float") * 255,
        B = getmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x8, "float") * 255
    }
end

Helper.setoutdoorambient = function(Lighting, Color)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient, "float", Color.R / 255)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x4, "float", Color.G / 255)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x8, "float", Color.B / 255)
end

Helper.getclocktime = function(Lighting)
    local Time = getmemoryvalue(Lighting, Offsets.ClockTime, "qword")
    local Hours = math.floor(Time / 3600000000)
    local Minutes = math.floor((Time % 3600000000) / 60000000)
    local Seconds = math.floor((Time % 60000000) / 1000000)
    return string.format("%02d:%02d:%02d", Hours, Minutes, Seconds)
end

Helper.setclocktime = function(Lighting, Time)
    local Hours, Minutes, Seconds = string.match(Time, "(%d+):(%d+):(%d+)")
    local Time = (tonumber(Hours) * 3600000000) + (tonumber(Minutes) * 60000000) + (tonumber(Seconds) * 1000000)
    setmemoryvalue(Lighting, Offsets.ClockTime, "qword", Time)
end

-- <Tool>
Helper.gettoolgripposition = function(Tool)
    return {
        X = getmemoryvalue(Tool, Offsets.Tool_Grip_Position, "float"),
        Y = getmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x4, "float"),
        Z = getmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x8, "float")
    }
end

Helper.settoolgripposition = function(Tool, Position)
    setmemoryvalue(Tool, Offsets.Tool_Grip_Position, "float", Position.X)
    setmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x4, "float", Position.Y)
    setmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x8, "float", Position.Z)
end

-- <Sound>
Helper.getsoundid = function(Sound)
    return getmemoryvalue(Sound, Offsets.SoundId, "qword")
end

-- <Animation>
Helper.getanimationid = function(Animation)
    return getmemoryvalue(Animation, Offsets.AnimationId, "qword")
end

return Helper
