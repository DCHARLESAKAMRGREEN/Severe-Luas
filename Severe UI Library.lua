local Colors = {
    ["Accent"] = {67, 12, 122},
    ["Window Background"] = {40, 40, 40},
    ["Window Background 2"] = {30, 30, 30},
    ["Window Border"] = {45, 45, 45},
    ["Tab Background"] = {20, 20, 20},
    ["Tab Border"] = {45, 45, 45},
    ["Tab Toggle Background"] = {28, 28, 28},
    ["Selected"] = {255, 255, 255},
    ["Section Background"] = {18, 18, 18},
    ["Section Border"] = {35, 35, 35},
    ["Text"] = {200, 200, 200},
    ["Disabled Text"] = {110, 110, 110},
    ["Object Background"] = {25, 25, 25},
    ["Object Border"] = {35, 35, 35},
    ["Dropdown Option Background"] = {19, 19, 19}
}

local MouseService = findservice(Game, "MouseService")
local Mouse = {
    X = 0,
    Y = 0,
    Clicked = false,
    Pressed = false
}

local Library = {}
local WindowActive = nil
local IsDragging = false
local DragOffsetX = 0
local DragOffsetY = 0
local IsVisible = true
local IsToggled = false
local HoveredButton = nil
local Running = true

function Library:Unload()
    Running = false
    if WindowActive then
        local function RemoveDrawingObjects(T)
            for _, V in pairs(T) do
                if type(V) == "table" and V.Remove then
                    V:Remove()
                elseif type(V) == "table" then
                    RemoveDrawingObjects(V)
                end
            end
        end
        RemoveDrawingObjects(WindowActive)
        WindowActive = nil
    end
    Library = nil
end

local function SetObjectVisibility(Object, Visible)
    if Object and Object.Visible ~= nil then
        Object.Visible = Visible
    end
end

local function SetInterfaceVisibility(UI, Visible)
    for _, Object in pairs(UI) do
        if Object.Type == "Section" then
            SetObjectVisibility(Object.Background, Visible)
            SetObjectVisibility(Object.Border, Visible)
            SetObjectVisibility(Object.Title, Visible)
            Object.Visible = Visible
            if Object.Interfaces then
                SetInterfaceVisibility(Object.Interfaces, Visible)
            end
        elseif Object.Type == "Button" or Object.Type == "Toggle" or Object.Type == "Slider" then
            for K,V in pairs(Object) do
                if type(V) == "table" and V.Visible ~= nil then
                    SetObjectVisibility(V, Visible)
                end
            end
            Object.Visible = Visible
            if Object.SliderObjects then
                for _, SliderObj in pairs(Object.SliderObjects) do
                    for K,V in pairs(SliderObj) do
                        if type(V) == "table" and V.Visible ~= nil then
                            SetObjectVisibility(V, Visible)
                        end
                    end
                end
            end
        else
            if Object.Visible ~= nil then
                Object.Visible = Visible
            end
            if Object.Interfaces then
                SetInterfaceVisibility(Object.Interfaces, Visible)
            end
            if Object.Background and Object.Background.Visible ~= nil then
                Object.Background.Visible = Visible
            end
            if Object.Border and Object.Border.Visible ~= nil then
                Object.Border.Visible = Visible
            end
            if Object.Title and Object.Title.Visible ~= nil then
                Object.Title.Visible = Visible
            end
            if Object.SelectedHighlight and Object.SelectedHighlight.Visible ~= nil then
                Object.SelectedHighlight.Visible = false
            end
        end
    end
end

function ToggleUI()
    IsVisible = not IsVisible
    if WindowActive then
        local Main = WindowActive
        SetObjectVisibility(Main.WindowBackground, IsVisible)
        SetObjectVisibility(Main.Title, IsVisible)
        SetObjectVisibility(Main.TabBackground, IsVisible)
        SetObjectVisibility(Main.TabBorder, IsVisible)
        SetObjectVisibility(Main.WindowBackground2, IsVisible)
        SetObjectVisibility(Main.Window2Border, IsVisible)
        SetObjectVisibility(Main.WindowBorder, IsVisible)
        for _, TabObj in ipairs(Main.Tabs) do
            SetObjectVisibility(TabObj.Button, IsVisible)
            SetObjectVisibility(TabObj.ButtonBorder, IsVisible)
            SetObjectVisibility(TabObj.ButtonText, IsVisible)
            local IsActiveTab = TabObj.Name == Main.ActiveTab
            SetObjectVisibility(TabObj.SelectedHighlight, IsVisible and IsActiveTab)
            SetInterfaceVisibility(TabObj.Content.LeftSections, IsVisible and IsActiveTab)
            SetInterfaceVisibility(TabObj.Content.RightSections, IsVisible and IsActiveTab)
        end
        if not IsVisible then
            IsDragging = false
            HoveredButton = nil
        else
            Main:SelectTab(Main.ActiveTab)
            Main:UpdateLayout()
        end
    end
end

function Library:Create(Options)
    local Main = {}
    local TitleText = Options.Name or "Severe UI"

    local function SetInitialVisibility(Object)
        if Object and Object.Visible ~= nil then
            Object.Visible = IsVisible
        end
    end

    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 700}
    Main.WindowBackground.Position = {350, 100}
    Main.WindowBackground.Color = Colors["Window Background"]
    Main.WindowBackground.Filled = true
    Main.WindowBackground.Thickness = 1
    Main.WindowBackground.Transparency = 1
    SetInitialVisibility(Main.WindowBackground)

    Main.Title = Drawing.new("Text")
    Main.Title.Text = TitleText
    Main.Title.Size = 16
    Main.Title.Font = 5
    Main.Title.Color = Colors["Text"]
    Main.Title.Outline = true
    Main.Title.OutlineColor = {0, 0, 0}
    Main.Title.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 5}
    Main.Title.Transparency = 1
    Main.Title.Center = false
    SetInitialVisibility(Main.Title)

    Main.TabBackground = Drawing.new("Square")
    Main.TabBackground.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 25}
    Main.TabBackground.Size = {Main.WindowBackground.Size.x - 20, 23}
    Main.TabBackground.Color = Colors["Tab Background"]
    Main.TabBackground.Filled = true
    Main.TabBackground.Thickness = 1
    Main.TabBackground.Transparency = 1
    SetInitialVisibility(Main.TabBackground)

    Main.TabBorder = Drawing.new("Square")
    Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
    Main.TabBorder.Size = {Main.TabBackground.Size.x, Main.TabBackground.Size.y}
    Main.TabBorder.Color = Colors["Tab Border"]
    Main.TabBorder.Filled = false
    Main.TabBorder.Thickness = 1
    Main.TabBorder.Transparency = 1
    SetInitialVisibility(Main.TabBorder)

    Main.WindowBackground2 = Drawing.new("Square")
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 48}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 68}
    Main.WindowBackground2.Color = Colors["Window Background 2"]
    Main.WindowBackground2.Filled = true
    Main.WindowBackground2.Thickness = 1
    Main.WindowBackground2.Transparency = 1
    SetInitialVisibility(Main.WindowBackground2)

    Main.Window2Border = Drawing.new("Square")
    Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
    Main.Window2Border.Size = {Main.WindowBackground2.Size.x, Main.WindowBackground2.Size.y}
    Main.Window2Border.Color = Colors["Window Border"]
    Main.Window2Border.Filled = false
    Main.Window2Border.Thickness = 1
    Main.Window2Border.Transparency = 1
    SetInitialVisibility(Main.Window2Border)

    Main.WindowBorder = Drawing.new("Square")
    Main.WindowBorder.Size = {Main.WindowBackground.Size.x, Main.WindowBackground.Size.y}
    Main.WindowBorder.Position = {Main.WindowBackground.Position.x, Main.WindowBackground.Position.y}
    Main.WindowBorder.Color = Colors["Accent"]
    Main.WindowBorder.Filled = false
    Main.WindowBorder.Thickness = 1
    Main.WindowBorder.Transparency = 1
    SetInitialVisibility(Main.WindowBorder)

    Main.Tabs = {}
    Main.TabButtons = {}
    Main.TabContents = {}
    Main.ActiveTab = nil

    function Main:IsObjectHovered(Object)
        if not IsVisible or not Object or not Object.Visible then return false end
        local MouseX, MouseY = Mouse.X, Mouse.Y
        local ObjectPos = Object.Position
        if not ObjectPos then return false end
        local ObjectX, ObjectY = ObjectPos.x, ObjectPos.y

        if Object.Size then
            local ObjectSize = Object.Size
            local ObjectW, ObjectH = ObjectSize.x, ObjectSize.y
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and MouseY <= ObjectY + ObjectH
        elseif Object.TextBounds then
            local ObjectBounds = Object.TextBounds
            local ObjectW, ObjectH = ObjectBounds.x, ObjectBounds.y
            if Object.Center then
                ObjectX = ObjectX - ObjectW / 2
            end
            ObjectY = ObjectY - ObjectH / 4
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and MouseY <= ObjectY + ObjectH
        end
        return false
    end

    function Main:IsWindowHovered()
        if not IsVisible then return false end
        return Main:IsObjectHovered(Main.WindowBackground)
    end

    function Main:UpdateElementPositions()
        local BasePos = Main.WindowBackground.Position
        local BaseX, BaseY = BasePos.x, BasePos.y
        Main.Title.Position = {BaseX + 10, BaseY + 5}
        Main.TabBackground.Position = {BaseX + 10, BaseY + 25}
        Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
        Main.WindowBackground2.Position = {BaseX + 10, BaseY + 48}
        Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
        Main.WindowBorder.Position = {BaseX, BaseY}
        Main:UpdateLayout()
    end

    function Main:UpdateTabSizes()
        local TabCount = #Main.Tabs
        if TabCount == 0 then return end
        local TabBackgroundPos = Main.TabBackground.Position
        local TabBackgroundSize = Main.TabBackground.Size
        local TotalWidth = TabBackgroundSize.x
        local StartXBase = TabBackgroundPos.x
        local TabY = TabBackgroundPos.y
        local TabH = TabBackgroundSize.y
        if TotalWidth <= 0 then return end
        local ExactTabWidth = TotalWidth / TabCount
        local Epsilon = 0.0001
        for i, TabObj in ipairs(Main.Tabs) do
            local StartX = StartXBase + (i - 1) * ExactTabWidth
            local EndX = StartX + ExactTabWidth
            local RoundedStartX = math.floor(StartX + Epsilon)
            local RoundedEndX = math.floor(EndX + Epsilon)
            local RoundedWidth = RoundedEndX - RoundedStartX
            if i == TabCount then
                RoundedEndX = math.floor(StartXBase + TotalWidth + Epsilon)
                RoundedWidth = RoundedEndX - RoundedStartX
            end
            if RoundedWidth <= 0 then RoundedWidth = 1 end
            local Button = TabObj.Button
            local ButtonBorder = TabObj.ButtonBorder
            local ButtonText = TabObj.ButtonText
            local Highlight = TabObj.SelectedHighlight
            Button.Position = {RoundedStartX, TabY}
            Button.Size = {RoundedWidth, TabH}
            ButtonBorder.Position = {RoundedStartX, TabY}
            ButtonBorder.Size = {RoundedWidth, TabH}
            Highlight.Position = {RoundedStartX, TabY}
            Highlight.Size = {RoundedWidth, TabH}
            ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - 7}
            ButtonText.Center = true
        end
    end
function Main:UpdateLayout()
        Main:UpdateTabSizes()
        if not Main.ActiveTab or not Main.TabContents[Main.ActiveTab] then return end
        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
        local ParentPos = Main.WindowBackground2.Position
        local ParentSize = Main.WindowBackground2.Size
        local ParentWidth = ParentSize.x
        local Padding = 5
        local AvailableWidth = ParentWidth - (Padding * 2) - Padding
        local ColumnWidth = math.floor(AvailableWidth / 2)
        local BaseX = ParentPos.x
        local BaseY = ParentPos.y
        local LeftColumnX = BaseX + Padding
        local RightColumnX = LeftColumnX + ColumnWidth + Padding
        local InitialY = BaseY + Padding
        local CurrentLeftY = InitialY
        local CurrentRightY = InitialY

        local function UpdateSectionLayout(SectionObj, ColumnX, StartY, Width)
            SetObjectVisibility(SectionObj.Background, true)
            SetObjectVisibility(SectionObj.Border, true)
            SetObjectVisibility(SectionObj.Title, true)
            SectionObj.Background.Position = {ColumnX, StartY}
            SectionObj.Border.Position = {ColumnX, StartY}
            local TitleHeight = SectionObj.Title.TextBounds and SectionObj.Title.TextBounds.y or 12
            SectionObj.Title.Position = {ColumnX + Padding, StartY + 3}
            local CurrentInternalY = StartY + TitleHeight + Padding * 2

            if SectionObj.Interfaces then
                for _, Object in ipairs(SectionObj.Interfaces) do
                    if Object.Type == "Button" then
                        local ButtonHeight = 18
                        local ButtonWidth = Width - (Padding * 2)
                        local ButtonX = ColumnX + Padding
                        local ButtonY = CurrentInternalY
                        SetObjectVisibility(Object.ButtonBackground, true)
                        SetObjectVisibility(Object.ButtonBorder, true)
                        SetObjectVisibility(Object.ButtonText, true)
                        Object.ButtonBackground.Position = {ButtonX, ButtonY}
                        Object.ButtonBackground.Size = {ButtonWidth, ButtonHeight}
                        Object.ButtonBorder.Position = {ButtonX, ButtonY}
                        Object.ButtonBorder.Size = {ButtonWidth, ButtonHeight}
                        Object.ButtonText.Position = {ButtonX + math.floor(ButtonWidth / 2), ButtonY + 3}
                        Object.ButtonText.Center = true
                        Object.ButtonText.Size = 12
                        CurrentInternalY = CurrentInternalY + ButtonHeight + Padding
                    elseif Object.Type == "Toggle" then
                        local ToggleHeight = 18
                        local ToggleWidth = 18
                        local TextWidth = Width - ToggleWidth - (Padding * 3)
                        local ToggleX = ColumnX + Padding
                        local ToggleY = CurrentInternalY
                        SetObjectVisibility(Object.OuterBox, true)
                        SetObjectVisibility(Object.InnerBox, true)
                        SetObjectVisibility(Object.Text, true)
                        Object.OuterBox.Position = {ToggleX, ToggleY}
                        Object.OuterBox.Size = {ToggleWidth, ToggleHeight}
                        Object.InnerBox.Position = {ToggleX + 2, ToggleY + 2}
                        Object.InnerBox.Size = {14, 14}
                        Object.Text.Position = {ToggleX + ToggleWidth + Padding, ToggleY + 4}
                        Object.Text.Center = false
                        Object.Text.Size = 12
                        CurrentInternalY = CurrentInternalY + ToggleHeight + Padding

                        if Object.SliderObjects then
                            for _, SliderObj in pairs(Object.SliderObjects) do
                                local SliderHeight = 18
                                local SliderWidth = Width - (Padding * 2)
                                local SliderX = ColumnX + Padding
                                local SliderY = CurrentInternalY
                                SetObjectVisibility(SliderObj.Background, true)
                                SetObjectVisibility(SliderObj.Border, true)
                                SetObjectVisibility(SliderObj.Fill, true)
                                SetObjectVisibility(SliderObj.Text, true)
                                SetObjectVisibility(SliderObj.ValueText, true)
                                SliderObj.Background.Position = {SliderX, SliderY}
                                SliderObj.Background.Size = {SliderWidth, SliderHeight}
                                SliderObj.Border.Position = {SliderX, SliderY}
                                SliderObj.Border.Size = {SliderWidth, SliderHeight}
                                SliderObj.Fill.Position = {SliderX, SliderY}
                                SliderObj.Fill.Size = {((SliderObj.Value - SliderObj.Min) / (SliderObj.Max - SliderObj.Min)) * SliderWidth, SliderHeight}
                                SliderObj.Text.Position = {SliderX, SliderY - 15}
                                
                                local ValueTextWidth = SliderObj.ValueText.TextBounds and SliderObj.ValueText.TextBounds.x or 50
                                SliderObj.ValueText.Position = {SliderX + (SliderWidth / 2) - (ValueTextWidth / 2), SliderY + (SliderHeight / 2) - 6}
                                SliderObj.ValueText.Center = true
                                
                                CurrentInternalY = CurrentInternalY + SliderHeight + Padding + 15
                            end
                        end
                    end
                end
            end
            local TotalSectionHeight = (CurrentInternalY - StartY)
            SectionObj.Background.Size = {Width, TotalSectionHeight}
            SectionObj.Border.Size = {Width, TotalSectionHeight}
            SectionObj.CalculatedHeight = TotalSectionHeight
            return StartY + TotalSectionHeight + Padding
        end

        for _, SectionObj in ipairs(CurrentTabContent.LeftSections) do
            if SectionObj.Visible then
                CurrentLeftY = UpdateSectionLayout(SectionObj, LeftColumnX, CurrentLeftY, ColumnWidth)
            else
                SetObjectVisibility(SectionObj.Background, false)
                SetObjectVisibility(SectionObj.Border, false)
                SetObjectVisibility(SectionObj.Title, false)
                if SectionObj.Interfaces then SetInterfaceVisibility(SectionObj.Interfaces, false) end
            end
        end

        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
            if SectionObj.Visible then
                CurrentRightY = UpdateSectionLayout(SectionObj, RightColumnX, CurrentRightY, ColumnWidth)
            else
                SetObjectVisibility(SectionObj.Background, false)
                SetObjectVisibility(SectionObj.Border, false)
                SetObjectVisibility(SectionObj.Title, false)
                if SectionObj.Interfaces then SetInterfaceVisibility(SectionObj.Interfaces, false) end
            end
        end
    end

    function Main:Tab(Options)
        local TabName = Options.Name or "Tab " .. (#Main.Tabs + 1)
        local TabButton = Drawing.new("Square")
        TabButton.Color = Colors["Tab Toggle Background"]
        TabButton.Filled = true
        TabButton.Thickness = 1
        TabButton.Transparency = 1
        SetInitialVisibility(TabButton)
        local TabButtonBorder = Drawing.new("Square")
        TabButtonBorder.Color = Colors["Tab Border"]
        TabButtonBorder.Filled = false
        TabButtonBorder.Thickness = 1
        TabButtonBorder.Transparency = 1
        SetInitialVisibility(TabButtonBorder)
        local TabButtonText = Drawing.new("Text")
        TabButtonText.Text = TabName
        TabButtonText.Size = 12
        TabButtonText.Font = 5
        TabButtonText.Color = Colors["Text"]
        TabButtonText.Outline = true
        TabButtonText.OutlineColor = {0, 0, 0}
        TabButtonText.Transparency = 1
        TabButtonText.Center = true
        SetInitialVisibility(TabButtonText)
        local SelectedHighlight = Drawing.new("Square")
        SelectedHighlight.Color = Colors["Selected"]
        SelectedHighlight.Transparency = 0.135
        SelectedHighlight.Filled = true
        SelectedHighlight.Visible = false
        local TabContent = {
            Name = TabName,
            LeftSections = {},
            RightSections = {},
            Visible = false
        }

        function TabContent:Section(Options)
            local SectionName = Options.Name or "Section"
            local Side = Options.Side or "Left"
            local SectionBackground = Drawing.new("Square")
            SectionBackground.Color = Colors["Section Background"]
            SectionBackground.Filled = true
            SectionBackground.Thickness = 1
            SectionBackground.Transparency = 1
            SectionBackground.Visible = false
            local SectionBorder = Drawing.new("Square")
            SectionBorder.Color = Colors["Section Border"]
            SectionBorder.Filled = false
            SectionBorder.Thickness = 1
            SectionBorder.Transparency = 1
            SectionBorder.Visible = false
            local SectionTitle = Drawing.new("Text")
            SectionTitle.Text = SectionName
            SectionTitle.Size = 12
            SectionTitle.Font = 5
            SectionTitle.Color = Colors["Text"]
            SectionTitle.Outline = true
            SectionTitle.OutlineColor = {0, 0, 0}
            SectionTitle.Transparency = 1
            SectionTitle.Center = false
            SectionTitle.Visible = false
            local SectionObj = {
                Type = "Section",
                Name = SectionName,
                Side = Side,
                Background = SectionBackground,
                Border = SectionBorder,
                Title = SectionTitle,
                Interfaces = {},
                Visible = false,
                CalculatedHeight = 0
            }

            function SectionObj:Button(Options)
                local ButtonName = Options.Name or "Button"
                local Callback = Options.Callback or function() end
                local ButtonBackground = Drawing.new("Square")
                ButtonBackground.Color = Colors["Object Background"]
                ButtonBackground.Filled = true
                ButtonBackground.Thickness = 1
                ButtonBackground.Transparency = 1
                ButtonBackground.Visible = self.Visible
                local ButtonBorder = Drawing.new("Square")
                ButtonBorder.Color = Colors["Object Border"]
                ButtonBorder.Filled = false
                ButtonBorder.Thickness = 1
                ButtonBorder.Transparency = 1
                ButtonBorder.Visible = self.Visible
                local ButtonText = Drawing.new("Text")
                ButtonText.Text = ButtonName
                ButtonText.Size = 12
                ButtonText.Font = 5
                ButtonText.Color = Colors["Text"]
                ButtonText.Outline = true
                ButtonText.OutlineColor = {0, 0, 0}
                ButtonText.Transparency = 1
                ButtonText.Center = true
                ButtonText.Visible = self.Visible
                local ButtonObj = {
                    Type = "Button",
                    Name = ButtonName,
                    Callback = Callback,
                    ButtonBackground = ButtonBackground,
                    ButtonBorder = ButtonBorder,
                    ButtonText = ButtonText,
                    DefaultBorderColor = Colors["Object Border"],
                    OriginalBackgroundColor = Colors["Object Background"],
                    OriginalBackgroundTransparency = 1,
                    Visible = self.Visible
                }
                table.insert(self.Interfaces, ButtonObj)
                if IsVisible and Main.ActiveTab == TabContent.Name then
                    Main:UpdateLayout()
                end
                return ButtonObj
            end

            function SectionObj:Toggle(Options)
                local ToggleName = Options.Name or "Toggle"
                local DefaultState = Options.Default or false
                local Callback = Options.Callback or function() end
                local ToggleOuterBox = Drawing.new("Square")
                ToggleOuterBox.Size = {18, 18}
                ToggleOuterBox.Filled = false
                ToggleOuterBox.Thickness = 1
                ToggleOuterBox.Transparency = 1
                ToggleOuterBox.Visible = self.Visible
                ToggleOuterBox.Color = Colors["Object Border"]
                local ToggleInnerBox = Drawing.new("Square")
                ToggleInnerBox.Size = {14, 14}
                ToggleInnerBox.Filled = true
                ToggleInnerBox.Thickness = 1
                ToggleInnerBox.Transparency = 1
                ToggleInnerBox.Visible = self.Visible
                ToggleInnerBox.Color = DefaultState and Colors["Accent"] or Colors["Object Background"]
                local ToggleText = Drawing.new("Text")
                ToggleText.Text = ToggleName
                ToggleText.Size = 12
                ToggleText.Font = 5
                ToggleText.Color = Colors["Text"]
                ToggleText.Outline = true
                ToggleText.OutlineColor = {0, 0, 0}
                ToggleText.Transparency = 1
                ToggleText.Center = false
                ToggleText.Visible = self.Visible
                local ToggleState = DefaultState
                local ToggleObj = {
                    Type = "Toggle",
                    Name = ToggleName,
                    State = ToggleState,
                    Callback = Callback,
                    OuterBox = ToggleOuterBox,
                    InnerBox = ToggleInnerBox,
                    Text = ToggleText,
                    DefaultBorderColor = Colors["Object Border"],
                    OriginalInnerColor = ToggleState and Colors["Accent"] or Colors["Object Background"],
                    Visible = self.Visible,
                    SliderObjects = {}
                }

                function ToggleObj:SetState(NewState)
                    self.State = NewState
                    self.InnerBox.Color = NewState and Colors["Accent"] or Colors["Object Background"]
                    self.OriginalInnerColor = self.InnerBox.Color
                    if self.Callback then
                        spawn(function() self.Callback(NewState) end)
                    end
                end

                function ToggleObj:Slider(Options)
                    local SliderName = Options.Name or "Slider"
                    local Min = Options.Min or 0
                    local Max = Options.Max or 100
                    local Default = math.clamp(Options.Default or ((Max - Min) / 2), Min, Max)
                    local Units = Options.Units or ""
                    local Callback = Options.Callback or function() end
                    
                    local SliderBackground = Drawing.new("Square")
                    SliderBackground.Color = Colors["Object Background"]
                    SliderBackground.Filled = true
                    SliderBackground.Thickness = 1
                    SliderBackground.Transparency = 1
                    SliderBackground.Visible = self.Visible
                    
                    local SliderBorder = Drawing.new("Square")
                    SliderBorder.Color = Colors["Object Border"]
                    SliderBorder.Filled = false
                    SliderBorder.Thickness = 1
                    SliderBorder.Transparency = 1
                    SliderBorder.Visible = self.Visible
                    
                    local SliderFill = Drawing.new("Square")
                    SliderFill.Color = Colors["Accent"]
                    SliderFill.Filled = true
                    SliderFill.Transparency = 0.5
                    SliderFill.Visible = self.Visible
                    
                    local SliderText = Drawing.new("Text")
                    SliderText.Text = SliderName
                    SliderText.Size = 12
                    SliderText.Font = 5
                    SliderText.Color = Colors["Text"]
                    SliderText.Outline = true
                    SliderText.OutlineColor = {0, 0, 0}
                    SliderText.Transparency = 1
                    SliderText.Center = false
                    SliderText.Visible = self.Visible
                    
                    local ValueText = Drawing.new("Text")
                    ValueText.Text = Default..Units
                    ValueText.Size = 12
                    ValueText.Font = 5
                    ValueText.Color = Colors["Text"]
                    ValueText.Outline = true
                    ValueText.OutlineColor = {0, 0, 0}
                    ValueText.Transparency = 1
                    ValueText.Center = true
                    ValueText.Visible = self.Visible
                    
                    local SliderObj = {
                        Type = "Slider",
                        Name = SliderName,
                        Min = Min,
                        Max = Max,
                        Value = Default,
                        Units = Units,
                        Callback = Callback,
                        Background = SliderBackground,
                        Border = SliderBorder,
                        Fill = SliderFill,
                        Text = SliderText,
                        ValueText = ValueText,
                        DefaultBorderColor = Colors["Object Border"],
                        OriginalBackgroundColor = Colors["Object Background"],
                        Visible = self.Visible,
                        Dragging = false
                    }

function SliderObj:SetValue(NewValue)
    self.Value = math.clamp(NewValue, self.Min, self.Max)
    self.ValueText.Text = string.format("%.1f%s", self.Value, self.Units)
    if self.Background.Size and self.Background.Size.x then
        local FillWidth = ((self.Value - self.Min) / (self.Max - self.Min)) * self.Background.Size.x
        self.Fill.Size = {FillWidth, self.Background.Size.y}
    end
    if self.Callback then
        spawn(function() self.Callback(self.Value) end)
    end
end

table.insert(self.SliderObjects, SliderObj)
if IsVisible and Main.ActiveTab == TabContent.Name then
    Main:UpdateLayout()
end
return SliderObj
end

table.insert(self.Interfaces, ToggleObj)
if IsVisible and Main.ActiveTab == TabContent.Name then
    Main:UpdateLayout()
end
return ToggleObj
end

if Side == "Left" then
    table.insert(TabContent.LeftSections, SectionObj)
else
    table.insert(TabContent.RightSections, SectionObj)
end

if IsVisible and Main.ActiveTab == TabContent.Name then
    Main:UpdateLayout()
end
return SectionObj
end

local TabObj = {
    Name = TabName,
    Button = TabButton,
    ButtonBorder = TabButtonBorder,
    ButtonText = TabButtonText,
    SelectedHighlight = SelectedHighlight,
    Content = TabContent
}

table.insert(Main.Tabs, TabObj)
Main.TabContents[TabName] = TabContent

if not Main.ActiveTab then
    Main:SelectTab(TabName)
end

Main:UpdateTabSizes()
return TabContent
end

function Main:SelectTab(TabName)
    if not TabName or not Main.TabContents[TabName] then return end
    
    Main.ActiveTab = TabName
    
    for _, TabObj in ipairs(Main.Tabs) do
        local IsSelected = (TabObj.Name == TabName)
        TabObj.SelectedHighlight.Visible = IsVisible and IsSelected
        
        local LeftSections = TabObj.Content.LeftSections
        local RightSections = TabObj.Content.RightSections
        
        for _, SectionObj in ipairs(LeftSections) do
            SectionObj.Visible = IsSelected
            SetObjectVisibility(SectionObj.Background, IsVisible and IsSelected)
            SetObjectVisibility(SectionObj.Border, IsVisible and IsSelected)
            SetObjectVisibility(SectionObj.Title, IsVisible and IsSelected)
            
            if SectionObj.Interfaces then
                for _, Interface in ipairs(SectionObj.Interfaces) do
                    Interface.Visible = IsSelected
                    for k, v in pairs(Interface) do
                        if type(v) == "table" and v.Visible ~= nil then
                            SetObjectVisibility(v, IsVisible and IsSelected)
                        end
                    end
                    if Interface.Type == "Toggle" and Interface.SliderObjects then
                        for _, SliderObj in pairs(Interface.SliderObjects) do
                            for k, v in pairs(SliderObj) do
                                if type(v) == "table" and v.Visible ~= nil then
                                    SetObjectVisibility(v, IsVisible and IsSelected)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        for _, SectionObj in ipairs(RightSections) do
            SectionObj.Visible = IsSelected
            SetObjectVisibility(SectionObj.Background, IsVisible and IsSelected)
            SetObjectVisibility(SectionObj.Border, IsVisible and IsSelected)
            SetObjectVisibility(SectionObj.Title, IsVisible and IsSelected)
            
            if SectionObj.Interfaces then
                for _, Interface in ipairs(SectionObj.Interfaces) do
                    Interface.Visible = IsSelected
                    for k, v in pairs(Interface) do
                        if type(v) == "table" and v.Visible ~= nil then
                            SetObjectVisibility(v, IsVisible and IsSelected)
                        end
                    end
                    if Interface.Type == "Toggle" and Interface.SliderObjects then
                        for _, SliderObj in pairs(Interface.SliderObjects) do
                            for k, v in pairs(SliderObj) do
                                if type(v) == "table" and v.Visible ~= nil then
                                    SetObjectVisibility(v, IsVisible and IsSelected)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    Main:UpdateLayout()
end

function Main:CheckButtonHover()
    for _, TabObj in ipairs(Main.Tabs) do
        if TabObj.Button and Main:IsObjectHovered(TabObj.Button) then
            if HoveredButton ~= TabObj then
                if HoveredButton then
                    HoveredButton.ButtonBorder.Color = HoveredButton.DefaultBorderColor or Colors["Tab Border"]
                end
                HoveredButton = TabObj
                TabObj.ButtonBorder.Color = Colors["Accent"]
                TabObj.DefaultBorderColor = Colors["Tab Border"]
            end
            return true
        end
    end
    
    if Main.ActiveTab and Main.TabContents[Main.ActiveTab] then
        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
        local function CheckSectionInterfaces(Sections)
            for _, SectionObj in ipairs(Sections) do
                if SectionObj.Interfaces then
                    for _, Interface in ipairs(SectionObj.Interfaces) do
                        if Interface.Type == "Button" and Interface.ButtonBackground and Main:IsObjectHovered(Interface.ButtonBackground) then
                            if HoveredButton ~= Interface then
                                if HoveredButton then
                                    HoveredButton.ButtonBorder.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
                                end
                                HoveredButton = Interface
                                Interface.ButtonBorder.Color = Colors["Accent"]
                                Interface.DefaultBorderColor = Colors["Object Border"]
                            end
                            return true
                        elseif Interface.Type == "Toggle" then
                            if Interface.OuterBox and Main:IsObjectHovered(Interface.OuterBox) then
                                if HoveredButton ~= Interface then
                                    if HoveredButton then
                                        if HoveredButton.ButtonBorder then
                                            HoveredButton.ButtonBorder.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
                                        elseif HoveredButton.OuterBox then
                                            HoveredButton.OuterBox.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
                                        end
                                    end
                                    HoveredButton = Interface
                                    Interface.OuterBox.Color = Colors["Accent"]
                                    Interface.DefaultBorderColor = Colors["Object Border"]
                                end
                                return true
                            end
                            
                            if Interface.SliderObjects then
                                for _, SliderObj in pairs(Interface.SliderObjects) do
                                    if SliderObj.Background and Main:IsObjectHovered(SliderObj.Background) then
                                        if HoveredButton ~= SliderObj then
                                            if HoveredButton then
                                                if HoveredButton.ButtonBorder then
                                                    HoveredButton.ButtonBorder.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
                                                elseif HoveredButton.Border then
                                                    HoveredButton.Border.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
                                                elseif HoveredButton.OuterBox then
                                                    HoveredButton.OuterBox.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
                                                end
                                            end
                                            HoveredButton = SliderObj
                                            SliderObj.Border.Color = Colors["Accent"]
                                            SliderObj.DefaultBorderColor = Colors["Object Border"]
                                        end
                                        return true
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return false
        end
        
        if CheckSectionInterfaces(CurrentTabContent.LeftSections) or CheckSectionInterfaces(CurrentTabContent.RightSections) then
            return true
        end
    end
    
    if HoveredButton then
        if HoveredButton.ButtonBorder then
            HoveredButton.ButtonBorder.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
        elseif HoveredButton.Border then
            HoveredButton.Border.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
        elseif HoveredButton.OuterBox then
            HoveredButton.OuterBox.Color = HoveredButton.DefaultBorderColor or Colors["Object Border"]
        end
        HoveredButton = nil
    end
    return false
end

WindowActive = Main

spawn(function()
    while Running and WindowActive do
        local MousePos = getmouseposition()
        Mouse.X = MousePos.x
        Mouse.Y = MousePos.y
        Mouse.Clicked = isleftclicked()
        Mouse.Pressed = isleftpressed()
        
        if KeyPressed and KeyPressed == 45 then
            ToggleUI()
            KeyPressed = nil
        end
        
        if IsVisible then
            Main:CheckButtonHover()
            
            if HoveredButton and Mouse.Clicked and not Mouse.OldClicked then
                if HoveredButton.Name and Main.TabContents[HoveredButton.Name] then
                    Main:SelectTab(HoveredButton.Name)
                elseif HoveredButton.Type == "Button" and HoveredButton.Callback then
                    spawn(function() HoveredButton.Callback() end)
                elseif HoveredButton.Type == "Toggle" then
                    HoveredButton:SetState(not HoveredButton.State)
                end
            end
            
            if HoveredButton and HoveredButton.Type == "Slider" then
                if Mouse.Pressed then
                    HoveredButton.Dragging = true
                end
            end
            
            for _, TabContent in pairs(Main.TabContents) do
                local function CheckSectionSliders(Sections)
                    for _, SectionObj in ipairs(Sections) do
                        if SectionObj.Interfaces then
                            for _, Interface in ipairs(SectionObj.Interfaces) do
                                if Interface.Type == "Toggle" and Interface.SliderObjects then
                                    for _, SliderObj in pairs(Interface.SliderObjects) do
                                        if SliderObj.Dragging then
                                            if not Mouse.Pressed then
                                                SliderObj.Dragging = false
                                            else
                                                local RelativeX = Mouse.X - SliderObj.Background.Position.x
                                                local Width = SliderObj.Background.Size.x
                                                local Percent = math.clamp(RelativeX / Width, 0, 1)
                                                local Value = SliderObj.Min + ((SliderObj.Max - SliderObj.Min) * Percent)
                                                SliderObj:SetValue(Value)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                CheckSectionSliders(TabContent.LeftSections)
                CheckSectionSliders(TabContent.RightSections)
            end
            
            if Main:IsObjectHovered(Main.WindowBackground) and Mouse.Pressed and not IsDragging then
                if Mouse.Y < Main.WindowBackground.Position.y + 25 then
                    IsDragging = true
                    DragOffsetX = Mouse.X - Main.WindowBackground.Position.x
                    DragOffsetY = Mouse.Y - Main.WindowBackground.Position.y
                end
            end
            
            if IsDragging then
                if not Mouse.Pressed then
                    IsDragging = false
                else
                    local NewX = Mouse.X - DragOffsetX
                    local NewY = Mouse.Y - DragOffsetY
                    
                    Main.WindowBackground.Position = {NewX, NewY}
                    Main:UpdateElementPositions()
                end
            end
        end
        
        Mouse.OldClicked = Mouse.Clicked
        
        wait()
    end
end)

return Main
end

spawn(function()
    while Running do
        local key = getpressedkey()
        if key == "Insert" then
            ToggleUI()
        end
        KeyPressed = key
        wait()
    end
end)

return Library
