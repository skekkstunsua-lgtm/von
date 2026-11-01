if getgenv().VergilLibrary and type(getgenv().VergilLibrary) == "table" and getgenv().VergilLibrary.Exit then
    getgenv().VergilLibrary:Exit()
end

cloneref = cloneref or function(Object) return Object end

--#region Services
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
local Lighting = cloneref(game:GetService("Lighting"))
local CoreGui = cloneref(game:GetService("CoreGui"))
--#endregion

local GetHui = gethui or function() return CoreGui end
local LocalPlayer = Players.LocalPlayer

Library = {
    Flags = { },
    SetFlags = { },
    MenuKeybind = tostring(Enum.KeyCode.RightShift),

    Directory = "Vergil",
    Folders = {
        Assets = "/Assets",
        Configs = "/Configs"
    },

    Name = "Vergil",
    FontSize = 12,
    FontUrl = "https://github.com/bluescan/proggyfonts/raw/master/ProggyOriginal/ProggyClean.ttf",

    Animation = {
        Time = 0.2,
        Style = "Quart",
        Direction = "Out",

        FadeTime = 0.4,
        FadeStyle = "Sine",
    },

    BlurEnabled = true,
    BlurSize = 12,
    SnowEnabled = true,
    SnowAmount = 90,

    Theme = {
        ["Background"]     = Color3.fromRGB(24, 24, 24),
        ["Window"]         = Color3.fromRGB(21, 21, 21),
        ["Hover"]          = Color3.fromRGB(32, 32, 32),
        ["Border"]         = Color3.fromRGB(36, 36, 35),
        ["Outline"]        = Color3.fromRGB(41, 41, 41),
        ["Button Outline"] = Color3.fromRGB(66, 66, 66),
        ["Text"]           = Color3.fromRGB(255, 255, 255),
        ["Dim Text"]       = Color3.fromRGB(175, 175, 175),
        ["Inactive Text"]  = Color3.fromRGB(121, 121, 120),
        ["Option Text"]    = Color3.fromRGB(113, 114, 115),
        ["Accent"]         = Color3.fromRGB(176, 188, 240),
        ["Element Accent"] = Color3.fromRGB(113, 119, 138),
    },

    Connections = { },
    Threads = { },
    Themed = { },
    OpenFrames = { },
    Floating = { },
    Landing = { },
    ShadowWanted = { },
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

--#region Helpers
local StrokeInner = Enum.BorderStrokePosition.Inner

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
        warn("[Vergil] callback error: " .. tostring(Result))
    end

    return Ok, Result
end

local function Tween(Object, Properties, Time)
    local Info = TweenInfo.new(
        Time or Library.Animation.Time,
        Enum.EasingStyle[Library.Animation.Style] or Enum.EasingStyle.Quart,
        Enum.EasingDirection[Library.Animation.Direction] or Enum.EasingDirection.Out
    )

    local NewTween = TweenService:Create(Object, Info, Properties)
    NewTween:Play()
    return NewTween
end

local function Glide(Item, Key, Properties, Instant)
    local Running = Item.Tweens[Key]

    if Running then
        Running:Cancel()
        Item.Tweens[Key] = nil
    end

    if Instant then
        for Property, Value in Properties do
            Item.Frame[Property] = Value
        end

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
            if Library.ShadowWanted[Shadow] ~= false then
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
            Scale.Scale = 0.97 + 0.03 * Alpha
        end
    end

    Connect(Driver.Changed, function(Alpha)
        if Fade.Snapshot then
            Apply(Alpha)
        end
    end)

    local function Settle()
        Fade.Tween = nil

        if Fade.Open then
            if Fade.Snapshot then
                Apply(1)
            end
            Fade.Snapshot = nil
            RestoreShadows()
        else
            Root.Visible = false
        end
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

local function AccentSequence(Base)
    local Accent = Theme.Accent
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0, Base),
        ColorSequenceKeypoint.new(0.25, Accent),
        ColorSequenceKeypoint.new(0.5, Base),
        ColorSequenceKeypoint.new(0.75, Accent),
        ColorSequenceKeypoint.new(1, Base),
    }
end

local function Outline(Parent, ColorKey, Thick)
    local Inner = New("UIStroke", {
        Parent = Parent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        BorderStrokePosition = StrokeInner,
        ZIndex = 2,
    })
    Themed(function() Inner.Color = Theme[ColorKey or "Outline"] end)

    New("UIStroke", {
        Parent = Parent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Color = Color3.new(0, 0, 0),
        Thickness = Thick and 2 or 1,
        BorderOffset = UDim.new(0, 1),
        BorderStrokePosition = StrokeInner,
    })

    return Inner
end

local function Shade(Parent, Rotation, From, To)
    return New("UIGradient", {
        Parent = Parent,
        Rotation = Rotation or 90,
        Color = ColorSequence.new(From or Color3.new(1, 1, 1), To or Color3.fromRGB(201, 201, 201)),
    })
end

local function Highlight(Parent, BaseKey, Position, Size)
    local Line = New("Frame", {
        Parent = Parent,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = Position or UDim2.new(0, 0, 0, 0),
        Size = Size or UDim2.new(1, 0, 0, 1),
        ZIndex = 3,
    })

    local Gradient = New("UIGradient", { Parent = Line })
    Themed(function()
        Gradient.Color = AccentSequence((Theme[BaseKey] or Theme.Background):Lerp(Color3.new(0, 0, 0), 0.2))
    end)

    return Line
end

local function TitleGradient(Label, Rotation)
    local Gradient = New("UIGradient", { Parent = Label, Rotation = Rotation or 0 })
    Themed(function() Gradient.Color = AccentSequence(Color3.new(1, 1, 1)) end)
    return Gradient
end

local function MainGradient(Label)
    local Gradient = New("UIGradient", { Parent = Label })
    Themed(function()
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 249, 255)),
            ColorSequenceKeypoint.new(0.128, Color3.fromRGB(135, 140, 160)),
            ColorSequenceKeypoint.new(0.233, Color3.fromRGB(102, 109, 132)),
            ColorSequenceKeypoint.new(0.597, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.Accent),
        }
    end)
    return Gradient
end

local function Draggable(Handle, Target)
    local Dragging, DragStart, StartPosition = false, nil, nil

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
            Target.Position = UDim2.new(
                StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
            )
        end
    end)
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

Library.ChangeTheme = function(Self, Key, Color)
    Theme[Key] = Color

    for _, Function in Library.Themed do
        Function()
    end
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
        task.cancel(Thread)
    end

    Library.Holder:Destroy()
    Library.PopupHolder:Destroy()
    Library.DragHolder:Destroy()
    Library.SnowHolder:Destroy()
    Library.Blur:Destroy()

    Library.Unloaded = true
    getgenv().VergilLibrary = nil
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

    return HttpService:JSONEncode(Config)
end

Library.LoadConfig = function(Self, Config)
    local Ok, Result = pcall(function()
        local Decoded = HttpService:JSONDecode(Config)

        for Index, Value in Decoded do
            local SetFunction = Library.SetFlags[Index]

            if SetFunction then
                if type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
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

    warn("[Vergil] ProggyClean failed to load, using Code font: " .. tostring(Result))
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
    Parent = Library.Holder,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -12, 1, -12),
    Size = UDim2.new(0, 400, 1, -24),
})

New("UIListLayout", {
    Parent = Library.NotifHolder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4),
})

Connect(RunService.RenderStepped, function()
    for _, Frame in Library.OpenFrames do
        if Frame.Reposition then
            Frame:Reposition()
        end
    end
end)
--#endregion

--#region Effects
Library.Blur = New("BlurEffect", { Parent = Lighting, Size = 0 })

Library.SnowHolder = New("ScreenGui", {
    Parent = GetHui(),
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 99,
})

local SnowFrame = New("Frame", {
    Parent = Library.SnowHolder,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Visible = false,
})

local SnowAlpha = Instance.new("NumberValue")
local Flakes = { }

local function Viewport()
    local Size = SnowFrame.AbsoluteSize
    if Size.X < 1 then
        Size = workspace.CurrentCamera.ViewportSize
    end
    return Size
end

local function NewFlake()
    local Size = Viewport()
    local Pixels = math.random(1, 3)

    return {
        Frame = New("Frame", {
            Parent = SnowFrame,
            Size = UDim2.fromOffset(Pixels, Pixels),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
        }),
        X = math.random() * Size.X,
        Y = math.random() * Size.Y,
        Speed = 15 + Pixels * 15 + math.random() * 15,
        Drift = math.random(-8, 8),
        Sway = 0.5 + math.random(),
        Phase = math.random() * math.pi * 2,
        Opacity = 0.35 + math.random() * 0.55,
    }
end

Library.SetSnowAmount = function(Self, Amount)
    Amount = math.floor(Amount)
    Library.SnowAmount = Amount

    while #Flakes < Amount do
        table.insert(Flakes, NewFlake())
    end

    while #Flakes > Amount do
        table.remove(Flakes).Frame:Destroy()
    end
end

Library.UpdateEffects = function(Self)
    local Open = Library.MenuOpen

    TweenService:Create(Library.Blur, FadeInfo("Window"), { Size = (Open and Library.BlurEnabled) and Library.BlurSize or 0 }):Play()
    TweenService:Create(SnowAlpha, FadeInfo("Window"), { Value = (Open and Library.SnowEnabled) and 1 or 0 }):Play()
end

local Clock = 0

Connect(RunService.RenderStepped, function(Delta)
    local Alpha = SnowAlpha.Value

    SnowFrame.Visible = Alpha > 0.001
    if not SnowFrame.Visible then
        return
    end

    Clock += Delta
    local Size = Viewport()

    for _, Flake in Flakes do
        Flake.Y += Flake.Speed * Delta
        Flake.X += (Flake.Drift + math.sin(Clock * Flake.Sway + Flake.Phase) * 12) * Delta

        if Flake.Y > Size.Y + 4 then
            Flake.Y = -4
            Flake.X = math.random() * Size.X
        end

        if Flake.X < -4 then
            Flake.X += Size.X + 8
        elseif Flake.X > Size.X + 4 then
            Flake.X -= Size.X + 8
        end

        Flake.Frame.Position = UDim2.fromOffset(Flake.X, Flake.Y)
        Flake.Frame.BackgroundTransparency = 1 - Flake.Opacity * Alpha
    end
end)

Library:SetSnowAmount(Library.SnowAmount)
--#endregion

--#region Notification
Library.Notification = function(Self, Params)
    Params = Params or { }

    local Text = Params.Name or Params.name or Params.Text or "notification"
    local Time = Params.Time or Params.time or 3

    local Label = New("TextLabel", {
        Parent = Library.NotifHolder,
        RichText = true,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTransparency = 1,
        TextStrokeTransparency = 1,
        LayoutOrder = NextOrder(),
        Text = string.format('[<font color="%s">%s</font>] %s', ToRichColor(Theme["Element Accent"]), Library.Name, tostring(Text)),
    })

    Tween(Label, { TextTransparency = 0, TextStrokeTransparency = 0 })

    task.delay(Time, function()
        local Out = Tween(Label, { TextTransparency = 1, TextStrokeTransparency = 1 })
        Out.Completed:Wait()
        Label:Destroy()
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
        Size = UDim2.new(1, -4, 0, Instant and Height or 0),
    })

    local Stroke = New("UIStroke", {
        Parent = Frame,
        Color = Theme.Accent,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        BorderStrokePosition = StrokeInner,
    })

    Tween(Frame, { BackgroundTransparency = 0.86, Size = UDim2.new(1, -4, 0, Height) })
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
        Goal.Size = UDim2.new(1, -4, 0, 0)
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
        Size = Vector2.new(Drag.Column.Scroll.AbsoluteSize.X - 4, Section.Height)
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
        BackgroundColor3 = Color3.new(1, 1, 1),
        LayoutOrder = NextOrder(),
    })
    Outline(Swatch)

    local Popup = New("TextButton", {
        Parent = Library.PopupHolder,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(190, 180),
    })
    Themed(function() Popup.BackgroundColor3 = Theme.Window end)
    Outline(Popup, "Border")
    Highlight(Popup, "Window")

    local Palette = New("TextButton", {
        Parent = Popup,
        BackgroundTransparency = 0,
        Position = UDim2.fromOffset(6, 7),
        Size = UDim2.new(1, -32, 1, -33),
    })
    Outline(Palette)

    local SaturationOverlay = New("Frame", {
        Parent = Palette,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
    })
    New("UIGradient", { Parent = SaturationOverlay, Transparency = NumberSequence.new(0, 1) })

    local ValueOverlay = New("Frame", {
        Parent = Palette,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        ZIndex = 2,
    })
    New("UIGradient", { Parent = ValueOverlay, Rotation = 90, Transparency = NumberSequence.new(1, 0) })

    local PaletteDragger = New("Frame", {
        Parent = Palette,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 3,
    })
    New("UIStroke", { Parent = PaletteDragger, Color = Color3.new(0, 0, 0) })

    local HueBar = New("TextButton", {
        Parent = Popup,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -6, 0, 7),
        Size = UDim2.new(0, 14, 1, -33),
    })
    Outline(HueBar)
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
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2,
    })
    New("UIStroke", { Parent = HueDragger, Color = Color3.new(0, 0, 0) })

    local AlphaBack = New("ImageLabel", {
        Parent = Popup,
        Position = UDim2.new(0, 6, 1, -20),
        Size = UDim2.new(1, -32, 0, 14),
        BackgroundTransparency = 1,
        Image = "rbxassetid://18274452449",
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(6, 6),
    })
    Outline(AlphaBack)

    local AlphaBar = New("TextButton", {
        Parent = AlphaBack,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1, 1),
    })
    New("UIGradient", { Parent = AlphaBar, Transparency = NumberSequence.new(0, 1) })

    local AlphaDragger = New("Frame", {
        Parent = AlphaBar,
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2,
    })
    New("UIStroke", { Parent = AlphaDragger, Color = Color3.new(0, 0, 0) })

    local Preview = New("Frame", {
        Parent = Popup,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -6, 1, -6),
        Size = UDim2.fromOffset(14, 14),
    })
    Outline(Preview)

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
            Popup.Visible = true
            Colorpicker:Reposition()
            Library.OpenFrames[Colorpicker] = Colorpicker
        else
            Popup.Visible = false
            Library.OpenFrames[Colorpicker] = nil
        end
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

    local function Paint()
        KeyButton.TextColor3 = Keybind.Picking and Theme.Text or Theme["Dim Text"]
    end
    Themed(Paint)

    local ModePopup = New("Frame", {
        Parent = Library.PopupHolder,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(70, 3 * 16 + 2 * 3 + 10),
    })
    Themed(function() ModePopup.BackgroundColor3 = Theme.Window end)
    Outline(ModePopup)
    New("UIPadding", { Parent = ModePopup, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) })
    New("UIListLayout", { Parent = ModePopup, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })

    local ModeButtons = { }

    local function PaintModes()
        for Mode, Button in ModeButtons do
            Button.TextColor3 = (Keybind.Mode == Mode) and Theme.Text or Theme["Option Text"]
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
            ModePopup.Visible = true
            Keybind:Reposition()
            Library.OpenFrames[Keybind] = Keybind
        else
            ModePopup.Visible = false
            Library.OpenFrames[Keybind] = nil
        end
    end

    for Index, Mode in { "Toggle", "Hold", "Always" } do
        local Button = New("TextButton", {
            Parent = ModePopup,
            Size = UDim2.new(1, 0, 0, 16),
            Text = Mode:lower(),
            LayoutOrder = Index,
        })

        ModeButtons[Mode] = Button

        Connect(Button.MouseButton1Click, function()
            Keybind.Mode = Mode
            Keybind:SetMode()

            if Mode == "Always" then
                Keybind:Press(true)
            end

            Keybind:SetOpen(false)
        end)
    end

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
        Items = { },
    }

    local Frame = New("Frame", {
        Parent = Library.Holder,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 12),
        Size = UDim2.new(0, 0, 0, 26),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Window end)
    Outline(Frame)
    Shade(Frame, -90)
    New("UIPadding", { Parent = Frame, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
    Highlight(Frame, "Window", UDim2.new(0, -6, 0, 0), UDim2.new(1, 12, 0, 1))

    local Label = New("TextLabel", {
        Parent = Frame,
        RichText = true,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
    })

    New("UIGradient", {
        Parent = Label,
        Rotation = 18,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(239, 241, 249)),
            ColorSequenceKeypoint.new(0.483, Color3.fromRGB(169, 178, 223)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(186, 190, 210)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(201, 201, 201)),
        }
    })

    Draggable(Frame, Frame)

    Watermark.Items = { Watermark = Wrap(Frame), Text = Wrap(Label) }
    local WatermarkFader = Fader(Frame, false, "Window")

    local function Render()
        local Parts = { Watermark.Name }

        if Watermark.SubName and Watermark.SubName ~= Watermark.Name then
            table.insert(Parts, Watermark.SubName)
        end

        table.insert(Parts, Watermark.PlaceName)
        local Now = os.date("*t")
        local Hour = Now.hour % 12
        table.insert(Parts, string.format("%d:%02d", Hour == 0 and 12 or Hour, Now.min))

        Label.Text = table.concat(Parts, " / ")
    end

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

    function Watermark:Center() end

    Spawn(function()
        local Ok, Info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)

        if Ok and Info and Info.Name then
            Watermark.PlaceName = Info.Name
        end
    end)

    Spawn(function()
        while true do
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
        Position = UDim2.new(0, 12, 0.45, 0),
        Size = UDim2.new(0, 180, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Window end)
    Outline(Frame, "Border")
    Shade(Frame, -90)
    New("UIPadding", {
        Parent = Frame,
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
    })
    Highlight(Frame, "Window", UDim2.new(0, -5, 0, 0), UDim2.new(1, 10, 0, 1))

    local Title = New("TextLabel", {
        Parent = Frame,
        RichText = true,
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = KeybindList.Name,
    })
    TitleGradient(Title)
    Draggable(Title, Frame)

    local Content = New("Frame", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 20),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
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

    function KeybindList:Center() end

    function KeybindList:Add(Name, Mode)
        local Entry = { }
        local CanBeVisible = true

        local Row = New("Frame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 15),
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
        Themed(function() ModeLabel.TextColor3 = Theme["Element Accent"] end)

        Entry.NewKey = Wrap(Row)
        Entry.Text = Wrap(NameLabel)
        Entry.Mode = Wrap(ModeLabel)

        function Entry:SetVis(Bool)
            CanBeVisible = Bool
            if not Bool then
                Row.Visible = false
            end
        end

        function Entry:SetStatus(Bool)
            Row.Visible = CanBeVisible and Bool and true or false
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

--#region TargetHUD
Library.TargetHUD = function(Self, Params)
    Params = Params or { }

    local HUD = {
        Enabled = true,
        Target = nil,
        Player = nil,
        Model = nil,
        Items = { },
    }

    local Outer = New("Frame", {
        Parent = Library.Holder,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -140),
        Size = UDim2.fromOffset(295, 135),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Visible = false,
    })
    Outline(Outer, "Border")
    Draggable(Outer, Outer)

    local Inner = New("Frame", {
        Parent = Outer,
        Position = UDim2.fromOffset(5, 6),
        Size = UDim2.new(1, -10, 1, -12),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    })
    Outline(Inner)
    Shade(Inner, -90)
    Highlight(Inner, "Window")

    local Title = New("TextLabel", {
        Parent = Outer,
        Position = UDim2.fromOffset(13, 7),
        Size = UDim2.new(1, -26, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Params.Name or "Target HUD",
    })
    TitleGradient(Title)

    local Avatar = New("ImageLabel", {
        Parent = Inner,
        Position = UDim2.fromOffset(8, 24),
        Size = UDim2.fromOffset(85, 85),
        BackgroundTransparency = 1,
        Image = "",
    })
    Outline(Avatar)

    local Info = New("Frame", {
        Parent = Inner,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(103, 23),
        Size = UDim2.fromOffset(170, 85),
    })
    New("UIPadding", { Parent = Info, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) })
    New("UIListLayout", { Parent = Info, Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder })

    local function InfoLabel(Order)
        return New("TextLabel", {
            Parent = Info,
            Size = UDim2.new(1, 0, 0, 15),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextStrokeTransparency = 1,
            LayoutOrder = Order,
        })
    end

    local UserLabel = InfoLabel(1)
    local HealthLabel = InfoLabel(2)
    local DistanceLabel = InfoLabel(3)
    local TeamLabel = InfoLabel(4)

    HUD.Items = {
        TargetHUD = Wrap(Outer),
        Avatar = Wrap(Avatar),
        User = Wrap(UserLabel),
        Health = Wrap(HealthLabel),
        Distance = Wrap(DistanceLabel),
        Team = Wrap(TeamLabel),
    }

    local Thumbnails = { }

    local function Resolve(Target)
        if type(Target) == "table" and Target.FinalPart then
            Target = Target.FinalPart
        end

        if typeof(Target) ~= "Instance" then
            return nil, nil
        end

        if Target:IsA("Player") then
            return Target, Target.Character
        end

        local Model = Target:IsA("Model") and Target or Target:FindFirstAncestorOfClass("Model")
        if not Model then
            return nil, nil
        end

        local Player = Players:GetPlayerFromCharacter(Model)
        if not Player then
            local Found = Players:FindFirstChild(Model.Name)
            Player = (Found and Found:IsA("Player")) and Found or nil
        end

        return Player, Model
    end

    local function SetAvatar(Player)
        if not Player then
            Avatar.Image = ""
            return
        end

        local UserId = Player.UserId

        if Thumbnails[UserId] then
            Avatar.Image = Thumbnails[UserId]
            return
        end

        task.spawn(function()
            local Ok, Image = pcall(function()
                return Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)

            if Ok and Image then
                Thumbnails[UserId] = Image
                if HUD.ShownPlayer == Player then
                    Avatar.Image = Image
                end
            end
        end)
    end

    function HUD:SetTarget(Target)
        local Player, Model = Resolve(Target)

        HUD.Target = Target
        HUD.Player = Player
        HUD.Model = Model
    end

    function HUD:SetVisibility(Bool)
        HUD.Enabled = Bool
    end

    local Elapsed = 0

    Connect(RunService.Heartbeat, function(Delta)
        Elapsed += Delta
        if Elapsed < 0.1 then
            return
        end
        Elapsed = 0

        local Player, Model = HUD.Player, HUD.Model

        if (not Model or not Model.Parent) and Library.MenuOpen then
            Player, Model = LocalPlayer, LocalPlayer.Character
        end

        if Player ~= HUD.ShownPlayer then
            HUD.ShownPlayer = Player
            SetAvatar(Player)
        end

        Outer.Visible = HUD.Enabled and Model ~= nil and Model.Parent ~= nil

        if not Outer.Visible then
            return
        end

        local Humanoid = Model:FindFirstChildOfClass("Humanoid")
        local Health, MaxHealth = 100, 100

        if Humanoid then
            Health, MaxHealth = Humanoid.Health, math.max(Humanoid.MaxHealth, 1)
        elseif Model:GetAttribute("Health") then
            Health = Model:GetAttribute("Health")
            MaxHealth = Model:GetAttribute("MaxHealth") or 100
        end

        local Team = (Player and Player.Team and Player.Team.Name)
            or Model:GetAttribute("Team")
            or (Player and Player:GetAttribute("Team"))

        local Distance = 0
        local Character = LocalPlayer.Character
        if Character and Model.Parent then
            Distance = (Character:GetPivot().Position - Model:GetPivot().Position).Magnitude * 0.28
        end

        UserLabel.Text = "Username - " .. (Player and Player.Name or Model.Name)
        HealthLabel.Text = string.format("Health - %d%%", math.floor(Health / MaxHealth * 100 + 0.5))
        DistanceLabel.Text = string.format("Distance - %dm", math.floor(Distance + 0.5))
        TeamLabel.Text = "Team - " .. (Team and tostring(Team) or "N/A")
    end)

    return setmetatable(HUD, Library)
end
--#endregion

--#region EspPreview
Library.EspPreview = function(Self, Params)
    Params = Params or { }

    local WindowSize = (Self.Size and Self.Size.X.Offset > 0) and Self.Size or UDim2.fromOffset(498, 598)

    local Preview = {
        Enabled = true,
        Items = { },
    }

    local Frame = New("Frame", {
        Parent = Library.Holder,
        Size = UDim2.fromOffset(275, 325),
        Position = UDim2.new(0.5, -WindowSize.X.Offset / 2 - 14 - 275, 0.5, -WindowSize.Y.Offset / 2),
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Window end)
    Outline(Frame)
    New("UIPadding", { Parent = Frame, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) })
    Highlight(Frame, "Window", UDim2.new(0, -5, 0, 0), UDim2.new(1, 10, 0, 1))

    local Title = New("TextLabel", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Params.Name or "Esp Preview",
    })
    TitleGradient(Title)
    Draggable(Title, Frame)

    local Inner = New("Frame", {
        Parent = Frame,
        Position = UDim2.fromOffset(0, 24),
        Size = UDim2.new(1, 0, 1, -29),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        ClipsDescendants = true,
    })
    Outline(Inner, "Border")

    local Image = New("ImageLabel", {
        Parent = Inner,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Image = Params.Image or "rbxassetid://89494888821949",
    })

    Preview.Items = { Window = Wrap(Frame), Image = Wrap(Image) }

    Frame.Visible = Library.MenuOpen
    local Entry = { Frame = Frame, Enabled = true, Fader = Fader(Frame, true, "Window") }
    table.insert(Library.Floating, Entry)

    function Preview:SetImage(Id)
        Image.Image = tostring(Id)
    end

    function Preview:SetVisibility(Bool)
        Entry.Enabled = Bool
        Entry.Fader:Set(Bool and Library.MenuOpen)
    end

    return setmetatable(Preview, Library)
end
--#endregion

--#region Window
Library.Window = function(Self, Params)
    Params = Params or { }

    local Window = {
        Name = Params.Name or Params.name or "Vergil.lol",
        Rank = Params.Rank or Params.rank,
        Size = Params.Size or Params.size or UDim2.fromOffset(498, 598),

        IsOpen = true,
        Pages = { },
        Current = nil,
        Items = { },
    }
    Window.Window = Window

    local Plain = (Window.Name:gsub("<[^>]->", ""))
    Library.Name = Plain:match("^%s*(.-)%s*|") or Plain

    local Main = New("Frame", {
        Parent = Library.Holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = Window.Size,
        BackgroundTransparency = 0,
    })
    Themed(function() Main.BackgroundColor3 = Theme.Background end)
    New("UIPadding", {
        Parent = Main,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })
    New("UIShadow", { Parent = Main })
    Outline(Main, "Border")
    Shade(Main, -90, Color3.fromRGB(144, 145, 145), Color3.fromRGB(201, 201, 201))
    Highlight(Main, "Background", UDim2.new(0, -10, 0, 0), UDim2.new(1, 20, 0, 1))

    local Title = New("TextLabel", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 30),
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Window.Name,
    })
    MainGradient(Title)
    Draggable(Title, Main)

    local Content = New("Frame", {
        Parent = Main,
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 0,
    })
    Themed(function() Content.BackgroundColor3 = Theme.Background end)
    Outline(Content)
    New("UIGradient", {
        Parent = Content,
        Rotation = 270,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(122, 121, 123)),
            ColorSequenceKeypoint.new(0.15, Color3.fromRGB(124, 124, 126)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }
    })

    local TabBar = New("Frame", {
        Parent = Content,
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 0, 24),
        BackgroundTransparency = 0,
        ZIndex = 2,
    })
    Themed(function() TabBar.BackgroundColor3 = Theme.Background end)
    New("UIListLayout", {
        Parent = TabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        VerticalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    local TabStroke = New("UIStroke", {
        Parent = TabBar,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        BorderStrokePosition = StrokeInner,
    })
    Themed(function() TabStroke.Color = Theme.Outline end)
    Shade(TabBar, 90)

    local PagesHolder = New("Frame", {
        Parent = Content,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 35),
        Size = UDim2.new(1, -20, 1, -77),
    })

    local Bottom = New("Frame", {
        Parent = Content,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, -10),
        Size = UDim2.new(1, -20, 0, 24),
        BackgroundTransparency = 0,
    })
    Themed(function() Bottom.BackgroundColor3 = Theme.Background end)
    Outline(Bottom, "Outline", true)
    Shade(Bottom, 90)
    New("UIPadding", { Parent = Bottom, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

    local BottomTitle = New("TextLabel", {
        Parent = Bottom,
        Size = UDim2.new(0.6, 0, 1, 0),
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Window.Name,
    })
    MainGradient(BottomTitle)

    local UserLabel = New("TextLabel", {
        Parent = Bottom,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = "@" .. LocalPlayer.Name,
    })
    Themed(function()
        UserLabel.Text = "@" .. LocalPlayer.Name
            .. (Window.Rank and string.format(' <font color="%s">[%s]</font>', ToRichColor(Theme["Element Accent"]), Window.Rank) or "")
    end)

    Window.Items = {
        MainFrame = Wrap(Main),
        Title = Wrap(Title),
        Content = Wrap(PagesHolder),
        Pages = Wrap(TabBar),
        BottomBar = Wrap(Bottom),
    }

    Window.Fader = Fader(Main, true, "Window")

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
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
        Main.Position = UDim2.fromScale(0.5, 0.5)
    end

    function Window:SetText(Text)
        Title.Text = tostring(Text)
        BottomTitle.Text = tostring(Text)
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

    local Tab = New("TextButton", {
        Parent = Window.Items.Pages.Instance,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = Page.Name,
        LayoutOrder = #Window.Pages + 1,
    })
    New("UIPadding", { Parent = Tab, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
    New("UIStroke", {
        Parent = Tab,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.new(0, 0, 0),
        BorderOffset = UDim.new(0, -2),
    })

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
            local Y = 2

            for _, Item in Data.Items do
                Item.Y = Y

                if not Item.Hidden then
                    if Item.State ~= "Landing" then
                        Glide(Item, "Position", { Position = UDim2.fromOffset(2, Y) }, Instant or Item == Snap)
                    end

                    Y += Item.Height + 8
                end
            end

            Scroll.CanvasSize = UDim2.fromOffset(0, math.max(Y - 6, 0))
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
        Inactive = Wrap(Tab),
        Text = Wrap(Tab),
        Page = Wrap(Holder),
        LeftColumn = Wrap(Left.Scroll),
        RightColumn = Wrap(Right.Scroll),
    }

    local function Paint()
        local Active = Window.Current == Page
        Tab.TextColor3 = Active and Theme["Element Accent"] or Theme["Inactive Text"]
    end
    Page.Paint = Paint
    Themed(Paint)

    Connect(Tab.MouseEnter, function()
        if Window.Current ~= Page then
            Tween(Tab, { TextColor3 = Theme["Dim Text"] })
        end
    end)

    Connect(Tab.MouseLeave, function()
        Tween(Tab, { TextColor3 = Window.Current == Page and Theme["Element Accent"] or Theme["Inactive Text"] })
    end)

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
            Old.Paint()
        end

        Holder.Position = UDim2.fromOffset(0, 8)
        Tween(Holder, { Position = UDim2.fromOffset(0, 0) })
        Page.Fader:Set(true)

        Paint()
    end

    Connect(Tab.MouseButton1Down, function()
        Page:Turn()
    end)

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
        Height = 42,
        Y = 0,
        Hidden = false,
        FloatSize = nil,
        Born = os.clock(),
        Tweens = { },
        Items = { },
    }
    Section.Section = Section

    local Frame = New("Frame", {
        Parent = Home.Scroll,
        Size = UDim2.new(1, -4, 0, Section.Height),
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Background end)
    Outline(Frame, "Outline", true)
    Shade(Frame, 90)

    local Accent = Highlight(Frame, "Background")
    Accent.Visible = false

    local Shadow = New("UIShadow", { })

    local Handle = New("Frame", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
    })

    local Title = New("TextLabel", {
        Parent = Handle,
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.new(1, -24, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Section.Name,
    })
    TitleGradient(Title)

    local Body = New("ScrollingFrame", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 28),
        Size = UDim2.new(1, -20, 1, -38),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = false,
        ScrollBarThickness = 2,
    })
    Themed(function() Body.ScrollBarImageColor3 = Theme["Element Accent"] end)
    New("UIPadding", {
        Parent = Body,
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2),
    })
    local List = New("UIListLayout", { Parent = Body, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

    local Grip = New("TextButton", {
        Parent = Frame,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -3, 1, -3),
        Size = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 0,
        ZIndex = 5,
        Visible = false,
    })
    Themed(function() Grip.BackgroundColor3 = Theme["Element Accent"] end)
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
    Section.Container = Body
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
        Library.ShadowWanted[Shadow] = Loose
        Shadow.Parent = Loose and Frame or nil

        if Floating and not Index then
            table.insert(Library.Floating, Entry)
        elseif Index and not Floating then
            table.remove(Library.Floating, Index)
        end
    end

    local function Measure()
        local Content = List.AbsoluteContentSize.Y

        Section.Height = Content + 42
        Body.CanvasSize = UDim2.fromOffset(0, Content + 4)

        if Section.State ~= "Docked" then
            return
        end

        local Instant = os.clock() - Section.Born < 1 or not Section.Column.Holder.Visible

        Glide(Section, "Size", { Size = UDim2.new(1, -4, 0, Section.Height) }, Instant)
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

        Glide(Section, "Position", { Position = UDim2.fromOffset(2, Section.Y) }, true)
        Glide(Section, "Size", { Size = UDim2.new(1, -4, 0, Section.Height) }, true)
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

        local Goal = Scroll.AbsolutePosition - Scroll.CanvasPosition - Origin + Vector2.new(2, Section.Y)

        Glide(Section, "Size", { Size = UDim2.fromOffset(Scroll.AbsoluteSize.X - 4, Section.Height) })
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

        SetState("Floating")
        Section.Column = nil
        Frame.Parent = Library.Holder
        Frame.ZIndex = NextOrder() + 1

        Glide(Section, "Position", { Position = UDim2.fromOffset(Position.X, Position.Y) }, true)
        Glide(Section, "Position", { Position = UDim2.fromOffset(Goal.X, Goal.Y) })
        Glide(Section, "Size", { Size = UDim2.fromOffset(Width, Height) })
    end

    local Pending = nil
    local Resizing = nil

    Connect(Handle.InputBegan, function(Input)
        if not IsClick(Input) or not CanDrag() then
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
            BeginDrag(Section)
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
        if IsClick(Input) then
            Pending = nil
            Resizing = nil
        end
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
    New("UIListLayout", { Parent = Root, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

    local Row = New("TextButton", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 16),
        LayoutOrder = 1,
    })

    local Box = New("Frame", {
        Parent = Row,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 0,
    })
    Outline(Box)

    local Shadow = New("UIShadow", { })

    local Label = New("TextLabel", {
        Parent = Row,
        Position = UDim2.fromOffset(17, 0),
        Size = UDim2.new(1, -17, 1, 0),
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

    local function Colors()
        local BoxColor = Toggle.Value and Theme["Element Accent"] or (Hovered and Theme.Hover or Theme.Background)
        local TextColor = Toggle.Value and Theme.Text or Theme["Dim Text"]
        return BoxColor, TextColor
    end

    Themed(function()
        local BoxColor, TextColor = Colors()
        Box.BackgroundColor3 = BoxColor
        Label.TextColor3 = TextColor
    end)

    local function Animate()
        local BoxColor, TextColor = Colors()
        Tween(Box, { BackgroundColor3 = BoxColor })
        Tween(Label, { TextColor3 = TextColor })
    end

    Connect(Row.MouseEnter, function() Hovered = true Animate() end)
    Connect(Row.MouseLeave, function() Hovered = false Animate() end)

    function Toggle:Set(Bool)
        Toggle.Value = Bool and true or false

        Animate()

        Library.ShadowWanted[Shadow] = Toggle.Value
        Shadow.Parent = Toggle.Value and Box or nil

        if Toggle.SettingsItem then
            Toggle.SettingsItem:SetOpen(Toggle.Value)
        end

        Flags[Toggle.Flag] = Toggle.Value
        SafeCall(Toggle.Callback, Toggle.Value)
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
        New("UIPadding", { Parent = Content, PaddingLeft = UDim.new(0, 17) })
        New("UIListLayout", { Parent = Content, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

        local Settings = {
            IsOpen = Toggle.Value,
            Container = Content,
            Window = Toggle.Window,
            Page = Toggle.Page,
            Items = { Content = Wrap(Content) },
        }
        Settings.Section = Settings

        function Settings:SetOpen(Bool)
            Settings.IsOpen = Bool
            Content.Visible = Bool
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

    local Frame = New("TextButton", {
        Parent = Self.Container,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = Button.Name,
        LayoutOrder = NextOrder(),
    })
    Themed(function()
        Frame.BackgroundColor3 = Theme.Hover
        Frame.TextColor3 = Theme.Accent
    end)
    Outline(Frame, "Button Outline")

    Button.Items = { Button = Wrap(Frame), Text = Wrap(Frame) }

    Connect(Frame.MouseEnter, function()
        Tween(Frame, { BackgroundTransparency = 0, TextColor3 = Theme.Text })
    end)

    Connect(Frame.MouseLeave, function()
        Tween(Frame, { BackgroundTransparency = 1, TextColor3 = Theme.Accent })
    end)

    function Button:Press()
        Frame.TextColor3 = Theme["Element Accent"]
        Tween(Frame, { TextColor3 = Theme.Text })
        SafeCall(Button.Callback)
    end

    function Button:SetVisibility(Bool)
        Frame.Visible = Bool
    end

    function Button:SetText(Text)
        Frame.Text = tostring(Text)
    end

    Connect(Frame.MouseButton1Click, function()
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

    local Title = New("TextLabel", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = Slider.Name,
        LayoutOrder = 1,
    })

    local Bar = New("TextButton", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 13),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
    })
    Themed(function() Bar.BackgroundColor3 = Theme.Hover end)
    Outline(Bar)

    local Fill = New("Frame", {
        Parent = Bar,
        Size = UDim2.fromScale(0, 1),
        BackgroundTransparency = 0,
    })
    Themed(function() Fill.BackgroundColor3 = Theme["Element Accent"] end)
    New("UIShadow", { Parent = Fill })

    local ValueLabel = New("TextLabel", {
        Parent = Bar,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
    })

    Slider.Items = {
        Slider = Wrap(Root),
        Text = Wrap(Title),
        RealSlider = Wrap(Bar),
        Accent = Wrap(Fill),
        Value = Wrap(ValueLabel),
    }

    Connect(Bar.MouseEnter, function() Tween(Bar, { BackgroundTransparency = 0 }) end)
    Connect(Bar.MouseLeave, function() Tween(Bar, { BackgroundTransparency = 1 }) end)

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

    function Slider:GetSize(Input)
        local Percent = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        return Slider.Min + (Slider.Max - Slider.Min) * Percent
    end

    Connect(Bar.InputBegan, function(Input)
        if IsClick(Input) then
            Slider.Sliding = true
            Slider:Set(Slider:GetSize(Input))
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if Slider.Sliding and IsMove(Input) then
            Slider:Set(Slider:GetSize(Input))
        end
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if IsClick(Input) then
            Slider.Sliding = false
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
        Name = Params.Name or Params.name or "Dropdown",
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

    local Title = New("TextLabel", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = Dropdown.Name,
        LayoutOrder = 1,
    })

    local Box = New("TextButton", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
    })
    Themed(function() Box.BackgroundColor3 = Theme.Hover end)
    Outline(Box)

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
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Text = "+",
    })

    local Popup = New("Frame", {
        Parent = Library.PopupHolder,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(100, 26),
    })
    Themed(function() Popup.BackgroundColor3 = Theme.Window end)
    Outline(Popup)

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
    Themed(function() Scroll.ScrollBarImageColor3 = Theme["Element Accent"] end)
    New("UIPadding", { Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) })
    New("UIListLayout", { Parent = Scroll, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })

    Dropdown.Items = {
        Dropdown = Wrap(Root),
        Text = Wrap(Title),
        RealDropdown = Wrap(Box),
        Value = Wrap(ValueLabel),
        OptionHolder = Wrap(Popup),
        OptionScroll = Wrap(Scroll),
    }
    Dropdown.Holder = Dropdown.Items.OptionHolder

    Connect(Box.MouseEnter, function() Tween(Box, { BackgroundTransparency = 0 }) end)
    Connect(Box.MouseLeave, function() Tween(Box, { BackgroundTransparency = 1 }) end)

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
            Text = Value,
            LayoutOrder = NextOrder(),
        })

        local OptionData = {
            Button = Wrap(OptionButton),
            Text = Wrap(OptionButton),
            Name = Value,
            IsSelected = false,
        }

        function OptionData:ToggleState(State)
            Tween(OptionButton, { TextColor3 = State == "Active" and Theme.Text or Theme["Option Text"] })
        end

        Themed(function()
            OptionButton.TextColor3 = OptionData.IsSelected and Theme.Text or Theme["Option Text"]
        end)

        Connect(OptionButton.MouseEnter, function()
            if not OptionData.IsSelected then
                Tween(OptionButton, { TextColor3 = Theme["Dim Text"] })
            end
        end)

        Connect(OptionButton.MouseLeave, function()
            if not OptionData.IsSelected then
                Tween(OptionButton, { TextColor3 = Theme["Option Text"] })
            end
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
                OptionData:ToggleState(OptionData.IsSelected and "Active" or "Inactive")
            else
                if OptionData.IsSelected then
                    Dropdown.Value = OptionData.Name

                    for _, Other in Dropdown.Options do
                        if Other ~= OptionData then
                            Other.IsSelected = false
                            Other:ToggleState("Inactive")
                        end
                    end

                    OptionData:ToggleState("Active")
                else
                    Dropdown.Value = nil
                    OptionData:ToggleState("Inactive")
                end
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
        Title.Text = tostring(Text)
    end

    function Dropdown:SetVisibility(Bool)
        Root.Visible = Bool
    end

    function Dropdown:Reposition()
        Popup.Size = UDim2.fromOffset(Box.AbsoluteSize.X, PopupHeight())
        PlaceBelow(Popup, Box, 4)
    end

    function Dropdown:SetOpen(Bool)
        Dropdown.IsOpen = Bool
        Sign.Text = Bool and "-" or "+"

        if Bool then
            Library:CloseAll(Dropdown)
            Popup.Visible = true
            Dropdown:Reposition()
            Library.OpenFrames[Dropdown] = Dropdown
        else
            Popup.Visible = false
            Library.OpenFrames[Dropdown] = nil
        end
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
        Size = UDim2.new(1, 0, 0, 14),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = NextOrder(),
    })

    local Text = New("TextLabel", {
        Parent = Row,
        Size = UDim2.new(1, 0, 0, 14),
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
        Size = UDim2.new(0, 0, 0, 14),
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
    end

    local Frame = New("Frame", {
        Parent = Root,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
    })
    Outline(Frame)

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
    Themed(function() Input.PlaceholderColor3 = Theme["Option Text"] end)

    Textbox.Items = { Textbox = Wrap(Root), Text = Title and Wrap(Title) or nil, Input = Wrap(Input) }

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
        Size = UDim2.fromOffset(250, 275),
        Position = UDim2.new(0.5, WindowSize.X.Offset / 2 + 14, 0.5, -WindowSize.Y.Offset / 2),
        BackgroundTransparency = 0,
    })
    Themed(function() Frame.BackgroundColor3 = Theme.Window end)
    Outline(Frame, "Border")
    Shade(Frame, -90)
    New("UIPadding", { Parent = Frame, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 6) })
    Highlight(Frame, "Window", UDim2.new(0, -5, 0, 0), UDim2.new(1, 11, 0, 1))

    local Title = New("TextLabel", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Config",
    })
    TitleGradient(Title)
    Draggable(Title, Frame)

    local ListFrame = New("Frame", {
        Parent = Frame,
        Position = UDim2.fromOffset(0, 21),
        Size = UDim2.new(1, 0, 0, 155),
        BackgroundTransparency = 0,
    })
    Themed(function() ListFrame.BackgroundColor3 = Theme.Window end)
    Outline(ListFrame)
    Shade(ListFrame, -90)

    local Scroll = New("ScrollingFrame", {
        Parent = ListFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 0,
        Active = true,
    })
    New("UIPadding", { Parent = Scroll, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) })
    New("UIListLayout", { Parent = Scroll, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })

    local NameFrame = New("Frame", {
        Parent = Frame,
        Position = UDim2.fromOffset(0, 184),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
    })
    Outline(NameFrame, "Button Outline")

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
    Themed(function() NameBox.PlaceholderColor3 = Theme["Option Text"] end)

    local function ConfigButton(Text, Position, Size)
        local Holder = New("Frame", {
            Parent = Frame,
            Position = Position,
            Size = Size,
            BackgroundTransparency = 1,
        })
        Outline(Holder, "Button Outline")

        local Button = New("TextButton", {
            Parent = Holder,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = Text,
        })
        Themed(function()
            Holder.BackgroundColor3 = Theme.Hover
            Button.TextColor3 = Theme.Accent
        end)

        Connect(Button.MouseEnter, function()
            Tween(Holder, { BackgroundTransparency = 0 })
            Tween(Button, { TextColor3 = Theme.Text })
        end)

        Connect(Button.MouseLeave, function()
            Tween(Holder, { BackgroundTransparency = 1 })
            Tween(Button, { TextColor3 = Theme.Accent })
        end)

        return Button
    end

    local SaveButton = ConfigButton("Save Config", UDim2.fromOffset(0, 212), UDim2.new(0.5, -4, 0, 25))
    local DeleteButton = ConfigButton("Delete Config", UDim2.new(0.5, 4, 0, 212), UDim2.new(0.5, -4, 0, 25))
    local LoadButton = ConfigButton("Load Config", UDim2.fromOffset(0, 244), UDim2.new(1, 0, 0, 25))

    local Selected = nil
    local Buttons = { }

    local function Paint()
        for Name, Button in Buttons do
            local IsSelected = Name == Selected
            Button.TextColor3 = IsSelected and Theme.Accent or Theme["Option Text"]
            Button.TextStrokeTransparency = IsSelected and 0 or 0.5
        end
    end
    Themed(Paint)

    local function Refresh()
        for _, Button in Buttons do
            Button:Destroy()
        end
        table.clear(Buttons)

        local List = Library:GetConfigsList()

        if Selected and not table.find(List, Selected) then
            Selected = nil
        end

        for _, Name in List do
            local Button = New("TextButton", {
                Parent = Scroll,
                Size = UDim2.new(1, 0, 0, 15),
                Text = Name,
                LayoutOrder = NextOrder(),
            })

            Buttons[Name] = Button

            Connect(Button.MouseButton1Click, function()
                if Selected == Name then
                    Selected = nil
                else
                    Selected = Name
                end
                if Selected then
                    NameBox.Text = Name
                end
                Paint()
            end)
        end

        Paint()
    end

    Connect(SaveButton.MouseButton1Click, function()
        local Name = NameBox.Text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[\\/:%*%?\"<>|]", "")
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

    Connect(DeleteButton.MouseButton1Click, function()
        if not Selected then
            Library:Notification({ Name = "select a config first", Time = 3 })
            return
        end

        local Name = Selected
        if isfile(ConfigPath(Name)) then
            delfile(ConfigPath(Name))
        end

        Selected = nil
        NameBox.Text = ""
        Refresh()
        Library:Notification({ Name = "deleted config " .. Name, Time = 3 })
    end)

    Connect(LoadButton.MouseButton1Click, function()
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

    local SettingsPage = Window:Page({ Name = "settings" })

    local MenuSection = SettingsPage:Section({ Name = "menu", Side = 1 }) do
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
            Default = "Quart",
            Callback = function(Value)
                Library.Animation.Style = Value
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
            Name = "unload",
            Callback = function()
                Library:Exit()
            end
        })
    end

    local EffectsSection = SettingsPage:Section({ Name = "effects", Side = 2 }) do
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

        EffectsSection:Toggle({
            Name = "snow",
            Flag = "ui_snow",
            Default = Library.SnowEnabled,
            Callback = function(Value)
                Library.SnowEnabled = Value
                Library:UpdateEffects()
            end
        })

        EffectsSection:Slider({
            Name = "snow amount",
            Flag = "ui_snowamount",
            Min = 10,
            Max = 300,
            Default = Library.SnowAmount,
            Decimals = 1,
            Callback = function(Value)
                Library:SetSnowAmount(Value)
            end
        })
    end

    local ThemeSection = SettingsPage:Section({ Name = "theme", Side = 2 }) do
        local Keys = { }
        for Key in Theme do
            table.insert(Keys, Key)
        end
        table.sort(Keys)

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
end
--#endregion

getgenv().VergilLibrary = Library

return Library
