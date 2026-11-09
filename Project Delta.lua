-- VIVISIVON PD


--local Loader = Library:Loader({Name = 'von<font color="rgb(126, 192, 255)">.club</font>'})

if not game:IsLoaded() then
    --Loader:SetProgress(0.1, "waiting for game to load")
    game.Loaded:Wait()
end 



--#region bypass

    local Detect = filtergc("function", {Name = "detectSuspiciousObjects"}, true)

    if not isfunctionhooked(Detect) then 
        local old; old = hookfunction(Detect, function(...)
            return 
        end)
    end 

    for i, v in filtergc("function", {Name = "a"}, false) do 
        if not isfunctionhooked(v) then 
            hookfunction(v, function(...) 
                return 
            end)
        end 
    end 

    local ProjectileInflict = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ProjectileInflict")

    local DisableChecks = function(Char)
        local Humanoid = Char:WaitForChild("Humanoid", 10)

        if Humanoid then 
            for i = 1, 50 do
                for i, v in getconnections(Humanoid:GetPropertyChangedSignal("HipHeight")) do
                    local Func = v.Function

                    if Func and islclosure(Func) then 
                        local Upvalues = debug.getupvalues(Func)
                        local HasChar = false 
                        local HasFunc = false 
                        local FlagIndex = nil

                        for Index, va in Upvalues do
                            if va == Char then
                                HasChar = true
                            elseif type(va) == "function" then
                                HasFunc = true
                            elseif type(va) == "boolean" then
                                FlagIndex = Index
                            end
                        end

                        if HasChar and HasFunc and FlagIndex then
                            debug.setupvalue(Func, FlagIndex, true)
                            return true
                        end
                    end 
                end

                task.wait(0.2)
            end
        end 
    end

    if game.Players.LocalPlayer.Character then
        task.spawn(DisableChecks, game.Players.LocalPlayer.Character)
    end

    game.Players.LocalPlayer.CharacterAdded:Connect(DisableChecks)
--#endregion



--#region defs

    local Camera = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    local Players = game.Players 
    local LocalPlayer = Players.LocalPlayer 
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local HttpService = cloneref(game:GetService("HttpService"))
    local Lighting = game:GetService("Lighting")
    local Teams = game:GetService("Teams")
    local SoundService = game:GetService("SoundService")
    local Entities = ReplicatedStorage.Players
    
    local Modules = { -- Modules.
        VFX = require(ReplicatedStorage.Modules.VFX);
        SpringV2 = require(ReplicatedStorage.Modules.SpringV2);
    };

    local Remotes = { -- Remotes.
        RealFireProjectile = ReplicatedStorage.Remotes.FireProjectile;
        MeleeInflict = ReplicatedStorage.Remotes.MeleeInflict;
        MeleeReplicate = ReplicatedStorage.Remotes.MeleeReplicate;
        RealProjectileInflict = ReplicatedStorage.Remotes.ProjectileInflict;
        UpdateTilt = ReplicatedStorage.Remotes.UpdateTilt;
        Reload = ReplicatedStorage.Remotes.Reload;
    };

    local CreateTracer;
    local TracerEnabled = false;
    local TracerLifetime = 1;

    local SelectedTracer = "Laser 1";

    local Trails = {
        ["Laser 1"] = { Texture = "rbxassetid://7136858729", Width0 = 0.4, Width1 = 0.4, TextureLength = 1, Lifetime = TracerLifetime };
        ["Laser 2"] = { Texture = "rbxassetid://6333823534", Width0 = 0.4, Width1 = 0.4, TextureLength = 1, Lifetime = TracerLifetime };
        ["DNA"] = { Texture = "rbxassetid://7071778278", Width0 = 0.6, Width1 = 0.6, TextureLength = 12, Lifetime = TracerLifetime };
        ["Energy"]  = { Texture = "rbxassetid://5864341017", Width0 = 0.4, Width1 = 0.4, TextureLength = 1, Lifetime = TracerLifetime };
    };
--#endregion



--#region library setup
    --local amity = loadstring(game:HttpGet('https://raw.githubusercontent.com/78n/Roblox/refs/heads/main/Lua/Libraries/DataToCode/DataToCode.luau'))()

    --Loader:SetProgress(0.2, "loading libraries")
    
    
    if identifyexecutor() ~= "Atomic" then 
        setfflag("AdornShadingAPI", "true")
    end 
    
    local EspLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/EspLib.lua'))() --https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/EspLib.lua
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/BullshitLib.lua"))()-- or loadstring(game:HttpGet("https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/BullshitLib.lua"))()
    
    local Window = Library:Window({
        Name = 'von<font color="rgb(126, 192, 255)">.club</font> | developer  | lifetime',
        Rank = "developer"
    }) 

    do
        local Watermark = Window:Watermark({
            Name = "von.club",
            SubName = "von.club"
        })

        local KeybindList = Window:KeybindList({
            Name = 'hot<font color="rgb(126, 192, 255)">keys</font>'
        })
    end



    local Pages = {
        CombatPage = Window:Page({Name = "combat"});
        VisualsPage = Window:Page({Name = "visuals"});
        MiscPage = Window:Page({Name = "misc"});
    };

    local Sections = {
        aimbot = Pages.CombatPage:Section({
            Name = 'aimbot';
            Side = 1;
        });
        killaura = Pages.CombatPage:Section({
            Name = 'killaura';
            Side = 2;
        });
        antiaim = Pages.CombatPage:Section({
            Name = 'anti aim';
            Side = 1;
        });
        gunmods = Pages.CombatPage:Section({
            Name = 'gun mods';
            Side = 2;
        });
        exploits = Pages.MiscPage:Section({
            Name = 'exploits';
            Side = 1;
        });
        movement = Pages.MiscPage:Section({
            Name = 'movement';
            Side = 2;
        });
        hit = Pages.MiscPage:Section({
            Name = 'hit';
            Side = 1;
        });
        target = Pages.MiscPage:Section({
            Name = 'target';
            Side = 2;
        });
        worldesp = Pages.VisualsPage:Section({
            Name = 'world esp';
            Side = 2;
        });
        visuals = Pages.VisualsPage:Section({
            Name = 'others';
            Side = 2;
        });
        world = Pages.VisualsPage:Section({
            Name = 'world';
            Side = 2;
        });
        vmisc = Pages.VisualsPage:Section({
            Name = "misc";
            Side = 2;
        });
        Esp = Pages.VisualsPage:Section({
            Name = 'esp';
            Side = 1;
        });
        chams = Pages.VisualsPage:Section({
            Name = "chams";
            Side = 1;
        });
        AudioP = Pages.MiscPage:Section({
            Name = "spotify player";
            Side = 2;
        });

    };

--#endregion
local RagebotTarget = nil
local FovCircleEnabled = false;
local FovCircle = Drawing.new("Circle")
local TargetAi = false
local TargetVehicles = false
local AiModels = {}
local Vehicles = {}
local GetVehiclePart = function(Model)
    local Pilots = Model:FindFirstChild("Pilots")
    if Pilots then
        for _, Pilot in Pilots:GetChildren() do
            local Head = Pilot:FindFirstChild("Head")
            local Humanoid = Pilot:FindFirstChildOfClass("Humanoid")
            if Head and Humanoid and Humanoid.Health > 0 then
                return Head
            end
        end
    end
    local Root = Model.PrimaryPart
    if Root and (Root:GetAttribute("Health") or 1) > 0 then
        return Root
    end
end

do 
    --Loader:SetProgress(0.3, "loading combat")
    local NoDrown = false;
    local InstantBulletEnabled = false
    local NoGearWeight = false 
    local FakeLatency = false 
    local LastPing = 0
    local NoSpread = false;
    local ManipulatedOrigin = nil
    local ManipulatedPart = nil
    local ManipulatedAimDir = nil
    local SilentHitPart = nil 
    local premaniporigin = nil
    local premanippart = nil
    local lastmanipscan = 0
    local AntiAimEnabled = false
    local PitchMode = "down"
    local YawMode = "backwards"
    local JitterFlip = false

    do -- combat
        local SilentAimEnabled = false;
        local NoSpreadEnabled = false;
        local ManipEnabled = false;
        local NoRecoilEnabled = false;
        local RageBotEnabled = false;
        local SilentReload = false;
        local RapidFireEnabled = false;
        local FireRate = 0;
        local InstantReload = false;
        local ForceFullAuto = false;
        local RestoreWait = 0;

        local SilentAimTarget = nil
        local NoSwayEnabled = false
        local KillauraEnabled = false
        local AutoReloadEnabled = false
        local KillauraRange = 10
        local LastSwing = 0
        local LastScan = 0
        local Controller = nil
        local PendingInstant = nil
        local InstantShots = {}


        local DoubleTapEnabled = false   
        local DoubleTapFiring = false
        local KillauraFanOut = false     

        local ForceAuto = false;
        local Resolver = false 

        local Cache = {}

        local DoCache = function(v)
            task.defer(function()
                local Char = v.Character

                if not Char then
                    return
                end

                local HRP = Char:FindFirstChild("HumanoidRootPart")
                local Ent = Entities:FindFirstChild(v.Name)

                if not HRP or not Ent then
                    return
                end

                local Status = Ent:FindFirstChild("Status")

                if not Status then
                    return
                end

                local UAC = Status:FindFirstChild("UAC")

                if not UAC then
                    return
                end

                Cache[v] = { HRP = HRP, UAC = UAC, LastPos = nil }
            end)
        end

        for _, v in Players:GetPlayers() do
            if v == LocalPlayer then continue end

            v.CharacterAdded:Connect(function()
                DoCache(v)
            end)

            v.CharacterRemoving:Connect(function()
                Cache[v] = nil
            end)
        end

        Players.PlayerAdded:Connect(function(v)
            if v == LocalPlayer then
                return
            end

            v.CharacterAdded:Connect(function()
                DoCache(v)
            end)

            v.CharacterRemoving:Connect(function()
                Cache[v] = nil
            end)
        end)

        Players.PlayerRemoving:Connect(function(v)
            Cache[v] = nil
        end)

        --#region resolver

            RunService.RenderStepped:Connect(function(d)
                if not Resolver then
                    return
                end

                for _, data in Cache do
                    local LastVerifiedPos = data.UAC:GetAttribute("LastVerifiedPos")

                    if not LastVerifiedPos or LastVerifiedPos == data.LastPos then
                        continue
                    end

                    data.LastPos = LastVerifiedPos
                    data.HRP.CFrame = CFrame.lookAt(LastVerifiedPos, LastVerifiedPos + data.HRP.CFrame.LookVector)
                end
            end)

        --#endregion



        --#region tracers

            CreateTracer = function(origin, direction)
                local data = Trails[SelectedTracer]
                if not data then
                    return
                end
                local result = workspace:Raycast(origin, direction * 2000, autofireparams)
                local hitDist = result and (result.Position - origin).Magnitude or 2000
                hitDist = math.max(hitDist, 150)
                local endPos = origin + direction * hitDist
                local p = Instance.new("Part")
                p.Anchored = true
                p.CanCollide = false
                p.Transparency = 1
                p.Size = Vector3.new(0.1, 0.1, 0.1)
                p.Position = origin
                p.Parent = workspace
                local a = Instance.new("Attachment")
                a.Parent = p
                a.Position = Vector3.zero
                local b = Instance.new("Attachment")
                b.Parent = p
                b.Position = endPos - origin
                local beam = Instance.new("Beam")
                beam.Attachment0 = a
                beam.Attachment1 = b
                beam.Texture = data.Texture
                beam.Width0 = data.Width0
                beam.Width1 = data.Width1
                beam.TextureLength = data.TextureLength
                beam.TextureMode = Enum.TextureMode.Wrap
                beam.LightEmission = 1
                beam.LightInfluence = 0
                beam.Transparency = NumberSequence.new(0.45)
                beam.Parent = p
                task.spawn(function()
                    local duration = data.Lifetime
                    local start = os.clock()
                    while os.clock() - start < duration do
                        local progress = (os.clock() - start) / duration
                        beam.Transparency = NumberSequence.new(0.45 + (0.55 * progress))
                        task.wait()
                    end
                    p:Destroy()
                end)
            end

        --#endregion



        --#region manip
            local originshiftoffsets = {
                CFrame.new(3,0,0), CFrame.new(-3,0,0), CFrame.new(-6,0,0),
                CFrame.new(6,0,0), CFrame.new(3,2,0), CFrame.new(-3,2,0),
                CFrame.new(-6,2,0), CFrame.new(6,2,0), CFrame.new(4,0,0),
                CFrame.new(-4,2,0), CFrame.new(-4,0,0), CFrame.new(4,2,0),
                CFrame.new(7,0,0), CFrame.new(-7,2,0), CFrame.new(-7,0,0),
                CFrame.new(7,2,0), CFrame.new(0.2,3.9,0), CFrame.new(1.8,4.1,1),
                CFrame.new(2.1,4.4,1.1), CFrame.new(0.15,5.2,0.1),
                CFrame.new(-1.8,5.4,-0.2), CFrame.new(-2.3,6.35,-0.4),
                CFrame.new(0.1,7.5,0), CFrame.new(0.1,8,0),
            }
            local scanpartnames = {
                "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
                "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
                "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg",
            }
            local autofireparams = RaycastParams.new()
            autofireparams.FilterType = Enum.RaycastFilterType.Blacklist
            autofireparams.CollisionGroup = "Bullet"
            autofireparams.FilterDescendantsInstances = {LocalPlayer.Character}
            LocalPlayer.CharacterAdded:Connect(function(char)
                autofireparams.FilterDescendantsInstances = {char}
            end)
            function findminoffset(target, origin)
                local targetchar = target.Parent
                if not targetchar then 
                    return nil, nil 
                end
                local origincf = CFrame.new(origin)
                autofireparams.FilterDescendantsInstances = {LocalPlayer.Character}
                for _, offset in originshiftoffsets do
                    local worldpos = (origincf * offset).Position
                    for _, partname in scanpartnames do
                        local part = targetchar:FindFirstChild(partname)
                        if part and part.Parent then
                            local result = workspace:Raycast(worldpos, part.Position - worldpos, autofireparams)
                            if not result or result.Instance:IsDescendantOf(targetchar) then
                                return worldpos, part
                            end
                        end
                    end
                end
                return nil, nil
            end
        --#endregion



        --#region targetting
            
            FovCircle.Radius = 100
            FovCircle.Color = Color3.fromRGB(255, 255, 255)
            FovCircle.Visible = false
            local fovconnection = RunService.Heartbeat:Connect(function()
                if FovCircleEnabled then
                    FovCircle.Position = UserInputService:GetMouseLocation()
                end
            end)

            function GetTarget()
                local MouseLocation = UserInputService.GetMouseLocation(UserInputService)
                local FinalPart, Distance = nil, math.huge
                local Check = function(AimPart)
                    local ScreenPos, OnScreen = Camera.WorldToViewportPoint(Camera, AimPart.Position)
                    if not OnScreen then
                        return
                    end;
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MouseLocation).Magnitude
                    if FovCircleEnabled then
                        local deg = math.clamp(FovCircle.Radius or 90, 0.5, 179.5)
                        local r = math.tan(math.rad(deg / 2)) / math.tan(math.rad(Camera.FieldOfView / 2)) * (Camera.ViewportSize.Y / 2)
                        if Dist > r then
                            return
                        end
                    end
                    if Distance < Dist then
                        return
                    end;
                    Distance = Dist
                    FinalPart = AimPart
                end
                for _, plr in Players.GetPlayers(Players) do
                    if plr == LocalPlayer then
                        continue
                    end;
                    local Data = plr.Character
                    if not Data then
                        continue
                    end;
                    local AimPart = Data.FindFirstChild(Data, "Head")
                    local Humanoid = Data.FindFirstChild(Data, "Humanoid")
                    if AimPart and Humanoid and Humanoid.Health > 0 then
                        Check(AimPart)
                    end
                end;
                if TargetAi then
                    for Model in AiModels do
                        local AimPart = Model:FindFirstChild("Head")
                        local Humanoid = Model:FindFirstChildOfClass("Humanoid")
                        if AimPart and Humanoid and Humanoid.Health > 0 then
                            Check(AimPart)
                        end
                    end
                end
                if TargetVehicles then
                    for Model in Vehicles do
                        local AimPart = GetVehiclePart(Model)
                        if AimPart then
                            Check(AimPart)
                        end
                    end
                end
                return FinalPart
            end;

            local auraparams = RaycastParams.new()
            auraparams.FilterType = Enum.RaycastFilterType.Exclude
            auraparams.CollisionGroup = "WeaponRay"
            
            
            local GetAuraTarget = function(Origin, Range)
                local Char = LocalPlayer.Character
                local FinalHead, FinalResult, Distance = nil, nil, Range
                auraparams.FilterDescendantsInstances = {Char}
                local Check = function(Data, Head)
                    local Dist = (Head.Position - Origin).Magnitude
                    if Dist > Distance then
                        return
                    end
                    local Result = workspace:Raycast(Origin, (Head.Position - Origin) * 1.1, auraparams)
                    if not Result or not Result.Instance:IsDescendantOf(Data) then
                        return
                    end
                    Distance = Dist
                    FinalHead = Head
                    FinalResult = Result
                end
                for _, plr in Players:GetPlayers() do
                    if plr == LocalPlayer then
                        continue
                    end
                    local Data = plr.Character
                    if not Data then
                        continue
                    end
                    local Head = Data:FindFirstChild("Head")
                    local Humanoid = Data:FindFirstChild("Humanoid")
                    if Head and Humanoid and Humanoid.Health > 0 then
                        Check(Data, Head)
                    end
                end
                if TargetAi then
                    for Model in AiModels do
                        local Head = Model:FindFirstChild("Head")
                        local Humanoid = Model:FindFirstChildOfClass("Humanoid")
                        if Head and Humanoid and Humanoid.Health > 0 then
                            Check(Model, Head)
                        end
                    end
                end
                if TargetVehicles then
                    for Model in Vehicles do
                        local Part = GetVehiclePart(Model)
                        if Part then
                            Check(Model, Part)
                        end
                    end
                end
                return FinalHead, FinalResult
            end

            local BulletGravity = 70
            local GetShotOrigin = function(Char)
                local HumanoidRootPart = Char.HumanoidRootPart
                local Humanoid = Char:FindFirstChild("Humanoid")
                local Height = (Humanoid and Humanoid:GetAttribute("Crouch")) and 0.6 or 1.6
                local Lean = Char:GetAttribute("Leaning") or 0
                return HumanoidRootPart.Position + Vector3.new(0, Height, 0) - HumanoidRootPart.CFrame.RightVector * Lean * 1.18
            end
            local PredictPosition = function(Part, Origin, Speed)
                local Root = Part.Parent:FindFirstChild("HumanoidRootPart") or Part
                local Velocity = Root.AssemblyLinearVelocity
                local Pos = Part.Position
                local Time = (Pos - Origin).Magnitude / Speed
                for i = 1, 4 do
                    Pos = Part.Position + Velocity * Time
                    Time = (Pos - Origin).Magnitude / Speed
                end
                return Pos + Vector3.new(0, 0.5 * BulletGravity * Time * Time, 0)
            end
        --#endregion



        --#region instant bullet
            local SpoofRadius = 10
            local InFlight = {}
            local Resolved = {}
            local ShotTarget = nil
            local ToHead = function(Part, Offset)
                local Model = Part and Part.Parent
                local Head = Model and Model:FindFirstChild("Humanoid") and Model:FindFirstChild("Head")
                if Head then
                    return Head, CFrame.new()
                end
                return Part, Offset
            end
            
            local FireProxy = {
                InvokeServer = function(self, Direction, Id, FireTick)
                    local Shot = PendingInstant
                    if not Shot then
                        if ShotTarget then
                            table.insert(InFlight, {Id = Id, Time = os.clock(), Head = ShotTarget})
                        end
                        if ManipulatedOrigin and ManipulatedAimDir then
                            Direction = ManipulatedAimDir
                        end
                        if SilentAimEnabled and SilentHitPart and SilentHitPart.Parent then
                            FireTick = tick() - ((SilentHitPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude / 1000)
                        end
                        local Result = Remotes.RealFireProjectile:InvokeServer(Direction, Id, FireTick)
                        if DoubleTapEnabled and not DoubleTapFiring and typeof(Direction) == "Vector3" then
                            DoubleTapFiring = true
                            Remotes.RealFireProjectile:InvokeServer(Direction, math.random(-100000, 100000), tick())
                            DoubleTapFiring = false
                        end
                        return Result
                    end
                    PendingInstant = nil
                    InstantShots[Id] = true
                    local Result = Remotes.RealFireProjectile:InvokeServer(Shot.Direction, Id, FireTick)
                    if Shot.Part.Parent then
                        local Part, Offset = ToHead(Shot.Part, Shot.Offset)
                        Remotes.RealProjectileInflict:FireServer(Part, Offset, Id, FireTick + 5)
                    end
                    return Result
                end;
            }
            local InflictProxy = {
                FireServer = function(self, Part, Offset, Id, ...)
                    if InstantShots[Id] or Resolved[Id] then
                        return
                    end
                    Resolved[Id] = true
                    Part, Offset = ToHead(Part, Offset)
                    return Remotes.RealProjectileInflict:FireServer(Part, Offset, Id, ...)
                end;
            }
            local VFXProxy = setmetatable({
                Impact = function(Part, Position, Normal, Material, Direction, Type, IsLocal, ...)
                    if IsLocal and Type == "Ranged" and Part and not (Part.Parent and Part.Parent:FindFirstChild("Humanoid")) then
                        while InFlight[1] and (Resolved[InFlight[1].Id] or os.clock() - InFlight[1].Time > 3) do
                            table.remove(InFlight, 1)
                        end
                        local Shot = InFlight[1]
                        local Head = Shot and Shot.Head
                        if Head and Head.Parent and (Head.Position - Position).Magnitude <= SpoofRadius then
                            table.remove(InFlight, 1)
                            Resolved[Shot.Id] = true
                            Remotes.RealProjectileInflict:FireServer(Head, CFrame.new(), Shot.Id, tick())
                        end
                    end
                    return Modules.VFX.Impact(Part, Position, Normal, Material, Direction, Type, IsLocal, ...)
                end;
            }, {__index = Modules.VFX})
        --#endregion



        --#region killaura
            local GetController = function()
                if Controller and Controller.character == LocalPlayer.Character then
                    return Controller
                end
                if os.clock() - LastScan < 1 then
                    return
                end
                LastScan = os.clock()
                Controller = filtergc("table", {Keys = {"weapon", "useDebounce", "clientAnimationTracks"}}, true)
                return Controller
            end
            RunService.Heartbeat:Connect(function()
                if not KillauraEnabled then
                    return
                end
                local Char = LocalPlayer.Character
                if not Char or not Char:FindFirstChild("HumanoidRootPart") then
                    return
                end
                local Ctrl = GetController()
                if not Ctrl or not Ctrl.weapon or not Ctrl.settings or Ctrl.settings.useModuleName ~= "MeleeWeaponDefault" then
                    return
                end
                if Ctrl.useDebounce then
                    return
                end
                local Tool = Ctrl.weapon.Value.ItemProperties.Tool
                if os.clock() - LastSwing < (Tool:GetAttribute("SwingRate") or 1) then
                    return
                end
                local Origin = GetShotOrigin(Char)
                local Range = math.min(KillauraRange, Tool:GetAttribute("RangeNormal") or KillauraRange)
                local Head, Result = GetAuraTarget(Origin, Range)
                if not Head then
                    return
                end
                LastSwing = os.clock()
                local Track = Ctrl.clientAnimationTracks.Use
                if Ctrl.serverAnimationTracks and Ctrl.serverAnimationTracks.Use then
                    Ctrl.serverAnimationTracks.Use:Play(0.08)
                end
                if not Track then
                    return
                end
                Track:GetMarkerReachedSignal("HitScan"):Once(function()
                    if not Head.Parent then
                        return
                    end
                    Remotes.MeleeInflict:FireServer(Head.Parent, Head, "NormalAttack")
                    Modules.VFX.Impact(Result.Instance, Result.Position, Result.Normal, Result.Material, (Head.Position - Origin).Unit, "Melee", true)
                    Remotes.MeleeReplicate:FireServer(Result.Instance, Result.Position, Result.Normal, Result.Material)

              
                    if KillauraFanOut then
                        for _, plr in Players:GetPlayers() do
                            local Other = plr ~= LocalPlayer and plr.Character
                            local OtherHead = Other and Other ~= Head.Parent and Other:FindFirstChild("Head")
                            local OtherHumanoid = OtherHead and Other:FindFirstChildOfClass("Humanoid")
                            if OtherHumanoid and OtherHumanoid.Health > 0 and (OtherHead.Position - Origin).Magnitude <= Range then
                                Remotes.MeleeInflict:FireServer(Other, OtherHead, "NormalAttack")
                            end
                        end
                    end
                end)
                Track:Play(0.08)
            end)
        --#endregion



        --#region anti aim
            
            RunService.RenderStepped:Connect(function(d)
                if not AntiAimEnabled then
                    return
                end

                local Char = LocalPlayer.Character
                local Humanoid = Char and Char:FindFirstChild("Humanoid")
                local HRP = Char and Char:FindFirstChild("HumanoidRootPart")

                if not Char or not Humanoid or not HRP then
                    return
                end

                local LookVector = Camera.CFrame.LookVector
                local BaseAngle = -math.atan2(LookVector.Z, LookVector.X) + math.rad(-90)
                local FinalAngle = BaseAngle

                if YawMode == "backwards" then
                    FinalAngle = BaseAngle + math.rad(180)
                elseif YawMode == "random" then
                    FinalAngle = math.rad(math.random(0, 360))
                elseif YawMode == "spin" then
                    FinalAngle = BaseAngle + (tick() * 15) % (math.pi * 2)
                elseif YawMode == "jitter" then
                    JitterFlip = not JitterFlip
                    FinalAngle = BaseAngle + (JitterFlip and math.rad(90) or math.rad(-90))
                elseif YawMode == "to target" then
                    local t = RagebotTarget or GetTarget()
                    if t then
                        FinalAngle = -math.atan2(
                            t.Position.Z - HRP.Position.Z,
                            t.Position.X - HRP.Position.X
                        ) + math.rad(90)
                    end
                end

                local _, Y, _ = (CFrame.new(HRP.Position) * CFrame.Angles(0, FinalAngle, 0)):ToOrientation()
                HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, Y, 0)
                Humanoid.AutoRotate = false

                local Pitch = 0

                if PitchMode == "down" then
                    Pitch = -0.78
                elseif PitchMode == "up" then
                    Pitch = 0.78
                elseif PitchMode == "jitter" then
                    Pitch = math.sin(tick() * 20) * 0.78
                end

                Remotes.UpdateTilt:FireServer(Pitch, nil, 0, 0)
            end)

        --#endregion 



        --#region ragebot
            local RageFiring = false
            local lastautoreload = 0

            task.spawn(function()
                while true do
                    local Char = LocalPlayer.Character
                    local Ctrl = (RageBotEnabled or RageFiring) and Char and Char:FindFirstChild("HumanoidRootPart") and GetController()
                    RagebotTarget = nil
                    if RageBotEnabled and Ctrl and Ctrl.useModuleName == "RangedWeaponDefault" then
                        RagebotTarget = GetAuraTarget(GetShotOrigin(Char), math.huge)
                    end
                    if RagebotTarget then
                        Ctrl.MouseHeld = true
                        RageFiring = true
                    elseif RageFiring then
                        RageFiring = false
                        if Ctrl then
                            Ctrl.MouseHeld = Ctrl.LeftMouseDown == true
                        end
                    end
                    if AutoReloadEnabled then
                        local Ctrl = GetController()
                        if Ctrl and Ctrl.weapon and not Ctrl.reloading and not Ctrl.cancellingReload and Ctrl.Bullets <= 0 then
                            local now = os.clock()
                            if now - lastautoreload > (Ctrl.ReloadLength or 3) then
                                local bestmag = nil
                                local bestammo = 0
                                local playerent = Entities:FindFirstChild(LocalPlayer.Name)
                                local playerinv = playerent and playerent:FindFirstChild("Inventory")
                                if playerinv then
                                    for _, slot in playerinv:GetChildren() do
                                        local subinv = slot:FindFirstChild("Inventory")
                                        if subinv then
                                            for _, item in subinv:GetChildren() do
                                                local loaded = item:GetAttribute("LoadedAmmo")
                                                if loaded and loaded > bestammo then
                                                    bestammo = loaded
                                                    bestmag = item
                                                end
                                            end
                                        end
                                    end
                                end
                                if bestmag and bestammo > Ctrl.Bullets then
                                    lastautoreload = now
                                    Remotes.Reload:InvokeServer(nil, Ctrl.equipAttemptId, bestmag)
                                elseif not bestmag then
                                    lastautoreload = now
                                    Remotes.Reload:InvokeServer(nil, Ctrl.equipAttemptId)
                                end
                            end
                        end
                    end
                    task.wait(0)
                end
            end)


        --#endregion



        --#region pre-scan
            RunService.Heartbeat:Connect(function()
                if not ManipEnabled then
                    premaniporigin = nil
                    premanippart = nil
                    return
                end
                local now = os.clock()
                if now - lastmanipscan < 0.03 then
                    return
                end
                local t = RagebotTarget or GetTarget()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not t or not hrp then
                    premaniporigin = nil
                    premanippart = nil
                    return
                end
                local neworigin, newpart = findminoffset(t, GetShotOrigin(char))
                lastmanipscan = now
                premaniporigin = neworigin
                premanippart = newpart
            end)
        --#endregion



        --#region silent logic
            local CreateBullet = filtergc("function", {Name = "CreateBullet"}, true)
            if isfunctionhooked(CreateBullet) then
                restorefunction(CreateBullet)
            end
            for Index, v in debug.getupvalues(CreateBullet) do
                if v == Remotes.RealFireProjectile then
                    debug.setupvalue(CreateBullet, Index, FireProxy)
                elseif v == Remotes.RealProjectileInflict then
                    debug.setupvalue(CreateBullet, Index, InflictProxy)
                elseif v == Modules.VFX then
                    debug.setupvalue(CreateBullet, Index, VFXProxy)
                end
            end
            
            local old; old = hookfunction(CreateBullet, function(self, weapon, worldModel, viewModel, aimPart, ToolStance, AmmoName, ...)
                ManipulatedOrigin = nil
                ManipulatedPart = nil
                ManipulatedAimDir = nil

                local t = RagebotTarget or GetTarget()
                SilentHitPart = (SilentAimEnabled or RagebotTarget) and t or nil
                local Char = LocalPlayer.Character
                local HumanoidRootPart = Char and Char:FindFirstChild("HumanoidRootPart")
                local CachedCFrame = nil
                local origaimcframe = nil
                local origin = HumanoidRootPart and GetShotOrigin(Char) or aimPart.Position

                if t and (SilentAimEnabled or RagebotTarget) and HumanoidRootPart then
                    if ManipEnabled then
                        if premaniporigin and premanippart and premanippart.Parent then
                            ManipulatedOrigin = premaniporigin
                            ManipulatedPart = premanippart
                            origin = ManipulatedOrigin
                            CachedCFrame = HumanoidRootPart.CFrame
                            origaimcframe = aimPart.CFrame
                            HumanoidRootPart.CFrame = CFrame.new(ManipulatedOrigin, ManipulatedPart.Position)
                            aimPart.CFrame = CFrame.new(ManipulatedOrigin, ManipulatedPart.Position)
                        end
                    end

                    local targethrp = t.Parent and t.Parent:FindFirstChild("HumanoidRootPart")
                    local baseaimpos
                    if targethrp and t.Position.Y < targethrp.Position.Y then
                        baseaimpos = targethrp.Position + Vector3.new(0, 1.5, 0)
                    else
                        baseaimpos = t.Position
                    end
                    local AimPos = ManipulatedPart and ManipulatedPart.Position or baseaimpos

                    local Ammo = ReplicatedStorage.AmmoTypes:FindFirstChild(AmmoName)
                    local Speed = Ammo and Ammo:GetAttribute("MuzzleVelocity")
                    if Speed then
                        if InstantBulletEnabled then
                            local Time = (t.Position - origin).Magnitude / Speed
                            AimPos = t.Position + Vector3.new(0, 0.5 * BulletGravity * Time * Time, 0)
                            auraparams.FilterDescendantsInstances = {Char}
                            local Result = workspace:Raycast(origin, (t.Position - origin) * 1.1, auraparams)
                            if Result and Result.Instance:IsDescendantOf(t.Parent) then
                                PendingInstant = {
                                    Part = Result.Instance;
                                    Offset = Result.Instance.CFrame:ToObjectSpace(CFrame.new(Result.Position));
                                    Direction = (AimPos - origin).Unit;
                                    Travel = Time;
                                }
                            end
                        else
                            AimPos = PredictPosition(t, origin, Speed)
                        end
                    end
                    aimPart.CFrame = CFrame.lookAt(aimPart.Position, aimPart.Position + (AimPos - origin).Unit)
                    if ManipulatedOrigin then
                        ManipulatedAimDir = aimPart.CFrame.LookVector
                    end
                end

                if TracerEnabled then
                    CreateTracer(origin, aimPart.CFrame.LookVector)
                end

                local AmmoObj = ReplicatedStorage.AmmoTypes:FindFirstChild(AmmoName)
                local RealVelocity = AmmoObj and AmmoObj:GetAttribute("MuzzleVelocity")
                local RealDeviation = AmmoObj and AmmoObj:GetAttribute("AccuracyDeviation")
                if AmmoObj and PendingInstant then
                    AmmoObj:SetAttribute("MuzzleVelocity", 50000)
                end
                if AmmoObj and NoSpread then
                    AmmoObj:SetAttribute("AccuracyDeviation", 1e-6)
                end
                ShotTarget = (ForceHitEnabled or SilentAimEnabled or RagebotTarget) and t or nil

                local results = {old(self, weapon, worldModel, viewModel, aimPart, ToolStance, AmmoName, ...)}
                if AmmoObj then
                    AmmoObj:SetAttribute("MuzzleVelocity", RealVelocity)
                    AmmoObj:SetAttribute("AccuracyDeviation", RealDeviation)
                end
                if origaimcframe and aimPart and aimPart.Parent then
                    aimPart.CFrame = origaimcframe
                end
                PendingInstant = nil
                ShotTarget = nil
                local savedcframe = CachedCFrame
                local savedhrp = HumanoidRootPart
                task.spawn(function()
                    RunService.RenderStepped:Wait()
                    if RestoreWait > 0 then 
                        task.wait(RestoreWait)
                    end 

                    ManipulatedOrigin = nil
                    ManipulatedPart = nil
                    ManipulatedAimDir = nil
                    if savedhrp and savedhrp.Parent and savedcframe then
                        savedhrp.CFrame = savedcframe
                    end
                end)

                if NoRecoilEnabled and results[1] then
                    results[1] = 0
                    results[2] = 0
                end
                return table.unpack(results)
            end)
        --#endregion



        --#region gun mods

            local PatchSpring = function(Spring)
                local Shove = Spring.shove
                Spring.shove = function(self, Force)
                    if NoRecoilEnabled then
                        return
                    end
                    return Shove(self, Force)
                end
            end
            local Create = Modules.SpringV2.create
            Modules.SpringV2.create = function(Self, Mass, Force, Damping, Speed)
                local Spring = Create(Self, Mass, Force, Damping, Speed)
                if Mass == 5 and Damping == 3.5 then
                    PatchSpring(Spring)
                end
                return Spring
            end
            local Ctrl = filtergc("table", {Keys = {"springs", "useDebounce"}}, true)
            if Ctrl then
                for _, Name in {"recoilRot", "recoilPos", "cameraRecoil"} do
                    if Ctrl.springs[Name] then
                        PatchSpring(Ctrl.springs[Name])
                    end
                end
            end
            local updateSway = filtergc("function", {Name = "updateSway"}, true)
            if isfunctionhooked(updateSway) then
                restorefunction(updateSway)
            end
            local old; old = hookfunction(updateSway, function(...)
                if NoSwayEnabled then
                    return
                end
                return old(...)
            end)
            local updateClient = filtergc("function", {Name = "updateClient"}, true)
            if isfunctionhooked(updateClient) then 
                restorefunction(updateClient)
            end 
            local old; old = hookfunction(updateClient, function(self, ...) 
                local Args = {...}
                if ForceAuto and self.FireModes and self.FireModes[self.FireModeIndex] == "Semi" and self.LeftMouseDown then
                    self.MouseHeld = true
                end
                return old(self, unpack(Args))
            end)
        --#endregion



        --#region toggles
            Sections.aimbot:Toggle({
                Name = 'silent aim';
                Flag = 'silentaim';
                Default = false;
                Callback = function(v)
                    SilentAimEnabled = v;
                    if not v then
                        SilentHitPart = nil
                    end
                end
            })
            Sections.aimbot:Toggle({
                Name = 'double tap';
                Flag = 'doubletap';
                Default = false;
                Callback = function(v)
                    DoubleTapEnabled = v;
                end
            })
            Sections.aimbot:Toggle({
                Name = 'target ai';
                Flag = 'targetai';
                Default = false;
                Callback = function(v)
                    TargetAi = v;
                end
            })
            Sections.aimbot:Toggle({
                Name = 'target vehicles';
                Flag = 'targetvehicles';
                Default = false;
                Callback = function(v)
                    TargetVehicles = v;
                end
            })
            Sections.aimbot:Toggle({
                Name = 'fov circle';
                Flag = 'fovcircle';
                Default = false;
                Callback = function(v)
                    FovCircleEnabled = v;
                    FovCircle.Visible = v;
                end
            })
            Sections.aimbot:Slider({
                Name = 'fov radius';
                Flag = 'fovradius';
                Default = FovCircle.Radius;
                Max = 1000;
                Min = 1;
                Decimals = 1;
                Callback = function(v)
                    FovCircle.Radius = v;
                end
            })
            Sections.aimbot:Label({Name = 'fov color'}):Colorpicker({
                Name = 'fov color';
                Flag = 'fovcolor';
                Default = FovCircle.Color;
                Callback = function(v)
                    FovCircle.Color = v;
                end
            })
            Sections.aimbot:Toggle({
                Name = 'origin manip';
                Flag = 'manip';
                Default = false;
                Callback = function(v)
                    ManipEnabled = v;
                end
            })
            Sections.aimbot:Slider({
                Name = 'restore wait';
                Flag = 'restorew';
                Default = RestoreWait;
                Min = 0;
                Max = 1;
                Decimals = 0.001;
                Callback = function(v)
                    RestoreWait = v;
                end 
            })
            Sections.aimbot:Toggle({
                Name = 'rage bot';
                Flag = 'ragebot';
                Default = false;
                Callback = function(v)
                    RageBotEnabled = v;
                end
            })
            Sections.gunmods:Toggle({
                Name = 'no spread';
                Flag = 'nospread';
                Default = false;
                Callback = function(v)
                    NoSpread = v;
                end
            })
            Sections.gunmods:Toggle({
                Name = 'no recoil';
                Flag = 'norecoil';
                Default = false;
                Callback = function(v)
                    NoRecoilEnabled = v;
                end
            })
            Sections.gunmods:Toggle({
                Name = 'no sway';
                Flag = 'nosway';
                Default = false;
                Callback = function(v)
                    NoSwayEnabled = v
                end
            })
            Sections.gunmods:Toggle({
                Name = 'instant bullet';
                Flag = 'instantbullet';
                Default = false;
                Callback = function(v)
                    InstantBulletEnabled = v;
                end
            })
            Sections.gunmods:Toggle({
                Name = 'force full auto';
                Flag = 'fullauto';
                Default = false;
                Callback = function(v)
                    ForceAuto = v;
                end 
            })
            Sections.gunmods:Toggle({
                Name = 'force hit';
                Flag = 'forcehit';
                Default = false;
                Callback = function(v)
                    ForceHitEnabled = v;
                end 
            })
            Sections.gunmods:Toggle({
                Name = 'auto reload';
                Flag = 'autoreload';
                Default = false;
                Callback = function(v)
                    AutoReloadEnabled = v;
                end
            })
            Sections.killaura:Toggle({
                Name = 'killaura';
                Flag = 'killaura';
                Default = false;
                Callback = function(v)
                    KillauraEnabled = v;
                end
            })
            Sections.killaura:Toggle({
                Name = 'killaura fan out';
                Flag = 'killaurafanout';
                Default = false;
                Callback = function(v)
                    KillauraFanOut = v;
                end
            })
            Sections.killaura:Slider({
                Name = 'killaura range';
                Flag = 'killaurarange';
                Default = 10;
                Min = 1;
                Max = 20;
                Decimals = 0.1;
                Callback = function(v)
                    KillauraRange = v;
                end
            })
            Sections.aimbot:Toggle({
                Name = 'resolver';
                Flag = 'Resolver';
                Default = false;
                Callback = function(v)
                    Resolver = v;
                end 
            })
            Sections.antiaim:Toggle({
                Name = 'anti aim';
                Flag = 'antiaim';
                Default = false;
                Callback = function(v)
                    AntiAimEnabled = v
                    local Char = LocalPlayer.Character
                    local Humanoid = Char and Char:FindFirstChild("Humanoid")
                    if not v and Humanoid then
                        Humanoid.AutoRotate = true
                    end
                end
            })
            Sections.antiaim:Dropdown({
                Name = 'pitch';
                Flag = 'aapitch';
                Items = {"up", "down", "jitter"};
                Default = "down";
                Callback = function(v)
                    PitchMode = v
                end
            })
            Sections.antiaim:Dropdown({
                Name = 'yaw';
                Flag = 'aayaw';
                Items = {"backwards", "random", "spin", "jitter", "to target"};
                Default = "backwards";
                Callback = function(v)
                    YawMode = v
                end
            })
        --#endregion

    end



    --#region namecall stuff
        local DefaultSendRate = getfflag("S2PhysicsSenderRate")
        local FakeLagEnabled, FakeLagRate = false, 2

        --[[local ApplyFakeLag = function()
            if identifyexecutor() ~= "Atomic" then 
                setfflag("S2PhysicsSenderRate", FakeLagEnabled and tostring(FakeLagRate) or DefaultSendRate)
            end
        end]]
        local old; old = hookmetamethod(game, "__namecall", function(self, ...)
            local Args = {...}
            if not checkcaller() then
                
                local Method = getnamecallmethod()
                
                --#region remotes
                    if Method == "FireServer" then
                        if self == ProjectileInflict then 
                            if debug.traceback():find("CharacterController", 1, true) then
                                return
                            end
                            if select("#", ...) > 4 then
                                print(string.format("[report] reason=%s info=%s", tostring(Args[3]), tostring(Args[5])))
                            end
                        end 
                        if self.Name == "Drowning" and NoDrown then 
                            return 
                        end 
                        if self.Name == "UpdateTilt" and AntiAimEnabled then 
                            return 
                        end 
                    end
                    if Method == "InvokeServer" then 
                        if FakeLatency then 
                            if self.Name == 'Ping' then 
                                if not (tick() - LastPing > 0.9) then 
                                    return 
                                else 
                                    LastPing = tick() 
                                end 
                            end 
                        end 
                    end 
                --#endregion

                if Method == "GetAttribute" then 
                    if NoGearWeight and (Args[1] == "MovementModifer" or Args[1] == "GearWeight") then 
                        return 0
                    end 
                    if Args[1] == "AccuracyDeviation" and NoSpread then
                        return 0
                    end
                end 
                if Method == "Raycast" then 
                    local tb = debug.traceback()

                    if SilentHitPart and SilentHitPart.Parent and typeof(Args[1]) == "Vector3" and tb:find("Bullet", 1, true) then
                        local Position = SilentHitPart.Position
                        local Direction = Position - Args[1]
                        return {
                            Instance = SilentHitPart;
                            Position = Position;
                            Normal = -Direction.Unit;
                            Material = SilentHitPart.Material;
                            Distance = Direction.Magnitude;
                        }
                    end
                    if ManipulatedOrigin and ManipulatedPart and ManipulatedAimDir and tb:find('onStep', 1, true) then
                        local dir = ManipulatedAimDir
                        if InstantBulletEnabled then
                            dir = dir * 9e9
                        end
                        Args[1] = ManipulatedOrigin
                        Args[2] = dir
                        return {
                            Instance = ManipulatedPart;
                            Position = ManipulatedPart.Position;
                            Normal = ManipulatedAimDir;
                            Material = ManipulatedPart.Material;
                            Distance = (ManipulatedPart.Position - ManipulatedOrigin).Magnitude;
                        }
                    end
                    if InstantBulletEnabled and tb:find('onStep', 1, true) then 
                        Args[2] = Args[2] * 9e9 
                    end 
                end
                if Method == "SaveScriptProfilingData" then
                    error("The current thread cannot call 'SaveScriptProfilingData' (lacking capability RobloxScript)", 0)
                end

            end
            return old(self, unpack(Args))
        end)

    --#endregion



    --Loader:SetProgress(0.5, "loading esp")
    do -- esp

        
        Sections.Esp:Toggle({
            Name = 'player esp';
            Flag = 'espenabled';
            Default = true;
            Callback = function(v)
                EspLib['Table']['Enabled'] = v
            end
        })
        
        Sections.Esp:Toggle({
            Name = 'team check';
            Flag = 'tc';
            Default = false;
            Callback = function(v)
                EspLib['Table']['TeamCheck'] = v;
            end 
        })

        Sections.Esp:Toggle({
            Name = 'box enabled';
            Flag = 'boxenable';
            Default = true;
            Callback = function(v)
                EspLib['Table']['Boxes']['Enabled'] = v
            end
        })

        for i, v in EspLib['Table']['Boxes'] do
            if type(v) ~= 'table' then 
                continue 
            end
            if rawget(v, 'Enabled') then
                Sections.Esp:Toggle({
                    Name = i;
                    Flag = 'boxtoggle'..i;
                    Default = v['Enabled'];
                    Callback = function(dih)
                        v['Enabled'] = dih
                    end
                })
            end

            if v['Top'] then
                Sections.Esp:Label({Name = i})

                Sections.Esp:Label({Name = 'top'}):Colorpicker({
                    Name = 'top color';
                    Flag = 'boxtopcolor'..i;
                    Default = v['Top'];
                    Callback = function(dih)
                        v['Top'] = dih
                    end;
                })
            end

            if v['Bot'] then
                Sections.Esp:Label({Name = i})

                Sections.Esp:Label({Name = 'bottom'}):Colorpicker({
                    Name = 'bottom color';
                    Flag = 'boxbotcolor'..i;
                    Default = v['Bot'];
                    Callback = function(dih)
                        v['Bot'] = dih
                    end;
                })
            end
        end

        for i, v in EspLib['Table']['Bars'] do
            if type(v) ~= 'table' then 
                continue 
            end
            if rawget(v, 'Enabled') then
                Sections.Esp:Toggle({
                    Name = i;
                    Flag = 'bartoggle'..i;
                    Default = v['Enabled'];
                    Callback = function(dih)
                        v['Enabled'] = dih
                    end
                })
            end

            if v['Top'] then
                Sections.Esp:Label({Name = i})

                Sections.Esp:Label({Name = 'top'}):Colorpicker({
                    Name = 'top color';
                    Flag = 'bartopcolor'..i;
                    Default = v['Top'];
                    Callback = function(dih)
                        v['Top'] = dih
                    end;
                })
            end

            if v['Bot'] then
                Sections.Esp:Label({Name = i})

                Sections.Esp:Label({Name = 'bottom'}):Colorpicker({
                    Name = 'bottom color';
                    Flag = 'barbotcolor'..i;
                    Default = v['Bot'];
                    Callback = function(dih)
                        v['Bot'] = dih
                    end;
                })
            end

            if v['Mid'] then
                Sections.Esp:Label({Name = i})

                Sections.Esp:Label({Name = 'mid'}):Colorpicker({
                    Name = 'mid color';
                    Flag = 'barmidcolor'..i;
                    Default = v['Mid'];
                    Callback = function(dih)
                        v['Mid'] = dih
                    end;
                })
            end
        end

        for i, v in EspLib['Table']['Texts'] do
            if type(v) ~= 'table' then 
                continue 
            end
            if rawget(v, 'Enabled') then
                Sections.Esp:Toggle({
                    Name = i;
                    Flag = 'texttoggle'..i;
                    Default = v['Enabled'];
                    Callback = function(dih)
                        v['Enabled'] = dih
                    end
                })
            end

            if v['Color'] then
                Sections.Esp:Label({Name = i})

                Sections.Esp:Label({Name = 'color'}):Colorpicker({
                    Name = 'color';
                    Flag = 'textcolor'..i;
                    Default = v['Color'];
                    Callback = function(dih)
                        v['Color'] = dih
                    end;
                })
            end
        end

        Sections.Esp:Slider({
            Name = 'max distance';
            Flag = 'espmaxdistance';
            Min = 200;
            Max = 5000;
            Default = 500;
            Decimals = 1;
            Callback = function(v)
                EspLib['Table']['Distance'] = v
            end
        })
    end



    do -- world esp
        local Watched = {}
        local MineFolders = {OutpostLandmines = "landmine", OutpostClaymores = "claymore"}
        local MineNames = {PMN2 = "landmine", MON50 = "claymore"}
        local VehicleNames = {MI24V = "helicopter", BTR80 = "btr", CargoPlane = "cargo plane", CargoPlaneSanta = "cargo plane"}

        local GetItemName = function(Item)
            local Value = Item:IsA("ObjectValue") and Item or Item:FindFirstChildOfClass("ObjectValue") or Item
            local Source = Value:IsA("ObjectValue") and Value.Value
            local Properties = Value:FindFirstChild("ItemProperties") or (Source and Source:FindFirstChild("ItemProperties"))
            local Name = Properties and Properties:GetAttribute("CallSign") or Item.Name
            local Amount = Value:GetAttribute("Amount")

            if Amount and Amount > 1 then
                Name = Name .. " x" .. Amount
            end

            return Name, Value
        end
        EspLib.GetWeapon = function(Character)
            local Holding = Character:FindFirstChild("Holding")
            local Item = Holding and Holding:IsA("ObjectValue") and Holding.Value
            return Item and (GetItemName(Item)) or nil
        end
        local GetContents = function(Inventory)
            local Lines = {}

            for _, Item in Inventory:GetChildren() do
                table.insert(Lines, (GetItemName(Item)))

                local Inner = Item:FindFirstChild("Inventory")

                if Inner then
                    for _, Child in Inner:GetChildren() do
                        table.insert(Lines, "  " .. GetItemName(Child))
                    end
                end
            end

            if #Lines > 14 then
                local Extra = #Lines - 13

                for i = #Lines, 14, -1 do
                    Lines[i] = nil
                end

                table.insert(Lines, "+" .. Extra .. " more")
            end

            return table.concat(Lines, "\n")
        end

        local BindContents = function(Entry, Inventory)
            local Refresh = function()
                if Entry.Pending then
                    return
                end

                Entry.Pending = true

                task.defer(function()
                    Entry.Pending = false
                    Entry.Contents = GetContents(Inventory)
                end)
            end

            table.insert(Entry.Links, Inventory.DescendantAdded:Connect(Refresh))
            table.insert(Entry.Links, Inventory.DescendantRemoving:Connect(Refresh))
            Refresh()
        end

        local Watch; Watch = function(Folder, Callback)
            for _, Child in Folder:GetChildren() do
                if Child:IsA("Folder") then
                    Watch(Child, Callback)
                else
                    task.spawn(Callback, Child)
                end
            end

            if Watched[Folder] then
                return
            end

            Watched[Folder] = true

            Folder.ChildAdded:Connect(function(Child)
                if Child:IsA("Folder") then
                    Watch(Child, Callback)
                else
                    Callback(Child)
                end
            end)
        end

        local AddVehicle = function(Model)
            Vehicles[Model] = EspLib:AddObject(Model, "Vehicles", VehicleNames[Model.Name])

            Model.AncestryChanged:Connect(function()
                if not Model:IsDescendantOf(workspace) then
                    Vehicles[Model] = nil
                end
            end)
        end

        Watch(workspace.AiZones, function(Model)
            local Mine = MineNames[Model.Name] or (Model.Parent and MineFolders[Model.Parent.Name])

            if Mine then
                EspLib:AddObject(Model, "Landmines", Mine)
                return
            end

            if not Model:IsA("Model") then
                return
            end

            if VehicleNames[Model.Name] then
                AddVehicle(Model)
                return
            end

            local Humanoid = Model:FindFirstChildOfClass("Humanoid") or Model:WaitForChild("Humanoid", 5)

            if not Humanoid or not Model:IsDescendantOf(workspace) then
                return
            end

            AiModels[Model] = true
            EspLib:AddModel(Model)

            Model.AncestryChanged:Connect(function()
                if not Model:IsDescendantOf(workspace) then
                    AiModels[Model] = nil
                end
            end)
        end)

        for _, Name in {"Vehicles", "WorldEvents"} do
            local Folder = workspace:FindFirstChild(Name)

            if Folder then
                Watch(Folder, function(Model)
                    if Model:IsA("Model") and VehicleNames[Model.Name] then
                        AddVehicle(Model)
                    end
                end)
            end
        end

        local Exits = workspace.NoCollision:FindFirstChild("ExitLocations")

        if Exits then
            Watch(Exits, function(Exit)
                EspLib:AddObject(Exit, "Extracts", Exit.Name)
            end)
        end

        Watch(workspace.Containers, function(Container)
            if not Container:IsA("Model") then
                return
            end

            local Entry = EspLib:AddObject(Container, "Containers", Container.Name)
            local Inventory = Container:WaitForChild("Inventory", 5)

            if Inventory then
                BindContents(Entry, Inventory)
            end
        end)

        Watch(workspace.DroppedItems, function(Item)
            if not Item:IsA("Model") then
                return
            end

            if Item:FindFirstChildOfClass("Humanoid") then
                local Entry = EspLib:AddObject(Item, "Corpses", Item.Name)
                local Inventory = Item:FindFirstChild("Inventory")

                if Inventory then
                    BindContents(Entry, Inventory)
                end

                return
            end

            local Name, Value = GetItemName(Item)
            local Entry = EspLib:AddObject(Item, "Items", Name)
            local Inventory = Value:FindFirstChild("Inventory")

            if Inventory then
                BindContents(Entry, Inventory)
            end
        end)

        RunService.Heartbeat:Connect(function()
            for Model, Entry in Vehicles do
                local Root = Model.PrimaryPart
                local Health = Root and Root:GetAttribute("Health")

                Entry.Info = Health and math.floor(Health + 0.5) .. "hp" or ""
            end
        end)

        Sections.worldesp:Toggle({
            Name = 'ai esp';
            Flag = 'aiesp';
            Default = false;
            Callback = function(v)
                EspLib['Table']['Ai']['Enabled'] = v
            end
        })

        Sections.worldesp:Slider({
            Name = 'ai distance';
            Flag = 'aidistance';
            Min = 50;
            Max = 5000;
            Default = 1000;
            Decimals = 1;
            Callback = function(v)
                EspLib['Table']['Ai']['Distance'] = v
            end
        })

        for _, i in {"Items", "Containers", "Corpses", "Extracts", "Landmines", "Vehicles"} do
            local v = EspLib['Table']['Objects'][i]

            Sections.worldesp:Toggle({
                Name = string.lower(i);
                Flag = 'objecttoggle'..i;
                Default = v['Enabled'];
                Callback = function(dih)
                    v['Enabled'] = dih
                end
            }):Colorpicker({
                Name = string.lower(i)..' color';
                Flag = 'objectcolor'..i;
                Default = Color3.fromRGB(255, 255, 255);
                Callback = function(dih)
                    v['Color'] = dih
                end;
            })
            

            if v['Contents'] ~= nil then
                Sections.worldesp:Toggle({
                    Name = string.lower(i)..' contents';
                    Flag = 'objectcontents'..i;
                    Default = v['Contents'];
                    Callback = function(dih)
                        v['Contents'] = dih
                    end
                })
            end

            Sections.worldesp:Slider({
                Name = string.lower(i)..' distance';
                Flag = 'objectdistance'..i;
                Min = 10;
                Max = 5000;
                Default = v['Distance'];
                Decimals = 1;
                Callback = function(dih)
                    v['Distance'] = dih
                end
            })
        end
    end



    do

        local allowlist = {"Head", "LeftFoot", "LeftHand", "LeftLowerArm", "LeftLowerLeg", "LeftUpperArm", "LeftUpperLeg", "LowerTorso", "RightFoot", "RightHand", "RightLowerArm", "RightLowerLeg", "RightUpperArm", "RightUpperLeg", "UpperTorso"}
        local glowshittyfactor = 1;
        local chamscolor = Color3.new(1,1,1);
        local function waitpartsok(chr)
            local k = time()
            local notloaded = {};
            for _, name in allowlist do
                if not chr.Parent then
                    return false;
                end;
                if not chr:WaitForChild(name) then
                    table.insert(notloaded, name);
                end;
            end;
            if (#notloaded == 0) == false then
                print("grrr!!!!!")
                print(notloaded)
                print(time() - k)
            end
            return #notloaded == 0;
        end;
        for _, v in Players:GetPlayers() do
            if v.Character and v.Character:IsA("Model") and v ~= LocalPlayer then
                waitpartsok(v.Character)
                EspLib.Chams:DoBHAChams(v.Character, allowlist)
                v.CharacterAdded:Connect(function(char)
                    waitpartsok(char)
                    EspLib.Chams:DoBHAChams(char, allowlist);
                end);
                v.CharacterRemoving:Connect(function(_)
                EspLib.Chams:ClearPlrChams(v.Name);
            end);
            end;
        end;
        Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(char)
                waitpartsok(char)
                EspLib.Chams:DoBHAChams(char, allowlist);
            end);
            plr.CharacterRemoving:Connect(function(_)
                EspLib.Chams:ClearPlrChams(plr.Name);
            end);
        end);
        Sections.chams:Toggle({
            Name = "enable BoxAdornment chams";
            Flag = "bhachamsenabled";
            Default = false;
            Callback = function(v)
                EspLib["Table"]["bha"]["Enabled"] = v;
                EspLib.Chams:Update();
            end
        }):Colorpicker({
            Name = 'color';
            Flag = "bhacolor";
            Default = Color3.new(1,1,1);
            Callback = function(v)
                EspLib["Table"]["bha"]["Color"] = Color3.new(v.R*glowshittyfactor, v.G*glowshittyfactor, v.B*glowshittyfactor);
                chamscolor = v;
                EspLib.Chams:Update();
            end;
        })

        Sections.chams:Dropdown({
            Name = "shading";
            Flag = "bhashading";
            Defualt = "XRayShaded";
            Items = {"Default", "Shaded", "XRay", "XRayShaded", "AlwaysOnTop"};
            Callback = function(v)
                if v then
                    EspLib["Table"]["bha"]["Shading"] = Enum.AdornShading[v];
                    EspLib.Chams:Update();
                end;
            end;
        })

        Sections.chams:Toggle({
            Name = "always on top";
            Flag = "bhaalwaysontop";
            Default = false;
            Callback = function(v)
                EspLib["Table"]["bha"]["AlwaysOnTop"] = v;
                EspLib.Chams:Update();
            end;
        });

        Sections.chams:Slider({
            Name = "transparency";
            Flag = "bhatransparency";
            Default = 0;
            Min = 0;
            Max = 1;
            Decimals = 0.01;
            Callback = function(v)
                EspLib["Table"]["bha"]["Transparency"] = v;
                EspLib.Chams:Update();
            end;
        });

        Sections.chams:Slider({
            Name = "padding";
            Flag = "bhasizepadding";
            Default = 0.01;
            Min = 0;
            Max = 1;
            Decimals = 0.01;
            Callback = function(v)
                EspLib["Table"]["bha"]["SizePadding"] = v;
                EspLib.Chams:Update();
            end;
        });

        Sections.chams:Slider({
            Name = "glow factor";
            Flag = "bhaglowfactor";
            Default = 1;
            Min = 0;
            Max = 10;
            Decimals = 1;
            Callback = function(v)
                glowshittyfactor = v;
                EspLib["Table"]["bha"]["Color"] = Color3.new(chamscolor.R*glowshittyfactor, chamscolor.G*glowshittyfactor, chamscolor.B*glowshittyfactor);
                EspLib.Chams:Update();
            end;
        });

    end;



    --Loader:SetProgress(0.75, "loading visuals")
    do -- visuals
        --[[local FullbrightEnabled = false;
        local NoFogEnabled = false;
        local TsAmbient = Color3.fromRGB(255, 255, 255)
        local TsOutdoorAmbient = Color3.fromRGB(255, 255, 255)
        local Fov = 200
        local FovChanger = false;
        local TpDistance = 15
        
                

        
        
        
        local oldmin = LocalPlayer.CameraMinZoomDistance
        local oldmax = LocalPlayer.CameraMaxZoomDistance
        ]]

        --[[
            --#region Skyboxes
                --repeat task.wait() until Lighting:FindFirstChildWhichIsA("Sky")

                local Sky = Lighting:FindFirstChildWhichIsA("Sky")

                
                local von = game:HttpGet('https://gist.githubusercontent.com/skekkstunsua-lgtm/131b1921a45d4cce654140b916ec0ccd/raw/15241ee33e8b0db830697c0a6d14b725acd8a035/gistfile1.txt')

                local decrypted = base64decode(von)

                writefile("von.png", decrypted)

                local vonasset = getcustomasset("von.png")

                local Skyboxes = {
                    ["Default"] = {
                        Sky.SkyboxBk,
                        Sky.SkyboxDn,
                        Sky.SkyboxFt,
                        Sky.SkyboxLf,
                        Sky.SkyboxRt,
                        Sky.SkyboxUp,
                    },
                    ["king von"] = {vonasset, vonasset, vonasset, vonasset, vonasset, vonasset},
                    ["Eyes"] = { "6823346883", "6823346883", "6823346883", "6823346883", "6823346883", "6823346883" },
                    ["Spongebob"] = { "277094910", "277094864", "277094957", "277095042", "277094996", "277095139" },

                    -- Omen
                    ["Blue Sky"] = { "591058823", "591059876", "591058104", "591057861", "591057625", "591059642" },
                    ["Vaporwave"] = { "1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643" },
                    ["Redshift"] = { "401664839", "401664862", "401664960", "401664881", "401664901", "401664936" },
                    ["Blaze"] = { "150939022", "150939038", "150939047", "150939056", "150939063", "150939082" },
                    ["Among Us"] = { "5752463190", "5752463190", "5752463190", "5752463190", "5752463190", "5752463190" },
                    ["Dark Night"] = { "6285719338", "6285721078", "6285722964", "6285724682", "6285726335", "6285730635" },
                    ["Bright Pink"] = { "271042516", "271077243", "271042556", "271042310", "271042467", "271077958" },
                    ["Purple Sky"] = { "570557514", "570557775", "570557559", "570557620", "570557672", "570557727" },
                    ["Galaxy"] = { "15125283003", "15125281008", "15125277539", "15125279325", "15125274388", "15125275800" },
                }

                local SkyOptions = {}
                for Option,_ in Skyboxes do
                    table.insert(SkyOptions, Option)
                end
            --#endregion
        ]]


        --#region calm luh logic brader

        --[[RunService.RenderStepped:Connect(function()
                if FullbrightEnabled then
                    Lighting.Brightness = 3
                    --Lighting.ClockTime = 18.5
                    Lighting.ExposureCompensation = 0.5
                    
                    if Lighting.Ambient ~= TsAmbient then 
                        Lighting.Ambient = TsAmbient 
                    end

                    if Lighting.OutdoorAmbient ~= TsOutdoorAmbient then 
                        Lighting.OutdoorAmbient = TsOutdoorAmbient 
                    end
                end
                if NoFogEnabled then
                    local atmo = Lighting:FindFirstChildWhichIsA('Atmosphere')
                    if atmo and atmo.Density ~= 0 then 
                        atmo.Density = 0 
                    end
                end
                if FovChanger and Camera.FieldOfView ~= Fov then
                    Camera.FieldOfView = Fov
                end
            end)
            RunService:BindToRenderStep("tpcam", Enum.RenderPriority.Last.Value + 1, function()
                if ThirdPerson then
                    Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, TpDistance)
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in char:GetDescendants() do
                            if part:IsA("BasePart") or part:IsA("Decal") then
                                part.LocalTransparencyModifier = 0
                            end
                        end
                    end
                end
            end)
            Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function() 
                if FovChanger and Camera.FieldOfView ~= Fov then 
                    Camera.FieldOfView = Fov
                end
            end)]]


        --#endregion



        --#region toggles

            --[[Sections.visuals:Toggle({
                Name = 'fov changer';
                Flag = 'fovchanger';
                Default = false;
                Callback = function(v)
                    FovChanger = v;
                end 
            })

            Sections.visuals:Slider({
                Name = 'fov';
                Flag = 'fov';
                Max = 110;
                Min = 60;
                Default = 110;
                Decimals = 1;
                Callback = function(v)
                    Fov = v;
                end
            })

            Sections.visuals:Toggle({
                Name = 'third person';
                Flag = 'ThirdPerson';
                Default = false;
                Callback = function(v)
                    ThirdPerson = v;
                end
            })

            Sections.visuals:Slider({
                Name = 'camera distance';
                Flag = 'tpdistance';
                Default = 15;
                Min = 1;
                Max = 15;
                Decimals = 1;
                Callback = function(v)
                    TpDistance = v;
                end
            })
            
            Sections.visuals:Toggle({
                Name = 'fullbright';
                Flag = 'fullbright';
                Default = false;
                Callback = function(v)
                    FullbrightEnabled = v;
                end
            })

            Sections.visuals:Label({Name = 'ambient'}):Colorpicker({
                Name = 'ambient';
                Flag = 'ambient';
                Default = TsAmbient;
                Callback = function(v)
                    TsAmbient = v;
                end
            })

            Sections.visuals:Label({Name = 'outdoor ambient'}):Colorpicker({
                Name = 'outdoor ambient';
                Flag = 'outdoor ambient';
                Default = TsOutdoorAmbient;
                Callback = function(v)
                    TsOutdoorAmbient = v;
                end
            })]]
            --[[Sections.visuals:Dropdown({
                Name = 'skybox';
                Items = SkyOptions;
                Default = 1;
                Callback = function(v)
                    local chosen = Skyboxes[v]

                    local function toAsset(val)
                        if type(val) ~= "string" then 
                            return val 
                        end
                        if val:sub(1, 3) == "rbx" then 
                            return val 
                        end

                        return "rbxassetid://" .. val
                    end

                    Sky.SkyboxBk = toAsset(chosen[1])
                    Sky.SkyboxDn = toAsset(chosen[2])
                    Sky.SkyboxFt = toAsset(chosen[3])
                    Sky.SkyboxLf = toAsset(chosen[4])
                    Sky.SkyboxRt = toAsset(chosen[5])
                    Sky.SkyboxUp = toAsset(chosen[6])
                end;
            })]]
            --[[Sections.visuals:Toggle({
                Name = 'no fog';
                Flag = 'nofog';
                Default = false;
                Callback = function(v)
                    NoFogEnabled = v;
                end
            })

        ]]

            --[[Sections.visuals:Toggle({
                Name = 'no grass';
                Flag = 'nograss';
                Default = false;
                Callback = function(v)
                    sethiddenproperty(workspace.Terrain, "Decoration", not v)
                end
            })]]
        --#endregion toggles

        --#region rewrite visuals
            --[[local FovToggle = false;
            local FovSize = 90;
            local ThirdPersonToggle = false;
            local ThirdPersonDistance = 15;]]
            
        --#endregion rewrite visuals
    end

    do -- world visuals 


        local function doBullshittingProperites(instance, property)
            local our = instance[property];
            local old; old = our;
            local conn;
            local apply = function()
                if instance[property] ~= our then
                    old = instance[property];
                    instance[property] = our;
                end;
            end
            return {
                toggle = function(check)
                    if conn then conn:Disconnect(); conn = nil; end;
                    if check then
                        apply();
                        conn = instance:GetPropertyChangedSignal(property):Connect(apply);
                    else
                        instance[property] = old;
                    end;
                end;
                set = function(v)
                    our = v;
                    if conn then instance[property] = v; end;
                end;
            };
        end;

        
        local ambient = doBullshittingProperites(Lighting, "Ambient")
        local brightness = doBullshittingProperites(Lighting, "Brightness")
        local colorShiftBottom = doBullshittingProperites(Lighting, "ColorShift_Bottom")
        local colorShiftTop = doBullshittingProperites(Lighting, "ColorShift_Top")
        local environmentDiffuseScale = doBullshittingProperites(Lighting, "EnvironmentDiffuseScale")
        local environmentSpecularScale = doBullshittingProperites(Lighting, "EnvironmentSpecularScale")
        local globalShadows = doBullshittingProperites(Lighting, "GlobalShadows")
        local lightingStyle = doBullshittingProperites(Lighting, "LightingStyle")
        local outdoorAmbient = doBullshittingProperites(Lighting, "OutdoorAmbient")
        local outlines = doBullshittingProperites(Lighting, "Outlines")
        local prioritizeLightingQuality = doBullshittingProperites(Lighting, "PrioritizeLightingQuality")
        local shadowColor = doBullshittingProperites(Lighting, "ShadowColor")
        local shadowSoftness = doBullshittingProperites(Lighting, "ShadowSoftness")
        local technology = doBullshittingProperites(Lighting, "Technology")
        local clockTime = doBullshittingProperites(Lighting, "ClockTime")
        local geographicLatitude = doBullshittingProperites(Lighting, "GeographicLatitude")
        local exposureCompensation = doBullshittingProperites(Lighting, "ExposureCompensation")
        Sections.world:Toggle({
            Name = "ambient toggle";
            Flag = "ambienttoggle";
            Default = false;
            Callback = function(v) ambient.toggle(v); end;
        }):Colorpicker({
            Name = "ambient color";
            Flag = "ambientcolor";
            Default = Lighting.Ambient;--ourvalues["Ambient"];
            Callback = function(v) --[[ourvalues["Ambient"] = v;]] ambient.set(v); end;
        });
    
        Sections.world:Toggle({
            Name = "brightness toggle";
            Flag = "brightnesstoggle";
            Default = false;
            Callback = function(v) brightness.toggle(v); end;
        })
        Sections.world:Slider({
            Name = "brightness value";
            Flag = "brightnessvalue";
            Min = 0;
            Max = 10;
            Default = Lighting.Brightness;
            Decimals = 0.1;
            Callback = function(v) brightness.set(v); end;
        });

        Sections.world:Toggle({
            Name = "color shift bottom toggle";
            Flag = "colorshiftbottomtoggle";
            Default = false;
            Callback = function(v) colorShiftBottom.toggle(v); end;
        }):Colorpicker({
            Name = "color shift bottom color";
            Flag = "colorshiftbottomcolor";
            Default = Lighting.ColorShift_Bottom;
            Callback = function(v) colorShiftBottom.set(v); end;
        });
        Sections.world:Toggle({
            Name = "color shift top toggle";
            Flag = "colorshifttoptoggle";
            Default = false;
            Callback = function(v) colorShiftTop.toggle(v); end;
        }):Colorpicker({
            Name = "color shift top color";
            Flag = "colorshifttopcolor";
            Default = Lighting.ColorShift_Top;
            Callback = function(v) colorShiftTop.set(v); end;
        });
        Sections.world:Toggle({
            Name = "environment diffuse scale toggle";
            Flag = "environmentdiffusescaletoggle";
            Default = false;
            Callback = function(v) environmentDiffuseScale.toggle(v); end;
        })
        Sections.world:Slider({
            Name = "environment diffuse scale value";
            Flag = "environmentdiffusescalevalue";
            Min = 0;
            Max = 1;
            Default = Lighting.EnvironmentDiffuseScale;
            Decimals = 0.01;
            Callback = function(v) environmentDiffuseScale.set(v); end;
        });
        Sections.world:Toggle({
            Name = "environment specular scale toggle";
            Flag = "environmentspecularscaletoggle";
            Default = false;
            Callback = function(v) environmentSpecularScale.toggle(v); end;
        })
        Sections.world:Slider({
            Name = "environment specular scale value";
            Flag = "environmentspecularscalevalue";
            Min = 0;
            Max = 1;
            Default = Lighting.EnvironmentSpecularScale;
            Decimals = 0.01;
            Callback = function(v) environmentSpecularScale.set(v); end;
        });
        Sections.world:Toggle({
            Name = "global shadows toggle";
            Flag = "globalshadowstoggle";
            Default = false;
            Callback = function(v) globalShadows.toggle(v); end;
        })
        Sections.world:Toggle({
            Name = "global shadows value";
            Flag = "globalshadowsvalue";
            Default = false;
            Callback = function(v) globalShadows.set(v); end;
        })
        Sections.world:Toggle({
            Name = "lighting style toggle";
            Flag = "lightingstyletoggle";
            Default = false;
            Callback = function(v) lightingStyle.toggle(v); end;
        })
        Sections.world:Dropdown({
            Name = "lighting style value";
            Flag = "lightingstylevalue";
            Items = {"Soft", "Realistic"};
            Default = "Realistic";
            Multi = false;
            Callback = function(v)
                local prop = Enum.LightingStyle.Realistic;
                if v == "Soft" or v == "Realistic" then
                    prop = Enum.LightingStyle[v];
                end;
                lightingStyle.set(prop);
            end;
        });
        Sections.world:Toggle({
            Name = "outdoor ambient toggle";
            Flag = "outdoorambienttoggle";
            Default = false;
            Callback = function(v) outdoorAmbient.toggle(v); end;
        }):Colorpicker({
            Name = "outdoor ambient color";
            Flag = "outdoorambientcolor";
            Default = Lighting.OutdoorAmbient;
            Callback = function(v) outdoorAmbient.set(v); end;
        });
        Sections.world:Toggle({
            Name = "outlines toggle";
            Flag = "outlinestoggle";
            Default = false;
            Callback = function(v) outlines.toggle(v); end;
        });
        Sections.world:Toggle({
            Name = "outlines value";
            Flag = "outlinesvalue";
            Default = false;
            Callback = function(v) outlines.set(v); end;
        });
        Sections.world:Toggle({
            Name = "prioritize lighting quality toggle";
            Flag = "prioritizelightingqualitytoggle";
            Default = false;
            Callback = function(v) prioritizeLightingQuality.toggle(v); end;
        });
        Sections.world:Toggle({
            Name = "prioritize lighting quality value";
            Flag = "prioritizelightingqualityvalue";
            Default = false;
            Callback = function(v) prioritizeLightingQuality.set(v); end;
        });
        Sections.world:Toggle({
            Name = "shadow color toggle";
            Flag = "shadowcolortoggle";
            Default = false;
            Callback = function(v) shadowColor.toggle(v); end;
        }):Colorpicker({
            Name = "shadow color value";
            Flag = "shadowcolorvalue";
            Default = Lighting.ShadowColor;
            Callback = function(v) shadowColor.set(v); end;
        });
        Sections.world:Toggle({
            Name = "shadow softness toggle";
            Flag = "shadowsoftnesstoggle";
            Default = false;
            Callback = function(v) shadowSoftness.toggle(v); end;
        })
        Sections.world:Slider({
            Name = "shadow softness value";
            Flag = "shadowsoftnessvalue";
            Min = 0;
            Max = 1;
            Default = Lighting.ShadowSoftness;
            Decimals = 0.01;
            Callback = function(v) shadowSoftness.set(v); end;
        });
        Sections.world:Toggle({
            Name = "technology toggle";
            Flag = "technologytoggle";
            Default = false;
            Callback = function(v) technology.toggle(v); end;
        })
        Sections.world:Dropdown({
            Name = "technology value";
            Flag = "technologyvalue";
            Items = {"Future", "Compatibility", "ShadowMap", "Voxel", "Unified", "Legacy"};
            Default = "Future";
            Multi = false;
            Callback = function(v)
                local prop = Enum.Technology.Future;
                if v == "Future" or v == "Compatibility" or v == "ShadowMap" or v == "Voxel" or v == "Unified" or v == "Legacy" then
                    prop = Enum.Technology[v];
                end;
                technology.set(prop);
            end;
        });
        Sections.world:Toggle({
            Name = "clock time toggle";
            Flag = "clocktimetoggle";
            Default = false;
            Callback = function(v) clockTime.toggle(v); end;
        })
        Sections.world:Slider({
            Name = "clock time value";
            Flag = "clocktimevalue";
            Min = 0;
            Max = 24;
            Default = Lighting.ClockTime;
            Decimals = 0.01;
            Callback = function(v) clockTime.set(v); end;
        });
        Sections.world:Toggle({
            Name = "geographic latitude toggle";
            Flag = "geographiclatitudetoggle";
            Default = false;
            Callback = function(v) geographicLatitude.toggle(v); end;
        })
        Sections.world:Slider({
            Name = "geographic latitude value";
            Flag = "geographiclatitudevalue";
            Min = -90;
            Max = 90;
            Default = Lighting.GeographicLatitude;
            Decimals = 0.01;
            Callback = function(v) geographicLatitude.set(v); end;
        });
        Sections.world:Toggle({
            Name = "exposure compensation toggle";
            Flag = "exposurecompensationtoggle";
            Default = false;
            Callback = function(v) exposureCompensation.toggle(v); end;
        })
        Sections.world:Slider({
            Name = "exposure compensation value";
            Flag = "exposurecompensationvalue";
            Min = -5;
            Max = 5;
            Default = Lighting.ExposureCompensation;
            Decimals = 0.01;
            Callback = function(v) exposureCompensation.set(v); end;
        });
        Sections.visuals:Toggle({
            Name = 'no grass';
            Flag = 'nograss';
            Default = false;
            Callback = function(v)
                sethiddenproperty(workspace.Terrain, "Decoration", not v)
            end
        })

        Sections.visuals:Toggle({ 
            Name = 'bullet tracers';
            Flag = 'tracers';
            Default = false;
            Callback = function(v) 
                TracerEnabled = v; 
            end
        })

        Sections.visuals:Dropdown({
            Name = 'tracer style';
            Items = {"Laser 1", "Laser 2", "DNA", "Energy"};
            Default = "Laser 1";
            Callback = function(v) 
                SelectedTracer = v; 
            end
        })

        Sections.visuals:Slider({
            Name = 'tracer lifetime';
            Flag = 'tracerlife';
            Default = TracerLifetime;
            Min = 0;
            Max = 5;
            Decimals = 0.1;
            Callback = function(v)
                TracerLifetime = v;
            end 
        })

    end

    do-- visuals miscs
        local FovToggle = false;
        local FovSize = 90;
        local ThirdPersonToggle = false;
        local ThirdPersonDistance = 15;

        RunService.RenderStepped:Connect(function()

            if FovToggle and Camera.FieldOfView ~= FovSize then
                Camera.FieldOfView = FovSize
            end
        end)
        RunService:BindToRenderStep("tpcam", Enum.RenderPriority.Last.Value + 1, function()
            if ThirdPersonToggle then
                Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, ThirdPersonDistance)
                local char = LocalPlayer.Character
                if char then
                    for _, part in char:GetDescendants() do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
            end
        end)
        Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function() 
            if FovToggle and Camera.FieldOfView ~= FovSize then 
                Camera.FieldOfView = FovSize
            end
        end)
        Sections.vmisc:Toggle({
            Name = "fov changer";
            Flag = "fovchanger";
            Default = false;
            Callback = function(v)
                FovToggle = v;
            end;
        });
        Sections.vmisc:Slider({
            Name = 'fov';
            Flag = 'fov';
            Max = 110;
            Min = 60;
            Default = 110;
            Decimals = 1;
            Callback = function(v)
                FovSize = v;
            end
        })
        Sections.vmisc:Toggle({
            Name = 'third person';
            Flag = 'ThirdPerson';
            Default = false;
            Callback = function(v)
                ThirdPersonToggle = v;
            end
        })

        Sections.vmisc:Slider({
            Name = 'camera distance';
            Flag = 'tpdistance';
            Default = 15;
            Min = 1;
            Max = 15;
            Decimals = 1;
            Callback = function(v)
                ThirdPersonDistance = v;
            end
        })
    end
    
    

    do -- misc

        local SpeedhackEnabled = false;
        local SpeedhackSpeed = 2;
        local BhopEnabled = false
        local BhopGain = 2
        local BhopMax = 40
        local BhopSpeed = 0
        local WasAirborne = false
        local NoclipEnabled = true
        local MoveController = nil
        local LastMoveScan = 0
        local HitsoundEnabled = false
        local SelectedHitsound = "Neverlose"
        local HitsoundVolume = 2

        local OmniSprintEnabled = false
        local hitnoti = false 

        local AiZones = workspace.AiZones

        
        local InLobby = false 
        if not workspace.AiZones:FindFirstChild('OutpostLandmines') then 
            InLobby = true 
        end 
        
        local Landmines = workspace.AiZones:FindFirstChild('OutpostLandmines')
        local Claymores = workspace.AiZones:FindFirstChild('OutpostClaymores')

        --#region speed hack

            local speedhackconnection = RunService.Heartbeat:Connect(function(delta)
                if SpeedhackEnabled then 
                    if not LocalPlayer.Character then 
                        return 
                    end 

                    local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
                    if not humanoid then 
                        return 
                    end 
                    LocalPlayer.Character:TranslateBy(humanoid.MoveDirection * (SpeedhackSpeed) * delta * 10)
                end;
            end)

        --#endregion



        --#region hitsounds
            local sounds = {
                ["Neverlose"] = "rbxassetid://8726881116";
                ["TF2"] = "rbxassetid://8255306220";
                ["Gamesense"] = "rbxassetid://4817809188";
                ["Rust"] = "rbxassetid://1255040462";
                ["Bubble"] = "rbxassetid://85730811347567";
                ["Quake"] = "rbxassetid://1455817260";
                ["Among-Us"] = "rbxassetid://7227567562";
                ["Ding"] = "rbxassetid://2868331684";
                ["Minecraft"] = "rbxassetid://6361963422";
                ["Blackout"] = "rbxassetid://3748776946";
                ["Osu!"] = "rbxassetid://7151989073";
                ["Windows XP"] = "rbxassetid://9066167010";
                ["HEADSHOT"] = "rbxassetid://18362692980";
                ["Hitmarker"] = "rbxassetid://705502934";
                ["Plush toy"] = "rbxassetid://136601315351295";
                ["Chomp"] = "rbxassetid://81906463817396";
                ["Gnome"] = "rbxassetid://115441166024380";
                ["Exp"] = "rbxassetid://80611228518495";
                ["Sans"] = "rbxassetid://132322331764933";
                ["Snap"] = "rbxassetid://93172144688075";
                ["Die"] = "rbxassetid://98450680047632";
                ["Mega kill!"] = "rbxassetid://92723765069002";
                ["OOF"] = "rbxassetid://79348298352567";
                ["CSGO Headshot"] = "rbxassetid://18315629371";
                ["MW2019 Killsound"] = "rbxassetid://7644722553";
                ["nn dog"] = "rbxassetid://5902468562";
                ["ar2 body"] = "rbxassetid://2062015952";
                ["ar2 head"] = "rbxassetid://2062016772";
                ["ar2 limb"] = "rbxassetid://6659353525";
                ["bag"] = "rbxassetid://364942410";
                ["bamboo"] = "rbxassetid://3769434519";
                ["bambi"] = "rbxassetid://8437203821";
                ["bameware"] = "rbxassetid://7898991882";
                ["bb hit"] = "rbxassetid://4645745735";
                ["bb kill"] = "rbxassetid://2636743632";
                ["bell"] = "rbxassetid://6534947240";
                ["bonk"] = "rbxassetid://3765689841";
                ["bruh"] = "rbxassetid://4275842574";
                ["cod"] = "rbxassetid://160432334";
                ["crit"] = "rbxassetid://296102734";
                ["headshot"] = "rbxassetid://8418469749";
                ["hl crowbar"] = "rbxassetid://546410481";
            }
            local SoundNames = {}

            for Name in sounds do
                table.insert(SoundNames, Name)
            end

            table.sort(SoundNames)

            local Impact = Modules.VFX.Impact

            if isfunctionhooked(Impact) then
                restorefunction(Impact)
            end

            local Effects = nil

            local old; old = hookfunction(Impact, function(Part, Position, Normal, Material, Direction, Type, IsLocal, ...)
                local Muted = {}

                if IsLocal and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
                    if HitsoundEnabled then 
                        local Sound = Instance.new("Sound")
                        Sound.SoundId = sounds[SelectedHitsound]
                        Sound.Volume = HitsoundVolume
                        Sound.Parent = SoundService
                        Sound.Ended:Once(function()
                            Sound:Destroy()
                        end)
                        Sound:Play()


                        local Data = Effects and Effects[Type] and Effects[Type].Blood

                        if Data and Data.Sound then
                            for _, Template in Data.Sound do
                                Muted[Template] = Template.Volume
                                Template.Volume = 0
                            end
                        end
                    end 
                    if hitnoti then 
                        --local oldident = getthreadidentity()

                        task.spawn(function()
                            setthreadidentity(8)
                            Library:Notification({
                                Name = 'hit '..tostring(Part.Parent.Name)..' in the '..tostring(Part.Name);
                                Time = 2
                            })
                        end)

                    end 
                end

                old(Part, Position, Normal, Material, Direction, Type, IsLocal, ...)

                for Template, Volume in Muted do
                    Template.Volume = Volume
                end
            end)

            for _, v in debug.getupvalues(old) do
                if type(v) == "table" and rawget(v, "Ranged") and rawget(v, "Melee") then
                    Effects = v
                end
            end

        --#endregion



        --#region bunny hop

            local GetMoveController = function()
                if MoveController and MoveController.humanoid and MoveController.humanoid.Parent == LocalPlayer.Character then
                    return MoveController
                end

                if os.clock() - LastMoveScan < 1 then
                    return
                end

                LastMoveScan = os.clock()
                MoveController = filtergc("table", {Keys = {"jumpDebounce", "lastJumpHeight", "humanoid"}}, true)
                return MoveController
            end 

            local bhopconnection = RunService.Heartbeat:Connect(function()
                if not BhopEnabled then
                    return
                end

                local Char = LocalPlayer.Character
                local Humanoid = Char and Char:FindFirstChildWhichIsA('Humanoid')
                local HumanoidRootPart = Char and Char:FindFirstChild('HumanoidRootPart')

                if not Humanoid or not HumanoidRootPart then
                    return
                end

                if not UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:GetFocusedTextBox() then
                    BhopSpeed = 0
                    WasAirborne = false
                    return
                end
                local Ctrl = GetMoveController()

                if Ctrl then
                    Ctrl.jumpDebounce = false
                end
                local State = Humanoid:GetState()
                local Grounded = Humanoid.FloorMaterial ~= Enum.Material.Air and State ~= Enum.HumanoidStateType.Jumping and State ~= Enum.HumanoidStateType.Freefall

                if Grounded then
                    if WasAirborne then
                        BhopSpeed = math.min(math.max(BhopSpeed, Humanoid.WalkSpeed) + BhopGain, BhopMax)
                    end

                    WasAirborne = false
                    Humanoid.Jump = true
                    return
                end

                WasAirborne = true

                if Humanoid.MoveDirection.Magnitude == 0 then
                    BhopSpeed = Humanoid.WalkSpeed
                    return
                end

                local Velocity = Humanoid.MoveDirection * math.max(BhopSpeed, Humanoid.WalkSpeed)
                HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(Velocity.X, HumanoidRootPart.AssemblyLinearVelocity.Y, Velocity.Z)
            end)

            --#region omni sprint

                local SetOmniSprint = function(Char)
                    if Char then
                        Char:SetAttribute("AltLook", OmniSprintEnabled and CFrame.new() or nil)
                    end
                end

                LocalPlayer.CharacterAdded:Connect(SetOmniSprint)

            --#endregion
            
        --#endregion



        --#region toggles

            Sections.exploits:Toggle({
                Name = 'no visor';
                Flag = 'novisor';
                Default = false;
                Callback = function(v)
                    LocalPlayer.PlayerGui.NoInsetGui.MainFrame.ScreenEffects.Visor.Visible = not v 
                    LocalPlayer.PlayerGui.NoInsetGui.MainFrame.ScreenEffects.HelmetMask.Visible = not v 
                end 
            })

            Sections.exploits:Toggle({
                Name = 'no inv blur';
                Flag = 'noblur';
                Default = false;
                Callback = function(v)
                    Lighting.InventoryBlur.Enabled = not v
                end 
            })

            Sections.exploits:Toggle({
                Name = 'no water blur';
                Flag = 'nowblur';
                Default = false;
                Callback = function(v)
                    if v then 
                        Lighting.WaterBlur.Size = 0
                    else 
                        Lighting.WaterBlur.Size = 24
                    end
                end 
            })

            Sections.exploits:Toggle({
                Name = 'no drown';
                Flag = 'nodrown';
                Default = false;
                Callback = function(v)
                    NoDrown = v;
                end 
            })

            Sections.exploits:Toggle({
                Name = 'no flashbang effects';
                Flag = 'noflashbng';
                Default = false;
                Callback = function(v)
                    if LocalPlayer.PlayerGui.NoInsetGui.MainFrame.ScreenEffects.Flashbang.Visible then 
                        LocalPlayer.PlayerGui.NoInsetGui.MainFrame.ScreenEffects.Flashbang.Visible = not v 
                    end 
                end 
            })

            Sections.exploits:Toggle({
                Name = 'no parallax effects';
                Flag = 'noflash';
                Default = false;
                Callback = function(v)
                    if LocalPlayer.PlayerGui.NoInsetGui.MainFrame.ScreenEffects.Parallax.Visible then 
                        LocalPlayer.PlayerGui.NoInsetGui.MainFrame.ScreenEffects.Parallax.Visible = not v 
                    end 
                end 
            })

            Sections.exploits:Toggle({
                Name = 'no landmines';
                FLag = 'nolandmines';
                Default = false;
                Callback = function(v)
                    if not InLobby then 
                        if v then 
                            Landmines.Parent = nil 
                            Claymores.Parent = nil 
                        else 
                            Landmines.Parent = AiZones
                            Claymores.Parent = AiZones
                        end 
                    end 
                end 
            })

            Sections.movement:Toggle({
                Name = 'speed hack';
                Flag = 'speedhack';
                Default = false;
                Callback = function(v)
                    SpeedhackEnabled = v;
                end 
            })

            Sections.movement:Slider({
                Name = 'speed';
                Flag = 'speed';
                Default = 1;
                Min = 0;
                Max = 5;
                Decimals = 0.01;
                Callback = function(v)
                    SpeedhackSpeed = v;
                end;
            })

            Sections.movement:Toggle({
                Name = 'bunny hop';
                Flag = 'bhop';
                Default = false;
                Callback = function(v)
                    BhopEnabled = v;
                end
            })

            Sections.movement:Slider({
                Name = 'bhop gain';
                Flag = 'bhopgain';
                Default = 2;
                Min = 0;
                Max = 10;
                Decimals = 0.1;
                Callback = function(v)
                    BhopGain = v;
                end;
            })

            Sections.movement:Slider({
                Name = 'bhop max speed';
                Flag = 'bhopmax';
                Default = 40;
                Min = 16;
                Max = 100;
                Decimals = 1;
                Callback = function(v)
                    BhopMax = v;
                end;
            })

            Sections.movement:Toggle({
                Name = 'omni sprint';
                Flag = 'omnisprint';
                Default = false;
                Callback = function(v)
                    OmniSprintEnabled = v;
                    SetOmniSprint(LocalPlayer.Character)
                end
            })

            Sections.movement:Toggle({
                Name = 'fakelag';
                Flag = 'fakel';
                Default = false;
                Callback = function(v)
                FakeLatency = v;
                    FakeLagEnabled = v
                    --ApplyFakeLag()
                end
            })

            --[[Sections.movement:Slider({
                Name = 'fakelag send rate';
                Flag = 'fakelrate';
                Default = 2;
                Min = 1;
                Max = 15;
                Decimals = 1;
                Callback = function(v)
                    FakeLagRate = v
                    ApplyFakeLag()
                end
            })]]


            Sections.movement:Toggle({
                Name = 'no gear weight';
                Flag = 'nogearweight';
                Default = false;
                Callback = function(v)
                    NoGearWeight = v;
                end 
            })
            
            Sections.hit:Toggle({
                Name = 'hitsounds';
                Flag = 'hitsounds';
                Default = false;
                Callback = function(v)
                    HitsoundEnabled = v;
                end
            })

            Sections.hit:Dropdown({
                Name = 'hitsound';
                Items = SoundNames;
                Default = "Neverlose";
                Callback = function(v)
                    SelectedHitsound = v;
                end
            })

            Sections.hit:Slider({
                Name = 'hitsound volume';
                Flag = 'hitsoundvolume';
                Default = 2;
                Min = 0;
                Max = 10;
                Decimals = 0.1;
                Callback = function(v)
                    HitsoundVolume = v;
                end
            })

            Sections.hit:Toggle({
                Name = 'hit notifications';
                Flag = 'hitnoti';
                Default = false;
                Callback = function(v)
                    hitnoti = v;
                end 
            })
        --#endregion
    end
    local iscorn = true;
    local drawing2 = Drawing.new("Line")
    drawing2.Color = Color3.new(1,1,1);
    drawing2.Thickness = 1;
    local drawing3 = Drawing.new("Line")
    drawing3.Color = Color3.new(1,1,1);
    drawing3.Thickness = 1;
    do -- target info
        local targetHudEnabled = false;
        local targetLineEnabled = false;
        local traceFromGun = false;
        local targetHud = Library:TargetHUD({
            Name = "target info";
        })
        currentTargetPart = nil;
        --targetupdateshit
        RunService.Heartbeat:Connect(function()
            task.spawn(function()
                if not targetHudEnabled then targetHud:SetVisibility(false); return; end;
                local target = RagebotTarget or GetTarget();
                if not target then targetHud:SetVisibility(false); return; end;
                if FovCircleEnabled then
                    local deg = math.clamp(FovCircle.Radius or 90, 0.5, 179.5);
                    local mouseLocation = UserInputService.GetMouseLocation(UserInputService)
                    local screenPos, _ = Camera.WorldToViewportPoint(Camera, target.Position);
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                    local r = math.tan(math.rad(deg/2)) / math.tan(math.rad(Camera.FieldOfView / 2)) * (Camera.ViewportSize.Y / 2);
                    if dist > r then targetHud:SetVisibility(false); return; end;
                    targetHud:SetVisibility(true);
                end;
                currentTargetPart = target;
                targetHud:SetTarget(target);
                targetHud:SetVisibility(true);
            end)
        end)
        --shitty draw bs;
        local targetLine = Drawing.new("Line");
        targetLine.Visible = false;
        RunService.RenderStepped:Connect(function()
            task.spawn(function()
                if not currentTargetPart or not targetLineEnabled then targetLine.Visible = false; return; end;
                local screenPos, onScreen = Camera.WorldToViewportPoint(Camera, currentTargetPart.Position);
                if not onScreen then targetLine.Visible = false; drawing2.Visible = false; drawing3.Visible = false; return; end;
                local mouseLocation = UserInputService.GetMouseLocation(UserInputService)
                if traceFromGun then
                    local Viewmodel = Camera.FindFirstChild(Camera, "ViewModel");
                    if Viewmodel then
                        local Item = Viewmodel.FindFirstChild(Viewmodel, "Item");
                        if Item then
                            local Barrel = Item.FindFirstChild(Item, "Barrel");
                            if Barrel then
                                local barrelPos, onScreen = Camera.WorldToViewportPoint(Camera, Barrel.CFrame.Position);
                                if onScreen then
                                    if iscorn  then
                                        drawing2.From = mouseLocation;
                                        drawing2.To = Vector2.new(screenPos.X, screenPos.Y);
                                        drawing3.From = mouseLocation
                                        drawing3.To = Vector2.new(barrelPos.X, barrelPos.Y);
                                        drawing2.Visible = true;
                                        drawing3.Visible = true;
                                    end
                                    targetLine.From = Vector2.new(barrelPos.X, barrelPos.Y);
                                else
                                    drawing2.Visible = false;
                                    drawing3.Visible = false;
                                    targetLine.From = mouseLocation;
                                end
                            else
                                drawing2.Visible = false;
                                drawing3.Visible = false;
                                targetLine.From = mouseLocation;
                            end
                        else
                            drawing2.Visible = false;
                            drawing3.Visible = false;
                            targetLine.From = mouseLocation;
                        end
                    else
                        drawing2.Visible = false;
                        drawing3.Visible = false;
                        targetLine.From = mouseLocation;
                    end
                    --[[local Barrel = Camera:FindFirstChild("ViewModel"):FindFirstChild("Item"):FindFirstChild("Barrel")
                    if Barrel then
                        local barrelPos, onScreen = Camera.WorldToViewportPoint(Camera, Barrel.CFrame.Position);
                        if onScreen then
                            targetLine.From = Vector2.new(barrelPos.X, barrelPos.Y);
                        else
                            targetLine.From = mouseLocation;
                        end
                    else
                        targetLine.From = mouseLocation;
                    end]]
                else
                    drawing2.Visible = false;
                    drawing3.Visible = false;
                    targetLine.From = mouseLocation;
                end
                --targetLine.From = Vector2.new(screenPos.X, screenPos.Y);
                --targetLine.To = mouseLocation;
                targetLine.To = Vector2.new(screenPos.X, screenPos.Y);
                if FovCircleEnabled then
                    local deg = math.clamp(FovCircle.Radius or 90, 0.5, 179.5);
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                    local r = math.tan(math.rad(deg/2)) / math.tan(math.rad(Camera.FieldOfView / 2)) * (Camera.ViewportSize.Y / 2);
                    if dist > r then targetLine.Visible = false; return; end;
                    targetLine.Visible = true;
                end
                targetLine.Visible = true;
            end)
        end)
        Sections.target:Toggle({
            Name = "target info";
            Flag = "targetinfo";
            Default = false;
            Callback = function(v)
                targetHudEnabled = v;
            end;
        })
        Sections.target:Toggle({
            Name = "target line";
            Flag = "targetline";
            Default = false;
            Callback = function(v) targetLineEnabled = v; end;
        }):Colorpicker({
            Name = "target line color";
            Flag = "targetlinecolor";
            Default = Color3.fromRGB(255, 255, 255);
            Callback = function(v) targetLine.Color = v; end;
        })
        Sections.target:Slider({
            Name = "target line thickness";
            Flag = "targetlinethickness";
            Min = 1;
            Max = 10;
            Default = 1;
            Decimals = 1;
            Callback = function(v) targetLine.Thickness = v; end;
        })
        Sections.target:Toggle({
            Name = "trace from gun";
            Flag = "tracefromgun";
            Default = false;
            Callback = function(v) traceFromGun = v; end;
        })
    end
    do -- song bs
        local port = "8080";
        local socket;
        local connectspotifybutton;     
        local spotifyPortinput;
        local spotifyHUD
        local AudioPToggle
        local function formattime(ms)
            local tsec = math.floor(ms/1000);
            --local hrs = math.floor(tsec/3600);
            local mins = math.floor((tsec % 3600) / 60);
            local segs = tsec % 60
            return string.format("%02d:%02d", mins, segs) 
        end
        local function connectSpotify()
            local url = "ws://127.0.0.1:" .. port .. "/ws"
            local ok = xpcall(function()
                socket = WebSocket.connect(url)
            end, function(err)
                Library:Notification({ Name = "spotify connect failed: " .. tostring(err), Time = 4 })
            end)

            if ok then
                Library:Notification({ Name = "spotify connected", Time = 2 })
                connectspotifybutton:SetVisibility(false)
                spotifyPortinput:SetVisibility(false)
                spotifyHUD = Library:AudioPlayer({Name = "playback"});

                AudioPToggle = Sections.AudioP:Toggle({
                    Name = "toggle spotify hud";
                    Flag = "togglespotifyhud";
                    Default = false;
                    Callback = function(v)
                        spotifyHUD:SetVisibility(v);
                    end;
                })
                socket.OnMessage:Connect(function(msg)
                    local data = HttpService:JSONDecode(msg)
                    --[[if data.playback then
                        if data.playback["title"] then
                            spotifyHUD:SetText(1, data.playback.title)
                        end
                        if data.playback["album"] then
                            spotifyHUD:SetText(3, data.playback.album)
                        end
                        if data.playback["artist"] then
                            spotifyHUD:SetText(2, data.playback.artist)
                        end
                        if data.playback["duration_ms"] and data.playback["position_ms"] then
                            spotifyHUD:SetTime(data.playback.position_ms ,data.playback.duration_ms)
                        end
                    end]]
                    spotifyHUD:Update(data)
                end)

            end
        end

        connectspotifybutton = Sections.AudioP:Button({
            Name = "connect spotify";
            Callback = function() connectSpotify(); end;
        })
        spotifyPortinput = Sections.AudioP:Textbox({
            Name = "client port";
            Flag = "spotifyclientport";
            Default = "8080";
            Callback = function(v)
                port = v;
            end;
        });


        
    end;
end;
--Loader:SetProgress(0.9, "finishing")
Window:InitWindow()
--Loader:Finish()
