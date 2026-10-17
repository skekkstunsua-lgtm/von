--arsenal



--#region checks

    if not game:IsLoaded() then 
        game.Loaded:Wait()
    end

    if not LPH_OBFUSCATED then 
        local FakeFunction = function(...)
            return(...)
        end;

        LPH_NO_VIRTUALIZE = FakeFunction;
        LPH_NO_UPVALUES = FakeFunction;
        LPH_JIT = FakeFunction;
        LPH_JIT_MAX = FakeFunction;
    end;

--#endregion



--#region defs

    local Camera = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    local Players = game.Players 
    local LocalPlayer = Players.LocalPlayer 
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local ReplicatedFirst = game:GetService("ReplicatedFirst")

    local Modules = { -- Modules.
        Spread = require(ReplicatedStorage.Modules.Spread);
        GeneralFunctions = require(ReplicatedStorage.Modules.GeneralFunctions);
        Events = require(ReplicatedStorage.Modules.Events);
        NetClient = require(ReplicatedFirst.Client.Utility.NetClient);
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
    local amity = loadstring(game:HttpGet('https://raw.githubusercontent.com/78n/Roblox/refs/heads/main/Lua/Libraries/DataToCode/DataToCode.luau'))()

    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sametexe001/sametlibs/refs/heads/main/secrethaxx/Library.lua"))()
    
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
        gunmods = Pages.CombatPage:Section({
            Name = 'gun mods';
            Side = 2;
        });
        exploits = Pages.CombatPage:Section({
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
        miscexploits = Pages.MiscPage:Section({
            Name = 'exploits';
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

do -- combat
    local SilentEnabled = false;
    local NoSpread = false;
    local ManipEnabled = false;
    local FovCircleEnabled = false;
    local NoSpreadEnabled = false;
    local Manips = 5;
    local ManipStep = 0.25;
    local RagebotEnabled = false;
    local AutoReloadEnabled = false;
    local BlinkEnabled = false;
    local blinkactive = false;
    local savedblinkCF = nil;
    local KillAllEnabled = false;
    local ForceHitEnabled = false;
    local ProjectileSilentEnabled = false
    local LastOrigin = nil
    local LastTarget = nil
    local AntiAimEnabled = false
    local AAPitch = "Up"
    local AAYaw = "Backwards"
    local AntiAimVec = nil
    local DefaultNeckC0 = nil
    local DefaultWaistC0 = nil

    RunService.RenderStepped:Connect(function()
        if blinkactive and savedblinkCF then
            Camera.CFrame = savedblinkCF
        end
    end)

    RunService:BindToRenderStep("AntiAimSync", Enum.RenderPriority.Last.Value + 1, function()
        if AntiAimEnabled and AntiAimVec then
            local Char = LocalPlayer.Character
            if Char then
                local Head = Char:FindFirstChild("Head")
                local UpperTorso = Char:FindFirstChild("UpperTorso")
                if Head and Head:FindFirstChild("Neck") and DefaultNeckC0 then
                    Head.Neck.C0 = DefaultNeckC0 * CFrame.Angles(math.asin(math.clamp(AntiAimVec.Y, -1, 1)), 0, 0)
                end
                if UpperTorso and UpperTorso:FindFirstChild("Waist") and DefaultWaistC0 then
                    local YawAngle = math.atan2(AntiAimVec.X, AntiAimVec.Z)
                    UpperTorso.Waist.C0 = DefaultWaistC0 * CFrame.Angles(0, -YawAngle, 0)
                end
            end
        end
    end)

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



    --#region silent logic
    
        local autofireparams = RaycastParams.new()
        autofireparams.FilterType = Enum.RaycastFilterType.Blacklist
        autofireparams.FilterDescendantsInstances = {LocalPlayer.Character}

        LocalPlayer.CharacterAdded:Connect(function(char)
            autofireparams.FilterDescendantsInstances = {char}
            task.wait()
            local Head = char:FindFirstChild("Head")
            local UpperTorso = char:FindFirstChild("UpperTorso")
            if Head and Head:FindFirstChild("Neck") then
                DefaultNeckC0 = Head.Neck.C0
            end
            if UpperTorso and UpperTorso:FindFirstChild("Waist") then
                DefaultWaistC0 = UpperTorso.Waist.C0
            end
        end)

        do
            local Char = LocalPlayer.Character
            if Char then
                local Head = Char:FindFirstChild("Head")
                local UpperTorso = Char:FindFirstChild("UpperTorso")
                if Head and Head:FindFirstChild("Neck") then
                    DefaultNeckC0 = Head.Neck.C0
                end
                if UpperTorso and UpperTorso:FindFirstChild("Waist") then
                    DefaultWaistC0 = UpperTorso.Waist.C0
                end
            end
        end


        local FovCircle = Drawing.new("Circle")

        FovCircle.Radius = 100
        FovCircle.Color = Color3.fromRGB(255, 255, 255)
        FovCircle.Visible = false

        local fovconnection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
            if FovCircleEnabled then 
                FovCircle.Position = UserInputService:GetMouseLocation()
            end
        end))


        function findminoffset(target, origin, ignorezeropos)
            local maxdist = Manips
            local step = ManipStep

            if target then 
                local aimpos = target.Position
                local disttotarget = (aimpos - origin).Magnitude -- change so not ziro

                local centerdir = (aimpos - origin).Unit
                local centerresult = workspace:Raycast(origin, centerdir * disttotarget, autofireparams)

                if centerresult and centerresult.Instance and not ignorezeropos then
                    if centerresult.Instance:IsDescendantOf(target.Parent) then
                        return Vector3.zero, false, centerresult.Instance
                    end
                end

                local step = 0.25
                local dist = step
            
                while dist <= Manips do
                    for i, v in cheatinfo.manip_corners do
                        if v == Vector3.zero then continue end

                        local newoffset = v * dist
                        local neworigin = origin + newoffset
                        local dir = (aimpos - neworigin).Unit
                        local result = workspace:Raycast(neworigin, dir * disttotarget, autofireparams)

                        if result and result.Instance then
                            if result.Instance:IsDescendantOf(target.Parent) then
                                return newoffset, i ~= 1, result.Instance
                            end
                        end
                    end
                    dist += step
                end

                return nil, false, nil
            end
        end

        function GetTarget()
            local MouseLocation = UserInputService.GetMouseLocation(UserInputService)
            local FinalPart, Distance = nil, math.huge

                for _, plr in Players.GetPlayers(Players) do
                    if plr == LocalPlayer then 
                        continue 
                    end;
                    if plr.Team == LocalPlayer.Team then
                        continue 
                    end

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

                    local ScreenPos, OnScreen = Camera.WorldToViewportPoint(Camera, AimPart.Position) --Camera:WorldToViewportPoint(AimPart.Position)
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


        local visparams = RaycastParams.new()
        visparams.FilterType = Enum.RaycastFilterType.Blacklist

        function GetVisibleTarget()
            for _, plr in Players:GetPlayers() do
                    if plr == LocalPlayer or plr.Team == LocalPlayer.Team then 
                    continue 
                    end
                    
                    local data = plr.Character
                    
                    if not data then 
                    continue 
                    end

                    local head = data:FindFirstChild("Head")
                    if not head or head.Position.Y < -250 then 
                    continue 
                    end
                    
                    local hum = data:FindFirstChild("Humanoid")
                    
                    if not hum or hum.Health <= 0 then 
                    continue 
                    end

                    visparams.FilterDescendantsInstances = {LocalPlayer.Character, data}
                    local origin = Camera.CFrame.Position
                    local visresult = workspace:Raycast(origin, head.Position - origin, visparams)

                    if not visresult then
                    local offset = ManipEnabled and findminoffset(head, origin) or nil
                    return { FinalPart = head, offset = offset }
                    elseif ManipEnabled then
                    local offset = findminoffset(head, origin)
                    if offset then
                            return { FinalPart = head, offset = offset }
                    end
                    end
            end
        end

        function GetKillAllTarget()
            for _, plr in Players:GetPlayers() do
                if plr == LocalPlayer or plr.Team == LocalPlayer.Team then 
                    continue 
                end
                
                local data = plr.Character
                
                if not data then 
                    continue 
                end

                local head = data:FindFirstChild("Head")
                if not head or head.Position.Y < -250 then 
                    continue 
                end
                
                local hum = data:FindFirstChild("Humanoid")
                
                if not hum or hum.Health <= 0 then 
                    continue 
                end

                return head
            end
        end 

        local Cast = Modules.GeneralFunctions.cast

        if isfunctionhooked(Cast) then 
            restorefunction(Cast)
        end 

        local old; old = hookfunction(Cast, function(p1, p2)
            local t;
            local origin;
            local dir;

            if not RagebotEnabled and not KillAllEnabled then 
                t = GetTarget()
            else 
                t = GetVisibleTarget()
            end 

            local c = LocalPlayer.Character
            
            if BlinkEnabled and c then
                local lroot = c:FindFirstChild("HumanoidRootPart")
                local blinktarget = GetTarget()

                if lroot and blinktarget and not GetVisibleTarget() then
                    savedblinkCF = lroot.CFrame
                    blinkactive = true
                    lroot.CFrame = CFrame.new(blinktarget.Position + Vector3.new(0, 1, 0))

                    t = GetVisibleTarget() or t

                    task.delay(0.05, function()
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then 
                            root.CFrame = savedblinkCF 
                        end
                        blinkactive = false
                    end)
                end
            end

            if t and c and RagebotEnabled and c:FindFirstChild("Head") then 
                local head = c:FindFirstChild("Head")
                origin = head.Position

                if ManipEnabled then
                    local offset = findminoffset(t.FinalPart, origin)
                    if offset then
                        origin = origin + offset
                        LastOrigin = (ManipEnabled and offset) and origin or nil
                        LastTarget = t.FinalPart
                    end
                end
                
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                local isKnife = tool and not tool:FindFirstChild("Ammo")

                dir = (t.FinalPart.Position - origin).Unit

                p1 = Ray.new(origin, dir * (isKnife and 60 or p1.Direction.Magnitude))
                if TracerEnabled then 
                    CreateTracer(origin, dir) 
                end

                if not ForceHitEnabled then 
                return old(p1, p2)
                else 
                local head = t.FinalPart.Parent:FindFirstChild("Head")
                local hitPart = head or t.FinalPart
                return hitPart, hitPart.Position, Vector3.new(0, 1, 0)
                end
            end

            if SilentEnabled and t and c and c:FindFirstChild("Head") then 

                local head = c:FindFirstChild("Head")
                
                origin = head.Position
                local offset, _, _ = findminoffset(t, origin)

                if offset and ManipEnabled then 
                    origin = origin + offset
                    LastOrigin = (ManipEnabled and offset) and origin or nil
                    LastTarget = t
                end

                dir = (t.Position - origin).Unit

                --origin = t.Position - dir * 3

                p1 = Ray.new(origin, dir)
            end 

            if TracerEnabled then
                local tracerDir = dir or p1.Direction.Unit
                local tracerOrigin = origin or p1.Origin
                CreateTracer(tracerOrigin, tracerDir)
            end

            if ForceHitEnabled and t then 
                local head = t.Parent and t.Parent:FindFirstChild("Head")
                local hitPart = head or t
                return hitPart, hitPart.Position, Vector3.new(0/0, 0/0, 0/0)
            else 
                return old(p1, p2)
            end
        end)
        
        do -- make silent work w projectiles.
        local project = false
        local createproject = false
        local throwball = false
        local throwgrenade = false
        local charlook = false
        local InHit = false
        local F32s = 0
        local targetprojectile = nil
        local throwspawnpos = {}
        local grenadevelo = nil
        local SpoofedCams = nil

        --u16 hook

        local old; old = hookfunction(Modules.NetClient.u16, function(id)
                if id == Modules.Events.ReplicateProjectile then
                project = true
                F32s = 0
                targetprojectile = SilentEnabled and GetTarget() or nil
                elseif id == Modules.Events.CreateProjectile then
                createproject = true
                F32s = 0
                targetprojectile = SilentEnabled and GetTarget() or nil
                elseif id == Modules.Events.ThrowBall then
                throwball = true
                F32s = 0
                throwspawnpos = {}
                targetprojectile = SilentEnabled and GetTarget() or nil
                elseif id == Modules.Events.ThrowGrenade then
                throwgrenade = true
                F32s = 0
                grenadevelo = nil
                if SilentEnabled then
                        local target = GetTarget()
                        if target then
                                local char = LocalPlayer.Character
                                local root = char and char:FindFirstChild("HumanoidRootPart")
                                if root then
                                        local spawnPos = root.Position + Vector3.new(0, 2, 0)
                                        local dir = (target.Position - spawnPos).Unit
                                        grenadevelo = dir * 85
                                end
                        end
                end
                elseif id == Modules.Events.HitPart then
                InHit = true
                F32s = 0

                if LastOrigin and LastTarget and ManipEnabled then
                        local spoofCF = CFrame.lookAt(LastOrigin, LastTarget.Position)
                        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = spoofCF:GetComponents()
                        SpoofedCams = {x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22}
                else
                        SpoofedCams = nil
                end
                elseif id == Modules.Events.ControlCharacterLook then
                if AntiAimEnabled then
                        charlook = true
                        F32s = 0

                        local PitchY
                        if AAPitch == "Up" then
                                PitchY = 0.9
                        elseif AAPitch == "Down" then
                                PitchY = -0.9
                        elseif AAPitch == "Jitter" then
                                PitchY = math.floor(tick() * 10) % 2 == 0 and 0.9 or -0.9
                        else
                                PitchY = 0
                        end

                        local HScale = math.sqrt(math.max(0, 1 - PitchY * PitchY))
                        local YawX, YawZ

                        if AAYaw == "Backwards" then
                                local LV = Camera.CFrame.LookVector
                                local Len = math.sqrt(LV.X * LV.X + LV.Z * LV.Z)
                                if Len > 0 then
                                        YawX = -LV.X / Len
                                        YawZ = -LV.Z / Len
                                else
                                        YawX = 0
                                        YawZ = 1
                                end
                        elseif AAYaw == "Away From Target" then
                                local Target = GetTarget()
                                local Char = LocalPlayer.Character
                                local Root = Char and Char:FindFirstChild("HumanoidRootPart")
                                if Target and Root then
                                        local DX = Root.Position.X - Target.Position.X
                                        local DZ = Root.Position.Z - Target.Position.Z
                                        local Len = math.sqrt(DX * DX + DZ * DZ)
                                        if Len > 0 then
                                                YawX = DX / Len
                                                YawZ = DZ / Len
                                        else
                                                YawX = 0
                                                YawZ = 1
                                        end
                                else
                                        YawX = 0
                                        YawZ = 1
                                end
                        elseif AAYaw == "Forwards" then
                                local LV = Camera.CFrame.LookVector
                                local Len = math.sqrt(LV.X * LV.X + LV.Z * LV.Z)
                                if Len > 0 then
                                        YawX = LV.X / Len
                                        YawZ = LV.Z / Len
                                else
                                        YawX = 0
                                        YawZ = 1
                                end
                        elseif AAYaw == "Spin" then
                                YawX = math.cos(tick() * 6)
                                YawZ = math.sin(tick() * 6)
                        else
                                YawX = 0
                                YawZ = 1
                        end

                        AntiAimVec = Vector3.new(YawX * HScale, PitchY, YawZ * HScale)
                end
                end

                return old(id)
        end)


        --f32 hook

        local old; old = hookfunction(Modules.NetClient.f32, function(v)
                if project then
                F32s += 1

                if F32s >= 2 and F32s <= 4 and targetprojectile then
                        local pos = targetprojectile.Position
                        return old(({pos.X, pos.Y, pos.Z})[F32s - 1])
                end
                elseif createproject then
                F32s += 1

                if F32s <= 3 and targetprojectile then
                        local pos = targetprojectile.Position
                        return old(({pos.X, pos.Y, pos.Z})[F32s])
                end
                elseif throwball then
                F32s += 1

                if F32s <= 3 then
                        throwspawnpos[F32s] = v
                elseif F32s <= 6 and targetprojectile and #throwspawnpos == 3 then
                        local spawnPos = Vector3.new(throwspawnpos[1], throwspawnpos[2], throwspawnpos[3])
                        local lookVec = (targetprojectile.Position - spawnPos).Unit
                        return old(({lookVec.X, lookVec.Y, lookVec.Z})[F32s - 3])
                end
                elseif throwgrenade then
                F32s += 1

                if F32s <= 3 and grenadevelo then
                        return old(({grenadevelo.X, grenadevelo.Y, grenadevelo.Z})[F32s])
                end
                elseif InHit then
                F32s += 1

                if F32s <= 12 and SpoofedCams then
                        return old(SpoofedCams[F32s])
                end
                elseif charlook then
                F32s += 1

                if F32s <= 3 and AntiAimVec then
                        return old(({AntiAimVec.X, AntiAimVec.Y, AntiAimVec.Z})[F32s])
                end
                end

                return old(v)
        end)


        -- unlock hook

        local old; old = hookfunction(Modules.NetClient.unlock, function(...)
                if project then
                project = false
                F32s = 0
                targetprojectile = nil
                elseif createproject then
                createproject = false
                F32s = 0
                targetprojectile = nil
                elseif throwball then
                throwball = false
                F32s = 0
                targetprojectile = nil
                throwspawnpos = {}
                elseif throwgrenade then
                throwgrenade = false
                F32s = 0
                grenadevelo = nil
                elseif InHit then
                InHit = false
                F32s = 0
                SpoofedCams = nil
                LastOrigin = nil
                LastTarget = nil
                elseif charlook then
                charlook = false
                F32s = 0
                end

                return old(...)
        end)
        end

        --local Bridge = require(game.ReplicatedFirst.Client.Utility.Bridge)
        local firebullet = filtergc("function", {Name = "firebullet"}, true)
        local reloadweapon = filtergc("function", {Name = "reloadwep"}, true)

        task.spawn(function()
            while true do 
                if KillAllEnabled then 
                    local t = GetKillAllTarget()

                    local c = LocalPlayer.Character
                    
                    if not firebullet then 
                        repeat firebullet = filtergc("function", {Name = "firebullet"}, true) task.wait() until firebullet 
                    end 


                    if t and c and c:FindFirstChild("Head") and c:FindFirstChild("HumanoidRootPart") then
						offset = cheatinfo.manip_corners[math.random(1, #cheatinfo.manip_corners)] * (math.random(1000, 4000)/1000)
                        c:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(t.Position + offset)
                        

                        local works = pcall(firebullet, false)

                        if not works then 
                            firebullet = nil 
                        end 
                        
                        --warn('yo')
                    end 

                elseif RagebotEnabled then 
                    local t = GetVisibleTarget()
                    local c = LocalPlayer.Character
                    
                    if not firebullet then 
                        repeat firebullet = filtergc("function", {Name = "firebullet"}, true) task.wait() until firebullet 
                    end 


                    if t and c and c:FindFirstChild("Head") then 
                        local works = pcall(firebullet, false)

                        if not works then 
                            firebullet = nil 
                        end 
                        
                        --warn('yo')
                    end 
                    --print('yo  wth')
                end 

                task.wait(0)
            end 
        end)

        task.spawn(function()
            while true do 
                if AutoReloadEnabled then 
                    if not reloadweapon then 
                        repeat reloadweapon = filtergc("function", {Name = "reloadwep"}, true) task.wait() until reloadweapon
                    end 
                    
                    local works = pcall(reloadweapon)

                    if not works then 
                        reloadweapon = nil 
                    end 
                end 

                task.wait(0)
            end 
        end)
    --#endregion

    

    --#region gun mod logic
        local c = Modules.Spread.calcspread

        if isfunctionhooked(c) then 
            restorefunction(c)
        end 

        local old; old = hookfunction(c, function(p1, p2, p3, p4, p5, p6, p7, p8, ...) 
            if NoSpreadEnabled then 
                p1 = 0
            end 

            return old(p1, p2, p3, p4, p5, p6, p7, p8, ...)
        end)

        local Weapons = ReplicatedStorage.Weapons

        local cached = {}
        local cachedfires = {}
        local cachedreloads = {}

        local DoReloadTime = function(value)
            if value then
                for _, v in Weapons:GetDescendants() do
                    if v.Name == "ReloadTime" or v.Name == "EReloadTime" or v.Name == "SReload" or v.Name == "AReload" then
                        cachedreloads[v] = v.Value
                        v.Value = 0
                    end
                end
            else
                for i, v in cachedreloads do
                    i.Value = v
                end
                table.clear(cachedreloads)
            end
        end
        local DoFireRate = function(value)
            if value then 
                for i, v in Weapons:GetDescendants() do 
                    if v.Name == "FireRate" then 
                        cachedfires[v] = v.Value 
                        v.Value = -1
                    end 
                end 
            else 
                for i, v in cachedfires do 
                    i.Value = v
                end 
                
                table.clear(cachedfires)
            end 
        end 

        local DoRecoil = function(value)
            if value then 
                for i, v in Weapons:GetDescendants() do 
                    if v.Name == "RecoilControl" then 
                        cached[v] = v.Value 
                        v.Value = 0
                    end 
                end 
            else 
                for i, v in cached do 
                    i.Value = v
                end 
                
                table.clear(cached)
            end 
        end 

    --#endregion



    --#region toggles
        Sections.aimbot:Toggle({
            Name = 'silent aim';
            Flag = 'silentaim';
            Default = false;
            Callback = function(v)
                SilentEnabled = v;
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
        Sections.aimbot:Label({Name = 'manip can lag with ragebot'})

        Sections.aimbot:Toggle({
            Name = 'ragebot';
            Flag = 'ragebot';
            Default = false;
            Callback = function(v)
                RagebotEnabled = v;
            end
        })

        Sections.gunmods:Toggle({
            Name = 'no spread';
            Flag = 'nospread';
            Default = false;
            Callback = function(v)
                NoSpreadEnabled = v;
            end 
        })

        Sections.gunmods:Toggle({
            Name = 'no recoil';
            Flag = 'norecoil';
            Default = false;
            Callback = function(v)
                DoRecoil(v)
            end 
        })

        Sections.gunmods:Toggle({
            Name = 'fast reload';
            Flag = 'fastreload';
            Default = false;
            Callback = function(v)
                DoReloadTime(v)
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

        Sections.gunmods:Toggle({
            Name = 'fast shoot';
            Flag = 'fastshoot';
            Default = false;
            Callback = function(v)
                DoFireRate(v)
            end 
        })

        Sections.exploits:Toggle({
            Name = 'force hit';
            Flag = 'forcehit';
            Default = false;
            Callback = function(v)
                ForceHitEnabled = v;
            end 
        })

        Sections.exploits:Toggle({
            Name = 'tp shoot';
            Flag = 'blinkshot';
            Default = false;
            Callback = function(v)
                BlinkEnabled = v;
            end
        })

        Sections.exploits:Toggle({
            Name = 'kill all (use with ragebot)';
            Flag = 'killall';
            Default = false;
            Callback = function(v)
                KillAllEnabled = v;
            end
        })

        Sections.exploits:Toggle({
            Name = 'anti aim';
            Flag = 'antiaim';
            Default = false;
            Callback = function(v)
                AntiAimEnabled = v
                if not v then
                    AntiAimVec = nil
                    local Char = LocalPlayer.Character
                    if Char then
                        local Head = Char:FindFirstChild("Head")
                        local UpperTorso = Char:FindFirstChild("UpperTorso")
                        if Head and Head:FindFirstChild("Neck") and DefaultNeckC0 then
                            Head.Neck.C0 = DefaultNeckC0
                        end
                        if UpperTorso and UpperTorso:FindFirstChild("Waist") and DefaultWaistC0 then
                            UpperTorso.Waist.C0 = DefaultWaistC0
                        end
                    end
                end
            end
        })

        Sections.exploits:Dropdown({
            Name = 'aa pitch';
            Items = {"Up", "Down", "Jitter"};
            Default = "Up";
            Callback = function(v)
                AAPitch = v
            end
        })

        Sections.exploits:Dropdown({
            Name = 'aa yaw';
            Items = {"Backwards", "Away From Target", "Forwards", "Spin"};
            Default = "Backwards";
            Callback = function(v)
                AAYaw = v
            end
        })
    --#endregion
end 



do -- visuals
    local FullbrightEnabled = false;
    local NoFogEnabled = false;
    local TsAmbient = Color3.fromRGB(255, 255, 255)
    local TsOutdoorAmbient = Color3.fromRGB(255, 255, 255)
    local Fov = 200
    local FovChanger = false;
    local ThirdPerson = false;
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
            Max = 200;
            Min = 60;
            Default = 200;
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

    --#endregion toggles
end 



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
end

do -- misc
    local BhopEnabled = false;
    local SpeedhackEnabled = false;
    local SpeedSpeed = 1;
    local NoMapKillers = false;

    --#region logic
        if workspace.Map and workspace.Map:FindFirstChild("Killers") and NoMapKillers then 
        workspace.Map.Killers.Parent = nil 
        end

        workspace.DescendantAdded:Connect(function(descent)
        if NoMapKillers and descent.Name == 'Killers' then 
                repeat descent.Parent = nil task.wait() until descent.Parent == nil 
                
        end
        end)
        RunService.Heartbeat:Connect(function(delta)
            if SpeedhackEnabled and LocalPlayer.Character then 
                local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')

                LocalPlayer.Character:TranslateBy(humanoid.MoveDirection * (SpeedSpeed) * delta * 10)
            end;
            if BhopEnabled then 
                local Char = LocalPlayer.Character 

                if Char and Char:FindFirstChild("Humanoid") then 
                    if Char:FindFirstChild("Humanoid").MoveDirection.Magnitude > 0 then
                        Char:FindFirstChild("Humanoid").Jump = true
                    end
                end 
            
            end;
        end)

    --#endregion



    --#region toggles
        Sections.miscexploits:Toggle({
            Name = 'no map killers';
            Flag = 'nokillers';
            Default = false;
            Callback = function(v)
                NoMapKillers = v;
                
                if workspace.Map and workspace.Map:FindFirstChild("Killers") and v then 
                    workspace.Map.Killers.Parent = nil 
                end
            end
        })
        
        Sections.movement:Toggle({
            Name = 'bhop';
            Flag = 'bop';
            Default = false;
            Callback = function(v)
                BhopEnabled = v;
            end 
        })

        Sections.movement:Toggle({
            Name = 'speed';
            Flag = 'speedhack';
            Default = false;
            Callback = function(v)
                SpeedhackEnabled = v;
            end 
        })

        Sections.movement:Slider({
            Name = 'speed speed';
            Flag = 'speedspeed';
            Default = 1;
            Min = 0;
            Max = 10;
            Decimals = 1;
            Callback = function(v)
                SpeedSpeed = v;
            end 
        })
    
    --#endregion

end 

Window:InitWindow()
