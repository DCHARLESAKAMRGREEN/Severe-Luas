local Colors = {
    ["Accent"] = {113, 93, 133},
    ["Window Background"] = {30, 30, 30},
    ["Window Border"] = {45, 45, 45},
    ["Tab Background"] = {20, 20, 20},
    ["Tab Border"] = {45, 45, 45},
    ["Tab Toggle Background"] = {28, 28, 28},
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
local ActiveWindow = nil
local IsDragging = false
local DragOffsetX = 0
local DragOffsetY = 0
local IsVisible = true 
local WasPDown = false 

function ToggleUI()
    IsVisible = not IsVisible
    if ActiveWindow then
        local Main = ActiveWindow
        
        -- Toggle main window elements
        Main.WindowBackground.Visible = IsVisible
        Main.Title.Visible = IsVisible
        Main.TabBackground.Visible = IsVisible
        Main.TabBorder.Visible = IsVisible
        Main.WindowBackground2.Visible = IsVisible
        Main.Window2Border.Visible = IsVisible
        Main.WindowBorder.Visible = IsVisible

        -- Toggle all tab buttons/text
        for _, TabObj in ipairs(Main.Tabs) do
             TabObj.Button.Visible = IsVisible
             TabObj.ButtonBorder.Visible = IsVisible
             TabObj.ButtonText.Visible = IsVisible
        end

        if not IsVisible then
             -- Explicitly hide all elements within all tabs when UI is hidden
             for _, TabContent in pairs(Main.TabContents) do
                 for _, Element in pairs(TabContent.Elements) do
                     if Element.Visible ~= nil then
                         Element.Visible = false
                     end
                 end
             end
             -- Stop dragging if UI is hidden
             IsDragging = false 
        else
            -- If becoming visible, re-select the active tab to show its content
            Main:SelectTab(Main.ActiveTab) 
        end
    end
end


function Library:Create(Title)
    local Main = {}
    
    -- Helper to set initial visibility
    local function SetInitialVisibility(Element)
        if Element and Element.Visible ~= nil then
            Element.Visible = IsVisible
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
    Main.WindowBackground2.Color = Colors["Section Background"]
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
    Main.WindowBorder.Color = Colors["Window Border"]
    Main.WindowBorder.Filled = false
    Main.WindowBorder.Thickness = 1
    Main.WindowBorder.Transparency = 1
    SetInitialVisibility(Main.WindowBorder)

    Main.Tabs = {}
    Main.TabButtons = {}
    Main.TabContents = {}
    Main.ActiveTab = nil

    function Main:IsHovered(Element)
        if not IsVisible or not Element or not Element.Visible then return false end -- Cannot hover invisible elements
        local MouseX, MouseY = Mouse.X, Mouse.Y
        local ElemX, ElemY = Element.Position.x, Element.Position.y
        local ElemW, ElemH = Element.Size.x, Element.Size.y

        return MouseX >= ElemX and MouseX <= ElemX + ElemW and MouseY >= ElemY and MouseY <= ElemY + ElemH
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
            TabObj.ButtonText.Position = {CurrentX + (TabWidth / 2), Main.TabBackground.Position.y + (Main.TabBackground.Size.y / 2) - 7}
            CurrentX = CurrentX + TabWidth
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
            Visible = false -- Content starts hidden until selected
        }

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

        Main:UpdateTabSizes() -- Recalculates positions/sizes including new tab

        -- Set visibility correctly based on current state
        if IsVisible then
            if #Main.Tabs == 1 then
                Main:SelectTab(TabName) -- Select if it's the first tab and UI is visible
            else
                 -- Ensure only the active tab's content is visible
                 Main:SelectTab(Main.ActiveTab) 
            end
        else 
             -- Ensure new tab elements are hidden if UI is globally hidden
             TabButton.Visible = false
             TabButtonBorder.Visible = false
             TabButtonText.Visible = false
        end


        return TabContent
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then return end 
        if not IsVisible then return end -- Don't change selection if UI is hidden

        for _, Tab in ipairs(Main.Tabs) do
            Tab.Button.Color = Colors["Tab Toggle Background"] -- Keep button color logic
            Tab.Content.Visible = false -- Hide all content first

            for _, Element in pairs(Tab.Content.Elements) do
                if Element.Visible ~= nil then
                    Element.Visible = false
                end
            end
        end

        local SelectedTab = Main.TabButtons[TabName]
        SelectedTab.Button.Color = Colors["Accent"] -- Highlight selected tab button
        SelectedTab.Content.Visible = true -- Show selected content container
        Main.ActiveTab = TabName

        -- Make elements within the selected tab visible
        for _, Element in pairs(SelectedTab.Content.Elements) do
            if Element.Visible ~= nil then
                Element.Visible = true
            end
        end
    end

    ActiveWindow = Main
    -- Ensure initial state respects IsVisible
    if not IsVisible then
        ToggleUI() -- Call toggle once to ensure all elements are correctly hidden if starting hidden
        IsVisible = false -- ToggleUI flips it, so set it back
    end
    return Main
end

spawn(function()
    while true do
        -- Always update mouse state and check for toggle key
        local MouseLocation = getmouselocation(MouseService)
        Mouse.X = MouseLocation.x
        Mouse.Y = MouseLocation.y
        Mouse.Clicked = isleftclicked() 
        Mouse.Pressed = isleftpressed() 
        
        local Keys = getpressedkeys() -- Assuming returns a table like { ['P'] = true }
        local IsPDown = Keys and Keys['P'] -- Check if 'P' key exists and is true

        if IsPDown and not WasPDown then
            ToggleUI()
        end
        WasPDown = IsPDown -- Update state for next frame

        -- Only process UI interactions if visible
        if IsVisible and ActiveWindow then
            local IsHovering = ActiveWindow:IsHoveringWindow() -- Check hover only if visible

            -- Define Drag Area (e.g., the title bar area up to the tabs)
            local DragAreaYMax = ActiveWindow.TabBackground.Position.y
            local IsOverDragArea = Mouse.X >= ActiveWindow.WindowBackground.Position.x and 
                                   Mouse.X <= ActiveWindow.WindowBackground.Position.x + ActiveWindow.WindowBackground.Size.x and
                                   Mouse.Y >= ActiveWindow.WindowBackground.Position.y and 
                                   Mouse.Y < DragAreaYMax -- Only allow dragging by the top bar

            -- Handle Dragging
            if Mouse.Clicked and IsOverDragArea and not IsDragging then
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

            -- Handle Tab Click
            if Mouse.Clicked and not IsDragging then 
                for _, TabObj in ipairs(ActiveWindow.Tabs) do
                    -- Use the IsHovered check which respects visibility
                    if ActiveWindow:IsHovered(TabObj.Button) then 
                         ActiveWindow:SelectTab(TabObj.Name)
                         break 
                    end
                end
            end
        end -- End of IsVisible block

        wait()
    end
end)

print("Library Loaded V1")
return Library
