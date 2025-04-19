local Colors = {
    ["Accent"] = {203, 166, 247},
    ["DarkContrast"] = {17, 17, 27},
    ["LightContrast"] = {24, 24, 37},
    ["Border"] = {49, 50, 68},
    ["Selected"] = {255, 255, 255},
    ["Text"] = {210, 210, 210},
    ["DisabledText"] = {110, 110, 110}
}

local MouseService = findservice(Game, "MouseService")
local Mouse = {
    X = 0,
    Y = 0,
    Clicked = false,
    Pressed = false
}

local Library = {}
local ActiveWindow = nil
local IsDragging = false
local DragOffsetX = 0
local DragOffsetY = 0
local IsVisible = true
local IsToggled = false
local HoveredButton = nil
local Running = true

function Library:Unload()
    Running = false
    if ActiveWindow then
        IsDragging = false
        IsToggled = false
        HoveredButton = nil
        if ActiveWindow.Tabs then
            for _, Tab in ipairs(ActiveWindow.Tabs) do
                if Tab.Button then Tab.Button:Remove() end
                if Tab.ButtonBorder then Tab.ButtonBorder:Remove() end
                if Tab.ButtonText then Tab.ButtonText:Remove() end
                if Tab.SelectedHighlight then Tab.SelectedHighlight:Remove() end
                if Tab.Content then
                    if Tab.Content.LeftSections then
                        for _, Section in ipairs(Tab.Content.LeftSections) do
                            if Section.Background then Section.Background:Remove() end
                            if Section.Border then Section.Border:Remove() end
                            if Section.Title then Section.Title:Remove() end
                            if Section.Interfaces then
                                for _, Interface in ipairs(Section.Interfaces) do
                                    if Interface.Type == "Button" then
                                        if Interface.ButtonBackground then Interface.ButtonBackground:Remove() end
                                        if Interface.ButtonBorder then Interface.ButtonBorder:Remove() end
                                        if Interface.ButtonText then Interface.ButtonText:Remove() end
                                    elseif Interface.Type == "Toggle" then
                                        if Interface.OuterBox then Interface.OuterBox:Remove() end
                                        if Interface.InnerBox then Interface.InnerBox:Remove() end
                                        if Interface.Text then Interface.Text:Remove() end
                                        if Interface.KeybindBackground then Interface.KeybindBackground:Remove() end
                                        if Interface.KeybindBorder then Interface.KeybindBorder:Remove() end
                                        if Interface.KeybindText then Interface.KeybindText:Remove() end
                                        if Interface.ModeSelectorBackground then Interface.ModeSelectorBackground:Remove() end
                                        if Interface.ModeSelectorBorder then Interface.ModeSelectorBorder:Remove() end
                                        if Interface.HoldText then Interface.HoldText:Remove() end
                                        if Interface.ToggleText then Interface.ToggleText:Remove() end
                                        if Interface.ModeDivider then Interface.ModeDivider:Remove() end
                                    elseif Interface.Type == "Slider" then
                                        if Interface.Background then Interface.Background:Remove() end
                                        if Interface.Border then Interface.Border:Remove() end
                                        if Interface.Fill then Interface.Fill:Remove() end
                                        if Interface.Text then Interface.Text:Remove() end
                                        if Interface.ValueText then Interface.ValueText:Remove() end
                                        if Section.SectionTopLine then Section.SectionTopLine:Remove() end
                                    end
                                end
                            end
                        end
                    end
                    if Tab.Content.RightSections then
                        for _, Section in ipairs(Tab.Content.RightSections) do
                            if Section.Background then Section.Background:Remove() end
                            if Section.Border then Section.Border:Remove() end
                            if Section.Title then Section.Title:Remove() end
                            if Section.Interfaces then
                                for _, Interface in ipairs(Section.Interfaces) do
                                    if Interface.Type == "Button" then
                                        if Interface.ButtonBackground then Interface.ButtonBackground:Remove() end
                                        if Interface.ButtonBorder then Interface.ButtonBorder:Remove() end
                                        if Interface.ButtonText then Interface.ButtonText:Remove() end
                                    elseif Interface.Type == "Toggle" then
                                        if Interface.OuterBox then Interface.OuterBox:Remove() end
                                        if Interface.InnerBox then Interface.InnerBox:Remove() end
                                        if Interface.Text then Interface.Text:Remove() end
                                        if Interface.KeybindBackground then Interface.KeybindBackground:Remove() end
                                        if Interface.KeybindBorder then Interface.KeybindBorder:Remove() end
                                        if Interface.KeybindText then Interface.KeybindText:Remove() end
                                        if Interface.ModeSelectorBackground then Interface.ModeSelectorBackground:Remove() end
                                        if Interface.ModeSelectorBorder then Interface.ModeSelectorBorder:Remove() end
                                        if Interface.HoldText then Interface.HoldText:Remove() end
                                        if Interface.ToggleText then Interface.ToggleText:Remove() end
                                        if Interface.ModeDivider then Interface.ModeDivider:Remove() end
                                    elseif Interface.Type == "Slider" then
                                        if Interface.Background then Interface.Background:Remove() end
                                        if Interface.Border then Interface.Border:Remove() end
                                        if Interface.Fill then Interface.Fill:Remove() end
                                        if Interface.Text then Interface.Text:Remove() end
                                        if Interface.ValueText then Interface.ValueText:Remove() end
                                        if Section.SectionTopLine then Section.SectionTopLine:Remove() end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if ActiveWindow.WindowBackground then ActiveWindow.WindowBackground:Remove() end
        if ActiveWindow.Title then ActiveWindow.Title:Remove() end
        if ActiveWindow.TabBackground then ActiveWindow.TabBackground:Remove() end
        if ActiveWindow.TabBorder then ActiveWindow.TabBorder:Remove() end
        if ActiveWindow.WindowBackground2 then ActiveWindow.WindowBackground2:Remove() end
        if ActiveWindow.Window2Border then ActiveWindow.Window2Border:Remove() end
        if ActiveWindow.WindowBorder then ActiveWindow.WindowBorder:Remove() end
        ActiveWindow.Tabs = {}
        ActiveWindow.TabButtons = {}
        ActiveWindow.TabContents = {}
        ActiveWindow = nil
    end
    Drawing.clear()
    Library = nil
end

local function SetVisibility(Object, Visible)
    if Object and Object.Visible ~= nil then Object.Visible = Visible end
end

local function SetInterfaceVisibility(UI, Visible)
    for _, Element in pairs(UI) do
        if Element.Type == "Section" then
            SetVisibility(Element.Background, Visible)
            SetVisibility(Element.Border, Visible)
            SetVisibility(Element.Title, Visible)
            SetVisibility(Element.SectionTopLine, Visible)
            Element.Visible = Visible
            if Element.Interfaces then SetInterfaceVisibility(Element.Interfaces, Visible) end
        elseif Element.Type == "Button" or Element.Type == "Toggle" or Element.Type == "Slider" then
            for _, Property in pairs(Element) do
                if type(Property) == "table" and Property.Visible ~= nil then SetVisibility(Property, Visible) end
            end
            Element.Visible = Visible
        else
            if Element.Visible ~= nil then SetVisibility(Element, Visible) end
            if Element.Interfaces then SetInterfaceVisibility(Element.Interfaces, Visible) end
            if Element.Background and Element.Background.Visible ~= nil then SetVisibility(Element.Background, Visible) end
            if Element.Border and Element.Border.Visible ~= nil then SetVisibility(Element.Border, Visible) end
            if Element.Title and Element.Title.Visible ~= nil then SetVisibility(Element.Title, Visible) end
            if Element.SelectedHighlight and Element.SelectedHighlight.Visible ~= nil then SetVisibility(Element.SelectedHighlight, false) end
        end
    end
end

function ToggleUI()
    IsVisible = not IsVisible
    if ActiveWindow then
        local Main = ActiveWindow
        SetVisibility(Main.WindowBackground, IsVisible)
        SetVisibility(Main.Title, IsVisible)
        SetVisibility(Main.TabBackground, IsVisible)
        SetVisibility(Main.TabBorder, IsVisible)
        SetVisibility(Main.WindowBackground2, IsVisible)
        SetVisibility(Main.Window2Border, IsVisible)
        SetVisibility(Main.WindowBorder, IsVisible)
        for _, Tab in ipairs(Main.Tabs) do
            SetVisibility(Tab.Button, IsVisible)
            SetVisibility(Tab.ButtonBorder, IsVisible)
            SetVisibility(Tab.ButtonText, IsVisible)
            local ActiveTab = Tab.Name == Main.ActiveTab
            SetVisibility(Tab.SelectedHighlight, IsVisible and ActiveTab)
            SetInterfaceVisibility(Tab.Content.LeftSections, IsVisible and ActiveTab)
            SetInterfaceVisibility(Tab.Content.RightSections, IsVisible and ActiveTab)
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
        if Object and Object.Visible ~= nil then SetVisibility(Object, IsVisible) end
    end

    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 700}
    Main.WindowBackground.Position = {350, 100}
    Main.WindowBackground.Color = Colors["LightContrast"]
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
    Main.TabBackground.Color = Colors["DarkContrast"]
    Main.TabBackground.Filled = true
    Main.TabBackground.Thickness = 1
    Main.TabBackground.Transparency = 1
    SetInitialVisibility(Main.TabBackground)

    Main.TabBorder = Drawing.new("Square")
    Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
    Main.TabBorder.Size = {Main.TabBackground.Size.x, Main.TabBackground.Size.y}
    Main.TabBorder.Color = Colors["Border"]
    Main.TabBorder.Filled = false
    Main.TabBorder.Thickness = 1
    Main.TabBorder.Transparency = 1
    SetInitialVisibility(Main.TabBorder)

    Main.WindowBackground2 = Drawing.new("Square")
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 40}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 50}
    Main.WindowBackground2.Color = Colors["DarkContrast"]
    Main.WindowBackground2.Filled = true
    Main.WindowBackground2.Thickness = 1
    Main.WindowBackground2.Transparency = 1
    SetInitialVisibility(Main.WindowBackground2)

    Main.Window2Border = Drawing.new("Square")
    Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
    Main.Window2Border.Size = {Main.WindowBackground2.Size.x, Main.WindowBackground2.Size.y}
    Main.Window2Border.Color = Colors["Border"]
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

    function Main:IsHovered(Object)
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
            if Object.Center then ObjectX = ObjectX - ObjectW / 2 end
            ObjectY = ObjectY - ObjectH / 4
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and MouseY <= ObjectY + ObjectH
        end
        return false
    end

    function Main:IsWindowHovered()
        if not IsVisible then return false end
        return Main:IsHovered(Main.WindowBackground)
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
        for i, Tab in ipairs(Main.Tabs) do
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
            local Button = Tab.Button
            local ButtonBorder = Tab.ButtonBorder
            local ButtonText = Tab.ButtonText
            local Highlight = Tab.SelectedHighlight
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
        local InitialY = BaseY + Padding + 5
        local CurrentLeftY = InitialY
        local CurrentRightY = InitialY

        local function UpdateSectionLayout(Section, ColumnX, StartY, Width)
            local InnerWidth = Width - (Padding * 2)
            local LineThickness = 1
            local BorderThickness = Section.Border.Thickness

            SetVisibility(Section.Background, true)
            SetVisibility(Section.Border, true)
            SetVisibility(Section.Title, true)
            SetVisibility(Section.SectionTopLine, true)

            Section.Background.Position = {ColumnX + Padding, StartY}
            Section.Background.Size = {InnerWidth, 0}

            Section.Border.Position = {ColumnX + Padding - BorderThickness, StartY + Padding - 1}
            Section.Border.Size = {InnerWidth + BorderThickness * 2, 0}

            Section.SectionTopLine.Position = {ColumnX + Padding, StartY + Padding}
            Section.SectionTopLine.Size = {InnerWidth, LineThickness}
            Section.SectionTopLine.Color = Colors["Accent"]

            local TitleHeight = Section.Title.TextBounds and Section.Title.TextBounds.y
            Section.Title.Position = {ColumnX + Padding + Padding, StartY + Padding + LineThickness + Padding - 1.5}

            local CurrentInternalY = StartY + Padding + LineThickness + Padding + TitleHeight + Padding

            if Section.Interfaces then
                for _, Element in ipairs(Section.Interfaces) do
                    if Element.Type == "Button" then
                        local ButtonHeight = 18
                        local ButtonWidth = InnerWidth - (Padding * 2)
                        local ButtonX = ColumnX + Padding + Padding
                        local ButtonY = CurrentInternalY
                        SetVisibility(Element.ButtonBackground, true)
                        SetVisibility(Element.ButtonBorder, true)
                        SetVisibility(Element.ButtonText, true)
                        Element.ButtonBackground.Position = {ButtonX, ButtonY}
                        Element.ButtonBackground.Size = {ButtonWidth, ButtonHeight}
                        Element.ButtonBorder.Position = {ButtonX, ButtonY}
                        Element.ButtonBorder.Size = {ButtonWidth, ButtonHeight}
                        Element.ButtonText.Position = {ButtonX + math.floor(ButtonWidth / 2), ButtonY + math.floor(ButtonHeight / 2) - 7}
                        Element.ButtonText.Center = true
                        Element.ButtonText.Size = 13
                        CurrentInternalY = CurrentInternalY + ButtonHeight + Padding
                    elseif Element.Type == "Toggle" then
                        local ToggleHeight = 16
                        local ToggleWidth = 16
                        local TextWidth = InnerWidth - ToggleWidth - Padding
                        local ToggleX = ColumnX + Padding + Padding
                        local ToggleY = CurrentInternalY
                        SetVisibility(Element.OuterBox, true)
                        SetVisibility(Element.InnerBox, true)
                        SetVisibility(Element.Text, true)
                        Element.OuterBox.Position = {ToggleX, ToggleY}
                        Element.OuterBox.Size = {ToggleWidth, ToggleHeight}
                        Element.InnerBox.Position = {ToggleX + 1, ToggleY + 1}
                        Element.InnerBox.Size = {14, 14}
                        Element.Text.Position = {ToggleX + ToggleWidth + Padding, ToggleY + math.floor(ToggleHeight / 2) - 6}
                        Element.Text.Center = false
                        
                        if Element.KeybindBackground then
                            local KeybindWidth = 40
                            local KeybindX = ColumnX + InnerWidth - KeybindWidth + Padding
                            local KeybindY = ToggleY
                            SetVisibility(Element.KeybindBackground, true)
                            SetVisibility(Element.KeybindBorder, true)
                            SetVisibility(Element.KeybindText, true)
                            Element.KeybindBackground.Position = {KeybindX - 5, KeybindY}
                            Element.KeybindBackground.Size = {KeybindWidth, ToggleHeight}
                            Element.KeybindBorder.Position = {KeybindX - 5, KeybindY}
                            Element.KeybindBorder.Size = {KeybindWidth, ToggleHeight}
                            Element.KeybindText.Position = {
                                KeybindX - 5 + (KeybindWidth / 2),
                                KeybindY + (ToggleHeight / 2) - 6
                            }
                            Element.KeybindText.Center = true
                        end
                        
                        CurrentInternalY = CurrentInternalY + ToggleHeight + Padding
                    elseif Element.Type == "Slider" then
                        local SliderHeight = 15
                        local SliderWidth = InnerWidth - (Padding * 2)
                        local SliderX = ColumnX + Padding + Padding
                        local SliderY = CurrentInternalY + 14
                        SetVisibility(Element.Background, true)
                        SetVisibility(Element.Border, true)
                        SetVisibility(Element.Fill, true)
                        SetVisibility(Element.Text, true)
                        SetVisibility(Element.ValueText, true)
                        Element.Background.Position = {SliderX, SliderY}
                        Element.Background.Size = {SliderWidth, SliderHeight}
                        Element.Border.Position = {SliderX, SliderY}
                        Element.Border.Size = {SliderWidth, SliderHeight}
                        Element.Fill.Position = {SliderX, SliderY}
                        Element.Fill.Size = {((Element.Value - Element.Min) / (Element.Max - Element.Min)) * SliderWidth, SliderHeight}
                        Element.Text.Position = {SliderX, SliderY - 15}
                        local SliderCenterX = SliderX + (SliderWidth / 2)
                        local SliderCenterY = SliderY + (SliderHeight / 2) - 6.5
                        Element.ValueText.Position = {SliderCenterX, SliderCenterY}
                        Element.ValueText.Center = true
                        CurrentInternalY = CurrentInternalY + SliderHeight + Padding + 15
                    end
                end
            end
            local TotalSectionHeight = (CurrentInternalY - StartY)
            Section.Background.Size = {InnerWidth, TotalSectionHeight}
            Section.Border.Size = {InnerWidth + BorderThickness * 2, TotalSectionHeight + BorderThickness - Padding}
            Section.CalculatedHeight = TotalSectionHeight
            return StartY + TotalSectionHeight + Padding
        end

        for _, Section in ipairs(CurrentTabContent.LeftSections) do
            if Section.Visible then
                CurrentLeftY = UpdateSectionLayout(Section, LeftColumnX, CurrentLeftY, ColumnWidth)
            else
                SetVisibility(Section.Background, false)
                SetVisibility(Section.Border, false)
                SetVisibility(Section.Title, false)
                if Section.Interfaces then SetInterfaceVisibility(Section.Interfaces, false) end
            end
        end

        for _, Section in ipairs(CurrentTabContent.RightSections) do
            if Section.Visible then
                CurrentRightY = UpdateSectionLayout(Section, RightColumnX, CurrentRightY, ColumnWidth)
            else
                SetVisibility(Section.Background, false)
                SetVisibility(Section.Border, false)
                SetVisibility(Section.Title, false)
                if Section.Interfaces then SetInterfaceVisibility(Section.Interfaces, false) end
            end
        end
    end

    function Main:Tab(Options)
        local TabName = Options.Name or "Tab " .. (#Main.Tabs + 1)
        local TabButton = Drawing.new("Square")
        TabButton.Color = Colors["LightContrast"]
        TabButton.Filled = true
        TabButton.Thickness = 1
        TabButton.Transparency = 1
        SetInitialVisibility(TabButton)
        local TabButtonBorder = Drawing.new("Square")
        TabButtonBorder.Color = Colors["Border"]
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
            SectionBackground.Color = Colors["DarkContrast"]
            SectionBackground.Filled = true
            SectionBackground.Thickness = 1
            SectionBackground.Transparency = 1
            SectionBackground.Visible = false
            local SectionBorder = Drawing.new("Square")
            SectionBorder.Color = Colors["Border"]
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
            local Section = {
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

            function Section:Button(Options)
                local ButtonName = Options.Name or "Button"
                local Callback = Options.Callback or function() end
                local ButtonBackground = Drawing.new("Square")
                ButtonBackground.Color = Colors["LightContrast"]
                ButtonBackground.Filled = true
                ButtonBackground.Thickness = 1
                ButtonBackground.Transparency = 1
                ButtonBackground.Visible = self.Visible

                local ButtonBorder = Drawing.new("Square")
                ButtonBorder.Color = Colors["Border"]
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

                local Button = {
                    Type = "Button",
                    Name = ButtonName,
                    Callback = Callback,
                    ButtonBackground = ButtonBackground,
                    ButtonBorder = ButtonBorder,
                    ButtonText = ButtonText,
                    DefaultBorderColor = Colors["Border"],
                    OriginalBackgroundColor = Colors["LightContrast"],
                    OriginalBackgroundTransparency = 1,
                    Visible = self.Visible
                }
                table.insert(self.Interfaces, Button)
                if IsVisible and Main.ActiveTab == TabContent.Name then Main:UpdateLayout() end
                return Button
            end

            function Section:Toggle(Options)
                local ToggleName = Options.Name or "Toggle"
                local DefaultState = Options.Default or false
                local Callback = Options.Callback or function() end
                local ToggleOuterBox = Drawing.new("Square")
                ToggleOuterBox.Size = {18, 18}
                ToggleOuterBox.Filled = false
                ToggleOuterBox.Thickness = 1
                ToggleOuterBox.Transparency = 1
                ToggleOuterBox.Visible = self.Visible
                ToggleOuterBox.Color = Colors["Border"]
                local ToggleInnerBox = Drawing.new("Square")
                ToggleInnerBox.Size = {16, 16}
                ToggleInnerBox.Filled = true
                ToggleInnerBox.Thickness = 1
                ToggleInnerBox.Transparency = 0.65
                ToggleInnerBox.Visible = self.Visible
                ToggleInnerBox.Color = DefaultState and Colors["Accent"] or Colors["LightContrast"]
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
                
                local Toggle = {
                    Type = "Toggle",
                    Name = ToggleName,
                    State = ToggleState,
                    Callback = Callback,
                    OuterBox = ToggleOuterBox,
                    InnerBox = ToggleInnerBox,
                    Text = ToggleText,
                    DefaultBorderColor = Colors["Border"],
                    OriginalInnerColor = ToggleState and Colors["Accent"] or Colors["LightContrast"],
                    Visible = self.Visible,
                    LastKeyState = false
                }

                function Toggle:SetState(NewState)
                    self.State = NewState
                    self.InnerBox.Color = NewState and Colors["Accent"] or Colors["LightContrast"]
                    self.OriginalInnerColor = self.InnerBox.Color
                    if self.Callback then spawn(function() self.Callback(NewState) end) end
                end
                
                function Toggle:Keybind(Options)
                    local KeybindBackground = Drawing.new("Square")
                    KeybindBackground.Color = Colors["LightContrast"]
                    KeybindBackground.Filled = true
                    KeybindBackground.Thickness = 1
                    KeybindBackground.Transparency = 1
                    KeybindBackground.Visible = self.Visible
                    
                    local KeybindBorder = Drawing.new("Square")
                    KeybindBorder.Color = Colors["Border"]
                    KeybindBorder.Filled = false
                    KeybindBorder.Thickness = 1
                    KeybindBorder.Transparency = 1
                    KeybindBorder.Visible = self.Visible
                    
                    local KeybindText = Drawing.new("Text")
                    KeybindText.Text = (Options.Default and not Options.Default:find("Mouse")) and Options.Default or "None"
                    KeybindText.Size = 12
                    KeybindText.Font = 5
                    KeybindText.Color = Colors["Text"]
                    KeybindText.Outline = true
                    KeybindText.OutlineColor = {0, 0, 0}
                    KeybindText.Transparency = 1
                    KeybindText.Center = true
                    KeybindText.Visible = self.Visible

                    local ModeSelectorBackground = Drawing.new("Square")
                    ModeSelectorBackground.Color = Colors["LightContrast"]
                    ModeSelectorBackground.Filled = true
                    ModeSelectorBackground.Thickness = 1
                    ModeSelectorBackground.Transparency = 1
                    ModeSelectorBackground.Visible = false
                    ModeSelectorBackground.ZIndex = 999

                    local ModeSelectorBorder = Drawing.new("Square")
                    ModeSelectorBorder.Color = Colors["Border"]
                    ModeSelectorBorder.Filled = false
                    ModeSelectorBorder.Thickness = 1
                    ModeSelectorBorder.Transparency = 1
                    ModeSelectorBorder.Visible = false
                    ModeSelectorBorder.ZIndex = 999

                    local HoldText = Drawing.new("Text")
                    HoldText.Text = "Hold"
                    HoldText.Size = 12
                    HoldText.Font = 5
                    HoldText.Color = Colors["Text"]
                    HoldText.Outline = true
                    HoldText.OutlineColor = {0, 0, 0}
                    HoldText.Transparency = 1
                    HoldText.Center = true
                    HoldText.Visible = false
                    HoldText.ZIndex = 999

                    local ToggleText = Drawing.new("Text")
                    ToggleText.Text = "Toggle"
                    ToggleText.Size = 12
                    ToggleText.Font = 5
                    ToggleText.Color = Colors["Text"]
                    ToggleText.Outline = true
                    ToggleText.OutlineColor = {0, 0, 0}
                    ToggleText.Transparency = 1
                    ToggleText.Center = true
                    ToggleText.Visible = false
                    ToggleText.ZIndex = 999

                    local ModeDivider = Drawing.new("Square")
                    ModeDivider.Color = Colors["Border"]
                    ModeDivider.Filled = true
                    ModeDivider.Thickness = 1
                    ModeDivider.Transparency = 1
                    ModeDivider.Visible = false
                    ModeDivider.ZIndex = 999
                    
                    Toggle.KeybindBackground = KeybindBackground
                    Toggle.KeybindBorder = KeybindBorder
                    Toggle.KeybindText = KeybindText
                    Toggle.KeybindValue = (Options.Default and not Options.Default:find("Mouse")) and Options.Default or nil
                    Toggle.KeybindCallback = Options.Callback
                    Toggle.Listening = false
                    Toggle.KeybindMode = "Toggle"
                    Toggle.ModeSelectorBackground = ModeSelectorBackground
                    Toggle.ModeSelectorBorder = ModeSelectorBorder
                    Toggle.HoldText = HoldText
                    Toggle.ToggleText = ToggleText
                    Toggle.ModeDivider = ModeDivider
                    
                    function Toggle:SetKeybind(Key)
                        if Key == "Escape" then
                            self.KeybindValue = nil
                            self.KeybindText.Text = "None"
                        elseif Key and not Key:find("Mouse") then
                            self.KeybindValue = Key
                            self.KeybindText.Text = Key
                        end
                        if self.KeybindCallback then 
                            spawn(function() self.KeybindCallback(self.KeybindValue, self.KeybindMode) end) 
                        end
                    end

                    function Toggle:UpdateModeSelectorPosition()
                        if self.KeybindBackground.Position and self.KeybindBackground.Size then
                            local BgPos = self.KeybindBackground.Position
                            local BgSize = self.KeybindBackground.Size
                            local SelectorWidth = 60
                            local SelectorHeight = 30
                            
                            self.ModeSelectorBackground.Position = {BgPos.x + BgSize.x - SelectorWidth, BgPos.y - SelectorHeight - 5}
                            self.ModeSelectorBackground.Size = {SelectorWidth, SelectorHeight}
                            self.ModeSelectorBorder.Position = self.ModeSelectorBackground.Position
                            self.ModeSelectorBorder.Size = self.ModeSelectorBackground.Size
                            
                            self.HoldText.Position = {
                                self.ModeSelectorBackground.Position.x + (SelectorWidth / 2),
                                self.ModeSelectorBackground.Position.y + (SelectorHeight / 4) - 6
                            }
                            
                            self.ToggleText.Position = {
                                self.ModeSelectorBackground.Position.x + (SelectorWidth / 2),
                                self.ModeSelectorBackground.Position.y + (SelectorHeight * 0.75) - 6
                            }
                            
                            self.ModeDivider.Position = {
                                self.ModeSelectorBackground.Position.x,
                                self.ModeSelectorBackground.Position.y + (SelectorHeight / 2)
                            }
                            self.ModeDivider.Size = {SelectorWidth, 1}
                        end
                    end

                    function Toggle:ToggleModeSelector(Visible)
                        self.ModeSelectorBackground.Visible = Visible
                        self.ModeSelectorBorder.Visible = Visible
                        self.HoldText.Visible = Visible
                        self.ToggleText.Visible = Visible
                        self.ModeDivider.Visible = Visible
                    end
                    
                    spawn(function()
                        while Running and Toggle.KeybindBackground do
                            if Toggle.KeybindBackground.Position and Toggle.KeybindBackground.Size then
                                local BgPos = Toggle.KeybindBackground.Position
                                local BgSize = Toggle.KeybindBackground.Size
                                Toggle.KeybindText.Position = {
                                    BgPos.x + (BgSize.x / 2),
                                    BgPos.y + (BgSize.y / 2) - 6
                                }
                                Toggle:UpdateModeSelectorPosition()
                            end
                            wait()
                        end
                    end)
                    
                    return {
                        Set = function(Key) Toggle:SetKeybind(Key) end,
                        Get = function() return Toggle.KeybindValue end,
                        GetMode = function() return Toggle.KeybindMode end
                    }
                end
                
                table.insert(self.Interfaces, Toggle)
                if IsVisible and Main.ActiveTab == TabContent.Name then Main:UpdateLayout() end
                return Toggle
            end

            function Section:Slider(Options)
                local SliderName = Options.Name or "Slider"
                local Min = Options.Min or 0
                local Max = Options.Max or 100
                local Default = math.clamp(Options.Default or ((Max - Min) / 2), Min, Max)
                local Units = Options.Units or ""
                local Increment = Options.Increment or 1
                local Callback = Options.Callback or function() end

                local SliderBackground = Drawing.new("Square")
                SliderBackground.Color = Colors["LightContrast"]
                SliderBackground.Filled = true
                SliderBackground.Thickness = 1
                SliderBackground.Transparency = 1
                SliderBackground.Visible = self.Visible

                local SliderBorder = Drawing.new("Square")
                SliderBorder.Color = Colors["Border"]
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

                local Slider = {
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
                    DefaultBorderColor = Colors["Border"],
                    OriginalBackgroundColor = Colors["LightContrast"],
                    Visible = self.Visible,
                    Dragging = false
                }

                function Slider:SetValue(NewValue)
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
                    if self.Callback then spawn(function() self.Callback(self.Value) end) end
                end

                table.insert(self.Interfaces, Slider)
                if IsVisible and Main.ActiveTab == TabContent.Name then Main:UpdateLayout() end
                return Slider
            end

            if Side == "Left" then
                table.insert(self.LeftSections, Section)
            else
                table.insert(self.RightSections, Section)
            end
            if IsVisible and Main.ActiveTab == TabContent.Name then
                Section.Visible = true
                SetVisibility(SectionBackground, true)
                SetVisibility(SectionBorder, true)
                SetVisibility(SectionTitle, true)
                SetVisibility(SectionTopLine, true)
                Main:UpdateLayout()
            end
            return Section
        end

        local Tab = {
            Name = TabName,
            Button = TabButton,
            ButtonBorder = TabButtonBorder,
            ButtonText = TabButtonText,
            SelectedHighlight = SelectedHighlight,
            Content = TabContent
        }
        table.insert(Main.Tabs, Tab)
        Main.TabButtons[TabName] = Tab
        Main.TabContents[TabName] = TabContent
        Main:UpdateTabSizes()
        if #Main.Tabs == 1 and IsVisible then
            Main:SelectTab(TabName)
        elseif Main.ActiveTab and IsVisible then
            Main:SelectTab(Main.ActiveTab)
        else
            SetVisibility(TabButton, false)
            SetVisibility(TabButtonBorder, false)
            SetVisibility(TabButtonText, false)
            SetVisibility(SelectedHighlight, false)
            SetInterfaceVisibility(TabContent.LeftSections, false)
            SetInterfaceVisibility(TabContent.RightSections, false)
        end
        return TabContent
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then return end
        Main.ActiveTab = TabName
        if not IsVisible then return end
        for OtherTabName, OtherTab in pairs(Main.TabButtons) do
            local Selected = OtherTabName == TabName
            SetVisibility(OtherTab.SelectedHighlight, Selected)
            OtherTab.Content.Visible = Selected
            SetInterfaceVisibility(OtherTab.Content.LeftSections, Selected)
            SetInterfaceVisibility(OtherTab.Content.RightSections, Selected)
        end
        Main:UpdateLayout()
    end

    ActiveWindow = Main
    return Main
end

spawn(function()
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

        if IsVisible and ActiveWindow then
            if ActiveWindow:IsWindowHovered() then
                IsHovered = true
            end
            for _, Tab in ipairs(ActiveWindow.Tabs) do
                if Tab.Button.Visible and ActiveWindow:IsHovered(Tab.Button) then
                    IsHovered = true
                    break
                end
            end

            local WindowPos = ActiveWindow.WindowBackground.Position
            local DragAreaYMax = ActiveWindow.TabBackground.Position.y
            if Mouse.Clicked and IsHovered and Mouse.Y < DragAreaYMax and not IsDragging then
                IsDragging = true
                DragOffsetX = Mouse.X - WindowPos.x
                DragOffsetY = Mouse.Y - WindowPos.y
                UIClickHandled = true
            elseif Mouse.Pressed and IsDragging then
                IsHovered = true
                local NewX = Mouse.X - DragOffsetX
                local NewY = Mouse.Y - DragOffsetY
                ActiveWindow.WindowBackground.Position = {NewX, NewY}
                ActiveWindow:UpdateElementPositions()
                UIClickHandled = true
            elseif not Mouse.Pressed and IsDragging then
                IsDragging = false
            end

            if Mouse.Clicked and not IsDragging and not UIClickHandled then
                for _, Tab in ipairs(ActiveWindow.Tabs) do
                    if Tab.Button.Visible and ActiveWindow:IsHovered(Tab.Button) then
                        ActiveWindow:SelectTab(Tab.Name)
                        UIClickHandled = true
                        break
                    end
                end

                if not UIClickHandled and ActiveWindow.ActiveTab then
                    local CurrentTabContent = ActiveWindow.TabContents[ActiveWindow.ActiveTab]
                    if CurrentTabContent then
                        local function CheckButtonClick(Sections)
                            for _, Section in ipairs(Sections) do
                                if Section.Visible and Section.Interfaces then
                                    for _, Element in ipairs(Section.Interfaces) do
                                        if Element.Type == "Button" and Element.ButtonBackground.Visible then
                                            if ActiveWindow:IsHovered(Element.ButtonBackground) then
                                                Element.ButtonBackground.Color = Colors["Selected"]
                                                Element.ButtonBackground.Transparency = 0.085
                                                Element.ButtonBorder.Color = Colors["Accent"]
                                                local TargetButton = Element
                                                spawn(function()
                                                    wait(0.075)
                                                    if IsVisible and ActiveWindow and TargetButton and TargetButton.ButtonBackground.Visible then
                                                        TargetButton.ButtonBackground.Color = TargetButton.OriginalBackgroundColor
                                                        TargetButton.ButtonBackground.Transparency = TargetButton.OriginalBackgroundTransparency
                                                        TargetButton.ButtonBorder.Color = ActiveWindow:IsHovered(TargetButton.ButtonBackground) and Colors["Accent"] or TargetButton.DefaultBorderColor
                                                    end
                                                end)
                                                if Element.Callback then spawn(Element.Callback) end
                                                UIClickHandled = true
                                                return
                                            end
                                        elseif Element.Type == "Toggle" and Element.OuterBox.Visible then
                                            local ToggleX = Element.OuterBox.Position.x
                                            local ToggleY = Element.OuterBox.Position.y
                                            local ToggleWidth = Element.OuterBox.Size.x
                                            local ToggleHeight = Element.OuterBox.Size.y
                                            local TextX = Element.Text.Position.x
                                            local TextBoundsX = Element.Text.TextBounds.x
                                            local IsToggleHovered = Mouse.X >= ToggleX and Mouse.X <= TextX + TextBoundsX and Mouse.Y >= ToggleY and Mouse.Y <= ToggleY + ToggleHeight
                                            
                                            if Element.KeybindBackground then
                                                local KeybindX = Element.KeybindBackground.Position.x
                                                local KeybindWidth = Element.KeybindBackground.Size.x
                                                local IsKeybindHovered = Mouse.X >= KeybindX and Mouse.X <= KeybindX + KeybindWidth and Mouse.Y >= ToggleY and Mouse.Y <= ToggleY + ToggleHeight
                                                
                                                if IsKeybindHovered then
                                                    if Mouse.Clicked then
                                                        Element.KeybindText.Text = "..."
                                                        Element.Listening = true
                                                        UIClickHandled = true
                                                    elseif isrightclicked() then
                                                        Element:ToggleModeSelector(not Element.ModeSelectorBackground.Visible)
                                                        UIClickHandled = true
                                                    end
                                                elseif IsToggleHovered and Mouse.Clicked and not IsKeybindHovered then
                                                    Element:SetState(not Element.State)
                                                    UIClickHandled = true
                                                end
                                            elseif IsToggleHovered and Mouse.Clicked then
                                                Element:SetState(not Element.State)
                                                UIClickHandled = true
                                            end
                                        elseif Element.Type == "Slider" and Element.Background.Visible then
                                            if ActiveWindow:IsHovered(Element.Background) then
                                                if Mouse.Clicked then
                                                    Element.Dragging = true
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

            if ActiveWindow.ActiveTab then
                local CurrentTabContent = ActiveWindow.TabContents[ActiveWindow.ActiveTab]
                if CurrentTabContent then
                    local function UpdateButtonVisuals(Sections)
                        for _, Section in ipairs(Sections) do
                            if Section.Visible and Section.Interfaces then
                                for _, Element in ipairs(Section.Interfaces) do
                                    if Element.Type == "Button" then
                                        local Hovered = ActiveWindow:IsHovered(Element.ButtonBackground)
                                        if Hovered then
                                            IsHovered = true
                                            HoveredButton = Element
                                            Element.ButtonBorder.Color = Colors["Accent"]
                                        else
                                            Element.ButtonBorder.Color = Element.DefaultBorderColor
                                        end
                                    elseif Element.Type == "Toggle" then
                                        local ToggleX = Element.OuterBox.Position.x
                                        local ToggleY = Element.OuterBox.Position.y
                                        local ToggleWidth = Element.OuterBox.Size.x
                                        local ToggleHeight = Element.OuterBox.Size.y
                                        local TextX = Element.Text.Position.x
                                        local TextBoundsX = Element.Text.TextBounds.x
                                        local IsToggleHovered = Mouse.X >= ToggleX and Mouse.X <= TextX + TextBoundsX and Mouse.Y >= ToggleY and Mouse.Y <= ToggleY + ToggleHeight
                                        
                                        if Element.KeybindBackground then
                                            local KeybindX = Element.KeybindBackground.Position.x
                                            local KeybindWidth = Element.KeybindBackground.Size.x
                                            local IsKeybindHovered = Mouse.X >= KeybindX and Mouse.X <= KeybindX + KeybindWidth and Mouse.Y >= ToggleY and Mouse.Y <= ToggleY + ToggleHeight
                                            
                                            if IsKeybindHovered then
                                                IsHovered = true
                                                HoveredButton = Element
                                                Element.KeybindBorder.Color = Colors["Accent"]
                                                Element.OuterBox.Color = Element.DefaultBorderColor
                                            elseif IsToggleHovered then
                                                IsHovered = true
                                                HoveredButton = Element
                                                Element.OuterBox.Color = Colors["Accent"]
                                                Element.KeybindBorder.Color = Element.DefaultBorderColor
                                            else
                                                Element.OuterBox.Color = Element.DefaultBorderColor
                                                Element.KeybindBorder.Color = Element.DefaultBorderColor
                                            end
                                        elseif IsToggleHovered then
                                            IsHovered = true
                                            HoveredButton = Element
                                            Element.OuterBox.Color = Colors["Accent"]
                                        else
                                            Element.OuterBox.Color = Element.DefaultBorderColor
                                        end
                                    elseif Element.Type == "Slider" then
                                        local Hovered = ActiveWindow:IsHovered(Element.Background)
                                        if Hovered or Element.Dragging then
                                            IsHovered = true
                                            HoveredButton = Element
                                            Element.Border.Color = Colors["Accent"]
                                        else
                                            Element.Border.Color = Element.DefaultBorderColor
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
            if ActiveWindow.ActiveTab then
                local CurrentTabContent = ActiveWindow.TabContents[ActiveWindow.ActiveTab]
                if CurrentTabContent then
                    local function FindDraggingSlider(Sections)
                        for _, Section in ipairs(Sections) do
                            if Section.Visible and Section.Interfaces then
                                for _, Element in ipairs(Section.Interfaces) do
                                    if Element.Type == "Slider" and Element.Dragging then
                                        return Element
                                    end
                                end
                            end
                        end
                        return nil
                    end
                    ActiveSlider = FindDraggingSlider(CurrentTabContent.LeftSections) or FindDraggingSlider(CurrentTabContent.RightSections)
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
                if ActiveWindow.ActiveTab then
                    local CurrentTabContent = ActiveWindow.TabContents[ActiveWindow.ActiveTab]
                    if CurrentTabContent then
                        local function StopDraggingSliders(Sections)
                            for _, Section in ipairs(Sections) do
                                if Section.Visible and Section.Interfaces then
                                    for _, Element in ipairs(Section.Interfaces) do
                                        if Element.Type == "Slider" and Element.Dragging then
                                            Element.Dragging = false
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
            
            if ActiveWindow.ActiveTab then
                local CurrentTabContent = ActiveWindow.TabContents[ActiveWindow.ActiveTab]
                if CurrentTabContent then
                    local function CheckKeybindListening(Sections)
                        for _, Section in ipairs(Sections) do
                            if Section.Visible and Section.Interfaces then
                                for _, Element in ipairs(Section.Interfaces) do
                                    if Element.Type == "Toggle" and Element.Listening then
                                        local Keys = getpressedkeys()
                                        if #Keys > 0 then
                                            local Key = Keys[1]
                                            if Key == "Escape" then
                                                Element.KeybindValue = nil
                                                Element.KeybindText.Text = "None"
                                                Element.Listening = false
                                                if Element.KeybindCallback then
                                                    spawn(function() Element.KeybindCallback(nil, Element.KeybindMode) end)
                                                end
                                            elseif Key ~= "MouseButton1" 
                                            and Key ~= "MouseButton2" 
                                            and not Key:find("Mouse") then
                                                Element.KeybindValue = Key
                                                Element.KeybindText.Text = Key
                                                Element.Listening = false
                                                if Element.KeybindCallback then
                                                    spawn(function() Element.KeybindCallback(Key, Element.KeybindMode) end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    local function CheckModeSelectorClick(Sections)
                        for _, Section in ipairs(Sections) do
                            if Section.Visible and Section.Interfaces then
                                for _, Element in ipairs(Section.Interfaces) do
                                    if Element.Type == "Toggle" and Element.ModeSelectorBackground and Element.ModeSelectorBackground.Visible then
                                        local SelectorPos = Element.ModeSelectorBackground.Position
                                        local SelectorSize = Element.ModeSelectorBackground.Size
                                        if Mouse.Clicked then
                                            if Mouse.X >= SelectorPos.x and Mouse.X <= SelectorPos.x + SelectorSize.x and
                                               Mouse.Y >= SelectorPos.y and Mouse.Y <= SelectorPos.y + (SelectorSize.y / 2) then
                                                Element.KeybindMode = "Hold"
                                                Element:ToggleModeSelector(false)
                                                UIClickHandled = true
                                            elseif Mouse.X >= SelectorPos.x and Mouse.X <= SelectorPos.x + SelectorSize.x and
                                                   Mouse.Y >= SelectorPos.y + (SelectorSize.y / 2) and Mouse.Y <= SelectorPos.y + SelectorSize.y then
                                                Element.KeybindMode = "Toggle"
                                                Element:ToggleModeSelector(false)
                                                UIClickHandled = true
                                            elseif not (Mouse.X >= SelectorPos.x and Mouse.X <= SelectorPos.x + SelectorSize.x and
                                                      Mouse.Y >= SelectorPos.y and Mouse.Y <= SelectorPos.y + SelectorSize.y) then
                                                Element:ToggleModeSelector(false)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    local function CheckKeybindStates(Sections)
                        for _, Section in ipairs(Sections) do
                            if Section.Visible and Section.Interfaces then
                                for _, Element in ipairs(Section.Interfaces) do
                                    if Element.Type == "Toggle" and Element.KeybindValue and not Element.Listening then
                                        local Keys = getpressedkeys()
                                        local KeyPressed = false
                                        for _, K in ipairs(Keys) do
                                            if K == Element.KeybindValue then
                                                KeyPressed = true
                                                break
                                            end
                                        end
                                        
                                        if Element.KeybindMode == "Hold" then
                                            Element:SetState(KeyPressed)
                                        elseif Element.KeybindMode == "Toggle" and KeyPressed and not Element.LastKeyState then
                                            Element:SetState(not Element.State)
                                        end
                                        Element.LastKeyState = KeyPressed
                                    end
                                end
                            end
                        end
                    end

                    CheckKeybindListening(CurrentTabContent.LeftSections)
                    CheckKeybindListening(CurrentTabContent.RightSections)
                    CheckModeSelectorClick(CurrentTabContent.LeftSections)
                    CheckModeSelectorClick(CurrentTabContent.RightSections)
                    CheckKeybindStates(CurrentTabContent.LeftSections)
                    CheckKeybindStates(CurrentTabContent.RightSections)
                end
            end
        end
        wait()
    end
end)

return Library
