cloneref = cloneref or function(Object) return Object end

if getgenv().EspLib then
    getgenv().EspLib:Unload()
end

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer
local GetHui = gethui or function() return CoreGui end

local White = Color3.fromRGB(255, 255, 255)
local Black = Color3.fromRGB(0, 0, 0)
local Purple = Color3.fromRGB(67, 0, 255)
local Lilac = Color3.fromRGB(160, 128, 255)
local Pale = Color3.fromRGB(253, 253, 255)

local BoxHeight = 5.8
local BoxOffset = Vector3.new(0, -0.4, 0)

local EspLib = {
    Directory = "Vergil",
    FontUrl = "https://github.com/bluescan/proggyfonts/raw/master/ProggyOriginal/ProggyClean.ttf",

    Table = {
        Enabled = true,
        TeamCheck = false,
        Distance = 500,

        Boxes = {
            Enabled = true,

            Box = {
                Enabled = true,
                Top = White,
                Bot = White,
            },

            Fill = {
                Enabled = true,
                Top = Purple,
                Bot = Pale,
                Transparency = 0.9,
            },
        },

        Bars = {
            Health = {
                Enabled = true,
                Top = Purple,
                Mid = Lilac,
                Bot = Pale,
            },
        },

        Texts = {
            Name = {
                Enabled = true,
                Color = White,
            },

            Health = {
                Enabled = true,
                Color = White,
            },

            Weapon = {
                Enabled = true,
                Color = White,
            },

            Distance = {
                Enabled = true,
                Color = White,
            },
        },
        bha = {
            Enabled = false;
            Color = Color3.new(1,1,1);
            Shading = Enum.AdornShading.XRayShaded;
            AlwaysOnTop = true;
            Transparency = 0;
            SizePadding = 0.01;
        };

    },

    Cache = { },
    Connections = { },
    Chams = {
        Players = {};
    }
}
local Cache = EspLib.Cache
local Shadow = { }
local Styles = { }
local Levels = { }

local function LoadFont()
    local Folder = EspLib.Directory .. "/Assets"
    local TtfPath = Folder .. "/ProggyClean.ttf"
    local JsonPath = Folder .. "/ProggyClean.json"

    if not isfolder(EspLib.Directory) then
        makefolder(EspLib.Directory)
    end

    if not isfolder(Folder) then
        makefolder(Folder)
    end

    if not isfile(TtfPath) then
        writefile(TtfPath, game:HttpGet(EspLib.FontUrl))
    end

    writefile(JsonPath, HttpService:JSONEncode({
        name = "ProggyClean",
        faces = {
            { name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(TtfPath) },
        },
    }))

    return Font.new(getcustomasset(JsonPath), Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end

local ProggyClean = LoadFont()

local function New(Class, Properties)
    local Object = Instance.new(Class)

    if Object:IsA("GuiObject") then
        Object.BorderSizePixel = 0
    end

    for Property, Value in Properties do
        if Property ~= "Parent" then
            Object[Property] = Value
        end
    end

    Object.Parent = Properties.Parent
    return Object
end

local function Text(Properties)
    Properties.BackgroundTransparency = 1
    Properties.FontFace = ProggyClean
    Properties.TextSize = 12
    Properties.TextColor3 = White
    Properties.TextStrokeTransparency = 0

    return New("TextLabel", Properties)
end

local function Outline(Parent)
    New("UIStroke", {
        Parent = Parent,
        Color = Black,
        LineJoinMode = Enum.LineJoinMode.Miter,
        BorderOffset = UDim.new(0, 1),
    })

    local Middle = New("UIStroke", {
        Parent = Parent,
        Color = White,
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    New("UIStroke", {
        Parent = Parent,
        Color = Black,
        LineJoinMode = Enum.LineJoinMode.Miter,
        BorderOffset = UDim.new(0, -1),
    })

    return Middle
end

local Gui = New("ScreenGui", {
    Name = "Banana esp",
    Parent = GetHui(),
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 1,
})

local function Diff(Source, Copy)
    local Dirty = false

    for Key, Value in Source do
        if type(Value) == "table" then
            local Inner = Copy[Key]

            if type(Inner) ~= "table" then
                Inner = { }
                Copy[Key] = Inner
                Dirty = true
            end

            if Diff(Value, Inner) then
                Dirty = true
            end
        elseif Copy[Key] ~= Value then
            Copy[Key] = Value
            Dirty = true
        end
    end

    return Dirty
end

local function Compile()
    local Settings = EspLib.Table
    local Box = Settings.Boxes.Box
    local Fill = Settings.Boxes.Fill
    local Health = Settings.Bars.Health

    Styles.Box = ColorSequence.new(Box.Bot, Box.Top)
    Styles.Fill = ColorSequence.new(Fill.Bot, Fill.Top)
    Styles.Bar = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Health.Bot),
        ColorSequenceKeypoint.new(0.5, Health.Mid),
        ColorSequenceKeypoint.new(1, Health.Top),
    }
end

local function Style(Esp)
    local Settings = EspLib.Table
    local Boxes = Settings.Boxes

    Esp.Fill.Visible = Boxes.Enabled and Boxes.Fill.Enabled
    Esp.Fill.BackgroundTransparency = Boxes.Fill.Transparency or 0.9
    Esp.FillGradient.Color = Styles.Fill

    Esp.Box.Visible = Boxes.Enabled and Boxes.Box.Enabled
    Esp.BoxGradient.Color = Styles.Box

    Esp.Bar.Visible = Settings.Bars.Health.Enabled
    Esp.BarGradient.Color = Styles.Bar

    for Key, Label in Esp.Labels do
        local Data = Settings.Texts[Key]

        Label.Visible = Data.Enabled
        Label.TextColor3 = Data.Color
    end
end

local function Level(Ratio)
    local Step = math.floor(Ratio * 200 + 0.5)
    local Sequence = Levels[Step]

    if Sequence then
        return Sequence
    end

    if Step >= 200 then
        Sequence = NumberSequence.new(0)
    elseif Step <= 0 then
        Sequence = NumberSequence.new(1)
    else
        local Cut = Step / 200

        Sequence = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(Cut, 0),
            NumberSequenceKeypoint.new(Cut + 0.001, 1),
            NumberSequenceKeypoint.new(1, 1),
        }
    end

    Levels[Step] = Sequence
    return Sequence
end

local function PaintHealth(Esp)
    Esp.BarGradient.Transparency = Level(Esp.Shown)
    Esp.Labels.Health.Position = UDim2.new(0, -12, 1 - Esp.Shown, 0)
end

--[[local function DoBHAChams(chr: Instance, allowlist: {any}, params: {any})
    params = params or {}
    local CIntances = {}
    for i, v in chr:GetChildren() do
        if table.find(allowlist, v.Name) then
            local BoxHandleAdornment = Instance.new("BoxHandleAdornment");
            BoxHandleAdornment.Parent = v;
            BoxHandleAdornment.Adornee = v;
            BoxHandleAdornment.Size = v.Size + Vector3.new(0.01, 0.01, 0.01);
            BoxHandleAdornment.Color3 = params.color;
            BoxHandleAdornment.Shading = params.shading;
            BoxHandleAdornment.AlwaysOnTop = params.alwaysOnTop;
            BoxHandleAdornment.Transparency = params.transparency;
            BoxHandleAdornment.Name = "\0"
            table.insert(CIntances, BoxHandleAdornment)
        end
    end
    return CIntances;
end]]
function EspLib.Chams:DoBHAChams(chr: Instance, allowlist: {any})
    local Settings = EspLib["Table"]["bha"]
    local CIntances = {}
    for _, v in chr:GetChildren() do
        if table.find(allowlist, v.Name) then
            local BoxHandleAdornment = Instance.new("BoxHandleAdornment");
            BoxHandleAdornment.Parent = v;
            BoxHandleAdornment.Adornee = v;
            BoxHandleAdornment.Size = v.Size + (Vector3.new(1, 1, 1)* Settings.SizePadding);
            BoxHandleAdornment.Color3 = Settings.Color;
            BoxHandleAdornment.Shading = Settings.Shading;
            BoxHandleAdornment.AlwaysOnTop = Settings.AlwaysOnTop;
            BoxHandleAdornment.Transparency = Settings.Transparency;
            BoxHandleAdornment.Name = "\0";
            BoxHandleAdornment.Visible = Settings.Enabled;
            table.insert(CIntances, BoxHandleAdornment);
        end;
    end;
    EspLib.Chams.Players[chr.Name] = CIntances;
end;

function EspLib.Chams:ClearPlrChams(plr: string)
    for _, v in EspLib.Chams.Players[plr] do
        v:Destroy()
    end
end

function EspLib.Chams:Update()
    local Settings = EspLib["Table"]["bha"]
    for name, list in EspLib.Chams.Players do
        --[[for _, Inst in plr do
            local part = Inst.Parent;
            if not part then
                --table.remove()
            if Inst:IsA("BoxHandleAdornment") and Settings.Enabled then
                Inst.Color3 = Settings.Color;
                Inst.Shading = Settings.Shading;
                Inst.AlwaysOnTop = Settings.AlwaysOnTop;
                Inst.Transparency = Settings.Transparency;
                Inst.Size = Inst.Parent.Size + (Vector3.new(1, 1, 1)* Settings.SizePadding)
                Inst.Visible = true;
            elseif Inst:IsA("BoxHandleAdornment") and not Settings.Enabled then
                Inst.Visible = false;
            end;
        end;]]
        for i = #list, 1, -1 do
            local inst = list[i];
            local part = inst.Parent
            -- my name is corn and im a bitch 
            if not part then
                table.remove(list, i)
            elseif inst:IsA("BoxHandleAdornment") and Settings.Enabled then
                inst.Color3 = Settings.Color;
                inst.Shading = Settings.Shading;
                inst.AlwaysOnTop = Settings.AlwaysOnTop;
                inst.Transparency = Settings.Transparency;
                inst.Size = inst.Parent.Size + (Vector3.new(1, 1, 1)* Settings.SizePadding)
                inst.Visible = true;
            else
                inst.Visible = false;
            end
        end
    end;
end;


local function SetHealth(Esp)
    local Humanoid = Esp.Humanoid
    local Health = math.max(Humanoid.Health, 0)

    Esp.Target = math.clamp(Health / math.max(Humanoid.MaxHealth, 1), 0, 1)
    Esp.Labels.Health.Text = tostring(math.floor(Health + 0.5))
end

local function SetWeapon(Esp)
    local Tool = Esp.Character:FindFirstChildOfClass("Tool")
    Esp.Labels.Weapon.Text = Tool and Tool.Name or "none"
end

local function Hide(Esp)
    if Esp.Visible then
        Esp.Visible = false
        Esp.Holder.Visible = false
    end
end

local function Show(Esp)
    if not Esp.Visible then
        Esp.Visible = true
        Esp.Holder.Visible = true
    end
end

local function Unbind(Esp)
    for _, Link in Esp.Links do
        Link:Disconnect()
    end

    table.clear(Esp.Links)
    Esp.Character = nil
    Esp.Root = nil
    Esp.Humanoid = nil
end

local function BindHumanoid(Esp, Humanoid)
    local function Changed()
        SetHealth(Esp)
    end

    Esp.Humanoid = Humanoid

    table.insert(Esp.Links, Humanoid.HealthChanged:Connect(Changed))
    table.insert(Esp.Links, Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(Changed))

    SetHealth(Esp)
    Esp.Shown = Esp.Target
    PaintHealth(Esp)
end

local function Bind(Esp, Character)
    Unbind(Esp)

    Esp.Character = Character
    Esp.Root = Character:FindFirstChild("HumanoidRootPart")

    table.insert(Esp.Links, Character.ChildAdded:Connect(function(Child)
        if Child.Name == "HumanoidRootPart" then
            Esp.Root = Child
        elseif Child:IsA("Humanoid") then
            BindHumanoid(Esp, Child)
        elseif Child:IsA("Tool") then
            SetWeapon(Esp)
        end
    end))

    table.insert(Esp.Links, Character.ChildRemoved:Connect(function(Child)
        if Child == Esp.Root then
            Esp.Root = nil
        elseif Child == Esp.Humanoid then
            Esp.Humanoid = nil
        elseif Child:IsA("Tool") then
            SetWeapon(Esp)
        end
    end))

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        BindHumanoid(Esp, Humanoid)
    end

    SetWeapon(Esp)
end

function EspLib:Add(Player)
    if Player == LocalPlayer or Cache[Player] then
        return
    end

    local Holder = New("Frame", {
        Parent = Gui,
        BackgroundTransparency = 1,
        Visible = false,
    })

    local Fill = New("Frame", {
        Parent = Holder,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = White,
        BackgroundTransparency = 0.9,
    })

    local Box = New("Frame", {
        Parent = Holder,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    local Bar = New("Frame", {
        Parent = Holder,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromOffset(-6, 0),
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundTransparency = 1,
    })
    Outline(Bar)

    local BarFill = New("Frame", {
        Parent = Bar,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = White,
    })

    local Bottom = New("Frame", {
        Parent = Holder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, 3),
        Size = UDim2.new(1, 0, 0, 22),
    })

    New("UIListLayout", {
        Parent = Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    })

    local Esp = {
        Player = Player,
        Holder = Holder,
        Fill = Fill,
        Box = Box,
        Bar = Bar,

        FillGradient = New("UIGradient", { Parent = Fill, Rotation = -90 }),
        BoxGradient = New("UIGradient", { Parent = Outline(Box), Rotation = -90 }),
        BarGradient = New("UIGradient", { Parent = BarFill, Rotation = -90 }),

        Labels = {
            Name = Text({
                Parent = Holder,
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 0, -3),
                Size = UDim2.fromOffset(0, 10),
                Text = Player.Name,
            }),

            Health = Text({
                Parent = Holder,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.fromOffset(-12, 0),
                Size = UDim2.fromOffset(0, 10),
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = "100",
            }),

            Weapon = Text({
                Parent = Bottom,
                Size = UDim2.new(1, 0, 0, 10),
                LayoutOrder = 1,
                Text = "none",
            }),

            Distance = Text({
                Parent = Bottom,
                Size = UDim2.new(1, 0, 0, 10),
                LayoutOrder = 2,
                Text = "0m",
            }),
        },

        Character = nil,
        Root = nil,
        Humanoid = nil,

        Target = 1,
        Shown = 1,
        Visible = false,
        X = -1,
        Y = -1,
        Width = -1,
        Height = -1,
        Meters = -1,

        Links = { },
    }

    Esp.PlayerLinks = {
        Player.CharacterAdded:Connect(function(Character)
            Bind(Esp, Character)
        end),

        Player.CharacterRemoving:Connect(function()
            Unbind(Esp)
            Hide(Esp)
        end),
    }

    Cache[Player] = Esp
    Style(Esp)

    if Player.Character then
        Bind(Esp, Player.Character)
    end

    return Esp
end

function EspLib:Remove(Player)
    local Esp = Cache[Player]

    if not Esp then
        return
    end

    Cache[Player] = nil
    Unbind(Esp)

    for _, Link in Esp.PlayerLinks do
        Link:Disconnect()
    end

    Esp.Holder:Destroy()
end

local function Step(Delta)
    local Settings = EspLib.Table

    if Diff(Settings, Shadow) then
        Compile()

        for _, Esp in Cache do
            Style(Esp)
        end
    end

    if not Settings.Enabled then
        for _, Esp in Cache do
            Hide(Esp)
        end

        return
    end

    local Camera = workspace.CurrentCamera
    local Origin = Camera.CFrame.Position
    local Viewport = Camera.ViewportSize
    local Factor = Viewport.Y / (2 * math.tan(math.rad(Camera.FieldOfView) / 2)) * BoxHeight
    local Range = Settings.Distance
    local TeamCheck = Settings.TeamCheck
    local Team = LocalPlayer.Team
    local ShowDistance = Settings.Texts.Distance.Enabled
    local Smooth = math.min(Delta * 12, 1)

    for Player, Esp in Cache do
        local Root = Esp.Root

        if not Root or not Esp.Humanoid or Esp.Target <= 0 or (TeamCheck and Team and Player.Team == Team) then
            Hide(Esp)
            continue
        end

        local Position = Root.Position + BoxOffset
        local Distance = (Position - Origin).Magnitude

        if Distance > Range then
            Hide(Esp)
            continue
        end

        local Screen = Camera:WorldToViewportPoint(Position)
        local Depth = Screen.Z

        if Depth <= 0 then
            Hide(Esp)
            continue
        end

        local Height = math.floor(Factor / Depth + 0.5)
        local Width = math.floor(Height / 1.5 + 0.5)
        local X = math.floor(Screen.X - Width / 2 + 0.5)
        local Y = math.floor(Screen.Y - Height / 2 + 0.5)

        if X > Viewport.X or Y > Viewport.Y or X + Width < 0 or Y + Height < 0 then
            Hide(Esp)
            continue
        end

        if X ~= Esp.X or Y ~= Esp.Y then
            Esp.X, Esp.Y = X, Y
            Esp.Holder.Position = UDim2.fromOffset(X, Y)
        end

        if Width ~= Esp.Width or Height ~= Esp.Height then
            Esp.Width, Esp.Height = Width, Height
            Esp.Holder.Size = UDim2.fromOffset(Width, Height)
        end

        if ShowDistance then
            local Meters = math.floor(Distance + 0.5)

            if Meters ~= Esp.Meters then
                Esp.Meters = Meters
                Esp.Labels.Distance.Text = Meters .. "m"
            end
        end

        if Esp.Shown ~= Esp.Target then
            local Shown = Esp.Shown + (Esp.Target - Esp.Shown) * Smooth

            if math.abs(Esp.Target - Shown) < 0.005 then
                Shown = Esp.Target
            end

            Esp.Shown = Shown
            PaintHealth(Esp)
        end

        Show(Esp)
    end
end

function EspLib:Unload()
    RunService:UnbindFromRenderStep("BananaEsp")

    for _, Connection in EspLib.Connections do
        Connection:Disconnect()
    end

    for Player in Cache do
        EspLib:Remove(Player)
    end

    Gui:Destroy()
    getgenv().EspLib = nil
end

Diff(EspLib.Table, Shadow)
Compile()

for _, Player in Players:GetPlayers() do
    EspLib:Add(Player)
end

table.insert(EspLib.Connections, Players.PlayerAdded:Connect(function(Player)
    EspLib:Add(Player)
end))

table.insert(EspLib.Connections, Players.PlayerRemoving:Connect(function(Player)
    EspLib:Remove(Player)
end))

RunService:BindToRenderStep("BananaEsp", Enum.RenderPriority.Camera.Value + 1, Step)

getgenv().EspLib = EspLib

return EspLib
