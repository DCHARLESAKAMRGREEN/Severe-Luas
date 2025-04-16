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
local Mouse = {X = 0, Y = 0, Clicked = false, Pressed = false}

local Library = {}
local WindowActive = nil
local IsDragging = false
local DragOffsetX = 0
local DragOffsetY = 0
local IsVisible = true
local IsToggled = false
local HoveredButton = nil

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
        elseif Object.Type == "Button" or Object.Type == "Toggle" then
             for _,v in pairs(Object) do
                 if type(v) == "table" and v.Visible ~= nil then
                     SetObjectVisibility(v, Visible)
                 end
             end
             Object.Visible = Visible
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

function Library:Create(TitleText)
    local Main = {}

    local function SetInitialVisibility(Object)
        if Object and Object.Visible ~= nil then
            Object.Visible = IsVisible
        end
    end

    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 745}
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
    Main.TabBackground.Size = {Main.WindowBackground.Size.x - 20, 20}
    Main.TabBackground.Color = Colors["Tab Background"]
    Main.TabBackground.Filled = true
    Main.TabBackground.Thickness = 1
    Main.TabBackground.Transparency = 1
    SetInitialVisibility(Main.TabBackground)

    Main.TabBorder = Drawing.new("Square")
    Main.TabBorder.Position = Main.TabBackground.Position
    Main.TabBorder.Size = Main.TabBackground.Size
    Main.TabBorder.Color = Colors["Tab Border"]
    Main.TabBorder.Filled = false
    Main.TabBorder.Thickness = 1
    Main.TabBorder.Transparency = 1
    SetInitialVisibility(Main.TabBorder)

    Main.WindowBackground2 = Drawing.new("Square")
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 45}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 55}
    Main.WindowBackground2.Color = Colors["Window Background 2"]
    Main.WindowBackground2.Filled = true
    Main.WindowBackground2.Thickness = 1
    Main.WindowBackground2.Transparency = 1
    SetInitialVisibility(Main.WindowBackground2)

    Main.Window2Border = Drawing.new("Square")
    Main.Window2Border.Position = Main.WindowBackground2.Position
    Main.Window2Border.Size = Main.WindowBackground2.Size
    Main.Window2Border.Color = Colors["Window Border"]
    Main.Window2Border.Filled = false
    Main.Window2Border.Thickness = 1
    Main.Window2Border.Transparency = 1
    SetInitialVisibility(Main.Window2Border)

    Main.WindowBorder = Drawing.new("Square")
    Main.WindowBorder.Size = Main.WindowBackground.Size
    Main.WindowBorder.Position = Main.WindowBackground.Position
    Main.WindowBorder.Color = Colors["Accent"]
    Main.WindowBorder.Filled = false
    Main.WindowBorder.Thickness = 1
    Main.WindowBorder.Transparency = 1
    SetInitialVisibility(Main.WindowBorder)

    Main.Tabs = {}
    Main.TabButtons = {}
    Main.TabContents = {}
    Main.ActiveTab = nil

    function Main:IsHovered(Object)
        if not IsVisible or not Object or not Object.Visible then return false end
        local ObjectPos = Object.Position
        if not ObjectPos then return false end

        if Object.Size then
            return Mouse.X >= ObjectPos.x and Mouse.X <= ObjectPos.x + Object.Size.x and 
                   Mouse.Y >= ObjectPos.y and Mouse.Y <= ObjectPos.y + Object.Size.y
        elseif Object.TextBounds then
            local x = Object.Center and ObjectPos.x - Object.TextBounds.x/2 or ObjectPos.x
            local y = ObjectPos.y - Object.TextBounds.y/4
            return Mouse.X >= x and Mouse.X <= x + Object.TextBounds.x and 
                   Mouse.Y >= y and Mouse.Y <= y + Object.TextBounds.y
        end
        return false
    end

    function Main:IsWindowHovered()
        return IsVisible and Main:IsHovered(Main.WindowBackground)
    end

    function Main:UpdateElementPositions()
        Main.Title.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 5}
        Main.TabBackground.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 25}
        Main.TabBorder.Position = Main.TabBackground.Position
        Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 45}
        Main.Window2Border.Position = Main.WindowBackground2.Position
        Main.WindowBorder.Position = Main.WindowBackground.Position
        Main:UpdateLayout()
    end

    function Main:UpdateTabSizes()
        local TabCount = #Main.Tabs
        if TabCount == 0 then return end
        
        local TabWidth = Main.TabBackground.Size.x / TabCount
        for i, TabObj in ipairs(Main.Tabs) do
            local TabX = Main.TabBackground.Position.x + (i-1)*TabWidth
            TabObj.Button.Position = {TabX, Main.TabBackground.Position.y}
            TabObj.Button.Size = {TabWidth, Main.TabBackground.Size.y}
            TabObj.ButtonBorder.Position = TabObj.Button.Position
            TabObj.ButtonBorder.Size = TabObj.Button.Size
            TabObj.SelectedHighlight.Position = TabObj.Button.Position
            TabObj.SelectedHighlight.Size = TabObj.Button.Size
            
            if TabObj.ButtonText.TextBounds then
                TabObj.ButtonText.Position = {TabX + TabWidth/2, Main.TabBackground.Position.y + Main.TabBackground.Size.y/2 - TabObj.ButtonText.TextBounds.y/2}
            else
                TabObj.ButtonText.Position = {TabX + TabWidth/2, Main.TabBackground.Position.y + Main.TabBackground.Size.y/2 - 7}
            end
            TabObj.ButtonText.Center = true
        end
    end

    function Main:UpdateLayout()
        Main:UpdateTabSizes()
        if not Main.ActiveTab or not Main.TabContents[Main.ActiveTab] then return end

        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
        local ColumnWidth = (Main.WindowBackground2.Size.x - 15)/2
        local CurrentLeftY = Main.WindowBackground2.Position.y + 5
        local CurrentRightY = CurrentLeftY

        local function UpdateSectionLayout(SectionObj, ColumnX, StartY)
            SectionObj.Background.Position = {ColumnX, StartY}
            SectionObj.Border.Position = SectionObj.Background.Position
            SectionObj.Title.Position = {ColumnX + 5, StartY + 3}
            
            local CurrentY = StartY + (SectionObj.Title.TextBounds and SectionObj.Title.TextBounds.y or 12) + 10
            
            for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                if InterfaceObj.Type == "Button" then
                    InterfaceObj.ButtonBackground.Position = {ColumnX + 5, CurrentY}
                    InterfaceObj.ButtonBackground.Size = {ColumnWidth - 10, 15}
                    InterfaceObj.ButtonBorder.Position = InterfaceObj.ButtonBackground.Position
                    InterfaceObj.ButtonBorder.Size = InterfaceObj.ButtonBackground.Size
                    InterfaceObj.ButtonText.Position = {
                        ColumnX + 5 + (ColumnWidth - 10)/2, 
                        CurrentY + (15 - (InterfaceObj.ButtonText.TextBounds and InterfaceObj.ButtonText.TextBounds.y or 12))/2
                    }
                    CurrentY = CurrentY + 20
                elseif InterfaceObj.Type == "Toggle" then
                    InterfaceObj.OuterBox.Position = {ColumnX + 5, CurrentY}
                    InterfaceObj.InnerBox.Position = {ColumnX + 7, CurrentY + 2}
                    InterfaceObj.Text.Position = {ColumnX + 30, CurrentY + 3}
                    CurrentY = CurrentY + 20
                end
            end
            
            SectionObj.Background.Size = {ColumnWidth, CurrentY - StartY}
            SectionObj.Border.Size = SectionObj.Background.Size
            return CurrentY + 5
        end

        for _, SectionObj in ipairs(CurrentTabContent.LeftSections) do
            if SectionObj.Visible then
                CurrentLeftY = UpdateSectionLayout(SectionObj, Main.WindowBackground2.Position.x + 5, CurrentLeftY)
            else
                SetInterfaceVisibility({SectionObj}, false)
            end
        end

        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
            if SectionObj.Visible then
                CurrentRightY = UpdateSectionLayout(SectionObj, Main.WindowBackground2.Position.x + ColumnWidth + 10, CurrentRightY)
            else
                SetInterfaceVisibility({SectionObj}, false)
            end
        end
    end

    function Main:Tab(TabName)
        TabName = TabName or "Tab " .. (#Main.Tabs + 1)
        
        local TabObj = {
            Name = TabName,
            Button = Drawing.new("Square"),
            ButtonBorder = Drawing.new("Square"),
            ButtonText = Drawing.new("Text"),
            SelectedHighlight = Drawing.new("Square"),
            Content = {
                Name = TabName,
                LeftSections = {},
                RightSections = {},
                Visible = false
            }
        }
        
        TabObj.Button.Color = Colors["Tab Toggle Background"]
        TabObj.Button.Filled = true
        TabObj.Button.Thickness = 1
        TabObj.Button.Transparency = 1
        SetInitialVisibility(TabObj.Button)
        
        TabObj.ButtonBorder.Color = Colors["Tab Border"]
        TabObj.ButtonBorder.Filled = false
        TabObj.ButtonBorder.Thickness = 1
        TabObj.ButtonBorder.Transparency = 1
        SetInitialVisibility(TabObj.ButtonBorder)
        
        TabObj.ButtonText.Text = TabName
        TabObj.ButtonText.Size = 14
        TabObj.ButtonText.Font = 5
        TabObj.ButtonText.Color = Colors["Text"]
        TabObj.ButtonText.Outline = true
        TabObj.ButtonText.OutlineColor = {0, 0, 0}
        TabObj.ButtonText.Transparency = 1
        TabObj.ButtonText.Center = true
        SetInitialVisibility(TabObj.ButtonText)
        
        TabObj.SelectedHighlight.Color = Colors["Tab Selected Background"]
        TabObj.SelectedHighlight.Transparency = 0.135
        TabObj.SelectedHighlight.Filled = true
        TabObj.SelectedHighlight.Visible = false
        
        function TabObj.Content:Section(SectionName, Options)
            Options = Options or {Side = "Left"}
            SectionName = SectionName or "Section"
            
            local SectionObj = {
                Type = "Section",
                Name = SectionName,
                Side = Options.Side,
                Background = Drawing.new("Square"),
                Border = Drawing.new("Square"),
                Title = Drawing.new("Text"),
                Interfaces = {},
                Visible = false,
                CalculatedHeight = 0
            }
            
            SectionObj.Background.Color = Colors["Section Background"]
            SectionObj.Background.Filled = true
            SectionObj.Background.Thickness = 1
            SectionObj.Background.Transparency = 1
            SectionObj.Background.Visible = false
            
            SectionObj.Border.Color = Colors["Section Border"]
            SectionObj.Border.Filled = false
            SectionObj.Border.Thickness = 1
            SectionObj.Border.Transparency = 1
            SectionObj.Border.Visible = false
            
            SectionObj.Title.Text = SectionName
            SectionObj.Title.Size = 12
            SectionObj.Title.Font = 5
            SectionObj.Title.Color = Colors["Text"]
            SectionObj.Title.Outline = true
            SectionObj.Title.OutlineColor = {0, 0, 0}
            SectionObj.Title.Transparency = 1
            SectionObj.Title.Center = false
            SectionObj.Title.Visible = false
            
            function SectionObj:Button(ButtonName, Callback)
                local ButtonObj = {
                    Type = "Button",
                    Name = ButtonName,
                    Callback = Callback,
                    ButtonBackground = Drawing.new("Square"),
                    ButtonBorder = Drawing.new("Square"),
                    ButtonText = Drawing.new("Text"),
                    DefaultBorderColor = Colors["Object Border"],
                    OriginalBackgroundColor = Colors["Object Background"],
                    OriginalBackgroundTransparency = 1,
                    Visible = self.Visible
                }
                
                ButtonObj.ButtonBackground.Color = Colors["Object Background"]
                ButtonObj.ButtonBackground.Filled = true
                ButtonObj.ButtonBackground.Thickness = 1
                ButtonObj.ButtonBackground.Transparency = 1
                ButtonObj.ButtonBackground.Visible = self.Visible
                
                ButtonObj.ButtonBorder.Color = Colors["Object Border"]
                ButtonObj.ButtonBorder.Filled = false
                ButtonObj.ButtonBorder.Thickness = 1
                ButtonObj.ButtonBorder.Transparency = 1
                ButtonObj.ButtonBorder.Visible = self.Visible
                
                ButtonObj.ButtonText.Text = ButtonName or "Button"
                ButtonObj.ButtonText.Size = 12
                ButtonObj.ButtonText.Font = 5
                ButtonObj.ButtonText.Color = Colors["Text"]
                ButtonObj.ButtonText.Outline = true
                ButtonObj.ButtonText.OutlineColor = {0, 0, 0}
                ButtonObj.ButtonText.Transparency = 1
                ButtonObj.ButtonText.Center = true
                ButtonObj.ButtonText.Visible = self.Visible
                
                table.insert(self.Interfaces, ButtonObj)
                if IsVisible and Main.ActiveTab == TabObj.Content.Name then
                    Main:UpdateLayout()
                end
                return ButtonObj
            end
            
            function SectionObj:Toggle(ToggleName, DefaultState, Callback)
                local ToggleObj = {
                    Type = "Toggle",
                    Name = ToggleName,
                    State = DefaultState or false,
                    Callback = Callback,
                    OuterBox = Drawing.new("Square"),
                    InnerBox = Drawing.new("Square"),
                    Text = Drawing.new("Text"),
                    DefaultBorderColor = Colors["Object Border"],
                    OriginalInnerColor = DefaultState and Colors["Accent"] or Colors["Object Background"],
                    Visible = self.Visible
                }
                
                ToggleObj.OuterBox.Size = {20, 20}
                ToggleObj.OuterBox.Filled = false
                ToggleObj.OuterBox.Thickness = 1
                ToggleObj.OuterBox.Transparency = 1
                ToggleObj.OuterBox.Visible = self.Visible
                ToggleObj.OuterBox.Color = Colors["Object Border"]
                
                ToggleObj.InnerBox.Size = {16, 16}
                ToggleObj.InnerBox.Filled = true
                ToggleObj.InnerBox.Thickness = 1
                ToggleObj.InnerBox.Transparency = 1
                ToggleObj.InnerBox.Visible = self.Visible
                ToggleObj.InnerBox.Color = ToggleObj.OriginalInnerColor
                
                ToggleObj.Text.Text = ToggleName or "Toggle"
                ToggleObj.Text.Size = 12
                ToggleObj.Text.Font = 5
                ToggleObj.Text.Color = Colors["Text"]
                ToggleObj.Text.Outline = true
                ToggleObj.Text.OutlineColor = {0, 0, 0}
                ToggleObj.Text.Transparency = 1
                ToggleObj.Text.Center = false
                ToggleObj.Text.Visible = self.Visible
                
                function ToggleObj:SetState(NewState)
                    self.State = NewState
                    self.InnerBox.Color = NewState and Colors["Accent"] or Colors["Object Background"]
                    self.OriginalInnerColor = self.InnerBox.Color
                    if self.Callback then spawn(function() self.Callback(NewState) end) end
                end
                
                table.insert(self.Interfaces, ToggleObj)
                if IsVisible and Main.ActiveTab == TabObj.Content.Name then
                    Main:UpdateLayout()
                end
                return ToggleObj
            end
            
            if Options.Side == "Left" then
                table.insert(self.LeftSections, SectionObj)
            else
                table.insert(self.RightSections, SectionObj)
            end
            
            if IsVisible and Main.ActiveTab == TabObj.Content.Name then
                SectionObj.Visible = true
                SetObjectVisibility(SectionObj.Background, true)
                SetObjectVisibility(SectionObj.Border, true)
                SetObjectVisibility(SectionObj.Title, true)
                Main:UpdateLayout()
            end
            
            return SectionObj
        end
        
        table.insert(Main.Tabs, TabObj)
        Main.TabButtons[TabName] = TabObj
        Main.TabContents[TabName] = TabObj.Content
        
        Main:UpdateTabSizes()
        if #Main.Tabs == 1 and IsVisible then
            Main:SelectTab(TabName)
        elseif Main.ActiveTab and IsVisible then
            Main:SelectTab(Main.ActiveTab)
        else
            SetInterfaceVisibility({TabObj}, false)
        end
        
        return TabObj.Content
    end

    function Main:SelectTab(TabName)
        if not Main.TabButtons[TabName] then return end
        Main.ActiveTab = TabName
        
        for OtherTabName, OtherTab in pairs(Main.TabButtons) do
            local IsSelected = OtherTabName == TabName
            SetObjectVisibility(OtherTab.SelectedHighlight, IsSelected and IsVisible)
            OtherTab.Content.Visible = IsSelected
            SetInterfaceVisibility(OtherTab.Content.LeftSections, IsSelected and IsVisible)
            SetInterfaceVisibility(OtherTab.Content.RightSections, IsSelected and IsVisible)
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
        local IsHovered = false
        
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
        
        if IsTogglePressed and not IsToggled then
            ToggleUI()
        end
        IsToggled = IsTogglePressed

        if IsVisible and WindowActive then
            if WindowActive:IsWindowHovered() then IsHovered = true end
            
            for _, TabObj in ipairs(WindowActive.Tabs) do
                if TabObj.Button.Visible and WindowActive:IsHovered(TabObj.Button) then
                    IsHovered = true
                    break
                end
            end

            if Mouse.Clicked and IsHovered and Mouse.Y < WindowActive.TabBackground.Position.y + WindowActive.TabBackground.Size.y and not IsDragging then
                IsDragging = true
                DragOffsetX = Mouse.X - WindowActive.WindowBackground.Position.x
                DragOffsetY = Mouse.Y - WindowActive.WindowBackground.Position.y
            elseif Mouse.Pressed and IsDragging then
                IsHovered = true
                WindowActive.WindowBackground.Position = {Mouse.X - DragOffsetX, Mouse.Y - DragOffsetY}
                WindowActive:UpdateElementPositions()
            elseif not Mouse.Pressed and IsDragging then
                IsDragging = false
            end

            if Mouse.Clicked and not IsDragging then
                for _, TabObj in ipairs(WindowActive.Tabs) do
                    if TabObj.Button.Visible and WindowActive:IsHovered(TabObj.Button) then
                        WindowActive:SelectTab(TabObj.Name)
                        break
                    end
                end

                if WindowActive.ActiveTab then
                    local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                    if CurrentTabContent then
                        local function CheckButtonClick(Sections)
                            for _, SectionObj in ipairs(Sections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                                        if InterfaceObj.Type == "Button" and InterfaceObj.ButtonBackground.Visible and WindowActive:IsHovered(InterfaceObj.ButtonBackground) then
                                            InterfaceObj.ButtonBackground.Color = Colors["Tab Selected Background"]
                                            InterfaceObj.ButtonBackground.Transparency = 0.135
                                            InterfaceObj.ButtonBorder.Color = Colors["Accent"]
                                            
                                            local TargetButtonObj = InterfaceObj
                                            spawn(function()
                                                wait(0.05)
                                                if IsVisible and WindowActive and TargetButtonObj and TargetButtonObj.ButtonBackground.Visible then
                                                    TargetButtonObj.ButtonBackground.Color = TargetButtonObj.OriginalBackgroundColor
                                                    TargetButtonObj.ButtonBackground.Transparency = TargetButtonObj.OriginalBackgroundTransparency
                                                    TargetButtonObj.ButtonBorder.Color = WindowActive:IsHovered(TargetButtonObj.ButtonBackground) and Colors["Accent"] or TargetButtonObj.DefaultBorderColor
                                                end
                                            end)
                                            
                                            if InterfaceObj.Callback then spawn(InterfaceObj.Callback) end
                                            return
                                        elseif InterfaceObj.Type == "Toggle" and InterfaceObj.OuterBox.Visible and WindowActive:IsHovered(InterfaceObj.OuterBox) then
                                            InterfaceObj:SetState(not InterfaceObj.State)
                                            return
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

            if WindowActive.ActiveTab then
                local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                if CurrentTabContent then
                    local function UpdateButtonVisuals(Sections)
                        for _, SectionObj in ipairs(Sections) do
                            if SectionObj.Visible and SectionObj.Interfaces then
                                for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                                    if InterfaceObj.Type == "Button" then
                                        InterfaceObj.ButtonBorder.Color = WindowActive:IsHovered(InterfaceObj.ButtonBackground) and Colors["Accent"] or InterfaceObj.DefaultBorderColor
                                    elseif InterfaceObj.Type == "Toggle" then
                                        InterfaceObj.OuterBox.Color = WindowActive:IsHovered(InterfaceObj.OuterBox) and Colors["Accent"] or InterfaceObj.DefaultBorderColor
                                    end
                                end
                            end
                        end
                    end
                    UpdateButtonVisuals(CurrentTabContent.LeftSections)
                    UpdateButtonVisuals(CurrentTabContent.RightSections)
                end
            end
        end
        wait()
    end
end)

print("Severe UI Library Loaded")
return Library
