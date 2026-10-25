--jailbird



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

    local Modules = { -- Modules.
        DynamicCrosshair = require(ReplicatedStorage.Components.DynamicCrosshair);
        Config = require(game:GetService("ReplicatedStorage").Config);
    };

    local Remotes = {
        KillEvent = ReplicatedStorage.GameEvents.Damage;
        DeviceUpdate = ReplicatedStorage.GameEvents.DeviceUpdate;
        ReloadEvent = ReplicatedStorage.GameEvents.Reload;
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

    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/BullshitLib.lua"))()

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



--#region lookups

    local BulletRayCast;

    LPH_NO_VIRTUALIZE(function()
        BulletRayCast = filtergc("function", {Name = 'BulletRayCast'}, true);
    end)()

--#endregion


local WallbangEnabled = false;

local cachedtarget = nil

do -- combat
    local SilentAimEnabled = false; 
    local KillAllEnabled = false;
    local NoSpreadEnabled = false;
    local ManipEnabled = false;
    local Manips = 5;
    local ManipStep = 0.25;
    local NoRecoilEnabled = false;
    local RageBotEnabled = false;
    local SilentReload = false;
    local AimbotEnabled = false;
    local Smoothing = 1;
    local FovCircleEnabled = false;
    local RapidFireEnabled = false;

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

        local cachedoffset = nil
        --local lastShotTarget = nil
        
        RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
            cachedtarget = (SilentAimEnabled or RageBotEnabled or AimbotEnabled) and GetTarget() or nil
        end))

        local autofireparams = RaycastParams.new()
        autofireparams.FilterType = Enum.RaycastFilterType.Blacklist
        autofireparams.FilterDescendantsInstances = {LocalPlayer.Character}

        LocalPlayer.CharacterAdded:Connect(function(char)
            autofireparams.FilterDescendantsInstances = {char}
        end)

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

    --#endregion

    --#region targetting
        local FovCircle = Drawing.new("Circle")

        FovCircle.Radius = 100
        FovCircle.Color = Color3.fromRGB(255, 255, 255)
        FovCircle.Visible = false

        local fovconnection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
            if FovCircleEnabled then 
                FovCircle.Position = UserInputService:GetMouseLocation()
            end
        end))

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



        function GetVisibleTarget()
            local visparams = RaycastParams.new()
            visparams.FilterType = Enum.RaycastFilterType.Blacklist

            for _, plr in Players:GetPlayers() do
                if plr == LocalPlayer or plr.Team == LocalPlayer.Team then 
                    continue 
                end
                
                local data = plr.Character
                
                if not data then 
                    continue 
                end

                local head = data:FindFirstChild("Head")
                if not head then 
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
                end
            end
        end

    --#endregion



    --#region hooks / logic

        --#region silent + no spread 
            if isfunctionhooked(BulletRayCast) then 
                restorefunction(BulletRayCast)
            end 

            local old; old = hookfunction(BulletRayCast, LPH_JIT_MAX(function(p22, p23, p24, p25, p26, p27, ...) 
                
                --cachedtarget = nil 
                --cachedtarget = GetTarget()

                local t = cachedtarget or GetTarget()
                local Stack = getstack(3)
                
                local OriginalOrigin = p22 
                local OriginalDirection = p23 

                --p22 is origin, p23 is direction. p27 is also like sum origin shit
                -- warn(p22)



                if t and SilentAimEnabled then 
                    local offset, _, _ = findminoffset(t, p22)

                    if offset and ManipEnabled then 
                        cachedoffset = offset

                        p22 = p22 + offset
                        --p27 = p27 + offset
                    end

                    p23 = (t.Position - p22).Unit

                    for i, v in Stack do 
                        if typeof(v) == 'Vector3' and v == OriginalOrigin then 
                            setstack(3, i, p22)
                        elseif typeof(v) == 'Vector3' and v == OriginalDirection then 
                            setstack(3, i, p23)
                        end 
                    end     

                    --p22 = t.Position - dir * 3
                elseif not t and NoSpreadEnabled then 
                    p23 = Camera.CFrame.LookVector
                end 

                if TracerEnabled then 
                    CreateTracer(p22, p23) 
                end

                return old(p22, p23, p24, p25, p26, p27, ...) 
            end))


            -- makes it look more visually pleasing i think

            if isfunctionhooked(Modules.DynamicCrosshair.Update) then 
                restorefunction(Modules.DynamicCrosshair.Update)
            end 

            local old; old = hookfunction(Modules.DynamicCrosshair.Update, function(p49, p50, ...) 
                if NoSpreadEnabled then 
                    p49.Spreading.Spread = 0.1
                    p49.Spreading.MinSpread = 0
                    p49.Spreading.MaxSpread = 0.1
                else 
                    p49.Spreading.MaxSpread = 150
                end 

                return old(p49, p50, ...)
            end)

        --#endregion



        --#region kill all & ragebot

            local RageBot = function()
                if not RageBotEnabled then 
                    return 
                end 

                local t = GetVisibleTarget()

                if t then 
                    local offset = t.offset
                    
                    local Origin = Camera.CFrame.Position

                    if offset and ManipEnabled then 
                        cachedoffset = offset
                        Origin = Origin + offset
                    end


                    if TracerEnabled then 
                        CreateTracer(Origin, (t.FinalPart.Position - Origin).Unit) 
                    end

                    Remotes.KillEvent:FireServer(
                        Players:GetPlayerFromCharacter(t.FinalPart.Parent),
                        200,
                        "M4A1",
                        {
                            Normal = Vector3.new(0/0, 0/0, 0/0),
                            Direction = (t.FinalPart.Position - Origin).Unit,
                            StartPosition = Origin,
                            Instance = t.FinalPart,
                            Material = t.FinalPart.Material,
                            EndPosition = t.FinalPart.Position 
                        }
                    )
                end 
            end


            local KillAll = function()
                if not KillAllEnabled then 
                    return 
                end 

                for i, v in Players:GetPlayers() do
                    if v == LocalPlayer then 
                        continue 
                    end
                    if v.Team == LocalPlayer.Team then 
                        continue 
                    end 
                    
                    if not v.Character or not v.Character:FindFirstChild("Head") then 
                        continue 
                    end 
                    
                    if not v.Character:FindFirstChild("Humanoid") or v.Character:FindFirstChild("Humanoid").Health <= 0 then 
                        continue 
                    end 


                    Remotes.KillEvent:FireServer(
                        v,
                        200,
                        "M4A1",
                        {
                            Normal = Vector3.new(0/0, 0/0, 0/0),
                            Direction = Vector3.new(0/0, 0/0, 0/0),
                            StartPosition = Vector3.new(0/0, 0/0, 0/0),
                            Instance = v.Character.Head,
                            Material = v.Character.Head.Material,
                            EndPosition = v.Character.Head.Position 
                        }
                    )
                end
            end

            task.spawn(function()
                while true do 
                    RageBot()
                    task.wait(0.1)
                end 
            end)

            task.spawn(function()
                while true do
                    KillAll()
                    
                    if SilentReload then 
                        Remotes.ReloadEvent:FireServer("G17")
                    end 

                    task.wait(0.05)
                end
            end)

        --#endregion
        
        
        
        --#region aimbot

            RunService.RenderStepped:Connect(LPH_JIT_MAX(function()
                local t = cachedtarget or GetTarget()

                if AimbotEnabled and t and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then 
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Smoothing)
                end 
            end))
        
        --#endregion



        --#region gun mods
            local shit = filtergc("function", {Name = 'Bullet'}, true)

            if isfunctionhooked(shit) then 
                restorefunction(shit)
            end 

            local old; old = hookfunction(shit, function(v7, ...) 
                local new = old(v7, ...)

                if NoRecoilEnabled then 
                    new.PositionInfluence = Vector3.zero
                    new.RotationInfluence = Vector3.zero 
                    new._camShakeInstance = false
                end 

                return new
            end)
            --[[local HookRecoil = function()
                local Recoil = filtergc("function", {Name = 'Recoil'}, true)
                
                if not Recoil then 
                    return 
                end 

                if isfunctionhooked(Recoil) then 
                    restorefunction(Recoil)
                end 

                local old; old = hookfunction(Recoil, LPH_JIT_MAX(function(...) 
                    if NoRecoilEnabled then 
                        return 
                    end 

                    return old(...)
                end))
            end
            
            HookRecoil()
            
            LocalPlayer.CharacterAdded:Connect(function(char)
                repeat task.wait(1) until char:FindFirstChild("ClientWeaponSystem")
                repeat task.wait() until filtergc("function", {Name = 'Recoil'}, true)
                HookRecoil()
                task.wait(3)
                HookRecoil()
                task.wait(4)
                HookRecoil()
                task.wait(8)
                HookRecoil()
                task.wait(2)
                HookRecoil()
                -- I know this looks tweaker asf, but I deadass couldnt find another way to do this reliably.
            end)]]
            

            --[[if isfunctionhooked(task.wait) then 
                restorefunction(task.wait)
            end

            local old; old = hookfunction(task.wait, function(num, ...)
                if RapidFireEnabled then
                    local tb = debug.traceback()

                    if tb:find('Shoot') and tb:find('ClientWeaponSystem') then
                        num = 0
                    end
                end

                return old(num, ...)
            end)]]
        --#endregion

    --#endregion

    
    
    --#region toggles

        Sections.aimbot:Toggle({
            Name = 'aimbot';
            Flag = 'aimbot';
            Default = false;
            Callback = function(v)
                AimbotEnabled = v;
            end 
        })

        Sections.aimbot:Slider({
            Name = "smoothing";
            Flag = 'smoothing';
            Max = 1;
            Min = 0;
            Default = 1;
            Decimals = 0.1;
            Callback = function(v)
                Smoothing = v;
            end
        })

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

        Sections.aimbot:Toggle({
            Name = 'origin manip';
            Flag = 'manip';
            Default = false;
            Callback = function(v)
                ManipEnabled = v;
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

        Sections.aimbot:Toggle({
            Name = 'auto kill all';
            Flag = 'autokillall';
            Default = false;
            Callback = function(v)
                KillAllEnabled = v;
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
                NoRecoilEnabled = v;
            end 
        })

        --[[Sections.gunmods:Toggle({
            Name = 'rapid fire';
            Flag = 'rapidfire';
            Default = false;
            Calllback = function(v)
                RapidFireEnabled = v;
            end
        })]]

        Sections.gunmods:Toggle({
            Name = 'silent reload';
            Flag = 'silentreload';
            Default = false;
            Callback = function(v)
                SilentReload = v;
            end;
        })

        Sections.gunmods:Toggle({
            Name = 'wallbang';
            Flag = 'wallbang';
            Default = false;
            Callback = function(v)
                WallbangEnabled = v;
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
    --local ThirdPerson = false;
    --local oldmin = LocalPlayer.CameraMinZoomDistance
    --local oldmax = LocalPlayer.CameraMaxZoomDistance

    --#region calm luh logic brader

        RunService.RenderStepped:Connect(function()
            if FullbrightEnabled then
                Lighting.Brightness = 3
                Lighting.ClockTime = 18.5
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

        --[[Sections.visuals:Toggle({
            Name = 'third person';
            Flag = 'ThirdPerson';
            Default = false;
            Callback = function(v)
                ThirdPerson = v;
            end
        })]]

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



local DeviceSpoofEnabled = false;
local Device = "Mobile"


--[[

Players.GetPlayerFromCharacter(Players, t.FinalPart.Parent)
Players:GetPlayerFromCharacter(t.FinalPart.Parent),
200,
"M4A1",
{
    Normal = Vector3.new(0/0, 0/0, 0/0),
    Direction = (t.FinalPart.Position - Origin).Unit,
    StartPosition = Origin,
    Instance = t.FinalPart,
    Material = t.FinalPart.Material,
    EndPosition = t.FinalPart.Position 
}


]]
--#region namecall stuff
    local mtHook; mtHook = hookmetamethod(game, "__namecall", LPH_JIT_MAX(function(self, ...)
        local method = getnamecallmethod()

        if WallbangEnabled and rawequal(self, Remotes.KillEvent) and method == "FireServer" then
            local t = cachedtarget or GetTarget()
            
            if t then
                return mtHook(self,
                    Players.GetPlayerFromCharacter(Players, t.Parent),
                    200,
                    "M4A1",
                    {
                        Normal = Vector3.new(0/0, 0/0, 0/0),
                        Direction = Vector3.new(0/0, 0/0, 0/0),
                        StartPosition = Vector3.new(0/0, 0/0, 0/0),
                        Instance = t,
                        Material = t.Material,
                        EndPosition = t.Position
                    }
                )
            end
        end

        if DeviceSpoofEnabled and rawequal(self, Remotes.DeviceUpdate) and method == "FireServer" then
            return Device
        end

        return mtHook(self, ...)
    end))

--#endregion



do -- misc
    Remotes.DeviceUpdate:FireServer(Device);
    
    local HitsoundEnabled = false
    local SelectedHitsound = "Neverlose"
    local HitsoundVolume = 1

    local SpeedhackEnabled = false;
    local SpeedhackSpeed = 2;

    local NoclipEnabled = true

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

        local soundkeys = {}
        
        for i in sounds do 
            table.insert(soundkeys, i) 
        end

        table.sort(soundkeys)

        local hitsoundobj = Instance.new("Sound")
        hitsoundobj.Parent = workspace
        hitsoundobj.Volume = HitsoundVolume

        local old; old = hookfunction(Modules.Config.AddSound, function(name, ...)
            if name == "HitMarker" and HitsoundEnabled then
                hitsoundobj.SoundId = sounds[SelectedHitsound]
                hitsoundobj.Volume = HitsoundVolume
                hitsoundobj:Play()
            end

            return old(name, ...)
        end)
    --#endregion





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



    --#region noclip
    
        LocalPlayer.CharacterAdded:Connect(function()
            if not NoclipEnabled then 
                return 
            end
            
            RunService.Stepped:Wait()
        end)

        RunService.Stepped:Connect(function()
            if not LocalPlayer.Character or not NoclipEnabled then
                return 
            end

            for i, v in LocalPlayer.Character:GetDescendants() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)

    --#endregion


    
    --#region hit toggles

    Sections.hit:Toggle({
        Name = 'hitsound';
        Flag = 'hitsound';
        Default = false;
        Callback = function(v)
            HitsoundEnabled = v;
        end
    })

    Sections.hit:Dropdown({
        Name = 'hitsound';
        Flag = 'hitsoundselect';
        Items = soundkeys;
        Default = 'Neverlose';
        Callback = function(v)
            SelectedHitsound = v;
        end
    })

    Sections.hit:Slider({
        Name = 'hitsound volume';
        Flag = 'hitsoundvol';
        Min = 0;
        Max = 3;
        Default = 1;
        Decimals = 0.1;
        Callback = function(v)
            HitsoundVolume = v;
        end
    })
    --#endregion



    --#region exploits toggles

        Sections.exploits:Toggle({
            Name = 'device spoofer';
            Flag = 'devicespoof';
            Default = false;
            Callback = function(v)
                DeviceSpoofEnabled = v;
                Remotes.DeviceUpdate:FireServer(Device);
            end
        })

        Sections.exploits:Dropdown({
            Name = 'device';
            Items = {"Mobile"; "Computer"; "Console"};
            Default = "Computer";
            Callback = function(v)
                Device = v;
                Remotes.DeviceUpdate:FireServer(v)
            end;
        })

    --#endregion



    --#region movement toggles

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
            Default = 2;
            Min = 1;
            Max = 5;
            Decimals = 1;
            Callback = function(v)
                SpeedhackSpeed = v;
            end;
        })

        Sections.movement:Toggle({
            Name = 'no clip';
            Flag = 'noclip';
            Default = false;
            Callback = function(v)
                NoclipEnabled = v;
            end 
        })

    --#endregion
end 



Window:InitWindow()
