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
    local Primitive = Helper.Primitive.get(Part)
    return getmemoryvalue(Primitive, Offsets.Anchored, "bool")
end

Helper.setanchored = function(Part, Value)
    local Primitive = Helper.Primitive.get(Part)
    setmemoryvalue(Primitive, Offsets.Anchored, "bool", Value)
end

Helper.setpartsize = function(Part, Size)
    local Primitive = Helper.Primitive.get(Part)
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
    local Primitive = Helper.Primitive.get(Part)
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
        local Primitive = Helper.Primitive.get(Part)
        setmemoryvalue(Primitive, Offsets.MaterialType, "dword", Material)
    end
end

-- <Color>
Helper.brickColors = {
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
    return Helper.brickColors[Color] or Color
end

Helper.setbrickcolor = function(Part, Color)
    for k,v in pairs(Helper.brickColors) do
        if v == Color then
            setmemoryvalue(Part, 0x1A8, "dword", k)
            break
        end
    end
end

Helper.getcolor = function(Part)
    local Color = getmemoryvalue(Part, 0x1A8, "dword")
    local r = bit32.band(Color, 0xFF)
    local g = bit32.band(bit32.rshift(Color, 8), 0xFF)
    local b = bit32.band(bit32.rshift(Color, 16), 0xFF)
    return {r = r, g = g, b = b}
end

Helper.setcolor = function(Part, Color)
    local Dword = bit32.bor(
        math.clamp(Color.r, 0, 255),
        bit32.lshift(math.clamp(Color.g, 0, 255), 8),
        bit32.lshift(math.clamp(Color.b, 0, 255), 16)
    )
    setmemoryvalue(Part, 0x1A8, "dword", Dword)
    return Color.r, Color.g, Color.b
end

-- <Humanoid>
Helper.getrigtype = function(Humanoid)
    local RigType = getmemoryvalue(Humanoid, Offsets.rigType, "dword")
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

Helper.getmovedirection = function(Humanoid)
    local x = getmemoryvalue(Humanoid, 0x160, "float")
    local y = getmemoryvalue(Humanoid, 0x164, "float")
    local z = getmemoryvalue(Humanoid, 0x168, "float")
    return {x = x, y = y, z = z}
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
    local Fov = Float / 57.2958 + 0.0167
    setmemoryvalue(Camera, Offsets.FOV, "float", Fov)
end

-- <Frame>
Helper.getframeposition = function(Frame)
    return {
        x = getmemoryvalue(Frame, Offsets.FramePositionX, "float"),
        y = getmemoryvalue(Frame, Offsets.FramePositionY, "float")
    }
end

Helper.setframeposition = function(Frame, Position)
    setmemoryvalue(Frame, Offsets.FramePositionX, "float", Position.X)
    setmemoryvalue(Frame, Offsets.FramePositionY, "float", Position.Y)
end

Helper.getframeoffset = function(Frame)
    return {
        x = getmemoryvalue(Frame, 0x3AC, "dword"),
        y = getmemoryvalue(Frame, 0x3B4, "dword")
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
        x = getmemoryvalue(Frame, Offsets.FrameSizeX, "float"),
        y = getmemoryvalue(Frame, Offsets.FrameSizeY, "float")
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
    [12] = "Light orange brown", [18] = "Nougat", [21] = "Bright red", 
    [22] = "Med. reddish violet", [23] = "Bright blue", [24] = "Bright yellow", 
    [25] = "Earth orange", [26] = "Black", [27] = "Dark grey", [28] = "Dark green", 
    [29] = "Medium green", [36] = "Lig. Yellowich orange", [37] = "Bright green", 
    [38] = "Dark orange", [39] = "Light bluish violet", [40] = "Transparent", 
    [41] = "Tr. Red", [42] = "Tr. Lg blue", [43] = "Tr. Blue", [44] = "Tr. Yellow", 
    [45] = "Light blue", [47] = "Tr. Flu. Reddish orange", [48] = "Tr. Green", 
    [49] = "Tr. Flu. Green", [50] = "Phosph. White", [100] = "Light red", 
    [101] = "Medium red", [102] = "Medium blue", [103] = "Light grey", 
    [104] = "Bright violet", [105] = "Br. yellowish orange", [106] = "Bright orange", 
    [107] = "Bright bluish green", [108] = "Earth yellow", [110] = "Bright bluish violet", 
    [111] = "Tr. Brown", [112] = "Medium bluish violet", [113] = "Tr. Medi. reddish violet", 
    [115] = "Med. yellowish green", [116] = "Med. bluish green", [118] = "Light bluish green", 
    [119] = "Br. yellowish green", [120] = "Lig. yellowish green", [121] = "Med. yellowish orange", 
    [123] = "Br. reddish orange", [124] = "Bright reddish violet", [125] = "Light orange", 
    [126] = "Tr. Bright bluish violet", [127] = "Gold", [128] = "Dark nougat", 
    [131] = "Silver", [133] = "Neon orange", [134] = "Neon green", [135] = "Sand blue", 
    [136] = "Sand violet", [137] = "Medium orange", [138] = "Sand yellow", [140] = "Earth blue", 
    [141] = "Earth green", [143] = "Tr. Flu. Blue", [145] = "Sand blue metallic", 
    [146] = "Sand violet metallic", [147] = "Sand yellow metallic", [148] = "Dark grey metallic", 
    [149] = "Black metallic", [150] = "Light grey metallic", [151] = "Sand green", 
    [153] = "Sand red", [154] = "Dark red", [157] = "Tr. Flu. Yellow", [158] = "Tr. Flu. Red", 
    [168] = "Gun metallic", [176] = "Red flip/flop", [178] = "Yellow flip/flop", 
    [179] = "Silver flip/flop", [180] = "Curry", [190] = "Fire Yellow", 
    [191] = "Flame yellowish orange", [192] = "Reddish brown", [193] = "Flame reddish orange", 
    [194] = "Medium stone grey", [195] = "Royal blue", [196] = "Dark Royal blue", 
    [198] = "Bright reddish lilac", [199] = "Dark stone grey", [200] = "Lemon metalic", 
    [208] = "Light stone grey", [209] = "Dark Curry", [210] = "Faded green", 
    [211] = "Turquoise", [212] = "Light Royal blue", [213] = "Medium Royal blue", 
    [216] = "Rust", [217] = "Brown", [218] = "Reddish lilac", [219] = "Lilac", 
    [220] = "Light lilac", [221] = "Bright purple", [222] = "Light purple", 
    [223] = "Light pink", [224] = "Light brick yellow", [225] = "Warm yellowish orange", 
    [226] = "Cool yellow", [232] = "Dove blue", [268] = "Medium lilac", 
    [301] = "Slime green", [302] = "Smoky grey", [303] = "Dark blue", 
    [304] = "Parsley green", [305] = "Steel blue", [306] = "Storm blue", 
    [307] = "Lapis", [308] = "Dark indigo", [309] = "Sea green", [310] = "Shamrock", 
    [311] = "Fossil", [312] = "Mulberry", [313] = "Forest green", [314] = "Cadet blue", 
    [315] = "Electric blue", [316] = "Eggplant", [317] = "Moss", [318] = "Artichoke", 
    [319] = "Sage green", [320] = "Ghost grey", [321] = "Lilac", [322] = "Plum", 
    [323] = "Olivine", [324] = "Laurel green", [325] = "Quill grey", [327] = "Crimson", 
    [328] = "Mint", [329] = "Baby blue", [330] = "Carnation pink", [331] = "Persimmon", 
    [332] = "Maroon", [333] = "Gold", [334] = "Daisy orange", [335] = "Pearl", 
    [336] = "Fog", [337] = "Salmon", [338] = "Terra Cotta", [339] = "Cocoa", 
    [340] = "Wheat", [341] = "Buttermilk", [342] = "Mauve", [343] = "Sunrise", 
    [344] = "Tawny", [345] = "Rust", [346] = "Cashmere", [347] = "Khaki", 
    [348] = "Lily white", [349] = "Seashell", [350] = "Burgundy", [351] = "Cork", 
    [352] = "Burlap", [353] = "Beige", [354] = "Oyster", [355] = "Pine Cone", 
    [356] = "Fawn brown", [357] = "Hurricane grey", [358] = "Cloudy grey", 
    [359] = "Linen", [360] = "Copper", [361] = "Medium brown", [362] = "Bronze", 
    [363] = "Flint", [364] = "Dark taupe", [365] = "Burnt Sienna", [1001] = "Institutional white", 
    [1002] = "Mid gray", [1003] = "Really black", [1004] = "Really red", 
    [1005] = "Deep orange", [1006] = "Alder", [1007] = "Dusty Rose", [1008] = "Olive", 
    [1009] = "New Yeller", [1010] = "Really blue", [1011] = "Navy blue", 
    [1012] = "Deep blue", [1013] = "Cyan", [1014] = "CGA brown", [1015] = "Magenta", 
    [1016] = "Pink", [1017] = "Deep orange", [1018] = "Teal", [1019] = "Toothpaste", 
    [1020] = "Lime green", [1021] = "Camo", [1022] = "Grime", [1023] = "Lavender", 
    [1024] = "Pastel light blue", [1025] = "Pastel orange", [1026] = "Pastel violet", 
    [1027] = "Pastel blue-green", [1028] = "Pastel green", [1029] = "Pastel yellow", 
    [1030] = "Pastel brown", [1031] = "Royal purple", [1032] = "Hot pink"
}

Helper.getteamcolor = function(Team)
    local Color = getmemoryvalue(Team, Offsets.TeamColor, "dword")
    return Helper.TeamColors[Color] or Color

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
        r = getmemoryvalue(Lighting, Offsets.FogColor, "float") * 255,
        g = getmemoryvalue(Lighting, Offsets.FogColor + 0x4, "float") * 255,
        b = getmemoryvalue(Lighting, Offsets.FogColor + 0x8, "float") * 255
    }
end

Helper.setfogcolor = function(Lighting, Color)
    setmemoryvalue(Lighting, Offsets.FogColor, "float", Color.r / 255)
    setmemoryvalue(Lighting, Offsets.FogColor + 0x4, "float", Color.g / 255)
    setmemoryvalue(Lighting, Offsets.FogColor + 0x8, "float", Color.b / 255)
end

Helper.getoutdoorambient = function(Lighting)
    return {
        r = getmemoryvalue(Lighting, Offsets.OutdoorAmbient, "float") * 255,
        g = getmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x4, "float") * 255,
        b = getmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x8, "float") * 255
    }
end

Helper.setoutdoorambient = function(Lighting, Color)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient, "float", Color.r / 255)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x4, "float", Color.g / 255)
    setmemoryvalue(Lighting, Offsets.OutdoorAmbient + 0x8, "float", Color.b / 255)
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
        x = getmemoryvalue(Tool, Offsets.Tool_Grip_Position, "float"),
        y = getmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x4, "float"),
        z = getmemoryvalue(Tool, Offsets.Tool_Grip_Position + 0x8, "float")
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
