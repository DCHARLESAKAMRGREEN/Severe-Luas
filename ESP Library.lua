local Library = (function()
    local RenderDistance = 500
    local Drawings = {}

    local Cache = {
        Size = {},
        Corners = {}
    }

    local function GetDistance(P1, P2)
        local Delta = {x = P2.x - P1.x, y = P2.y - P1.y, z = P2.z - P1.z}
        return math.sqrt(Delta.x^2 + Delta.y^2 + Delta.z^2)
    end

    local function Remove(DrawingObject)
        if DrawingObject and DrawingObject.Remove then
            DrawingObject:Remove()
        end
    end

    local Camera
    spawn(function()
        while true do
            Camera = getposition(findfirstchildofclass(Game, "Camera"))
            wait(0.1)
        end
    end)

    local function DrawText(Params, Text)
        local TextObj = Drawing.new("Text")
        TextObj.Text = Text
        TextObj.Color = Params.TextColor or Params.Color or {255, 255, 255}
        TextObj.Font = Params.TextFont or 29
        TextObj.Size = Params.TextSize or 12
        TextObj.Center = true
        TextObj.Outline = true
        TextObj.OutlineColor = {0, 0, 0}
        TextObj.Visible = false
        return TextObj
    end

    local function Renderer()
        while true do
            for _, DrawingEntry in pairs(Drawings) do
                local Visible = false
                local MinX, MaxX, MinY, MaxY = math.huge, -math.huge, math.huge, -math.huge

                for _, Part in ipairs(DrawingEntry.Parts) do
                    if not Part then
                        Remove(DrawingEntry.BBox)
                        Remove(DrawingEntry.BBoxOutline)
                        Remove(DrawingEntry.NameText)
                        Remove(DrawingEntry.DistanceText)
                        Drawings[_] = nil
                        break
                    end

                    local Position = getposition(Part)
                    if Position then
                        local ObjectDistance = GetDistance(Position, Camera)
                        if ObjectDistance and ObjectDistance <= RenderDistance then
                            local Size = Cache.Size[Part] or getsize(Part)
                            if Size then
                                Cache.Size[Part] = Size
                                local HalfX, HalfY, HalfZ = Size.x / 2, Size.y / 2, Size.z / 2
                                local Corners3D = Cache.Corners[Part] or {
                                    {Position.x - HalfX, Position.y + HalfY, Position.z - HalfZ},
                                    {Position.x + HalfX, Position.y + HalfY, Position.z - HalfZ},
                                    {Position.x - HalfX, Position.y - HalfY, Position.z - HalfZ},
                                    {Position.x + HalfX, Position.y - HalfY, Position.z - HalfZ},
                                    {Position.x - HalfX, Position.y + HalfY, Position.z + HalfZ},
                                    {Position.x + HalfX, Position.y + HalfY, Position.z + HalfZ},
                                    {Position.x - HalfX, Position.y - HalfY, Position.z + HalfZ},
                                    {Position.x + HalfX, Position.y - HalfY, Position.z + HalfZ}
                                }
                                Cache.Corners[Part] = Corners3D

                                for _, Corner in ipairs(Corners3D) do
                                    local ScreenPos, OnScreen = worldtoscreenpoint({Corner[1], Corner[2], Corner[3]})
                                    if OnScreen then
                                        MinX = math.min(MinX, ScreenPos.x)
                                        MaxX = math.max(MaxX, ScreenPos.x)
                                        MinY = math.min(MinY, ScreenPos.y)
                                        MaxY = math.max(MaxY, ScreenPos.y)
                                        Visible = true
                                    end
                                end
                            end
                        end
                    end
                end

                if Visible then
                    local CenterX = (MinX + MaxX) / 2
                    DrawingEntry.BBox.PointA = {MinX, MinY}
                    DrawingEntry.BBox.PointB = {MaxX, MinY}
                    DrawingEntry.BBox.PointC = {MaxX, MaxY}
                    DrawingEntry.BBox.PointD = {MinX, MaxY}
                    DrawingEntry.BBox.Visible = true
                    DrawingEntry.BBoxOutline.PointA = {MinX, MinY}
                    DrawingEntry.BBoxOutline.PointB = {MaxX, MinY}
                    DrawingEntry.BBoxOutline.PointC = {MaxX, MaxY}
                    DrawingEntry.BBoxOutline.PointD = {MinX, MaxY}
                    DrawingEntry.BBoxOutline.Visible = true

                    if DrawingEntry.NameText then
                        DrawingEntry.NameText.Position = {CenterX, MinY - 20}
                        DrawingEntry.NameText.Visible = true
                    end
                    if DrawingEntry.DistanceText then
                        DrawingEntry.DistanceText.Text = string.format("[%d]", math.floor(GetDistance(getposition(DrawingEntry.Parts[1]), Camera)))
                        DrawingEntry.DistanceText.Position = {CenterX, MaxY + 5}
                        DrawingEntry.DistanceText.Visible = true
                    end
                else
                    DrawingEntry.BBox.Visible = false
                    DrawingEntry.BBoxOutline.Visible = false
                    if DrawingEntry.NameText then DrawingEntry.NameText.Visible = false end
                    if DrawingEntry.DistanceText then DrawingEntry.DistanceText.Visible = false end
                end
            end
            wait()
        end
    end

    local function RenderBBox(Params)
        local BBox = Drawing.new("Quad")
        local BBoxOutline = Drawing.new("Quad")
        local NameText = Params.Name and DrawText(Params, Params.Name) or nil
        local DistanceText = Params.Distance and DrawText(Params, "") or nil

        BBox.Color = Params.Color or {255, 255, 255}
        BBox.Thickness = 1.5
        BBox.Filled = Params.Filled or false
        BBox.Transparency = Params.Transparency or 1
        BBox.zIndex = 2
        BBox.Visible = false

        BBoxOutline.Color = {0, 0, 0}
        BBoxOutline.Thickness = 3
        BBoxOutline.Filled = false
        BBoxOutline.Transparency = 1
        BBoxOutline.zIndex = 1
        BBoxOutline.Visible = false

        Drawings[#Drawings + 1] = {
            BBox = BBox,
            BBoxOutline = BBoxOutline,
            NameText = NameText,
            DistanceText = DistanceText,
            Parts = Params.Parts
        }
    end

    local function RemoveAll()
        for _, DrawingEntry in pairs(Drawings) do
            Remove(DrawingEntry.BBox)
            Remove(DrawingEntry.BBoxOutline)
            Remove(DrawingEntry.NameText)
            Remove(DrawingEntry.DistanceText)
        end
        Drawings = {}
        Cache = {Size = {}, Corners = {}}
    end

    spawn(Renderer)

    return {
        RenderBBox = RenderBBox,
        Remove = Remove,
        RemoveAll = RemoveAll
    }
end)()

return Library
