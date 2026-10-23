--bloxstrike


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
        bullet = require(game:GetService("ReplicatedStorage").Components.Weapon.Classes.Bullet);
        CameraController = require(ReplicatedStorage.Controllers.CameraController);
        InventoryController = require(ReplicatedStorage.Controllers.InventoryController);
        RuntimeKinematics = require(ReplicatedStorage.MovementV2.RuntimeKinematics);
        PlayerModule = require(LocalPlayer.PlayerScripts.PlayerModule);
        CharacterController = require(ReplicatedStorage.Controllers.CharacterController);
        FlashEffect = require(ReplicatedStorage.Components.Common.VFXLibary.FlashEffect);
        Remotes = require(ReplicatedStorage.Database.Security.Remotes);
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

    local ThirdPerson = false;
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
    
    local EspLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/EspLibBloxstrike.lua'))()

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
        cosmetics = Pages.MiscPage:Section({
            Name = 'cosmetics';
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
    local NoRecoilEnabled = false;
    local Manips = 5;
    local ManipStep = 0.25;
    local RagebotEnabled = false;
    local RagebotTarget = nil;
    local AutoReloadEnabled = false;
    local FastReload = false;
    local ForceFullAuto = false;

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
        --Modules.bullet

            local FovCircle = Drawing.new("Circle")

            FovCircle.Radius = 100
            FovCircle.Color = Color3.fromRGB(255, 255, 255)
            FovCircle.Visible = false

            RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
                if FovCircleEnabled then 
                    FovCircle.Position = UserInputService:GetMouseLocation()
                end
            end))
        
        --#region maanip
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

            local Characters = workspace:FindFirstChild("Characters")

            function GetTarget()
                local MouseLocation = UserInputService:GetMouseLocation()
                local FinalPart, Distance = nil, math.huge

                    for _, plr in Characters:GetChildren() do
                        local name = plr.Name
                        if plr.ClassName ~= "Model" then 
                            continue 
                        end
                        if name == LocalPlayer.Name then 
                            continue 
                        end;
                    

                        local CharTeam = plr:GetAttribute("Team")
                        if CharTeam == nil then
                            local Plr = Players:FindFirstChild(name)
                            if Plr then
                                CharTeam = Plr:GetAttribute("Team")
                            end
                        end

                        if CharTeam ~= nil and CharTeam == LocalPlayer:GetAttribute("Team") then
                            continue
                        end
                        


                        local Data = plr

                        if not Data then 
                            continue 
                        end;

                        local AimPart = Data:FindFirstChild("Head")
                        if not AimPart then
                            continue
                        end;
                        
                        if Data:GetAttribute("Dead") then
                            continue
                        end

                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(AimPart.Position)
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

                        if Distance < Dist then
                            continue
                        end;
                        Distance = Dist
                        FinalPart = AimPart
                    end;
                return FinalPart
            end;

            function GetVisibleTarget()
                local FinalPart, Distance = nil, math.huge
                local Char = LocalPlayer.Character 

                if Char then 
                    local Head = Char:FindFirstChild("Head")

                    if Head then 
                        local origin;

                        if ThirdPerson then 
                            origin = Head.CFrame.Position
                        else 
                            origin = Camera.CFrame.Position
                        end 
                        

                        for _, plr in Characters:GetChildren() do
                            local name = plr.Name
                            if plr.ClassName ~= "Model" then 
                                continue 
                            end
                            if name == LocalPlayer.Name then 
                                continue 
                            end

                            local CharTeam = plr:GetAttribute("Team")
                            if CharTeam == nil then
                                local Plr = Players:FindFirstChild(name)
                                if Plr then
                                    CharTeam = Plr:GetAttribute("Team")
                                end
                            end

                            if CharTeam ~= nil and CharTeam == LocalPlayer:GetAttribute("Team") then
                                continue
                            end

                            local AimPart = plr:FindFirstChild("Head")
                            
                            if not AimPart then 
                                continue 
                            end

                            if plr:GetAttribute("Dead") then 
                                continue 
                            end




                            local dist = (AimPart.Position - origin).Magnitude
                            local dir = (AimPart.Position - origin).Unit
                            
                            local result = workspace:Raycast(origin, dir * dist, autofireparams)

                            if result and result.Instance and result.Instance:IsDescendantOf(plr) then
                                local offset = ManipEnabled and findminoffset(AimPart, origin) or nil 

                                if dist < Distance then
                                    return {
                                        FinalPart = AimPart,
                                        Offset = offset
                                    }
                                    --Distance = dist
                                    --FinalPart = AimPart
                                end
                            elseif ManipEnabled then 
                                local offset = ManipEnabled and findminoffset(AimPart, origin) or nil 

                                if offset and dist < Distance then
                                    return {
                                        FinalPart = AimPart,
                                        Offset = offset
                                    }
                                    --Distance = dist
                                    --FinalPart = AimPart
                                end
                            end 
                        end
                    end 
                end 

                return nil 
            end

        --#endregion



        local Bullet = Modules.bullet.create

        if isfunctionhooked(Bullet) then 
            restorefunction(Bullet)
        end 

        local old; old = hookfunction(Bullet, function(...) 
            local new = old(...)
            local t

            if RagebotEnabled and RagebotTarget then
                t = RagebotTarget
            elseif SilentEnabled then
                t = GetTarget()
            end

            if t and (SilentEnabled and not RagebotTarget) then
                if not new.Hits then 
                    new.Hits = {} 
                end
                if not new.Hits[1] then 
                    new.Hits[1] = {} 
                end

                if ManipEnabled then
                    local offset = findminoffset(t, new.Origin)
                    if offset then
                        new.Origin = new.Origin + offset
                    end
                end

                new.Direction = (t.Position - new.Origin).Unit 
                new.Hits[1].Instance = t 
                new.Hits[1].Position = t.Position
            elseif RagebotEnabled and RagebotTarget then 
                if not new.Hits then 
                    new.Hits = {} 
                end
                if not new.Hits[1] then 
                    new.Hits[1] = {} 
                end

                if ManipEnabled then
                    local offset = RagebotTarget.Offset or findminoffset(RagebotTarget.FinalPart, new.Origin)
                    if offset then
                        new.Origin = new.Origin + offset
                    end
                end

                new.Direction = (RagebotTarget.FinalPart.Position - new.Origin).Unit 
                new.Hits[1].Instance = RagebotTarget.FinalPart
                new.Hits[1].Position = RagebotTarget.FinalPart.Position

                RagebotTarget = nil 
            end 

            if TracerEnabled and new.Origin and new.Direction then 
                CreateTracer(new.Origin, new.Direction)
            end 

            return new
        end)

    --#endregion
    
    
    
    --#region ragebot

        task.spawn(function()
            while true do 
                if not RagebotEnabled then
                    RagebotTarget = nil
                else 
                    local t = GetVisibleTarget()

                    if t and t.FinalPart then
                        RagebotTarget = t

                        local weapon = Modules.InventoryController.peekCurrentEquippedForMovement()
                        if weapon and weapon.shoot then 
                            setthreadidentity(2)
                            weapon:shoot()
                        end
                    end
                end 

                task.wait(0)
            end 
        end)

    --#endregion



    --#region gun mods

        local RecoilSpring = getupvalues(Modules.CameraController.setWeaponRecoil)[1]
        local KickSpring = getupvalues(Modules.CameraController.weaponKick)[1]

        local old; old = hookfunction(Modules.CameraController.setWeaponRecoil, newcclosure(function(...) 
            if not NoRecoilEnabled then
                return old(...)
            end
        end))

        local old; old = hookfunction(Modules.CameraController.weaponKick, newcclosure(function(...)
            if not NoRecoilEnabled then
                return old(...)
            end
        end))

        local old; old = hookfunction(Modules.bullet._performRaycast, newcclosure(function(weapon, spread)
            if NoSpreadEnabled then
                return old(weapon, 0)
            end

            return old(weapon, spread)
        end))

        task.spawn(function()
            local weapon = Modules.InventoryController.getCurrentEquipped()

            repeat task.wait() weapon = Modules.InventoryController.getCurrentEquipped() until (weapon and weapon.reload)

            local old; old = hookfunction(weapon.reload, function(self)
                if FastReload and self and self.Properties then
                    local isDM = workspace:GetAttribute("Gamemode") == "Deathmatch"
                    local infinite = isDM and self.Properties.ReloadAnimationCount == 1
                    local ammoNeeded = (self.Properties.Rounds or 0) - (self.Rounds or 0)
                    local hasCapacity = infinite or (self.Capacity or 0) > 0

                    if ammoNeeded > 0 and hasCapacity then
                        Modules.Remotes.Inventory.CreateMagazine.Send(self.Identifier)
                        Modules.Remotes.Inventory.ReloadWeapon.Send({
                            Identifier = self.Identifier,
                            Rounds = self.Rounds,
                            Capacity = self.Capacity
                        })
                        local added = infinite and ammoNeeded or math.min(self.Capacity, ammoNeeded)
                        self.Rounds = self.Rounds + added
                        if not infinite then
                            self.Capacity = math.max(0, self.Capacity - added)
                        end
                        return
                    end
                end

                return old(self)
            end)
        end)

        task.spawn(function()
            while true do
                if AutoReloadEnabled then
                    local weapon = Modules.InventoryController.getCurrentEquipped()

                    if (weapon and weapon.Properties) and not (weapon.IsReloading or weapon.IsShooting) then
                        if weapon.Properties.Rounds and weapon.Rounds < weapon.Properties.Rounds then
                            setthreadidentity(2)
                            weapon:reload()
                        end
                    end 
                end 
                if ForceFullAuto then
                    local weapon = Modules.InventoryController.getCurrentEquipped()

                    if weapon and weapon.IsFireHeld and weapon.shoot then
                        weapon.IsShooting = false
                        setthreadidentity(2)
                        weapon:shoot()
                    end
                end

                task.wait(0)
            end 

        end)

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

        Sections.aimbot:Slider({
            Name = 'max manip dist';
            Flag = 'maxmanip';
            Default = Manips;
            Min = 0;
            Decimals = 0.01;
            Max = 20;
            Callback = function(v)
                Manips = v;
            end 
        })

        Sections.aimbot:Toggle({
            Name = 'ragebot';
            Flag = 'ragebot';
            Default = false;
            Callback = function(v)
                RagebotEnabled = v
                if not v then
                    RagebotTarget = nil
                end
            end
        })

        Sections.gunmods:Toggle({
            Name = 'no recoil';
            Flag = 'norecoil';
            Default = false;
            Callback = function(v)
                NoRecoilEnabled = v
                if v then
                    RecoilSpring:reset(Vector3.zero)
                    KickSpring:reset(Vector3.zero)
                end
            end
        })

        Sections.gunmods:Toggle({
            Name = 'no spread';
            Flag = 'nospread';
            Default = false;
            Callback = function(v)
                NoSpreadEnabled = v
            end
        })

        Sections.gunmods:Toggle({
            Name = 'force full auto';
            Flag = 'ffa';
            Default = false;
            Callback = function(v)
                ForceFullAuto = v;
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
            Name = 'fast reload';
            Flag = 'fastreload';
            Default = false;
            Callback = function(v)
                FastReload = v
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

    Sections.Esp:Slider({
        Name = 'max distance';
        Flag = 'espmaxdistance';
        Min = 200;
        Max = 2000;
        Default = 500;
        Decimals = 1;
        Callback = function(v)
            EspLib['Table']['Distance'] = v
        end
    })
end



do -- misc
    local BhopEnabled = false
    local wasOnGround = false
    local NoFlashEffects = false 
    local HitsoundEnabled = false
    local HitsoundVolume = 0.5


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
        
        local HitsoundSelected = soundkeys[1]

        local hitsoundobj = Instance.new("Sound")
        hitsoundobj.Parent = workspace
        hitsoundobj.Volume = HitsoundVolume
        hitsoundobj.SoundId = sounds[HitsoundSelected]

        local headshotIds = {}
        for _, v in game:GetService("ReplicatedStorage").Sounds:GetDescendants() do
            if v:IsA("Sound") and (v.Parent.Name == "Headshot" or v.Parent.Name == "Helmet Headshot") then
                headshotIds[v.SoundId] = true
            end
        end

        local namecall; namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if method == "Play" and self.ClassName == "Sound" and headshotIds[self.SoundId] then
                if HitsoundEnabled then
                    task.spawn(function()
                        hitsoundobj:Stop()
                        hitsoundobj:Play()
                    end)
                    return
                end
            end

            return namecall(self, ...)
        end))

    --#endregion

    --#region bhop n no flash

        RunService.Heartbeat:Connect(function()
            if not BhopEnabled then
                wasOnGround = false
                return
            end

            local char = LocalPlayer.Character
            if not char then
                wasOnGround = false
                return
            end

            local onGround = Modules.RuntimeKinematics.isOnGround(char)

            if onGround and not wasOnGround then
                local controller = Modules.PlayerModule:GetControls().activeController
                if controller and controller.moveVector.Magnitude > 0.1 then
                    Modules.CharacterController.jump()
                end
            end

            wasOnGround = onGround
        end)

        local Flash = Modules.FlashEffect.Flash

        if isfunctionhooked(Flash) then 
            restorefunction(Flash)
        end 

        local old; old = hookfunction(Flash, function(...) 
            if NoFlashEffects then 
                return false 
            end 

            return old(...)
        end)

    --#endregion



    --#region skin changer

        local SkinEnabled = false
        local SelectedSkin = "Default"
        local HookedWeapon = nil
        local LastViewmodel = nil
        local SkinDropdown = nil

        local WearLevels = {
            "Factory New";
            "Minimal Wear";
            "Field-Tested";
            "Well-Worn";
            "Battle-Scarred";
        }

        local GetWearing = function(base)
            if base:FindFirstChildOfClass("SurfaceAppearance") then
                return base
            end
            for _, v in WearLevels do
                local f = base:FindFirstChild(v)

                if f then
                    return f
                end
            end
            return base:FindFirstChildOfClass("Folder")
        end

        local ApplySkin = function()
            local cam = workspace.CurrentCamera
            local viewmodel = nil

            for i, v in cam:GetChildren() do
                if v:IsA("Model") then
                    viewmodel = v
                    break
                end
            end

            if viewmodel then
                local WeaponName = viewmodel.Name
                local SkinsFolder = ReplicatedStorage.Assets:FindFirstChild("Skins")

                if SkinsFolder then
                    local WeaponSkins = SkinsFolder:FindFirstChild(WeaponName)

                    if WeaponSkins and SelectedSkin then
                        local TheSkin = WeaponSkins:FindFirstChild(SelectedSkin)

                        if TheSkin then
                            local cameraFolder = TheSkin:FindFirstChild("Camera") or TheSkin
                            local WearFolder = GetWearing(cameraFolder)

                            if WearFolder then
                                local WeaponModel = viewmodel:FindFirstChild("Weapon")

                                if WeaponModel then
                                    for _, sa in WearFolder:GetChildren() do
                                        if sa:IsA("SurfaceAppearance") then
                                            for _, part in WeaponModel:GetDescendants() do
                                                if part:IsA("MeshPart") and part.Name == sa.Name then
                                                    local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                                                    if existing then
                                                        existing:Destroy()
                                                    end

                                                    sa:Clone().Parent = part
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        RunService.Heartbeat:Connect(function()
            local Weapon = Modules.InventoryController.getCurrentEquipped()

            if Weapon and Weapon.Properties and Weapon ~= HookedWeapon then
                HookedWeapon = Weapon

                local WeaponName = Weapon.Name
                local SkinsFolder = ReplicatedStorage.Assets:FindFirstChild("Skins")
                local WeaponFolder = SkinsFolder and SkinsFolder:FindFirstChild(WeaponName)

                local SkinList = {}
                if WeaponFolder then
                    for _, v in WeaponFolder:GetChildren() do
                        if v:IsA("Folder") then
                            table.insert(SkinList, v.Name)
                        end
                    end
                    table.sort(SkinList)
                end

                if #SkinList == 0 then
                    SkinList = {"Default"}
                end

                if SkinDropdown then
                    SkinDropdown:Refresh(SkinList)
                    SelectedSkin = SkinList[1]
                    SkinDropdown.Value = SkinList[1]
                    SkinDropdown.Items["Value"].Instance.Text = SkinList[1]
                    local FirstOpt = SkinDropdown.Options[SkinList[1]]
                    if FirstOpt then
                        FirstOpt.IsSelected = true
                        FirstOpt:ToggleState("Active")
                    end
                end

                if SkinEnabled then
                    local Props = Weapon.Properties
                    setreadonly(Props, false)
                    rawset(Props, "Skin", nil)
                    rawset(Props, "SkinId", nil)

                    local ExistMt = getrawmetatable(Props)

                    if ExistMt then
                        setreadonly(ExistMt, false)
                        ExistMt.__index = function(t, k)
                            if k == "Skin" or k == "SkinId" then
                                return SelectedSkin
                            end
                            return rawget(t, k)
                        end
                        setreadonly(ExistMt, true)
                    else
                        setmetatable(Props, {
                            __index = function(t, k)
                                if k == "Skin" or k == "SkinId" then
                                    return SelectedSkin
                                end
                                return rawget(t, k)
                            end
                        })
                    end

                    setreadonly(Props, true)
                end
            end

            if SkinEnabled then
                local cam = workspace.CurrentCamera
                local viewmodel = nil

                for _, child in cam:GetChildren() do
                    if child:IsA("Model") then
                        viewmodel = child
                        break
                    end
                end

                if viewmodel ~= LastViewmodel then
                    LastViewmodel = viewmodel
                    if viewmodel then
                        ApplySkin()
                    end
                end
            end
        end)

    --#endregion



    --#region toggles

        Sections.movement:Toggle({
            Name = 'bhop';
            Flag = 'bhop';
            Default = false;
            Callback = function(v)
                BhopEnabled = v
            end
        })

        Sections.miscexploits:Toggle({
            Name = 'no flash bang effects';
            Flag = 'noflashb';
            Default = false;
            Callback = function(v)
                NoFlashEffects = v;

                if v then 
                    if Modules.FlashEffect.IsFlashed() then
                        Modules.FlashEffect.CancelFlash()
                    end
                end 
            end 
        })

        Sections.hit:Toggle({
            Name = 'hitsound';
            Flag = 'hitsounds';
            Default = false;
            Callback = function(v)
                HitsoundEnabled = v
            end
        })

        Sections.hit:Dropdown({
            Name = 'hitsound';
            Items = soundkeys;
            Default = soundkeys[1];
            Callback = function(v)
                HitsoundSelected = v
                hitsoundobj.SoundId = sounds[v]
            end
        })

        Sections.hit:Slider({
            Name = 'volume';
            Flag = 'hitsoundvolume';
            Default = 50;
            Min = 0;
            Max = 100;
            Decimals = 1;
            Callback = function(v)
                HitsoundVolume = v / 100
                hitsoundobj.Volume = HitsoundVolume
            end
        })

        Sections.cosmetics:Toggle({
            Name = 'skin changer';
            Flag = 'skinchanger';
            Default = false;
            Callback = function(v)
                SkinEnabled = v
                HookedWeapon = nil
                LastViewmodel = nil
                if v then
                    ApplySkin()
                end
            end
        })

        SkinDropdown = Sections.cosmetics:Dropdown({
            Name = 'skin';
            Items = {};
            Default = "";
            Callback = function(v)
                SelectedSkin = v
                LastViewmodel = nil
                if SkinEnabled then
                    ApplySkin()
                end
            end
        })
    --#endregion
end 

Window:InitWindow()
