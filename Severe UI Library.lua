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
    ["Object Background"] = {25, 25, 25}, -- Used for Toggle box
    ["Object Border"] = {35, 35, 35},     -- Used for Toggle box border
    ["Object Filled"] = {67, 12, 122},    -- Accent color for Toggle fill
    ["Dropdown Option Background"] = {19, 19, 19}
}

-- Layout Constants
local SECTION_PADDING = { X = 5, Y = 5 }
local SECTION_TITLE_HEIGHT = 15 -- Approx height needed for section title + padding
local ELEMENT_PADDING = { X = 5, Y = 3 } -- Padding around elements within sections
local TOGGLE_SIZE = 12 -- Size of the toggle square
local TOGGLE_LABEL_OFFSET = 5 -- Space between toggle box and label

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

-- Enhanced visibility function
local function SetVisibilityRecursive(InterfaceCollection, Visible)
    for _, Interface in pairs(InterfaceCollection) do
        local IsElementVisible = Visible

        -- Handle sections specifically, they manage internal visibility
        if Interface.IsSection then
             Interface.Visible = IsElementVisible -- Set section's own visibility flag
             Interface.Background.Visible = IsElementVisible
             Interface.Border.Visible = IsElementVisible
             if Interface.Title then
                Interface.Title.Visible = IsElementVisible
             end
             -- Recursively apply to interfaces *within* the section
             SetVisibilityRecursive(Interface.Interfaces, IsElementVisible)
        -- Handle Toggles (or other future elements)
        elseif Interface.IsToggle then
             Interface.Visible = IsElementVisible -- Set toggle's own visibility flag
             Interface.ToggleBox.Visible = IsElementVisible
             Interface.ToggleBoxBorder.Visible = IsElementVisible
             Interface.ToggleLabel.Visible = IsElementVisible
             -- Only show fill if toggle is On *and* supposed to be visible
             Interface.ToggleFill.Visible = IsElementVisible and Interface.IsOn
        -- Handle generic drawing objects if needed (fallback)
        elseif Interface.Visible ~= nil then
             Interface.Visible = IsElementVisible
        end

        -- Original checks for window parts etc. (if passed directly)
        if Interface.Interfaces and not Interface.IsSection then -- Avoid double recursion on sections
             SetVisibilityRecursive(Interface.Interfaces, IsElementVisible)
        end
        if Interface.Background and Interface.Background.Visible ~= nil and not Interface.IsSection then
            Interface.Background.Visible = IsElementVisible
        end
        if Interface.Border and Interface.Border.Visible ~= nil and not Interface.IsSection then
            Interface.Border.Visible = IsElementVisible
        end
        if Interface.Title and Interface.Title.Visible ~= nil and not Interface.IsSection then
            Interface.Title.Visible = IsElementVisible
        end
        if Interface.Remove and Interface.Position and not Interface.IsToggle and not Interface.IsSection then
            Interface.Visible = IsElementVisible
        end
         if Interface.SelectedHighlight and Interface.SelectedHighlight.Visible ~= nil then
            -- Special handling for tab highlight during toggle
            if Interface.IsTabHighlight then
                -- Visibility depends on tab selection AND overall UI visibility
                Interface.Visible = Visible and (Interface.ParentTab.Name == WindowActive.ActiveTab)
            else
                -- Default hide other highlights when toggling UI off
                 Interface.SelectedHighlight.Visible = false
            end
        end
    end
end


function ToggleUI()
    IsVisible = not IsVisible

    if WindowActive then
        local Main = WindowActive

        -- Toggle basic window elements
        Main.WindowBackground.Visible = IsVisible
        Main.Title.Visible = IsVisible
        Main.TabBackground.Visible = IsVisible
        Main.TabBorder.Visible = IsVisible
        Main.WindowBackground2.Visible = IsVisible
        Main.Window2Border.Visible = IsVisible
        Main.WindowBorder.Visible = IsVisible

        -- Toggle tabs and their contents
        for _, TabObj in ipairs(Main.Tabs) do
            local IsActiveTab = TabObj.Name == Main.ActiveTab

            TabObj.Button.Visible = IsVisible
            TabObj.ButtonBorder.Visible = IsVisible
            TabObj.ButtonText.Visible = IsVisible

             -- Explicitly handle highlight visibility
             if TabObj.SelectedHighlight then
                 TabObj.SelectedHighlight.Visible = IsVisible and IsActiveTab
             end

            -- Recursively toggle visibility for sections and their content
            local shouldShowContent = IsVisible and IsActiveTab
            SetVisibilityRecursive(TabObj.Content.LeftSections, shouldShowContent)
            SetVisibilityRecursive(TabObj.Content.RightSections, shouldShowContent)
            -- Note: Interfaces directly under TabContent are not used in current structure
            -- SetVisibilityRecursive(TabObj.Content.Interfaces, shouldShowContent)
        end

        if not IsVisible then
            IsDragging = false
        else
            -- Refresh layout if becoming visible
            Main:SelectTab(Main.ActiveTab) -- This calls Main:Sections indirectly
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

    -- Create Window Elements (same as before)
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

    -- Hover Check (modified slightly for clarity)
    function Main:IsHovered(Interface)
        if not IsVisible or not Interface or not Interface.Visible then return false end

        local MouseX, MouseY = Mouse.X, Mouse.Y
        local InterfacePos = Interface.Position
        local InterfaceSize = Interface.Size
        local InterfaceBounds = Interface.TextBounds -- For text objects

        if InterfacePos then
             local InterfaceX, InterfaceY = InterfacePos.x, InterfacePos.y
             local InterfaceW, InterfaceH

             if InterfaceSize then
                InterfaceW, InterfaceH = InterfaceSize.x, InterfaceSize.y
             elseif InterfaceBounds then
                 InterfaceW, InterfaceH = InterfaceBounds.x, InterfaceBounds.y
                 if Interface.Center then -- Adjust X for centered text
                     InterfaceX = InterfaceX - InterfaceW / 2
                 end
             else
                 return false -- Cannot determine bounds
             end

            return MouseX >= InterfaceX and MouseX <= InterfaceX + InterfaceW and MouseY >= InterfaceY and MouseY <= InterfaceY + InterfaceH
        end
        return false
    end

    function Main:IsHoveringWindow()
        if not IsVisible then return false end
        return Main:IsHovered(Main.WindowBackground)
    end

    -- Update main element positions (mostly unchanged, relies on Main:Sections for content)
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
        Main:Sections() -- Recalculate section positions and their internal elements
    end

    -- Update Tab Sizes (unchanged)
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

            -- Center text vertically, horizontally requires Center=true
            if ButtonText.TextBounds then
                 ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - (ButtonText.TextBounds.y / 2)}
            else
                 ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - 7} -- Approx fallback
            end
            ButtonText.Center = true -- Ensure horizontal centering
        end
    end


    -- Reworked Sections function for dynamic height and element positioning
    function Main:Sections()
        if not Main.ActiveTab or not Main.TabContents[Main.ActiveTab] then return end

        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
        local ParentPos = Main.WindowBackground2.Position
        local ParentSize = Main.WindowBackground2.Size
        local ParentWidth = ParentSize.x
        local AvailableWidth = ParentWidth - (SECTION_PADDING.X * 2) - SECTION_PADDING.X -- Space for 2 columns + padding between
        local ColumnWidth = math.floor(AvailableWidth / 2)

        local BaseX = ParentPos.x
        local BaseY = ParentPos.y

        local LeftColumnX = BaseX + SECTION_PADDING.X
        local RightColumnX = LeftColumnX + ColumnWidth + SECTION_PADDING.X
        local InitialY = BaseY + SECTION_PADDING.Y

        CurrentTabContent.CurrentLeftY = InitialY
        CurrentTabContent.CurrentRightY = InitialY

        -- Helper function to position a section and its internal elements
        local function PositionSectionAndContent(SectionObj, ColumnX, CurrentColumnY)
            local SectionBaseX = ColumnX
            local SectionBaseY = CurrentColumnY

            -- Position Section Background & Border first
            SectionObj.Background.Position = {SectionBaseX, SectionBaseY}
            SectionObj.Border.Position = {SectionBaseX, SectionBaseY}
            SectionObj.Background.Size = {ColumnWidth, SectionObj.Height} -- Use calculated height
            SectionObj.Border.Size = {ColumnWidth, SectionObj.Height}

            -- Position Title
            if SectionObj.Title then
                SectionObj.Title.Position = {SectionBaseX + SECTION_PADDING.X, SectionBaseY + ELEMENT_PADDING.Y}
                -- Visibility is handled by SetVisibilityRecursive
            end

            -- Position elements *inside* the section
            local InternalOffsetY = SECTION_TITLE_HEIGHT -- Start below title area
            for _, Element in ipairs(SectionObj.Interfaces) do
                if Element.IsToggle then
                     local ElementX = SectionBaseX + SECTION_PADDING.X
                     local ElementY = SectionBaseY + InternalOffsetY
                     Element.ToggleBox.Position = {ElementX, ElementY}
                     Element.ToggleBoxBorder.Position = {ElementX, ElementY}
                     Element.ToggleFill.Position = {ElementX, ElementY}
                     Element.ToggleLabel.Position = {ElementX + TOGGLE_SIZE + TOGGLE_LABEL_OFFSET, ElementY + (TOGGLE_SIZE / 2) - (Element.ToggleLabel.TextBounds.y / 2) }

                     InternalOffsetY = InternalOffsetY + Element.Height -- Use element's defined height
                -- Add other element types here (e.g., Button, Slider)
                end
            end

            -- Return the Y position for the *next* section
            return SectionBaseY + SectionObj.Height + SECTION_PADDING.Y
        end

        -- Position Left Sections
        for _, SectionObj in ipairs(CurrentTabContent.LeftSections) do
            if SectionObj.Visible then -- Only position visible sections
                 CurrentTabContent.CurrentLeftY = PositionSectionAndContent(SectionObj, LeftColumnX, CurrentTabContent.CurrentLeftY)
            end
        end

        -- Position Right Sections
        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
            if SectionObj.Visible then -- Only position visible sections
                 CurrentTabContent.CurrentRightY = PositionSectionAndContent(SectionObj, RightColumnX, CurrentTabContent.CurrentRightY)
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
        TabButtonText.Center = true -- Important for centering
        SetInitialVisibility(TabButtonText)

        local SelectedHighlight = Drawing.new("Square")
        SelectedHighlight.Color = Colors["Tab Selected Background"]
        SelectedHighlight.Transparency = 0.135
        SelectedHighlight.Filled = true
        SelectedHighlight.Visible = false
        SelectedHighlight.IsTabHighlight = true -- Mark for visibility handling


        local TabContent = {
            Name = TabName,
            Interfaces = {}, -- Elements directly under tab (not typically used now)
            LeftSections = {},
            RightSections = {},
            CurrentLeftY = 0, -- Track Y positions for column layout
            CurrentRightY = 0,
            Visible = false -- Content area visibility tied to tab selection
        }

        -- Define Section method within TabContent context
        function TabContent:Section(SectionName, Options)
            Options = Options or {}
            local Side = Options.Side or "Left"
            SectionName = SectionName or "Section"

            local SectionBackground = Drawing.new("Square")
            SectionBackground.Color = Colors["Section Background"]
            SectionBackground.Filled = true
            SectionBackground.Thickness = 1
            SectionBackground.Transparency = 1
            SectionBackground.Visible = false -- Initial state

            local SectionBorder = Drawing.new("Square")
            SectionBorder.Color = Colors["Section Border"]
            SectionBorder.Filled = false
            SectionBorder.Thickness = 1
            SectionBorder.Transparency = 1
            SectionBorder.Visible = false -- Initial state

            local SectionTitle = Drawing.new("Text")
            SectionTitle.Text = SectionName
            SectionTitle.Size = 12
            SectionTitle.Font = 5
            SectionTitle.Color = Colors["Text"]
            SectionTitle.Outline = true
            SectionTitle.OutlineColor = {0, 0, 0}
            SectionTitle.Transparency = 1
            SectionTitle.Center = false
            SectionTitle.Visible = false -- Initial state

            local SectionObj = {
                IsSection = true, -- Identifier
                Name = SectionName,
                Side = Side,
                Background = SectionBackground,
                Border = SectionBorder,
                Title = SectionTitle,
                Interfaces = {}, -- Holds toggles, buttons, etc.
                Visible = false, -- Section's own visibility state
                Height = SECTION_TITLE_HEIGHT, -- Start with title height + padding
                CurrentYOffset = SECTION_TITLE_HEIGHT -- Where the next element starts vertically
            }
             SelectedHighlight.ParentTab = SectionObj -- Link highlight back to parent for visibility check


            -- Define Toggle method within SectionObj context
            function SectionObj:Toggle(Name, DefaultValue, Callback)
                local IsOn = DefaultValue or false
                Name = Name or "Toggle"
                Callback = Callback or function() end

                local ToggleBox = Drawing.new("Square")
                ToggleBox.Size = {TOGGLE_SIZE, TOGGLE_SIZE}
                ToggleBox.Color = Colors["Object Background"]
                ToggleBox.Filled = true
                ToggleBox.Visible = false -- Initial state

                local ToggleBoxBorder = Drawing.new("Square")
                ToggleBoxBorder.Size = {TOGGLE_SIZE, TOGGLE_SIZE}
                ToggleBoxBorder.Color = Colors["Object Border"]
                ToggleBoxBorder.Filled = false
                ToggleBoxBorder.Thickness = 1
                ToggleBoxBorder.Visible = false -- Initial state

                local ToggleFill = Drawing.new("Square")
                ToggleFill.Size = {TOGGLE_SIZE - 2, TOGGLE_SIZE - 2} -- Slightly smaller fill
                ToggleFill.Color = Colors["Object Filled"]
                ToggleFill.Filled = true
                ToggleFill.Visible = IsOn -- Initial state based on DefaultValue

                local ToggleLabel = Drawing.new("Text")
                ToggleLabel.Text = Name
                ToggleLabel.Size = 12
                ToggleLabel.Font = 0 -- Basic font
                ToggleLabel.Color = Colors["Text"]
                ToggleLabel.Outline = false -- Cleaner look for small text
                ToggleLabel.Transparency = 1
                ToggleLabel.Center = false
                ToggleLabel.Visible = false -- Initial state

                local ToggleElementHeight = TOGGLE_SIZE + ELEMENT_PADDING.Y

                local ToggleObj = {
                    IsToggle = true, -- Identifier
                    Name = Name,
                    ToggleBox = ToggleBox,
                    ToggleBoxBorder = ToggleBoxBorder,
                    ToggleFill = ToggleFill,
                    ToggleLabel = ToggleLabel,
                    IsOn = IsOn,
                    Callback = Callback,
                    Visible = false, -- Toggle's own visibility state
                    Height = ToggleElementHeight, -- Store required height
                    ParentSection = self -- Reference back to the section
                }

                -- Position elements relative to section origin (absolute done in Main:Sections)
                local ElementYOffset = self.CurrentYOffset
                ToggleBox.Position = {0, ElementYOffset} -- Placeholder, absolute set later
                ToggleBoxBorder.Position = {0, ElementYOffset}
                ToggleFill.Position = {1, ElementYOffset + 1} -- Offset within border
                ToggleLabel.Position = {TOGGLE_SIZE + TOGGLE_LABEL_OFFSET, ElementYOffset} -- Placeholder

                table.insert(self.Interfaces, ToggleObj)

                -- Update section's internal offset and total height
                self.CurrentYOffset = self.CurrentYOffset + ToggleElementHeight
                self.Height = self.Height + ToggleElementHeight

                 -- Make visible immediately if parent section should be visible
                 local shouldBeVisible = IsVisible and Main.ActiveTab == self.ParentTab.Name and self.Visible
                 ToggleObj.Visible = shouldBeVisible
                 ToggleBox.Visible = shouldBeVisible
                 ToggleBoxBorder.Visible = shouldBeVisible
                 ToggleLabel.Visible = shouldBeVisible
                 ToggleFill.Visible = shouldBeVisible and IsOn

                return ToggleObj -- Return the toggle object if needed elsewhere
            end

            -- Add section to the correct list in the tab content
            if Side == "Left" then
                table.insert(self.LeftSections, SectionObj)
            else
                table.insert(self.RightSections, SectionObj)
            end
             SectionObj.ParentTab = self -- Link section back to its parent TabContent

            -- Set initial visibility if the tab is active and UI is visible
            if IsVisible and Main.ActiveTab == self.Name then
                SectionObj.Visible = true
                SectionBackground.Visible = true
                SectionBorder.Visible = true
                SectionTitle.Visible = true
                -- No need to call Main:Sections here, it's called by SelectTab or dragging
            end

            return SectionObj
        end -- End of TabContent:Section definition

        local TabObj = {
            Name = TabName,
            Button = TabButton,
            ButtonBorder = TabButtonBorder,
            ButtonText = TabButtonText,
            SelectedHighlight = SelectedHighlight,
            Content = TabContent -- Contains Left/Right sections
        }

        table.insert(Main.Tabs, TabObj)
        Main.TabButtons[TabName] = TabObj
        Main.TabContents[TabName] = TabContent

        -- Set ParentTab reference for the highlight
        SelectedHighlight.ParentTab = TabObj.Content

        Main:UpdateTabSizes()

        -- Select the first tab automatically or re-select current if UI is visible
        if #Main.Tabs == 1 then
             Main:SelectTab(TabName) -- Select first tab added
        elseif IsVisible then
             Main:SelectTab(Main.ActiveTab) -- Re-apply selection if UI already visible
        else
             -- Ensure elements are hidden if UI is not visible
             TabButton.Visible = false
             TabButtonBorder.Visible = false
             TabButtonText.Visible = false
             SelectedHighlight.Visible = false
             SetVisibilityRecursive(TabContent.LeftSections, false)
             SetVisibilityRecursive(TabContent.RightSections, false)
        end


        return TabContent
    end -- End of Main:Tab definition

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] or not IsVisible then return end

        local PreviousTab = Main.ActiveTab

        -- Hide content of the previously active tab first
        if PreviousTab and Main.TabContents[PreviousTab] and PreviousTab ~= TabName then
             local PrevTabContent = Main.TabContents[PreviousTab]
             SetVisibilityRecursive(PrevTabContent.LeftSections, false)
             SetVisibilityRecursive(PrevTabContent.RightSections, false)
             if Main.TabButtons[PreviousTab] then
                 Main.TabButtons[PreviousTab].SelectedHighlight.Visible = false
             end
        end

        -- Show content of the new tab
        local SelectedTab = Main.TabButtons[TabName]
        SelectedTab.SelectedHighlight.Visible = true
        SelectedTab.Content.Visible = true -- Mark content area as active conceptually
        Main.ActiveTab = TabName

        SetVisibilityRecursive(SelectedTab.Content.LeftSections, true)
        SetVisibilityRecursive(SelectedTab.Content.RightSections, true)

        Main:Sections() -- Recalculate layout for the newly selected tab
    end

    WindowActive = Main
    return Main
end -- End of Library:Create definition


-- Main Loop (with Toggle interaction)
spawn(function()
    while true do
        local MouseLocation = getmouselocation(MouseService)
        Mouse.X = MouseLocation.x
        Mouse.Y = MouseLocation.y
        Mouse.Clicked = isleftclicked()
        Mouse.Pressed = isleftpressed()

        -- Keyboard Toggle for UI Visibility (unchanged)
        local Keys = getpressedkeys()
        local IsToggleKeyPressed = false
        if Keys then
            for _, k in ipairs(Keys) do
                if k == 'P' then -- Hardcoded toggle key
                    IsToggleKeyPressed = true
                    break
                end
            end
        end
        if IsToggleKeyPressed and not TogglePressed then
            ToggleUI()
        end
        TogglePressed = IsToggleKeyPressed


        if IsVisible and WindowActive then
            local IsHoveringSomething = false -- Track if mouse is over *any* UI element

            -- 1. Check Window Dragging
            local WindowPos = WindowActive.WindowBackground.Position
            local DragAreaYMax = WindowActive.TabBackground.Position.y -- Can only drag by title bar area
            local IsHoveringTitleBar = Mouse.Y < DragAreaYMax and WindowActive:IsHovered(WindowActive.WindowBackground) -- More specific hover check

            if Mouse.Clicked and IsHoveringTitleBar and not IsDragging then
                IsDragging = true
                DragOffsetX = Mouse.X - WindowPos.x
                DragOffsetY = Mouse.Y - WindowPos.y
                IsHoveringSomething = true
            elseif Mouse.Pressed and IsDragging then
                local NewX = Mouse.X - DragOffsetX
                local NewY = Mouse.Y - DragOffsetY
                WindowActive.WindowBackground.Position = {NewX, NewY}
                WindowActive:UpdateElementPositions() -- Update all child positions
                IsHoveringSomething = true
            elseif not Mouse.Pressed and IsDragging then
                 IsDragging = false
                 -- Don't reset IsHoveringSomething here, mouse might still be over UI
            end

            -- 2. Check Tab Clicks (only if not dragging)
            if not IsDragging and Mouse.Clicked and Mouse.Y >= DragAreaYMax and Mouse.Y < WindowActive.WindowBackground2.Position.y then -- Check Y bounds for tab bar
                 for _, TabObj in ipairs(WindowActive.Tabs) do
                     if WindowActive:IsHovered(TabObj.Button) then
                         WindowActive:SelectTab(TabObj.Name)
                         IsHoveringSomething = true
                         break -- Stop checking tabs once one is clicked
                     end
                 end
            end

            -- 3. Check Element Clicks (Toggles) within the Active Tab (only if not dragging)
            if not IsDragging and Mouse.Clicked and Main.ActiveTab then
                local ActiveContent = Main.TabContents[Main.ActiveTab]
                local function CheckSectionInterfaces(Sections)
                     for _, Section in ipairs(Sections) do
                         if Section.Visible then -- Only check visible sections
                             for _, Element in ipairs(Section.Interfaces) do
                                 if Element.IsToggle and Element.Visible then
                                     if WindowActive:IsHovered(Element.ToggleBox) then
                                         -- Clicked on Toggle!
                                         Element.IsOn = not Element.IsOn
                                         Element.ToggleFill.Visible = Element.IsOn
                                         -- Execute Callback safely
                                         if type(Element.Callback) == "function" then
                                             -- Use pcall for safety against errors in user callbacks
                                             pcall(Element.Callback, Element.IsOn)
                                         end
                                         IsHoveringSomething = true
                                         return true -- Stop checking interfaces once one is clicked
                                     end
                                 -- Add checks for other element types (Buttons etc.) here
                                 end
                             end
                         end
                     end
                     return false -- No click handled in this set of sections
                end

                if CheckSectionInterfaces(ActiveContent.LeftSections) then goto EndInteractionCheck end
                if CheckSectionInterfaces(ActiveContent.RightSections) then goto EndInteractionCheck end
            end

            ::EndInteractionCheck::

             -- Check if hovering any interactive element for potential passthrough logic later
             if not IsHoveringSomething and not IsDragging then
                 IsHoveringSomething = WindowActive:IsHoveringWindow() -- Check if just hovering window background
             end
             -- Example: set_window_passthrough(not IsHoveringSomething) -- Make overlay clickable if not interacting

        end -- End if IsVisible and WindowActive

        wait() -- Yield thread
    end -- End while true
end) -- End spawn

print'1'
return Library
