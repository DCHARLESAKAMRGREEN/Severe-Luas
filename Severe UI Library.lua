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
    Y = 0
}

spawn(function()
    while true do
        local MouseLocation = getmouselocation(MouseService)
        Mouse.X = MouseLocation.x
        Mouse.Y = MouseLocation.y
        wait()
    end
end)

local Library = {}

function Library:Create(Title)
    local Main = {}
    
    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 750}
    Main.WindowBackground.Position = {350, 100}
    Main.WindowBackground.Color = Colors["Window Background"]
    Main.WindowBackground.Filled = true
    Main.WindowBackground.Thickness = 1
    Main.WindowBackground.Transparency = 1
    Main.WindowBackground.Visible = true

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

    Main.TabBackground = Drawing.new("Square")
    Main.TabBackground.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 25}
    Main.TabBackground.Size = {Main.WindowBackground.Size.x - 20, 25}
    Main.TabBackground.Color = Colors["Tab Background"]
    Main.TabBackground.Filled = true
    Main.TabBackground.Thickness = 1
    Main.TabBackground.Transparency = 1
    Main.TabBackground.Visible = true

    Main.TabBorder = Drawing.new("Square")
    Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
    Main.TabBorder.Size = {Main.TabBackground.Size.x, Main.TabBackground.Size.y}
    Main.TabBorder.Color = Colors["Tab Border"]
    Main.TabBorder.Filled = false
    Main.TabBorder.Thickness = 1
    Main.TabBorder.Transparency = 1
    Main.TabBorder.Visible = true

    Main.WindowBackground2 = Drawing.new("Square")
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 50}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 60}
    Main.WindowBackground2.Color = Colors["Section Background"]
    Main.WindowBackground2.Filled = true
    Main.WindowBackground2.Thickness = 1
    Main.WindowBackground2.Transparency = 1
    Main.WindowBackground2.Visible = true

    Main.Window2Border = Drawing.new("Square")
    Main.Window2Border.Position = {Main.WindowBackground2.Position.x, Main.WindowBackground2.Position.y}
    Main.Window2Border.Size = {Main.WindowBackground2.Size.x, Main.WindowBackground2.Size.y}
    Main.Window2Border.Color = Colors["Section Border"]
    Main.Window2Border.Filled = false
    Main.Window2Border.Thickness = 1
    Main.Window2Border.Transparency = 1
    Main.Window2Border.Visible = true

    Main.WindowBorder = Drawing.new("Square")
    Main.WindowBorder.Size = {Main.WindowBackground.Size.x, Main.WindowBackground.Size.y}
    Main.WindowBorder.Position = {Main.WindowBackground.Position.x, Main.WindowBackground.Position.y}
    Main.WindowBorder.Color = Colors["Window Border"]
    Main.WindowBorder.Filled = false
    Main.WindowBorder.Thickness = 1
    Main.WindowBorder.Transparency = 1
    Main.WindowBorder.Visible = true

    Main.Tabs = {}
    Main.TabButtons = {}
    Main.TabContents = {}
    Main.ActiveTab = nil
    Main.TabWidth = 500

    function Main:IsHovered()
        local MouseX, MouseY = Mouse.X, Mouse.Y
        local WindowX, WindowY = Main.WindowBackground.Position.x, Main.WindowBackground.Position.y
        local WindowW, WindowH = Main.WindowBackground.Size.x, Main.WindowBackground.Size.y
        
        if MouseX >= WindowX and MouseX <= WindowX + WindowW and MouseY >= WindowY and MouseY <= WindowY + WindowH then
            print("Hovered")
            return true
        end
        return false
    end

    function Main:Tab(TabName)
        if not TabName then
            TabName = "Tab " .. (#Main.Tabs + 1)
        end
        
        local TabCount = #Main.Tabs
        local TabX = Main.TabBackground.Position.x + (TabCount * Main.TabWidth)
        
        local TabButton = Drawing.new("Square")
        TabButton.Size = {Main.TabWidth, Main.TabBackground.Size.y}
        TabButton.Position = {TabX, Main.TabBackground.Position.y}
        TabButton.Color = Colors["Tab Toggle Background"]
        TabButton.Filled = true
        TabButton.Thickness = 1
        TabButton.Transparency = 1
        TabButton.Visible = true
        
        local TabButtonBorder = Drawing.new("Square")
        TabButtonBorder.Size = {Main.TabWidth, Main.TabBackground.Size.y}
        TabButtonBorder.Position = {TabX, Main.TabBackground.Position.y}
        TabButtonBorder.Color = Colors["Tab Border"]
        TabButtonBorder.Filled = false
        TabButtonBorder.Thickness = 1
        TabButtonBorder.Transparency = 1
        TabButtonBorder.Visible = true
        
        local TabButtonText = Drawing.new("Text")
        TabButtonText.Text = TabName
        TabButtonText.Size = 14
        TabButtonText.Font = 5
        TabButtonText.Color = Colors["Text"]
        TabButtonText.Outline = true
        TabButtonText.OutlineColor = {0, 0, 0}
        TabButtonText.Position = {TabX + (Main.TabWidth / 2), Main.TabBackground.Position.y + (Main.TabBackground.Size.y / 2) - 7}
        TabButtonText.Transparency = 1
        TabButtonText.Visible = true
        TabButtonText.Center = true
        
        local TabContent = {
            Name = TabName,
            Elements = {},
            Visible = false
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
        
        if #Main.Tabs == 1 then
            Main:SelectTab(TabName)
        end
        
        return TabContent
    end

    function Main:SelectTab(TabName)
        for _, Tab in ipairs(Main.Tabs) do
            Tab.Button.Color = Colors["Tab Toggle Background"]
            Tab.Content.Visible = false
            
            for _, Element in pairs(Tab.Content.Elements) do
                if Element.Visible ~= nil then
                    Element.Visible = false
                end
            end
        end
        
        local SelectedTab = Main.TabButtons[TabName]
        if SelectedTab then
            SelectedTab.Button.Color = Colors["Accent"]
            SelectedTab.Content.Visible = true
            Main.ActiveTab = TabName
            
            for _, Element in pairs(SelectedTab.Content.Elements) do
                if Element.Visible ~= nil then
                    Element.Visible = true
                end
            end
        end
    end
    
    return Main
end

return Library
