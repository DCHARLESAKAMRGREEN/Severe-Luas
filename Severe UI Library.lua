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

local Library = {} -- Initialize Library here

local WindowActive = nil
local IsDragging = false
local DragOffsetX = 0
local DragOffsetY = 0
local IsVisible = true
local IsToggled = false
local HoveredButton = nil
local Running = true

Library.Unload = function() -- Changed to Library.Unload
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
        elseif Object.Type == "Button" or Object.Type == "Toggle" then -- Slider is handled differently
            for K,V in pairs(Object) do
                if type(V) == "table" and V.Visible ~= nil then
                    SetObjectVisibility(V, Visible)
                end
            end
            Object.Visible = Visible
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

local function ToggleUI()
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

Library.Create = function(Options) -- Changed to Library.Create
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
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY <= ObjectY + ObjectH
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

                        if Object.Slider then
                            local SliderHeight = 18
                            local SliderWidth = Width - (Padding * 2)
                            local SliderX = ColumnX + Padding
                            local SliderY = CurrentInternalY + 15
                            SetObjectVisibility(Object.Slider.Background, true)
                            SetObjectVisibility(Object.Slider.Border, true)
                            SetObjectVisibility(Object.Slider.Fill, true)
                            SetObjectVisibility(Object.Slider.Text, true)
                            SetObjectVisibility(Object.Slider.ValueText, true)
                            Object.Slider.Background.Position = {SliderX, SliderY}
                            Object.Slider.Background.Size = {SliderWidth, SliderHeight}
                            Object.Slider.Border.Position = {SliderX, SliderY}
                            Object.Slider.Border.Size = {SliderWidth, SliderHeight}
                            Object.Slider.Fill.Position = {SliderX, SliderY}
                            Object.Slider.Fill.Size = {((Object.Slider.Value - Object.Slider.Min) / (Object.Slider.Max - Object.Slider.Min)) * SliderWidth, SliderHeight}
                            Object.Slider.Text.Position = {SliderX, SliderY - 15}
                            Object.Slider.ValueText.Position = {SliderX + SliderWidth / 2, SliderY + SliderHeight / 2 - 6} -- Centered Value Text
                            Object.Slider.ValueText.Center = true
                            CurrentInternalY = CurrentInternalY + SliderHeight + Padding + 15
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
                    Visible = self.Visible
                }

                function ToggleObj:SetState(NewState)
                    self.State = NewState
                    self.InnerBox.Color = NewState and Colors["Accent"] or Colors["Object Background"]
                    self.OriginalInnerColor = self.InnerBox.Color
                    if self.Callback then
                        spawn(function() self.Callback(NewState) end)
                    end
                end

                table.insert(self.Interfaces, ToggleObj)

                -- Create and store the slider if options are provided
                if Options.Slider then
                    local SliderOptions = Options.Slider
                    local SliderObj = self:Slider({
                        Name = SliderOptions.Name,
                        Min = SliderOptions.Min,
                        Max = SliderOptions.Max,
                        Default = SliderOptions.Default,
                        Units = SliderOptions.Units,
                        Callback = SliderOptions.Callback,
                    })
                    ToggleObj.Slider = SliderObj
                end

                if IsVisible and Main.ActiveTab == TabContent.Name then
                    Main:UpdateLayout()
                end
                return ToggleObj
            end

            function SectionObj:Slider(Options)
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
                ValueText.Center = false
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

                table.insert(self.Interfaces, SliderObj)
                if IsVisible and Main.ActiveTab == TabContent.Name then
                    Main:UpdateLayout()
                end
                return SliderObj
            end

            if Side == "Left" then
                table.insert(self.LeftSections, SectionObj)
            else
                table.insert(self.RightSections, SectionObj)
            end
            if IsVisible and Main.ActiveTab == TabContent.Name then
                SectionObj.Visible = true
                SetObjectVisibility(SectionBackground, true)
                SetObjectVisibility(SectionBorder, true)
                SetObjectVisibility(SectionTitle, true)
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
        table.insert(Main.TabButtons, TabButton)

        local TabIndex = #Main.Tabs
        local function TabButtonCallback()
            Main:SelectTab(TabName)
        end

        TabButton.Callback = TabButtonCallback
        TabButtonBorder.Callback = TabButtonCallback
        TabButtonText.Callback = TabButtonCallback
        Main:UpdateTabSizes()
        if #Main.Tabs == 1 then
            Main:SelectTab(TabName)
        end
        return TabContent
    end

    function Main:SelectTab(TabName)
        Main.ActiveTab = TabName
        for _, TabObj in ipairs(Main.Tabs) do
            local IsActiveTab = TabObj.Name == TabName
            SetObjectVisibility(TabObj.SelectedHighlight, IsVisible and IsActiveTab)
            SetInterfaceVisibility(TabObj.Content.LeftSections, IsVisible and IsActiveTab)
            SetInterfaceVisibility(TabObj.Content.RightSections, IsVisible and IsActiveTab)
        end
        Main:UpdateLayout()
    end

    WindowActive = Main
    spawn(function()
        while Running do
            Mouse.X, Mouse.Y = getscreendimensions()
            Mouse.X = Mouse.X / 2
            Mouse.Y = Mouse.Y / 2
            Mouse.Pressed = isleftpressed()
            Mouse.Clicked = isleftclicked()

            if IsVisible and WindowActive then
                if Main:IsWindowHovered() and Mouse.Pressed and not IsDragging then
                    IsDragging = true
                    DragOffsetX = Mouse.X - Main.WindowBackground.Position.x
                    DragOffsetY = Mouse.Y - Main.WindowBackground.Position.y
                elseif not Mouse.Pressed then
                    IsDragging = false
                end

                if IsDragging then
                    Main.WindowBackground.Position = {Mouse.X - DragOffsetX, Mouse.Y - DragOffsetY}
                    Main:UpdateElementPositions()
                end

                local function CheckButtonHover(Sections)
                    for _, SectionObj in ipairs(Sections) do
                        if SectionObj.Visible and SectionObj.Interfaces then
                            for _, Object in ipairs(SectionObj.Interfaces) do
                                if Object.Type == "Button" then
                                    local IsHovered = Main:IsObjectHovered(Object.ButtonBackground)
                                    if IsHovered then
                                        HoveredButton = Object
                                        Object.ButtonBackground.Color = {
                                            math.min(Object.OriginalBackgroundColor[1] + 10, 255),
                                            math.min(Object.OriginalBackgroundColor[2] + 10, 255),
                                            math.min(Object.OriginalBackgroundColor[3] + 10, 255)
                                        }
                                        Object.ButtonBorder.Color = Colors["Accent"]
                                    else
                                        if HoveredButton == Object then
                                            HoveredButton = nil
                                        end
                                        Object.ButtonBackground.Color = Object.OriginalBackgroundColor
                                        Object.ButtonBorder.Color = Object.DefaultBorderColor
                                    end
                                elseif Object.Type == "Toggle" then
                                    local IsHovered = Main:IsObjectHovered(Object.OuterBox)
                                    if IsHovered then
                                        Object.OuterBox.Color = Colors["Accent"]
                                    else
                                        Object.OuterBox.Color = Object.DefaultBorderColor
                                    end
                                end
                            end
                        end
                    end
                end

                if WindowActive.ActiveTab then
                    local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                    if CurrentTabContent then
                        CheckButtonHover(CurrentTabContent.LeftSections)
                        CheckButtonHover(CurrentTabContent.RightSections)
                    end
                end

                if Mouse.Clicked then
                    if WindowActive.ActiveTab then
                        local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                        if CurrentTabContent then
                            for _, SectionObj in ipairs(CurrentTabContent.LeftSections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for _, Object in ipairs(SectionObj.Interfaces) do
                                        if Object.Type == "Button" and Main:IsObjectHovered(Object.ButtonBackground) then
                                            if Object.Callback then
                                                spawn(function() Object.Callback() end)
                                            end
                                        elseif Object.Type == "Toggle" and Main:IsObjectHovered(Object.OuterBox) then
                                            Object:SetState(not Object.State)
                                        end
                                    end
                                end
                            end
                            for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for _, Object in ipairs(SectionObj.Interfaces) do
                                        if Object.Type == "Button" and Main:IsObjectHovered(Object.ButtonBackground) then
                                            if Object.Callback then
                                                spawn(function() Object.Callback() end)
                                            end
                                        elseif Object.Type == "Toggle" and Main:IsObjectHovered(Object.OuterBox) then
                                            Object:SetState(not Object.State)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    for _, TabObj in ipairs(WindowActive.Tabs) do
                        if Main:IsObjectHovered(TabObj.Button) then
                            if TabObj.Button.Callback then
                                TabObj.Button.Callback()
                            end
                        end
                    end
                end

                -- Slider Interaction
                local ActiveSlider = nil
                if WindowActive.ActiveTab then
                    local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                    if CurrentTabContent then
                        local function FindActiveSlider(Sections)
                            for _, SectionObj in ipairs(Sections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for _, Object in ipairs(SectionObj.Interfaces) do
                                        if Object.Type == "Slider" and Main:IsObjectHovered(Object.Background) then
                                            ActiveSlider = Object
                                            Object.Dragging = true
                                            break
                                        end
                                    end
                                    if ActiveSlider then
                                        break
                                    end
                                end
                            end
                        end
                        FindActiveSlider(CurrentTabContent.LeftSections)
                        if not ActiveSlider then
                            FindActiveSlider(CurrentTabContent.RightSections)
                        end
                    end
                end

                if ActiveSlider and ActiveSlider.Dragging then
                    local SliderX = ActiveSlider.Background.Position.x
                    local SliderWidth = ActiveSlider.Background.Size.x
                    local Ratio = math.clamp((Mouse.X - SliderX) / SliderWidth, 0, 1)
                    local NewValue = (ActiveSlider.Max - ActiveSlider.Min) * Ratio + ActiveSlider.Min
                    ActiveSlider:SetValue(NewValue) -- Update slider value while dragging
                end
            end

             -- Stop Slider Dragging (Add this section)
            if not Mouse.Pressed then
                 if WindowActive.ActiveTab then
                     local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                     if CurrentTabContent then
                         local function StopDraggingSliders(Sections)
                             for _, SectionObj in ipairs(Sections) do
                                 if SectionObj.Visible and SectionObj.Interfaces then
                                     for _, Object in ipairs(SectionObj.Interfaces) do
                                         if Object.Type == "Slider" and Object.Dragging then
                                             Object.Dragging = false
                                         end
                                     end
                                 end
                             end
                         end
                         StopDraggingSliders(CurrentTabContent.LeftSections)
                         StopDraggingSliders(CurrentTabContent.RightSections)
                     end
                 end
            end

        end -- End of 'if IsVisible and WindowActive then'
        wait()
    end -- End of 'while Running do'
end) -- End of 'spawn(function()

return Library
