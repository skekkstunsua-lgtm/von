-- VIVISIVON PD

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/BullshitLib.lua"))()
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
    
    
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        if not checkcaller() then
            local Method = getnamecallmethod()

            if Method == "FireServer" and self == ProjectileInflict then
                local _, Second = ...

                if Second == CFrame.new(1, 1, 1) or Second == Vector3.new(-1, -1, -1) then
                    return
                end
            end

            if Method == "SaveScriptProfilingData" then
                error("The current thread cannot call 'SaveScriptProfilingData' (lacking capability RobloxScript)", 0)
            end
        end

        return old(self, ...)
    end)

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
    local Lighting = game:GetService("Lighting")
    local Teams = game:GetService("Teams")
    local SoundService = game:GetService("SoundService")

    local Modules = { -- Modules.

    };

    local Remotes = {
        
    };

    local cheatinfo = {
        autofireconnection = nil;
        offset = Vector3.new(0, 0, 0);
        didmanip = false;
        target = nil;
        manip_corners = {
            Vector3.new(0, 0, 0), --center
            Vector3.new(0, 0, 1), --front
            Vector3.new(0, 0, -1), --back
            
            Vector3.new(0, 1, 0), -- up
            Vector3.new(0, 1, 1), -- up front
            Vector3.new(0, 1, -1), -- up back
            
            
            Vector3.new(0, -1, 0), -- down
            Vector3.new(-1, 0, 0), -- left
            Vector3.new(1, 0, 0), --right
            Vector3.new(-1, 1, 0), -- top lef
            Vector3.new(1, 1, 0), -- top right
            Vector3.new(-1, -1, 0), -- bottom left
            Vector3.new(1, -1, 0), -- bottom right
        };
        box_corners = {
            Vector3.new(-1, -1, -1);
            Vector3.new(1, -1, -1);
            Vector3.new(1, 1, -1);
            Vector3.new(-1, 1, -1);
            Vector3.new(-1, -1, 1);
            Vector3.new(1, -1, 1);
            Vector3.new(1, 1, 1);
            Vector3.new(-1, 1, 1);
        };
        box_faces = {
            -- top
            {1,2}, {2,3}, {3,4}, {4,1},
            -- bottom
            {5,6}, {6,7}, {7,8}, {8,5},
            -- poles/sides/stick whatever
            {1,5}, {2,6}, {3,7}, {4,8}
        };
    }

    local CreateTracer;
    local TracerEnabled = false;

    local SelectedTracer = "Laser 1";

    local Trails = {
        ["Laser 1"] = { Texture = "rbxassetid://7136858729", Width0 = 0.4, Width1 = 0.4, TextureLength = 1, Lifetime = 1 };
        ["Laser 2"] = { Texture = "rbxassetid://6333823534", Width0 = 0.4, Width1 = 0.4, TextureLength = 1, Lifetime = 1 };
        ["DNA"] = { Texture = "rbxassetid://7071778278", Width0 = 0.6, Width1 = 0.6, TextureLength = 12, Lifetime = 1 };
        ["Energy"]  = { Texture = "rbxassetid://5864341017", Width0 = 0.4, Width1 = 0.4, TextureLength = 1, Lifetime = 1 };
    };
--#endregion



--#region library setup
    --local amity = loadstring(game:HttpGet('https://raw.githubusercontent.com/78n/Roblox/refs/heads/main/Lua/Libraries/DataToCode/DataToCode.luau'))()

    --Loader:SetProgress(0.2, "loading libraries")
    local EspLib = loadstring(game:HttpGet('https://github.com/skekkstunsua-lgtm/von/raw/refs/heads/main/EspLib.lua'))()

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
        visuals = Pages.VisualsPage:Section({
            Name = 'world';
            Side = 2;
        });
        Esp = Pages.VisualsPage:Section({
            Name = 'esp';
            Side = 1;
        })
    };

--#endregion


--Loader:SetProgress(0.3, "loading combat")
do -- combat
    local SilentAimEnabled = false;
    local NoSpreadEnabled = false;
    local ManipEnabled = false;
    local Manips = 5;
    local ManipStep = 0.25;
    local NoRecoilEnabled = false;
    local RageBotEnabled = false;
    local SilentReload = false;
    local FovCircleEnabled = false;
    local RapidFireEnabled = false;
    local FireRate = 0;
    local InstantReload = false;
    local ForceFullAuto = false;
    local NoSpread = false;
    local RagebotTarget = nil
    local SilentAimTarget = nil
    local NoSwayEnabled = false
    local KillauraEnabled = false
    local KillauraRange = 10
    local LastSwing = 0
    local LastScan = 0
    local Controller = nil
    local MeleeInflict = ReplicatedStorage.Remotes.MeleeInflict
    local InstantBulletEnabled = false
    --local TickBack = 0.05
    local PendingInstant = nil
    local InstantShots = {}
    local MeleeReplicate = ReplicatedStorage.Remotes.MeleeReplicate
    local VFX = require(ReplicatedStorage.Modules.VFX)
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
        --local lastShotTarget = nil
        local autofireparams = RaycastParams.new()
        autofireparams.FilterType = Enum.RaycastFilterType.Blacklist
        autofireparams.CollisionGroup = "Bullet"
        autofireparams.FilterDescendantsInstances = {LocalPlayer.Character}
        LocalPlayer.CharacterAdded:Connect(function(char)
            autofireparams.FilterDescendantsInstances = {char}
        end)
        function findminoffset(target, origin)
            if target then
                autofireparams.FilterDescendantsInstances = {LocalPlayer.Character, target.Parent}
                local aimpos = target.Position
                if not workspace:Raycast(origin, aimpos - origin, autofireparams) then
                    return Vector3.zero
                end
                local dist = ManipStep
                while dist <= Manips do
                    for i, v in cheatinfo.manip_corners do
                        if v == Vector3.zero then continue end
                        local neworigin = origin + v * dist
                        if not workspace:Raycast(neworigin, aimpos - neworigin, autofireparams) then
                            return v * dist
                        end
                    end
                    dist += ManipStep
                end
            end
        end
    --#endregion
    --#region targetting
        local FovCircle = Drawing.new("Circle")
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
                for _, plr in Players.GetPlayers(Players) do
                    if plr == LocalPlayer then
                        continue
                    end;
                    --if plr.Team == LocalPlayer.Team then
                    --    continue
                    --end
                    local Data = plr.Character
                    if not Data then
                        continue
                    end;
                    local AimPart = Data.FindFirstChild(Data, "Head") --Data:FindFirstChild("Head")
                    if not AimPart then
                        continue
                    end;
                    local Humanoid = Data.FindFirstChild(Data, "Humanoid")--Data:FindFirstChild('Humanoid')
                    if not Humanoid or Humanoid.Health <= 0 then
                        continue
                    end
                    local ScreenPos, OnScreen = Camera.WorldToViewportPoint(Camera, AimPart.Position)
--Camera:WorldToViewportPoint(AimPart.Position)
                    if not OnScreen then
                        continue
                    end;
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MouseLocation).Magnitude
                    if FovCircleEnabled then
                        local deg = math.clamp(FovCircle.Radius or 90, 0.5, 179.5)
                        local r = math.tan(math.rad(deg / 2)) / math.tan(math.rad(Camera.FieldOfView / 2)) * (Camera.ViewportSize.Y / 2)
                        if Dist > r then
                            continue
                        end
                    end
                    local vp = Camera.ViewportSize
                    if Distance < Dist then
                        continue
                    end;
                    Distance = Dist
                    FinalPart = AimPart
                end;
            return FinalPart
        end;
        local auraparams = RaycastParams.new()
        auraparams.FilterType = Enum.RaycastFilterType.Exclude
        auraparams.CollisionGroup = "WeaponRay"
        local GetAuraTarget = function(Origin, Range)
            local Char = LocalPlayer.Character
            local FinalHead, FinalResult, Distance = nil, nil, Range
            auraparams.FilterDescendantsInstances = {Char}
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
                if not Head or not Humanoid or Humanoid.Health <= 0 then
                    continue
                end
                local Dist = (Head.Position - Origin).Magnitude
                if Dist > Distance then
                    continue
                end
                local Result = workspace:Raycast(Origin, (Head.Position - Origin) * 1.1, auraparams)
                if not Result or not Result.Instance:IsDescendantOf(Data) then
                    continue
                end
                Distance = Dist
                FinalHead = Head
                FinalResult = Result
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
        local RealFireProjectile = ReplicatedStorage.Remotes.FireProjectile
        local RealProjectileInflict = ReplicatedStorage.Remotes.ProjectileInflict
        local FireProxy = {
            InvokeServer = function(self, Direction, Id, FireTick)
                local Shot = PendingInstant
                if not Shot then
                    if ShotTarget then
                        table.insert(InFlight, {Id = Id, Time = os.clock(), Head = ShotTarget})
                    end
                    return RealFireProjectile:InvokeServer(Direction, Id, FireTick)
                end
                PendingInstant = nil
                InstantShots[Id] = true
                local Result = RealFireProjectile:InvokeServer(Shot.Direction, Id, FireTick)
                if Shot.Part.Parent then
                    local Part, Offset = ToHead(Shot.Part, Shot.Offset)
                    RealProjectileInflict:FireServer(Part, Offset, Id, FireTick + 5)
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
                return RealProjectileInflict:FireServer(Part, Offset, Id, ...)
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
                        RealProjectileInflict:FireServer(Head, CFrame.new(), Shot.Id, tick())
                    end
                end
                return VFX.Impact(Part, Position, Normal, Material, Direction, Type, IsLocal, ...)
            end;
        }, {__index = VFX})
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
                MeleeInflict:FireServer(Head.Parent, Head, "NormalAttack")
                VFX.Impact(Result.Instance, Result.Position, Result.Normal, Result.Material, (Head.Position - Origin).Unit, "Melee", true)
                MeleeReplicate:FireServer(Result.Instance, Result.Position, Result.Normal, Result.Material)
            end)
            Track:Play(0.08)
        end)
    --#endregion
    --#region ragebot
        local RageFiring = false
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
                task.wait()
            end
        end)
    --#endregion
    --#region silent logic
        local CreateBullet = filtergc("function", {Name = "CreateBullet"}, true)
        if isfunctionhooked(CreateBullet) then
            restorefunction(CreateBullet)
        end
        for Index, v in debug.getupvalues(CreateBullet) do
            if v == RealFireProjectile then
                debug.setupvalue(CreateBullet, Index, FireProxy)
            elseif v == RealProjectileInflict then
                debug.setupvalue(CreateBullet, Index, InflictProxy)
            elseif v == VFX then
                debug.setupvalue(CreateBullet, Index, VFXProxy)
            end
        end
        local old; old = hookfunction(CreateBullet, function(self, weapon, worldModel, viewModel, aimPart, ToolStance, AmmoName, ...)
            local t = RagebotTarget or GetTarget()
            local Char = LocalPlayer.Character
            local HumanoidRootPart = Char and Char:FindFirstChild("HumanoidRootPart")
            local CachedCFrame = nil
            local origin = HumanoidRootPart and GetShotOrigin(Char) or aimPart.Position
            if t and (SilentAimEnabled or RagebotTarget) and HumanoidRootPart then
                if ManipEnabled then
                    local offset = findminoffset(t, origin)
                    if offset then
                        CachedCFrame = HumanoidRootPart.CFrame
                        origin = origin + offset
                        HumanoidRootPart.CFrame = CachedCFrame + offset
                    end
                end
                local AimPos = t.Position
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
            PendingInstant = nil
            ShotTarget = nil
            if CachedCFrame then
                HumanoidRootPart.CFrame = CachedCFrame
            end
            if NoRecoilEnabled and results[1] then
                results[1] = 0
                results[2] = 0
            end
            return table.unpack(results)
        end)
    --#endregion
    --#region gun mods
        local SpringV2 = require(ReplicatedStorage.Modules.SpringV2)
        local PatchSpring = function(Spring)
            local Shove = Spring.shove
            Spring.shove = function(self, Force)
                if NoRecoilEnabled then
                    return
                end
                return Shove(self, Force)
            end
        end
        local Create = SpringV2.create
        SpringV2.create = function(Self, Mass, Force, Damping, Speed)
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
        --[[local shove = filtergc("function", {Name = "shove"}, true)
        if isfunctionhooked(shove) then
            restorefunction(shove)
        end
        local old; old = hookfunction(shove, function(...)
            if NoRecoilEnabled then
                return
            end
            return old(...)
        end)]]
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
    --#endregion
    --#region toggles
        Sections.aimbot:Toggle({
            Name = 'silent aim';
            Flag = 'silentaim';
            Default = false;
            Callback = function(v)
                SilentAimEnabled = v;
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
        --[[Sections.aimbot:Toggle({
            Name = 'origin manip';
            Flag = 'manip';
            Default = false;
            Callback = function(v)
                ManipEnabled = v;
            end
        })
        Sections.aimbot:Slider({
            Name = "manip dist";
            Flag = 'manipdist';
            Max = 5;
            Min = 0;
            Default = 6;
            Decimals = 1;
            Callback = function(v)
                Manips = v;
            end
        })]]
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
            Name = 'force hit';
            Flag = 'forcehit';
            Default = false;
            Callback = function(v)
                ForceHitEnabled = v;
            end 
        })
        --[[Sections.gunmods:Slider({
            Name = 'fake latency (ms)';
            Flag = 'ticklatency';
            Default = 50;
            Min = 0;
            Max = 300;
            Decimals = 1;
            Callback = function(v)
                TickBack = v / 1000;
            end
        })]]
        Sections.killaura:Toggle({
            Name = 'killaura';
            Flag = 'killaura';
            Default = false;
            Callback = function(v)
                KillauraEnabled = v;
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
    --#endregion
end


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


--Loader:SetProgress(0.75, "loading visuals")
do -- visuals
    local FullbrightEnabled = false;
    local NoFogEnabled = false;
    local TsAmbient = Color3.fromRGB(255, 255, 255)
    local TsOutdoorAmbient = Color3.fromRGB(255, 255, 255)
    local Fov = 200
    local FovChanger = false;
    local TpDistance = 15
    
    

    
    
    
    local oldmin = LocalPlayer.CameraMinZoomDistance
    local oldmax = LocalPlayer.CameraMaxZoomDistance


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

        RunService.RenderStepped:Connect(function()
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
        end)


    --#endregion



    --#region toggles

        Sections.visuals:Toggle({
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
        })
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
        Sections.visuals:Toggle({
            Name = 'no fog';
            Flag = 'nofog';
            Default = false;
            Callback = function(v)
                NoFogEnabled = v;
            end
        })

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

        --[[Sections.visuals:Toggle({
            Name = 'no grass';
            Flag = 'nograss';
            Default = false;
            Callback = function(v)
                sethiddenproperty(workspace.Terrain, "Decoration", not v)
            end
        })]]
    --#endregion toggles
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
    local VFX = require(ReplicatedStorage.Modules.VFX)
    local OmniSprintEnabled = false


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

        local Impact = VFX.Impact

        if isfunctionhooked(Impact) then
            restorefunction(Impact)
        end

        local Effects = nil

        local old; old = hookfunction(Impact, function(Part, Position, Normal, Material, Direction, Type, IsLocal, ...)
            local Muted = {}

            if HitsoundEnabled and IsLocal and Part.Parent and Part.Parent:FindFirstChild("Humanoid") then
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
    --#endregion
end 


--Loader:SetProgress(0.9, "finishing")
Window:InitWindow()
--Loader:Finish()
