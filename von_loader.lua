-- Instances: 19 | Scripts: 0 | Modules: 0 | Tags: 0
local G2L = {};

-- StarterGui.ScreenGui
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;

-- StarterGui.ScreenGui.LoadingWindow_Frame
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 54);
G2L["2"]["Size"] = UDim2.new(0, 305, 0, 310);
G2L["2"]["Position"] = UDim2.new(0.4124, 0, 0.28659, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2"]["Name"] = [[LoadingWindow_Frame]];

-- StarterGui.ScreenGui.LoadingWindow_Frame.UIStroke
G2L["3"] = Instance.new("UIStroke", G2L["2"]);
G2L["3"]["Color"] = Color3.fromRGB(176, 188, 240);
G2L["3"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["3"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

-- StarterGui.ScreenGui.LoadingWindow_Frame.UIStroke
G2L["4"] = Instance.new("UIStroke", G2L["2"]);
G2L["4"]["BorderOffset"] = UDim.new(0, 1);
G2L["4"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["4"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

-- StarterGui.ScreenGui.LoadingWindow_Frame.Logo_Image
-- VideoFrame never loads a getcustomasset video, so the logo plays from sprite sheets instead: 75 frames at 25 fps,
-- 170 px each, 6 x 6 per sheet (Roblox caps an image at 1024 px), over 3 sheets
local Sheets = {};

for Index = 1, 3 do
    local Path = `von_{Index}.png`;

    if not isfile(Path) then
        writefile(Path, base64decode(game:HttpGet(`https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/von_{Index}.txt`)));
    end

    Sheets[Index] = getcustomasset(Path);
end

-- all three load up front, so switching sheets mid-loop never blinks
game:GetService("ContentProvider"):PreloadAsync(Sheets);

-- ProggyClean rebuilt pixel-sharp for TextSize 12 (tools/robloxfont.py); it is only sharp at exactly 12
local Proggy = nil;

do
    local FontPath = "ProggyClean_12.ttf";

    if not isfile(FontPath) then
        writefile(FontPath, base64decode(game:HttpGet("https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/ProggyClean_12.txt")));
    end

    writefile("ProggyClean_12.font", game:GetService("HttpService"):JSONEncode({
        name = "ProggyClean",
        faces = { { name = "Normal", weight = 400, style = "Normal", assetId = getcustomasset(FontPath) } },
    }));

    Proggy = Font.new(getcustomasset("ProggyClean_12.font"));
end

-- a 1 px black outline; Miter joins, since the default Round joins half-light the corners
local function Outline(Label)
    Label.TextStrokeTransparency = 1;

    local Stroke = Instance.new("UIStroke");
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
    Stroke.LineJoinMode = Enum.LineJoinMode.Miter;
    Stroke.Color = Color3.new(0, 0, 0);
    Stroke.Thickness = 1;
    Stroke.Parent = Label;
end

G2L["5"] = Instance.new("ImageLabel", G2L["2"]);
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["BackgroundTransparency"] = 1;
G2L["5"]["Size"] = UDim2.new(0, 250, 0, 250);
G2L["5"]["Position"] = UDim2.new(0.05805, 0, 0.01515, 0);
G2L["5"]["Name"] = [[Logo_Image]];
G2L["5"]["Image"] = Sheets[1];
G2L["5"]["ImageRectSize"] = Vector2.new(170, 170);

do
    local Logo, LastFrame = G2L["5"], nil;
    local Connection = nil;

    Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not Logo.Parent then
            Connection:Disconnect();
            return;
        end

        local Frame = math.floor(os.clock() * 25) % 75;

        if Frame == LastFrame then
            return;
        end

        LastFrame = Frame;

        local Cell = Frame % 36;

        Logo.Image = Sheets[Frame // 36 + 1];
        Logo.ImageRectOffset = Vector2.new(Cell % 6 * 170, Cell // 6 * 170);
    end);
end

-- StarterGui.ScreenGui.LoadingWindow_Frame.Logo_Image.UIStroke
G2L["6"] = Instance.new("UIStroke", G2L["5"]);
G2L["6"]["Color"] = Color3.fromRGB(93, 94, 94);
G2L["6"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["6"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

-- StarterGui.ScreenGui.LoadingWindow_Frame.Logo_Image.UIStroke
G2L["7"] = Instance.new("UIStroke", G2L["5"]);
G2L["7"]["BorderOffset"] = UDim.new(0, 1);
G2L["7"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["7"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

-- StarterGui.ScreenGui.LoadingWindow_Frame.Logo_Image.UIGradient
G2L["8"] = Instance.new("UIGradient", G2L["5"]);
G2L["8"]["Rotation"] = -90;
G2L["8"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(75, 75, 75)),ColorSequenceKeypoint.new(0.526, Color3.fromRGB(176, 188, 240)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(176, 188, 240))};

-- StarterGui.ScreenGui.LoadingWindow_Frame.UIPadding
G2L["9"] = Instance.new("UIPadding", G2L["2"]);
G2L["9"]["PaddingTop"] = UDim.new(0, 10);
G2L["9"]["PaddingRight"] = UDim.new(0, 10);
G2L["9"]["PaddingLeft"] = UDim.new(0, 10);
G2L["9"]["PaddingBottom"] = UDim.new(0, 10);

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame
G2L["a"] = Instance.new("Frame", G2L["2"]);
G2L["a"]["BorderSizePixel"] = 0;
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(176, 188, 240);
G2L["a"]["Size"] = UDim2.new(0, 250, 0, 10);
G2L["a"]["Position"] = UDim2.new(0.05965, 0, 0.91129, 0);
G2L["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a"]["Name"] = [[LoadingBar_Frame]];
G2L["a"]["BackgroundTransparency"] = 1;

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame.UIStroke
G2L["b"] = Instance.new("UIStroke", G2L["a"]);
G2L["b"]["Color"] = Color3.fromRGB(93, 94, 94);
G2L["b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["b"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame.UIStroke
G2L["c"] = Instance.new("UIStroke", G2L["a"]);
G2L["c"]["BorderOffset"] = UDim.new(0, 1);
G2L["c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame.BarFill_Frame
G2L["d"] = Instance.new("Frame", G2L["a"]);
G2L["d"]["BorderSizePixel"] = 0;
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(176, 188, 240);
G2L["d"]["Size"] = UDim2.new(0, 125, 0, 10);
G2L["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["Name"] = [[BarFill_Frame]];

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame.BarFill_Frame.BarFillVaule_Frame
G2L["e"] = Instance.new("TextLabel", G2L["d"]);
G2L["e"]["TextStrokeTransparency"] = 0;
G2L["e"]["BorderSizePixel"] = 0;
G2L["e"]["TextSize"] = 12;
G2L["e"]["TextXAlignment"] = Enum.TextXAlignment.Right;
G2L["e"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(176, 188, 240);
G2L["e"]["FontFace"] = Proggy;
G2L["e"]["TextColor3"] = Color3.fromRGB(176, 188, 240);
G2L["e"]["BackgroundTransparency"] = 1;
G2L["e"]["Size"] = UDim2.new(0, 200, 0, 50);
G2L["e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["e"]["Text"] = [[50%]];
G2L["e"]["Name"] = [[BarFillVaule_Frame]];
Outline(G2L["e"]);

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame.BarFill_Frame.UIListLayout
G2L["f"] = Instance.new("UIListLayout", G2L["d"]);
G2L["f"]["HorizontalFlex"] = Enum.UIFlexAlignment.Fill;
G2L["f"]["VerticalFlex"] = Enum.UIFlexAlignment.Fill;
G2L["f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame.BarFill_Frame.UIGradient
G2L["10"] = Instance.new("UIGradient", G2L["d"]);
G2L["10"]["Rotation"] = -90;
G2L["10"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(75, 75, 75)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(176, 188, 240))};

-- StarterGui.ScreenGui.LoadingWindow_Frame.LoadingBar_Frame.UIListLayout
G2L["11"] = Instance.new("UIListLayout", G2L["a"]);
G2L["11"]["VerticalFlex"] = Enum.UIFlexAlignment.Fill;
G2L["11"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

-- StarterGui.ScreenGui.LoadingWindow_Frame.Loading _Label
G2L["12"] = Instance.new("TextLabel", G2L["2"]);
G2L["12"]["TextStrokeTransparency"] = 0;
G2L["12"]["BorderSizePixel"] = 0;
G2L["12"]["TextSize"] = 12;
G2L["12"]["BackgroundColor3"] = Color3.fromRGB(176, 188, 240);
G2L["12"]["FontFace"] = Proggy;
G2L["12"]["TextColor3"] = Color3.fromRGB(176, 188, 240);
G2L["12"]["BackgroundTransparency"] = 1;
G2L["12"]["Size"] = UDim2.new(0, 250, 0, 19);
G2L["12"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["12"]["Text"] = [[Loading...]];
G2L["12"]["Name"] = [[Loading _Label]];
G2L["12"]["Position"] = UDim2.new(0.05614, 0, 0.94577, 0);
Outline(G2L["12"]);

-- StarterGui.ScreenGui.LoadingWindow_Frame.UIGradient
G2L["13"] = Instance.new("UIGradient", G2L["2"]);
G2L["13"]["Rotation"] = -90;
G2L["13"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(75, 75, 75)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(176, 188, 240))};

return G2L["1"], require;
