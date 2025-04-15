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
local TogglePressed = false
local HoveredButton = nil

local function SetElementVisibility(Element, Visible)
    if Element and Element.Visible ~= nil then Element.Visible = Visible end
end

local function SetVisibilityRecursive(InterfaceCollection, Visible)
    for _, Interface in pairs(InterfaceCollection) do
        if Interface.Type == "Section" then
            SetElementVisibility(Interface.Background, Visible)
            SetElementVisibility(Interface.Border, Visible)
            SetElementVisibility(Interface.Title, Visible)
            Interface.Visible = Visible
            if Interface.Interfaces then SetVisibilityRecursive(Interface.Interfaces, Visible) end
        elseif Interface.Type == "Button" or Interface.Type == "Toggle" then
            for _,v in pairs(Interface) do if type(v) == "table" and v.Visible ~= nil then SetElementVisibility(v, Visible) end end
            Interface.Visible = Visible
        else
            if Interface.Visible ~= nil then Interface.Visible = Visible end
            if Interface.Interfaces then SetVisibilityRecursive(Interface.Interfaces, Visible) end
            if Interface.Background and Interface.Background.Visible ~= nil then Interface.Background.Visible = Visible end
            if Interface.Border and Interface.Border.Visible ~= nil then Interface.Border.Visible = Visible end
            if Interface.Title and Interface.Title.Visible ~= nil then Interface.Title.Visible = Visible end
            if Interface.SelectedHighlight and Interface.SelectedHighlight.Visible ~= nil then Interface.SelectedHighlight.Visible = false end
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
        if Interface and Interface.Visible ~= nil then Interface.Visible = IsVisible end
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

    function Main:IsHovered(Interface)
        if not IsVisible or not Interface or not Interface.Visible then return false end
        local MouseX, MouseY = Mouse.X, Mouse.Y
        local InterfacePos = Interface.Position
        if not InterfacePos then return false end
        local InterfaceX, InterfaceY = InterfacePos.x, InterfacePos.y

        if Interface.Size then
            local InterfaceSize = Interface.Size
            return MouseX >= InterfaceX and MouseX <= InterfaceX + InterfaceSize.x and MouseY >= InterfaceY and MouseY <= InterfaceY + InterfaceSize.y
        elseif Interface.TextBounds then
            local InterfaceBounds = Interface.TextBounds
            local InterfaceW, InterfaceH = InterfaceBounds.x, InterfaceBounds.y
            if Interface.Center then InterfaceX = InterfaceX - InterfaceW / 2 end
            InterfaceY = InterfaceY - InterfaceH / 4
            return MouseX >= InterfaceX and MouseX <= InterfaceX + InterfaceW and MouseY >= InterfaceY and MouseY <= InterfaceY + InterfaceH
        end
        return false
    end

    function Main:IsHoveringWindow()
        return IsVisible and Main:IsHovered(Main.WindowBackground)
    end

    function Main:UpdateElementPositions()
        local BasePos = Main.WindowBackground.Position
        Main.Title.Position = {BasePos.x + 10, BasePos.y + 5}
        Main.TabBackground.Position = {BasePos.x + 10, BasePos.y + 25}
        Main.TabBorder.Position = Main.TabBackground.Position
        Main.WindowBackground2.Position = {BasePos.x + 10, BasePos.y + 45}
        Main.Window2Border.Position = Main.WindowBackground2.Position
        Main.WindowBorder.Position = BasePos
        Main:UpdateLayout()
    end

    function Main:UpdateTabSizes()
        local TabCount = #Main.Tabs
        if TabCount == 0 then return end
        local TabBackgroundPos = Main.TabBackground.Position
        local TotalWidth = Main.TabBackground.Size.x
        local ExactTabWidth = TotalWidth / TabCount
        
        for i, TabObj in ipairs(Main.Tabs) do
            local StartX = TabBackgroundPos.x + (i - 1) * ExactTabWidth
            local RoundedWidth = math.floor(StartX + ExactTabWidth + 0.0001) - math.floor(StartX + 0.0001)
            if RoundedWidth <= 0 then RoundedWidth = 1 end
            
            TabObj.Button.Position = {StartX, TabBackgroundPos.y}
            TabObj.Button.Size = {RoundedWidth, Main.TabBackground.Size.y}
            TabObj.ButtonBorder.Position = TabObj.Button.Position
            TabObj.ButtonBorder.Size = TabObj.Button.Size
            TabObj.SelectedHighlight.Position = TabObj.Button.Position
            TabObj.SelectedHighlight.Size = TabObj.Button.Size
            
            if TabObj.ButtonText.TextBounds then
                TabObj.ButtonText.Position = {StartX + RoundedWidth/2, TabBackgroundPos.y + Main.TabBackground.Size.y/2 - TabObj.ButtonText.TextBounds.y/2}
            else
                TabObj.ButtonText.Position = {StartX + RoundedWidth/2, TabBackgroundPos.y + Main.TabBackground.Size.y/2 - 6}
            end
            TabObj.ButtonText.Center = true
        end
    end

    function Main:UpdateLayout()
        Main:UpdateTabSizes()
        if not Main.ActiveTab or not Main.TabContents[Main.ActiveTab] then return end
        
        local CurrentTabContent = Main.TabContents[Main.ActiveTab]
        local ParentPos = Main.WindowBackground2.Position
        local ColumnWidth = math.floor((Main.WindowBackground2.Size.x - 15) / 2)
        local CurrentLeftY = ParentPos.y + 5
        local CurrentRightY = ParentPos.y + 5

        local function UpdateSectionLayout(SectionObj, ColumnX, StartY, Width)
            SectionObj.Background.Position = {ColumnX, StartY}
            SectionObj.Border.Position = SectionObj.Background.Position
            SectionObj.Title.Position = {ColumnX + 5, StartY + 3}
            
            local CurrentInternalY = StartY + (SectionObj.Title.TextBounds and SectionObj.Title.TextBounds.y or 12) + 10
            
            for _, InterfaceObj in ipairs(SectionObj.Interfaces) do
                if InterfaceObj.Type == "Button" then
                    InterfaceObj.ButtonBackground.Position = {ColumnX + 5, CurrentInternalY}
                    InterfaceObj.ButtonBackground.Size = {Width - 10, 16}
                    InterfaceObj.ButtonBorder.Position = InterfaceObj.ButtonBackground.Position
                    InterfaceObj.ButtonBorder.Size = InterfaceObj.ButtonBackground.Size
                    InterfaceObj.ButtonText.Position = {ColumnX + 5 + (Width - 10)/2, CurrentInternalY + (InterfaceObj.ButtonText.TextBounds and (16 - InterfaceObj.ButtonText.TextBounds.y)/2 or 1)}
                    CurrentInternalY = CurrentInternalY + 16 + 5
                elseif InterfaceObj.Type == "Toggle" then
                    InterfaceObj.OuterBox.Position = {ColumnX + 5, CurrentInternalY}
                    InterfaceObj.InnerBox.Position = {ColumnX + 7, CurrentInternalY + 2}
                    InterfaceObj.Text.Position = {ColumnX + 30, CurrentInternalY + 3}
                    CurrentInternalY = CurrentInternalY + 20 + 5
                end
            end
            
            local TotalSectionHeight = CurrentInternalY - StartY
            SectionObj.Background.Size = {Width, TotalSectionHeight}
            SectionObj.Border.Size = SectionObj.Background.Size
            return CurrentInternalY + 5
        end

        for _, SectionObj in ipairs(CurrentTabContent.LeftSections) do
            if SectionObj.Visible then
                CurrentLeftY = UpdateSectionLayout(SectionObj, ParentPos.x + 5, CurrentLeftY, ColumnWidth)
            else
                SetVisibilityRecursive({SectionObj}, false)
            end
        end

        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
            if SectionObj.Visible then
                CurrentRightY = UpdateSectionLayout(SectionObj, ParentPos.x + ColumnWidth + 10, CurrentRightY, ColumnWidth)
            else
                SetVisibilityRecursive({SectionObj}, false)
            end
        end
    end

    function Main:Tab(TabName)
        TabName = TabName or "Tab " .. (#Main.Tabs + 1)
        
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
        TabButtonText.Size = 12
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
            Visible = false
        }

        function TabContent:Section(SectionName, Options)
            Options = Options or {}
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
                Side = Options.Side or "Left",
                Background = SectionBackground,
                Border = SectionBorder,
                Title = SectionTitle,
                Interfaces = {},
                Visible = false,
                CalculatedHeight = 0
            }

            function SectionObj:Button(ButtonName, Callback)
                local ButtonBackground = Drawing.new("Square")
                ButtonBackground.Color = Colors["Object Background"]
                ButtonBackground.Filled = true
                ButtonBackground.Thickness = 1
                ButtonBackground.Transparency = 1
                ButtonBackground.Visible = self.Visible
                
                local ButtonBorder = Drawing.new("Square")
                ButtonBorder.Color = Colors["Object Border"]
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
                    DefaultBorderColor = Colors["Object Border"],
                    OriginalBackgroundColor = Colors["Object Background"],
                    OriginalBackgroundTransparency = 1,
                    Visible = self.Visible
                }
                
                table.insert(self.Interfaces, ButtonObj)
                if IsVisible and Main.ActiveTab == TabContent.Name then Main:UpdateLayout() end
                return ButtonObj
            end

            function SectionObj:Toggle(ToggleName, DefaultState, Callback)
                local ToggleOuterBox = Drawing.new("Square")
                ToggleOuterBox.Size = {20, 20}
                ToggleOuterBox.Filled = false
                ToggleOuterBox.Thickness = 1
                ToggleOuterBox.Transparency = 1
                ToggleOuterBox.Visible = self.Visible
                ToggleOuterBox.Color = Colors["Object Border"]
                
                local ToggleInnerBox = Drawing.new("Square")
                ToggleInnerBox.Size = {16, 16}
                ToggleInnerBox.Filled = true
                ToggleInnerBox.Thickness = 1
                ToggleInnerBox.Transparency = 1
                ToggleInnerBox.Visible = self.Visible
                ToggleInnerBox.Color = DefaultState and Colors["Accent"] or Colors["Object Background"]
                
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
                
                local ToggleObj = {
                    Type = "Toggle",
                    Name = ToggleName,
                    State = DefaultState or false,
                    Callback = Callback,
                    OuterBox = ToggleOuterBox,
                    InnerBox = ToggleInnerBox,
                    Text = ToggleText,
                    DefaultBorderColor = Colors["Object Border"],
                    OriginalInnerColor = DefaultState and Colors["Accent"] or Colors["Object Background"],
                    Visible = self.Visible
                }

                function ToggleObj:SetState(NewState)
                    self.State = NewState
                    self.InnerBox.Color = NewState and Colors["Accent"] or Colors["Object Background"]
                    self.OriginalInnerColor = self.InnerBox.Color
                    if self.Callback then spawn(function() self.Callback(NewState) end) end
                end

                table.insert(self.Interfaces, ToggleObj)
                if IsVisible and Main.ActiveTab == TabContent.Name then Main:UpdateLayout() end
                return ToggleObj
            end

            if SectionObj.Side == "Left" then
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
        if not IsVisible then return end
        
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
        
        local Keys = getpressedkeys()
        local IsToggleKeyPressed = false
        for _, k in ipairs(Keys) do
            if k == 'P' then
                IsToggleKeyPressed = true
                break
            end
        end
        
        if IsToggleKeyPressed and not TogglePressed then
            ToggleUI()
        end
        TogglePressed = IsToggleKeyPressed

        if IsVisible and WindowActive then
            local IsMouseOverUI = WindowActive:IsHoveringWindow()
            
            for _, TabObj in ipairs(WindowActive.Tabs) do
                if TabObj.Button.Visible and WindowActive:IsHovered(TabObj.Button) then
                    IsMouseOverUI = true
                    break
                end
            end

            local WindowPos = WindowActive.WindowBackground.Position
            if Mouse.Clicked and IsMouseOverUI and Mouse.Y < WindowActive.TabBackground.Position.y and not IsDragging then
                IsDragging = true
                DragOffsetX = Mouse.X - WindowPos.x
                DragOffsetY = Mouse.Y - WindowPos.y
            elseif Mouse.Pressed and IsDragging then
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

print("Library Loaded")
return Library
