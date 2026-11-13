-- TTK TESTING



--#region anti cheat bypass

    local send = filtergc("function", {Name = "send"}, true)

    if isfunctionhooked(send) then  
        restorefunction(send) 
    end  

    local old; old= hookfunction(send, function(dtc, reason, ...) -- cmon, man. 
        --print(dtc, reason, ...) 
        return 
    end) 

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
    local Entities = workspace.MercPlayers
    
    local Modules = { -- Modules.
        SpreadUtil = require(ReplicatedStorage.Modules.Shared.SpreadUtil);
        BulletController = require(ReplicatedStorage.Modules.Client.Controllers.BulletController);
        AimStream = require(ReplicatedStorage.Modules.Shared.Character.AimStream);
        CameraController = require(ReplicatedStorage.Modules.Client.Controllers.CameraController);
    };

    local Remotes = { -- Remotes.

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
        --killaura = Pages.CombatPage:Section({
        --    Name = 'killaura';
        --    Side = 2;
        --});
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
        --target = Pages.MiscPage:Section({
        --    Name = 'target';
        --    Side = 2;
        --});
        --worldesp = Pages.VisualsPage:Section({
        --    Name = 'world esp';
        --    Side = 2;
        --});
        visuals = Pages.VisualsPage:Section({
            Name = 'others';
            Side = 2;
        });
        --world = Pages.VisualsPage:Section({
        --    Name = 'world';
        --    Side = 2;
        --});
        --vmisc = Pages.VisualsPage:Section({
        --    Name = "misc";
        --    Side = 2;
        --});
        Esp = Pages.VisualsPage:Section({
            Name = 'esp';
            Side = 1;
        });
        chams = Pages.VisualsPage:Section({
            Name = "chams";
            Side = 1;
        });
        --AudioP = Pages.MiscPage:Section({
        --    Name = "spotify player";
        --    Side = 2;
        --});

    };

--#endregion



do 

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
        local ForceHit = false;
        local NoWallAvoidance = false;
        local AntiAimEnabled = false;
        local Pitch = "Up"
        local PitchEnabled = false 
        local LeanAnglesEnabled = false;
        local LeanAngle = "Left"

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

            local fovconnection = RunService.Heartbeat:Connect(function()
                if FovCircleEnabled then 
                    FovCircle.Position = UserInputService:GetMouseLocation()
                end
            end)

            function GetTarget()
                local MouseLocation = UserInputService.GetMouseLocation(UserInputService)
                local FinalPart, Distance = nil, math.huge
                
                    for _, v in Entities:GetChildren() do
                        local uid = v:GetAttribute("OwnerUserId")
                        
                        if not uid or uid == LocalPlayer.UserId then 
                            continue 
                        end

                        local plr = Players:GetPlayerByUserId(uid)
                        
                        if MyTeam and plr and plr.Team == MyTeam then 
                            continue 
                        end
                        
                        local AimPart = v:FindFirstChild("Head")
                        
                        if not AimPart then 
                            continue 
                        end
                        
                        local Humanoid = v:FindFirstChild("Humanoid")
                        
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
            
                    end 

                    --[[for _, plr in Players.GetPlayers(Players) do
                        if plr == LocalPlayer then 
                            continue 
                        end;
                        if LocalPlayer.Team ~= nil then 
                            if plr.Team == LocalPlayer.Team then
                                continue 
                            end
                        end 

                        local Data = Entities:FindFirstChild("MercHitboxes_"..tostring(plr)) or plr.Character

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
                    end;]]
                return FinalPart
            end;



        --#endregion



        --#region silent aim logic
            local Target = nil 

            local fireHitscan = filtergc("function", {Name = "fireHitscan"}, true)

            local traceShot = filtergc("function", {Name = "traceShot"}, true)
            if isfunctionhooked(fireHitscan) then 
                restorefunction(fireHitscan)
            end 

            local old; old = hookfunction(fireHitscan, function(origin, dir, p149, p150, ...) 
                if Target and ForceHit then 
                    new = {
                        Instance = Target,
                        Position = Target.Position, 
                        Normal = Vector3.new(0/0, 0/0, 0/0) 
                    }   
                    Target = nil 
                    return new
                else 
                    return old(origin, dir, p149, p150, ...)
                end  
            end)
            
            local Dischange = Modules.BulletController.Discharge
            if isfunctionhooked(Dischange) then 
                restorefunction(Dischange)
            end 

            local old; old = hookfunction(Dischange, function(self, name, origin, direction, muzzleCF, ...)
                if SilentAimEnabled then
                    local t = GetTarget()
                
                    if t then
                        if ManipEnabled then
                            local offset = findminoffset(t, origin)

                            if offset then 
                                origin = origin + offset 
                            end
                        end
                        direction = (t.Position - origin).Unit
                        Target = t
                    end
                end
                
                if TracerEnabled then 
                    CreateTracer(origin, direction) 
                end

                return old(self, name, origin, direction, muzzleCF, ...)
            end)

            --[[if isfunctionhooked(traceShot) then 
                restorefunction(traceShot)
            end 

            local old; old = hookfunction(traceShot, function(origin, dir, ...) 
                local t = GetTarget()

                if t and SilentAimEnabled then 
                    if ManipEnabled then 
                        local offset = findminoffset(t, origin)

                        if offset then 
                            origin = origin + offset
                        end 
                    end 
                    Target = t 
                    dir = (t.Position - origin).Unit 
                end 

                if TracerEnabled then 
                    CreateTracer(origin, dir)
                end 

                return old(origin, dir, ...)
            end)]]

        --#endregion

        

        --#region ragebot



        --#endregion



        --#region anti aim

            local Publish = Modules.AimStream.Publish

            if isfunctionhooked(Publish) then 
                restorefunction(Publish)
            end 

            local old; old = hookfunction(Publish, function(pitch, yaw, lean) 
                if AntiAimEnabled then 
                    if PitchEnabled then 
                        if Pitch == "Up" then 
                            pitch = math.huge 
                        elseif Pitch == "Down" then 
                            pitch = -math.huge
                        end 
                    end 
                    if LeanAnglesEnabled then 
                        if LeanAngle == "Left" then 
                            lean = math.huge
                        elseif LeanAngle == "Right" then 
                            lean = -math.huge 
                        end 
                    end 
                end 
                return old(pitch, yaw, lean)
            end)

        --#endregion



        --#region gun mods

            local RandomConeDirection = Modules.SpreadUtil.RandomConeDirection
            local cameraKick = filtergc("function", {Name = "cameraKick"}, true)
            local _UpdateWallAvoidance = filtergc("function", {Name = "_UpdateWallAvoidance"}, true)
            
            if isfunctionhooked(cameraKick) then 
                restorefunction(cameraKick)
            end 


            local old; old = hookfunction(cameraKick, function(...) 
                if not NoRecoilEnabled then 
                    return old(...)
                end 

                return 
            end)
            
            local RecoilFunctions = {
                RecoilRock = Modules.CameraController.RecoilRock;
                BoomKick = Modules.CameraController.BoomKick;
                ShakeImpulse = Modules.CameraController.ShakeImpulse;
            }

            for i, v in next, RecoilFunctions do 
                if isfunctionhooked(v) then 
                    restorefunction(v)
                end 

                local old; old = hookfunction(v, function(...)
                    if NoRecoilEnabled then 
                        return 
                    end  
                    return old(...)
                end)
            end 

            
            
            --[[
            local RecoilTbl = Modules.Weapons.Recoil 
            local OriginalRecoils = {}

            for i, v in RecoilTbl do 
                OriginalRecoils[i] = v 
            end 

            table.clear(RecoilTbl)

            setmetatable(RecoilTbl, {
                __index = function(tbl, key)
                    if key == "CamRoll" or key == "CamJolt" then 
                        rawset(tbl, key, 0)
                        return 0
                    else 
                        rawset(tbl, key, OriginalRecoils[key])
                        return OriginalRecoils[key] 
                    end 
                end,
                __newindex = function(tbl, key, value)
                    if key == "CamRoll" or key == "CamJolt" then 
                        rawset(tbl, key, 0)
                        return 0
                    else 
                        rawset(tbl, key, OriginalRecoils[key])
                        return OriginalRecoils[key] 
                    end 
                end 
            })]] 

            if isfunctionhooked(RandomConeDirection) then 
                restorefunction(RandomConeDirection)
            end 

            local old; old = hookfunction(RandomConeDirection, function(dir, spread, ...) 
                local tb = debug.traceback()

                if tb:find('GunController') and NoSpread then 
                    return dir 
                end 
                return old(dir, spread, ...)
            end)

            if isfunctionhooked(_UpdateWallAvoidance) then 
                restorefunction(_UpdateWallAvoidance)
            end 

            local old; old = hookfunction(_UpdateWallAvoidance, function(p68, ...) 
                if NoWallAvoidance then 
                    return 
                end 

                return old(p68, ...)
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
            
            Sections.aimbot:Toggle({
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
                Name = 'no wall avoidance';
                Flag = 'nowallavoid';
                Default = false;
                Callback = function(v)
                    NoWallAvoidance = v;
                end 
            })

            Sections.gunmods:Toggle({
                Name = 'force hit';
                Flag = 'forcehit';
                Default = ForceHit;
                Callback = function(v)
                    ForceHit = v;
                end 
            })
            
            Sections.antiaim:Toggle({
                Name = 'anti aim';
                Flag = 'antiaim';
                Default = false;
                Callback = function(v)
                    AntiAimEnabled = v;
                end 
            })

            Sections.antiaim:Toggle({
                Name = 'pitch enabled';
                Flag = 'pitchaa';
                Default = false;
                Callback = function(v)
                    PitchEnabled = v;
                end 
            })

            Sections.antiaim:Dropdown({
                Name = 'pitch';
                Flag = 'pitch';
                Default = "None";
                Items = {"Up", "Down", "None"};
                Callback = function(v)
                    Pitch = v;
                end 
            })
            
            Sections.antiaim:Toggle({
                Name = 'lean angles enabled';
                Flag = 'leanaa';
                Default = false;
                Callback = function(v)
                    LeanAnglesEnabled = v; 
                end 
            })

            Sections.antiaim:Dropdown({
                Name = 'lean';
                Flag = 'lean';
                Default = "None";
                Items = {"Left", "Right", "None"};
                Callback = function(v)
                    LeanAngle = v; 
                end 
            })

        --#endregion
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

        local NoclipEnabled = true




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



        --#region toggles

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
                Max = 40;
                Decimals = 1;
                Callback = function(v)
                    SpeedhackSpeed = v;
                end;
            })
        --#endregion
    end 

end 

Window:InitWindow()
