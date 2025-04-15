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

local Game = Game -- Assuming 'Game' is the predefined global userdata
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
local HoveredObject = nil -- Renamed from HoveredButton for clarity

local function SetElementVisibility(Element, Visible)
    if Element and Element.Visible ~= nil then
        Element.Visible = Visible
    end
end

local function SetVisibilityRecursive(InterfaceCollection, Visible)
    for _, Interface in pairs(InterfaceCollection) do
         local ObjectVisible = Visible and Interface.Visible -- Respect individual object visibility if needed later

         if Interface.Type == "Section" then
             SetElementVisibility(Interface.Background, ObjectVisible)
             SetElementVisibility(Interface.Border, ObjectVisible)
             SetElementVisibility(Interface.Title, ObjectVisible)
             Interface.Visible = ObjectVisible -- Update section visibility state
             if Interface.Interfaces then
                 SetVisibilityRecursive(Interface.Interfaces, ObjectVisible)
             end
         elseif Interface.Type == "Button" then
             SetElementVisibility(Interface.ButtonBackground, ObjectVisible)
             SetElementVisibility(Interface.ButtonBorder, ObjectVisible)
             SetElementVisibility(Interface.ButtonText, ObjectVisible)
             Interface.Visible = ObjectVisible
         elseif Interface.Type == "Toggle" then
             SetElementVisibility(Interface.BoxBackground, ObjectVisible)
             SetElementVisibility(Interface.BoxBorder, ObjectVisible)
             SetElementVisibility(Interface.LabelText, ObjectVisible)
             Interface.Visible = ObjectVisible
         else
             -- Handle other potential types or generic visibility
             if Interface.Visible ~= nil then
                 Interface.Visible = ObjectVisible
             end
             if Interface.Interfaces then
                 SetVisibilityRecursive(Interface.Interfaces, ObjectVisible)
             end
             -- Fallback for common elements if not specifically typed
             if Interface.Background and Interface.Background.Visible ~= nil then Interface.Background.Visible = ObjectVisible end
             if Interface.Border and Interface.Border.Visible ~= nil then Interface.Border.Visible = ObjectVisible end
             if Interface.Title and Interface.Title.Visible ~= nil then Interface.Title.Visible = ObjectVisible end
             if Interface.SelectedHighlight and Interface.SelectedHighlight.Visible ~= nil then Interface.SelectedHighlight.Visible = false end -- Ensure highlights reset correctly
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

            -- Recursively set visibility based on whether the tab is active and UI is visible
            SetVisibilityRecursive(TabObj.Content.LeftSections, IsVisible and IsActiveTab)
            SetVisibilityRecursive(TabObj.Content.RightSections, IsVisible and IsActiveTab)
        end

        if not IsVisible then
            IsDragging = false
            HoveredObject = nil
        else
            -- Ensure the correct tab content is shown when UI becomes visible
            Main:SelectTab(Main.ActiveTab)
            Main:UpdateLayout() -- Recalculate layout after showing
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
    Main.WindowBackground.Color = Colors["Window Background"]
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

        -- Check for box-like elements (Square, Image, etc.)
        if Interface.Size then
            local InterfaceSize = Interface.Size
            local InterfaceW, InterfaceH = InterfaceSize.x, InterfaceSize.y
            return MouseX >= InterfaceX and MouseX <= InterfaceX + InterfaceW and MouseY >= InterfaceY and MouseY <= InterfaceY + InterfaceH
        -- Check for text elements
        elseif Interface.TextBounds then
            local InterfaceBounds = Interface.TextBounds
            local InterfaceW, InterfaceH = InterfaceBounds.x, InterfaceBounds.y
             -- Adjust X for centered text
            if Interface.Center then
                InterfaceX = InterfaceX - InterfaceW / 2
            end
            -- Approximate Y adjustment for text baseline/vertical center
            InterfaceY = InterfaceY - InterfaceH / 3 -- Adjust as needed for font
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
                 ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - 7} -- Fallback positioning
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
        local ElementSpacing = 5 -- Vertical space between elements
        local AvailableWidth = ParentWidth - (Padding * 3) -- Padding on left, right, and between columns
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
            local InternalPadding = 3 -- Padding inside the section for elements

            if SectionObj.Interfaces then
                for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                     local ElementX = ColumnX + InternalPadding
                     local ElementWidth = Width - (InternalPadding * 2)

                     if InterfaceObj.Type == "Button" then
                         local ButtonHeight = 18 -- Increased height slightly
                         local ButtonY = CurrentInternalY

                         SetElementVisibility(InterfaceObj.ButtonBackground, true)
                         SetElementVisibility(InterfaceObj.ButtonBorder, true)
                         SetElementVisibility(InterfaceObj.ButtonText, true)

                         InterfaceObj.ButtonBackground.Position = {ElementX, ButtonY}
                         InterfaceObj.ButtonBackground.Size = {ElementWidth, ButtonHeight}
                         InterfaceObj.ButtonBorder.Position = {ElementX, ButtonY}
                         InterfaceObj.ButtonBorder.Size = {ElementWidth, ButtonHeight}

                         local TextYOffset = 0
                         if InterfaceObj.ButtonText.TextBounds then
                             TextYOffset = math.floor((ButtonHeight - InterfaceObj.ButtonText.TextBounds.y) / 2)
                         else
                             TextYOffset = 3 -- Adjust fallback
                         end
                         InterfaceObj.ButtonText.Position = {ElementX + math.floor(ElementWidth / 2), ButtonY + TextYOffset}
                         InterfaceObj.ButtonText.Center = true

                         CurrentInternalY = CurrentInternalY + ButtonHeight + ElementSpacing

                     elseif InterfaceObj.Type == "Toggle" then
                         local BoxSize = 12
                         local LabelPadding = 4
                         local ToggleY = CurrentInternalY

                         SetElementVisibility(InterfaceObj.BoxBackground, true)
                         SetElementVisibility(InterfaceObj.BoxBorder, true)
                         SetElementVisibility(InterfaceObj.LabelText, true)

                         InterfaceObj.BoxBackground.Position = {ElementX, ToggleY}
                         InterfaceObj.BoxBackground.Size = {BoxSize, BoxSize}
                         InterfaceObj.BoxBorder.Position = {ElementX, ToggleY}
                         InterfaceObj.BoxBorder.Size = {BoxSize, BoxSize}

                         local TextHeight = 0
                         if InterfaceObj.LabelText.TextBounds then TextHeight = InterfaceObj.LabelText.TextBounds.y else TextHeight = 12 end
                         local TextYOffset = math.floor((BoxSize - TextHeight) / 2) -- Align text vertically with box center

                         InterfaceObj.LabelText.Position = {ElementX + BoxSize + LabelPadding, ToggleY + TextYOffset}
                         InterfaceObj.LabelText.Center = false

                         local ElementHeight = math.max(BoxSize, TextHeight)
                         CurrentInternalY = CurrentInternalY + ElementHeight + ElementSpacing
                     end
                end
            end

            local TotalSectionHeight = (CurrentInternalY - ElementSpacing - StartY) + InternalPadding -- Adjust height calculation
            SectionObj.Background.Size = {Width, TotalSectionHeight}
            SectionObj.Border.Size = {Width, TotalSectionHeight}
            SectionObj.CalculatedHeight = TotalSectionHeight

            return StartY + TotalSectionHeight + Padding -- Use outer padding for space between sections
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
            LeftSections = {},
            RightSections = {},
            Visible = false -- Content visibility is tied to tab selection
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
                Type = "Section",
                Name = SectionName,
                Side = Side,
                Background = SectionBackground,
                Border = SectionBorder,
                Title = SectionTitle,
                Interfaces = {},
                Visible = false, -- Section visibility depends on tab selection
                CalculatedHeight = 0
            }

            function SectionObj:Button(ButtonName, Callback)
                local ButtonBackground = Drawing.new("Square")
                ButtonBackground.Color = Colors["Object Background"]
                ButtonBackground.Filled = true
                ButtonBackground.Thickness = 1
                ButtonBackground.Transparency = 1
                ButtonBackground.Visible = false -- Element visibility managed by layout/tab

                local ButtonBorder = Drawing.new("Square")
                ButtonBorder.Color = Colors["Object Border"]
                ButtonBorder.Filled = false
                ButtonBorder.Thickness = 1
                ButtonBorder.Transparency = 1
                ButtonBorder.Visible = false

                local ButtonText = Drawing.new("Text")
                ButtonText.Text = ButtonName or "Button"
                ButtonText.Size = 12
                ButtonText.Font = 5
                ButtonText.Color = Colors["Text"]
                ButtonText.Outline = true
                ButtonText.OutlineColor = {0, 0, 0}
                ButtonText.Transparency = 1
                ButtonText.Center = true
                ButtonText.Visible = false

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
                    Visible = false -- Default to not visible
                }

                table.insert(self.Interfaces, ButtonObj)

                if IsVisible and Main.ActiveTab == TabContent.Name and self.Visible then
                     Main:UpdateLayout()
                end

                return ButtonObj
            end

            function SectionObj:Toggle(ToggleName, Callback)
                local DefaultState = false -- Toggles usually start off

                local BoxBackground = Drawing.new("Square")
                BoxBackground.Color = Colors["Object Background"]
                BoxBackground.Filled = true
                BoxBackground.Thickness = 1
                BoxBackground.Transparency = 1
                BoxBackground.Visible = false -- Element visibility managed by layout/tab

                local BoxBorder = Drawing.new("Square")
                BoxBorder.Color = Colors["Object Border"]
                BoxBorder.Filled = false
                BoxBorder.Thickness = 1
                BoxBorder.Transparency = 1
                BoxBorder.Visible = false

                local LabelText = Drawing.new("Text")
                LabelText.Text = ToggleName or "Toggle"
                LabelText.Size = 12
                LabelText.Font = 5
                LabelText.Color = Colors["Text"]
                LabelText.Outline = true
                LabelText.OutlineColor = {0, 0, 0}
                LabelText.Transparency = 1
                LabelText.Center = false -- Align left next to box
                LabelText.Visible = false

                local ToggleObj = {
                    Type = "Toggle",
                    Name = ToggleName,
                    Callback = Callback or function() end, -- Provide default empty callback
                    State = DefaultState,
                    BoxBackground = BoxBackground,
                    BoxBorder = BoxBorder,
                    LabelText = LabelText,
                    DefaultBoxColor = Colors["Object Background"],
                    DefaultBorderColor = Colors["Object Border"],
                    AccentColor = Colors["Accent"],
                    Visible = false -- Default to not visible
                }

                -- Initialize visual state based on default State
                if DefaultState then
                    ToggleObj.BoxBackground.Color = ToggleObj.AccentColor
                    ToggleObj.BoxBackground.Filled = true
                else
                    ToggleObj.BoxBackground.Color = ToggleObj.DefaultBoxColor
                    ToggleObj.BoxBackground.Filled = true -- Keep it filled, just change color
                end

                table.insert(self.Interfaces, ToggleObj)

                if IsVisible and Main.ActiveTab == TabContent.Name and self.Visible then
                     Main:UpdateLayout()
                end

                return ToggleObj
            end


            if Side == "Left" then
                table.insert(self.LeftSections, SectionObj)
            else
                table.insert(self.RightSections, SectionObj)
            end

            -- Set initial section visibility based on whether its tab is active and the UI is visible
            SectionObj.Visible = IsVisible and Main.ActiveTab == TabContent.Name
            SetElementVisibility(SectionBackground, SectionObj.Visible)
            SetElementVisibility(SectionBorder, SectionObj.Visible)
            SetElementVisibility(SectionTitle, SectionObj.Visible)
            -- Do not automatically update layout here, let SelectTab handle it

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

        if #Main.Tabs == 1 then -- Automatically select the first tab created
            Main:SelectTab(TabName)
        elseif Main.ActiveTab and IsVisible then
             Main:SelectTab(Main.ActiveTab) -- Reselect current tab if one exists and UI is visible
        else
             -- Ensure new tab elements are initially hidden if UI is not visible or no tab was active
             SetElementVisibility(TabButton, IsVisible)
             SetElementVisibility(TabButtonBorder, IsVisible)
             SetElementVisibility(TabButtonText, IsVisible)
             SetElementVisibility(SelectedHighlight, false)
             -- Content visibility is handled by SelectTab
        end

        return TabContent
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then
            if #Main.Tabs > 0 then -- If requested tab doesn't exist, select the first one
                TabName = Main.Tabs[1].Name
                if not Main.TabButtons[TabName] then return end -- No tabs exist
            else
                return -- No tabs exist
            end
        end

        Main.ActiveTab = TabName

        if not IsVisible then
             -- If UI is hidden, just store the active tab name
             -- Ensure all content is marked as not visible internally
             for OtherTabName, OtherTab in pairs(Main.TabButtons) do
                 SetElementVisibility(OtherTab.SelectedHighlight, false)
                 OtherTab.Content.Visible = false
                 SetVisibilityRecursive(OtherTab.Content.LeftSections, false)
                 SetVisibilityRecursive(OtherTab.Content.RightSections, false)
             end
             return
        end

        -- If UI is visible, update visuals
        for OtherTabName, OtherTab in pairs(Main.TabButtons) do
            local IsSelected = OtherTabName == TabName
            SetElementVisibility(OtherTab.SelectedHighlight, IsSelected)
            OtherTab.Content.Visible = IsSelected -- Set content visibility flag

            -- Recursively update visibility based on selection
            SetVisibilityRecursive(OtherTab.Content.LeftSections, IsSelected)
            SetVisibilityRecursive(OtherTab.Content.RightSections, IsSelected)
        end

        Main:UpdateLayout() -- Update layout for the newly selected tab
    end

    WindowActive = Main
    return Main
end

spawn(function()
    while true do
        local MouseLocation = getmouselocation(MouseService)
        Mouse.X = MouseLocation.x
        Mouse.Y = MouseLocation.y
        Mouse.Clicked = isleftclicked() -- Check for single click frame
        Mouse.Pressed = isleftpressed() -- Check if button is held down
        HoveredObject = nil -- Reset hovered object each frame
        local UIClickHandled = false
        local IsMouseOverUI = false

        local Keys = getpressedkeys()
        local IsToggleKeyPressed = false
        if Keys then
            for _, k in ipairs(Keys) do
                if k == 'P' then -- Use 'P' key to toggle UI visibility
                    IsToggleKeyPressed = true
                    break
                end
            end
        end

        -- Toggle UI visibility on key press (rising edge detection)
        if IsToggleKeyPressed and not TogglePressed then
            ToggleUI()
        end
        TogglePressed = IsToggleKeyPressed -- Update state for next frame

        if IsVisible and WindowActive then
            -- Check if mouse is over the main window background
            if WindowActive:IsHoveringWindow() then IsMouseOverUI = true end
            -- Check if mouse is over any visible tab button
            for _, TabObj in ipairs(WindowActive.Tabs) do
                if TabObj.Button.Visible and WindowActive:IsHovered(TabObj.Button) then
                    IsMouseOverUI = true
                    break
                end
            end

            -- Window Dragging Logic
            local WindowPos = WindowActive.WindowBackground.Position
            local DragAreaYMax = WindowActive.TabBackground.Position.y -- Only allow dragging by title/top bar area
            if Mouse.Clicked and IsMouseOverUI and Mouse.Y < DragAreaYMax and not IsDragging then
                IsDragging = true
                DragOffsetX = Mouse.X - WindowPos.x
                DragOffsetY = Mouse.Y - WindowPos.y
                UIClickHandled = true -- Prevent other clicks while starting drag
            elseif Mouse.Pressed and IsDragging then
                IsMouseOverUI = true -- Keep UI interaction active while dragging
                local NewX = Mouse.X - DragOffsetX
                local NewY = Mouse.Y - DragOffsetY
                WindowActive.WindowBackground.Position = {NewX, NewY}
                WindowActive:UpdateElementPositions() -- Update all child positions relative to window
                UIClickHandled = true -- Prevent other clicks while dragging
            elseif not Mouse.Pressed and IsDragging then
                IsDragging = false -- Stop dragging when mouse is released
            end

            -- Click Handling for UI Elements (Tabs, Buttons, Toggles)
            if Mouse.Clicked and not IsDragging and not UIClickHandled then
                -- Tab Selection
                for _, TabObj in ipairs(WindowActive.Tabs) do
                    if TabObj.Button.Visible and WindowActive:IsHovered(TabObj.Button) then
                        WindowActive:SelectTab(TabObj.Name)
                        UIClickHandled = true
                        break
                    end
                end

                -- Element Interaction within Active Tab
                if not UIClickHandled and WindowActive.ActiveTab then
                    local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                    if CurrentTabContent then
                         local function CheckElementInteraction(Sections)
                             if UIClickHandled then return end -- Stop checking if click handled
                             for _, SectionObj in ipairs(Sections) do
                                 if SectionObj.Visible and SectionObj.Interfaces then
                                     for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                                         if InterfaceObj.Visible then -- Only interact with visible elements
                                             if InterfaceObj.Type == "Button" then
                                                 local IsHover = WindowActive:IsHovered(InterfaceObj.ButtonBackground)
                                                 if IsHover then
                                                     -- Visual feedback for click (temporary color change)
                                                     InterfaceObj.ButtonBackground.Color = InterfaceObj.AccentColor or Colors["Tab Selected Background"] -- Use Accent if defined, else fallback
                                                     InterfaceObj.ButtonBackground.Transparency = 0.3 -- Make it slightly more visible
                                                     InterfaceObj.ButtonBorder.Color = InterfaceObj.AccentColor or Colors["Accent"]

                                                     local TargetButtonObj = InterfaceObj
                                                     spawn(function()
                                                         wait(0.07) -- Duration of click feedback
                                                         if IsVisible and WindowActive and TargetButtonObj and TargetButtonObj.ButtonBackground.Visible then
                                                              TargetButtonObj.ButtonBackground.Color = TargetButtonObj.OriginalBackgroundColor
                                                              TargetButtonObj.ButtonBackground.Transparency = TargetButtonObj.OriginalBackgroundTransparency
                                                              -- Re-check hover state after feedback to set border correctly
                                                              local isHoverNow = WindowActive:IsHovered(TargetButtonObj.ButtonBackground)
                                                              TargetButtonObj.ButtonBorder.Color = isHoverNow and (TargetButtonObj.AccentColor or Colors["Accent"]) or TargetButtonObj.DefaultBorderColor
                                                         end
                                                     end)

                                                     -- Execute callback
                                                     if InterfaceObj.Callback then spawn(InterfaceObj.Callback) end
                                                     UIClickHandled = true
                                                     return -- Stop checking after handling click

                                                 end
                                             elseif InterfaceObj.Type == "Toggle" then
                                                 -- Check hover on box OR label
                                                 local IsHoverBox = WindowActive:IsHovered(InterfaceObj.BoxBackground)
                                                 local IsHoverLabel = WindowActive:IsHovered(InterfaceObj.LabelText)
                                                 if IsHoverBox or IsHoverLabel then
                                                     -- Toggle State
                                                     InterfaceObj.State = not InterfaceObj.State

                                                     -- Update Visuals
                                                     if InterfaceObj.State then
                                                         InterfaceObj.BoxBackground.Color = InterfaceObj.AccentColor
                                                     else
                                                         InterfaceObj.BoxBackground.Color = InterfaceObj.DefaultBoxColor
                                                     end
                                                     InterfaceObj.BoxBackground.Filled = true -- Always filled, just color changes

                                                     -- Execute Callback with new state
                                                     if InterfaceObj.Callback then
                                                         spawn(function() InterfaceObj.Callback(InterfaceObj.State) end)
                                                     end
                                                     UIClickHandled = true
                                                     return -- Stop checking after handling click
                                                 end
                                             end
                                         end
                                     end
                                 end
                                 if UIClickHandled then return end -- Exit section loop if handled
                             end
                         end
                         CheckElementInteraction(CurrentTabContent.LeftSections)
                         CheckElementInteraction(CurrentTabContent.RightSections)
                    end
                end
            end

            -- Hover Effect Handling (runs every frame regardless of click)
            if WindowActive.ActiveTab then
                 local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                 if CurrentTabContent then
                     local function UpdateElementVisuals(Sections)
                         for _, SectionObj in ipairs(Sections) do
                             if SectionObj.Visible and SectionObj.Interfaces then
                                 for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                                     if InterfaceObj.Visible then
                                         if InterfaceObj.Type == "Button" then
                                             local IsCurrentlyHovered = WindowActive:IsHovered(InterfaceObj.ButtonBackground)
                                             if IsCurrentlyHovered then
                                                 IsMouseOverUI = true
                                                 HoveredObject = InterfaceObj -- Track hovered object
                                             end
                                             -- Update border color based on hover, unless click animation is active
                                             if InterfaceObj.ButtonBackground.Color ~= (InterfaceObj.AccentColor or Colors["Tab Selected Background"]) then -- Don't override click feedback color
                                                 InterfaceObj.ButtonBorder.Color = IsCurrentlyHovered and (InterfaceObj.AccentColor or Colors["Accent"]) or InterfaceObj.DefaultBorderColor
                                             end
                                         elseif InterfaceObj.Type == "Toggle" then
                                             local IsHoverBox = WindowActive:IsHovered(InterfaceObj.BoxBackground)
                                             local IsHoverLabel = WindowActive:IsHovered(InterfaceObj.LabelText)
                                             local IsCurrentlyHovered = IsHoverBox or IsHoverLabel

                                             if IsCurrentlyHovered then
                                                 IsMouseOverUI = true
                                                 HoveredObject = InterfaceObj -- Track hovered object
                                             end
                                             -- Update border color based on hover
                                             InterfaceObj.BoxBorder.Color = IsCurrentlyHovered and InterfaceObj.AccentColor or InterfaceObj.DefaultBorderColor
                                         end
                                     end
                                 end
                             end
                         end
                     end
                     UpdateElementVisuals(CurrentTabContent.LeftSections)
                     UpdateElementVisuals(CurrentTabContent.RightSections)
                 end
             end
        end

        wait() -- Yield thread briefly
    end
end)

print("Severe UI Lib Initialized - Toggle Added")
return Library
