local Colors = {
    ["Accent"] = {203, 166, 247},
    ["Window Background"] = {24, 24, 37},
    ["Window Background 2"] = {17, 17, 27},
    ["Window Border"] = {49, 50, 68},
    ["Tab Background"] = {17, 17, 27},
    ["Tab Border"] = {49, 50, 68},
    ["Tab Toggle Background"] = {24, 24, 37},
    ["Selected"] = {255, 255, 255},
    ["Section Background"] = {17, 17, 27},
    ["Section Border"] = {49, 50, 68},
    ["Text"] = {210, 210, 210},
    ["Disabled Text"] = {110, 110, 110},
    ["Object Background"] = {24, 24, 37},
    ["Object Border"] = {49, 50, 68},
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
        IsDragging = false
        IsToggled = false
        HoveredButton = nil

        if WindowActive.Tabs then
            for _, TabObj in ipairs(WindowActive.Tabs) do
                if TabObj.Button then
                    TabObj.Button:Remove()
                end
                if TabObj.ButtonBorder then
                    TabObj.ButtonBorder:Remove()
                end
                if TabObj.ButtonText then
                    TabObj.ButtonText:Remove()
                end
                if TabObj.SelectedHighlight then
                    TabObj.SelectedHighlight:Remove()
                end

                if TabObj.Content then
                    if TabObj.Content.LeftSections then
                        for _, SectionObj in ipairs(TabObj.Content.LeftSections) do
                            if SectionObj.Background then
                                SectionObj.Background:Remove()
                            end
                            if SectionObj.Border then
                                SectionObj.Border:Remove()
                            end
                            if SectionObj.Title then
                                SectionObj.Title:Remove()
                            end
                            if SectionObj.Interfaces then
                                for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                                    if InterfaceObj.Type == "Button" then
                                        if InterfaceObj.ButtonBackground then
                                            InterfaceObj.ButtonBackground:Remove()
                                        end
                                        if InterfaceObj.ButtonBorder then
                                            InterfaceObj.ButtonBorder:Remove()
                                        end
                                        if InterfaceObj.ButtonText then
                                            InterfaceObj.ButtonText:Remove()
                                        end
                                    elseif InterfaceObj.Type == "Toggle" then
                                        if InterfaceObj.OuterBox then
                                            InterfaceObj.OuterBox:Remove()
                                        end
                                        if InterfaceObj.InnerBox then
                                            InterfaceObj.InnerBox:Remove()
                                        end
                                        if InterfaceObj.Text then
                                            InterfaceObj.Text:Remove()
                                        end
                                    elseif InterfaceObj.Type == "Slider" then
                                        if InterfaceObj.Background then
                                            InterfaceObj.Background:Remove()
                                        end
                                        if InterfaceObj.Border then
                                            InterfaceObj.Border:Remove()
                                        end
                                        if InterfaceObj.Fill then
                                            InterfaceObj.Fill:Remove()
                                        end
                                        if InterfaceObj.Text then
                                            InterfaceObj.Text:Remove()
                                        end
                                        if InterfaceObj.ValueText then
                                            InterfaceObj.ValueText:Remove()
                                            if SectionObj.SectionTopLine then
                                                SectionObj.SectionTopLine:Remove()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if TabObj.Content.RightSections then
                        for _, SectionObj in ipairs(TabObj.Content.RightSections) do
                            if SectionObj.Background then
                                SectionObj.Background:Remove()
                            end
                            if SectionObj.Border then
                                SectionObj.Border:Remove()
                            end
                            if SectionObj.Title then
                                SectionObj.Title:Remove()
                            end

                            if SectionObj.Interfaces then
                                for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                                    if InterfaceObj.Type == "Button" then
                                        if InterfaceObj.ButtonBackground then
                                            InterfaceObj.ButtonBackground:Remove()
                                        end
                                        if InterfaceObj.ButtonBorder then
                                            InterfaceObj.ButtonBorder:Remove()
                                        end
                                        if InterfaceObj.ButtonText then
                                            InterfaceObj.ButtonText:Remove()
                                        end
                                    elseif InterfaceObj.Type == "Toggle" then
                                        if InterfaceObj.OuterBox then
                                            InterfaceObj.OuterBox:Remove()
                                        end
                                        if InterfaceObj.InnerBox then
                                            InterfaceObj.InnerBox:Remove()
                                        end
                                        if InterfaceObj.Text then
                                            InterfaceObj.Text:Remove()
                                        end
                                    elseif InterfaceObj.Type == "Slider" then
                                        if InterfaceObj.Background then
                                            InterfaceObj.Background:Remove()
                                        end
                                        if InterfaceObj.Border then
                                            InterfaceObj.Border:Remove()
                                        end
                                        if InterfaceObj.Fill then
                                            InterfaceObj.Fill:Remove()
                                        end
                                        if InterfaceObj.Text then
                                            InterfaceObj.Text:Remove()
                                        end
                                        if InterfaceObj.ValueText then
                                            InterfaceObj.ValueText:Remove()
                                            if SectionObj.SectionTopLine then
                                                SectionObj.SectionTopLine:Remove()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if WindowActive.WindowBackground then
            WindowActive.WindowBackground:Remove()
        end
        if WindowActive.Title then
            WindowActive.Title:Remove()
        end
        if WindowActive.TabBackground then
            WindowActive.TabBackground:Remove()
        end
        if WindowActive.TabBorder then
            WindowActive.TabBorder:Remove()
        end
        if WindowActive.WindowBackground2 then
            WindowActive.WindowBackground2:Remove()
        end
        if WindowActive.Window2Border then
            WindowActive.Window2Border:Remove()
        end
        if WindowActive.WindowBorder then
            WindowActive.WindowBorder:Remove()
        end

        WindowActive.Tabs = {}
        WindowActive.TabButtons = {}
        WindowActive.TabContents = {}
        WindowActive = nil
    end

    Drawing.clear()

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
            SetObjectVisibility(Object.SectionTopLine, Visible)
            Object.Visible = Visible
            if Object.Interfaces then
                SetInterfaceVisibility(Object.Interfaces, Visible)
            end
        elseif Object.Type == "Button" or Object.Type == "Toggle" or Object.Type == "Slider" then
            for K, V in pairs(Object) do
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
    Main.TabBackground.Size = {Main.WindowBackground.Size.x - 20, 19}
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
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 40}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 50}
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
    Main.WindowBorder.Thickness = 1.25
    Main.WindowBorder.Transparency = 1
    SetInitialVisibility(Main.WindowBorder)

    Main.Tabs = {}
    Main.TabButtons = {}
    Main.TabContents = {}
    Main.ActiveTab = nil

    function Main:IsObjectHovered(Object)
        if not IsVisible or not Object or not Object.Visible then
            return false
        end
        local MouseX, MouseY = Mouse.X, Mouse.Y
        local ObjectPos = Object.Position
        if not ObjectPos then
            return false
        end
        local ObjectX, ObjectY = ObjectPos.x, ObjectPos.y

        if Object.Size then
            local ObjectSize = Object.Size
            local ObjectW, ObjectH = ObjectSize.x, ObjectSize.y
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and
                MouseY <= ObjectY + ObjectH
        elseif Object.TextBounds then
            local ObjectBounds = Object.TextBounds
            local ObjectW, ObjectH = ObjectBounds.x, ObjectBounds.y
            if Object.Center then
                ObjectX = ObjectX - ObjectW / 2
            end
            ObjectY = ObjectY - ObjectH / 4
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and
                MouseY <= ObjectY + ObjectH
        end
        return false
    end

    function Main:IsWindowHovered()
        if not IsVisible then
            return false
        end
        return Main:IsObjectHovered(Main.WindowBackground)
    end

    function Main:UpdateElementPositions()
        local BasePos = Main.WindowBackground.Position
        local BaseX, BaseY = BasePos.x, BasePos.y
        Main.Title.Position = {BaseX + 10, BaseY + 5}
        Main.TabBackground.Position = {BaseX + 10, BaseY + 25}
        Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
        Main.WindowBackground2.Position = {BaseX + 10, BaseY + 40}
        Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
        Main.WindowBorder.Position = {BaseX, BaseY}
        Main:UpdateLayout()
    end

    function Main:UpdateTabSizes()
        local TabCount = #Main.Tabs
        if TabCount == 0 then
            return
        end
        local TabBackgroundPos = Main.TabBackground.Position
        local TabBackgroundSize = Main.TabBackground.Size
        local TotalWidth = TabBackgroundSize.x
        local StartXBase = TabBackgroundPos.x
        local TabY = TabBackgroundPos.y
        local TabH = TabBackgroundSize.y
        if TotalWidth <= 0 then
            return
        end
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
            if RoundedWidth <= 0 then
                RoundedWidth = 1
            end
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
        if not Main.ActiveTab or not Main.TabContents[Main.ActiveTab] then
            return
        end
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
        local InitialY = BaseY + Padding + 5
        local CurrentLeftY = InitialY
        local CurrentRightY = InitialY

        local function UpdateSectionLayout(SectionObj, ColumnX, StartY, Width)
            local InnerWidth = Width - (Padding * 2)
            local LineThickness = 1
            local BorderThickness = SectionObj.Border.Thickness

            SetObjectVisibility(SectionObj.Background, true)
            SetObjectVisibility(SectionObj.Border, true)
            SetObjectVisibility(SectionObj.Title, true)
            SetObjectVisibility(SectionObj.SectionTopLine, true)

            SectionObj.Background.Position = {ColumnX + Padding, StartY}
            SectionObj.Background.Size = {InnerWidth, 0}

            SectionObj.Border.Position = {ColumnX + Padding - BorderThickness, StartY + Padding - 1}
            SectionObj.Border.Size = {InnerWidth + BorderThickness * 2, 0}

            SectionObj.SectionTopLine.Position = {ColumnX + Padding, StartY + Padding}
            SectionObj.SectionTopLine.Size = {InnerWidth, LineThickness}
            SectionObj.SectionTopLine.Color = Colors["Accent"]

            local TitleHeight = SectionObj.Title.TextBounds and SectionObj.Title.TextBounds.y
            SectionObj.Title.Position = {ColumnX + Padding + Padding, StartY + Padding + LineThickness + Padding - 1.5}

            local CurrentInternalY = StartY + Padding + LineThickness + Padding + TitleHeight + Padding

            if SectionObj.Interfaces then
                for _, Object in ipairs(SectionObj.Interfaces) do
                    if Object.Type == "Button" then
                        local ButtonHeight = 18
                        local ButtonWidth = InnerWidth - (Padding * 2)
                        local ButtonX = ColumnX + Padding + Padding
                        local ButtonY = CurrentInternalY
                        SetObjectVisibility(Object.ButtonBackground, true)
                        SetObjectVisibility(Object.ButtonBorder, true)
                        SetObjectVisibility(Object.ButtonText, true)
                        Object.ButtonBackground.Position = {ButtonX, ButtonY}
                        Object.ButtonBackground.Size = {ButtonWidth, ButtonHeight}
                        Object.ButtonBorder.Position = {ButtonX, ButtonY}
                        Object.ButtonBorder.Size = {ButtonWidth, ButtonHeight}
                        Object.ButtonText.Position = {
                            ButtonX + math.floor(ButtonWidth / 2),
                            ButtonY + math.floor(ButtonHeight / 2) - 7
                        }
                        Object.ButtonText.Center = true
                        Object.ButtonText.Size = 13
                        CurrentInternalY = CurrentInternalY + ButtonHeight + Padding
                    elseif Object.Type == "Toggle" then
                        local ToggleHeight = 16
                        local ToggleWidth = 16
                        local TextWidth = InnerWidth - ToggleWidth - Padding
                        local ToggleX = ColumnX + Padding + Padding
                        local ToggleY = CurrentInternalY
                        SetObjectVisibility(Object.OuterBox, true)
                        SetObjectVisibility(Object.InnerBox, true)
                        SetObjectVisibility(Object.Text, true)
                        Object.OuterBox.Position = {ToggleX, ToggleY}
                        Object.OuterBox.Size = {ToggleWidth, ToggleHeight}
                        Object.InnerBox.Position = {ToggleX + 1, ToggleY + 1}
                        Object.InnerBox.Size = {14, 14}
                        Object.Text.Position = {
                            ToggleX + ToggleWidth + Padding,
                            ToggleY + math.floor(ToggleHeight / 2) - 6
                        }
                        Object.Text.Center = false
                        CurrentInternalY = CurrentInternalY + ToggleHeight + Padding
                    elseif Object.Type == "Slider" then
                        local SliderHeight = 15
                        local SliderWidth = InnerWidth - (Padding * 2)
                        local SliderX = ColumnX + Padding + Padding
                        local SliderY = CurrentInternalY + 14
                        SetObjectVisibility(Object.Background, true)
                        SetObjectVisibility(Object.Border, true)
                        SetObjectVisibility(Object.Fill, true)
                        SetObjectVisibility(Object.Text, true)
                        SetObjectVisibility(Object.ValueText, true)
                        Object.Background.Position = {SliderX, SliderY}
                        Object.Background.Size = {SliderWidth, SliderHeight}
                        Object.Border.Position = {SliderX, SliderY}
                        Object.Border.Size = {SliderWidth, SliderHeight}
                        Object.Fill.Position = {SliderX, SliderY}
                        Object.Fill.Size = {
                            ((Object.Value - Object.Min) / (Object.Max - Object.Min)) * SliderWidth,
                            SliderHeight
                        }
                        Object.Text.Position = {SliderX, SliderY - 15}

                        local SliderCenterX = SliderX + (SliderWidth / 2)
                        local SliderCenterY = SliderY + (SliderHeight / 2) - 6.5
                        Object.ValueText.Position = {SliderCenterX, SliderCenterY}
                        Object.ValueText.Center = true

                        CurrentInternalY = CurrentInternalY + SliderHeight + Padding + 15
                    end
                end
            end
            local TotalSectionHeight = (CurrentInternalY - StartY)
            SectionObj.Background.Size = {InnerWidth, TotalSectionHeight}
            SectionObj.Border.Size = {InnerWidth + BorderThickness * 2, TotalSectionHeight + BorderThickness - Padding}
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
                if SectionObj.Interfaces then
                    SetInterfaceVisibility(SectionObj.Interfaces, false)
                end
            end
        end

        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
            if SectionObj.Visible then
                CurrentRightY = UpdateSectionLayout(SectionObj, RightColumnX, CurrentRightY, ColumnWidth)
            else
                SetObjectVisibility(SectionObj.Background, false)
                SetObjectVisibility(SectionObj.Border, false)
                SetObjectVisibility(SectionObj.Title, false)
                if SectionObj.Interfaces then
                    SetInterfaceVisibility(SectionObj.Interfaces, false)
                end
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
        TabButtonText.Size = 13
        TabButtonText.Font = 5
        TabButtonText.Color = Colors["Text"]
        TabButtonText.Outline = true
        TabButtonText.OutlineColor = {0, 0, 0}
        TabButtonText.Transparency = 1
        TabButtonText.Center = true
        SetInitialVisibility(TabButtonText)
        local SelectedHighlight = Drawing.new("Square")
        SelectedHighlight.Color = Colors["Selected"]
        SelectedHighlight.Transparency = 0.085
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
            local SectionTopLine = Drawing.new("Square")
            SectionTopLine.Color = Colors["Accent"]
            SectionTopLine.Filled = true
            SectionTopLine.Thickness = 1
            SectionTopLine.Transparency = 1
            SectionTopLine.Visible = false
            local SectionObj = {
                Type = "Section",
                Name = SectionName,
                Side = Side,
                Background = SectionBackground,
                Border = SectionBorder,
                Title = SectionTitle,
                SectionTopLine = SectionTopLine,
                Interfaces = {},
                Visible = false,
                CalculatedHeight = 0
            }

            function SectionObj:Button(Options)
                local ButtonName = Options.Name or "Button"
                local Callback = Options.Callback or function()
                    end
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
                ButtonText.Size = 13
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
                local Callback = Options.Callback or function()
                    end
                local ToggleOuterBox = Drawing.new("Square")
                ToggleOuterBox.Size = {18, 18}
                ToggleOuterBox.Filled = false
                ToggleOuterBox.Thickness = 1
                ToggleOuterBox.Transparency = 1
                ToggleOuterBox.Visible = self.Visible
                ToggleOuterBox.Color = Colors["Object Border"]
                local ToggleInnerBox = Drawing.new("Square")
                ToggleInnerBox.Size = {16, 16}
                ToggleInnerBox.Filled = true
                ToggleInnerBox.Thickness = 1
                ToggleInnerBox.Transparency = 0.65
                ToggleInnerBox.Visible = self.Visible
                ToggleInnerBox.Color = DefaultState and Colors["Accent"] or Colors["Object Background"]
                local ToggleText = Drawing.new("Text")
                ToggleText.Text = ToggleName
                ToggleText.Size = 13
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
                        spawn(
                            function()
                                self.Callback(NewState)
                            end
                        )
                    end
                end

                table.insert(self.Interfaces, ToggleObj)
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
                local Increment = Options.Increment or 1
                local Callback = Options.Callback or function()
                    end

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
                SliderFill.Transparency = 0.65
                SliderFill.Visible = self.Visible

                local SliderText = Drawing.new("Text")
                SliderText.Text = SliderName
                SliderText.Size = 13
                SliderText.Font = 5
                SliderText.Color = Colors["Text"]
                SliderText.Outline = true
                SliderText.OutlineColor = {0, 0, 0}
                SliderText.Transparency = 1
                SliderText.Center = false
                SliderText.Visible = self.Visible

                local ValueText = Drawing.new("Text")
                ValueText.Text = Default .. Units
                ValueText.Size = 13
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
                    Increment = Increment,
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
                    local snappedValue = Min + (math.floor((NewValue - Min) / self.Increment + 0.5) * self.Increment)
                    self.Value = math.clamp(snappedValue, self.Min, self.Max)

                    local format = "%.0f%s"
                    if self.Increment < 1 then
                        local decimalPlaces = math.max(0, math.ceil(math.abs(math.log10(self.Increment))))
                        format = "%." .. decimalPlaces .. "f%s"
                    end

                    self.ValueText.Text = string.format(format, self.Value, self.Units)

                    if self.Background.Size and self.Background.Size.x then
                        local FillWidth = ((self.Value - self.Min) / (self.Max - self.Min)) * self.Background.Size.x
                        self.Fill.Size = {FillWidth, self.Background.Size.y}

                        local SliderCenterX = self.Background.Position.x + (self.Background.Size.x / 2)
                        local SliderCenterY = self.Background.Position.y + (self.Background.Size.y / 2) - 6.5
                        self.ValueText.Position = {SliderCenterX, SliderCenterY}
                    end
                    if self.Callback then
                        spawn(
                            function()
                                self.Callback(self.Value)
                            end
                        )
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
                SetObjectVisibility(SectionTopLine, true)
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
        Main.TabButtons[TabName] = TabObj
        Main.TabContents[TabName] = TabContent
        Main:UpdateTabSizes()
        if #Main.Tabs == 1 and IsVisible then
            Main:SelectTab(TabName)
        elseif Main.ActiveTab and IsVisible then
            Main:SelectTab(Main.ActiveTab)
        else
            SetObjectVisibility(TabButton, false)
            SetObjectVisibility(TabButtonBorder, false)
            SetObjectVisibility(TabButtonText, false)
            SetObjectVisibility(SelectedHighlight, false)
            SetInterfaceVisibility(TabContent.LeftSections, false)
            SetInterfaceVisibility(TabContent.RightSections, false)
        end
        return TabContent
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then
            return
        end
        Main.ActiveTab = TabName
        if not IsVisible then
            return
        end
        for OtherTabName, OtherTab in pairs(Main.TabButtons) do
            local IsSelected = OtherTabName == TabName
            SetObjectVisibility(OtherTab.SelectedHighlight, IsSelected)
            OtherTab.Content.Visible = IsSelected
            SetInterfaceVisibility(OtherTab.Content.LeftSections, IsSelected)
            SetInterfaceVisibility(OtherTab.Content.RightSections, IsSelected)
        end
        Main:UpdateLayout()
    end

    WindowActive = Main
    return Main
end

spawn(
    function()
        while Running do
            local MouseLocation = getmouselocation(MouseService)
            Mouse.X = MouseLocation.x
            Mouse.Y = MouseLocation.y
            Mouse.Clicked = isleftclicked()
            Mouse.Pressed = isleftpressed()
            HoveredButton = nil
            local UIClickHandled = false
            local IsHovered = false
            local Keys = getpressedkeys()
            local IsTogglePressed = false

            for _, K in ipairs(Keys) do
                if K == "P" then
                    IsTogglePressed = true
                    break
                end
            end

            if IsTogglePressed and not IsToggled then
                ToggleUI()
            end
            IsToggled = IsTogglePressed

            if IsVisible and WindowActive then
                if WindowActive:IsWindowHovered() then
                    IsHovered = true
                end
                for _, TabObj in ipairs(WindowActive.Tabs) do
                    if TabObj.Button.Visible and WindowActive:IsObjectHovered(TabObj.Button) then
                        IsHovered = true
                        break
                    end
                end

                local WindowPos = WindowActive.WindowBackground.Position
                local DragAreaYMax = WindowActive.TabBackground.Position.y
                if Mouse.Clicked and IsHovered and Mouse.Y < DragAreaYMax and not IsDragging then
                    IsDragging = true
                    DragOffsetX = Mouse.X - WindowPos.x
                    DragOffsetY = Mouse.Y - WindowPos.y
                    UIClickHandled = true
                elseif Mouse.Pressed and IsDragging then
                    IsHovered = true
                    local NewX = Mouse.X - DragOffsetX
                    local NewY = Mouse.Y - DragOffsetY
                    WindowActive.WindowBackground.Position = {NewX, NewY}
                    WindowActive:UpdateElementPositions()
                    UIClickHandled = true
                elseif not Mouse.Pressed and IsDragging then
                    IsDragging = false
                end

                if Mouse.Clicked and not IsDragging and not UIClickHandled then
                    for _, TabObj in ipairs(WindowActive.Tabs) do
                        if TabObj.Button.Visible and WindowActive:IsObjectHovered(TabObj.Button) then
                            WindowActive:SelectTab(TabObj.Name)
                            UIClickHandled = true
                            break
                        end
                    end

                    if not UIClickHandled and WindowActive.ActiveTab then
                        local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                        if CurrentTabContent then
                            local function CheckButtonClick(Sections)
                                for _, SectionObj in ipairs(Sections) do
                                    if SectionObj.Visible and SectionObj.Interfaces then
                                        for InterfaceIndex, Object in ipairs(SectionObj.Interfaces) do
                                            if Object.Type == "Button" and Object.ButtonBackground.Visible then
                                                if WindowActive:IsObjectHovered(Object.ButtonBackground) then
                                                    Object.ButtonBackground.Color = Colors["Selected"]
                                                    Object.ButtonBackground.Transparency = 0.085
                                                    Object.ButtonBorder.Color = Colors["Accent"]
                                                    local TargetButtonObj = Object
                                                    spawn(
                                                        function()
                                                            wait(0.075)
                                                            if
                                                                IsVisible and WindowActive and TargetButtonObj and
                                                                    TargetButtonObj.ButtonBackground.Visible
                                                             then
                                                                TargetButtonObj.ButtonBackground.Color =
                                                                    TargetButtonObj.OriginalBackgroundColor
                                                                TargetButtonObj.ButtonBackground.Transparency =
                                                                    TargetButtonObj.OriginalBackgroundTransparency
                                                                TargetButtonObj.ButtonBorder.Color =
                                                                    WindowActive:IsObjectHovered(
                                                                    TargetButtonObj.ButtonBackground
                                                                ) and
                                                                    Colors["Accent"] or
                                                                    TargetButtonObj.DefaultBorderColor
                                                            end
                                                        end
                                                    )
                                                    if Object.Callback then
                                                        spawn(Object.Callback)
                                                    end
                                                    UIClickHandled = true
                                                    return
                                                end
                                            elseif Object.Type == "Toggle" and Object.OuterBox.Visible then
                                                local ToggleX = Object.OuterBox.Position.x
                                                local ToggleY = Object.OuterBox.Position.y
                                                local ToggleWidth = Object.OuterBox.Size.x
                                                local ToggleHeight = Object.OuterBox.Size.y
                                                local TextX = Object.Text.Position.x
                                                local TextBoundsX = Object.Text.TextBounds.x
                                                local IsToggleHovered =
                                                    Mouse.X >= ToggleX and Mouse.X <= TextX + TextBoundsX and
                                                    Mouse.Y >= ToggleY and
                                                    Mouse.Y <= ToggleY + ToggleHeight

                                                if IsToggleHovered then
                                                    Object:SetState(not Object.State)
                                                    UIClickHandled = true
                                                    return
                                                end
                                            elseif Object.Type == "Slider" and Object.Background.Visible then
                                                if WindowActive:IsObjectHovered(Object.Background) then
                                                    if Mouse.Clicked then
                                                        Object.Dragging = true
                                                        UIClickHandled = true
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            CheckButtonClick(CurrentTabContent.LeftSections)
                            CheckButtonClick(CurrentTabContent.RightSections)
                        end
                    end
                end

                if WindowActive.ActiveTab then
                    local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                    if CurrentTabContent then
                        local function UpdateButtonVisuals(Sections)
                            for _, SectionObj in ipairs(Sections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for InterfaceIndex, Object in ipairs(SectionObj.Interfaces) do
                                        if Object.Type == "Button" then
                                            local Hovered = WindowActive:IsObjectHovered(Object.ButtonBackground)
                                            if Hovered then
                                                IsHovered = true
                                                HoveredButton = Object
                                                Object.ButtonBorder.Color = Colors["Accent"]
                                            else
                                                Object.ButtonBorder.Color = Object.DefaultBorderColor
                                            end
                                        elseif Object.Type == "Toggle" then
                                            local ToggleX = Object.OuterBox.Position.x
                                            local ToggleY = Object.OuterBox.Position.y
                                            local ToggleWidth = Object.OuterBox.Size.x
                                            local ToggleHeight = Object.OuterBox.Size.y
                                            local TextX = Object.Text.Position.x
                                            local TextBoundsX = Object.Text.TextBounds.x
                                            local IsToggleHovered =
                                                Mouse.X >= ToggleX and Mouse.X <= TextX + TextBoundsX and
                                                Mouse.Y >= ToggleY and
                                                Mouse.Y <= ToggleY + ToggleHeight
                                            if IsToggleHovered then
                                                IsHovered = true
                                                HoveredButton = Object
                                                Object.OuterBox.Color = Colors["Accent"]
                                            else
                                                Object.OuterBox.Color = Object.DefaultBorderColor
                                            end
                                        elseif Object.Type == "Slider" then
                                            local Hovered = WindowActive:IsObjectHovered(Object.Background)
                                            if Hovered or Object.Dragging then
                                                IsHovered = true
                                                HoveredButton = Object
                                                Object.Border.Color = Colors["Accent"]
                                            else
                                                Object.Border.Color = Object.DefaultBorderColor
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        UpdateButtonVisuals(CurrentTabContent.LeftSections)
                        UpdateButtonVisuals(CurrentTabContent.RightSections)
                    end
                end

                local ActiveSlider = nil
                if WindowActive.ActiveTab then
                    local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                    if CurrentTabContent then
                        local function FindDraggingSlider(Sections)
                            for _, SectionObj in ipairs(Sections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for _, Object in ipairs(SectionObj.Interfaces) do
                                        if Object.Type == "Slider" and Object.Dragging then
                                            return Object
                                        end
                                    end
                                end
                            end
                            return nil
                        end
                        ActiveSlider =
                            FindDraggingSlider(CurrentTabContent.LeftSections) or
                            FindDraggingSlider(CurrentTabContent.RightSections)
                    end
                end

                if ActiveSlider and Mouse.Pressed then
                    IsHovered = true
                    UIClickHandled = true
                    local MouseX = Mouse.X
                    local SliderX = ActiveSlider.Background.Position.x
                    local SliderW = ActiveSlider.Background.Size.x
                    if SliderW > 0 then
                        local Ratio = math.clamp((MouseX - SliderX) / SliderW, 0, 1)
                        local RawValue = ActiveSlider.Min + (ActiveSlider.Max - ActiveSlider.Min) * Ratio
                        ActiveSlider:SetValue(RawValue)
                    end
                end

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
            end
            wait()
        end
    end
)

return Library
