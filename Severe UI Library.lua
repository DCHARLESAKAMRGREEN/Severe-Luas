local Colors = {
    ["Accent"] = {67, 12, 122},
    ["Window Background"] = {40, 40, 40},
    ["Window Background 2"] = {30, 30, 30},
    ["Window Border"] = {45, 45, 45},
    ["Tab Background"] = {20, 20, 20},
    ["Tab Border"] = {45, 45, 45},
    ["Tab Toggle Background"] = {28, 28, 28},
    ["Tab Selected Background"] = {255, 255, 255},
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
local TogglePressed = false

local function SetVisibilityRecursive(InterfaceCollection, Visible)
    for _, Interface in pairs(InterfaceCollection) do
        if Interface.Visible ~= nil then
             Interface.Visible = Visible
        end
        if Interface.Interfaces then
            SetVisibilityRecursive(Interface.Interfaces, Visible)
        end
         if Interface.Background and Interface.Background.Visible ~= nil then
             Interface.Background.Visible = Visible
         end
         if Interface.Border and Interface.Border.Visible ~= nil then
             Interface.Border.Visible = Visible
         end
         if Interface.Title and Interface.Title.Visible ~= nil then
             Interface.Title.Visible = Visible
         end
         if Interface.Remove and Interface.Position then
             Interface.Visible = Visible
         end
         if Interface.SelectedHighlight and Interface.SelectedHighlight.Visible ~= nil then
            Interface.SelectedHighlight.Visible = false
         end
    end
end

function ToggleUI()
    IsVisible = not IsVisible

    if WindowActive then
        local Main = WindowActive

        Main.WindowBackground.Visible = IsVisible
        Main.Title.Visible = IsVisible
        Main.TabBackground.Visible = IsVisible
        Main.TabBorder.Visible = IsVisible
        Main.WindowBackground2.Visible = IsVisible
        Main.Window2Border.Visible = IsVisible
        Main.WindowBorder.Visible = IsVisible

        for _, TabObj in ipairs(Main.Tabs) do
             TabObj.Button.Visible = IsVisible
             TabObj.ButtonBorder.Visible = IsVisible
             TabObj.ButtonText.Visible = IsVisible
             if TabObj.SelectedHighlight then
                 TabObj.SelectedHighlight.Visible = IsVisible and (TabObj.Name == Main.ActiveTab)
             end

             local IsActiveTab = TabObj.Name == Main.ActiveTab
             SetVisibilityRecursive(TabObj.Content.LeftSections, IsVisible and IsActiveTab)
             SetVisibilityRecursive(TabObj.Content.RightSections, IsVisible and IsActiveTab)
             SetVisibilityRecursive(TabObj.Content.Interfaces, IsVisible and IsActiveTab)
        end

        if not IsVisible then
             IsDragging = false
        else
            Main:SelectTab(Main.ActiveTab)
        end
    end
end


function Library:Create(Title)
    local Main = {}

    local function SetInitialVisibility(Interface)
        if Interface and Interface.Visible ~= nil then
            Interface.Visible = IsVisible
        end
    end

    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 750}
    Main.WindowBackground.Position = {350, 100}
    Main.WindowBackground.Color = Colors["Window Background"]
    Main.WindowBackground.Filled = true
    Main.WindowBackground.Thickness = 1
    Main.WindowBackground.Transparency = 1
    SetInitialVisibility(Main.WindowBackground)

    Main.Title = Drawing.new("Text")
    Main.Title.Text = Title or "Severe UI"
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
    Main.TabBackground.Size = {Main.WindowBackground.Size.x - 20, 25}
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
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 50}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 60}
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

    function Main:IsHovered(Interface)
        if not IsVisible or not Interface or not Interface.Visible then return false end
        local MouseX, MouseY = Mouse.X, Mouse.Y
        local InterfacePos = Interface.Position
        if not InterfacePos then return false end
        local InterfaceX, InterfaceY = InterfacePos.x, InterfacePos.y

        if Interface.Size then
             local InterfaceSize = Interface.Size
             local InterfaceW, InterfaceH = InterfaceSize.x, InterfaceSize.y
             return MouseX >= InterfaceX and MouseX <= InterfaceX + InterfaceW and MouseY >= InterfaceY and MouseY <= InterfaceY + InterfaceH
        elseif Interface.TextBounds then
             local InterfaceBounds = Interface.TextBounds
             local InterfaceW, InterfaceH = InterfaceBounds.x, InterfaceBounds.y
             if Interface.Center then
                 InterfaceX = InterfaceX - InterfaceW / 2
             end
             return MouseX >= InterfaceX and MouseX <= InterfaceX + InterfaceW and MouseY >= InterfaceY and MouseY <= InterfaceY + InterfaceH
        end
        return false
    end

    function Main:IsHoveringWindow()
         if not IsVisible then return false end
         return Main:IsHovered(Main.WindowBackground)
    end

    function Main:UpdateElementPositions()
        local BasePos = Main.WindowBackground.Position
        local BaseX, BaseY = BasePos.x, BasePos.y

        Main.Title.Position = {BaseX + 10, BaseY + 5}
        Main.TabBackground.Position = {BaseX + 10, BaseY + 25}
        Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
        Main.WindowBackground2.Position = {BaseX + 10, BaseY + 50}
        Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
        Main.WindowBorder.Position = {BaseX, BaseY}

        Main:UpdateTabSizes()
        Main:Sections()
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

            if ButtonText.TextBounds then
                 ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - (ButtonText.TextBounds.y / 2)}
            else
                 ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - 7}
            end
        end
    end


    function Main:Sections()
        if not Main.ActiveTab or not Main.TabContents[Main.ActiveTab] then return end

        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
        local ParentPos = Main.WindowBackground2.Position
        local ParentSize = Main.WindowBackground2.Size
        local ParentWidth = ParentSize.x
        local AvailableWidth = ParentWidth - (5 * 2) - 5
        local ColumnWidth = AvailableWidth / 2

        local BaseX = ParentPos.x
        local BaseY = ParentPos.y

        local LeftColumnX = BaseX + 5
        local RightColumnX = LeftColumnX + ColumnWidth + 5
        local InitialY = BaseY + 5

        CurrentTabContent.CurrentLeftY = InitialY
        CurrentTabContent.CurrentRightY = InitialY

        local function PositionSection(SectionObj, ColumnX, CurrentY)
            local PlaceholderHeight = 100
            local Background = SectionObj.Background
            local Border = SectionObj.Border
            local Title = SectionObj.Title

            Background.Position = {ColumnX, CurrentY}
            Border.Position = {ColumnX, CurrentY}
            Background.Size = {ColumnWidth, PlaceholderHeight}
            Border.Size = {ColumnWidth, PlaceholderHeight}

            if Title then
                Title.Position = {ColumnX + 5, CurrentY + 3}
                Title.Visible = SectionObj.Visible
            end
            return CurrentY + PlaceholderHeight + 5
        end

        for _, SectionObj in ipairs(CurrentTabContent.LeftSections) do
             if SectionObj.Visible then
                CurrentTabContent.CurrentLeftY = PositionSection(SectionObj, LeftColumnX, CurrentTabContent.CurrentLeftY)
             end
        end

        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
            if SectionObj.Visible then
                CurrentTabContent.CurrentRightY = PositionSection(SectionObj, RightColumnX, CurrentTabContent.CurrentRightY)
            end
        end
    end

    function Main:Tab(TabName)
        if not TabName then
            TabName = "Tab " .. (#Main.Tabs + 1)
        end

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
        TabButtonText.Size = 14
        TabButtonText.Font = 5
        TabButtonText.Color = Colors["Text"]
        TabButtonText.Outline = true
        TabButtonText.OutlineColor = {0, 0, 0}
        TabButtonText.Transparency = 1
        TabButtonText.Center = true
        SetInitialVisibility(TabButtonText)

        local SelectedHighlight = Drawing.new("Square")
        SelectedHighlight.Color = Colors["Tab Selected Background"]
        SelectedHighlight.Transparency = 0.135
        SelectedHighlight.Filled = true
        SelectedHighlight.Visible = false

        local TabContent = {
            Name = TabName,
            Interfaces = {},
            LeftSections = {},
            RightSections = {},
            CurrentLeftY = 0,
            CurrentRightY = 0,
            Visible = false
        }

        function TabContent:Section(SectionName, Options)
            Options = Options or {}
            local Side = Options.Side or "Left"
            SectionName = SectionName or "Section"

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
                Name = SectionName,
                Side = Side,
                Background = SectionBackground,
                Border = SectionBorder,
                Title = SectionTitle,
                Interfaces = {},
                Visible = false
            }

            if Side == "Left" then
                table.insert(self.LeftSections, SectionObj)
            else
                table.insert(self.RightSections, SectionObj)
            end

            if IsVisible and Main.ActiveTab == self.Name then
                 SectionObj.Visible = true
                 SectionBackground.Visible = true
                 SectionBorder.Visible = true
                 SectionTitle.Visible = true
                 Main:Sections()
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

        if IsVisible then
            if #Main.Tabs == 1 then
                Main:SelectTab(TabName)
            else
                 Main:SelectTab(Main.ActiveTab)
            end
        else
             TabButton.Visible = false
             TabButtonBorder.Visible = false
             TabButtonText.Visible = false
             SelectedHighlight.Visible = false
        end

        return TabContent
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then return end
        if not IsVisible then return end

        for _, OtherTab in ipairs(Main.Tabs) do
            OtherTab.SelectedHighlight.Visible = false
            OtherTab.Content.Visible = false
            SetVisibilityRecursive(OtherTab.Content.LeftSections, false)
            SetVisibilityRecursive(OtherTab.Content.RightSections, false)
            SetVisibilityRecursive(OtherTab.Content.Interfaces, false) 
        end

        local SelectedTab = Main.TabButtons[TabName]
        SelectedTab.SelectedHighlight.Visible = true
        SelectedTab.Content.Visible = true
        Main.ActiveTab = TabName

        SetVisibilityRecursive(SelectedTab.Content.LeftSections, true)
        SetVisibilityRecursive(SelectedTab.Content.RightSections, true)
        SetVisibilityRecursive(SelectedTab.Content.Interfaces, true) 

        Main:Sections()
    end

    WindowActive = Main
    return Main
end

spawn(function()
    while true do
        local MouseLocation = getmouselocation(MouseService)
        Mouse.X = MouseLocation.x
        Mouse.Y = MouseLocation.y
        Mouse.Clicked = isleftclicked()
        Mouse.Pressed = isleftpressed()

        local Keys = getpressedkeys()
        local IsTogglePressed = false
        if Keys then
            for _, k in ipairs(Keys) do
                if k == 'P' then
                    IsTogglePressed = true
                    break
                end
            end
        end

        if IsTogglePressed and not TogglePressed then
            ToggleUI()
        end
        TogglePressed = IsTogglePressed

        local IsHoveringNow = false
        if IsVisible and WindowActive then
             IsHoveringNow = WindowActive:IsHoveringWindow()

            local WindowPos = WindowActive.WindowBackground.Position
            local WindowSize = WindowActive.WindowBackground.Size
            local WindowX = WindowPos.x
            local WindowY = WindowPos.y

            local DragAreaYMax = WindowActive.TabBackground.Position.y
            local IsHoveredDragArea = Mouse.X >= WindowX and
                                  Mouse.X <= WindowX + WindowSize.x and
                                  Mouse.Y >= WindowY and
                                  Mouse.Y < DragAreaYMax

            if Mouse.Clicked and IsHoveredDragArea and not IsDragging then
                IsDragging = true
                DragOffsetX = Mouse.X - WindowX
                DragOffsetY = Mouse.Y - WindowY
            elseif Mouse.Pressed and IsDragging then
                local NewX = Mouse.X - DragOffsetX
                local NewY = Mouse.Y - DragOffsetY
                WindowActive.WindowBackground.Position = {NewX, NewY}
                WindowActive:UpdateElementPositions()
            elseif not Mouse.Pressed and IsDragging then
                 IsDragging = false
            end

            if Mouse.Clicked and not IsDragging then
                for _, TabObj in ipairs(WindowActive.Tabs) do
                    if WindowActive:IsHovered(TabObj.Button) then
                        WindowActive:SelectTab(TabObj.Name)
                        break
                    end
                end
            end
        end

        if IsHoveringNow then
            set_window_passthrough(false)
        else
            set_window_passthrough(true)
        end

        wait()
    end
end)

print("V1")
return Library
