
    if getgenv().EspLibrary and getgenv().EspLibrary.Unload then
        pcall(getgenv().EspLibrary.Unload, getgenv().EspLibrary)
    end

    local GetService = setmetatable({}, {
        __index = function(_, Name)
            return game:GetService(Name);
        end;
    })

        local Workspace, Players, RunService, HttpService, CollectionService = GetService["Workspace"], GetService["Players"], GetService["RunService"], GetService["HttpService"], GetService["CollectionService"];
        local LocalPlayer, Camera = Players.LocalPlayer, Workspace.CurrentCamera;
        local WorldToViewportPoint, FindFirstChildOfClass, FindFirstChild = (Camera and Camera.WorldToViewportPoint), game.FindFirstChildOfClass, game.FindFirstChild;

        local NewVector3, NewVector2, Dim, Dim2, DimOffset = Vector3.new, Vector2.new, UDim.new, UDim2.new, UDim2.fromOffset;
        local NumSeq = NumberSequence.new;
        local NumKey = NumberSequenceKeypoint.new;

        local Format, Spawn, Clear, Floor, Clamp, Abs, Tan, Rad, Huge, Remove = string.format, task.spawn, table.clear, math.floor, math.clamp, math.abs, math.tan, math.rad, math.huge, table.remove;
        local Frame, ZeroVector3, CameraPosition, FocalLength, ViewPortY, Updates = 1 / 60, NewVector3(0,0,0), NewVector3(0,0,0), 0, 0, 0;

        local CachedFocalLength = 0
        local CameraFrame
        local Now = 0
        local CameraConnections = {}
        local function CameraCache()
            if not Camera then return end
            ViewPortY = Camera.ViewportSize.Y
            CachedFocalLength = ViewPortY / (2 * Tan(Rad(Camera.FieldOfView) * 0.5))
        end
        local function BindCamera()
            for _, connection in CameraConnections do connection:Disconnect() end
            table.clear(CameraConnections)
            Camera = Workspace.CurrentCamera
            if not Camera then return end
            WorldToViewportPoint = Camera.WorldToViewportPoint
            CameraCache()
            CameraConnections[1] = Camera:GetPropertyChangedSignal("FieldOfView"):Connect(CameraCache)
            CameraConnections[2] = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(CameraCache)
        end
        getgenv().EspLibrary = {
            ['Directory'] = 'Esp',
            ['Cache'] = {},
            ['Holder'] = nil,
            ['Threads'] = {},
            ['Connections'] = {},

            ['Table'] = {
                ['Enabled'] = true,
                ['Npcs'] = true,
                ['NpcTags'] = { 'FustNpc' },
                ['Distance'] = 500,
                ['Boxes'] = {
                    ['Enabled'] = true,
                    ['Bounding Box'] = {
                        ['Enabled'] = true,
                        ['IncludeAcsessories'] = false,
                        ['BoxX'] = 0,
                        ['BoxY'] = 2,
                    },

                    ['Box Glow'] = {
                        ['Enabled'] = true,
                        ['Top'] = Color3.fromRGB(255, 255, 255),
                        ['Bot'] = Color3.fromRGB(255, 255, 255),
                        ['Transparency'] = {0.85, 0.85},
                    },

                    ['Gradients'] = {
                        ['Top'] = Color3.fromRGB(255, 255, 255),
                        ['Bot'] = Color3.fromRGB(255, 255, 255),
                    },

                    ['Filled'] = {
                        ['Enabled'] = true,
                        ['Top'] = Color3.fromRGB(255, 255, 255),
                        ['Bot'] = Color3.fromRGB(255, 255, 255),
                        ['Transparency'] = {0.85, 0.85},
                    },
                },

                ['Bars'] = {
                    ['Health Bar'] = {
                        ['Enabled'] = true,
                        ['Top'] = Color3.fromRGB(255, 255, 255),
                        ['Mid'] = Color3.fromRGB(255, 255, 255),
                        ['Bot'] = Color3.fromRGB(200, 200, 200),
                    },
                    ['Armor Bar'] = {
                        ['Enabled'] = false,
                        ['Top'] = Color3.fromRGB(100, 180, 255),
                        ['Mid'] = Color3.fromRGB(60, 120, 220),
                        ['Bot'] = Color3.fromRGB(30, 60, 180),
                    },
                },
				
                ['Texts'] = {
                    ['Name'] = {
                        ['Enabled'] = true,
                        ['Color'] = Color3.fromRGB(255, 255, 255),
                    },
                    ['Distance'] = {
                        ['Enabled'] = true,
                        ['Color'] = Color3.fromRGB(200, 200, 200),
                    },
                    ['Weapon'] = {
                        ['Enabled'] = true,
                        ['Color'] = Color3.fromRGB(255, 0, 0),
                    },
                },
            },
        }

        local EspLibrary = getgenv().EspLibrary
        local Table = EspLibrary.Table

        Table.UpdateRate = 60 
        Table.DetailRate = 10 
        Table.TeamCheck = true
        BindCamera()
        EspLibrary.Connections.Camera = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(BindCamera)

		local Fonts = { }; do
			local function FontsRegister(Name, Weight, Style, Asset)
				if not isfile(Asset.Id) then writefile(Asset.Id, game:HttpGet(Asset.Url)) end

				if isfile(Name .. ".font") then
					delfile(Name .. ".font")
				end

				local Info = {
					name = Name,
					faces = {
						{
							name = "Normal",
							weight = Weight,
							style = Style,
							assetId = getcustomasset(Asset.Id)
						}
					}
				}

				writefile(Name .. ".font", HttpService:JSONEncode(Info))

				return getcustomasset(Name .. ".font")
			end

			Fonts.Tahoma = FontsRegister("Tahoma", 400, "Normal", {
				Id = "Tahoma.ttf",
				Url = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf"
			})

			Fonts.SmallestPixel = FontsRegister("SmallestPixel", 400, "Normal", {
				Id = "smallest_pixel-7.ttf",
				Url = "https://raw.githubusercontent.com/sametexe001/luas/main/smallest_pixel-7.ttf"
			})

			Fonts.ProggyClean = FontsRegister("ProggyClean", 400, "Normal", {
				Id = "ProggyClean.ttf",
				Url = "https://github.com/i77lhm/storage/raw/main/fonts/ProggyClean.ttf"
			})

			EspLibrary.ProggyClean = Font.new(Fonts.ProggyClean, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			EspLibrary.Tahoma = Font.new(Fonts.Tahoma, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			EspLibrary.SmallestPixel = Font.new(Fonts.SmallestPixel, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		end

        EspLibrary.__index = EspLibrary; 

        function EspLibrary:CreateObjects(Name, Prop)
            local New = Instance.new(Name);
            for Property, Value in Prop or {} do
                New[Property] = Value;
            end;
            return New;
        end

        function EspLibrary:CreateThreads(Name, Signal, Callback)
            local Connection = Signal:Connect(Callback);
            self.Threads[Name] = Connection;
            return Connection;
        end

        EspLibrary.Holder = EspLibrary:CreateObjects("ScreenGui", {
            Name = "\n",
            Parent = gethui(),
            ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            ResetOnSpawn = false,
            DisplayOrder = 10000,
            IgnoreGuiInset = true,
        })

        function EspLibrary:InitEsp(Data)
            local Objects = Data.Objects

            do
                Objects["TargetHolder"] = self:CreateObjects("Frame", {
                    Parent = self.Holder,
                    Visible = false,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["TopHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["TargetHolder"],
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = true,
                    BackgroundTransparency = 1,
                    AnchorPoint = NewVector2(0, 1),
                    Position = Dim2(0, -2, 0, -5),
                    Size = Dim2(1, 4, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["BottomHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["TargetHolder"],
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = true,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, -2, 1, 3),
                    Size = Dim2(1, 4, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["LeftHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["TargetHolder"],
                    AutomaticSize = Enum.AutomaticSize.X,
                    Visible = true,
                    BackgroundTransparency = 1,
                    AnchorPoint = NewVector2(1, 0),
                    Position = Dim2(0, -5, 0, -2),
                    Size = Dim2(0, 0, 1, 4),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["RightHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["TargetHolder"],
                    AutomaticSize = Enum.AutomaticSize.X,
                    Visible = true,
                    BackgroundTransparency = 1,
                    Position = Dim2(1, 5, 0, -2),
                    Size = Dim2(0, 0, 1, 4),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })
            end

            do
                Objects["TopTextHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["TopHolder"],
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = true,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["BottomTextHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["BottomHolder"],
                    LayoutOrder = 2,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = true,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["LeftTextHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["LeftHolder"],
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Visible = true,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["RightTextHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["RightHolder"],
                    LayoutOrder = 2,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Visible = true,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })
            end

            do
                Objects["LeftBarHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["LeftHolder"],
                    AutomaticSize = Enum.AutomaticSize.X,
                    Visible = false,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["BottomBarHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["BottomHolder"],
                    LayoutOrder = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = false,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })
            end

            do
                self:CreateObjects("UIListLayout", {
                    Parent = Objects["TopTextHolder"],
                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = Dim(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["BottomTextHolder"],
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = Dim(0, -1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["LeftTextHolder"],
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = Dim(0, 0),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["RightTextHolder"],
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = Dim(0, 0),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["LeftBarHolder"],
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = Dim(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["BottomBarHolder"],
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = Dim(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["TopHolder"],
                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                    Padding = Dim(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["BottomHolder"],
                    Padding = Dim(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["LeftHolder"],
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = Dim(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                self:CreateObjects("UIListLayout", {
                    Parent = Objects["RightHolder"],
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = Dim(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
            end

            do
                self:CreateObjects("UIPadding", {
                    Parent = Objects["TopTextHolder"],
                    PaddingBottom = Dim(0, 0),
                })

                self:CreateObjects("UIPadding", {
                    Parent = Objects["BottomTextHolder"],
                    PaddingTop = Dim(0, -1)
                })

                self:CreateObjects("UIPadding", {
                    Parent = Objects["LeftTextHolder"],
                    PaddingTop = Dim(0, -3),
                })

                self:CreateObjects("UIPadding", {
                    Parent = Objects["RightTextHolder"],
                    PaddingTop = Dim(0, -3),
                })

                self:CreateObjects("UIPadding", {
                    Parent = Objects["LeftBarHolder"],
                    PaddingRight = Dim(0, 1),
                })

                self:CreateObjects("UIPadding", {
                    Parent = Objects["BottomBarHolder"],
                    PaddingTop = Dim(0, 3),
                })

                self:CreateObjects("UIPadding", {
                    Parent = Objects["LeftHolder"],
                    PaddingRight = Dim(0, 1),
                })
            end

            do
                Objects["BoxGlow"] = self:CreateObjects("ImageLabel", {
                    Parent = Objects["TargetHolder"],
                    Image = "rbxassetid://110204605000367",
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(NewVector2(21, 21), NewVector2(79, 79)),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    ImageTransparency = 0.65,
                    ResampleMode = Enum.ResamplerMode.Pixelated,
                    Visible = true,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, -21, 0, -21),
                    Size = Dim2(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["BoxGlowGradient"] = self:CreateObjects("UIGradient", {
                    Parent = Objects["BoxGlow"],
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
                    }),
                    Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
                })

                self:CreateObjects("UIPadding", {
                    Parent = Objects["BoxGlow"],
                    PaddingTop = Dim(0, 21),
                    PaddingBottom = Dim(0, 20),
                    PaddingLeft = Dim(0, 21),
                    PaddingRight = Dim(0, 20),
                })

                Objects["BoxOutlineHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["BoxGlow"],
                    Visible = false,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["BoxOutline"] = self:CreateObjects("UIStroke", {
                    Parent = Objects["BoxOutlineHolder"],
                    Thickness = 3,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["BoxOutlineGradient"] = self:CreateObjects("UIGradient", {
                    Parent = Objects["BoxOutline"],
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
                    }),
                    Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
                })

                Objects["BoxInlineHolder"] = self:CreateObjects("Frame", {
                    Parent = Objects["BoxGlow"],
                    Visible = false,
                    BackgroundTransparency = 1,
                    Position = Dim2(0, -1, 0, -1),
                    Size = Dim2(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["BoxInline"] = self:CreateObjects("UIStroke", {
                    Parent = Objects["BoxInlineHolder"],
                    Color = Color3.fromRGB(255, 255, 255),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["BoxInlineGradient"] = self:CreateObjects("UIGradient", {
                    Parent = Objects["BoxInline"],
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
                    }),
                    Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
                })

                Objects["BoxFill"] = self:CreateObjects("Frame", {
                    Parent = Objects["BoxGlow"],
                    Visible = false,
                    BackgroundTransparency = 0,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["BoxFillGradient"] = self:CreateObjects("UIGradient", {
                    Parent = Objects["BoxFill"],
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
                    }),
                    Transparency = NumSeq({NumKey(0, 1), NumKey(1, 1)}),
                })
            end

            do
                Objects["HealthBarOutline"] = self:CreateObjects("Frame", {
                    Parent = Objects["LeftBarHolder"],
                    ZIndex = 5,
                    LayoutOrder = 0,
                    Visible = false,
                    BackgroundTransparency = 0,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(0, 2, 1, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    ClipsDescendants = false,
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["HealthBarOutline"],
                    Thickness = 1,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["HealthBar"] = self:CreateObjects("Frame", {
                    Parent = Objects["HealthBarOutline"],
                    ZIndex = 6,
                    AnchorPoint = NewVector2(0, 1),
                    Position = Dim2(0, 0, 1, 0),
                    Size = Dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    ClipsDescendants = true,
                })

                Objects["HealthBarGradient"] = self:CreateObjects("UIGradient", {
                    Parent = Objects["HealthBar"],
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Table['Bars']['Health Bar']['Top']),
                        ColorSequenceKeypoint.new(0.5, Table['Bars']['Health Bar']['Mid']),
                        ColorSequenceKeypoint.new(1, Table['Bars']['Health Bar']['Bot']),
                    }),
                    Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
                })

                Objects["HealthBarText"] = self:CreateObjects("TextLabel", {
                    Parent = Objects["HealthBarOutline"],
                    FontFace = EspLibrary.SmallestPixel,
                    TextSize = 9,
                    ZIndex = 10,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = "",
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    AnchorPoint = NewVector2(0.5, 0.5),
                    Position = Dim2(0.5, 0, 1, 0),
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = Dim2(0, 0, 0, 0),
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["HealthBarText"],
                    Color = Color3.fromRGB(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["ArmorBarOutline"] = self:CreateObjects("Frame", {
                    Parent = Objects["BottomBarHolder"],
                    ZIndex = 5,
                    LayoutOrder = 0,
                    Visible = false,
                    BackgroundTransparency = 0,
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(1, 0, 0, 2),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    ClipsDescendants = true,
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["ArmorBarOutline"],
                    Thickness = 1,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["ArmorBar"] = self:CreateObjects("Frame", {
                    Parent = Objects["ArmorBarOutline"],
                    ZIndex = 6,
                    AnchorPoint = NewVector2(0, 0),
                    Position = Dim2(0, 0, 0, 0),
                    Size = Dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                })

                Objects["ArmorBarGradient"] = self:CreateObjects("UIGradient", {
                    Parent = Objects["ArmorBar"],
                    Rotation = 0,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Table['Bars']['Armor Bar']['Top']),
                        ColorSequenceKeypoint.new(0.5, Table['Bars']['Armor Bar']['Mid']),
                        ColorSequenceKeypoint.new(1, Table['Bars']['Armor Bar']['Bot']),
                    }),
                    Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
                })

                Objects["ArmorBarText"] = self:CreateObjects("TextLabel", {
                    Parent = Objects["ArmorBar"],
                    FontFace = EspLibrary.SmallestPixel,
                    TextSize = 9,
                    ZIndex = 10,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = "",
                    TextXAlignment = Enum.TextXAlignment.Center,
                    AnchorPoint = NewVector2(0.5, 0.5),
                    Position = Dim2(0.5, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = Dim2(0, 0, 0, 0),
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["ArmorBarText"],
                    Color = Color3.fromRGB(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })
            end

            do
                Objects["TargetName"] = self:CreateObjects("TextLabel", {
                    Parent = Objects["TopTextHolder"],
                    FontFace = EspLibrary.Tahoma,
                    TextSize = 12,
                    LayoutOrder = 2,
                    TextColor3 = Table['Texts']['Name']['Color'],
                    Text = "",
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = Dim2(0, 0, 0, 0),
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["TargetName"],
                    Color = Color3.fromRGB(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["Distance"] = self:CreateObjects("TextLabel", {
                    Parent = Objects["BottomTextHolder"],
                    FontFace = EspLibrary.SmallestPixel,
                    TextSize = 9,
                    LayoutOrder = 2,
                    TextColor3 = Table['Texts']['Distance']['Color'],
                    Text = "",
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = Dim2(0, 0, 0, 0),
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["Distance"],
                    Color = Color3.fromRGB(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["WalkFlag"] = self:CreateObjects("TextLabel", {
                    Parent = Objects["RightTextHolder"],
                    FontFace = EspLibrary.SmallestPixel,
                    TextSize = 9,
                    LayoutOrder = 1,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = "Walking",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = Dim2(0, 0, 0, 0),
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["WalkFlag"],
                    Color = Color3.fromRGB(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["JumpFlag"] = self:CreateObjects("TextLabel", {
                    Parent = Objects["RightTextHolder"],
                    FontFace = EspLibrary.SmallestPixel,
                    TextSize = 9,
                    LayoutOrder = 2,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = "Jumping",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = Dim2(0, 0, 0, 0),
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["JumpFlag"],
                    Color = Color3.fromRGB(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })

                Objects["Weapon"] = self:CreateObjects("TextLabel", {
                    Parent = Objects["BottomTextHolder"],
                    FontFace = EspLibrary.SmallestPixel,
                    TextSize = 9,
                    LayoutOrder = 3,
                    TextColor3 = Table['Texts']['Weapon']['Color'],
                    Text = "none",
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = Dim2(0, 0, 0, 0),
                })

                self:CreateObjects("UIStroke", {
                    Parent = Objects["Weapon"],
                    Color = Color3.fromRGB(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                })
            end
        end

        function EspLibrary:CalculateBox(Data)
            local RootPart = Data['RootPart']

            if not RootPart then
                return nil, nil, nil, nil, false;
            end;

            local RootScreen, OnScreen = WorldToViewportPoint(Camera, RootPart.Position)

            if not OnScreen then
                return nil, nil, nil, nil, false;
            end;

            local BoundingBox = Table['Boxes']['Bounding Box'];

            if BoundingBox['Enabled'] then
                local Children = Data['Children'];

                if not Children then
                    return nil, nil, nil, nil, false;
                end;

                local IncludeAccessories = BoundingBox.IncludeAccessories or BoundingBox['IncludeAcsessories'];
                local ScrMinX, ScrMinY = Huge, Huge;
                local ScrMaxX, ScrMaxY = -Huge, -Huge;
                local HasValidParts = false;

                for _, Part in Children do
                    if Part.Transparency ~= 1 and Part ~= RootPart then
                        local Parent = Part.Parent

                        if Parent == nil then
                            continue
                        end

                        if not IncludeAccessories and Parent:IsA('Accessory') then
                            continue;
                        end;

                        local PartScreen, PartOnScreen = WorldToViewportPoint(Camera, Part.Position);

                        if not PartOnScreen or PartScreen.Z <= 0 then
                            continue;
                        end;

                        HasValidParts = true;

                        local Cf = CameraFrame:ToObjectSpace(Part.CFrame);
                        local Sz = Part.Size;
                        local HX, HY, HZ = Sz.X * 0.5, Sz.Y * 0.5, Sz.Z * 0.5;
                        local RX, UY, LZ = Cf.RightVector, Cf.UpVector, Cf.LookVector;
                        local DepthScale = CachedFocalLength / PartScreen.Z;

                        local Ex = (Abs(RX.X * HX) + Abs(UY.X * HY) + Abs(LZ.X * HZ)) * DepthScale;
                        local Ey = (Abs(RX.Y * HX) + Abs(UY.Y * HY) + Abs(LZ.Y * HZ)) * DepthScale;

                        local PMinX, PMaxX = PartScreen.X - Ex, PartScreen.X + Ex;
                        local PMinY, PMaxY = PartScreen.Y - Ey, PartScreen.Y + Ey;

                        if PMinX < ScrMinX then ScrMinX = PMinX; end
                        if PMaxX > ScrMaxX then ScrMaxX = PMaxX; end
                        if PMinY < ScrMinY then ScrMinY = PMinY; end
                        if PMaxY > ScrMaxY then ScrMaxY = PMaxY; end
                    end;
                end;

                if not HasValidParts then
                    return nil, nil, nil, nil, false;
                end;

                local PadX = BoundingBox['BoxX'];
                local PadY = BoundingBox['BoxY'];
                local W = (ScrMaxX - ScrMinX) + PadX;
                local H = (ScrMaxY - ScrMinY) + PadY;

                return W, H, ScrMinX - (PadX * 0.5), ScrMinY - (PadY * 0.5), true;
            else
                local Scale = (RootPart.Size.Y * ViewPortY) / (RootScreen.Z * 2);
                local W, H = 3 * Scale, 4.5 * Scale;
                return W, H, RootScreen.X - (W * 0.5), RootScreen.Y - (H * 0.5), OnScreen;
            end
        end

        
        function EspLibrary:AddTarget(Target)
            if Target == LocalPlayer then
                return
            end;

            if self.Cache[Target] then
                return
            end;

            local IsNpc = not Target:IsA("Player")
            local Player = not IsNpc and Target or nil

            local Data = {
                ['Player'] = Player,
                ['IsNpc'] = IsNpc,
                ['Name'] = IsNpc and Target.Name or nil,
                ['Binding'] = false,
                ['Objects'] = {},
                ['Conns'] = {},
                ['Character'] = nil,
                ['RootPart'] = nil,
                ['Humanoid'] = nil,
                ['Children'] = nil,
                ['Health'] = 0,
                ['MaxHealth'] = 100,
                ['Armor'] = 100,
                ['MaxArmor'] = 100,
                ['CurrentTool'] = nil,
                ['Alive'] = false,
                ['LastW'] = nil,
                ['LastH'] = nil,
                ['LastX'] = nil,
                ['LastY'] = nil,
                ['WalkActive'] = false,
                ['JumpActive'] = false,
                ['IncludeAccessories'] = Table['Boxes']['Bounding Box']['IncludeAcsessories'],
                ['LastGlowTop'] = nil,
                ['LastGlowBot'] = nil,
                ['LastGlowT1'] = nil,
                ['LastGlowT2'] = nil,
                ['LastGradTop'] = nil,
                ['LastGradBot'] = nil,
                ['LastFillTop'] = nil,
                ['LastFillBot'] = nil,
                ['LastFillT1'] = nil,
                ['LastFillT2'] = nil,
                ['LastDist'] = nil,
                ['LastDistColor'] = nil,
                ['LastDisplayName'] = nil,
                ['LastNameColor'] = nil,
                ['LastHealthTop'] = nil,
                ['LastHealthMid'] = nil,
                ['LastHealthBot'] = nil,
                ['LastHealthFloor'] = nil,
                ['LastRatio'] = nil,
                ['LastArmorTop'] = nil,
                ['LastArmorMid'] = nil,
                ['LastArmorBot'] = nil,
                ['LastArmorFloor'] = nil,
                ['LastArmorRatio'] = nil,
                ['LastWeapon'] = nil,
                ['LastWeaponColor'] = nil,
            }
            self:InitEsp(Data);
            self['Cache'][Target] = Data;

            local HealthHandler = {}; do
                function HealthHandler.BindHealth(Humanoid)
                    if Data['Conns']['Health'] then
                        Data['Conns']['Health']:Disconnect()
                    end

                    if Data['Conns']['Died'] then
                        Data['Conns']['Died']:Disconnect()
                    end

                    Data['Humanoid'] = Humanoid
                    Data['Health'] = Humanoid.Health
                    Data['MaxHealth'] = Humanoid.MaxHealth
                    Data['Alive'] = Humanoid.Health > 0

                    Data['Conns']['Health'] = Humanoid.HealthChanged:Connect(function(NewHealth)
                        Data['Alive'] = NewHealth > 0
                        Data['Health'] = NewHealth
                    end)

                    Data.Conns.MaxHealth = Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
                        Data.MaxHealth = Humanoid.MaxHealth
                    end)
                    Data['Conns']['Died'] = Humanoid.Died:Connect(function()
                        Data['Alive'] = false
                    end)

                    
                    if Data.IsNpc then
                        local Model = Data.Character
                        if Model:GetAttribute("Dead") == true then
                            Data['Alive'] = false
                        end
                        Data.Conns.NpcDead = Model:GetAttributeChangedSignal("Dead"):Connect(function()
                            if Model:GetAttribute("Dead") == true then
                                Data['Alive'] = false
                            end
                        end)
                    end
                end

                Data['BindHealth'] = HealthHandler.BindHealth;
            end

            local ToolHandler = {}; do
                function ToolHandler.BindTool(Character)
                    if Data['Conns']['ToolAdded'] then
                        Data['Conns']['ToolAdded']:Disconnect()
                    end

                    if Data['Conns']['ToolRemoved'] then
                        Data['Conns']['ToolRemoved']:Disconnect()
                    end

                    
                    if Data.IsNpc then
                        local function GetWeapon()
                            local Gun = Character:FindFirstChild("Gun")
                            local Weapon = Character:GetAttribute("Weapon") or (Gun and Gun:GetAttribute("ItemId"))
                            return type(Weapon) == "string" and Weapon or nil
                        end

                        Data.CurrentTool = GetWeapon()
                        Data['Conns']['ToolAdded'] = Character:GetAttributeChangedSignal("Weapon"):Connect(function()
                            Data.CurrentTool = GetWeapon()
                        end)
                        return
                    end

                    local tool = Character:FindFirstChildOfClass("Tool")
                    Data.CurrentTool = tool and tool.Name or nil
                    Data['Conns']['ToolAdded'] = Character.ChildAdded:Connect(function(Child)
                        if Child:IsA('Tool') then
                            Data['CurrentTool'] = Child.Name
                        end
                    end)

                    Data['Conns']['ToolRemoved'] = Character.ChildRemoved:Connect(function(Child)
                        if Child:IsA('Tool') then
                            local remaining = Character:FindFirstChildOfClass("Tool")
                            Data.CurrentTool = remaining and remaining.Name or nil
                        end
                    end)
                end

                Data['BindTool'] = ToolHandler.BindTool
            end

            local ChildHandler = {}; do
                function ChildHandler.BindChildren(Character)
                    if Data['Conns']['ChildAdded'] then
                        Data['Conns']['ChildAdded']:Disconnect();
                    end;

                    if Data['Conns']['ChildRemoved'] then
                        Data['Conns']['ChildRemoved']:Disconnect();
                    end;

                    local Children, Indices = {}, {}
                    Data.Children = Children
                    local function AddPart(child)
                        if child:IsA("BasePart") and not Indices[child] then
                            Children[#Children + 1] = child
                            Indices[child] = #Children
                        end
                    end
                    local function RemovePart(child)
                        local index = Indices[child]
                        if not index then return end
                        local last = Children[#Children]
                        Children[index] = last
                        Indices[last] = index
                        Children[#Children] = nil
                        Indices[child] = nil
                    end
                    Data.Conns.ChildAdded = Character.DescendantAdded:Connect(AddPart)
                    Data.Conns.ChildRemoved = Character.DescendantRemoving:Connect(RemovePart)
                    for _, child in Character:GetDescendants() do AddPart(child) end
                    Data['BindTool'](Character);
                end

                Data['BindChildren'] = ChildHandler.BindChildren;
            end

            local FlagsHandler = {}; do
                function FlagsHandler.BindFlags(Humanoid)
                    if Data['Conns']['MoveDir'] then
                        Data['Conns']['MoveDir']:Disconnect();
                    end;

                    if Data['Conns']['StateChange'] then
                        Data['Conns']['StateChange']:Disconnect();
                    end;

                    local Objects = Data['Objects']
                    Data['JumpActive'] = false;
                    Data['WalkActive'] = false;

                    Objects['WalkFlag'].Visible = false;
                    Objects['JumpFlag'].Visible = false;

                    Data['Conns']['MoveDir'] = Humanoid:GetPropertyChangedSignal('MoveDirection'):Connect(function()
                        local Walking = Humanoid.MoveDirection ~= ZeroVector3;

                        if Walking and not Data['WalkActive'] then
                            Data['WalkActive'] = true;

                            if Data['JumpActive'] then
                                Objects['WalkFlag'].LayoutOrder = 2;
                            else
                                Objects['WalkFlag'].LayoutOrder = 1;
                                Objects['JumpFlag'].LayoutOrder = 2;
                            end

                            Objects['WalkFlag'].Visible = true
                        elseif not Walking and Data['WalkActive'] then
                            Data['WalkActive'] = false;
                            Objects['WalkFlag'].Visible = false;

                            if Data['JumpActive'] then
                                Objects['JumpFlag'].LayoutOrder = 1;
                            end
                        end
                    end)

                    Data['Conns']['StateChange'] = Humanoid.StateChanged:Connect(function(_, NewState)
                        local Jumping = NewState == Enum.HumanoidStateType.Jumping or NewState == Enum.HumanoidStateType.Freefall

                        if Jumping and not Data['JumpActive'] then
                            Data['JumpActive'] = true;

                            if Data['WalkActive'] then
                                Objects['JumpFlag'].LayoutOrder = 2;
                            else
                                Objects['JumpFlag'].LayoutOrder = 1;
                                Objects['WalkFlag'].LayoutOrder = 2;
                            end

                            Objects['JumpFlag'].Visible = true
                        elseif not Jumping and Data['JumpActive'] then
                            Data['JumpActive'] = false;
                            Objects['JumpFlag'].Visible = false;

                            if Data['WalkActive'] then
                                Objects['WalkFlag'].LayoutOrder = 1;
                            end
                        end
                    end)
                end

                Data['BindFlags'] = FlagsHandler.BindFlags;
            end

            local KeepConns = { CharAdded = true, CharRemoving = true, CharChanged = true }

            local CharacterHandler = {}; do
                function CharacterHandler.OnCharacter(Character)
                    if self.Cache[Target] ~= Data or not Character then return end
                    if Data.Character == Character and (Data.Binding or (Data.RootPart and Data.RootPart.Parent and Character.Parent)) then return end

                    for name, connection in Data.Conns do
                        if not KeepConns[name] then
                            connection:Disconnect()
                            Data.Conns[name] = nil
                        end
                    end
                    Data.CurrentTool = nil
                    Data.NextDetail = 0
                    Data.Objects.TargetHolder.Visible = false
                    Data['Character'] = Character;
                    Data['RootPart'] = nil;
                    Data['Humanoid'] = nil;
                    Data['Children'] = nil;
                    Data['Alive'] = false;
                    Data['WalkActive'] = false;
                    Data['JumpActive'] = false;
                    Data.Binding = false

                    if not Character.Parent then
                        return;
                    end;

                    Data.Binding = true

                    local RootPart = FindFirstChild(Character, "HumanoidRootPart") or Character:WaitForChild('HumanoidRootPart', 10);
                    local Humanoid = FindFirstChildOfClass(Character, 'Humanoid') or Character:WaitForChild('Humanoid', 10);

                    
                    if self.Cache[Target] ~= Data or Data.Character ~= Character then
                        return;
                    end;

                    Data.Binding = false

                    if not RootPart or not Humanoid or not Character.Parent then
                        return;
                    end;

                    Data['RootPart'] = RootPart;
                    Data['Humanoid'] = Humanoid;

                    if Data.IsNpc then
                        Data.Name = Humanoid.DisplayName ~= "" and Humanoid.DisplayName or Character.Name
                    end

                    Data['BindChildren'](Character);
                    Data['BindHealth'](Humanoid);
                    Data['BindFlags'](Humanoid);
                end

                Data['Rebind'] = CharacterHandler.OnCharacter

                if Player then
                    Data.Conns.CharAdded = Player.CharacterAdded:Connect(CharacterHandler.OnCharacter)
                    Data.Conns.CharChanged = Player:GetPropertyChangedSignal("Character"):Connect(function()
                        if Player.Character then
                            CharacterHandler.OnCharacter(Player.Character)
                        end
                    end)
                    Data.Conns.CharRemoving = Player.CharacterRemoving:Connect(function(character)
                        if Data.Character ~= character then return end
                        Data.Character, Data.RootPart, Data.Humanoid = nil, nil, nil
                        Data.Alive = false
                        Data.Binding = false
                        Data.Objects.TargetHolder.Visible = false
                        for name, connection in Data.Conns do
                            if not KeepConns[name] then
                                connection:Disconnect()
                                Data.Conns[name] = nil
                            end
                        end
                    end)
                    if Player.Character then task.defer(CharacterHandler.OnCharacter, Player.Character) end
                else
                    task.defer(CharacterHandler.OnCharacter, Target)
                end
            end
        end

        function EspLibrary:RemoveTarget(Player)
            local Data = self['Cache'][Player];

            if not Data then
                return;
            end;

            for _, Connections in Data['Conns'] do
                Connections:Disconnect()
            end;

            Clear(Data['Conns']);

            if Data['Objects']['TargetHolder'] then
                Data['Objects']['TargetHolder']:Destroy();
            end;

            Clear(Data['Objects']);
            self['Cache'][Player] = nil;
        end

        function EspLibrary:Update(Player, Data)
            local Objects = Data['Objects']

            local Hidden
            if Data.IsNpc then
                Hidden = not Table.Npcs
            else
                Hidden = Table.TeamCheck and Player.Team == LocalPlayer.Team
            end

            
            if Hidden or not Data.RootPart or not Data.RootPart.Parent or not Data.Character or not Data.Character.Parent then
                if Objects['TargetHolder'].Visible then
                    Objects['TargetHolder'].Visible = false
                end
                return
            end

            if not Data['Alive'] then
                if Objects['TargetHolder'].Visible then
                    Objects['TargetHolder'].Visible = false
                end
                return
            end

            local RootPos = Data['RootPart'].Position
            local delta = CameraPosition - RootPos
            local distanceSquared = delta:Dot(delta)
            local limit = math.max(0, Table.Distance)
            if distanceSquared > limit * limit then
                if Objects['TargetHolder'].Visible then
                    Objects['TargetHolder'].Visible = false
                end
                return
            end

            local W, H, X, Y, OnScreen = self:CalculateBox(Data)

            if not OnScreen or not W then
                if Objects['TargetHolder'].Visible then
                    Objects['TargetHolder'].Visible = false
                end
                return
            end

            W = Floor(W)
            H = Floor(H)
            X = Floor(X)
            Y = Floor(Y)

            if not Objects['TargetHolder'].Visible then
                Objects['TargetHolder'].Visible = true
                Data.NextDetail = 0
            end

            local DirtySizes = Data['LastW'] ~= W or Data['LastH'] ~= H
            local DirtyPosition = Data['LastX'] ~= X or Data['LastY'] ~= Y

            if DirtyPosition then
                Objects['TargetHolder'].Position = DimOffset(X, Y)
                Data['LastX'] = X
                Data['LastY'] = Y
            end

            if DirtySizes then
                Objects['TargetHolder'].Size = DimOffset(W, H)
                Objects['BoxGlow'].Size = DimOffset(W, H)
                Objects['BoxOutlineHolder'].Size = DimOffset(W, H)
                Objects['BoxInlineHolder'].Size = DimOffset(W + 2, H + 2)
                Objects['BoxFill'].Size = DimOffset(W, H)
                Data['LastW'] = W
                Data['LastH'] = H
            end

            if Now < (Data.NextDetail or 0) then return end
            Data.NextDetail = Now + (Table.DetailRate > 0 and 1 / Table.DetailRate or 0)
            local Distance = Floor(math.sqrt(distanceSquared))
            local BoxesCfg = Table['Boxes']
            local TextsCfg = Table['Texts']

            if BoxesCfg['Enabled'] then
                if BoxesCfg['Box Glow']['Enabled'] then
                    if Objects['BoxGlow'].ImageTransparency ~= 0 then
                        Objects['BoxGlow'].ImageTransparency = 0
                    end

                    local GlowTop = BoxesCfg['Box Glow']['Top']
                    local GlowBot = BoxesCfg['Box Glow']['Bot']

                    if Data['LastGlowTop'] ~= GlowTop or Data['LastGlowBot'] ~= GlowBot then
                        Objects['BoxGlowGradient'].Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, GlowTop),
                            ColorSequenceKeypoint.new(1, GlowBot),
                        })
                        Data['LastGlowTop'] = GlowTop
                        Data['LastGlowBot'] = GlowBot
                    end

                    local T1 = BoxesCfg['Box Glow']['Transparency'][1]
                    local T2 = BoxesCfg['Box Glow']['Transparency'][2]

                    if Data['LastGlowT1'] ~= T1 or Data['LastGlowT2'] ~= T2 then
                        Objects['BoxGlowGradient'].Transparency = NumSeq({NumKey(0, T1), NumKey(1, T2)})
                        Data['LastGlowT1'] = T1
                        Data['LastGlowT2'] = T2
                    end
                else
                    if Objects['BoxGlow'].ImageTransparency ~= 1 then
                        Objects['BoxGlow'].ImageTransparency = 1
                    end
                end

                if not Objects['BoxOutlineHolder'].Visible then
                    Objects['BoxOutlineHolder'].Visible = true
                end

                if not Objects['BoxInlineHolder'].Visible then
                    Objects['BoxInlineHolder'].Visible = true
                end

                local GradTop = BoxesCfg['Gradients']['Top']
                local GradBot = BoxesCfg['Gradients']['Bot']

                if Data['LastGradTop'] ~= GradTop or Data['LastGradBot'] ~= GradBot then
                    Objects['BoxInlineGradient'].Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, GradTop),
                        ColorSequenceKeypoint.new(1, GradBot),
                    })
                    Data['LastGradTop'] = GradTop
                    Data['LastGradBot'] = GradBot
                end

                if BoxesCfg['Filled']['Enabled'] then
                    if not Objects['BoxFill'].Visible then
                        Objects['BoxFill'].Visible = true
                    end

                    local FillTop = BoxesCfg['Filled']['Top']
                    local FillBot = BoxesCfg['Filled']['Bot']
                    local FillT1 = BoxesCfg['Filled']['Transparency'][1]
                    local FillT2 = BoxesCfg['Filled']['Transparency'][2]

                    if Data['LastFillTop'] ~= FillTop or Data['LastFillBot'] ~= FillBot then
                        Objects['BoxFillGradient'].Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, FillTop),
                            ColorSequenceKeypoint.new(1, FillBot),
                        })
                        Data['LastFillTop'] = FillTop
                        Data['LastFillBot'] = FillBot
                    end

                    if Data['LastFillT1'] ~= FillT1 or Data['LastFillT2'] ~= FillT2 then
                        Objects['BoxFillGradient'].Transparency = NumSeq({NumKey(0, FillT1), NumKey(1, FillT2)})
                        Data['LastFillT1'] = FillT1
                        Data['LastFillT2'] = FillT2
                    end
                else
                    if Objects['BoxFill'].Visible then
                        Objects['BoxFill'].Visible = false
                    end
                end
            else
                if Objects['BoxGlow'].ImageTransparency ~= 1 then
                    Objects['BoxGlow'].ImageTransparency = 1
                end

                if Objects['BoxOutlineHolder'].Visible then
                    Objects['BoxOutlineHolder'].Visible = false
                end

                if Objects['BoxInlineHolder'].Visible then
                    Objects['BoxInlineHolder'].Visible = false
                end

                if Objects['BoxFill'].Visible then
                    Objects['BoxFill'].Visible = false
                end
            end

            if TextsCfg['Name']['Enabled'] then
                if not Objects['TargetName'].Visible then
                    Objects['TargetName'].Visible = true
                end

                local DisplayName = Data.IsNpc and Data.Name or Player.DisplayName

                if Data['LastDisplayName'] ~= DisplayName then
                    Objects['TargetName'].Text = DisplayName
                    Data['LastDisplayName'] = DisplayName
                end

                local NameColor = TextsCfg['Name']['Color']

                if Data['LastNameColor'] ~= NameColor then
                    Objects['TargetName'].TextColor3 = NameColor
                    Data['LastNameColor'] = NameColor
                end
            else
                if Objects['TargetName'].Visible then
                    Objects['TargetName'].Visible = false
                end
            end

            if TextsCfg['Distance']['Enabled'] then
                if not Objects['Distance'].Visible then
                    Objects['Distance'].Visible = true
                end

                if Data['LastDist'] ~= Distance then
                    Objects['Distance'].Text = Format('%dst', Distance)
                    Data['LastDist'] = Distance
                end

                local DistColor = TextsCfg['Distance']['Color']

                if Data['LastDistColor'] ~= DistColor then
                    Objects['Distance'].TextColor3 = DistColor
                    Data['LastDistColor'] = DistColor
                end
            else
                if Objects['Distance'].Visible then
                    Objects['Distance'].Visible = false
                end
            end

            local HealthCfg = Table['Bars']['Health Bar']
            local ArmorCfg = Table['Bars']['Armor Bar']

            if HealthCfg['Enabled'] then
                local Health = Data['Health'] or 0
                local MaxHealth = Data['MaxHealth'] or 100
                local Ratio = Clamp(Health / math.max(MaxHealth, 0.001), 0, 1)

                if not Objects['LeftBarHolder'].Visible then
                    Objects['LeftBarHolder'].Visible = true
                end

                if not Objects['HealthBarOutline'].Visible then
                    Objects['HealthBarOutline'].Visible = true
                end

                if Data['LastRatio'] ~= Ratio then
                    Objects['HealthBar'].Size = Dim2(1, 0, Ratio, 0)
                    Objects['HealthBarText'].Position = Dim2(0.5, 0, 1 - Ratio, 0)
                    Data['LastRatio'] = Ratio
                end

                local GradTop = HealthCfg['Top']
                local GradMid = HealthCfg['Mid']
                local GradBot = HealthCfg['Bot']

                if Data['LastHealthTop'] ~= GradTop or Data['LastHealthMid'] ~= GradMid or Data['LastHealthBot'] ~= GradBot then
                    Objects['HealthBarGradient'].Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, GradTop),
                        ColorSequenceKeypoint.new(0.5, GradMid),
                        ColorSequenceKeypoint.new(1, GradBot),
                    })
                    Data['LastHealthTop'] = GradTop
                    Data['LastHealthMid'] = GradMid
                    Data['LastHealthBot'] = GradBot
                end

                if Ratio < 1 then
                    if not Objects['HealthBarText'].Visible then
                        Objects['HealthBarText'].Visible = true
                    end

                    local FlooredHealth = Floor(Health)

                    if Data['LastHealthFloor'] ~= FlooredHealth then
                        Objects['HealthBarText'].Text = Format('%d', FlooredHealth)
                        Objects['HealthBarText'].Position = Dim2(0.5, 0, 1 - Ratio, 0)
                        Data['LastHealthFloor'] = FlooredHealth
                    end
                else
                    if Objects['HealthBarText'].Visible then
                        Objects['HealthBarText'].Visible = false
                    end
                end
            else
                if Objects['HealthBarOutline'].Visible then
                    Objects['HealthBarOutline'].Visible = false
                end

                if Objects['HealthBarText'].Visible then
                    Objects['HealthBarText'].Visible = false
                end

                if not ArmorCfg['Enabled'] then
                    if Objects['LeftBarHolder'].Visible then
                        Objects['LeftBarHolder'].Visible = false
                    end
                end
            end

            if ArmorCfg['Enabled'] then
                local Ratio = Clamp(Data['Armor'] / math.max(Data['MaxArmor'], 0.001), 0, 1)

                if not Objects['BottomBarHolder'].Visible then
                    Objects['BottomBarHolder'].Visible = true
                end

                if not Objects['ArmorBarOutline'].Visible then
                    Objects['ArmorBarOutline'].Visible = true
                end

                if Data['LastArmorRatio'] ~= Ratio then
                    Objects['ArmorBar'].Size = Dim2(Ratio, 0, 1, 0)
                    Data['LastArmorRatio'] = Ratio
                end

                local GradTop = ArmorCfg['Top']
                local GradMid = ArmorCfg['Mid']
                local GradBot = ArmorCfg['Bot']

                if Data['LastArmorTop'] ~= GradTop or Data['LastArmorMid'] ~= GradMid or Data['LastArmorBot'] ~= GradBot then
                    Objects['ArmorBarGradient'].Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, GradTop),
                        ColorSequenceKeypoint.new(0.5, GradMid),
                        ColorSequenceKeypoint.new(1, GradBot),
                    })
                    Data['LastArmorTop'] = GradTop
                    Data['LastArmorMid'] = GradMid
                    Data['LastArmorBot'] = GradBot
                end

                if Ratio < 1 then
                    if not Objects['ArmorBarText'].Visible then
                        Objects['ArmorBarText'].Visible = true
                    end

                    local FlooredArmor = Floor(Data['Armor'])

                    if Data['LastArmorFloor'] ~= FlooredArmor then
                        Objects['ArmorBarText'].Text = Format('%d', FlooredArmor)
                        Data['LastArmorFloor'] = FlooredArmor
                    end
                else
                    if Objects['ArmorBarText'].Visible then
                        Objects['ArmorBarText'].Visible = false
                    end
                end
            else
                if Objects['BottomBarHolder'].Visible then
                    Objects['BottomBarHolder'].Visible = false
                end

                if Objects['ArmorBarOutline'].Visible then
                    Objects['ArmorBarOutline'].Visible = false
                end

                if Objects['ArmorBarText'].Visible then
                    Objects['ArmorBarText'].Visible = false
                end
            end

            local WeaponCfg = TextsCfg['Weapon']

            if WeaponCfg['Enabled'] then
                if not Objects['Weapon'].Visible then
                    Objects['Weapon'].Visible = true
                end

                local CurrentTool = Data['CurrentTool'] or 'none'

                if Data['LastWeapon'] ~= CurrentTool then
                    Objects['Weapon'].Text = CurrentTool
                    Data['LastWeapon'] = CurrentTool
                end

                local WeaponColor = WeaponCfg['Color']

                if Data['LastWeaponColor'] ~= WeaponColor then
                    Objects['Weapon'].TextColor3 = WeaponColor
                    Data['LastWeaponColor'] = WeaponColor
                end
            else
                if Objects['Weapon'].Visible then
                    Objects['Weapon'].Visible = false
                end
            end
        end

        do
            local elapsed = 0
            EspLibrary:CreateThreads('Renderer', RunService.RenderStepped, function(dt)
                local enabled = Table.Enabled and Camera ~= nil
                if EspLibrary.Holder.Enabled ~= enabled then EspLibrary.Holder.Enabled = enabled end
                if not enabled then return end
                elapsed = elapsed + dt
                local interval = Table.UpdateRate > 0 and 1 / Table.UpdateRate or 0
                if elapsed + 0.000001 < interval then return end
                elapsed = interval > 0 and elapsed % interval or 0
                Now = os.clock()
                CameraFrame = Camera.CFrame
                CameraPosition = CameraFrame.Position
                for Player, Data in EspLibrary.Cache do EspLibrary:Update(Player, Data) end
            end)
        end
        do
            for _, Player in Players:GetPlayers() do
                EspLibrary:AddTarget(Player)
            end

            EspLibrary:CreateThreads('PlayerAdded', Players.PlayerAdded, function(Player)
                EspLibrary:AddTarget(Player)
            end)

            EspLibrary:CreateThreads('PlayerRemoving', Players.PlayerRemoving, function(Player)
                EspLibrary:RemoveTarget(Player)
            end)

            
            EspLibrary:CreateThreads('CharStreamIn', Workspace.ChildAdded, function(Child)
                if not Child:IsA("Model") then
                    return
                end

                local Player = Players:FindFirstChild(Child.Name)
                if not Player or not Player:IsA("Player") or Player == LocalPlayer then
                    return
                end

                local Data = EspLibrary.Cache[Player]
                if Data then
                    Data.Rebind(Child)
                end
            end)
        end

        do 
            local function NpcAdded(Model)
                if Model:IsA("Model") and Model:IsDescendantOf(Workspace) then
                    EspLibrary:AddTarget(Model)
                end
            end

            local function NpcRemoved(Model)
                EspLibrary:RemoveTarget(Model)
            end

            for _, Tag in Table.NpcTags do
                for _, Model in CollectionService:GetTagged(Tag) do
                    NpcAdded(Model)
                end

                EspLibrary:CreateThreads('NpcAdded' .. Tag, CollectionService:GetInstanceAddedSignal(Tag), NpcAdded)
                EspLibrary:CreateThreads('NpcRemoved' .. Tag, CollectionService:GetInstanceRemovedSignal(Tag), NpcRemoved)
            end

            local NpcFolder = Workspace:FindFirstChild("Npcs")
            if NpcFolder then
                for _, Model in NpcFolder:GetChildren() do
                    NpcAdded(Model)
                end

                EspLibrary:CreateThreads('NpcFolderAdded', NpcFolder.ChildAdded, NpcAdded)
                EspLibrary:CreateThreads('NpcFolderRemoved', NpcFolder.ChildRemoved, NpcRemoved)
            end
        end

        do
            function EspLibrary:Unload()
                for _, connection in CameraConnections do connection:Disconnect() end
                table.clear(CameraConnections)
                for Player in self['Cache'] do
                    self:RemoveTarget(Player);
                end;

                for _, Conn in self['Connections'] do
                    Conn:Disconnect();
                end;

                Clear(self['Connections']);

                for _, Conn in self['Threads'] do
                    Conn:Disconnect();
                end;

                Clear(self['Threads']);

                if self['Holder'] then
                    self['Holder']:Destroy();
                    self['Holder'] = nil;
                end;

                Clear(self['Cache']);
            end
        end

        return EspLibrary
