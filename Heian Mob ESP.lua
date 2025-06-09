local RenderDistance = 500

local Live = findfirstchild(Workspace, "Live")
local NPCs = findfirstchild(Workspace, "NPCs")

local Camera = findfirstchildofclass(Workspace, "Camera")
local CameraPosition = getposition(Camera)

local Alive = {
    Mobs = {
        Parts = {},
        Humanoids = {},
        MaxHealth = {},
        Health = {},
        Names = {}
    },
    NPCs = {
        Parts = {},
        Names = {}
    }
}

local Drawings = {
    Boxes = {
        Main = {},
        Outline = {}
    },
    Healthbars = {
        Background = {},
        Fill = {}
    },
    Text = {
        Names = {},
        Distances = {}
    }
}

local function GetMobName(Mob)
    local Name = getname(Mob)
    Name = Name:gsub("%f[%w_][Cc][Uu][Rr][Ss][Ee]%f[^%w_].*", ""):gsub("_", " "):gsub("%-.*", ""):gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper()..rest:lower()
    end):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    return Name
end

local function GetDistance(Position1, Position2)
    local DeltaX = Position1.x - Position2.x
    local DeltaY = Position1.y - Position2.y
    local DeltaZ = Position1.z - Position2.z
    return math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY + DeltaZ * DeltaZ)
end

local function GetCorners(Part)
    local Size = getsize(Part)
    local Position = getposition(Part)
    local HalfSize = {
        x = Size.x/2,
        y = Size.y/2,
        z = Size.z/2
    }
    return {
        {Position.x + HalfSize.x, Position.y + HalfSize.y, Position.z + HalfSize.z},
        {Position.x - HalfSize.x, Position.y + HalfSize.y, Position.z + HalfSize.z}, 
        {Position.x + HalfSize.x, Position.y - HalfSize.y, Position.z + HalfSize.z}, 
        {Position.x - HalfSize.x, Position.y - HalfSize.y, Position.z + HalfSize.z}, 
        {Position.x + HalfSize.x, Position.y + HalfSize.y, Position.z - HalfSize.z},
        {Position.x - HalfSize.x, Position.y + HalfSize.y, Position.z - HalfSize.z},
        {Position.x - HalfSize.x, Position.y - HalfSize.y, Position.z - HalfSize.z}
    }
end

local function CreateQuad(Mob)
    if not Drawings.Boxes.Main[Mob] then
        local Boxes = Drawings.Boxes
        local Healthbars = Drawings.Healthbars
        local Text = Drawings.Text
        local Name = getname(Mob)
        local Color = Alive.NPCs.Parts[Mob] and {0, 150, 255} or (Name:lower():find("sorcerer") and {0, 255, 0} or {255, 255, 255})

        Boxes.Main[Mob] = Drawing.new("Quad")
        Boxes.Main[Mob].Visible = true
        Boxes.Main[Mob].Color = Color
        Boxes.Main[Mob].Thickness = 1.25
        Boxes.Main[Mob].Transparency = 1
        Boxes.Main[Mob].Filled = false
        Boxes.Main[Mob].zIndex = 1
        
        Boxes.Outline[Mob] = Drawing.new("Quad")
        Boxes.Outline[Mob].Visible = true
        Boxes.Outline[Mob].Color = {0, 0, 0}
        Boxes.Outline[Mob].Thickness = 3.25
        Boxes.Outline[Mob].Transparency = 1
        Boxes.Outline[Mob].Filled = false
        Boxes.Outline[Mob].zIndex = 0

        Text.Names[Mob] = Drawing.new("Text")
        Text.Names[Mob].Visible = false
        Text.Names[Mob].Color = Color
        Text.Names[Mob].Size = 12
        Text.Names[Mob].Font = 29
        Text.Names[Mob].Center = true
        Text.Names[Mob].Outline = true
        Text.Names[Mob].OutlineColor = {0, 0, 0}
        Text.Names[Mob].zIndex = 2
        Text.Names[Mob].Position = {0, 0}

        Text.Distances[Mob] = Drawing.new("Text")
        Text.Distances[Mob].Visible = false
        Text.Distances[Mob].Color = Color
        Text.Distances[Mob].Size = 12
        Text.Distances[Mob].Font = 29
        Text.Distances[Mob].Center = true
        Text.Distances[Mob].Outline = true
        Text.Distances[Mob].OutlineColor = {0, 0, 0}
        Text.Distances[Mob].zIndex = 2
        Text.Distances[Mob].Position = {0, 0}

        if not Alive.NPCs.Parts[Mob] then
            Healthbars.Background[Mob] = Drawing.new("Quad")
            Healthbars.Background[Mob].Visible = true
            Healthbars.Background[Mob].Color = {0, 0, 0}
            Healthbars.Background[Mob].Thickness = 1
            Healthbars.Background[Mob].Transparency = 1
            Healthbars.Background[Mob].Filled = true
            Healthbars.Background[Mob].zIndex = 1

            Healthbars.Fill[Mob] = Drawing.new("Quad")
            Healthbars.Fill[Mob].Visible = true
            Healthbars.Fill[Mob].Color = {255, 0, 0}
            Healthbars.Fill[Mob].Thickness = 1
            Healthbars.Fill[Mob].Transparency = 1
            Healthbars.Fill[Mob].Filled = true
            Healthbars.Fill[Mob].zIndex = 2
        end
    end
end

local function UpdateQuad(Mob)
    local Part = Alive.Mobs.Parts[Mob] or Alive.NPCs.Parts[Mob]
    if not Part or not Drawings.Boxes.Main[Mob] then return end
    
    local MobPosition = getposition(Part)
    if not MobPosition then return end
    
    local Distance = GetDistance(CameraPosition, MobPosition)
    if Distance > RenderDistance then
        local Boxes = Drawings.Boxes
        local Healthbars = Drawings.Healthbars
        local Text = Drawings.Text
        
        Boxes.Main[Mob].Visible = false
        Boxes.Outline[Mob].Visible = false
        Text.Names[Mob].Visible = false
        Text.Distances[Mob].Visible = false
        if not Alive.NPCs.Parts[Mob] then
            Healthbars.Background[Mob].Visible = false
            Healthbars.Fill[Mob].Visible = false
        end
        return
    end
    
    local Boxes = Drawings.Boxes
    local Healthbars = Drawings.Healthbars
    local Text = Drawings.Text
    local MinX = math.huge
    local MinY = math.huge
    local MaxX = -math.huge
    local MaxY = -math.huge
    local AVisible = true
    
    for _, Part in ipairs(getchildren(Mob)) do
        if getclassname(Part) == "Part" or getclassname(Part) == "MeshPart" then
            local Corners = GetCorners(Part)
            if not Corners then continue end
            
            for _, Corner in ipairs(Corners) do
                local ScreenPos, Visible = worldtoscreenpoint(Corner)
                if not ScreenPos then continue end
                
                if not Visible then
                    AVisible = false
                    break
                end
                MinX = math.min(MinX, ScreenPos.x)
                MinY = math.min(MinY, ScreenPos.y)
                MaxX = math.max(MaxX, ScreenPos.x)
                MaxY = math.max(MaxY, ScreenPos.y)
            end
        end
    end
    
    if MinX == math.huge or MaxX == -math.huge then return end

    Boxes.Main[Mob].Visible = AVisible
    Boxes.Outline[Mob].Visible = AVisible
    Text.Names[Mob].Visible = AVisible
    Text.Distances[Mob].Visible = AVisible
    if not Alive.NPCs.Parts[Mob] then
        Healthbars.Background[Mob].Visible = AVisible
        Healthbars.Fill[Mob].Visible = AVisible
    end
    
    if AVisible then
        Boxes.Main[Mob].PointA = {MaxX, MinY}
        Boxes.Main[Mob].PointB = {MinX, MinY}
        Boxes.Main[Mob].PointC = {MinX, MaxY}
        Boxes.Main[Mob].PointD = {MaxX, MaxY}
        
        Boxes.Outline[Mob].PointA = {MaxX, MinY}
        Boxes.Outline[Mob].PointB = {MinX, MinY}
        Boxes.Outline[Mob].PointC = {MinX, MaxY}
        Boxes.Outline[Mob].PointD = {MaxX, MaxY}

        Text.Names[Mob].Position = {MinX + (MaxX - MinX) / 2, MinY - 15}
        Text.Names[Mob].Text = Alive.Mobs.Names[Mob] or Alive.NPCs.Names[Mob]

        Text.Distances[Mob].Position = {MinX + (MaxX - MinX) / 2, MaxY + 5}
        Text.Distances[Mob].Text = math.floor(Distance) .. "m"

        if not Alive.NPCs.Parts[Mob] then
            local HealthBarX = MinX - 6
            local HealthBarFillX = HealthBarX + 1

            Healthbars.Background[Mob].PointA = {HealthBarX, MinY - 1}
            Healthbars.Background[Mob].PointB = {HealthBarX + 4, MinY - 1}
            Healthbars.Background[Mob].PointC = {HealthBarX + 4, MaxY + 1}
            Healthbars.Background[Mob].PointD = {HealthBarX, MaxY + 1}

            if Alive.Mobs.MaxHealth[Mob] and Alive.Mobs.Health[Mob] and Alive.Mobs.MaxHealth[Mob] > 0 then
                local HealthPercent = Alive.Mobs.Health[Mob] / Alive.Mobs.MaxHealth[Mob]
                local HealthHeight = (MaxY - MinY) * HealthPercent

                if HealthPercent > 0.7 then
                    Healthbars.Fill[Mob].Color = {0, 255, 0}
                elseif HealthPercent > 0.3 then
                    Healthbars.Fill[Mob].Color = {255, 255, 0}
                else
                    Healthbars.Fill[Mob].Color = {255, 0, 0}
                end

                Healthbars.Fill[Mob].PointA = {HealthBarFillX, MaxY - HealthHeight}
                Healthbars.Fill[Mob].PointB = {HealthBarFillX + 2, MaxY - HealthHeight}
                Healthbars.Fill[Mob].PointC = {HealthBarFillX + 2, MaxY}
                Healthbars.Fill[Mob].PointD = {HealthBarFillX, MaxY}
            end
        end
    end
end

local function DrawMobs()
    if not Camera or not Live then return end
    
    CameraPosition = getposition(Camera)
    if not CameraPosition then return end
    
    for Mob in pairs(Alive.Mobs.Parts) do
        if Alive.Mobs.Humanoids[Mob] then
            Alive.Mobs.Health[Mob] = gethealth(Alive.Mobs.Humanoids[Mob])
        end
        UpdateQuad(Mob)
    end
    
    for Mob in pairs(Alive.NPCs.Parts) do
        UpdateQuad(Mob)
    end
end

local function RemoveDrawings(Mob)
    if Drawings.Boxes.Main[Mob] then
        Drawings.Boxes.Main[Mob]:Remove()
        Drawings.Boxes.Main[Mob] = nil
    end
    if Drawings.Boxes.Outline[Mob] then
        Drawings.Boxes.Outline[Mob]:Remove()
        Drawings.Boxes.Outline[Mob] = nil
    end
    if Drawings.Text.Names[Mob] then
        Drawings.Text.Names[Mob]:Remove()
        Drawings.Text.Names[Mob] = nil
    end
    if Drawings.Text.Distances[Mob] then
        Drawings.Text.Distances[Mob]:Remove()
        Drawings.Text.Distances[Mob] = nil
    end
    if Drawings.Healthbars.Background[Mob] then
        Drawings.Healthbars.Background[Mob]:Remove()
        Drawings.Healthbars.Background[Mob] = nil
    end
    if Drawings.Healthbars.Fill[Mob] then
        Drawings.Healthbars.Fill[Mob]:Remove()
        Drawings.Healthbars.Fill[Mob] = nil
    end
end

local function CleanupMob(Mob)
    Alive.Mobs.Parts[Mob] = nil
    Alive.Mobs.Humanoids[Mob] = nil
    Alive.Mobs.MaxHealth[Mob] = nil
    Alive.Mobs.Health[Mob] = nil
    Alive.Mobs.Names[Mob] = nil
    RemoveDrawings(Mob)
end

local function CleanupNPC(Mob)
    Alive.NPCs.Parts[Mob] = nil
    Alive.NPCs.Names[Mob] = nil
    RemoveDrawings(Mob)
end

local function GetMobs()
    if not Live then return end
    
    local Active = {}
    
    for _, Mob in ipairs(getchildren(Live)) do
        if getname(Mob):find("-") then
            Active[Mob] = true
            if not Alive.Mobs.Parts[Mob] then
                Alive.Mobs.Parts[Mob] = findfirstchildofclass(Mob, "Part")
                Alive.Mobs.Humanoids[Mob] = findfirstchildofclass(Mob, "Humanoid")
                Alive.Mobs.Names[Mob] = GetMobName(Mob)
                if Alive.Mobs.Humanoids[Mob] then
                    Alive.Mobs.MaxHealth[Mob] = getmaxhealth(Alive.Mobs.Humanoids[Mob])
                    Alive.Mobs.Health[Mob] = gethealth(Alive.Mobs.Humanoids[Mob])
                end
                CreateQuad(Mob)
            end
        end
    end

    if NPCs then
        for _, NPC in ipairs(getchildren(NPCs)) do
            Active[NPC] = true
            if not Alive.NPCs.Parts[NPC] then
                Alive.NPCs.Parts[NPC] = findfirstchildofclass(NPC, "Part")
                Alive.NPCs.Names[NPC] = GetMobName(NPC)
                CreateQuad(NPC)
            end
        end
    end
    
    for Mob in pairs(Alive.Mobs.Parts) do
        if not Active[Mob] then
            CleanupMob(Mob)
        end
    end
    
    for Mob in pairs(Alive.NPCs.Parts) do
        if not Active[Mob] then
            CleanupNPC(Mob)
        end
    end
end

local function GetNPCs()
    if not NPCs then return end
    
    for _, NPC in ipairs(getchildren(NPCs)) do
        if Alive.NPCs.Parts[NPC] then
            Alive.NPCs.Names[NPC] = GetMobName(NPC)
        end
    end
end

GetMobs()

spawn(function()
    while true do
        wait(1)
        GetMobs()
    end
end)

spawn(function()
    while true do
        wait(3)
        GetNPCs()
    end
end)

while true do
    DrawMobs()
    wait()
end
