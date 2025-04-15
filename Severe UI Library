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

local Library = {}

function Library:Create(Title)
    local Main = {}
    
    -- Get MouseService
    local Game = Game()
    local MouseService = findservice(Game, "UserInputService")
    
    -- Window background
    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 750}
    Main.WindowBackground.Position = {350, 100}
    Main.WindowBackground.Color = Colors["Window Background"]
    Main.WindowBackground.Filled = true
    Main.WindowBackground.Thickness = 1
    Main.WindowBackground.Transparency = 1
    Main.WindowBackground.Visible = true

    -- Title
    Main.Title = Drawing.new("Text")
    Main.Title.Text = Title or "Severe UI"
    Main.Title.Size = 16
    Main.Title.Font = 5
    Main.Title.Color = Colors["Text"]
    Main.Title.Outline = true
    Main.Title.OutlineColor = {0, 0, 0}
    Main.Title.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 5}
    Main.Title.Transparency = 1
    Main.Title.Visible = true
    Main.Title.Center = false

    -- Tab background
    Main.TabBackground = Drawing.new("Square")
    Main.TabBackground.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 25}
    Main.TabBackground.Size = {Main.WindowBackground.Size.x - 20, 25}
    Main.TabBackground.Color = Colors["Tab Background"]
    Main.TabBackground.Filled = true
    Main.TabBackground.Thickness = 1
    Main.TabBackground.Transparency = 1
    Main.TabBackground.Visible = true

    -- Tab border
    Main.TabBorder = Drawing.new("Square")
    Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
    Main.TabBorder.Size = {Main.TabBackground.Size.x, Main.TabBackground.Size.y}
    Main.TabBorder.Color = Colors["Tab Border"]
    Main.TabBorder.Filled = false
    Main.TabBorder.Thickness = 1
    Main.TabBorder.Transparency = 1
    Main.TabBorder.Visible = true

    -- Content background
    Main.WindowBackground2 = Drawing.new("Square")
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 50}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 60}
    Main.WindowBackground2.Color = Colors["Section Background"]
    Main.WindowBackground2.Filled = true
    Main.WindowBackground2.Thickness = 1
    Main.WindowBackground2.Transparency = 1
    Main.WindowBackground2.Visible = true

    -- Content border
    Main.Window2Border = Drawing.new("Square")
    Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
    Main.Window2Border.Size = {Main.WindowBackground2.Size.x, Main.WindowBackground2.Size.y}
    Main.Window2Border.Color = Colors["Section Border"]
    Main.Window2Border.Filled = false
    Main.Window2Border.Thickness = 1
    Main.Window2Border.Transparency = 1
    Main.Window2Border.Visible = true

    -- Window border
    Main.WindowBorder = Drawing.new("Square")
    Main.WindowBorder.Size = {Main.WindowBackground.Size.x, Main.WindowBackground.Size.y}
    Main.WindowBorder.Position = {Main.WindowBackground.Position.x, Main.WindowBackground.Position.y}
    Main.WindowBorder.Color = Colors["Window Border"]
    Main.WindowBorder.Filled = false
    Main.WindowBorder.Thickness = 1
    Main.WindowBorder.Transparency = 1
    Main.WindowBorder.Visible = true

    -- Tab system
    Main.Tabs = {}
    Main.TabButtons = {}
    Main.TabContents = {}
    Main.ActiveTab = nil
    Main.Dragging = false
    Main.DragOffset = {x = 0, y = 0}

    -- Helper function to check if a point is within a rectangle
    function Main:IsHovered(Rect, Point)
        return Point.x >= Rect.Position.x and 
               Point.x <= Rect.Position.x + Rect.Size.x and 
               Point.y >= Rect.Position.y and 
               Point.y <= Rect.Position.y + Rect.Size.y
    end

    -- Function to add a tab
    function Main:Tab(TabName)
        if not TabName then
            TabName = "Tab " .. (#Main.Tabs + 1)
        end
        
        -- Create tab button
        local TabCount = #Main.Tabs
        local TabWidth = 500 -- Fixed width for tabs
        local TabX = Main.TabBackground.Position.x + (TabCount * TabWidth)
        
        -- Create the tab button
        local TabButton = Drawing.new("Square")
        TabButton.Size = {TabWidth, Main.TabBackground.Size.y}
        TabButton.Position = {TabX, Main.TabBackground.Position.y}
        TabButton.Color = Colors["Tab Toggle Background"]
        TabButton.Filled = true
        TabButton.Thickness = 1
        TabButton.Transparency = 1
        TabButton.Visible = true
        
        -- Create tab button border
        local TabButtonBorder = Drawing.new("Square")
        TabButtonBorder.Size = {TabWidth, Main.TabBackground.Size.y}
        TabButtonBorder.Position = {TabX, Main.TabBackground.Position.y}
        TabButtonBorder.Color = Colors["Tab Border"]
        TabButtonBorder.Filled = false
        TabButtonBorder.Thickness = 1
        TabButtonBorder.Transparency = 1
        TabButtonBorder.Visible = true
        
        -- Create tab button text
        local TabButtonText = Drawing.new("Text")
        TabButtonText.Text = TabName
        TabButtonText.Size = 14
        TabButtonText.Font = 5
        TabButtonText.Color = Colors["Text"]
        TabButtonText.Outline = true
        TabButtonText.OutlineColor = {0, 0, 0}
        TabButtonText.Position = {TabX + (TabWidth / 2), Main.TabBackground.Position.y + (Main.TabBackground.Size.y / 2) - 7}
        TabButtonText.Transparency = 1
        TabButtonText.Visible = true
        TabButtonText.Center = true
        
        -- Create tab content container
        local TabContent = {
            Name = TabName,
            Elements = {},
            Visible = false
        }
        
        -- Store everything
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
        
        -- If this is the first tab, make it active
        if #Main.Tabs == 1 then
            Main:SelectTab(TabName)
        end
        
        -- Return tab content for chaining
        return TabContent
    end

    -- Function to select a tab
    function Main:SelectTab(TabName)
        -- Hide all tab contents
        for _, Tab in ipairs(Main.Tabs) do
            -- Reset tab appearance
            Tab.Button.Color = Colors["Tab Toggle Background"]
            Tab.Content.Visible = false
            
            -- Hide all elements of this tab
            for _, Element in pairs(Tab.Content.Elements) do
                if Element.Visible ~= nil then
                    Element.Visible = false
                end
            end
        end
        
        -- Show selected tab content
        local SelectedTab = Main.TabButtons[TabName]
        if SelectedTab then
            SelectedTab.Button.Color = Colors["Accent"]
            SelectedTab.Content.Visible = true
            Main.ActiveTab = TabName
            
            -- Show all elements of this tab
            for _, Element in pairs(SelectedTab.Content.Elements) do
                if Element.Visible ~= nil then
                    Element.Visible = true
                end
            end
        end
    end

    -- Handle window dragging
    spawn(function()
        while wait(0.01) do
            -- Get mouse position
            local MousePos = getmouselocation(MouseService)
            local Mouse = {x = MousePos.x, y = MousePos.y}
            
            -- Handle dragging
            if isleftpressed() then
                -- Check if mouse is in title bar for drag start
                if Main:IsHovered({
                    Position = {Main.WindowBackground.Position.x, Main.WindowBackground.Position.y},
                    Size = {Main.WindowBackground.Size.x, 25}  -- Title bar height
                }, Mouse) and not Main.Dragging then
                    Main.Dragging = true
                    Main.DragOffset = {
                        x = Mouse.x - Main.WindowBackground.Position.x,
                        y = Mouse.y - Main.WindowBackground.Position.y
                    }
                end
                
                -- Update position while dragging
                if Main.Dragging then
                    local NewX = Mouse.x - Main.DragOffset.x
                    local NewY = Mouse.y - Main.DragOffset.y
                    
                    -- Move window
                    Main.WindowBackground.Position = {NewX, NewY}
                    Main.WindowBorder.Position = {NewX, NewY}
                    Main.Title.Position = {NewX + 10, NewY + 5}
                    Main.TabBackground.Position = {NewX + 10, NewY + 25}
                    Main.TabBorder.Position = {NewX + 10, NewY + 25}
                    Main.WindowBackground2.Position = {NewX + 10, NewY + 50}
                    Main.Window2Border.Position = {NewX + 10, NewY + 50}
                    
                    -- Move tab buttons
                    for _, Tab in ipairs(Main.Tabs) do
                        local TabIndex = 0
                        for i, t in ipairs(Main.Tabs) do
                            if t == Tab then
                                TabIndex = i - 1
                                break
                            end
                        end
                        
                        local TabX = Main.TabBackground.Position.x + (TabIndex * 500)
                        Tab.Button.Position = {TabX, Main.TabBackground.Position.y}
                        Tab.ButtonBorder.Position = {TabX, Main.TabBackground.Position.y}
                        Tab.ButtonText.Position = {TabX + (500 / 2), Main.TabBackground.Position.y + (Main.TabBackground.Size.y / 2) - 7}
                    end
                end
            else
                Main.Dragging = false
            end
            
            -- Handle tab clicking
            if isleftclicked() then
                for _, Tab in ipairs(Main.Tabs) do
                    if Main:IsHovered({
                        Position = Tab.Button.Position,
                        Size = Tab.Button.Size
                    }, Mouse) then
                        Main:SelectTab(Tab.Name)
                        wait(0.2) -- Debounce
                    end
                end
            end
        end
    end)
    
    return Main
end

return Library
