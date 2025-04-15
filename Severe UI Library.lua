local Colors = {
    ["Accent"] = {67, 12, 122},
    ["WindowBackground"] = {40, 40, 40},
    ["WindowBackground2"] = {30, 30, 30},
    ["WindowBorder"] = {45, 45, 45},
    ["TabBackground"] = {20, 20, 20},
    ["TabBorder"] = {45, 45, 45},
    ["TabToggleBackground"] = {28, 28, 28},
    ["TabSelectedBackground"] = {255, 255, 255},
    ["SectionBackground"] = {18, 18, 18},
    ["SectionBorder"] = {35, 35, 35},
    ["Text"] = {200, 200, 200},
    ["DisabledText"] = {110, 110, 110},
    ["ObjectBackground"] = {25, 25, 25},
    ["ObjectBorder"] = {35, 35, 35},
    ["DropdownOptionBackground"] = {19, 19, 19}
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
local HoveredButton = nil

local function SetElementVisibility(Element, Visible)
    if Element and Element.Visible ~= nil then
        Element.Visible = Visible
    end
end

local function SetVisibilityRecursive(InterfaceCollection, Visible)
    for _, Interface in pairs(InterfaceCollection) do
        if Interface.Type == "Section" then
             SetElementVisibility(Interface.Background, Visible)
             SetElementVisibility(Interface.Border, Visible)
             SetElementVisibility(Interface.Title, Visible)
             Interface.Visible = Visible
             if Interface.Interfaces then
                 SetVisibilityRecursive(Interface.Interfaces, Visible)
             end
        elseif Interface.Type == "Button" then
             SetElementVisibility(Interface.ButtonBackground, Visible)
             SetElementVisibility(Interface.ButtonBorder, Visible)
             SetElementVisibility(Interface.ButtonText, Visible)
             Interface.Visible = Visible
        elseif Interface.Type == "Toggle" then
             SetElementVisibility(Interface.ToggleBackground, Visible)
             SetElementVisibility(Interface.ToggleBorder, Visible)
             SetElementVisibility(Interface.ToggleText, Visible)
             Interface.Visible = Visible
        else
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
             if Interface.SelectedHighlight and Interface.SelectedHighlight.Visible ~= nil then
                 Interface.SelectedHighlight.Visible = false
             end
        end
    end
end

function ToggleUI()
    IsVisible = not IsVisible

    if WindowActive then
        local Main = WindowActive

        SetElementVisibility(Main.WindowBackground, IsVisible)
        SetElementVisibility(Main.Title, IsVisible)
        SetElementVisibility(Main.TabBackground, IsVisible)
        SetElementVisibility(Main.TabBorder, IsVisible)
        SetElementVisibility(Main.WindowBackground2, IsVisible)
        SetElementVisibility(Main.Window2Border, IsVisible)
        SetElementVisibility(Main.WindowBorder, IsVisible)

        for _, TabObj in ipairs(Main.Tabs) do
            SetElementVisibility(TabObj.Button, IsVisible)
            SetElementVisibility(TabObj.ButtonBorder, IsVisible)
            SetElementVisibility(TabObj.ButtonText, IsVisible)

            local IsActiveTab = TabObj.Name == Main.ActiveTab
            SetElementVisibility(TabObj.SelectedHighlight, IsVisible and IsActiveTab)

            SetVisibilityRecursive(TabObj.Content.LeftSections, IsVisible and IsActiveTab)
            SetVisibilityRecursive(TabObj.Content.RightSections, IsVisible and IsActiveTab)
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

function Library:Create(TitleText)
    local Main = {}

    local function SetInitialVisibility(Interface)
        if Interface and Interface.Visible ~= nil then
            Interface.Visible = IsVisible
        end
    end

    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 750}
    Main.WindowBackground.Position = {350, 100}
    Main.WindowBackground.Color = Colors["WindowBackground"]
    Main.WindowBackground.Filled = true
    Main.WindowBackground.Thickness = 1
    Main.WindowBackground.Transparency = 1
    SetInitialVisibility(Main.WindowBackground)

    Main.Title = Drawing.new("Text")
    Main.Title.Text = TitleText or "Severe UI"
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
    Main.TabBackground.Color = Colors["TabBackground"]
    Main.TabBackground.Filled = true
    Main.TabBackground.Thickness = 1
    Main.TabBackground.Transparency = 1
    SetInitialVisibility(Main.TabBackground)

    Main.TabBorder = Drawing.new("Square")
    Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
    Main.TabBorder.Size = {Main.TabBackground.Size.x, Main.TabBackground.Size.y}
    Main.TabBorder.Color = Colors["TabBorder"]
    Main.TabBorder.Filled = false
    Main.TabBorder.Thickness = 1
    Main.TabBorder.Transparency = 1
    SetInitialVisibility(Main.TabBorder)

    Main.WindowBackground2 = Drawing.new("Square")
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 50}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 60}
    Main.WindowBackground2.Color = Colors["WindowBackground2"]
    Main.WindowBackground2.Filled = true
    Main.WindowBackground2.Thickness = 1
    Main.WindowBackground2.Transparency = 1
    SetInitialVisibility(Main.WindowBackground2)

    Main.Window2Border = Drawing.new("Square")
    Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
    Main.Window2Border.Size = {Main.WindowBackground2.Size.x, Main.WindowBackground2.Size.y}
    Main.Window2Border.Color = Colors["WindowBorder"]
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
             InterfaceY = InterfaceY - InterfaceH / 4
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

            if ButtonText.TextBounds then
                 ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - (ButtonText.TextBounds.y / 2)}
            else
                 ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - 7}
            end
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
            SetElementVisibility(SectionObj.Background, true)
            SetElementVisibility(SectionObj.Border, true)
            SetElementVisibility(SectionObj.Title, true)

            SectionObj.Background.Position = {ColumnX, StartY}
            SectionObj.Border.Position = {ColumnX, StartY}

            local TitleHeight = 0
            if SectionObj.Title then
                SectionObj.Title.Position = {ColumnX + Padding, StartY + 3}
                if SectionObj.Title.TextBounds then TitleHeight = SectionObj.Title.TextBounds.y else TitleHeight = 12 end
            end

            local CurrentInternalY = StartY + TitleHeight + Padding * 2

            if SectionObj.Interfaces then
                for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                     if InterfaceObj.Type == "Button" then
                         local ButtonHeight = 20
                         local ButtonWidth = Width - (Padding * 2)
                         local ButtonX = ColumnX + Padding
                         local ButtonY = CurrentInternalY

                         SetElementVisibility(InterfaceObj.ButtonBackground, true)
                         SetElementVisibility(InterfaceObj.ButtonBorder, true)
                         SetElementVisibility(InterfaceObj.ButtonText, true)

                         InterfaceObj.ButtonBackground.Position = {ButtonX, ButtonY}
                         InterfaceObj.ButtonBackground.Size = {ButtonWidth, ButtonHeight}
                         InterfaceObj.ButtonBorder.Position = {ButtonX, ButtonY}
                         InterfaceObj.ButtonBorder.Size = {ButtonWidth, ButtonHeight}

                         local TextYOffset = 0
                         if InterfaceObj.ButtonText.TextBounds then
                             TextYOffset = math.floor((ButtonHeight - InterfaceObj.ButtonText.TextBounds.y) / 2)
                         else
                             TextYOffset = 1
                         end
                         InterfaceObj.ButtonText.Position = {ButtonX + math.floor(ButtonWidth / 2), ButtonY + TextYOffset}
                         InterfaceObj.ButtonText.Center = true

                         CurrentInternalY = CurrentInternalY + ButtonHeight + Padding
                     elseif InterfaceObj.Type == "Toggle" then
                         local ToggleSize = 20
                         local ToggleX = ColumnX + Padding
                         local ToggleY = CurrentInternalY

                         SetElementVisibility(InterfaceObj.ToggleBackground, true)
                         SetElementVisibility(InterfaceObj.ToggleBorder, true)
                         SetElementVisibility(InterfaceObj.ToggleText, true)

                         InterfaceObj.ToggleBackground.Position = {ToggleX, ToggleY}
                         InterfaceObj.ToggleBackground.Size = {ToggleSize, ToggleSize}
                         InterfaceObj.ToggleBorder.Position = {ToggleX, ToggleY}
                         InterfaceObj.ToggleBorder.Size = {ToggleSize, ToggleSize}

                         local TextYOffset = math.floor((ToggleSize - 12) / 2)
                         InterfaceObj.ToggleText.Position = {ToggleX + ToggleSize + 5, ToggleY + TextYOffset}

                         CurrentInternalY = CurrentInternalY + ToggleSize + Padding
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
                SetElementVisibility(SectionObj.Background, false)
                SetElementVisibility(SectionObj.Border, false)
                SetElementVisibility(SectionObj.Title, false)
                if SectionObj.Interfaces then SetVisibilityRecursive(SectionObj.Interfaces, false) end
            end
        end

        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
             if SectionObj.Visible then
                CurrentRightY = UpdateSectionLayout(SectionObj, RightColumnX, CurrentRightY, ColumnWidth)
             else
                SetElementVisibility(SectionObj.Background, false)
                SetElementVisibility(SectionObj.Border, false)
                SetElementVisibility(SectionObj.Title, false)
                if SectionObj.Interfaces then SetVisibilityRecursive(SectionObj.Interfaces, false) end
             end
        end
    end

    function Main:Tab(TabName)
        if not TabName then
            TabName = "Tab " .. (#Main.Tabs + 1)
        end

        local TabButton = Drawing.new("Square")
        TabButton.Color = Colors["TabToggleBackground"]
        TabButton.Filled = true
        TabButton.Thickness = 1
        TabButton.Transparency = 1
        SetInitialVisibility(TabButton)

        local TabButtonBorder = Drawing.new("Square")
        TabButtonBorder.Color = Colors["TabBorder"]
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
        SelectedHighlight.Color = Colors["TabSelectedBackground"]
        SelectedHighlight.Transparency = 0.135
        SelectedHighlight.Filled = true
        SelectedHighlight.Visible = false

        local TabContent = {
            Name = TabName,
            LeftSections = {},
            RightSections = {},
            Visible = false
        }

        function TabContent:Section(SectionName, Options)
            Options = Options or {}
            local Side = Options.Side or "Left"
            SectionName = SectionName or "Section"

            local SectionBackground = Drawing.new("Square")
            SectionBackground.Color = Colors["SectionBackground"]
            SectionBackground.Filled = true
            SectionBackground.Thickness = 1
            SectionBackground.Transparency = 1
            SectionBackground.Visible = false

            local SectionBorder = Drawing.new("Square")
            SectionBorder.Color = Colors["SectionBorder"]
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

            function SectionObj:Button(ButtonName, Callback)
                local ButtonBackground = Drawing.new("Square")
                ButtonBackground.Color = Colors["ObjectBackground"]
                ButtonBackground.Filled = true
                ButtonBackground.Thickness = 1
                ButtonBackground.Transparency = 1
                ButtonBackground.Visible = self.Visible

                local ButtonBorder = Drawing.new("Square")
                ButtonBorder.Color = Colors["ObjectBorder"]
                ButtonBorder.Filled = false
                ButtonBorder.Thickness = 1
                ButtonBorder.Transparency = 1
                ButtonBorder.Visible = self.Visible

                local ButtonText = Drawing.new("Text")
                ButtonText.Text = ButtonName or "Button"
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
                    DefaultBorderColor = Colors["ObjectBorder"],
                    OriginalBackgroundColor = Colors["ObjectBackground"],
                    OriginalBackgroundTransparency = 1,
                    Visible = self.Visible
                }

                table.insert(self.Interfaces, ButtonObj)

                if IsVisible and Main.ActiveTab == TabContent.Name then
                     Main:UpdateLayout()
                end

                return ButtonObj
            end

            function SectionObj:Toggle(ToggleName, DefaultState, Callback)
                local ToggleBackground = Drawing.new("Square")
                ToggleBackground.Color = Colors["Accent"]
                ToggleBackground.Filled = false  -- Will be set based on state
                ToggleBackground.Thickness = 1
                ToggleBackground.Transparency = 1
                ToggleBackground.Visible = self.Visible

                local ToggleBorder = Drawing.new("Square")
                ToggleBorder.Color = Colors["ObjectBorder"]
                ToggleBorder.Filled = false
                ToggleBorder.Thickness = 1
                ToggleBorder.Transparency = 1
                ToggleBorder.Visible = self.Visible

                local ToggleText = Drawing.new("Text")
                ToggleText.Text = ToggleName or "Toggle"
                ToggleText.Size = 12
                ToggleText.Font = 5
                ToggleText.Color = Colors["Text"]
                ToggleText.Outline = true
                ToggleText.OutlineColor = {0, 0, 0}
                ToggleText.Transparency = 1
                ToggleText.Center = false
                ToggleText.Visible = self.Visible

                local State = DefaultState or false
                
                local function UpdateToggleVisuals()
                    if State then
                        ToggleBackground.Filled = true  -- Fill when on
                        ToggleBackground.Transparency = 0.5
                        ToggleBorder.Color = Colors["Accent"]
                    else
                        ToggleBackground.Filled = false  -- No fill when off
                        ToggleBackground.Transparency = 1
                        
                        -- Only check hover when not toggled
                        local isHovered = false
                        if WindowActive then
                            local togglePos = ToggleBackground.Position
                            local toggleSize = ToggleBackground.Size
                            local textPos = ToggleText.Position
                            local textBounds = ToggleText.TextBounds or {x = 100, y = 12}
                            
                            local hitboxX = togglePos.x
                            local hitboxY = togglePos.y
                            local hitboxWidth = (textPos.x + textBounds.x) - togglePos.x + 5
                            local hitboxHeight = math.max(toggleSize.y, textBounds.y)
                            
                            isHovered = (Mouse.X >= hitboxX and Mouse.X <= hitboxX + hitboxWidth and
                                       Mouse.Y >= hitboxY and Mouse.Y <= hitboxY + hitboxHeight)
                        end
                        
                        ToggleBorder.Color = isHovered and Colors["Accent"] or Colors["ObjectBorder"]
                    end
                end
                
                UpdateToggleVisuals()

                local ToggleObj = {
                    Type = "Toggle",
                    Name = ToggleName,
                    Callback = Callback,
                    ToggleBackground = ToggleBackground,
                    ToggleBorder = ToggleBorder,
                    ToggleText = ToggleText,
                    DefaultBorderColor = Colors["ObjectBorder"],
                    OriginalBackgroundColor = Colors["Accent"],
                    OriginalBackgroundTransparency = 0.5,
                    Visible = self.Visible,
                    State = State,
                    Update = UpdateToggleVisuals
                }

                table.insert(self.Interfaces, ToggleObj)

                if IsVisible and Main.ActiveTab == TabContent.Name then
                    Main:UpdateLayout()
                end

                return ToggleObj
            end

            if Side == "Left" then
                table.insert(self.LeftSections, SectionObj)
            else
                table.insert(self.RightSections, SectionObj)
            end

            if IsVisible and Main.ActiveTab == TabContent.Name then
                SectionObj.Visible = true
                SetElementVisibility(SectionBackground, true)
                SetElementVisibility(SectionBorder, true)
                SetElementVisibility(SectionTitle, true)
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
             SetElementVisibility(TabButton, false)
             SetElementVisibility(TabButtonBorder, false)
             SetElementVisibility(TabButtonText, false)
             SetElementVisibility(SelectedHighlight, false)
             SetVisibilityRecursive(TabContent.LeftSections, false)
             SetVisibilityRecursive(TabContent.RightSections, false)
        end

        return TabContent
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then return end

        Main.ActiveTab = TabName

        if not IsVisible then
             return
        end

        for OtherTabName, OtherTab in pairs(Main.TabButtons) do
            local IsSelected = OtherTabName == TabName
            SetElementVisibility(OtherTab.SelectedHighlight, IsSelected)
            OtherTab.Content.Visible = IsSelected
            SetVisibilityRecursive(OtherTab.Content.LeftSections, IsSelected)
            SetVisibilityRecursive(OtherTab.Content.RightSections, IsSelected)
        end

        Main:UpdateLayout()
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
        HoveredButton = nil
        local UIClickHandled = false
        local IsMouseOverUI = false

        local Keys = getpressedkeys()
        local IsToggleKeyPressed = false
        if Keys then
for _,key in ipairs(Keys) do
            if key == "RightShift" then
                IsToggleKeyPressed = true
                break
            end
        end
    end

    if IsToggleKeyPressed and not TogglePressed then
        ToggleUI()
        TogglePressed = true
    elseif not IsToggleKeyPressed then
        TogglePressed = false
    end

    if WindowActive and IsVisible then
        IsMouseOverUI = WindowActive:IsHoveringWindow()

        if Mouse.Pressed and not IsDragging then
            local TitleBarArea = {
                x = WindowActive.WindowBackground.Position.x,
                y = WindowActive.WindowBackground.Position.y,
                width = WindowActive.WindowBackground.Size.x,
                height = 25
            }

            if Mouse.X >= TitleBarArea.x and Mouse.X <= TitleBarArea.x + TitleBarArea.width and
               Mouse.Y >= TitleBarArea.y and Mouse.Y <= TitleBarArea.y + TitleBarArea.height then
                IsDragging = true
                DragOffsetX = Mouse.X - WindowActive.WindowBackground.Position.x
                DragOffsetY = Mouse.Y - WindowActive.WindowBackground.Position.y
            end
        end

        if not Mouse.Pressed then
            IsDragging = false
        end

        if IsDragging then
            WindowActive.WindowBackground.Position = {Mouse.X - DragOffsetX, Mouse.Y - DragOffsetY}
            WindowActive:UpdateElementPositions()
        end

        -- Handle Tab Button Clicks
        if Mouse.Clicked and not UIClickHandled then
            for _, TabObj in ipairs(WindowActive.Tabs) do
                if WindowActive:IsHovered(TabObj.Button) then
                    WindowActive:SelectTab(TabObj.Name)
                    UIClickHandled = true
                    break
                end
            end
        end

        -- Check for button hovers and clicks
        if WindowActive.ActiveTab then
            local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
            if CurrentTabContent then
                local function ProcessInterfaces(Interfaces)
                    for _, Interface in ipairs(Interfaces) do
                        if Interface.Type == "Section" and Interface.Visible and Interface.Interfaces then
                            for _, InterfaceObj in ipairs(Interface.Interfaces) do
                                if InterfaceObj.Type == "Button" and InterfaceObj.Visible then
                                    local IsHovered = WindowActive:IsHovered(InterfaceObj.ButtonBackground)
                                    
                                    if IsHovered then
                                        InterfaceObj.ButtonBorder.Color = Colors["Accent"]
                                        HoveredButton = InterfaceObj
                                    else
                                        InterfaceObj.ButtonBorder.Color = InterfaceObj.DefaultBorderColor
                                    end
                                    
                                    if IsHovered and Mouse.Clicked and not UIClickHandled then
                                        if InterfaceObj.Callback then
                                            spawn(function()
                                                InterfaceObj.Callback()
                                            end)
                                        end
                                        UIClickHandled = true
                                    end
                                elseif InterfaceObj.Type == "Toggle" and InterfaceObj.Visible then
                                    local ToggleX = InterfaceObj.ToggleBackground.Position.x
                                    local ToggleY = InterfaceObj.ToggleBackground.Position.y
                                    local ToggleSize = InterfaceObj.ToggleBackground.Size.x
                                    local TextX = InterfaceObj.ToggleText.Position.x
                                    local TextY = InterfaceObj.ToggleText.Position.y
                                    local TextWidth = InterfaceObj.ToggleText.TextBounds and InterfaceObj.ToggleText.TextBounds.x or 100
                                    local TextHeight = InterfaceObj.ToggleText.TextBounds and InterfaceObj.ToggleText.TextBounds.y or 12
                                    
                                    local HitboxX = ToggleX
                                    local HitboxY = ToggleY
                                    local HitboxWidth = (TextX + TextWidth) - ToggleX + 5
                                    local HitboxHeight = math.max(ToggleSize, TextHeight)
                                    
                                    local IsHovered = Mouse.X >= HitboxX and Mouse.X <= HitboxX + HitboxWidth and
                                                     Mouse.Y >= HitboxY and Mouse.Y <= HitboxY + HitboxHeight
                                    
                                    if IsHovered and Mouse.Clicked and not UIClickHandled then
                                        InterfaceObj.State = not InterfaceObj.State
                                        InterfaceObj.Update()
                                        
                                        if InterfaceObj.Callback then
                                            spawn(function()
                                                InterfaceObj.Callback(InterfaceObj.State)
                                            end)
                                        end
                                        UIClickHandled = true
                                    else
                                        InterfaceObj.Update()
                                    end
                                end
                            end
                        end
                    end
                end
                
                ProcessInterfaces(CurrentTabContent.LeftSections)
                ProcessInterfaces(CurrentTabContent.RightSections)
            end
        end
        
        if HoveredButton and HoveredButton.ButtonBackground then
            set_window_passthrough(false)
        else
            set_window_passthrough(not IsMouseOverUI)
        end
    else
        set_window_passthrough(true)
    end
    
    wait()
end
end)

return Library
