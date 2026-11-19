if getgenv().DescendantLibrary and type(getgenv().DescendantLibrary) == "table" and getgenv().DescendantLibrary.Exit then
    getgenv().DescendantLibrary:Exit()
end

cloneref = cloneref or function(Object) return Object end

--#region Services
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
local Lighting = cloneref(game:GetService("Lighting"))
local CoreGui = cloneref(game:GetService("CoreGui"))
--#endregion

local GetHui = gethui or function() return CoreGui end

Library = {
    Flags = { },
    SetFlags = { },
    MenuKeybind = tostring(Enum.KeyCode.RightShift),

    Directory = "vivisivon",
    Folders = {
        Assets = "/Assets",
        Configs = "/Configs"
    },

    Name = "vivisivon",
    FontSize = 12,
    FontUrl = "https://github.com/bluescan/proggyfonts/raw/master/ProggyOriginal/ProggyClean.ttf",

    Animation = {
        Time = 0.2,
        Style = "Quart",
        Direction = "Out",

        FadeTime = 0.35,
        FadeStyle = "Sine",
    },

    Glow = {
        Enabled = true,
        Strength = 0.6,
        Size = 8,
    },

    BlurEnabled = false,
    BlurSize = 12,
    MinSize = Vector2.new(420, 320),

    Theme = {
        ["Window"]        = Color3.fromRGB(40, 41, 47),
        ["Inner"]         = Color3.fromRGB(30, 30, 37),
        ["Section"]       = Color3.fromRGB(30, 30, 36),
        ["Element"]       = Color3.fromRGB(50, 52, 60),
        ["Field"]         = Color3.fromRGB(26, 25, 32),
        ["Dark Outline"]  = Color3.fromRGB(16, 17, 19),
        ["Light Outline"] = Color3.fromRGB(59, 62, 73),
        ["Field Outline"] = Color3.fromRGB(49, 52, 61),
        ["Text"]          = Color3.fromRGB(255, 255, 255),
        ["Dim Text"]      = Color3.fromRGB(202, 204, 204),
        ["Inactive Text"] = Color3.fromRGB(125, 127, 134),
        ["Accent"]        = Color3.fromRGB(188, 188, 238),
    },

    Connections = { },
    Threads = { },
    Themed = { },
    OpenFrames = { },
    Floating = { },
    Landing = { },
    Sections = { },
    Movables = { },
    KeyList = nil,
    MenuOpen = true,
    Order = 0,
    Font = nil,
    Holder = nil,
    PopupHolder = nil,
    DragHolder = nil,
}
Library.__index = Library

local Flags = Library.Flags
local SetFlags = Library.SetFlags
local Theme = Library.Theme
local ConfigsFolder = Library.Directory .. Library.Folders.Configs
local AutoloadPath = Library.Directory .. "/autoload.txt"

local Black = Color3.new(0, 0, 0)
local White = Color3.new(1, 1, 1)

--#region Helpers
local function New(Class, Props)
    local Object = Instance.new(Class)
    Object.Name = "\0"

    if Object:IsA("GuiObject") then
        Object.BorderSizePixel = 0

        if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
            Object.FontFace = Library.Font
            Object.TextSize = Library.FontSize
            Object.TextColor3 = Theme.Text
            Object.TextStrokeTransparency = 0
            Object.BackgroundTransparency = 1
            Object.Text = ""
        end

        if Object:IsA("GuiButton") then
            Object.AutoButtonColor = false
        end
    end

    for Property, Value in Props do
        if Property ~= "Parent" then
            Object[Property] = Value
        end
    end

    Object.Parent = Props.Parent
    return Object
end

local function Wrap(Object)
    return { Instance = Object }
end

local function Connect(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(Library.Connections, Connection)
    return Connection
end

local function Spawn(Function)
    local Thread = task.spawn(Function)
    table.insert(Library.Threads, Thread)
    return Thread
end

local function SafeCall(Function, ...)
    if type(Function) ~= "function" then
        return false
    end

    local Ok, Result = pcall(Function, ...)
    if not Ok then
        warn("[vivisivon] callback error: " .. tostring(Result))
    end

    return Ok, Result
end

local function Tween(Object, Properties, Time, Style, Direction)
    local Info = TweenInfo.new(
        Time or Library.Animation.Time,
        Style or Enum.EasingStyle[Library.Animation.Style] or Enum.EasingStyle.Quart,
        Direction or Enum.EasingDirection[Library.Animation.Direction] or Enum.EasingDirection.Out
    )

    local NewTween = TweenService:Create(Object, Info, Properties)
    NewTween:Play()
    return NewTween
end

local function Animate(Object, Properties, Instant)
    if Instant then
        for Property, Value in Properties do
            Object[Property] = Value
        end

        return nil
    end

    return Tween(Object, Properties)
end

local function Glide(Item, Key, Properties, Instant)
    local Running = Item.Tweens[Key]

    if Running then
        Running:Cancel()
        Item.Tweens[Key] = nil
    end

    if Instant then
        Animate(Item.Frame, Properties, true)
        return nil
    end

    local NewTween = Tween(Item.Frame, Properties)
    Item.Tweens[Key] = NewTween
    return NewTween
end

local function Themed(Function)
    table.insert(Library.Themed, Function)
    Function()
    return Function
end

local function FadeProperties(Object)
    if Object:IsA("UIStroke") then
        return { "Transparency" }
    end

    if not Object:IsA("GuiObject") then
        return nil
    end

    local Properties = { "BackgroundTransparency" }

    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
        table.insert(Properties, "TextTransparency")
        table.insert(Properties, "TextStrokeTransparency")
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        table.insert(Properties, "ImageTransparency")
    end

    if Object:IsA("ScrollingFrame") then
        table.insert(Properties, "ScrollBarImageTransparency")
    end

    return Properties
end

local function FadeInfo(Kind)
    local Animation = Library.Animation

    if Kind == "Window" then
        return TweenInfo.new(
            Animation.FadeTime,
            Enum.EasingStyle[Animation.FadeStyle] or Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )
    end

    return TweenInfo.new(
        Animation.Time,
        Enum.EasingStyle[Animation.Style] or Enum.EasingStyle.Quart,
        Enum.EasingDirection[Animation.Direction] or Enum.EasingDirection.Out
    )
end

local function Fader(Root, UseScale, Kind)
    local Fade = {
        Open = Root.Visible,
        Snapshot = nil,
        Tween = nil,
        Shadows = { },
    }

    local Driver = Instance.new("NumberValue")
    Driver.Value = Fade.Open and 1 or 0

    local Scale = UseScale and New("UIScale", { Parent = Root }) or nil

    local function DetachShadows()
        for _, Object in Root:GetDescendants() do
            if Object:IsA("UIShadow") then
                Fade.Shadows[Object] = Object.Parent
                Object.Parent = nil
            end
        end
    end

    local function RestoreShadows()
        for Shadow, Parent in Fade.Shadows do
            if Parent.Parent then
                Shadow.Parent = Parent
            end
        end
        table.clear(Fade.Shadows)
    end

    local function Capture()
        local Snapshot = { }
        local Objects = Root:GetDescendants()
        table.insert(Objects, Root)

        for _, Object in Objects do
            local Properties = FadeProperties(Object)

            if Properties then
                local Values = { }
                for _, Property in Properties do
                    Values[Property] = Object[Property]
                end
                table.insert(Snapshot, { Object, Values })
            end
        end

        return Snapshot
    end

    local function Apply(Alpha)
        for _, Entry in Fade.Snapshot do
            local Object = Entry[1]
            for Property, Value in Entry[2] do
                Object[Property] = Value + (1 - Value) * (1 - Alpha)
            end
        end

        if Scale then
            Scale.Scale = 0.96 + 0.04 * Alpha
        end
    end

    Connect(Driver.Changed, function(Alpha)
        if Fade.Snapshot then
            Apply(Alpha)
        end
    end)

    local function Settle()
        Fade.Tween = nil

        if not Fade.Open then
            Root.Visible = false
        end

        if Fade.Snapshot then
            Apply(1)
        end

        Fade.Snapshot = nil
        RestoreShadows()
    end

    function Fade:Set(Bool)
        if Bool == Fade.Open then
            return
        end

        Fade.Open = Bool

        if Fade.Tween then
            Fade.Tween:Cancel()
        end

        DetachShadows()

        if not Fade.Snapshot then
            Fade.Snapshot = Capture()
            Driver.Value = Bool and 0 or 1
            Apply(Driver.Value)
        end

        if Bool then
            Root.Visible = true
        end

        local NewTween = TweenService:Create(Driver, FadeInfo(Kind), { Value = Bool and 1 or 0 })
        NewTween:Play()
        Fade.Tween = NewTween

        NewTween.Completed:Connect(function(State)
            if State == Enum.PlaybackState.Completed and Fade.Tween == NewTween then
                Settle()
            end
        end)
    end

    function Fade:Finish()
        if not Fade.Tween then
            return
        end

        Fade.Tween:Cancel()
        Driver.Value = Fade.Open and 1 or 0
        Settle()
    end

    return Fade
end

local function NextOrder()
    Library.Order += 1
    return Library.Order
end

local function IsClick(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(Input)
    return Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch
end

local function MouseAbs()
    return UserInputService:GetMouseLocation() + Library.Holder.AbsolutePosition
end

local function IsMouseOver(Object)
    if not Object or not Object.Parent or not Object.Visible then
        return false
    end

    local Mouse = MouseAbs()
    local Position, Size = Object.AbsolutePosition, Object.AbsoluteSize

    return Mouse.X >= Position.X and Mouse.X <= Position.X + Size.X
        and Mouse.Y >= Position.Y and Mouse.Y <= Position.Y + Size.Y
end

local function PlaceBelow(Popup, Anchor, OffsetY, AlignRight)
    local Position = Anchor.AbsolutePosition - Library.PopupHolder.AbsolutePosition
    local X = Position.X

    if AlignRight then
        X = Position.X + Anchor.AbsoluteSize.X - Popup.AbsoluteSize.X
    end

    Popup.Position = UDim2.fromOffset(X, Position.Y + Anchor.AbsoluteSize.Y + (OffsetY or 4))
end

local function Round(Number, Step)
    Step = tonumber(Step) or 1
    if Step <= 0 then
        Step = 1
    end

    local Rounded = math.floor(Number / Step + 0.5) * Step
    local Text = tostring(Step)
    local Dot = Text:find(".", 1, true)
    local Digits = Dot and (#Text - Dot) or 0

    return tonumber(string.format("%." .. Digits .. "f", Rounded))
end

local function ToRichColor(Color)
    return string.format("rgb(%d, %d, %d)", math.floor(Color.R * 255), math.floor(Color.G * 255), math.floor(Color.B * 255))
end

local function Glow(Parent)
    return New("UIShadow", {
        Parent = Parent,
        Transparency = 1,
        ShowBehindParent = false,
        BlurRadius = UDim.new(0, Library.Glow.Size),
        Spread = UDim2.fromOffset(1, 1),
    })
end

local function GlowTo(Shadow, On, Instant, Power)
    local Strength = math.clamp(Library.Glow.Strength * (Power or 1), 0, 1)

    return Animate(Shadow, {
        Color = Theme.Accent,
        BlurRadius = UDim.new(0, Library.Glow.Size),
        Transparency = (On and Library.Glow.Enabled) and 1 - Strength or 1,
    }, Instant)
end

local function Border(Parent, MidKey, Gradient)
    local Strokes = { }

    for Index, Key in { "Dark Outline", MidKey or "Light Outline", "Dark Outline" } do
        local Stroke = New("UIStroke", {
            Parent = Parent,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            BorderOffset = UDim.new(0, Index - 1),
        })
        Themed(function() Stroke.Color = Theme[Key] end)
        Strokes[Index] = Stroke
    end

    if Gradient then
        New("UIGradient", {
            Parent = Strokes[2],
            Rotation = -90,
            Color = ColorSequence.new(Color3.fromRGB(91, 90, 91), White),
        })
    end

    return Strokes
end

local function Outline(Parent, Key)
    local Inner = New("UIStroke", {
        Parent = Parent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    if Key then
        Themed(function() Inner.Color = Theme[Key] end)
    end

    New("UIStroke", {
        Parent = Parent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        BorderOffset = UDim.new(0, 1),
        Color = Black,
    })

    return Inner
end

local function Shade(Parent, Rotation, From, To)
    return New("UIGradient", {
        Parent = Parent,
        Rotation = Rotation or 90,
        Color = ColorSequence.new(From or White, To or Color3.fromRGB(201, 201, 201)),
    })
end

local function Highlight(Parent, Inset)
    Inset = Inset or 0

    local Line = New("Frame", {
        Parent = Parent,
        Position = UDim2.fromOffset(-Inset, -Inset),
        Size = UDim2.new(1, Inset * 2, 0, 1),
        ZIndex = 3,
    })

    New("UIGradient", {
        Parent = Line,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 110, 110)),
            ColorSequenceKeypoint.new(0.5, White),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 110, 110)),
        }
    })

    local Shadow = Glow(Line)

    Themed(function()
        Line.BackgroundColor3 = Theme.Accent
        GlowTo(Shadow, true, true, 0.7)
    end)

    return Line
end

local function Draggable(Handle, Target, Id)
    local Dragging, DragStart, StartPosition = false, nil, nil

    if Id then
        Library.Movables[Id] = Target
    end

    Connect(Handle.InputBegan, function(Input)
        if IsClick(Input) then
            Dragging = true
            DragStart = Input.Position
            StartPosition = Target.Position
        end
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if IsClick(Input) then
            Dragging = false
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if Dragging and IsMove(Input) then
            local Delta = Input.Position - DragStart

            Tween(Target, {
                Position = UDim2.new(
                    StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                    StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
                )
            }, 0.08)
        end
    end)
end

local function TabButton(Parent, Text, Order, BackKey)
    local Tab = { Active = false, Hovered = false }

    local Frame = New("Frame", {
        Parent = Parent,
        Size = UDim2.new(0, 10, 1, 0),
        BackgroundTransparency = 0,
        LayoutOrder = Order or 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme[BackKey or "Inner"] end)
    Border(Frame)

    local Shadow = Glow(Frame)

    local Fill = New("Frame", {
        Parent = Frame,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0.9,
    })
    New("UIGradient", { Parent = Fill, Rotation = -90, Color = ColorSequence.new(Black, Color3.fromRGB(183, 184, 186)) })

    local Line = New("Frame", {
        Parent = Frame,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(0, 0, 0, 1),
        ZIndex = 3,
    })

    local Label = New("TextLabel", {
        Parent = Frame,
        Size = UDim2.fromScale(1, 1),
        Text = Text,
        ZIndex = 2,
    })

    function Tab:Paint(Instant)
        local Active = Tab.Active

        Animate(Fill, { BackgroundColor3 = Active and White or (Tab.Hovered and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(60, 60, 60)) }, Instant)
        Animate(Line, { BackgroundColor3 = Theme.Accent, Size = UDim2.new(Active and 1 or 0, 0, 0, 1) }, Instant)
        Animate(Label, { TextColor3 = Active and Theme.Text or (Tab.Hovered and Theme["Dim Text"] or Theme["Inactive Text"]) }, Instant)
        GlowTo(Shadow, Active, Instant, 0.45)
    end

    Themed(function() Tab:Paint(true) end)

    function Tab:SetActive(Bool)
        Tab.Active = Bool
        Tab:Paint()
    end

    Connect(Frame.MouseEnter, function()
        Tab.Hovered = true
        Tab:Paint()
    end)

    Connect(Frame.MouseLeave, function()
        Tab.Hovered = false
        Tab:Paint()
    end)

    Tab.Frame, Tab.Label = Frame, Label
    return Tab
end

local function ButtonFrame(Parent, Text, Props, BackKey)
    local Item = { Hovered = false }

    local Button = New("TextButton", {
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 0,
    })

    for Property, Value in Props or { } do
        Button[Property] = Value
    end

    Themed(function() Button.BackgroundColor3 = Theme[BackKey or "Section"] end)
    Border(Button)

    local Shadow = Glow(Button)

    local Fill = New("Frame", {
        Parent = Button,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0.9,
    })
    New("UIGradient", { Parent = Fill, Rotation = -90, Color = ColorSequence.new(Black, Color3.fromRGB(183, 184, 186)) })

    local Line = New("Frame", {
        Parent = Button,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(0, 0, 0, 1),
        ZIndex = 3,
    })

    local Label = New("TextLabel", {
        Parent = Button,
        Size = UDim2.fromScale(1, 1),
        Text = Text,
        ZIndex = 2,
    })

    function Item:Paint(Instant)
        local Hovered = Item.Hovered

        Animate(Fill, { BackgroundColor3 = Hovered and White or Color3.fromRGB(70, 70, 70) }, Instant)
        Animate(Line, { BackgroundColor3 = Theme.Accent, Size = UDim2.new(Hovered and 1 or 0, 0, 0, 1) }, Instant)
        Animate(Label, { TextColor3 = Hovered and Theme.Text or Theme["Dim Text"] }, Instant)
        GlowTo(Shadow, Hovered, Instant, 0.45)
    end

    Themed(function() Item:Paint(true) end)

    function Item:Flash()
        Label.TextColor3 = Theme.Accent
        GlowTo(Shadow, true, true, 1.6)
        Item:Paint()
    end

    Connect(Button.MouseEnter, function()
        Item.Hovered = true
        Item:Paint()
    end)

    Connect(Button.MouseLeave, function()
        Item.Hovered = false
        Item:Paint()
    end)

    Item.Button, Item.Label = Button, Label
    return Item
end

local KeyNames = {
    LeftShift = "LShift", RightShift = "RShift",
    LeftControl = "LCtrl", RightControl = "RCtrl",
    LeftAlt = "LAlt", RightAlt = "RAlt",
    MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
    Return = "Enter", CapsLock = "Caps",
    Backspace = "None", Escape = "None", Unknown = "None", None = "None",
}

local function KeyName(Key)
    local Name = tostring(Key):match("([^%.]+)$") or "None"
    return KeyNames[Name] or Name
end
--#endregion

--#region Library methods
Library.SafeCall = function(Self, Function, ...)
    return SafeCall(Function, ...)
end

Library.Connect = function(Self, Signal, Callback)
    return Connect(Signal, Callback)
end

Library.Thread = function(Self, Function)
    return Spawn(Function)
end

Library.Round = function(Self, Number, Step)
    return Round(Number, Step)
end

Library.IsMouseOverFrame = function(Self, Object)
    return IsMouseOver(Object or (Self.Instance))
end

Library.Refresh = function(Self)
    for _, Function in Library.Themed do
        Function()
    end
end

Library.ChangeTheme = function(Self, Key, Color)
    Theme[Key] = Color
    Library:Refresh()
end

Library.CloseAll = function(Self, Except)
    for _, Frame in Library.OpenFrames do
        if Frame ~= Except then
            Frame:SetOpen(false)
        end
    end
end

Library.Exit = function(Self)
    for _, Connection in Library.Connections do
        Connection:Disconnect()
    end

    for _, Thread in Library.Threads do
        pcall(task.cancel, Thread)
    end

    Library.Holder:Destroy()
    Library.PopupHolder:Destroy()
    Library.DragHolder:Destroy()
    Library.Blur:Destroy()
    Library.Unloaded = true
    getgenv().DescendantLibrary = nil
end

Library.GetConfig = function(Self)
    local Config = { }

    for Index, Value in Library.Flags do
        if type(Value) == "table" and Value.Key then
            Config[Index] = { Key = tostring(Value.Key), Mode = Value.Mode }
        elseif type(Value) == "table" and Value.Color then
            Config[Index] = { Color = "#" .. Value.HexValue, Alpha = Value.Alpha }
        else
            Config[Index] = Value
        end
    end

    Config.__layout = Library:GetLayout()

    return HttpService:JSONEncode(Config)
end

Library.LoadConfig = function(Self, Config)
    local Ok, Result = pcall(function()
        local Decoded = HttpService:JSONDecode(Config)

        for Index, Value in Decoded do
            local SetFunction = SetFlags[Index]

            if SetFunction then
                if type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end

        if Decoded.__layout then
            Library:ApplyLayout(Decoded.__layout)
        end
    end)

    return Ok, Result
end

Library.GetConfigsList = function(Self, Element)
    local List = { }

    for _, File in listfiles(ConfigsFolder) do
        local Name = File:match("([^/\\]+)%.json$")
        if Name then
            table.insert(List, Name)
        end
    end

    table.sort(List)

    if Element and Element.Refresh then
        Element:Refresh(List)
    end

    return List
end

Library.GetAutoload = function(Self)
    if not isfile(AutoloadPath) then
        return nil
    end

    local Name = readfile(AutoloadPath)
    return Name ~= "" and Name or nil
end

Library.SetAutoload = function(Self, Name)
    if Name then
        writefile(AutoloadPath, Name)
    elseif isfile(AutoloadPath) then
        delfile(AutoloadPath)
    end
end
--#endregion

--#region Folders + Font
if not isfolder(Library.Directory) then
    makefolder(Library.Directory)
end

for _, Folder in Library.Folders do
    if not isfolder(Library.Directory .. Folder) then
        makefolder(Library.Directory .. Folder)
    end
end

Library.Font = (function()
    local Ok, Result = pcall(function()
        local Assets = Library.Directory .. Library.Folders.Assets
        local TtfPath = Assets .. "/ProggyClean.ttf"
        local JsonPath = Assets .. "/ProggyClean.json"

        if not isfile(TtfPath) then
            local Data = game:HttpGet(Library.FontUrl)
            assert(#Data > 10000, "bad font download")
            writefile(TtfPath, Data)
        end

        writefile(JsonPath, HttpService:JSONEncode({
            name = "ProggyClean",
            faces = {
                { name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(TtfPath) }
            }
        }))

        return Font.new(getcustomasset(JsonPath), Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    end)

    if Ok and Result then
        return Result
    end

    warn("[vivisivon] ProggyClean failed to load, using Code font: " .. tostring(Result))
    return Font.fromEnum(Enum.Font.Code)
end)()
--#endregion

--#region Holders
Library.Holder = New("ScreenGui", {
    Parent = GetHui(),
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 100,
})

Library.PopupHolder = New("ScreenGui", {
    Parent = GetHui(),
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 101,
})

Library.DragHolder = New("ScreenGui", {
    Parent = GetHui(),
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 102,
})

Library.NotifHolder = New("Frame", {
    Parent = Library.PopupHolder,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -14, 1, -14),
    Size = UDim2.new(0, 250, 1, -28),
})

New("UIListLayout", {
    Parent = Library.NotifHolder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
})

Connect(RunService.RenderStepped, function()
    for _, Frame in Library.OpenFrames do
        if Frame.Reposition then
            Frame:Reposition()
        end
    end
end)

Library.Blur = New("BlurEffect", { Parent = Lighting, Size = 0 })

Library.UpdateEffects = function(Self)
    TweenService:Create(Library.Blur, FadeInfo("Window"), {
        Size = (Library.MenuOpen and Library.BlurEnabled) and Library.BlurSize or 0
    }):Play()
end
--#endregion

--#region Notification
Library.Notification = function(Self, Params)
    Params = Params or { }

    local Text = Params.Name or Params.name or Params.Text or Params.text or "notification"
    local Title = Params.Title or Params.title or Library.Name
    local Time = Params.Time or Params.time or 3

    local Slot = New("Frame", {
        Parent = Library.NotifHolder,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(250, 0),
        LayoutOrder = NextOrder(),
    })

    local Card = New("Frame", {
        Parent = Slot,
        Position = UDim2.fromOffset(270, 0),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
    })
    Themed(function() Card.BackgroundColor3 = Theme.Window end)
    Border(Card, nil, true)
    Shade(Card, -90, Color3.fromRGB(91, 90, 91), White)
    Highlight(Card, 2)

    local Info = New("Frame", {
        Parent = Card,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    New("UIPadding", {
        Parent = Info,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })
    New("UIListLayout", { Parent = Info, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

    local Head = New("TextLabel", {
        Parent = Info,
        Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = tostring(Title),
        LayoutOrder = 1,
    })
    Themed(function() Head.TextColor3 = Theme.Accent end)

    local Body = New("TextLabel", {
        Parent = Info,
        Size = UDim2.new(1, 0, 0, 12),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        RichText = true,
        Text = tostring(Text),
        LayoutOrder = 2,
    })
    Themed(function() Body.TextColor3 = Theme["Dim Text"] end)

    local Bar = New("Frame", {
        Parent = Card,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 3,
    })
    local BarGlow = Glow(Bar)
    Themed(function()
        Bar.BackgroundColor3 = Theme.Accent
        GlowTo(BarGlow, true, true, 0.8)
    end)

    Spawn(function()
        task.wait()

        Tween(Slot, { Size = UDim2.fromOffset(250, Card.AbsoluteSize.Y) }, 0.3)
        Tween(Card, { Position = UDim2.fromOffset(0, 0) }, 0.45, Enum.EasingStyle.Quint)
        Tween(Bar, { Size = UDim2.new(0, 0, 0, 1) }, Time, Enum.EasingStyle.Linear)

        task.wait(Time)

        Tween(Card, { Position = UDim2.fromOffset(270, 0) }, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
        Tween(Slot, { Size = UDim2.fromOffset(250, 0) }, 0.25).Completed:Wait()
        Slot:Destroy()
    end)
end
--#endregion

--#region Docking
local Drag = nil

local function CanDrag()
    local Window = Library.WindowObject

    if Drag or not Window or not Window.IsOpen or Window.Fader.Tween then
        return false
    end

    local Page = Window.Current
    return not (Page and Page.Fader.Tween)
end

local function SettleLanding()
    for Section in Library.Landing do
        Section:Settle()
    end
end

local function NewPlaceholder(Column, Height, Instant)
    local Frame = New("Frame", {
        Parent = Column.Scroll,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(4, 0),
        Size = UDim2.new(1, -8, 0, Instant and Height or 0),
    })

    local Stroke = New("UIStroke", {
        Parent = Frame,
        Color = Theme.Accent,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Tween(Frame, { BackgroundTransparency = 0.88, Size = UDim2.new(1, -8, 0, Height) })
    Tween(Stroke, { Transparency = 0 })

    return {
        Frame = Frame,
        Stroke = Stroke,
        Height = Height,
        Placeholder = true,
        Tweens = { },
    }
end

local function DropPlaceholder(Placeholder, Shrink)
    local Goal = { BackgroundTransparency = 1 }

    if Shrink then
        Goal.Size = UDim2.new(1, -8, 0, 0)
    end

    Tween(Placeholder.Stroke, { Transparency = 1 })
    Tween(Placeholder.Frame, Goal).Completed:Connect(function()
        Placeholder.Frame:Destroy()
    end)
end

local function SlotAt(Mouse)
    local Window = Library.WindowObject
    local Page = Window and Window.Current

    if not Page or not Window.IsOpen then
        return nil
    end

    local Area = Window.Items.Content.Instance

    if not IsMouseOver(Area) then
        return nil
    end

    local Middle = Area.AbsolutePosition.X + Area.AbsoluteSize.X / 2
    local Column = Page.Columns[Mouse.X < Middle and 1 or 2]
    local Y = Mouse.Y - Column.Scroll.AbsolutePosition.Y + Column.Scroll.CanvasPosition.Y
    local Index = 1

    for _, Item in Column.Items do
        if not Item.Placeholder and Y > Item.Y + (Item.Hidden and 0 or Item.Height / 2) then
            Index += 1
        end
    end

    return Column, Index
end

local function Reshape()
    local Section = Drag.Section
    local Size = Drag.Size

    if Drag.Column then
        Size = Vector2.new(Drag.Column.Scroll.AbsoluteSize.X - 8, Section.Height)
    end

    Drag.Offset = Vector2.new(math.min(Drag.Offset.X, Size.X - 16), Drag.Offset.Y)
    Glide(Section, "Size", { Size = UDim2.fromOffset(Size.X, Size.Y) })
end

local function SetSlot(Column, Index)
    if Column == Drag.Column and Index == Drag.Index then
        return
    end

    local Old = Drag.Column
    local Placeholder = Drag.Placeholder

    if Old then
        table.remove(Old.Items, table.find(Old.Items, Placeholder))

        if Old ~= Column then
            DropPlaceholder(Placeholder, true)
            Placeholder = nil
            Old:Layout()
        end
    end

    if Column then
        local Snap = nil

        if not Placeholder then
            Placeholder = NewPlaceholder(Column, Drag.Section.Height)
            Snap = Placeholder
        end

        table.insert(Column.Items, Index, Placeholder)
        Column:Layout(false, Snap)
    end

    Drag.Column, Drag.Index, Drag.Placeholder = Column, Index, Placeholder

    if Column ~= Old then
        Reshape()
    end
end

local function BeginDrag(Section)
    local Frame = Section.Frame
    local Column = Section.Column
    local Position = Frame.AbsolutePosition

    Library:CloseAll()

    Drag = {
        Section = Section,
        Position = Position,
        Offset = MouseAbs() - Position,
        Size = Section.FloatSize or Frame.AbsoluteSize,
    }

    if Column then
        local Index = table.find(Column.Items, Section)
        local Placeholder = NewPlaceholder(Column, Section.Height, true)

        Column.Items[Index] = Placeholder
        Drag.Column, Drag.Index, Drag.Placeholder = Column, Index, Placeholder
        Column:Layout(false, Placeholder)
    end

    Section:Lift()
end

local function EndDrag()
    local Current = Drag
    local Column, Placeholder = Current.Column, Current.Placeholder

    Drag = nil

    if Column then
        local Index = table.find(Column.Items, Placeholder)

        table.remove(Column.Items, Index)
        DropPlaceholder(Placeholder)
        Current.Section:Dock(Column, Index)
    else
        Current.Section:Float()
    end
end

Connect(RunService.RenderStepped, function(Delta)
    if not Drag then
        return
    end

    local Mouse = MouseAbs()
    local Origin = Library.DragHolder.AbsolutePosition

    Drag.Position = Drag.Position:Lerp(Mouse - Drag.Offset, math.min(Delta * 24, 1))
    Drag.Section.Frame.Position = UDim2.fromOffset(Drag.Position.X - Origin.X, Drag.Position.Y - Origin.Y)

    local Column, Index = SlotAt(Mouse)

    if Column then
        local Scroll = Column.Scroll
        local Top = Scroll.AbsolutePosition.Y
        local Bottom = Top + Scroll.AbsoluteSize.Y
        local Direction = 0

        if Mouse.Y < Top + 24 then
            Direction = -1
        elseif Mouse.Y > Bottom - 24 then
            Direction = 1
        end

        if Direction ~= 0 then
            local Limit = math.max(Scroll.AbsoluteCanvasSize.Y - Scroll.AbsoluteWindowSize.Y, 0)
            Scroll.CanvasPosition = Vector2.new(0, math.clamp(Scroll.CanvasPosition.Y + Direction * 320 * Delta, 0, Limit))
        end
    end

    SetSlot(Column, Index)
end)

Connect(UserInputService.InputEnded, function(Input)
    if Drag and IsClick(Input) then
        EndDrag()
    end
end)

local function FindPage(Name)
    local Window = Library.WindowObject

    for _, Page in Window.Pages do
        if Page.Name == Name then
            return Page
        end
    end
end

Library.GetLayout = function(Self)
    local Layout = { Frames = { }, Sections = { } }
    local Window = Library.WindowObject

    if Window then
        Layout.Size = { Window.Size.X.Offset, Window.Size.Y.Offset }
    end

    for Id, Frame in Library.Movables do
        local Position = Frame.Position
        Layout.Frames[Id] = { Position.X.Scale, Position.X.Offset, Position.Y.Scale, Position.Y.Offset }
    end

    for Id, Section in Library.Sections do
        Layout.Sections[Id] = Section:Save()
    end

    return Layout
end

Library.ApplyLayout = function(Self, Layout)
    local Window = Library.WindowObject

    if type(Layout) ~= "table" or not Window then
        return
    end

    if Drag then
        EndDrag()
    end

    SettleLanding()

    if type(Layout.Size) == "table" and Layout.Size[1] and Layout.Size[2] then
        Window:Resize(Layout.Size[1], Layout.Size[2])
    end

    for Id, Position in Layout.Frames or { } do
        local Frame = Library.Movables[Id]

        if Frame and type(Position) == "table" and #Position == 4 then
            Tween(Frame, { Position = UDim2.new(Position[1], Position[2], Position[3], Position[4]) })
        end
    end

    local Entries = { }

    for Id, Data in Layout.Sections or { } do
        local Section = Library.Sections[Id]

        if Section and type(Data) == "table" then
            Section:Pull()
            table.insert(Entries, { Section, Data })
        end
    end

    table.sort(Entries, function(A, B)
        return (A[2].Index or 0) < (B[2].Index or 0)
    end)

    for _, Entry in Entries do
        Entry[1]:Place(Entry[2])
    end

    for _, Page in Window.Pages do
        for _, Column in Page.Columns do
            Column:Layout(true)
        end
    end
end
--#endregion

--#region Colorpicker
Library.CreateColorpicker = function(Self, Data)
    local Colorpicker = {
        Hue = 0,
        Saturation = 0,
        Value = 1,
        Alpha = 0,

        Color = Color3.new(1, 1, 1),
        HexValue = "FFFFFF",

        Flag = Data.Flag,
        IsOpen = false,
        Items = { },
    }

    local Swatch = New("TextButton", {
        Parent = Data.Parent,
        Size = UDim2.fromOffset(20, 10),
        BackgroundTransparency = 0,
        LayoutOrder = NextOrder(),
    })
    Outline(Swatch, "Field Outline")

    local SwatchGlow = Glow(Swatch)
    local Hovered = false

    local function PaintSwatch(Instant)
        Animate(SwatchGlow, {
            Color = Colorpicker.Color,
            BlurRadius = UDim.new(0, Library.Glow.Size),
            Transparency = ((Hovered or Colorpicker.IsOpen) and Library.Glow.Enabled) and 1 - Library.Glow.Strength or 1,
        }, Instant)
    end
    Themed(function() PaintSwatch(true) end)

    local Popup = New("TextButton", {
        Parent = Library.PopupHolder,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(190, 180),
    })
    Themed(function() Popup.BackgroundColor3 = Theme.Window end)
    Border(Popup, nil, true)
    Highlight(Popup, 2)

    local Palette = New("TextButton", {
        Parent = Popup,
        BackgroundTransparency = 0,
        Position = UDim2.fromOffset(7, 8),
        Size = UDim2.new(1, -35, 1, -36),
    })
    Outline(Palette, "Field Outline")

    local SaturationOverlay = New("Frame", {
        Parent = Palette,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = White,
    })
    New("UIGradient", { Parent = SaturationOverlay, Transparency = NumberSequence.new(0, 1) })

    local ValueOverlay = New("Frame", {
        Parent = Palette,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Black,
        ZIndex = 2,
    })
    New("UIGradient", { Parent = ValueOverlay, Rotation = 90, Transparency = NumberSequence.new(1, 0) })

    local PaletteDragger = New("Frame", {
        Parent = Palette,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(4, 4),
        BackgroundColor3 = White,
        ZIndex = 3,
    })
    New("UIStroke", { Parent = PaletteDragger, Color = Black })

    local HueBar = New("TextButton", {
        Parent = Popup,
        BackgroundTransparency = 0,
        BackgroundColor3 = White,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -7, 0, 8),
        Size = UDim2.new(0, 14, 1, -36),
    })
    Outline(HueBar, "Field Outline")
    New("UIGradient", {
        Parent = HueBar,
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }
    })

    local HueDragger = New("Frame", {
        Parent = HueBar,
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = White,
        ZIndex = 2,
    })
    New("UIStroke", { Parent = HueDragger, Color = Black })

    local AlphaBack = New("ImageLabel", {
        Parent = Popup,
        Position = UDim2.new(0, 7, 1, -21),
        Size = UDim2.new(1, -35, 0, 13),
        BackgroundTransparency = 1,
        Image = "rbxassetid://18274452449",
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(6, 6),
    })
    Outline(AlphaBack, "Field Outline")

    local AlphaBar = New("TextButton", {
        Parent = AlphaBack,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1, 1),
    })
    New("UIGradient", { Parent = AlphaBar, Transparency = NumberSequence.new(0, 1) })

    local AlphaDragger = New("Frame", {
        Parent = AlphaBar,
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = White,
        ZIndex = 2,
    })
    New("UIStroke", { Parent = AlphaDragger, Color = Black })

    local Preview = New("Frame", {
        Parent = Popup,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -7, 1, -8),
        Size = UDim2.fromOffset(14, 13),
    })
    Outline(Preview, "Field Outline")

    local PopupFader = Fader(Popup, true)

    Colorpicker.Items = {
        ColorpickerButton = Wrap(Swatch),
        ColorpickerWindow = Wrap(Popup),
        Palette = Wrap(Palette),
        Hue = Wrap(HueBar),
        Alpha = Wrap(AlphaBar),
    }
    Colorpicker.Holder = Colorpicker.Items.ColorpickerWindow

    function Colorpicker:Update()
        Colorpicker.Color = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value)
        Colorpicker.HexValue = Colorpicker.Color:ToHex()

        Swatch.BackgroundColor3 = Colorpicker.Color
        Palette.BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
        AlphaBar.BackgroundColor3 = Colorpicker.Color
        Preview.BackgroundColor3 = Colorpicker.Color
        Preview.BackgroundTransparency = Colorpicker.Alpha

        PaletteDragger.Position = UDim2.fromScale(Colorpicker.Saturation, 1 - Colorpicker.Value)
        HueDragger.Position = UDim2.fromScale(0, Colorpicker.Hue)
        AlphaDragger.Position = UDim2.fromScale(Colorpicker.Alpha, 0)
        PaintSwatch(true)

        Flags[Colorpicker.Flag] = {
            Alpha = Colorpicker.Alpha,
            Color = Colorpicker.Color,
            HexValue = Colorpicker.HexValue,
            Transparency = 1 - Colorpicker.Alpha,
        }

        SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
    end

    function Colorpicker:Set(Color, Alpha)
        if type(Color) == "table" then
            Color = Color3.fromRGB(Color[1], Color[2], Color[3])
        elseif type(Color) == "string" then
            Color = Color3.fromHex(Color)
        end

        if typeof(Color) ~= "Color3" then
            return
        end

        Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
        Colorpicker.Alpha = Alpha or 0
        Colorpicker:Update()
    end

    function Colorpicker:SetVisibility(Bool)
        Swatch.Visible = Bool
    end

    function Colorpicker:Reposition()
        PlaceBelow(Popup, Swatch, 6, true)
    end

    function Colorpicker:SetOpen(Bool)
        Colorpicker.IsOpen = Bool

        if Bool then
            Library:CloseAll(Colorpicker)
            Colorpicker:Reposition()
            Library.OpenFrames[Colorpicker] = Colorpicker
        else
            Library.OpenFrames[Colorpicker] = nil
        end

        PopupFader:Set(Bool)
        PaintSwatch()
    end

    local Sliding = nil

    local function Slide()
        local Mouse = MouseAbs()

        if Sliding == "Palette" then
            local Position, Size = Palette.AbsolutePosition, Palette.AbsoluteSize
            Colorpicker.Saturation = math.clamp((Mouse.X - Position.X) / Size.X, 0, 1)
            Colorpicker.Value = 1 - math.clamp((Mouse.Y - Position.Y) / Size.Y, 0, 1)
        elseif Sliding == "Hue" then
            local Position, Size = HueBar.AbsolutePosition, HueBar.AbsoluteSize
            Colorpicker.Hue = math.clamp((Mouse.Y - Position.Y) / Size.Y, 0, 0.999)
        elseif Sliding == "Alpha" then
            local Position, Size = AlphaBar.AbsolutePosition, AlphaBar.AbsoluteSize
            Colorpicker.Alpha = math.clamp((Mouse.X - Position.X) / Size.X, 0, 1)
        else
            return
        end

        Colorpicker:Update()
    end

    for Name, Object in { Palette = Palette, Hue = HueBar, Alpha = AlphaBar } do
        Connect(Object.InputBegan, function(Input)
            if IsClick(Input) then
                Sliding = Name
                Slide()
            end
        end)
    end

    Connect(UserInputService.InputChanged, function(Input)
        if Sliding and IsMove(Input) then
            Slide()
        end
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if IsClick(Input) then
            Sliding = nil
        end
    end)

    Connect(Swatch.MouseEnter, function()
        Hovered = true
        PaintSwatch()
    end)

    Connect(Swatch.MouseLeave, function()
        Hovered = false
        PaintSwatch()
    end)

    Connect(Swatch.MouseButton1Click, function()
        Colorpicker:SetOpen(not Colorpicker.IsOpen)
    end)

    Connect(UserInputService.InputBegan, function(Input)
        if IsClick(Input) and Colorpicker.IsOpen and not IsMouseOver(Popup) and not IsMouseOver(Swatch) then
            Colorpicker:SetOpen(false)
        end
    end)

    Colorpicker:Set(Data.Default or Color3.new(1, 1, 1), Data.Alpha)

    SetFlags[Colorpicker.Flag] = function(Value, Alpha)
        Colorpicker:Set(Value, Alpha)
    end

    return Colorpicker, Colorpicker.Items
end
--#endregion

--#region Keybind
Library.CreateKeybind = function(Self, Data)
    local Keybind = {
        Flag = Data.Flag,
        IsOpen = false,

        Key = "None",
        Mode = Data.Mode or "Toggle",
        Value = "None",

        Toggled = false,
        Picking = false,

        Items = { },
    }

    local KeyButton = New("TextButton", {
        Parent = Data.Parent,
        Size = UDim2.new(0, 0, 0, 12),
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = "[None]",
        LayoutOrder = NextOrder(),
    })

    local Hovered = false

    local function Paint(Instant)
        Animate(KeyButton, {
            TextColor3 = Keybind.Picking and Theme.Accent or (Hovered and Theme.Text or Theme["Dim Text"])
        }, Instant)
    end
    Themed(function() Paint(true) end)

    local ModePopup = New("Frame", {
        Parent = Library.PopupHolder,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(70, 3 * 16 + 2 * 3 + 10),
    })
    Themed(function() ModePopup.BackgroundColor3 = Theme.Window end)
    Border(ModePopup, nil, true)
    Highlight(ModePopup, 2)
    New("UIPadding", { Parent = ModePopup, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) })
    New("UIListLayout", { Parent = ModePopup, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

    local PopupFader = Fader(ModePopup, true)
    local ModeButtons = { }

    local function PaintModes(Instant)
        for Mode, Button in ModeButtons do
            Animate(Button, { TextColor3 = (Keybind.Mode == Mode) and Theme.Accent or Theme["Inactive Text"] }, Instant)
        end
    end

    Keybind.Items = {
        KeyButton = Wrap(KeyButton),
        KeybindWindow = Wrap(ModePopup),
    }
    Keybind.Holder = Keybind.Items.KeybindWindow

    local Entry
    if Library.KeyList and Data.ShowInList ~= false then
        Entry = Library.KeyList:Add(Data.Name or Keybind.Flag, Keybind.Mode)
    end

    local function Update()
        PaintModes()

        if not Entry then
            return
        end

        Entry:Set(Data.Name or Keybind.Flag, Keybind.Mode)

        if Keybind.Mode == "Hold" then
            Entry:SetMode(Keybind.Toggled and "holding" or "off")
        elseif Keybind.Mode == "Always" then
            Entry:SetMode("always on")
        else
            Entry:SetMode(Keybind.Toggled and "toggled" or "off")
        end

        Entry:SetStatus(Keybind.Toggled)
    end

    local function WriteFlag()
        Flags[Keybind.Flag] = {
            Mode = Keybind.Mode,
            Key = Keybind.Key,
            Toggled = Keybind.Toggled,
        }
    end

    function Keybind:SetMode()
        WriteFlag()
        SafeCall(Data.Callback, Keybind.Toggled)
        Update()
    end

    function Keybind:Press(Bool)
        if Keybind.Mode == "Toggle" then
            Keybind.Toggled = not Keybind.Toggled
        elseif Keybind.Mode == "Hold" then
            Keybind.Toggled = Bool
        elseif Keybind.Mode == "Always" then
            Keybind.Toggled = true
        end

        WriteFlag()
        SafeCall(Data.Callback, Keybind.Toggled)
        Update()
    end

    local function ApplyKey(Key)
        local Display = KeyName(Key)

        if Display == "None" then
            Keybind.Key = "None"
        else
            Keybind.Key = tostring(Key)
        end

        Keybind.Value = Display
        KeyButton.Text = "[" .. Display .. "]"
    end

    function Keybind:Set(Key)
        if typeof(Key) == "EnumItem" then
            ApplyKey(Key)
            Keybind:SetMode()
        elseif type(Key) == "table" then
            ApplyKey(Key.Key or "None")
            Keybind.Mode = Key.Mode or "Toggle"
            Keybind:SetMode()

            if Keybind.Mode == "Always" then
                Keybind:Press(true)
            end
        elseif type(Key) == "string" and table.find({ "Toggle", "Hold", "Always" }, Key) then
            Keybind.Mode = Key
            Keybind:SetMode()
        elseif type(Key) == "string" then
            ApplyKey(Key)
            Keybind:SetMode()
        end

        Keybind.Picking = false
        Paint()
    end

    function Keybind:Reposition()
        PlaceBelow(ModePopup, KeyButton, 4, true)
    end

    function Keybind:SetOpen(Bool)
        Keybind.IsOpen = Bool

        if Bool then
            Library:CloseAll(Keybind)
            Keybind:Reposition()
            Library.OpenFrames[Keybind] = Keybind
        else
            Library.OpenFrames[Keybind] = nil
        end

        PopupFader:Set(Bool)
    end

    for Index, Mode in { "Toggle", "Hold", "Always" } do
        local Button = New("TextButton", {
            Parent = ModePopup,
            Size = UDim2.new(1, 0, 0, 16),
            Text = Mode:lower(),
            LayoutOrder = Index,
        })

        ModeButtons[Mode] = Button

        Connect(Button.MouseEnter, function()
            if Keybind.Mode ~= Mode then
                Tween(Button, { TextColor3 = Theme["Dim Text"] })
            end
        end)

        Connect(Button.MouseLeave, function()
            PaintModes()
        end)

        Connect(Button.MouseButton1Click, function()
            Keybind.Mode = Mode
            Keybind:SetMode()

            if Mode == "Always" then
                Keybind:Press(true)
            end

            Keybind:SetOpen(false)
        end)
    end

    Themed(function() PaintModes(true) end)

    Connect(KeyButton.MouseEnter, function()
        Hovered = true
        Paint()
    end)

    Connect(KeyButton.MouseLeave, function()
        Hovered = false
        Paint()
    end)

    Connect(KeyButton.MouseButton1Click, function()
        if Keybind.Picking then
            return
        end

        Keybind.Picking = true
        KeyButton.Text = "[...]"
        Paint()

        local Picker
        Picker = UserInputService.InputBegan:Connect(function(Input)
            local Key

            if Input.UserInputType == Enum.UserInputType.Keyboard then
                Key = Input.KeyCode
            elseif Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.MouseButton2
                or Input.UserInputType == Enum.UserInputType.MouseButton3 then
                Key = Input.UserInputType
            else
                return
            end

            Picker:Disconnect()

            ApplyKey(Key)
            WriteFlag()
            SafeCall(Data.Callback, Keybind.Toggled)
            Update()

            task.defer(function()
                Keybind.Picking = false
                Paint()
            end)
        end)
    end)

    Connect(KeyButton.MouseButton2Click, function()
        Keybind:SetOpen(not Keybind.IsOpen)
    end)

    local function Matches(Input)
        return tostring(Input.KeyCode) == Keybind.Key or tostring(Input.UserInputType) == Keybind.Key
    end

    Connect(UserInputService.InputBegan, function(Input, GameProcessed)
        if IsClick(Input) and Keybind.IsOpen and not IsMouseOver(ModePopup) and not IsMouseOver(KeyButton) then
            Keybind:SetOpen(false)
        end

        if Keybind.Picking or Keybind.Value == "None" or GameProcessed then
            return
        end

        if Data.Toggle and not Data.Toggle.Value then
            return
        end

        if Matches(Input) then
            if Keybind.Mode == "Toggle" then
                Keybind:Press()
            else
                Keybind:Press(true)
            end
        end
    end)

    Connect(UserInputService.InputEnded, function(Input, GameProcessed)
        if GameProcessed or Keybind.Value == "None" then
            return
        end

        if Matches(Input) and Keybind.Mode == "Hold" then
            Keybind:Press(false)
        end
    end)

    if Data.Default then
        Keybind:Set({ Key = Data.Default, Mode = Data.Mode or "Toggle" })
    else
        WriteFlag()
        Update()
    end

    SetFlags[Keybind.Flag] = function(Value)
        Keybind:Set(Value)
    end

    return Keybind, Keybind.Items
end
--#endregion

--#region Watermark
Library.Watermark = function(Self, Params)
    Params = Params or { }

    local Watermark = {
        Name = Params.Name or Params.name or Library.Name,
        SubName = Params.SubName or Params.subname,
        PlaceName = "game",
        Fps = 0,
        Items = { },
    }

    local Frame = New("Frame", {
        Parent = Library.Holder,
        Position = UDim2.new(0, 14, 0, 14),
        Size = UDim2.new(0, 0, 0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Window end)
    Border(Frame, nil, true)
    Shade(Frame, -90, Color3.fromRGB(91, 90, 91), White)
    Highlight(Frame, 2)
    New("UIPadding", { Parent = Frame, PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) })

    local Label = New("TextLabel", {
        Parent = Frame,
        RichText = true,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
    })

    Draggable(Frame, Frame, "Watermark")

    Watermark.Items = { Watermark = Wrap(Frame), Text = Wrap(Label) }
    local WatermarkFader = Fader(Frame, false, "Window")

    local function Render()
        local Parts = { string.format('<font color="%s">%s</font>', ToRichColor(Theme.Accent), Watermark.Name) }

        if Watermark.SubName and Watermark.SubName ~= Watermark.Name then
            table.insert(Parts, Watermark.SubName)
        end

        table.insert(Parts, Watermark.PlaceName)
        table.insert(Parts, Watermark.Fps .. " fps")

        local Now = os.date("*t")
        local Hour = Now.hour % 12
        table.insert(Parts, string.format("%d:%02d", Hour == 0 and 12 or Hour, Now.min))

        Label.Text = table.concat(Parts, " / ")
    end
    Themed(Render)

    function Watermark:SetText(Text)
        Watermark.Name = tostring(Text)
        Render()
    end

    function Watermark:SetSubText(Text)
        Watermark.SubName = Text and tostring(Text) or nil
        Render()
    end

    function Watermark:SetVisibility(Bool)
        WatermarkFader:Set(Bool)
    end

    Spawn(function()
        local Ok, Info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)

        if Ok and Info and Info.Name then
            Watermark.PlaceName = Info.Name
        end
    end)

    local Frames = 0

    Connect(RunService.RenderStepped, function()
        Frames += 1
    end)

    Spawn(function()
        while true do
            Watermark.Fps = Frames
            Frames = 0
            Render()
            task.wait(1)
        end
    end)

    Library.WatermarkObject = Watermark
    return setmetatable(Watermark, Library)
end
--#endregion

--#region KeybindList
Library.KeybindList = function(Self, Params)
    Params = Params or { }

    local KeybindList = {
        Name = Params.Name or Params.name or "keybinds",
        Items = { },
    }

    local Frame = New("Frame", {
        Parent = Library.Holder,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.45, 0),
        Size = UDim2.new(0, 180, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Window end)
    Border(Frame, nil, true)
    Shade(Frame, -90, Color3.fromRGB(91, 90, 91), White)
    Highlight(Frame, 2)
    New("UIPadding", {
        Parent = Frame,
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7),
    })

    local Title = New("TextLabel", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 0, 22),
        Text = KeybindList.Name,
    })
    Draggable(Title, Frame, "Keybinds")

    local Content = New("Frame", {
        Parent = Frame,
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
    })
    Themed(function() Content.BackgroundColor3 = Theme.Inner end)
    Border(Content)
    New("UIPadding", {
        Parent = Content,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
    })
    New("UIListLayout", { Parent = Content, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })

    KeybindList.Items = { KeybindList = Wrap(Frame), Text = Wrap(Title), Content = Wrap(Content) }
    local ListFader = Fader(Frame, false, "Window")

    function KeybindList:SetText(Text)
        Title.Text = tostring(Text)
    end

    function KeybindList:SetVisibility(Bool)
        ListFader:Set(Bool)
    end

    function KeybindList:Add(Name, Mode)
        local Entry = { }
        local CanBeVisible = true

        local Row = New("Frame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Visible = false,
            LayoutOrder = NextOrder(),
        })

        local NameLabel = New("TextLabel", {
            Parent = Row,
            Size = UDim2.new(1, -60, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = tostring(Name),
        })

        local ModeLabel = New("TextLabel", {
            Parent = Row,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 60, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = tostring(Mode),
        })
        Themed(function() ModeLabel.TextColor3 = Theme.Accent end)

        local RowFader = Fader(Row)

        Entry.NewKey = Wrap(Row)
        Entry.Text = Wrap(NameLabel)
        Entry.Mode = Wrap(ModeLabel)

        function Entry:SetVis(Bool)
            CanBeVisible = Bool
            if not Bool then
                RowFader:Set(false)
            end
        end

        function Entry:SetStatus(Bool)
            RowFader:Set(CanBeVisible and Bool and true or false)
        end

        function Entry:Set(NewName)
            NameLabel.Text = tostring(NewName)
        end

        function Entry:SetMode(NewMode)
            ModeLabel.Text = "[" .. tostring(NewMode) .. "]"
        end

        return Entry
    end

    Library.KeyList = KeybindList
    return setmetatable(KeybindList, Library)
end
--#endregion

--#region Window
Library.Window = function(Self, Params)
    Params = Params or { }

    local Window = {
        Name = Params.Name or Params.name or "vivisivon.lua",
        Size = Params.Size or Params.size or UDim2.fromOffset(494, 414),

        IsOpen = true,
        Pages = { },
        Current = nil,
        Items = { },
    }
    Window.Window = Window

    local Plain = (Window.Name:gsub("<[^>]->", ""))
    Library.Name = Plain:match("^%s*(.-)%s*|") or Plain

    local Width, Height = Window.Size.X.Offset, Window.Size.Y.Offset

    local Main = New("Frame", {
        Parent = Library.Holder,
        Position = UDim2.new(0.5, -Width / 2, 0.5, -Height / 2),
        Size = Window.Size,
        BackgroundTransparency = 0,
    })
    Themed(function() Main.BackgroundColor3 = Theme.Window end)
    Border(Main, nil, true)
    Shade(Main, -90, Color3.fromRGB(91, 90, 91), White)
    Highlight(Main, 2)
    New("UIShadow", {
        Parent = Main,
        Color = Black,
        Transparency = 0.4,
        BlurRadius = UDim.new(0, 24),
        Offset = UDim2.fromOffset(0, 4),
    })

    local Title = New("TextLabel", {
        Parent = Main,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -14, 0, 25),
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Window.Name,
    })
    Draggable(Title, Main, "Window")

    local Content = New("Frame", {
        Parent = Main,
        Position = UDim2.fromOffset(10, 25),
        Size = UDim2.new(1, -20, 1, -37),
        BackgroundTransparency = 0,
    })
    Themed(function() Content.BackgroundColor3 = Theme.Inner end)
    Border(Content)
    Shade(Content, -90, Color3.fromRGB(91, 90, 91), White)
    Highlight(Content, 2)

    local PagesHolder = New("Frame", {
        Parent = Content,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7, 7),
        Size = UDim2.new(1, -14, 1, -45),
    })

    local TabBar = New("Frame", {
        Parent = Content,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 30),
    })
    New("UIListLayout", {
        Parent = TabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        VerticalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local Grip = New("TextButton", {
        Parent = Main,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1),
        Size = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 0.6,
        ZIndex = 5,
    })
    Themed(function() Grip.BackgroundColor3 = Theme.Accent end)
    New("UIGradient", {
        Parent = Grip,
        Rotation = 45,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(0.51, 0),
            NumberSequenceKeypoint.new(1, 0),
        }
    })

    Window.Items = {
        MainFrame = Wrap(Main),
        Title = Wrap(Title),
        Content = Wrap(PagesHolder),
        Pages = Wrap(TabBar),
        Grip = Wrap(Grip),
    }

    Window.Fader = Fader(Main, true, "Window")

    function Window:Resize(X, Y, Fast)
        local Screen = Library.Holder.AbsoluteSize
        local Min = Library.MinSize

        X = math.clamp(math.floor(X), Min.X, math.max(Screen.X, Min.X))
        Y = math.clamp(math.floor(Y), Min.Y, math.max(Screen.Y, Min.Y))

        Window.Size = UDim2.fromOffset(X, Y)
        Tween(Main, { Size = Window.Size }, Fast and 0.08 or nil)
    end

    local Resizing = nil

    Connect(Grip.MouseEnter, function() Tween(Grip, { BackgroundTransparency = 0 }) end)
    Connect(Grip.MouseLeave, function() Tween(Grip, { BackgroundTransparency = 0.6 }) end)

    Connect(Grip.InputBegan, function(Input)
        if IsClick(Input) then
            Library:CloseAll()
            Resizing = { Mouse = MouseAbs(), Size = Vector2.new(Window.Size.X.Offset, Window.Size.Y.Offset) }
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if Resizing and IsMove(Input) then
            local Delta = MouseAbs() - Resizing.Mouse
            Window:Resize(Resizing.Size.X + Delta.X, Resizing.Size.Y + Delta.Y, true)
        end
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if IsClick(Input) then
            Resizing = nil
        end
    end)

    function Window:SetOpen(Bool)
        if Bool == Window.IsOpen then
            return
        end

        if Drag then
            EndDrag()
        end

        SettleLanding()

        Window.IsOpen = Bool
        Library.MenuOpen = Bool
        Library:CloseAll()

        for _, Page in Window.Pages do
            Page.Fader:Finish()
        end

        Window.Fader:Set(Bool)

        for _, Entry in Library.Floating do
            Entry.Fader:Set(Bool and Entry.Enabled)
        end

        Library:UpdateEffects()
    end

    function Window:Center()
        local Size = Window.Size
        Tween(Main, { Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2) })
    end

    function Window:SetText(Text)
        Title.Text = tostring(Text)
    end

    Connect(UserInputService.InputBegan, function(Input)
        if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
            if UserInputService:GetFocusedTextBox() then
                return
            end

            Window:SetOpen(not Window.IsOpen)
        end
    end)

    Library.WindowObject = Window
    Library:UpdateEffects()
    return setmetatable(Window, Library)
end
--#endregion

--#region Page
Library.Page = function(Self, Params)
    Params = Params or { }

    local Window = Self.Window or Self

    local Page = {
        Name = Params.Name or Params.name or "Page",
        Window = Window,
        Columns = { },
        ColumnsData = { },
        Items = { },
    }
    Page.Page = Page

    local Tab = TabButton(Window.Items.Pages.Instance, Page.Name, #Window.Pages + 1, "Inner")

    local Holder = New("Frame", {
        Parent = Window.Items.Content.Instance,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
    })

    local function Column(Index)
        local Scroll = New("ScrollingFrame", {
            Parent = Holder,
            BackgroundTransparency = 1,
            Position = Index == 1 and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 5, 0, 0),
            Size = UDim2.new(0.5, -5, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 0,
            Active = true,
        })

        Connect(Scroll:GetPropertyChangedSignal("CanvasPosition"), function()
            Library:CloseAll()
        end)

        local Data = {
            Scroll = Scroll,
            Holder = Holder,
            Page = Page,
            Items = { },
        }

        function Data:Layout(Instant, Snap)
            local Y = 5

            for _, Item in Data.Items do
                Item.Y = Y

                if not Item.Hidden then
                    if Item.State ~= "Landing" then
                        Glide(Item, "Position", { Position = UDim2.fromOffset(4, Y) }, Instant or Item == Snap)
                    end

                    Y += Item.Height + 8
                end
            end

            Scroll.CanvasSize = UDim2.fromOffset(0, math.max(Y - 3, 0))
        end

        return Data
    end

    local Left, Right = Column(1), Column(2)
    Page.Columns[1] = Left
    Page.Columns[2] = Right
    Page.ColumnsData[1] = Left.Scroll
    Page.ColumnsData[2] = Right.Scroll
    Page.Fader = Fader(Holder)

    Page.Items = {
        Inactive = Wrap(Tab.Frame),
        Text = Wrap(Tab.Label),
        Page = Wrap(Holder),
        LeftColumn = Wrap(Left.Scroll),
        RightColumn = Wrap(Right.Scroll),
    }

    function Page:Turn()
        local Old = Window.Current

        if Old == Page or Window.Fader.Tween or Drag then
            return
        end

        SettleLanding()
        Library:CloseAll()
        Window.Current = Page

        if Old then
            Old.Fader:Set(false)
            Tween(Old.Items.Page.Instance, { Position = UDim2.fromOffset(0, -8) })
            Old.Tab:SetActive(false)
        end

        Holder.Position = UDim2.fromOffset(0, 8)
        Tween(Holder, { Position = UDim2.fromOffset(0, 0) })
        Page.Fader:Set(true)

        Tab:SetActive(true)
    end

    Connect(Tab.Frame.InputBegan, function(Input)
        if IsClick(Input) then
            Page:Turn()
        end
    end)

    Page.Tab = Tab
    table.insert(Window.Pages, Page)

    if #Window.Pages == 1 then
        Page:Turn()
    end

    return setmetatable(Page, Library)
end
--#endregion

--#region Section
Library.Section = function(Self, Params)
    Params = Params or { }

    local Side = Params.Side or Params.side or 1
    if type(Side) == "string" then
        Side = Side:lower() == "right" and 2 or 1
    end
    Side = math.clamp(Side, 1, 2)

    local Home = Self.Columns[Side]

    local Section = {
        Name = Params.Name or Params.name or "Section",
        Side = Side,

        Window = Self.Window,
        Page = Self,
        Column = Home,

        State = "Docked",
        Height = 54,
        Y = 0,
        Hidden = false,
        FloatSize = nil,
        FloatPosition = nil,
        Born = os.clock(),
        Tweens = { },
        Tabs = { },
        CurrentTab = nil,
        Items = { },
    }
    Section.Section = Section

    local Id = Self.Name .. "/" .. Section.Name
    while Library.Sections[Id] do
        Id ..= "+"
    end
    Section.Id = Id
    Library.Sections[Id] = Section

    local Frame = New("Frame", {
        Parent = Home.Scroll,
        Position = UDim2.fromOffset(4, 0),
        Size = UDim2.new(1, -8, 0, Section.Height),
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Section end)
    Border(Frame)
    Shade(Frame, 90)

    local Accent = Highlight(Frame, 2)
    Accent.Visible = false

    local Shadow = Glow(Frame)
    Themed(function() GlowTo(Shadow, Section.State ~= "Docked", true, 0.7) end)

    local Handle = New("TextButton", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 0, 36),
    })

    local Header = New("Frame", {
        Parent = Handle,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(1, -24, 0, 20),
    })

    local Title = New("TextLabel", {
        Parent = Header,
        Size = UDim2.fromScale(1, 1),
        Text = Section.Name,
    })
    Border(Title)

    local TabList = New("Frame", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
    })
    New("UIListLayout", {
        Parent = TabList,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        VerticalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local Body = New("ScrollingFrame", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(6, 36),
        Size = UDim2.new(1, -12, 1, -42),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = false,
        ScrollBarThickness = 2,
    })
    Themed(function() Body.ScrollBarImageColor3 = Theme.Accent end)
    New("UIPadding", {
        Parent = Body,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
    })
    local List = New("UIListLayout", { Parent = Body, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

    local Default = New("Frame", {
        Parent = Body,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
    })
    New("UIListLayout", { Parent = Default, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

    Connect(Default.ChildAdded, function()
        Default.Visible = true
    end)

    local Grip = New("TextButton", {
        Parent = Frame,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -3, 1, -3),
        Size = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 0,
        ZIndex = 5,
        Visible = false,
    })
    Themed(function() Grip.BackgroundColor3 = Theme.Accent end)
    New("UIGradient", {
        Parent = Grip,
        Rotation = 45,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(0.51, 0),
            NumberSequenceKeypoint.new(1, 0),
        }
    })

    Section.Frame = Frame
    Section.Container = Default
    Section.Fader = Fader(Frame, true, "Window")
    Section.Items = {
        Section = Wrap(Frame),
        Content = Wrap(Body),
        Text = Wrap(Title),
        Handle = Wrap(Handle),
        Grip = Wrap(Grip),
    }

    local Entry = { Frame = Frame, Enabled = true, Fader = Section.Fader }

    local function SetState(State)
        local Loose = State ~= "Docked"
        local Floating = State == "Floating"
        local Index = table.find(Library.Floating, Entry)

        Section.State = State
        Accent.Visible = Loose
        Grip.Visible = Floating
        Body.ScrollingEnabled = Floating
        GlowTo(Shadow, Loose, false, 0.7)

        if Floating and not Index then
            table.insert(Library.Floating, Entry)
        elseif Index and not Floating then
            table.remove(Library.Floating, Index)
        end
    end

    local function Measure()
        local Content = List.AbsoluteContentSize.Y

        Section.Height = Content + 54
        Body.CanvasSize = UDim2.fromOffset(0, Content + 12)

        if Section.State ~= "Docked" then
            return
        end

        local Instant = os.clock() - Section.Born < 1 or not Section.Column.Holder.Visible

        Glide(Section, "Size", { Size = UDim2.new(1, -8, 0, Section.Height) }, Instant)
        Section.Column:Layout(Instant)
    end

    function Section:SetText(Text)
        Title.Text = tostring(Text)
    end

    function Section:SetVisibility(Bool)
        Section.Hidden = not Bool
        Entry.Enabled = Bool

        if Section.State == "Floating" then
            Section.Fader:Set(Bool and Library.MenuOpen)
        else
            Frame.Visible = Bool
        end

        if Section.Column then
            Section.Column:Layout()
        end
    end

    function Section:Tab(Data)
        Data = Data or { }

        local SubTab = {
            Name = Data.Name or Data.name or "Tab",
            Window = Section.Window,
            Page = Section.Page,
            Section = Section,
            Items = { },
        }

        local Button = TabButton(TabList, SubTab.Name, #Section.Tabs + 1, "Section")

        local Content = New("Frame", {
            Parent = Body,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            LayoutOrder = 1,
        })
        New("UIListLayout", { Parent = Content, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

        SubTab.Container = Content
        SubTab.Button = Button
        SubTab.Fader = Fader(Content)
        SubTab.Items = { Button = Wrap(Button.Frame), Text = Wrap(Button.Label), Content = Wrap(Content) }

        function SubTab:Select()
            local Old = Section.CurrentTab

            if Old == SubTab then
                return
            end

            Library:CloseAll()
            Section.CurrentTab = SubTab

            if Old then
                Old.Button:SetActive(false)
                Old.Fader:Set(false)
                Old.Fader:Finish()
            end

            Button:SetActive(true)
            SubTab.Fader:Set(true)
        end

        table.insert(Section.Tabs, SubTab)
        Title.Visible = false
        TabList.Visible = true

        if #Section.Tabs == 1 then
            SubTab:Select()
        end

        return setmetatable(SubTab, Library)
    end

    function Section:Lift()
        local Position = Frame.AbsolutePosition - Library.DragHolder.AbsolutePosition
        local Size = Frame.AbsoluteSize

        SetState("Dragging")
        Section.Column = nil
        Frame.Parent = Library.DragHolder

        Glide(Section, "Position", { Position = UDim2.fromOffset(Position.X, Position.Y) }, true)
        Glide(Section, "Size", { Size = UDim2.fromOffset(Size.X, Size.Y) }, true)
    end

    function Section:Settle()
        if Section.State ~= "Landing" then
            return
        end

        Library.Landing[Section] = nil
        SetState("Docked")

        Frame.Parent = Section.Column.Scroll
        Frame.ZIndex = 1

        Glide(Section, "Position", { Position = UDim2.fromOffset(4, Section.Y) }, true)
        Glide(Section, "Size", { Size = UDim2.new(1, -8, 0, Section.Height) }, true)
    end

    function Section:Dock(Target, Index)
        local Scroll = Target.Scroll
        local Origin = Library.DragHolder.AbsolutePosition

        Index = math.clamp(Index or #Target.Items + 1, 1, #Target.Items + 1)
        table.insert(Target.Items, Index, Section)

        Section.Column = Target
        Section.Page = Target.Page
        Section.Side = table.find(Target.Page.Columns, Target)
        Library.Landing[Section] = true

        SetState("Landing")
        Body.CanvasPosition = Vector2.zero
        Target:Layout()

        local Goal = Scroll.AbsolutePosition - Scroll.CanvasPosition - Origin + Vector2.new(4, Section.Y)

        Glide(Section, "Size", { Size = UDim2.fromOffset(Scroll.AbsoluteSize.X - 8, Section.Height) })
        Glide(Section, "Position", { Position = UDim2.fromOffset(Goal.X, Goal.Y) }).Completed:Connect(function(State)
            if State == Enum.PlaybackState.Completed then
                Section:Settle()
            end
        end)
    end

    function Section:Float()
        local Position = Frame.AbsolutePosition - Library.Holder.AbsolutePosition
        local Size = Frame.AbsoluteSize
        local Screen = Library.Holder.AbsoluteSize

        Section.FloatSize = Section.FloatSize or Vector2.new(Size.X, math.min(Size.Y, 420))

        local Width, Height = Section.FloatSize.X, Section.FloatSize.Y
        local Goal = Vector2.new(
            math.clamp(Position.X, 0, math.max(Screen.X - Width, 0)),
            math.clamp(Position.Y, 0, math.max(Screen.Y - Height, 0))
        )

        Section.FloatPosition = Goal
        SetState("Floating")
        Section.Column = nil
        Frame.Parent = Library.Holder
        Frame.ZIndex = NextOrder() + 1

        Glide(Section, "Position", { Position = UDim2.fromOffset(Position.X, Position.Y) }, true)
        Glide(Section, "Position", { Position = UDim2.fromOffset(Goal.X, Goal.Y) })
        Glide(Section, "Size", { Size = UDim2.fromOffset(Width, Height) })
    end

    function Section:Pull()
        local Column = Section.Column

        if Column then
            local Index = table.find(Column.Items, Section)

            if Index then
                table.remove(Column.Items, Index)
            end

            Section.Column = nil
        end
    end

    function Section:Place(Data)
        if Data.State == "Floating" and Data.W and Data.H then
            local Screen = Library.Holder.AbsoluteSize
            local Width, Height = math.max(Data.W, 150), math.max(Data.H, 60)
            local X = math.clamp(Data.X or 0, 0, math.max(Screen.X - Width, 0))
            local Y = math.clamp(Data.Y or 0, 0, math.max(Screen.Y - Height, 0))

            Section.FloatSize = Vector2.new(Width, Height)
            Section.FloatPosition = Vector2.new(X, Y)

            if Section.State ~= "Floating" then
                local Position = Frame.AbsolutePosition - Library.Holder.AbsolutePosition
                Frame.Parent = Library.Holder
                Glide(Section, "Position", { Position = UDim2.fromOffset(Position.X, Position.Y) }, true)
            end

            SetState("Floating")
            Frame.ZIndex = NextOrder() + 1

            Glide(Section, "Position", { Position = UDim2.fromOffset(X, Y) })
            Glide(Section, "Size", { Size = UDim2.fromOffset(Width, Height) })
            return
        end

        local Page = FindPage(Data.Page) or Section.Page
        local Target = Page.Columns[Data.Side] or Page.Columns[Section.Side] or Page.Columns[1]
        local Index = math.clamp(tonumber(Data.Index) or #Target.Items + 1, 1, #Target.Items + 1)

        table.insert(Target.Items, Index, Section)

        Section.Column = Target
        Section.Page = Page
        Section.Side = table.find(Page.Columns, Target)

        SetState("Docked")
        Frame.Parent = Target.Scroll
        Frame.ZIndex = 1
        Body.CanvasPosition = Vector2.zero

        Glide(Section, "Size", { Size = UDim2.new(1, -8, 0, Section.Height) }, true)
    end

    function Section:Save()
        if Section.State == "Floating" then
            local Position = Section.FloatPosition or Frame.AbsolutePosition
            local Size = Section.FloatSize or Frame.AbsoluteSize

            return { State = "Floating", X = Position.X, Y = Position.Y, W = Size.X, H = Size.Y }
        end

        local Column = Section.Column

        if not Column then
            return nil
        end

        local Index = 0

        for _, Item in Column.Items do
            if not Item.Placeholder then
                Index += 1
            end

            if Item == Section then
                break
            end
        end

        return {
            State = "Docked",
            Page = Column.Page.Name,
            Side = table.find(Column.Page.Columns, Column),
            Index = Index,
        }
    end

    local Pending = nil
    local Resizing = nil

    Connect(Handle.InputBegan, function(Input)
        if not IsClick(Input) then
            return
        end

        if Section.State == "Floating" then
            Frame.ZIndex = NextOrder() + 1
        end

        if Section.State == "Floating" or Section.State == "Docked" then
            Pending = MouseAbs()
        end
    end)

    Connect(Grip.InputBegan, function(Input)
        if IsClick(Input) and Section.State == "Floating" then
            Resizing = { Mouse = MouseAbs(), Size = Frame.AbsoluteSize }
            Frame.ZIndex = NextOrder() + 1
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if not IsMove(Input) then
            return
        end

        local Mouse = MouseAbs()

        if Pending and (Mouse - Pending).Magnitude > 4 then
            Pending = nil

            if CanDrag() then
                BeginDrag(Section)
            end
        elseif Resizing then
            local Screen = Library.Holder.AbsoluteSize
            local Delta = Mouse - Resizing.Mouse
            local Width = math.clamp(Resizing.Size.X + Delta.X, 150, math.max(Screen.X, 150))
            local Height = math.clamp(Resizing.Size.Y + Delta.Y, 60, math.max(Screen.Y, 60))

            Section.FloatSize = Vector2.new(Width, Height)
            Glide(Section, "Size", { Size = UDim2.fromOffset(Width, Height) }, true)
        end
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if not IsClick(Input) then
            return
        end

        if Pending then
            for _, SubTab in Section.Tabs do
                if IsMouseOver(SubTab.Button.Frame) then
                    SubTab:Select()
                    break
                end
            end
        end

        Pending = nil
        Resizing = nil
    end)

    Connect(Body:GetPropertyChangedSignal("CanvasPosition"), function()
        Library:CloseAll()
    end)

    Connect(List:GetPropertyChangedSignal("AbsoluteContentSize"), Measure)

    table.insert(Home.Items, Section)
    Home:Layout(true)
    Measure()

    return setmetatable(Section, Library)
end
--#endregion

--#region Toggle
Library.Toggle = function(Self, Params)
    Params = Params or { }

    local Toggle = {
        Name = Params.Name or Params.name or "Toggle",
        Flag = Params.Flag or Params.flag or Params.Name or Params.name or ("toggle_" .. NextOrder()),
        Default = Params.Default or Params.default or false,
        Callback = Params.Callback or Params.callback or function() end,

        Window = Self.Window,
        Page = Self.Page,
        Section = Self.Section or Self,

        Value = false,
        Items = { },
        SettingsItem = nil,
    }

    local Root = New("Frame", {
        Parent = Self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(),
    })
    New("UIListLayout", { Parent = Root, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

    local Row = New("TextButton", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 12),
        LayoutOrder = 1,
    })

    local Box = New("Frame", {
        Parent = Row,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 1, 0.5, 0),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 0,
    })
    local BoxStroke = Outline(Box)
    New("UIGradient", { Parent = BoxStroke, Rotation = -90, Color = ColorSequence.new(Color3.fromRGB(157, 158, 159), White) })
    New("UIGradient", { Parent = Box, Rotation = -90, Color = ColorSequence.new(Color3.fromRGB(157, 158, 159), White) })

    local BoxScale = New("UIScale", { Parent = Box })
    local Shadow = Glow(Box)

    local Label = New("TextLabel", {
        Parent = Row,
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -18, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Toggle.Name,
    })

    local Sub = New("Frame", {
        Parent = Row,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
    })
    New("UIListLayout", {
        Parent = Sub,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    Toggle.Items = {
        Toggle = Wrap(Root),
        Button = Wrap(Row),
        Indicator = Wrap(Box),
        Text = Wrap(Label),
        SubElements = Wrap(Sub),
    }

    local Hovered = false

    local function Paint(Instant)
        local On = Toggle.Value
        local BoxColor = On and Theme.Accent or (Hovered and Theme.Element:Lerp(White, 0.1) or Theme.Element)

        Animate(Box, { BackgroundColor3 = BoxColor }, Instant)
        Animate(BoxStroke, { Color = BoxColor }, Instant)
        Animate(Label, { TextColor3 = (On or Hovered) and Theme.Text or Theme["Dim Text"] }, Instant)
        GlowTo(Shadow, On, Instant, Hovered and 1.2 or 1)
    end
    Themed(function() Paint(true) end)

    Connect(Row.MouseEnter, function() Hovered = true Paint() end)
    Connect(Row.MouseLeave, function() Hovered = false Paint() end)

    function Toggle:Set(Bool)
        Bool = Bool and true or false

        if Bool and not Toggle.Value then
            BoxScale.Scale = 0.55
            Tween(BoxScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
        end

        Toggle.Value = Bool
        Paint()

        if Toggle.SettingsItem then
            Toggle.SettingsItem:SetOpen(Bool)
        end

        Flags[Toggle.Flag] = Bool
        SafeCall(Toggle.Callback, Bool)
    end

    function Toggle:SetVisibility(Bool)
        Root.Visible = Bool
    end

    function Toggle:SetText(Text)
        Label.Text = tostring(Text)
    end

    function Toggle:Colorpicker(Data)
        Data = Data or { }

        return (Library:CreateColorpicker({
            Parent = Sub,
            Section = Toggle.Section,
            Flag = Data.Flag or Data.flag or Data.Name or Data.name or (Toggle.Flag .. "_color"),
            Default = Data.Default or Data.default or Color3.new(1, 1, 1),
            Alpha = Data.Alpha or Data.alpha or 0,
            Callback = Data.Callback or Data.callback or function() end,
        }))
    end

    function Toggle:Keybind(Data)
        Data = Data or { }

        return (Library:CreateKeybind({
            Parent = Sub,
            Name = Data.Name or Data.name or Toggle.Name,
            Section = Toggle.Section,
            Toggle = Toggle,
            Flag = Data.Flag or Data.flag or Data.Name or Data.name or (Toggle.Flag .. "_bind"),
            Default = Data.Default or Data.default,
            Mode = Data.Mode or Data.mode or "Toggle",
            ShowInList = Data.ShowInList,
            Callback = Data.Callback or Data.callback or function() end,
        }))
    end

    function Toggle:Settings()
        local Content = New("Frame", {
            Parent = Root,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = Toggle.Value,
            LayoutOrder = 2,
        })
        New("UIPadding", { Parent = Content, PaddingLeft = UDim.new(0, 18) })
        New("UIListLayout", { Parent = Content, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

        local Settings = {
            IsOpen = Toggle.Value,
            Container = Content,
            Window = Toggle.Window,
            Page = Toggle.Page,
            Items = { Content = Wrap(Content) },
        }
        Settings.Section = Settings

        local SettingsFader = Fader(Content)

        function Settings:SetOpen(Bool)
            Settings.IsOpen = Bool
            SettingsFader:Set(Bool)
        end

        Toggle.SettingsItem = Settings
        return setmetatable(Settings, Library)
    end

    Connect(Row.MouseButton1Click, function()
        Toggle:Set(not Toggle.Value)
    end)

    Toggle:Set(Toggle.Default)

    SetFlags[Toggle.Flag] = function(Value)
        Toggle:Set(Value)
    end

    return setmetatable(Toggle, Library)
end
--#endregion

--#region Button
Library.Button = function(Self, Params)
    Params = Params or { }

    local Button = {
        Name = Params.Name or Params.name or "Button",
        Callback = Params.Callback or Params.callback or function() end,

        Window = Self.Window,
        Page = Self.Page,
        Section = Self.Section or Self,
        Items = { },
    }

    local Item = ButtonFrame(Self.Container, Button.Name, { LayoutOrder = NextOrder() }, "Section")

    Button.Items = { Button = Wrap(Item.Button), Text = Wrap(Item.Label) }

    function Button:Press()
        Item:Flash()
        SafeCall(Button.Callback)
    end

    function Button:SetVisibility(Bool)
        Item.Button.Visible = Bool
    end

    function Button:SetText(Text)
        Item.Label.Text = tostring(Text)
    end

    Connect(Item.Button.MouseButton1Click, function()
        Button:Press()
    end)

    return setmetatable(Button, Library)
end
--#endregion

--#region Slider
Library.Slider = function(Self, Params)
    Params = Params or { }

    local Slider = {
        Name = Params.Name or Params.name or "Slider",
        Flag = Params.Flag or Params.flag or Params.Name or Params.name or ("slider_" .. NextOrder()),
        Default = Params.Default or Params.default or 0,
        Min = Params.Min or Params.min or 0,
        Max = Params.Max or Params.max or 100,
        Decimals = Params.Decimals or Params.decimals or 1,
        Suffix = Params.Suffix or Params.suffix or "",
        Callback = Params.Callback or Params.callback or function() end,

        Window = Self.Window,
        Page = Self.Page,
        Section = Self.Section or Self,

        Value = nil,
        Sliding = false,
        Items = { },
    }

    local Root = New("Frame", {
        Parent = Self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(),
    })
    New("UIListLayout", { Parent = Root, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

    local Top = New("Frame", {
        Parent = Root,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 12),
        LayoutOrder = 1,
    })

    local Title = New("TextLabel", {
        Parent = Top,
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Slider.Name,
    })

    local ValueLabel = New("TextLabel", {
        Parent = Top,
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local Bar = New("TextButton", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 0,
        LayoutOrder = 2,
    })
    local BarStroke = Outline(Bar)

    local Fill = New("Frame", {
        Parent = Bar,
        Size = UDim2.fromScale(0, 1),
        BackgroundTransparency = 0,
    })
    New("UIGradient", { Parent = Fill, Rotation = -90, Color = ColorSequence.new(Color3.fromRGB(157, 158, 159), White) })
    local FillGlow = Glow(Fill)

    Slider.Items = {
        Slider = Wrap(Root),
        Text = Wrap(Title),
        RealSlider = Wrap(Bar),
        Accent = Wrap(Fill),
        Value = Wrap(ValueLabel),
    }

    local Hovered = false

    local function Paint(Instant)
        local Active = Hovered or Slider.Sliding

        Animate(Bar, { BackgroundColor3 = Theme.Field }, Instant)
        Animate(Fill, { BackgroundColor3 = Theme.Accent }, Instant)
        Animate(BarStroke, { Color = Active and Theme["Light Outline"] or Theme.Element }, Instant)
        Animate(Title, { TextColor3 = Active and Theme.Text or Theme["Dim Text"] }, Instant)
        Animate(ValueLabel, { TextColor3 = Slider.Sliding and Theme.Accent or Theme["Dim Text"] }, Instant)
        GlowTo(FillGlow, true, Instant, Slider.Sliding and 1.2 or 0.55)
    end
    Themed(function() Paint(true) end)

    Connect(Bar.MouseEnter, function() Hovered = true Paint() end)
    Connect(Bar.MouseLeave, function() Hovered = false Paint() end)

    function Slider:Set(Value)
        Value = tonumber(Value) or Slider.Min

        local NewValue = Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Decimals)
        local Changed = NewValue ~= Slider.Value
        Slider.Value = NewValue

        local Percent = (Slider.Max == Slider.Min) and 0 or (NewValue - Slider.Min) / (Slider.Max - Slider.Min)
        Tween(Fill, { Size = UDim2.fromScale(math.clamp(Percent, 0, 1), 1) }, 0.12)
        ValueLabel.Text = tostring(NewValue) .. Slider.Suffix

        Flags[Slider.Flag] = NewValue

        if Changed then
            SafeCall(Slider.Callback, NewValue)
        end
    end

    function Slider:SetVisibility(Bool)
        Root.Visible = Bool
    end

    function Slider:SetText(Text)
        Title.Text = tostring(Text)
    end

    function Slider:GetSize()
        local Percent = math.clamp((MouseAbs().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        return Slider.Min + (Slider.Max - Slider.Min) * Percent
    end

    Connect(Bar.InputBegan, function(Input)
        if IsClick(Input) then
            Slider.Sliding = true
            Paint()
            Slider:Set(Slider:GetSize())
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if Slider.Sliding and IsMove(Input) then
            Slider:Set(Slider:GetSize())
        end
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if IsClick(Input) and Slider.Sliding then
            Slider.Sliding = false
            Paint()
        end
    end)

    Slider:Set(Slider.Default)

    SetFlags[Slider.Flag] = function(Value)
        Slider:Set(Value)
    end

    return setmetatable(Slider, Library)
end
--#endregion

--#region Dropdown
Library.Dropdown = function(Self, Params)
    Params = Params or { }

    local Dropdown = {
        Name = Params.Name or Params.name,
        OptionItems = Params.Items or Params.items or { },
        Flag = Params.Flag or Params.flag or Params.Name or Params.name or ("dropdown_" .. NextOrder()),
        Default = Params.Default or Params.default or "",
        Callback = Params.Callback or Params.callback or function() end,
        Multi = Params.Multi or Params.multi or false,

        Window = Self.Window,
        Page = Self.Page,
        Section = Self.Section or Self,

        Value = nil,
        Options = { },
        IsOpen = false,
        Items = { },
    }

    if Dropdown.Multi then
        Dropdown.Value = { }
    end

    local Root = New("Frame", {
        Parent = Self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(),
    })
    New("UIListLayout", { Parent = Root, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

    local Title
    if Dropdown.Name then
        Title = New("TextLabel", {
            Parent = Root,
            Size = UDim2.new(1, 0, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = Dropdown.Name,
            LayoutOrder = 1,
        })
        Themed(function() Title.TextColor3 = Theme["Dim Text"] end)
    end

    local Box = New("TextButton", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 0,
        LayoutOrder = 2,
    })
    local BoxStroke = Outline(Box)
    local BoxGlow = Glow(Box)

    local ValueLabel = New("TextLabel", {
        Parent = Box,
        Position = UDim2.fromOffset(5, 0),
        Size = UDim2.new(1, -25, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = "...",
    })

    local Sign = New("TextLabel", {
        Parent = Box,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -2, 0, 0),
        Size = UDim2.new(0, 16, 1, 0),
        Text = "=",
    })

    local Popup = New("Frame", {
        Parent = Library.PopupHolder,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(100, 26),
    })
    Themed(function() Popup.BackgroundColor3 = Theme.Field end)
    Border(Popup, "Field Outline")
    Highlight(Popup, 2)

    local Scroll = New("ScrollingFrame", {
        Parent = Popup,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 2,
        Active = true,
    })
    Themed(function() Scroll.ScrollBarImageColor3 = Theme.Accent end)
    New("UIPadding", {
        Parent = Scroll,
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    })
    New("UIListLayout", { Parent = Scroll, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })

    local PopupFader = Fader(Popup, true)

    Dropdown.Items = {
        Dropdown = Wrap(Root),
        Text = Title and Wrap(Title) or nil,
        RealDropdown = Wrap(Box),
        Value = Wrap(ValueLabel),
        OptionHolder = Wrap(Popup),
        OptionScroll = Wrap(Scroll),
    }
    Dropdown.Holder = Dropdown.Items.OptionHolder

    local Hovered = false

    local function Paint(Instant)
        local Open = Dropdown.IsOpen

        Animate(Box, { BackgroundColor3 = Theme.Field }, Instant)
        Animate(BoxStroke, { Color = Open and Theme.Accent or (Hovered and Theme["Light Outline"] or Theme["Field Outline"]) }, Instant)
        Animate(ValueLabel, { TextColor3 = (Open or Hovered) and Theme.Text or Theme["Dim Text"] }, Instant)
        Animate(Sign, { Rotation = Open and 90 or 0, TextColor3 = Open and Theme.Accent or Theme["Dim Text"] }, Instant)
        GlowTo(BoxGlow, Open, Instant, 0.6)
    end
    Themed(function() Paint(true) end)

    Connect(Box.MouseEnter, function() Hovered = true Paint() end)
    Connect(Box.MouseLeave, function() Hovered = false Paint() end)

    local function OptionCount()
        local Count = 0
        for _ in Dropdown.Options do
            Count += 1
        end
        return Count
    end

    local function PopupHeight()
        return math.clamp(OptionCount() * 21 + 5, 26, 200)
    end

    local function ValueText()
        if Dropdown.Multi then
            return #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "..."
        end

        return Dropdown.Value or "..."
    end

    function Dropdown:Set(Value)
        if Dropdown.Multi then
            if type(Value) ~= "table" then
                return
            end

            Dropdown.Value = { }

            for _, Name in Value do
                if Dropdown.Options[Name] then
                    table.insert(Dropdown.Value, Name)
                end
            end

            for Name, OptionData in Dropdown.Options do
                OptionData.IsSelected = table.find(Dropdown.Value, Name) ~= nil
                OptionData:ToggleState(OptionData.IsSelected and "Active" or "Inactive")
            end
        else
            local Selected = Dropdown.Options[Value]
            if not Selected then
                return
            end

            Dropdown.Value = Value

            for _, OptionData in Dropdown.Options do
                OptionData.IsSelected = OptionData == Selected
                OptionData:ToggleState(OptionData.IsSelected and "Active" or "Inactive")
            end
        end

        Flags[Dropdown.Flag] = Dropdown.Value
        ValueLabel.Text = ValueText()
        SafeCall(Dropdown.Callback, Dropdown.Value)
    end

    function Dropdown:Add(Value)
        Value = tostring(Value)

        local OptionButton = New("TextButton", {
            Parent = Scroll,
            Size = UDim2.new(1, 0, 0, 16),
            LayoutOrder = NextOrder(),
        })

        local Marker = New("Frame", {
            Parent = OptionButton,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.fromOffset(2, 0),
            BackgroundTransparency = 0,
        })
        local MarkerGlow = Glow(Marker)

        local Text = New("TextLabel", {
            Parent = OptionButton,
            Position = UDim2.fromOffset(6, 0),
            Size = UDim2.new(1, -6, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = Value,
        })

        local OptionData = {
            Button = Wrap(OptionButton),
            Text = Wrap(Text),
            Name = Value,
            IsSelected = false,
            Hovered = false,
        }

        local function PaintOption(Instant)
            local On = OptionData.IsSelected

            Animate(Marker, { BackgroundColor3 = Theme.Accent, Size = UDim2.fromOffset(2, On and 10 or 0) }, Instant)
            Animate(Text, {
                Position = UDim2.fromOffset(On and 10 or 6, 0),
                TextColor3 = On and Theme.Accent or (OptionData.Hovered and Theme["Dim Text"] or Theme["Inactive Text"]),
            }, Instant)
            GlowTo(MarkerGlow, On, Instant)
        end
        Themed(function() PaintOption(true) end)

        function OptionData:ToggleState()
            PaintOption()
        end

        Connect(OptionButton.MouseEnter, function()
            OptionData.Hovered = true
            PaintOption()
        end)

        Connect(OptionButton.MouseLeave, function()
            OptionData.Hovered = false
            PaintOption()
        end)

        function OptionData:Set()
            OptionData.IsSelected = not OptionData.IsSelected

            if Dropdown.Multi then
                local Index = table.find(Dropdown.Value, OptionData.Name)

                if Index then
                    table.remove(Dropdown.Value, Index)
                else
                    table.insert(Dropdown.Value, OptionData.Name)
                end

                OptionData.IsSelected = not Index
                OptionData:ToggleState()
            else
                if OptionData.IsSelected then
                    Dropdown.Value = OptionData.Name

                    for _, Other in Dropdown.Options do
                        if Other ~= OptionData then
                            Other.IsSelected = false
                            Other:ToggleState()
                        end
                    end
                else
                    Dropdown.Value = nil
                end

                OptionData:ToggleState()
            end

            Flags[Dropdown.Flag] = Dropdown.Value
            ValueLabel.Text = ValueText()
            SafeCall(Dropdown.Callback, Dropdown.Value)

            if not Dropdown.Multi then
                Dropdown:SetOpen(false)
            end
        end

        Connect(OptionButton.MouseButton1Click, function()
            OptionData:Set()
        end)

        Dropdown.Options[Value] = OptionData

        if Dropdown.IsOpen then
            Dropdown:Reposition()
        end

        return OptionData
    end

    function Dropdown:Remove(Option)
        local OptionData = Dropdown.Options[Option]

        if OptionData then
            OptionData.Button.Instance:Destroy()
            Dropdown.Options[Option] = nil
        end
    end

    function Dropdown:Refresh(List)
        for Name in Dropdown.Options do
            Dropdown:Remove(Name)
        end

        for _, Value in List do
            Dropdown:Add(Value)
        end

        if Dropdown.IsOpen then
            Dropdown:Reposition()
        end
    end

    function Dropdown:SetText(Text)
        if Title then
            Title.Text = tostring(Text)
        end
    end

    function Dropdown:SetVisibility(Bool)
        Root.Visible = Bool
    end

    function Dropdown:Reposition()
        Popup.Size = UDim2.fromOffset(Box.AbsoluteSize.X, PopupHeight())
        PlaceBelow(Popup, Box, 5)
    end

    function Dropdown:SetOpen(Bool)
        Dropdown.IsOpen = Bool

        if Bool then
            Library:CloseAll(Dropdown)
            Dropdown:Reposition()
            Library.OpenFrames[Dropdown] = Dropdown
        else
            Library.OpenFrames[Dropdown] = nil
        end

        PopupFader:Set(Bool)
        Paint()
    end

    Connect(Box.MouseButton1Click, function()
        Dropdown:SetOpen(not Dropdown.IsOpen)
    end)

    Connect(UserInputService.InputBegan, function(Input)
        if IsClick(Input) and Dropdown.IsOpen and not IsMouseOver(Popup) and not IsMouseOver(Box) then
            Dropdown:SetOpen(false)
        end
    end)

    for _, Value in Dropdown.OptionItems do
        Dropdown:Add(Value)
    end

    if type(Dropdown.Default) == "number" and Dropdown.OptionItems[Dropdown.Default] then
        Dropdown.Default = Dropdown.OptionItems[Dropdown.Default]
    end

    Dropdown:Set(Dropdown.Default)

    SetFlags[Dropdown.Flag] = function(Value)
        Dropdown:Set(Value)
    end

    return setmetatable(Dropdown, Library)
end
--#endregion

--#region Label
Library.Label = function(Self, Params)
    Params = Params or { }

    local Label = {
        Name = Params.Name or Params.name or "Label",

        Window = Self.Window,
        Page = Self.Page,
        Section = Self.Section or Self,
        Items = { },
    }

    local Row = New("Frame", {
        Parent = Self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 12),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(),
    })

    local Text = New("TextLabel", {
        Parent = Row,
        Size = UDim2.new(1, 0, 0, 12),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        RichText = true,
        Text = Label.Name,
    })
    Themed(function() Text.TextColor3 = Theme["Dim Text"] end)

    local Sub = New("Frame", {
        Parent = Row,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 12),
        AutomaticSize = Enum.AutomaticSize.X,
    })
    New("UIListLayout", {
        Parent = Sub,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    Label.Items = { Label = Wrap(Row), Text = Wrap(Text), SubElements = Wrap(Sub) }

    function Label:SetVisibility(Bool)
        Row.Visible = Bool
    end

    function Label:SetText(NewText)
        Text.Text = tostring(NewText)
    end

    function Label:Colorpicker(Data)
        Data = Data or { }

        return (Library:CreateColorpicker({
            Parent = Sub,
            Section = Label.Section,
            Flag = Data.Flag or Data.flag or Data.Name or Data.name or Label.Name,
            Default = Data.Default or Data.default or Color3.new(1, 1, 1),
            Alpha = Data.Alpha or Data.alpha or 0,
            Callback = Data.Callback or Data.callback or function() end,
        }))
    end

    function Label:Keybind(Data)
        Data = Data or { }

        return (Library:CreateKeybind({
            Parent = Sub,
            Name = Data.Name or Data.name or Label.Name,
            Section = Label.Section,
            Flag = Data.Flag or Data.flag or Data.Name or Data.name or Label.Name,
            Default = Data.Default or Data.default,
            Mode = Data.Mode or Data.mode or "Toggle",
            ShowInList = Data.ShowInList,
            Callback = Data.Callback or Data.callback or function() end,
        }))
    end

    return setmetatable(Label, Library)
end
--#endregion

--#region Textbox
Library.Textbox = function(Self, Params)
    Params = Params or { }

    local Textbox = {
        Name = Params.Name or Params.name,
        Flag = Params.Flag or Params.flag or Params.Name or Params.name or ("textbox_" .. NextOrder()),
        Default = Params.Default or Params.default or "",
        Callback = Params.Callback or Params.callback or function() end,
        Finished = Params.Finished or Params.finished or false,
        Placeholder = Params.Placeholder or Params.placeholder or "",
        Numeric = Params.Numeric or Params.numeric or false,

        Window = Self.Window,
        Page = Self.Page,
        Section = Self.Section or Self,

        Value = "",
        Items = { },
    }

    local Root = New("Frame", {
        Parent = Self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(),
    })
    New("UIListLayout", { Parent = Root, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

    local Title
    if Textbox.Name then
        Title = New("TextLabel", {
            Parent = Root,
            Size = UDim2.new(1, 0, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = Textbox.Name,
            LayoutOrder = 1,
        })
        Themed(function() Title.TextColor3 = Theme["Dim Text"] end)
    end

    local Frame = New("Frame", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 0,
        LayoutOrder = 2,
    })
    local FrameStroke = Outline(Frame)
    local FrameGlow = Glow(Frame)

    local Input = New("TextBox", {
        Parent = Frame,
        Position = UDim2.fromOffset(5, 0),
        Size = UDim2.new(1, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        PlaceholderText = Textbox.Placeholder,
        Text = "",
    })

    Textbox.Items = { Textbox = Wrap(Root), Text = Title and Wrap(Title) or nil, Input = Wrap(Input) }

    local Focused, Hovered = false, false

    local function Paint(Instant)
        Animate(Frame, { BackgroundColor3 = Theme.Field }, Instant)
        Animate(FrameStroke, { Color = Focused and Theme.Accent or (Hovered and Theme["Light Outline"] or Theme["Field Outline"]) }, Instant)
        Animate(Input, { TextColor3 = Focused and Theme.Text or Theme["Dim Text"], PlaceholderColor3 = Theme["Inactive Text"] }, Instant)
        GlowTo(FrameGlow, Focused, Instant, 0.6)
    end
    Themed(function() Paint(true) end)

    Connect(Frame.MouseEnter, function() Hovered = true Paint() end)
    Connect(Frame.MouseLeave, function() Hovered = false Paint() end)
    Connect(Input.Focused, function() Focused = true Paint() end)
    Connect(Input.FocusLost, function() Focused = false Paint() end)

    function Textbox:Set(Value)
        Value = tostring(Value or "")

        if Textbox.Numeric then
            Value = Value:gsub("[^%d%.%-]", "")
        end

        Textbox.Value = Value
        if Input.Text ~= Value then
            Input.Text = Value
        end

        Flags[Textbox.Flag] = Value
        SafeCall(Textbox.Callback, Value)
    end

    function Textbox:SetVisibility(Bool)
        Root.Visible = Bool
    end

    function Textbox:SetText(Text)
        if Title then
            Title.Text = tostring(Text)
        end
    end

    if Textbox.Finished then
        Connect(Input.FocusLost, function()
            Textbox:Set(Input.Text)
        end)
    else
        Connect(Input:GetPropertyChangedSignal("Text"), function()
            if Input.Text ~= Textbox.Value then
                Textbox:Set(Input.Text)
            end
        end)
    end

    Textbox:Set(Textbox.Default)

    SetFlags[Textbox.Flag] = function(Value)
        Textbox:Set(Value)
    end

    return setmetatable(Textbox, Library)
end
--#endregion

--#region InitWindow
local function ConfigPath(Name)
    return ConfigsFolder .. "/" .. Name .. ".json"
end

local function BuildConfigWindow(Window)
    local WindowSize = Window.Size

    local Frame = New("Frame", {
        Parent = Library.Holder,
        Size = UDim2.fromOffset(230, 273),
        Position = UDim2.new(0.5, WindowSize.X.Offset / 2 + 16, 0.5, -WindowSize.Y.Offset / 2),
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Window end)
    Border(Frame, nil, true)
    Shade(Frame, -90, Color3.fromRGB(91, 90, 91), White)
    Highlight(Frame, 2)
    New("UIShadow", {
        Parent = Frame,
        Color = Black,
        Transparency = 0.4,
        BlurRadius = UDim.new(0, 20),
        Offset = UDim2.fromOffset(0, 4),
    })

    local Title = New("TextLabel", {
        Parent = Frame,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -14, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "config",
    })
    Draggable(Title, Frame, "Config")

    local ListFrame = New("Frame", {
        Parent = Frame,
        Position = UDim2.fromOffset(10, 25),
        Size = UDim2.new(1, -20, 0, 150),
        BackgroundTransparency = 0,
    })
    Themed(function() ListFrame.BackgroundColor3 = Theme.Inner end)
    Border(ListFrame)

    local Scroll = New("ScrollingFrame", {
        Parent = ListFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 2,
        Active = true,
    })
    Themed(function() Scroll.ScrollBarImageColor3 = Theme.Accent end)
    New("UIPadding", {
        Parent = Scroll,
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
    })
    New("UIListLayout", { Parent = Scroll, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

    local NameFrame = New("Frame", {
        Parent = Frame,
        Position = UDim2.fromOffset(10, 185),
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 0,
    })
    Themed(function() NameFrame.BackgroundColor3 = Theme.Field end)
    local NameStroke = Outline(NameFrame)
    local NameGlow = Glow(NameFrame)

    local NameBox = New("TextBox", {
        Parent = NameFrame,
        Position = UDim2.fromOffset(5, 0),
        Size = UDim2.new(1, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        PlaceholderText = "config name...",
        Text = "",
    })

    local Typing = false

    local function PaintName(Instant)
        Animate(NameStroke, { Color = Typing and Theme.Accent or Theme["Field Outline"] }, Instant)
        NameBox.PlaceholderColor3 = Theme["Inactive Text"]
        GlowTo(NameGlow, Typing, Instant, 0.6)
    end
    Themed(function() PaintName(true) end)

    Connect(NameBox.Focused, function() Typing = true PaintName() end)
    Connect(NameBox.FocusLost, function() Typing = false PaintName() end)

    local SaveButton = ButtonFrame(Frame, "save", { Position = UDim2.fromOffset(10, 213), Size = UDim2.new(0.5, -14, 0, 20) }, "Window")
    local DeleteButton = ButtonFrame(Frame, "delete", { Position = UDim2.new(0.5, 4, 0, 213), Size = UDim2.new(0.5, -14, 0, 20) }, "Window")
    local LoadButton = ButtonFrame(Frame, "load", { Position = UDim2.fromOffset(10, 241), Size = UDim2.new(0.5, -14, 0, 20) }, "Window")
    local AutoButton = ButtonFrame(Frame, "set autoload", { Position = UDim2.new(0.5, 4, 0, 241), Size = UDim2.new(0.5, -14, 0, 20) }, "Window")

    local Selected = nil
    local Rows = { }

    local function Paint(Instant)
        local Autoload = Library:GetAutoload()

        for Name, Row in Rows do
            local IsSelected = Name == Selected

            Row.Label.Text = Name .. (Name == Autoload and " [auto]" or "")
            Animate(Row.Label, {
                Position = UDim2.fromOffset(IsSelected and 6 or 2, 0),
                TextColor3 = IsSelected and Theme.Accent or Theme["Inactive Text"],
            }, Instant)
            Animate(Row.Marker, { BackgroundColor3 = Theme.Accent, Size = UDim2.fromOffset(2, IsSelected and 10 or 0) }, Instant)
        end

        AutoButton.Label.Text = (Selected and Selected == Autoload) and "clear autoload" or "set autoload"
    end
    Themed(function() Paint(true) end)

    local function Refresh()
        for _, Row in Rows do
            Row.Button:Destroy()
        end
        table.clear(Rows)

        local List = Library:GetConfigsList()

        if Selected and not table.find(List, Selected) then
            Selected = nil
        end

        for _, Name in List do
            local Button = New("TextButton", {
                Parent = Scroll,
                Size = UDim2.new(1, 0, 0, 14),
                LayoutOrder = NextOrder(),
            })

            local Marker = New("Frame", {
                Parent = Button,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(2, 0),
                BackgroundTransparency = 0,
            })

            local Label = New("TextLabel", {
                Parent = Button,
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -6, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = Name,
            })

            Rows[Name] = { Button = Button, Label = Label, Marker = Marker }

            Connect(Button.MouseButton1Click, function()
                Selected = Selected ~= Name and Name or nil

                if Selected then
                    NameBox.Text = Name
                end

                Paint()
            end)
        end

        Paint(true)
    end

    local function Sanitize(Text)
        return (Text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[\\/:%*%?\"<>|]", ""))
    end

    Connect(SaveButton.Button.MouseButton1Click, function()
        SaveButton:Flash()

        local Name = Sanitize(NameBox.Text)
        if Name == "" then
            Name = Selected
        end

        if not Name or Name == "" then
            Library:Notification({ Name = "enter a config name", Time = 3 })
            return
        end

        writefile(ConfigPath(Name), Library:GetConfig())

        Selected = Name
        Refresh()
        Library:Notification({ Name = "saved config " .. Name, Time = 3 })
    end)

    Connect(DeleteButton.Button.MouseButton1Click, function()
        DeleteButton:Flash()

        if not Selected then
            Library:Notification({ Name = "select a config first", Time = 3 })
            return
        end

        local Name = Selected
        if isfile(ConfigPath(Name)) then
            delfile(ConfigPath(Name))
        end

        if Library:GetAutoload() == Name then
            Library:SetAutoload(nil)
        end

        Selected = nil
        NameBox.Text = ""
        Refresh()
        Library:Notification({ Name = "deleted config " .. Name, Time = 3 })
    end)

    Connect(LoadButton.Button.MouseButton1Click, function()
        LoadButton:Flash()

        if not Selected then
            Library:Notification({ Name = "select a config first", Time = 3 })
            return
        end

        if not isfile(ConfigPath(Selected)) then
            Refresh()
            return
        end

        local Ok, Error = Library:LoadConfig(readfile(ConfigPath(Selected)))

        if Ok then
            Library:Notification({ Name = "loaded config " .. Selected, Time = 3 })
        else
            Library:Notification({ Name = "failed to load config: " .. tostring(Error), Time = 3 })
        end
    end)

    Connect(AutoButton.Button.MouseButton1Click, function()
        AutoButton:Flash()

        if not Selected then
            Library:Notification({ Name = "select a config first", Time = 3 })
            return
        end

        if Library:GetAutoload() == Selected then
            Library:SetAutoload(nil)
            Library:Notification({ Name = "cleared autoload", Time = 3 })
        else
            Library:SetAutoload(Selected)
            Library:Notification({ Name = Selected .. " will now autoload", Time = 3 })
        end

        Paint()
    end)

    Refresh()

    Frame.Visible = Library.MenuOpen
    local Entry = { Frame = Frame, Enabled = true, Fader = Fader(Frame, true, "Window") }
    table.insert(Library.Floating, Entry)

    return {
        Items = { Window = Wrap(Frame), List = Wrap(Scroll), Name = Wrap(NameBox) },
        Refresh = Refresh,
        SetVisibility = function(_, Bool)
            Entry.Enabled = Bool
            Entry.Fader:Set(Bool and Library.MenuOpen)
        end,
    }
end

Library.InitWindow = function(Self)
    local Window = Self.Window or Self

    Library.ConfigWindow = BuildConfigWindow(Window)

    local SettingsPage = Window:Page({ Name = "Settings" })

    local MenuSection = SettingsPage:Section({ Name = "Menu", Side = 1 }) do
        MenuSection:Label({ Name = "menu bind" }):Keybind({
            Name = "menu bind",
            Flag = "uibind",
            Mode = "Toggle",
            Default = Enum.KeyCode.RightShift,
            ShowInList = false,
            Callback = function()
                if Flags["uibind"] and Flags["uibind"].Key ~= "None" then
                    Library.MenuKeybind = Flags["uibind"].Key
                end
            end
        })

        MenuSection:Toggle({
            Name = "config window",
            Flag = "ui_configwindow",
            Default = true,
            Callback = function(Value)
                Library.ConfigWindow:SetVisibility(Value)
            end
        })

        if Library.WatermarkObject then
            MenuSection:Toggle({
                Name = "watermark",
                Flag = "ui_watermark",
                Default = true,
                Callback = function(Value)
                    Library.WatermarkObject:SetVisibility(Value)
                end
            })
        end

        if Library.KeyList then
            MenuSection:Toggle({
                Name = "keybind list",
                Flag = "ui_keybindlist",
                Default = true,
                Callback = function(Value)
                    Library.KeyList:SetVisibility(Value)
                end
            })
        end

        MenuSection:Dropdown({
            Name = "animation style",
            Flag = "ui_animstyle",
            Items = { "Linear", "Quad", "Quart", "Back", "Circular", "Cubic", "Exponential", "Sine", "Quint" },
            Default = Library.Animation.Style,
            Callback = function(Value)
                if Value then
                    Library.Animation.Style = Value
                end
            end
        })

        MenuSection:Slider({
            Name = "animation time",
            Flag = "ui_animtime",
            Min = 0,
            Max = 1,
            Default = Library.Animation.Time,
            Decimals = 0.01,
            Suffix = "s",
            Callback = function(Value)
                Library.Animation.Time = Value
            end
        })

        MenuSection:Slider({
            Name = "fade time",
            Flag = "ui_fadetime",
            Min = 0,
            Max = 1.5,
            Default = Library.Animation.FadeTime,
            Decimals = 0.01,
            Suffix = "s",
            Callback = function(Value)
                Library.Animation.FadeTime = Value
            end
        })

        MenuSection:Button({
            Name = "center window",
            Callback = function()
                Window:Center()
            end
        })

        MenuSection:Button({
            Name = "unload",
            Callback = function()
                Library:Exit()
            end
        })
    end

    local EffectsSection = SettingsPage:Section({ Name = "Effects", Side = 1 }) do
        EffectsSection:Toggle({
            Name = "accent glow",
            Flag = "ui_glow",
            Default = Library.Glow.Enabled,
            Callback = function(Value)
                Library.Glow.Enabled = Value
                Library:Refresh()
            end
        })

        EffectsSection:Slider({
            Name = "glow strength",
            Flag = "ui_glowstrength",
            Min = 0,
            Max = 1,
            Default = Library.Glow.Strength,
            Decimals = 0.01,
            Callback = function(Value)
                Library.Glow.Strength = Value
                Library:Refresh()
            end
        })

        EffectsSection:Slider({
            Name = "glow size",
            Flag = "ui_glowsize",
            Min = 2,
            Max = 24,
            Default = Library.Glow.Size,
            Decimals = 1,
            Suffix = "px",
            Callback = function(Value)
                Library.Glow.Size = Value
                Library:Refresh()
            end
        })

        EffectsSection:Toggle({
            Name = "background blur",
            Flag = "ui_blur",
            Default = Library.BlurEnabled,
            Callback = function(Value)
                Library.BlurEnabled = Value
                Library:UpdateEffects()
            end
        })

        EffectsSection:Slider({
            Name = "blur size",
            Flag = "ui_blursize",
            Min = 1,
            Max = 56,
            Default = Library.BlurSize,
            Decimals = 1,
            Callback = function(Value)
                Library.BlurSize = Value
                Library:UpdateEffects()
            end
        })
    end

    local ThemeSection = SettingsPage:Section({ Name = "Theme", Side = 2 }) do
        local Keys = { }
        for Key in Theme do
            if Key ~= "Accent" then
                table.insert(Keys, Key)
            end
        end
        table.sort(Keys)
        table.insert(Keys, 1, "Accent")

        for _, Key in Keys do
            ThemeSection:Label({ Name = Key:lower() }):Colorpicker({
                Name = Key,
                Flag = "theme_" .. Key,
                Default = Theme[Key],
                Callback = function(Value)
                    Library:ChangeTheme(Key, Value)
                end
            })
        end
    end

    local Autoload = Library:GetAutoload()

    if Autoload and isfile(ConfigPath(Autoload)) then
        local Ok, Error = Library:LoadConfig(readfile(ConfigPath(Autoload)))

        Library:Notification({
            Name = Ok and ("autoloaded config " .. Autoload) or ("failed to autoload: " .. tostring(Error)),
            Time = 3,
        })
    end
end
--#endregion

getgenv().DescendantLibrary = Library
return Library

