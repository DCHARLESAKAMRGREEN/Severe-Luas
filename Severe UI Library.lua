local Colors = {
    ["Accent"] = {113, 93, 133},
    ["Window Background"] = {30, 30, 30},
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
    ["Dropdown Option Background"] = {19, 19, 19},
    ["Cursor"] = {255, 255, 255}
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
local TogglePressed = false
local SectionPadding = 10
local SectionMiddlePadding = 10
local CustomCursor = nil

local function SetElementVisibilityRecursive(Elements, Visible)
    for _, Element in pairs(Elements) do
        if Element.Visible ~= nil then
             Element.Visible = Visible
        end
        if Element.Elements then
            SetElementVisibilityRecursive(Element.Elements, Visible)
        end
         if Element.Background and Element.Background.Visible ~= nil then
             Element.Background.Visible = Visible
         end
         if Element.Border and Element.Border.Visible ~= nil then
             Element.Border.Visible = Visible
         end
         if Element.Remove and Element.Position then
             Element.Visible = Visible
         end
    end
end

function ToggleUI()
    IsVisible = not IsVisible
    setmouseiconenabled(MouseService, not IsVisible)

    if CustomCursor then
        CustomCursor.Visible = IsVisible
    end

    if ActiveWindow then
        local Main = ActiveWindow

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

             local IsActiveTab = TabObj.Name == Main.ActiveTab
             SetElementVisibilityRecursive(TabObj.Content.LeftSections, IsVisible and IsActiveTab)
             SetElementVisibilityRecursive(TabObj.Content.RightSections, IsVisible and IsActiveTab)
             SetElementVisibilityRecursive(TabObj.Content.Elements, IsVisible and IsActiveTab)
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

    local function SetInitialVisibility(Element)
        if Element and Element.Visible ~= nil then
            Element.Visible = IsVisible
        end
    end

    CustomCursor = Drawing.new("Triangle")
    CustomCursor.Color = Colors["Cursor"]
    CustomCursor.Filled = true
    CustomCursor.Thickness = 1
    CustomCursor.Transparency = 1
    CustomCursor.Visible = IsVisible
    setmouseiconenabled(MouseService, not IsVisible)

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
    Main.WindowBackground2.Color = Colors["Window Background"]
    Main.WindowBackground2.Filled = true
    Main.WindowBackground2.Thickness = 1
    Main.WindowBackground2.Transparency = 1
    SetInitialVisibility(Main.WindowBackground2)

    Main.Window2Border = Drawing.new("Square")
    Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
    Main.Window2Border.Size = {Main.WindowBackground2.Size.x, Main.WindowBackground2.Size.y}
    Main.Window2Border.Color = Colors["Section Border"]
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

    function Main:IsHovered(Element)
        if not IsVisible or not Element or not Element.Visible then return false end
        local MouseX, MouseY = Mouse.X, Mouse.Y
        if Element.Size and Element.Position then
             local ElemX, ElemY = Element.Position.x, Element.Position.y
             local ElemW, ElemH = Element.Size.x, Element.Size.y
             return MouseX >= ElemX and MouseX <= ElemX + ElemW and MouseY >= ElemY and MouseY <= ElemY + ElemH
        elseif Element.TextBounds and Element.Position then
             local ElemX, ElemY = Element.Position.x, Element.Position.y
             local ElemW, ElemH = Element.TextBounds.x, Element.TextBounds.y
             if Element.Center then
                 ElemX = ElemX - ElemW / 2
             end
             -- Adjust Y pos for centering text if needed, though TextBounds should account for height
             -- ElemY = ElemY - ElemH / 2 -- May not be needed depending on how Position is set
             return MouseX >= ElemX and MouseX <= ElemX + ElemW and MouseY >= ElemY and MouseY <= ElemY + ElemH
        end
        return false
    end

    function Main:IsHoveringWindow()
         if not IsVisible then return false end
         return Main:IsHovered(Main.WindowBackground)
    end

    function Main:UpdateElementPositions()
        local BaseX, BaseY = Main.WindowBackground.Position.x, Main.WindowBackground.Position.y

        Main.Title.Position = {BaseX + 10, BaseY + 5}
        Main.TabBackground.Position = {BaseX + 10, BaseY + 25}
        Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
        Main.WindowBackground2.Position = {BaseX + 10, BaseY + 50}
        Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
        Main.WindowBorder.Position = {BaseX, BaseY}

        Main:UpdateTabSizes()
        Main:UpdateSectionPositions()
    end

    function Main:UpdateTabSizes()
        local TabCount = #Main.Tabs
        if TabCount == 0 then return end

        local TotalWidth = Main.TabBackground.Size.x
        local CalculatedTabWidth = TotalWidth / TabCount
        local MinTabWidth = 50
        local TabWidth = math.max(CalculatedTabWidth, MinTabWidth)

        if TabWidth * TabCount > TotalWidth then
             TabWidth = TotalWidth / TabCount
        end

        local CurrentX = Main.TabBackground.Position.x
        for i, TabObj in ipairs(Main.Tabs) do
            TabObj.Button.Size = {TabWidth, Main.TabBackground.Size.y}
            TabObj.Button.Position = {CurrentX, Main.TabBackground.Position.y}
            TabObj.ButtonBorder.Size = {TabWidth, Main.TabBackground.Size.y}
            TabObj.ButtonBorder.Position = {CurrentX, Main.TabBackground.Position.y}
            if TabObj.ButtonText.TextBounds then -- Check if TextBounds exists
                 TabObj.ButtonText.Position = {CurrentX + (TabWidth / 2), Main.TabBackground.Position.y + (Main.TabBackground.Size.y / 2) - (TabObj.ButtonText.TextBounds.y / 2)}
            else -- Fallback if TextBounds isn't ready immediately
                 TabObj.ButtonText.Position = {CurrentX + (TabWidth / 2), Main.TabBackground.Position.y + (Main.TabBackground.Size.y / 2) - 7}
            end
            CurrentX = CurrentX + TabWidth
        end
    end

    function Main:UpdateSectionPositions()
        if not Main.ActiveTab or not Main.TabContents[Main.ActiveTab] then return end

        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
        local ParentWidth = Main.WindowBackground2.Size.x
        local AvailableWidth = ParentWidth - (SectionPadding * 2) - SectionMiddlePadding
        local ColumnWidth = AvailableWidth / 2

        local BaseX = Main.WindowBackground2.Position.x
        local BaseY = Main.WindowBackground2.Position.y

        local LeftColumnX = BaseX + SectionPadding
        local RightColumnX = LeftColumnX + ColumnWidth + SectionMiddlePadding
        local InitialY = BaseY + SectionPadding

        CurrentTabContent.CurrentLeftY = InitialY
        CurrentTabContent.CurrentRightY = InitialY

        local function PositionSection(SectionObj, ColumnX, CurrentY)
            local PlaceholderHeight = 100
            SectionObj.Background.Position = {ColumnX, CurrentY}
            SectionObj.Border.Position = {ColumnX, CurrentY}
            SectionObj.Background.Size = {ColumnWidth, PlaceholderHeight}
            SectionObj.Border.Size = {ColumnWidth, PlaceholderHeight}
            return CurrentY + PlaceholderHeight + SectionPadding
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

        local TabContent = {
            Name = TabName,
            Elements = {},
            LeftSections = {},
            RightSections = {},
            CurrentLeftY = 0,
            CurrentRightY = 0,
            Visible = false
        }

        function TabContent:Section(SectionName, Options)
            Options = Options or {}
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

            local SectionObj = {
                Name = SectionName or "Section",
                Side = Side,
                Background = SectionBackground,
                Border = SectionBorder,
                Elements = {},
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
                 Main:UpdateSectionPositions()
            end

            return SectionObj
        end

        local TabObj = {
            Name = TabName,
            Button = TabButton,
            ButtonBorder = TabButtonBorder,
            ButtonText = TabButtonText,
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
        end

        return TabContent
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then return end
        if not IsVisible then return end

        for _, OtherTab in ipairs(Main.Tabs) do
            OtherTab.Button.Color = Colors["Tab Toggle Background"]
            OtherTab.Button.Transparency = 1 -- Reset transparency for non-selected tabs
            OtherTab.Content.Visible = false
            SetElementVisibilityRecursive(OtherTab.Content.LeftSections, false)
            SetElementVisibilityRecursive(OtherTab.Content.RightSections, false)
            SetElementVisibilityRecursive(OtherTab.Content.Elements, false)
        end

        local SelectedTab = Main.TabButtons[TabName]
        SelectedTab.Button.Color = Colors["Tab Selected Background"]
        SelectedTab.Button.Transparency = 0.6 -- Set transparency for selected tab (0.4 as requested)
        SelectedTab.Content.Visible = true
        Main.ActiveTab = TabName

        SetElementVisibilityRecursive(SelectedTab.Content.LeftSections, true)
        SetElementVisibilityRecursive(SelectedTab.Content.RightSections, true)
        SetElementVisibilityRecursive(SelectedTab.Content.Elements, true)

        Main:UpdateSectionPositions()
    end

    ActiveWindow = Main
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

        if IsVisible then
            if ActiveWindow then
                local DragAreaYMax = ActiveWindow.TabBackground.Position.y
                local IsHoveredDragArea = Mouse.X >= ActiveWindow.WindowBackground.Position.x and
                                      Mouse.X <= ActiveWindow.WindowBackground.Position.x + ActiveWindow.WindowBackground.Size.x and
                                      Mouse.Y >= ActiveWindow.WindowBackground.Position.y and
                                      Mouse.Y < DragAreaYMax

                if Mouse.Clicked and IsHoveredDragArea and not IsDragging then
                    IsDragging = true
                    DragOffsetX = Mouse.X - ActiveWindow.WindowBackground.Position.x
                    DragOffsetY = Mouse.Y - ActiveWindow.WindowBackground.Position.y
                elseif Mouse.Pressed and IsDragging then
                    local NewX = Mouse.X - DragOffsetX
                    local NewY = Mouse.Y - DragOffsetY
                    ActiveWindow.WindowBackground.Position = {NewX, NewY}
                    ActiveWindow:UpdateElementPositions()
                elseif not Mouse.Pressed and IsDragging then
                     IsDragging = false
                end

                if Mouse.Clicked and not IsDragging then
                    for _, TabObj in ipairs(ActiveWindow.Tabs) do
                        if ActiveWindow:IsHovered(TabObj.Button) then
                            ActiveWindow:SelectTab(TabObj.Name)
                            break
                        end
                    end
                end
            end

            if CustomCursor then
                local CursorX, CursorY = Mouse.X, Mouse.Y
                CustomCursor.PointA = { CursorX, CursorY }
                CustomCursor.PointB = { CursorX + 5, CursorY + 13 }
                CustomCursor.PointC = { CursorX + 13, CursorY + 5 }
                CustomCursor.Visible = true
            end
        elseif CustomCursor then
            CustomCursor.Visible = false
        end

        wait()
    end
end)

print("V6")
return Library
