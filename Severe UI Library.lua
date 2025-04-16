local Colors = {
    ["Accent"] = {67, 12, 122},
    ["Window Background"] = {40, 40, 40},
    ["Window Background 2"] = {30, 30, 30},
    ["Window Border"] = {45, 45, 45},
    ["Tab Background"] = {20, 20, 20},
    ["Tab Border"] = {45, 45, 45},
    ["Tab Toggle Background"] = {28, 28, 28},
    ["Selected"] = {255, 255, 255},
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
local IsToggleKeyPressed = false
local HoveredElement = nil
local Running = true

function Library:Unload()
    Running = false
    if WindowActive then
        local function RemoveDrawingObjectsRecursive(TargetTable)
            for _, Value in pairs(TargetTable) do
                if type(Value) == "table" then
                    if Value.Remove then
                        Value:Remove()
                    else
                        RemoveDrawingObjectsRecursive(Value)
                    end
                end
                 if type(Value) == "table" and Value.Slider then
                     RemoveDrawingObjectsRecursive(Value.Slider)
                 end
            end
        end
        RemoveDrawingObjectsRecursive(WindowActive)
        WindowActive = nil
    end
    Library = nil
end

local function SetElementVisibility(Element, Visible)
    if Element and Element.Visible ~= nil then
        Element.Visible = Visible
    end
     if Element and Element.Slider then
         for _, SliderPart in pairs(Element.Slider) do
             if type(SliderPart) == "table" and SliderPart.Visible ~= nil then
                 SetElementVisibility(SliderPart, Visible)
             end
         end
         if Element.Slider.Visible ~= nil then Element.Slider.Visible = Visible end
     end
end

local function SetSectionContentVisibility(ElementsTable, Visible)
     for _, Element in pairs(ElementsTable) do
         if Element.Type == "Section" then
             SetElementVisibility(Element.Background, Visible)
             SetElementVisibility(Element.Border, Visible)
             SetElementVisibility(Element.Title, Visible)
             Element.Visible = Visible
             if Element.Interfaces then
                 SetSectionContentVisibility(Element.Interfaces, Visible)
             end
         elseif Element.Type == "Button" or Element.Type == "Toggle" or Element.Type == "Slider" then
             for _, Part in pairs(Element) do
                 if type(Part) == "table" and Part.Visible ~= nil then
                    SetElementVisibility(Part, Visible)
                 end
             end
             Element.Visible = Visible
              if Element.Type == "Toggle" and Element.Slider then
                 SetElementVisibility(Element.Slider, Visible and Element.State)
              end
         else
             if Element.Visible ~= nil then
                 Element.Visible = Visible
             end
             if Element.Interfaces then
                 SetSectionContentVisibility(Element.Interfaces, Visible)
             end
             if Element.Background and Element.Background.Visible ~= nil then
                 Element.Background.Visible = Visible
             end
             if Element.Border and Element.Border.Visible ~= nil then
                 Element.Border.Visible = Visible
             end
             if Element.Title and Element.Title.Visible ~= nil then
                 Element.Title.Visible = Visible
             end
             if Element.SelectedHighlight and Element.SelectedHighlight.Visible ~= nil then
                 Element.SelectedHighlight.Visible = false
             end
         end
     end
end


local function ToggleUI()
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
            SetSectionContentVisibility(TabObj.Content.LeftSections, IsVisible and IsActiveTab)
            SetSectionContentVisibility(TabObj.Content.RightSections, IsVisible and IsActiveTab)
        end
        if not IsVisible then
            IsDragging = false
            HoveredElement = nil
        else
             if Main.ActiveTab then
                Main:SelectTab(Main.ActiveTab)
             end
            Main:UpdateLayout()
        end
    end
end

function Library:Create(Options)
    local Main = {}
    local TitleText = Options.Name or "Severe UI"

    local function SetInitialVisibility(Object)
        if Object and Object.Visible ~= nil then
            Object.Visible = IsVisible
        end
    end

    Main.WindowBackground = Drawing.new("Square")
    Main.WindowBackground.Size = {650, 700}
    Main.WindowBackground.Position = {350, 100}
    Main.WindowBackground.Color = Colors["Window Background"]
    Main.WindowBackground.Filled = true
    Main.WindowBackground.Thickness = 1
    Main.WindowBackground.Transparency = 1
    SetInitialVisibility(Main.WindowBackground)

    Main.Title = Drawing.new("Text")
    Main.Title.Text = TitleText
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
    Main.TabBackground.Size = {Main.WindowBackground.Size.x - 20, 23}
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
    Main.WindowBackground2.Position = {Main.WindowBackground.Position.x + 10, Main.WindowBackground.Position.y + 48}
    Main.WindowBackground2.Size = {Main.WindowBackground.Size.x - 20, Main.WindowBackground.Size.y - 68}
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

    function Main:IsObjectHovered(Object)
        if not IsVisible or not Object or not Object.Visible then return false end
        local MouseX, MouseY = Mouse.X, Mouse.Y
        local ObjectPos = Object.Position
        if not ObjectPos then return false end
        local ObjectX, ObjectY = ObjectPos.x, ObjectPos.y

        if Object.Size then
            local ObjectSize = Object.Size
            local ObjectW, ObjectH = ObjectSize.x, ObjectSize.y
            return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and MouseY <= ObjectY + ObjectH
        elseif Object.TextBounds then
             local ObjectBounds = Object.TextBounds
             local ObjectW, ObjectH = ObjectBounds.x, ObjectBounds.y
             if Object.Center then
                 ObjectX = ObjectX - ObjectW / 2
             end
             ObjectY = ObjectY - ObjectH / 4
             return MouseX >= ObjectX and MouseX <= ObjectX + ObjectW and MouseY >= ObjectY and MouseY <= ObjectY + ObjectH
        end
        return false
    end

    function Main:IsWindowHovered()
        if not IsVisible then return false end
        return Main:IsObjectHovered(Main.WindowBackground)
    end

    function Main:UpdateElementPositions()
        local BasePos = Main.WindowBackground.Position
        local BaseX, BaseY = BasePos.x, BasePos.y
        Main.Title.Position = {BaseX + 10, BaseY + 5}
        Main.TabBackground.Position = {BaseX + 10, BaseY + 25}
        Main.TabBorder.Position = {Main.TabBackground.Position.x, Main.TabBackground.Position.y}
        Main.WindowBackground2.Position = {BaseX + 10, BaseY + 48}
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
            ButtonText.Position = {RoundedStartX + (RoundedWidth / 2), TabY + (TabH / 2) - 7}
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
            local TitleHeight = SectionObj.Title.TextBounds and SectionObj.Title.TextBounds.y or 12
            SectionObj.Title.Position = {ColumnX + Padding, StartY + 3}
            local CurrentInternalY = StartY + TitleHeight + Padding * 2

            if SectionObj.Interfaces then
                for _, Object in ipairs(SectionObj.Interfaces) do
                    if Object.Type == "Button" then
                         local ButtonHeight = 18
                         local ButtonWidth = Width - (Padding * 2)
                         local ButtonX = ColumnX + Padding
                         local ButtonY = CurrentInternalY
                         SetElementVisibility(Object.ButtonBackground, true)
                         SetElementVisibility(Object.ButtonBorder, true)
                         SetElementVisibility(Object.ButtonText, true)
                         Object.ButtonBackground.Position = {ButtonX, ButtonY}
                         Object.ButtonBackground.Size = {ButtonWidth, ButtonHeight}
                         Object.ButtonBorder.Position = {ButtonX, ButtonY}
                         Object.ButtonBorder.Size = {ButtonWidth, ButtonHeight}
                         Object.ButtonText.Position = {ButtonX + math.floor(ButtonWidth / 2), ButtonY + 3}
                         Object.ButtonText.Center = true
                         Object.ButtonText.Size = 12
                         CurrentInternalY = CurrentInternalY + ButtonHeight + Padding
                    elseif Object.Type == "Toggle" then
                         local ToggleHeight = 18
                         local ToggleWidth = 18
                         local TextWidth = Width - ToggleWidth - (Padding * 3)
                         local ToggleX = ColumnX + Padding
                         local ToggleY = CurrentInternalY
                         SetElementVisibility(Object.OuterBox, true)
                         SetElementVisibility(Object.InnerBox, true)
                         SetElementVisibility(Object.Text, true)
                         Object.OuterBox.Position = {ToggleX, ToggleY}
                         Object.OuterBox.Size = {ToggleWidth, ToggleHeight}
                         Object.InnerBox.Position = {ToggleX + 2, ToggleY + 2}
                         Object.InnerBox.Size = {14, 14}
                         Object.Text.Position = {ToggleX + ToggleWidth + Padding, ToggleY + 4}
                         Object.Text.Center = false
                         Object.Text.Size = 12
                         CurrentInternalY = CurrentInternalY + ToggleHeight + Padding

                         if Object.Slider then
                            SetElementVisibility(Object.Slider, Object.State)
                             if Object.State then
                                 local SliderHeight = 18
                                 local SliderWidth = Width - (Padding * 2)
                                 local SliderX = ColumnX + Padding
                                 local SliderY = CurrentInternalY
                                 local SliderObj = Object.Slider
                                 SetElementVisibility(SliderObj.Background, true)
                                 SetElementVisibility(SliderObj.Border, true)
                                 SetElementVisibility(SliderObj.Fill, true)
                                 SetElementVisibility(SliderObj.Text, true)
                                 SetElementVisibility(SliderObj.ValueText, true)
                                 SliderObj.Background.Position = {SliderX, SliderY}
                                 SliderObj.Background.Size = {SliderWidth, SliderHeight}
                                 SliderObj.Border.Position = {SliderX, SliderY}
                                 SliderObj.Border.Size = {SliderWidth, SliderHeight}
                                 SliderObj.Fill.Position = {SliderX, SliderY}
                                 local FillWidth = ((SliderObj.Value - SliderObj.Min) / (SliderObj.Max - SliderObj.Min)) * SliderWidth
                                 FillWidth = math.max(0, FillWidth)
                                 SliderObj.Fill.Size = {FillWidth, SliderHeight}
                                 SliderObj.Text.Position = {SliderX, SliderY - 15}
                                 SliderObj.ValueText.Position = {SliderX + SliderWidth / 2, SliderY + SliderHeight / 2 - 7}
                                 SliderObj.ValueText.Center = true
                                 CurrentInternalY = CurrentInternalY + SliderHeight + Padding + 15
                             end
                         end
                     elseif Object.Type == "Slider" and not Object.ParentToggle then
                        local SliderHeight = 18
                        local SliderWidth = Width - (Padding * 2)
                        local SliderX = ColumnX + Padding
                        local SliderY = CurrentInternalY + 15
                        SetElementVisibility(Object.Background, true)
                        SetElementVisibility(Object.Border, true)
                        SetElementVisibility(Object.Fill, true)
                        SetElementVisibility(Object.Text, true)
                        SetElementVisibility(Object.ValueText, true)
                        Object.Background.Position = {SliderX, SliderY}
                        Object.Background.Size = {SliderWidth, SliderHeight}
                        Object.Border.Position = {SliderX, SliderY}
                        Object.Border.Size = {SliderWidth, SliderHeight}
                        Object.Fill.Position = {SliderX, SliderY}
                        local FillWidth = ((Object.Value - Object.Min) / (Object.Max - Object.Min)) * SliderWidth
                        FillWidth = math.max(0, FillWidth)
                        Object.Fill.Size = {FillWidth, SliderHeight}
                        Object.Text.Position = {SliderX, SliderY - 15}
                        Object.ValueText.Position = {SliderX + SliderWidth / 2, SliderY + SliderHeight / 2 - 7}
                        Object.ValueText.Center = true
                        CurrentInternalY = CurrentInternalY + SliderHeight + Padding + 15
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
                if SectionObj.Interfaces then SetSectionContentVisibility(SectionObj.Interfaces, false) end
            end
        end

        for _, SectionObj in ipairs(CurrentTabContent.RightSections) do
            if SectionObj.Visible then
                CurrentRightY = UpdateSectionLayout(SectionObj, RightColumnX, CurrentRightY, ColumnWidth)
            else
                SetElementVisibility(SectionObj.Background, false)
                SetElementVisibility(SectionObj.Border, false)
                SetElementVisibility(SectionObj.Title, false)
                if SectionObj.Interfaces then SetSectionContentVisibility(SectionObj.Interfaces, false) end
            end
        end
    end

    function Main:Tab(Options)
        local TabName = Options.Name or "Tab " .. (#Main.Tabs + 1)
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
        SelectedHighlight.Color = Colors["Selected"]
        SelectedHighlight.Transparency = 0.135
        SelectedHighlight.Filled = true
        SelectedHighlight.Visible = false
        local TabContent = {
            Name = TabName,
            LeftSections = {},
            RightSections = {},
            Visible = false
        }

        function TabContent:Section(Options)
            local SectionName = Options.Name or "Section"
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

            function SectionObj:Button(Options)
                local ButtonName = Options.Name or "Button"
                local Callback = Options.Callback or function() end
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
                ButtonText.Text = ButtonName
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
                if IsVisible and Main.ActiveTab == TabContent.Name then
                    Main:UpdateLayout()
                end
                return ButtonObj
            end

            function SectionObj:Toggle(Options)
                 local ToggleName = Options.Name or "Toggle"
                 local DefaultState = Options.Default or false
                 local Callback = Options.Callback or function() end
                 local ToggleOuterBox = Drawing.new("Square")
                 ToggleOuterBox.Size = {18, 18}
                 ToggleOuterBox.Filled = false
                 ToggleOuterBox.Thickness = 1
                 ToggleOuterBox.Transparency = 1
                 ToggleOuterBox.Visible = self.Visible
                 ToggleOuterBox.Color = Colors["Object Border"]
                 local ToggleInnerBox = Drawing.new("Square")
                 ToggleInnerBox.Size = {14, 14}
                 ToggleInnerBox.Filled = true
                 ToggleInnerBox.Thickness = 1
                 ToggleInnerBox.Transparency = 1
                 ToggleInnerBox.Visible = self.Visible
                 ToggleInnerBox.Color = DefaultState and Colors["Accent"] or Colors["Object Background"]
                 local ToggleText = Drawing.new("Text")
                 ToggleText.Text = ToggleName
                 ToggleText.Size = 12
                 ToggleText.Font = 5
                 ToggleText.Color = Colors["Text"]
                 ToggleText.Outline = true
                 ToggleText.OutlineColor = {0, 0, 0}
                 ToggleText.Transparency = 1
                 ToggleText.Center = false
                 ToggleText.Visible = self.Visible
                 local ToggleState = DefaultState
                 local ToggleObj = {
                     Type = "Toggle",
                     Name = ToggleName,
                     State = ToggleState,
                     Callback = Callback,
                     OuterBox = ToggleOuterBox,
                     InnerBox = ToggleInnerBox,
                     Text = ToggleText,
                     DefaultBorderColor = Colors["Object Border"],
                     OriginalInnerColor = ToggleState and Colors["Accent"] or Colors["Object Background"],
                     Visible = self.Visible,
                     Slider = nil
                 }

                 function ToggleObj:SetState(NewState)
                     self.State = NewState
                     self.InnerBox.Color = NewState and Colors["Accent"] or Colors["Object Background"]
                     self.OriginalInnerColor = self.InnerBox.Color
                      if self.Slider then
                          SetElementVisibility(self.Slider, NewState)
                          if WindowActive and WindowActive.ActiveTab == TabContent.Name then
                              WindowActive:UpdateLayout()
                          end
                      end
                     if self.Callback then
                         spawn(function() self.Callback(NewState) end)
                     end
                 end

                 function ToggleObj:Slider(Options)
                     local SliderName = Options.Name or "Slider"
                     local Min = Options.Min or 0
                     local Max = Options.Max or 100
                     local Default = math.clamp(Options.Default or ((Max - Min) / 2), Min, Max)
                     local Units = Options.Units or ""
                     local Callback = Options.Callback or function() end

                     local SliderBackground = Drawing.new("Square")
                     SliderBackground.Color = Colors["Object Background"]
                     SliderBackground.Filled = true
                     SliderBackground.Thickness = 1
                     SliderBackground.Transparency = 1
                     SliderBackground.Visible = self.Visible and self.State

                     local SliderBorder = Drawing.new("Square")
                     SliderBorder.Color = Colors["Object Border"]
                     SliderBorder.Filled = false
                     SliderBorder.Thickness = 1
                     SliderBorder.Transparency = 1
                     SliderBorder.Visible = self.Visible and self.State

                     local SliderFill = Drawing.new("Square")
                     SliderFill.Color = Colors["Accent"]
                     SliderFill.Filled = true
                     SliderFill.Transparency = 0.5
                     SliderFill.Visible = self.Visible and self.State

                     local SliderText = Drawing.new("Text")
                     SliderText.Text = SliderName
                     SliderText.Size = 12
                     SliderText.Font = 5
                     SliderText.Color = Colors["Text"]
                     SliderText.Outline = true
                     SliderText.OutlineColor = {0, 0, 0}
                     SliderText.Transparency = 1
                     SliderText.Center = false
                     SliderText.Visible = self.Visible and self.State

                     local ValueText = Drawing.new("Text")
                     ValueText.Text = string.format("%.1f%s", Default, Units)
                     ValueText.Size = 12
                     ValueText.Font = 5
                     ValueText.Color = {255, 255, 255}
                     ValueText.Outline = true
                     ValueText.OutlineColor = {0, 0, 0}
                     ValueText.Transparency = 1
                     ValueText.Center = true
                     ValueText.Visible = self.Visible and self.State

                     local SliderObj = {
                         Type = "Slider",
                         Name = SliderName,
                         Min = Min,
                         Max = Max,
                         Value = Default,
                         Units = Units,
                         Callback = Callback,
                         Background = SliderBackground,
                         Border = SliderBorder,
                         Fill = SliderFill,
                         Text = SliderText,
                         ValueText = ValueText,
                         DefaultBorderColor = Colors["Object Border"],
                         OriginalBackgroundColor = Colors["Object Background"],
                         Visible = self.Visible and self.State,
                         Dragging = false,
                         ParentToggle = self
                     }

                     function SliderObj:SetValue(NewValue)
                         local ClampedValue = math.clamp(NewValue, self.Min, self.Max)
                         self.Value = ClampedValue
                         self.ValueText.Text = string.format("%.1f%s", self.Value, self.Units)
                         if self.Background.Size and self.Background.Size.x and self.Background.Size.x > 0 then
                             local FillWidth = ((self.Value - self.Min) / (self.Max - self.Min)) * self.Background.Size.x
                             FillWidth = math.max(0, FillWidth)
                              self.Fill.Size = {FillWidth, self.Background.Size.y}
                         end
                         if self.Callback then
                             spawn(function() self.Callback(self.Value) end)
                         end
                     end

                     self.Slider = SliderObj

                     if IsVisible and WindowActive and WindowActive.ActiveTab == TabContent.Name then
                         WindowActive:UpdateLayout()
                     end
                     return SliderObj
                 end

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
             SetSectionContentVisibility(TabContent.LeftSections, false)
             SetSectionContentVisibility(TabContent.RightSections, false)
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
            SetSectionContentVisibility(OtherTab.Content.LeftSections, IsSelected)
            SetSectionContentVisibility(OtherTab.Content.RightSections, IsSelected)
        end
        Main:UpdateLayout()
    end

    WindowActive = Main
    return Main
end
spawn(function()
    while Running do
        local MouseLocation = getmouselocation(MouseService)
        Mouse.X = MouseLocation.x
        Mouse.Y = MouseLocation.y
        Mouse.Clicked = isleftclicked()
        Mouse.Pressed = isleftpressed()
        HoveredElement = nil
        local UIClickHandled = false
        local IsHovered = false
        local Keys = getpressedkeys()
        local IsToggleKeyNowPressed = false

        for _, K in ipairs(Keys) do
            if K == 'P' then
                IsToggleKeyNowPressed = true
                break
            end
        end

        if IsToggleKeyNowPressed and not IsToggleKeyPressed then
            ToggleUI()
        end
        IsToggleKeyPressed = IsToggleKeyNowPressed

        if IsVisible and WindowActive then
            if WindowActive:IsWindowHovered() then IsHovered = true end
            for _, TabObj in ipairs(WindowActive.Tabs) do
                if TabObj.Button.Visible and WindowActive:IsObjectHovered(TabObj.Button) then
                    IsHovered = true
                    break
                end
            end

            local WindowPos = WindowActive.WindowBackground.Position
            local DragAreaYMax = WindowActive.TabBackground.Position.y
            if Mouse.Clicked and IsHovered and Mouse.Y < DragAreaYMax and not IsDragging then
                 if not WindowActive.ActiveSlider then
                    IsDragging = true
                    DragOffsetX = Mouse.X - WindowPos.x
                    DragOffsetY = Mouse.Y - WindowPos.y
                    UIClickHandled = true
                 end
            elseif Mouse.Pressed and IsDragging then
                IsHovered = true
                local NewX = Mouse.X - DragOffsetX
                local NewY = Mouse.Y - DragOffsetY
                WindowActive.WindowBackground.Position = {NewX, NewY}
                WindowActive:UpdateElementPositions()
                UIClickHandled = true
            elseif not Mouse.Pressed and IsDragging then
                IsDragging = false
            end

             local ActiveSlider = nil
             if WindowActive.ActiveTab then
                 local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                 if CurrentTabContent then
                     local function FindActiveSlider(Sections)
                         for _, SectionObj in ipairs(Sections) do
                             if SectionObj.Visible and SectionObj.Interfaces then
                                 for _, Object in ipairs(SectionObj.Interfaces) do
                                     if Object.Type == "Toggle" and Object.Slider and Object.Slider.Dragging then
                                         return Object.Slider
                                     elseif Object.Type == "Slider" and Object.Dragging and not Object.ParentToggle then
                                        return Object
                                     end
                                 end
                             end
                         end
                         return nil
                     end
                     ActiveSlider = FindActiveSlider(CurrentTabContent.LeftSections) or FindActiveSlider(CurrentTabContent.RightSections)
                     WindowActive.ActiveSlider = ActiveSlider
                 end
             end

             if ActiveSlider and Mouse.Pressed then
                  IsHovered = true
                  UIClickHandled = true
                  local MouseX = Mouse.X
                  local SliderX = ActiveSlider.Background.Position.x
                  local SliderW = ActiveSlider.Background.Size.x
                  if SliderW > 0 then
                      local Ratio = math.clamp((MouseX - SliderX) / SliderW, 0, 1)
                      local NewValue = ActiveSlider.Min + (ActiveSlider.Max - ActiveSlider.Min) * Ratio
                      ActiveSlider:SetValue(NewValue)
                  end
             elseif not Mouse.Pressed then
                  if WindowActive.ActiveTab then
                      local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                      if CurrentTabContent then
                          local function StopDraggingSliders(Sections)
                              for _, SectionObj in ipairs(Sections) do
                                  if SectionObj.Visible and SectionObj.Interfaces then
                                      for _, Object in ipairs(SectionObj.Interfaces) do
                                         if Object.Type == "Toggle" and Object.Slider and Object.Slider.Dragging then
                                              Object.Slider.Dragging = false
                                          elseif Object.Type == "Slider" and Object.Dragging and not Object.ParentToggle then
                                              Object.Dragging = false
                                          end
                                      end
                                  end
                              end
                          end
                          StopDraggingSliders(CurrentTabContent.LeftSections)
                          StopDraggingSliders(CurrentTabContent.RightSections)
                          WindowActive.ActiveSlider = nil
                      end
                  end
             end


            if Mouse.Clicked and not IsDragging and not UIClickHandled then
                for _, TabObj in ipairs(WindowActive.Tabs) do
                    if TabObj.Button.Visible and WindowActive:IsObjectHovered(TabObj.Button) then
                        WindowActive:SelectTab(TabObj.Name)
                        UIClickHandled = true
                        break
                    end
                end

                if not UIClickHandled and WindowActive.ActiveTab then
                    local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                    if CurrentTabContent then
                        local function CheckElementClick(Sections)
                            for _, SectionObj in ipairs(Sections) do
                                if SectionObj.Visible and SectionObj.Interfaces then
                                    for _, Object in ipairs(SectionObj.Interfaces) do
                                         if Object.Type == "Button" and Object.ButtonBackground.Visible then
                                             if WindowActive:IsObjectHovered(Object.ButtonBackground) then
                                                 Object.ButtonBackground.Color = Colors["Selected"]
                                                 Object.ButtonBackground.Transparency = 0.135
                                                 Object.ButtonBorder.Color = Colors["Accent"]
                                                 local TargetButtonObj = Object
                                                 spawn(function()
                                                     wait(0.05)
                                                     if IsVisible and WindowActive and TargetButtonObj and TargetButtonObj.ButtonBackground.Visible then
                                                         TargetButtonObj.ButtonBackground.Color = TargetButtonObj.OriginalBackgroundColor
                                                         TargetButtonObj.ButtonBackground.Transparency = TargetButtonObj.OriginalBackgroundTransparency
                                                         TargetButtonObj.ButtonBorder.Color = WindowActive:IsObjectHovered(TargetButtonObj.ButtonBackground) and Colors["Accent"] or TargetButtonObj.DefaultBorderColor
                                                     end
                                                 end)
                                                 if Object.Callback then spawn(Object.Callback) end
                                                 UIClickHandled = true
                                                 return true
                                             end
                                         elseif Object.Type == "Toggle" and Object.OuterBox.Visible then
                                             if WindowActive:IsObjectHovered(Object.OuterBox) then
                                                 Object:SetState(not Object.State)
                                                 UIClickHandled = true
                                                 return true
                                              elseif Object.Slider and Object.Slider.Visible and WindowActive:IsObjectHovered(Object.Slider.Background) then
                                                  Object.Slider.Dragging = true
                                                  UIClickHandled = true
                                                  return true
                                             end
                                         elseif Object.Type == "Slider" and Object.Background.Visible and not Object.ParentToggle then
                                             if WindowActive:IsObjectHovered(Object.Background) then
                                                 Object.Dragging = true
                                                 UIClickHandled = true
                                                 return true
                                             end
                                         end
                                     end
                                 end
                             end
                             return false
                        end
                        if CheckElementClick(CurrentTabContent.LeftSections) then goto EndClickCheck end
                        if CheckElementClick(CurrentTabContent.RightSections) then goto EndClickCheck end
                        ::EndClickCheck::
                    end
                end
            end

             if WindowActive.ActiveTab then
                 local CurrentTabContent = WindowActive.TabContents[WindowActive.ActiveTab]
                 if CurrentTabContent then
                     local function UpdateElementVisuals(Sections)
                         for _, SectionObj in ipairs(Sections) do
                             if SectionObj.Visible and SectionObj.Interfaces then
                                 for _, Object in ipairs(SectionObj.Interfaces) do
                                     if Object.Type == "Button" and Object.ButtonBackground.Visible then
                                         local Hovered = WindowActive:IsObjectHovered(Object.ButtonBackground)
                                         if Hovered then
                                             IsHovered = true
                                             HoveredElement = Object
                                             Object.ButtonBorder.Color = Colors["Accent"]
                                         elseif not Mouse.Clicked or HoveredElement ~= Object then
                                             Object.ButtonBorder.Color = Object.DefaultBorderColor
                                         end
                                     elseif Object.Type == "Toggle" and Object.OuterBox.Visible then
                                         local HoveredBox = WindowActive:IsObjectHovered(Object.OuterBox)
                                         local HoveredSlider = false
                                         if Object.Slider and Object.Slider.Visible then
                                             HoveredSlider = WindowActive:IsObjectHovered(Object.Slider.Background)
                                         end

                                         if HoveredBox then
                                             IsHovered = true
                                             HoveredElement = Object
                                             Object.OuterBox.Color = Colors["Accent"]
                                         else
                                             Object.OuterBox.Color = Object.DefaultBorderColor
                                         end

                                         if Object.Slider then
                                             if HoveredSlider or Object.Slider.Dragging then
                                                 IsHovered = true
                                                 HoveredElement = Object.Slider
                                                 Object.Slider.Border.Color = Colors["Accent"]
                                             else
                                                  Object.Slider.Border.Color = Object.Slider.DefaultBorderColor
                                             end
                                         end
                                      elseif Object.Type == "Slider" and Object.Background.Visible and not Object.ParentToggle then
                                         local Hovered = WindowActive:IsObjectHovered(Object.Background)
                                         if Hovered or Object.Dragging then
                                             IsHovered = true
                                             HoveredElement = Object
                                             Object.Border.Color = Colors["Accent"]
                                         else
                                             Object.Border.Color = Object.DefaultBorderColor
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
        wait()
    end
end)

return Library
