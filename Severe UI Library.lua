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
            if Object.ToggleSlider then
                SetObjectVisibility(Object.ToggleSlider.Background, Visible)
                SetObjectVisibility(Object.ToggleSlider.Border, Visible)
                SetObjectVisibility(Object.ToggleSlider.Fill, Visible)
                SetObjectVisibility(Object.ToggleSlider.ValueText, Visible)
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
            -- Ensure all values are numbers before comparison
            if type(MouseX) ~= "number" or type(MouseY) ~= "number" or
               type(ObjectX) ~= "number" or type(ObjectY) ~= "number" or
               type(ObjectW) ~= "number" or type(ObjectH) ~= "number" then
                return false  -- Or handle the error appropriately
            end
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and MouseY <= ObjectY + ObjectH
        elseif Object.TextBounds then
            local ObjectBounds = Object.TextBounds
            local ObjectW, ObjectH = ObjectBounds.x, ObjectBounds.y
            if Object.Center then
                ObjectX = ObjectX - ObjectW / 2
            end
            ObjectY = ObjectY - ObjectH / 4
             -- Ensure all values are numbers before comparison
            if type(MouseX) ~= "number" or type(MouseY) ~= "number" or
               type(ObjectX) ~= "number" or type(ObjectY) ~= "number" or
               type(ObjectW) ~= "number" or type(ObjectH) ~= "number" then
                return false  -- Or handle the error appropriately
            end
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
                        Object.ButtonText.Position = {ButtonX + (ButtonWidth / 2), ButtonY + (ButtonHeight / 2) - 7}
                        Object.ButtonText.Center = true
                        CurrentInternalY = ButtonY + ButtonHeight + Padding
                    elseif Object.Type == "Toggle" then
                        local ToggleHeight = 18
                        local ToggleWidth = Width - (Padding * 2)
                        local ToggleX = ColumnX + Padding
                        local ToggleY = CurrentInternalY
                        SetObjectVisibility(Object.ToggleBackground, true)
                        SetObjectVisibility(Object.ToggleBorder, true)
                        SetObjectVisibility(Object.ToggleText, true)
                        Object.ToggleBackground.Position = {ToggleX, ToggleY}
                        Object.ToggleBackground.Size = {ToggleWidth, ToggleHeight}
                        Object.ToggleBorder.Position = {ToggleX, ToggleY}
                        Object.ToggleBorder.Size = {ToggleWidth, ToggleHeight}
                        Object.ToggleText.Position = {ToggleX + (ToggleWidth / 2), ToggleY + (ToggleHeight / 2) - 7}
                        Object.ToggleText.Center = true
                        CurrentInternalY = ToggleY + ToggleHeight + Padding
                        if Object.ToggleSlider then
                            local SliderHeight = 18
                            local SliderWidth = Width - (Padding * 2)
                            local SliderX = ColumnX + Padding
                            local SliderY = CurrentInternalY
                            SetObjectVisibility(Object.ToggleSlider.Background, true)
                            SetObjectVisibility(Object.ToggleSlider.Border, true)
                            SetObjectVisibility(Object.ToggleSlider.Fill, true)
                            SetObjectVisibility(Object.ToggleSlider.ValueText, true)
                            Object.ToggleSlider.Background.Position = {SliderX, SliderY}
                            Object.ToggleSlider.Background.Size = {SliderWidth, SliderHeight}
                            Object.ToggleSlider.Border.Position = {SliderX, SliderY}
                            Object.ToggleSlider.Border.Size = {SliderWidth, SliderHeight}
                            local FillWidth = (Object.ToggleSlider.Value - Object.ToggleSlider.Min) / (Object.ToggleSlider.Max - Object.ToggleSlider.Min) * SliderWidth
                            Object.ToggleSlider.Fill.Position = {SliderX, SliderY}
                            Object.ToggleSlider.Fill.Size = {FillWidth, SliderHeight}
                            local ValueTextX = SliderX + (SliderWidth / 2)
                            local ValueTextY = SliderY + (SliderHeight / 2) - 7
                            Object.ToggleSlider.ValueText.Position = {ValueTextX, ValueTextY}
                            Object.ToggleSlider.ValueText.Center = true
                            CurrentInternalY = SliderY + SliderHeight + Padding
                        end
                    elseif Object.Type == "Slider" then
                        local SliderHeight = 18
                        local SliderWidth = Width - (Padding * 2)
                        local SliderX = ColumnX + Padding
                        local SliderY = CurrentInternalY
                        SetObjectVisibility(Object.Background, true)
                        SetObjectVisibility(Object.Border, true)
                        SetObjectVisibility(Object.Fill, true)
                        SetObjectVisibility(Object.ValueText, true)
                        Object.Background.Position = {SliderX, SliderY}
                        Object.Background.Size = {SliderWidth, SliderHeight}
                        Object.Border.Position = {SliderX, SliderY}
                        Object.Border.Size = {SliderWidth, SliderHeight}
                        local FillWidth = (Object.Value - Object.Min) / (Object.Max - Object.Min) * SliderWidth
                        Object.Fill.Position = {SliderX, SliderY}
                        Object.Fill.Size = {FillWidth, SliderHeight}
                        local ValueTextX = SliderX + (SliderWidth / 2)
                        local ValueTextY = SliderY + (SliderHeight / 2) - 7
                        Object.ValueText.Position = {ValueTextX, ValueTextY}
                        Object.ValueText.Center = true
                        CurrentInternalY = SliderY + SliderHeight + Padding
                    end
                end
            end
            local SectionHeight = CurrentInternalY - StartY
            SectionObj.Background.Size = {Width, SectionHeight}
            SectionObj.Border.Size = {Width, SectionHeight}
            return SectionHeight
        end

        if CurrentTabContent.LeftSections then
            for _, SectionObj in ipairs(CurrentTabContent.LeftSections) do
                local SectionHeight = UpdateSectionLayout(SectionObj, LeftColumnX, CurrentLeftY, ColumnWidth)
                CurrentLeftY = CurrentLeftY + SectionHeight + Padding
            end
        end

        if CurrentTabContent.RightSections then
            for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
                local SectionHeight = UpdateSectionLayout(SectionObj, RightColumnX, CurrentRightY, ColumnWidth)
                CurrentRightY = CurrentRightY + SectionHeight + Padding
            end
        end
    end

    function Main:AddTab(TabName)
        local TabButton = Drawing.new("Square")
        TabButton.Color = Colors["Tab Background"]
        TabButton.Filled = true
        TabButton.Thickness = 1
        TabButton.Transparency = 1

        local TabButtonBorder = Drawing.new("Square")
        TabButtonBorder.Color = Colors["Tab Border"]
        TabButtonBorder.Filled = false
        TabButtonBorder.Thickness = 1
        TabButtonBorder.Transparency = 1

        local TabButtonText = Drawing.new("Text")
        TabButtonText.Text = TabName
        TabButtonText.Size = 12
        TabButtonText.Font = 5
        TabButtonText.Color = Colors["Text"]
        TabButtonText.Outline = true
        TabButtonText.OutlineColor = {0, 0, 0}
        TabButtonText.Transparency = 1
        TabButtonText.Center = true

        local SelectedHighlight = Drawing.new("Square")
        SelectedHighlight.Color = Colors["Accent"]
        SelectedHighlight.Filled = false
        SelectedHighlight.Thickness = 2
        SelectedHighlight.Transparency = 1
        SelectedHighlight.Visible = false

        local TabObj = {
            Name = TabName,
            Button = TabButton,
            ButtonBorder = TabButtonBorder,
            ButtonText = TabButtonText,
            SelectedHighlight = SelectedHighlight,
            Content = {
                LeftSections = {},
                RightSections = {}
            }
        }

        table.insert(Main.Tabs, TabObj)
        Main.TabContents[TabName] = TabObj.Content
        Main:UpdateTabSizes()
        if not Main.ActiveTab then
            Main:SelectTab(TabName)
        end
    end

    function Main:SelectTab(TabName)
        if Main.ActiveTab == TabName then return end
        if Main.ActiveTab then
            local PreviousTab = Main.TabContents[Main.ActiveTab]
            if PreviousTab then
                SetInterfaceVisibility(PreviousTab.LeftSections, false)
                SetInterfaceVisibility(PreviousTab.RightSections, false)
            end
            local PreviousTabObj = Main.Tabs[table.find(Main.Tabs, function(Tab) return Tab.Name == Main.ActiveTab end)]
            if PreviousTabObj then
                PreviousTabObj.SelectedHighlight.Visible = false
            end
        end
        Main.ActiveTab = TabName
        local NewTab = Main.TabContents[TabName]
        if NewTab then
            SetInterfaceVisibility(NewTab.LeftSections, true)
            SetInterfaceVisibility(NewTab.RightSections, true)
        end
        local NewTabObj = Main.Tabs[table.find(Main.Tabs, function(Tab) return Tab.Name == TabName end)]
        if NewTabObj then
            NewTabObj.SelectedHighlight.Visible = true
        end
        Main:UpdateLayout()
    end

    function Main:AddSection(TabName, SectionName, Side)
        if not Main.TabContents[TabName] then return end
        local SectionBackground = Drawing.new("Square")
        SectionBackground.Color = Colors["Section Background"]
        SectionBackground.Filled = true
        SectionBackground.Thickness = 1
        SectionBackground.Transparency = 1

        local SectionBorder = Drawing.new("Square")
        SectionBorder.Color = Colors["Section Border"]
        SectionBorder.Filled = false
        SectionBorder.Thickness = 1
        SectionBorder.Transparency = 1

        local SectionTitle = Drawing.new("Text")
        SectionTitle.Text = SectionName
        SectionTitle.Size = 12
        SectionTitle.Font = 5
        SectionTitle.Color = Colors["Text"]
        SectionTitle.Outline = true
        SectionTitle.OutlineColor = {0, 0, 0}
        SectionTitle.Transparency = 1
        SectionTitle.Center = false

        local SectionObj = {
            Name = SectionName,
            Background = SectionBackground,
            Border = SectionBorder,
            Title = SectionTitle,
            Interfaces = {},
            Type = "Section"
        }

        if Side == "Left" then
            table.insert(Main.TabContents[TabName].LeftSections, SectionObj)
        elseif Side == "Right" then
            table.insert(Main.TabContents[TabName].RightSections, SectionObj)
        end
        Main:UpdateLayout()
        return SectionObj
    end

    function Main:AddButton(Section, ButtonName, Callback)
        if not Section then return end
        local ButtonBackground = Drawing.new("Square")
        ButtonBackground.Color = Colors["Object Background"]
        ButtonBackground.Filled = true
        ButtonBackground.Thickness = 1
        ButtonBackground.Transparency = 1

        local ButtonBorder = Drawing.new("Square")
        ButtonBorder.Color = Colors["Object Border"]
        ButtonBorder.Filled = false
        ButtonBorder.Thickness = 1
        ButtonBorder.Transparency = 1

        local ButtonText = Drawing.new("Text")
        ButtonText.Text = ButtonName
        ButtonText.Size = 12
        ButtonText.Font = 5
        ButtonText.Color = Colors["Text"]
        ButtonText.Outline = true
        ButtonText.OutlineColor = {0, 0, 0}
        ButtonText.Transparency = 1
        ButtonText.Center = true

        local ButtonObj = {
            Name = ButtonName,
            ButtonBackground = ButtonBackground,
            ButtonBorder = ButtonBorder,
            ButtonText = ButtonText,
            Callback = Callback,
            Type = "Button"
        }

        table.insert(Section.Interfaces, ButtonObj)
        Main:UpdateLayout()
        return ButtonObj
    end

    function Main:AddToggle(Section, ToggleName, Callback)
        if not Section then return end
        local ToggleBackground = Drawing.new("Square")
        ToggleBackground.Color = Colors["Object Background"]
        ToggleBackground.Filled = true
        ToggleBackground.Thickness = 1
        ToggleBackground.Transparency = 1

        local ToggleBorder = Drawing.new("Square")
        ToggleBorder.Color = Colors["Object Border"]
        ToggleBorder.Filled = false
        ToggleBorder.Thickness = 1
        ToggleBorder.Transparency = 1

        local ToggleText = Drawing.new("Text")
        ToggleText.Text = ToggleName
        ToggleText.Size = 12
        ToggleText.Font = 5
        ToggleText.Color = Colors["Text"]
        ToggleText.Outline = true
        ToggleText.OutlineColor = {0, 0, 0}
        ToggleText.Transparency = 1
        ToggleText.Center = true

        local ToggleSlider = {}
        ToggleSlider.Background = Drawing.new("Square")
        ToggleSlider.Background.Color = Colors["Object Background"]
        ToggleSlider.Background.Filled = true
        ToggleSlider.Background.Thickness = 1
        ToggleSlider.Background.Transparency = 1

        ToggleSlider.Border = Drawing.new("Square")
        ToggleSlider.Border.Color = Colors["Object Border"]
        ToggleSlider.Border.Filled = false
        ToggleSlider.Border.Thickness = 1
        ToggleSlider.Border.Transparency = 1

        ToggleSlider.Fill = Drawing.new("Square")
        ToggleSlider.Fill.Color = Colors["Accent"]
        ToggleSlider.Fill.Filled = true
        ToggleSlider.Fill.Thickness = 1
        ToggleSlider.Fill.Transparency = 1

        ToggleSlider.ValueText = Drawing.new("Text")
        ToggleSlider.ValueText.Text = "0"
        ToggleSlider.ValueText.Size = 12
        ToggleSlider.ValueText.Font = 5
        ToggleSlider.ValueText.Color = Colors["Text"]
        ToggleSlider.ValueText.Outline = true
        ToggleSlider.OutlineColor = {0, 0, 0}
        ToggleSlider.ValueText.Transparency = 1
        ToggleSlider.ValueText.Center = true
        ToggleSlider.Min = 0
        ToggleSlider.Max = 100
        ToggleSlider.Value = 0
        ToggleSlider.Dragging = false

        local ToggleObj = {
            Name = ToggleName,
            ToggleBackground = ToggleBackground,
            ToggleBorder = ToggleBorder,
            ToggleText = ToggleText,
            Callback = Callback,
            ToggleSlider = ToggleSlider,
            Value = false,
            Type = "Toggle"
        }

        table.insert(Section.Interfaces, ToggleObj)
        Main:UpdateLayout()
        return ToggleObj
    end

    function Main:AddSlider(Section, SliderName, Min, Max, Default, Callback)
        if not Section then return end
        local SliderBackground = Drawing.new("Square")
        SliderBackground.Color = Colors["Object Background"]
        SliderBackground.Filled = true
        SliderBackground.Thickness = 1
        SliderBackground.Transparency = 1

        local SliderBorder = Drawing.new("Square")
        SliderBorder.Color = Colors["Object Border"]
        SliderBorder.Filled = false
        SliderBorder.Thickness = 1
        SliderBorder.Transparency = 1

        local SliderFill = Drawing.new("Square")
        SliderFill.Color = Colors["Accent"]
        SliderFill.Filled = true
        SliderFill.Thickness = 1
        SliderFill.Transparency = 1

        local SliderValueText = Drawing.new("Text")
        SliderValueText.Text = tostring(Default)
        SliderValueText.Size = 12
        SliderValueText.Font = 5
        SliderValueText.Color = Colors["Text"]
        SliderValueText.Outline = true
        SliderValueText.OutlineColor = {0, 0, 0}
        SliderValueText.Transparency = 1
        SliderValueText.Center = true

        local SliderObj = {
            Name = SliderName,
            Background = SliderBackground,
            Border = SliderBorder,
            Fill = SliderFill,
            ValueText = SliderValueText,
            Min = Min,
            Max = Max,
            Value = Default,
            Callback = Callback,
            Dragging = false,
            Type = "Slider"
        }

        table.insert(Section.Interfaces, SliderObj)
        Main:UpdateLayout()
        return SliderObj
    end

    function Main:SetSliderValue(Slider, Value)
        if not Slider then return end
        Slider.Value = math.clamp(Value, Slider.Min, Slider.Max)
        Slider.ValueText.Text = tostring(math.floor(Slider.Value))
        Main:UpdateLayout()
    end

    function Main:SetToggleValue(Toggle, Value)
        if not Toggle then return end
        Toggle.Value = Value
        Main:UpdateLayout()
    end

    WindowActive = Main
    spawn(function()
        while Running do
            Mouse.X, Mouse.Y = getmouseposition()
            Mouse.Clicked = isleftclicked()
            Mouse.Pressed = isleftpressed()
            if IsVisible and WindowActive then
                if Mouse.Pressed and Main:IsObjectHovered(Main.WindowBackground) then
                    if not IsDragging then
                        IsDragging = true
                        DragOffsetX = Mouse.X - Main.WindowBackground.Position.x
                        DragOffsetY = Mouse.Y - Main.WindowBackground.Position.y
                    end
                else
                    IsDragging = false
                end

                if IsDragging then
                    Main.WindowBackground.Position = {Mouse.X - DragOffsetX, Mouse.Y - DragOffsetY}
                    Main:UpdateElementPositions()
                end

                HoveredButton = nil
                for _, TabObj in ipairs(Main.Tabs) do
                    local Button = TabObj.Button
                    local ButtonBorder = TabObj.ButtonBorder
                    local ButtonText = TabObj.ButtonText
                    if Main:IsObjectHovered(Button) then
HoveredButton = Button
                        ButtonBorder.Color = Colors["Accent"]
                        ButtonText.Color = Colors["Selected"]
                        if Mouse.Clicked then
                            Main:SelectTab(TabObj.Name)
                        end
                    else
                        ButtonBorder.Color = Colors["Tab Border"]
                        ButtonText.Color = Colors["Text"]
                    end
                end

                if Main.ActiveTab then
                    local CurrentTabContent = Main.TabContents[Main.ActiveTab]
                    if CurrentTabContent then
                        local function HandleSectionInteraction(Sections)
                            for _, SectionObj in ipairs(Sections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for _, Object in ipairs(SectionObj.Interfaces) do
                                        if Object.Type == "Button" then
                                            if Main:IsObjectHovered(Object.ButtonBackground) then
                                                Object.ButtonBorder.Color = Colors["Accent"]
                                                Object.ButtonText.Color = Colors["Selected"]
                                                if Mouse.Clicked then
                                                    if Object.Callback then
                                                        Object.Callback()
                                                    end
                                                end
                                            else
                                                Object.ButtonBorder.Color = Colors["Object Border"]
                                                Object.ButtonText.Color = Colors["Text"]
                                            end
                                        elseif Object.Type == "Toggle" then
                                            if Main:IsObjectHovered(Object.ToggleBackground) then
                                                Object.ToggleBorder.Color = Colors["Accent"]
                                                Object.ToggleText.Color = Colors["Selected"]
                                                if Mouse.Clicked then
                                                    Object.Value = not Object.Value
                                                    if Object.Callback then
                                                        Object.Callback(Object.Value)
                                                    end
                                                    Main:UpdateLayout()
                                                end
                                            else
                                                Object.ToggleBorder.Color = Colors["Object Border"]
                                                Object.ToggleText.Color = Colors["Text"]
                                            end
                                            if Object.ToggleSlider then
                                                if Main:IsObjectHovered(Object.ToggleSlider.Background) then
                                                    if Mouse.Pressed then
                                                        Object.ToggleSlider.Dragging = true
                                                    end
                                                end
                                                if Object.ToggleSlider.Dragging then
                                                    local SliderX = Object.ToggleSlider.Background.Position.x
                                                    local SliderWidth = Object.ToggleSlider.Background.Size.x
                                                    local Ratio = math.clamp((Mouse.X - SliderX) / SliderWidth, 0, 1)
                                                    local NewValue = Object.ToggleSlider.Min + (Object.ToggleSlider.Max - Object.ToggleSlider.Min) * Ratio
                                                    Main:SetSliderValue(Object.ToggleSlider, NewValue)
                                                    if Object.Callback then
                                                        Object.Callback(NewValue)
                                                    end
                                                end
                                            end
                                        elseif Object.Type == "Slider" then
                                            if Main:IsObjectHovered(Object.Background) then
                                                if Mouse.Pressed then
                                                    Object.Dragging = true
                                                end
                                            end
                                            if Object.Dragging then
                                                local SliderX = Object.Background.Position.x
                                                local SliderWidth = Object.Background.Size.x
                                                local Ratio = math.clamp((Mouse.X - SliderX) / SliderWidth, 0, 1)
                                                local NewValue = Object.Min + (Object.Max - Object.Min) * Ratio
                                                Main:SetSliderValue(Object, NewValue)
                                                if Object.Callback then
                                                    Object.Callback(NewValue)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        HandleSectionInteraction(CurrentTabContent.LeftSections)
                        HandleSectionInteraction(CurrentTabContent.RightSections)
                    end
                end

                -- Stop Slider Dragging
                if not Mouse.Pressed then
                    if Main.ActiveTab then
                        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
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
    end)

    return Main
end

spawn(function()
    while Running do
        Mouse.X, Mouse.Y = getmouseposition()
        Mouse.Clicked = isleftclicked()
        Mouse.Pressed = isleftpressed()
        if IsVisible and WindowActive then
            if Mouse.Pressed and WindowActive:IsObjectHovered(WindowActive.WindowBackground) then
                if not IsDragging then
                    IsDragging = true
                    DragOffsetX = Mouse.X - WindowActive.WindowBackground.Position.x
                    DragOffsetY = Mouse.Y - WindowActive.WindowBackground.Position.y
                end
            else
                IsDragging = false
            end

            if IsDragging then
                WindowActive.WindowBackground.Position = {Mouse.X - DragOffsetX, Mouse.Y - DragOffsetY}
                WindowActive:UpdateElementPositions()
            end

            HoveredButton = nil
            for _, TabObj in ipairs(WindowActive.Tabs) do
                local Button = TabObj.Button
                local ButtonBorder = TabObj.ButtonBorder
                local ButtonText = TabObj.ButtonText
                if WindowActive:IsObjectHovered(Button) then
                    HoveredButton = Button
                    ButtonBorder.Color = Colors["Accent"]
                    ButtonText.Color = Colors["Selected"]
                    if Mouse.Clicked then
                        WindowActive:SelectTab(TabObj.Name)
                    end
                else
                    ButtonBorder.Color = Colors["Tab Border"]
                    ButtonText.Color = Colors["Text"]
                end
            end

            if WindowActive.ActiveTab then
                local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                if CurrentTabContent then
                    local function HandleSectionInteraction(Sections)
                        for _, SectionObj in ipairs(Sections) do
                            if SectionObj.Visible and SectionObj.Interfaces then
                                for _, Object in ipairs(SectionObj.Interfaces) do
                                    if Object.Type == "Button" then
                                        if WindowActive:IsObjectHovered(Object.ButtonBackground) then
                                            Object.ButtonBorder.Color = Colors["Accent"]
                                            Object.ButtonText.Color = Colors["Selected"]
                                            if Mouse.Clicked then
                                                if Object.Callback then
                                                    Object.Callback()
                                                end
                                            end
                                        else
                                            Object.ButtonBorder.Color = Colors["Object Border"]
                                            Object.ButtonText.Color = Colors["Text"]
                                        end
                                    elseif Object.Type == "Toggle" then
                                        if WindowActive:IsObjectHovered(Object.ToggleBackground) then
                                            Object.ToggleBorder.Color = Colors["Accent"]
                                            Object.ToggleText.Color = Colors["Selected"]
                                            if Mouse.Clicked then
                                                Object.Value = not Object.Value
                                                if Object.Callback then
                                                    Object.Callback(Object.Value)
                                                end
                                                WindowActive:UpdateLayout()
                                            end
                                        else
                                            Object.ToggleBorder.Color = Colors["Object Border"]
                                            Object.ToggleText.Color = Colors["Text"]
                                        end
                                        if Object.ToggleSlider then
                                            if WindowActive:IsObjectHovered(Object.ToggleSlider.Background) then
                                                if Mouse.Pressed then
                                                    Object.ToggleSlider.Dragging = true
                                                end
                                            end
                                            if Object.ToggleSlider.Dragging then
                                                local SliderX = Object.ToggleSlider.Background.Position.x
                                                local SliderWidth = Object.ToggleSlider.Background.Size.x
                                                local Ratio = math.clamp((Mouse.X - SliderX) / SliderWidth, 0, 1)
                                                local NewValue = Object.ToggleSlider.Min + (Object.ToggleSlider.Max - Object.ToggleSlider.Min) * Ratio
                                                WindowActive:SetSliderValue(Object.ToggleSlider, NewValue)
                                                if Object.Callback then
                                                    Object.Callback(NewValue)
                                                end
                                            end
                                        end
                                    elseif Object.Type == "Slider" then
                                        if WindowActive:IsObjectHovered(Object.Background) then
                                            if Mouse.Pressed then
                                                Object.Dragging = true
                                            end
                                        end
                                        if Object.Dragging then
                                            local SliderX = Object.Background.Position.x
                                            local SliderWidth = Object.Background.Size.x
                                            local Ratio = math.clamp((Mouse.X - SliderX) / SliderWidth, 0, 1)
                                            local NewValue = Object.Min + (Object.Max - Object.Min) * Ratio
                                            WindowActive:SetSliderValue(Object, NewValue)
                                            if Object.Callback then
                                                Object.Callback(NewValue)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    HandleSectionInteraction(CurrentTabContent.LeftSections)
                    HandleSectionInteraction(CurrentTabContent.RightSections)
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
end)

print'e'
return Library
