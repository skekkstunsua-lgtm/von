--cold war



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
    local GroupService = game:GetService("GroupService")
    local GuiService = game:GetService("GuiService")

    local Modules = { -- Modules.
        RecoilController = require(ReplicatedStorage.Client.Tools.Weapon.controllers.RecoilController);
        WallPush = require(ReplicatedStorage.Client.Tools.Weapon.controllers.WallPush);
        ClientFire = require(LocalPlayer.PlayerScripts.BallisticsClient.ClientFire);
        Trajectory = require(ReplicatedStorage.Shared.Ballistics.Trajectory);
        WeaponConfigManager = require(ReplicatedStorage.Shared.WeaponConfigManager);
        HitReporter = require(LocalPlayer.PlayerScripts.BallisticsClient:WaitForChild("HitReporter"));
    };

    local Remotes = {
        Weapon = ReplicatedStorage.Remotes.Weapon;
        MovementEvent = ReplicatedStorage.Remotes.StreamingHint;
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



--#region bypass (I just made some BULLSHITT)



    --#region streaming hint bypass bs

        local StreamingHintR = ReplicatedStorage.Remotes:WaitForChild("StreamingHint")
        local Original = nil 
        local StreamingHint = nil 

        local oldInspect; oldInspect = hookfunction(GuiService.InspectPlayerFromHumanoidDescription, newcclosure(function()
            return
        end))
        -- these guys love their animations to detect u man <3

        local applyLens = filtergc("function", {Name = "applyLens"}, true)

        if isfunctionhooked(applyLens) then 
            restorefunction(applyLens)
        end 

        local old; old = hookfunction(applyLens, function(...) 
            return 
        end)

        local settleFocus = filtergc("function", {Name = "settleFocus"}, true)


        local old; old = hookfunction(settleFocus, function()

        end)

        for i, v in getconnections(LocalPlayer.CharacterAdded) do 
            local Func = v.Function

            if Func then 
                for id, va in getupvalues(Func) do 
                    if type(va) == 'function' then 
                        for _, val in getupvalues(va) do 
                            if type(val) == 'function' then 
                                for i1, v1 in getupvalues(val) do 
                                    if v1 == "StreamingHint" then 
                                        StreamingHint = val;
                                        break
                                    end 
                                end 
                            end 
                        end 
                    end 
                end 
            end 
        end 

        for i, v in getupvalues(StreamingHint) do 
            if type(v) == 'function' and v ~= game.WaitForChild then 
                Original = v
            end 
        end 

        local AcHook = newcclosure(function(self, key, ...)
            if self == StreamingHintR and (key == "f" or key == "s" or key == "c" or key == "a" or key == "b" or key == "g") then
                return
            end
            return Original(self, key, ...)
        end)

        for i, v in filtergc("function", {}) do 
            local upvs = getupvalues(v)
            local HasHintThing = false 
            local blahblehbleh = nil 

            for id, va in upvs do 
                if va == "StreamingHint" then 
                    HasHintThing = true 
                end 

                if va == Original then 
                    blahblehbleh = id
                end 
            end 

            if HasHintThing and blahblehbleh then 
                setupvalue(v, blahblehbleh, AcHook)
            end 
        end

    --#endregion

--#endregion



--#region library setup
    --local amity = loadstring(game:HttpGet('https://raw.githubusercontent.com/78n/Roblox/refs/heads/main/Lua/Libraries/DataToCode/DataToCode.luau'))()

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
    local ManipEnabled = false;
    local NoRecoilEnabled = false;
    local NoWallPushEnabled = false; 
    local NoSwayEnabled = false;
    local Manips = 5;
    local ManipStep = 0.25;
    local RagebotEnabled = false;
    local AutoReloadEnabled = false;
    local ForceHitEnabled = false;
    local AntiAimEnabled = false;
    local AntiAimPitch = "Down";
    local YawAimEnabled = false;
    local IsShooting = false;
    local Jitter = false;
    local YawMode = "Backwards";
    local spinAngle = 0;
    local InstantBulletEnabled = false;



    local autofireparams = RaycastParams.new()


    autofireparams.FilterType = Enum.RaycastFilterType.Blacklist

    autofireparams.FilterDescendantsInstances = {LocalPlayer.Character}

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



    --#region anti aim 

        local sendOwnInfo = filtergc("function", {Name = "sendOwnInfo"}, true)
        local sendOwnInfoOriginal = nil

        if isfunctionhooked(sendOwnInfo) then 
            restorefunction(sendOwnInfo)
        end 

        local old; old = hookfunction(sendOwnInfo, function(...) 
            local upvs = getupvalues(old)
            local info = upvs[1]

            if AntiAimEnabled and not IsShooting and info and type(info) == 'table' then 
                if AntiAimPitch == "Down" then
                    info.NewCameraAngle = -math.pi / 2
                    info.CurrentCameraAngle = -math.pi / 2
                elseif AntiAimPitch == "Up" then
                    info.NewCameraAngle = math.pi / 2
                    info.CurrentCameraAngle = math.pi / 2
                elseif AntiAimPitch == "Inhead" then
                    info.NewCameraAngle = 0/0
                    info.CurrentCameraAngle = 0/0
                elseif AntiAimPitch == "Jitter" then
                    Jitter = not Jitter
                    local angle = Jitter and math.pi / 2 or -math.pi / 2
                    info.NewCameraAngle = angle
                    info.CurrentCameraAngle = angle
                end
            end

            return old(...)
        end)

        sendOwnInfoOriginal = old 

        

        RunService.Heartbeat:Connect(function(dt)
            if YawAimEnabled and not IsShooting then 
                local char = LocalPlayer.Character 

                if char then 
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildWhichIsA("Humanoid")

                    if hrp and hum then 
                        hum.AutoRotate = false 

                        local _, CameraYaw, _ = Camera.CFrame:ToOrientation()

                        if YawMode == "Backwards" then
                            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, CameraYaw + math.pi, 0)
                        elseif YawMode == "Spin" then
                            spinAngle += math.pi * 6 * dt
                            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
                        elseif YawMode == "Sideways" then
                            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, CameraYaw + math.pi / 2, 0)
                        end
                    end 
                end 
            end 
        end)

    --#endregion



    --#region silent logic

        local GetMuzzlePos = function()
            local char = LocalPlayer.Character 

            if char then 
                local tool = char:FindFirstChildWhichIsA("Tool")

                if tool then 
                    for i, v in tool:GetDescendants() do 
                        if v:IsA("Attachment") and v.Name:match("^Muzzle") then 
                            return v.WorldPosition
                        end 
                    end 
                end 
            end 

            return Camera.CFrame.Position -- defaults to cam pos if it dont find muzzle
        end 

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

            --#region preds (vibecoded :( )

                local function GetBallisticProps(weaponOrTool, muzzleIndex, bulletIndex, options)
                    local profile = options and options.Profile

                    if not profile then
                        local weaponName

                        if typeof(weaponOrTool) == "Instance" then
                            weaponName = weaponOrTool.Name
                        elseif type(weaponOrTool) == "string" then
                            weaponName = weaponOrTool
                        end

                        if not weaponName then
                            return nil
                        end

                        local muzzle = Modules.WeaponConfigManager:GetMuzzleConfig(weaponName, muzzleIndex or 1)

                        local bullet = muzzle and muzzle.BulletSettings and muzzle.BulletSettings[bulletIndex or 1]

                        if not bullet then
                            return nil
                        end

                        profile = {
                            MuzzleSpeed = bullet.MuzzleVelocity or 0,
                            K = bullet.Drag or 1,
                        }
                    end

                    if type(profile.MuzzleSpeed) ~= "number" or profile.MuzzleSpeed <= 0 then
                        return nil
                    end

                    return {
                        MuzzleSpeed = math.max(profile.MuzzleSpeed, 0),
                        K = math.max(profile.K or 0, 0),
                        Gravity = profile.Gravity or workspace.Gravity,
                        Up = Vector3.new(0, 1, 0),
                    }
                end

                local function PredictDirection(origin: Vector3, targetPosition: Vector3, targetVelocity: Vector3, props, settings)
                    settings = settings or {};

                    local function IsFinite(value)
                        return type(value) == "number" and value == value and math.abs(value) < math.huge;
                    end;

                    local function IsValidVector(value)
                        return typeof(value) == "Vector3" and IsFinite(value.X) and IsFinite(value.Y) and IsFinite(value.Z);
                    end;

                    if not IsValidVector(origin) or not IsValidVector(targetPosition) or not IsValidVector(targetVelocity) or type(props) ~= "table" or not IsFinite(props.MuzzleSpeed) or props.MuzzleSpeed <= 1e-6 then
                        return nil;
                    end;

                    local gravity = props.Gravity;
                    local drag = props.K or 0;
                    local maxTime = props.MaxTime or 5;
                    local stateAge = settings.StateAge or 0;

                    if gravity == nil then
                        gravity = workspace.Gravity;
                    end;

                    if not IsFinite(gravity) or not IsFinite(drag) or not IsFinite(maxTime) or maxTime <= 0 or not IsFinite(stateAge) or stateAge < 0 then
                        return nil;
                    end;

                    local up = Vector3.new(0, 1, 0);
                    local startPosition = targetPosition + targetVelocity * stateAge;

                    if not IsValidVector(startPosition)
                        or (startPosition - origin).Magnitude <= 1e-6 then
                        return nil;
                    end;

                    local traj = Modules.Trajectory.new({
                        Origin = origin;
                        Direction = Vector3.new(0, 0, -1);
                        MuzzleSpeed = props.MuzzleSpeed;
                        K = drag;
                        Gravity = gravity;
                        Up = up;
                    });

                    local function Evaluate(time)
                        local futurePosition = startPosition + targetVelocity * time;
                        local requiredTravel = futurePosition - origin + up * (0.5 * gravity * time * time);

                        local distance = requiredTravel.Magnitude;
                        local forward = Modules.Trajectory.GetForwardDistance(traj, time);

                        if not IsFinite(distance) or not IsFinite(forward) then
                            return nil;
                        end;

                        return distance - forward, requiredTravel;
                    end;

                    local samples = 96;
                    local left = 0;
                    local right;

                    for i = 1, samples do
                        local time = maxTime * (i / samples) ^ 2;
                        local error = Evaluate(time);

                        if error == nil then
                            return nil;
                        end;

                        if error <= 0 then
                            right = time;
                            break;
                        end;

                        left = time;
                    end;

                    if not right then
                        return nil;
                    end;

                    for _ = 1, 28 do
                        local middle = (left + right) * 0.5;
                        local error = Evaluate(middle);

                        if error == nil then
                            return nil;
                        end;

                        if error > 0 then
                            left = middle;
                        else
                            right = middle;
                        end;
                    end;

                    local flightTime = (left + right) * 0.5;
                    local error, requiredTravel = Evaluate(flightTime);

                    if error == nil or math.abs(error) > 0.02 or requiredTravel.Magnitude <= 1e-6 then
                        return nil;
                    end;

                    return requiredTravel.Unit;
                end;

            --#endregion


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
                local Origin = Camera.CFrame.Position
                local BestHead = nil
                local BestDist = math.huge

                for _, Plr in Players:GetPlayers() do
                    if Plr == LocalPlayer or Plr.Team == LocalPlayer.Team then
                        continue
                    end

                    local Data = Plr.Character
                    if not Data then
                        continue
                    end

                    local Head = Data:FindFirstChild("Head")
                    if not Head or Head.Position.Y < -250 then
                        continue
                    end

                    local Hum = Data:FindFirstChild("Humanoid")
                    if not Hum or Hum.Health <= 0 then
                        continue
                    end

                    local Dist = (Head.Position - Origin).Magnitude
                    if Dist >= BestDist then
                        continue
                    end

                    visparams.FilterDescendantsInstances = {
                        LocalPlayer.Character,
                        Data
                    }

                    local Hit = workspace:Raycast(Origin, Head.Position - Origin, visparams)

                    if not Hit then
                        BestDist = Dist
                        BestHead = Head
                    end
                end

                if BestHead then
                    local Offset = nil

                    if ManipEnabled then
                        Offset = findminoffset(BestHead, Origin)
                    end

                    return {
                        FinalPart = BestHead,
                        offset = Offset
                    }
                end

                if not ManipEnabled then
                    return nil
                end

                BestDist = math.huge
                local BestOffset = nil

                for _, Plr in Players:GetPlayers() do
                    if Plr == LocalPlayer or Plr.Team == LocalPlayer.Team then
                        continue
                    end

                    local Data = Plr.Character
                    if not Data then
                        continue
                    end

                    local Head = Data:FindFirstChild("Head")
                    if not Head or Head.Position.Y < -250 then
                        continue
                    end

                    local Hum = Data:FindFirstChild("Humanoid")
                    if not Hum or Hum.Health <= 0 then
                        continue
                    end

                    local Dist = (Head.Position - Origin).Magnitude
                    if Dist >= BestDist then
                        continue
                    end

                    visparams.FilterDescendantsInstances = {
                        LocalPlayer.Character,
                        Data
                    }

                    local Offset = findminoffset(Head, Origin)

                    if Offset then
                        BestDist = Dist
                        BestHead = Head
                        BestOffset = Offset
                    end
                end

                if BestHead then
                    return {
                        FinalPart = BestHead,
                        offset = BestOffset
                    }
                end

                return nil
            end

        --#endregion


        local Shoot = Modules.ClientFire.sLnpiWe6Dt
        local SendClaim = Modules.HitReporter.sendClaim

        local RealShoot;

        if isfunctionhooked(SendClaim) then 
            restorefunction(SendClaim)
        end 

        local oldC; oldC = hookfunction(SendClaim, function(seed, impact)
            local t = nil;
            
            if not ForceHitEnabled and not InstantBulletEnabled then
                return oldC(seed, impact)
            end

            if RagebotEnabled then 
                t = GetVisibleTarget()
            else 
                t = GetTarget()
            end

            if t then
                if RagebotEnabled then 
                    return oldC(seed, {
                        Instance = t.FinalPart,
                        Position = t.FinalPart.Position
                    })
                elseif SilentEnabled then
                    return oldC(seed, {
                        Instance = t,
                        Position = t.Position
                    })
                end 
            end

            return oldC(seed, impact)
        end)

        if isfunctionhooked(Shoot) then 
            restorefunction(Shoot)
        end 

        local old; old = hookfunction(Shoot, function(p20, p21, p22, origin, p24, p25) 
            local t = GetTarget()

            if t and SilentEnabled then 
                
                local offset, _, _ = findminoffset(t, origin)
                
                if ManipEnabled and offset then 
                    origin = origin + offset
                end
                local ballisticProps = GetBallisticProps(p20, p21, p22, p25)
                local newdir = PredictDirection(origin, t.Position, t.AssemblyLinearVelocity, ballisticProps) or (t.Position - origin).Unit;

                -- p24[1] is the direction
                p24[1] = newdir
            end 
            
            if t and ForceHitEnabled then
                local ballisticProps = GetBallisticProps(p20, p21, p22, p25)
                p24[1] = PredictDirection(origin, t.Position, t.AssemblyLinearVelocity, ballisticProps) or (t.Position - origin).Unit

                local targetChar = t:FindFirstAncestorOfClass("Model")
                
                if targetChar then
                    p25 = p25 or {}
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Include
                    params.FilterDescendantsInstances = {targetChar}
                    p25.RaycastParams = params
                end
            end

            if TracerEnabled then 
                CreateTracer(origin, p24[1])
            end

            IsShooting = true 

            local char = LocalPlayer.Character  

            if char and YawAimEnabled then

                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildWhichIsA("Humanoid")
                if hrp and hum then
                    hum.AutoRotate = true
                    local _, CamYaw, _ = Camera.CFrame:ToOrientation()
                    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, CamYaw, 0)
                    origin = GetMuzzlePos()
                end
            end

            if AntiAimEnabled and sendOwnInfoOriginal then 
                local upvs = getupvalues(sendOwnInfoOriginal)
                local info = upvs[1]

                if info and type(info) == 'table' then 
                    local CamPitch, _, _ = Camera.CFrame:ToOrientation()

                    info.NewCameraAngle = CamPitch
                    info.CurrentCameraAngle = CamPitch
                    
                    sendOwnInfoOriginal()
                end 
            end 

            local new = old(p20, p21, p22, origin, p24, p25)
            
            if InstantBulletEnabled and t and new and new[1] then
                oldC(new[1].seed, {
                    Instance = t,
                    Position = t.Position
                })
            end
            
            IsShooting = false 

            return new
        end)

        RealShoot = old


        --#region RAGEBOT!!!!!
            
            task.spawn(function()
                while true do 

                    if RagebotEnabled and RealShoot then 
                        local t = GetVisibleTarget()

                        if t then 
                            local head = t.FinalPart
                            local char = LocalPlayer.Character

                            if char then 
                                local tool = char:FindFirstChildWhichIsA("Tool")

                                if tool then 
                                    local origin = GetMuzzlePos()
                                    local ShootOrigin = origin


                                    if ManipEnabled and t.offset then 
                                        ShootOrigin = origin + t.offset
                                    end

                                    local ballisticProps = GetBallisticProps(tool, 1, 1, {})
                                    local direction = PredictDirection(ShootOrigin, head.Position, head.AssemblyLinearVelocity, ballisticProps) or (head.Position - ShootOrigin).Unit

                                    IsShooting = true
                                    
                                    local char = LocalPlayer.Character 

                                    if YawAimEnabled and char then
                                        local hrp = char:FindFirstChild("HumanoidRootPart")
                                        local hum = char:FindFirstChildWhichIsA("Humanoid")

                                        if hrp and hum then
                                            hum.AutoRotate = true
                                            local _, CamYaw, _ = Camera.CFrame:ToOrientation()
                                            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, CamYaw, 0)
                                            ShootOrigin = GetMuzzlePos()
                                            direction = PredictDirection(ShootOrigin, head.Position, head.AssemblyLinearVelocity, ballisticProps) or (head.Position - ShootOrigin).Unit
                                        end
                                    end

                                    if AntiAimEnabled and sendOwnInfoOriginal then
                                        local upvs = getupvalues(sendOwnInfoOriginal)
                                        local info = upvs[1]

                                        if info and type(info) == 'table' then
                                            local CamPitch, _, _ = Camera.CFrame:ToOrientation()
                                            info.NewCameraAngle = CamPitch
                                            info.CurrentCameraAngle = CamPitch
                                            sendOwnInfoOriginal()
                                        end
                                    end

                                    local new = RealShoot(tool, 1, 1, ShootOrigin, {direction}, {})
                                    
                                    if InstantBulletEnabled and new and new[1] then
                                        oldC(new[1].seed, {
                                            Instance = head,
                                            Position = head.Position
                                        })
                                    end

                                    IsShooting = false

                                    if TracerEnabled then 
                                        CreateTracer(ShootOrigin, direction)
                                    end
                                end 
                            end 
                        end 

                    --elseif not RealShoot then 
                    --    print('didnt find RealShoot')
                    end 

                    task.wait(0)
                end     
            end)

        --#endregion
        
    --#endregion



    --#region gun mods

        local Recoil = Modules.RecoilController.rNDvKCHx7N

        if isfunctionhooked(Recoil) then 
            restorefunction(Recoil)
        end 

        local old; old = hookfunction(Recoil, function(...) 
            if NoRecoilEnabled then 
                return 
            end

            return old(...)
        end)

        local Solve = Modules.WallPush.solve

        if isfunctionhooked(Solve) then 
            restorefunction(Solve)
        end 

        local old; old = hookfunction(Solve, function(p3, p4, p5, p6, ...) 
            if NoWallPushEnabled then 
                return {
                    raise = 0;
                    push = 0;
                    hit = nil;
                }
            end

            return old(p3, p4, p5, p6, ...)
        end)



        local updateSway = filtergc("function", {Name = "updateSway"}, true)
        local updateShake = filtergc("function", {Name = "updateShake"}, true)

        if isfunctionhooked(updateSway) then 
            restorefunction(updateSway)
        end 

        local old; old = hookfunction(updateSway, function(p54, ...) 

            if not NoSwayEnabled then 
                return old(p54, ...)
            end 

        end)
        

        local ReloadBuffer = buffer.create(3)

        buffer.writeu8(ReloadBuffer, 0, 1)
        buffer.writeu8(ReloadBuffer, 1, 1)
        buffer.writeu8(ReloadBuffer, 2, 1)


        task.spawn(function()
            while true do 
                if AutoReloadEnabled then 
                    Remotes.Weapon:FireServer(ReloadBuffer)
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

        Sections.aimbot:Toggle({
            Name = 'ragebot';
            Flag = 'ragebot';
            Default = false;
            Callback = function(v)
                RagebotEnabled = v;
            end 
        })

        Sections.aimbot:Label({Name = "pick between manip or ragebot"})
        Sections.aimbot:Label({Name = "enabling both means lag"})

        Sections.gunmods:Toggle({
            Name = 'no recoil';
            Flag = 'norecoil';
            Default = false; 
            Callback = function(v)
                NoRecoilEnabled = v;
            end 
        })

        Sections.gunmods:Toggle({
            Name = 'no wall push';
            Flag = 'nowallpush';
            Default = false; 
            Callback = function(v)
                NoWallPushEnabled = v;
            end 
        })

        Sections.gunmods:Toggle({
            Name = 'no gun sway';
            Flag = 'nogunsway';
            Default = false;
            Callback = function(v)
                NoSwayEnabled = v;
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
            Name = "instant bullet";
            Flag = "instantbullet";
            Default = false;
            Callback = function(v)
                InstantBulletEnabled = v
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
            Name = "anti aim";
            Flag = "antiaim";
            Default = false;
            Callback = function(v)
                AntiAimEnabled = v
            end
        })

        Sections.exploits:Dropdown({
            Name = "pitch mode";
            Items = {"Down", "Up", "Inhead", "Jitter"};
            Default = "Down";
            Callback = function(v)
                AntiAimPitch = v
            end
        })
        
        Sections.exploits:Toggle({
            Name = "yaw anti aim";
            Flag = "yawaantiaim";
            Default = false;
            Callback = function(v)
                YawAimEnabled = v
                
                if not v then
                    local char = LocalPlayer.Character
                
                    if char then
                        local hum = char:FindFirstChildWhichIsA("Humanoid")
                
                        if hum then
                            hum.AutoRotate = true
                        end
                    end
                end
            end
        })

        Sections.exploits:Dropdown({
            Name = "yaw mode";
            Items = {"Backwards", "Spin", "Sideways"};
            Default = "Backwards";
            Callback = function(v)
                YawMode = v
                spinAngle = 0
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
        --[[RunService:BindToRenderStep("tpcam", Enum.RenderPriority.Last.Value + 1, function()
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
        end)]]
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

        --Sections.visuals:Toggle({
        --    Name = 'third person';
        --    Flag = 'ThirdPerson';
        --    Default = false;
        --    Callback = function(v)
        --        ThirdPerson = v;
        --    end
        --})

        --Sections.visuals:Slider({
        --    Name = 'camera distance';
        --    Flag = 'tpdistance';
        --    Default = 15;
        --    Min = 1;
        --    Max = 15;
        --    Decimals = 1;
        --    Callback = function(v)
        --        TpDistance = v;
        --    end
        --})
        
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


        --workspace.Map.Vegetation
        
        --Sections.visuals:Toggle({
        --    Name = 'no vegitation';
        --    Flag = 'noveg';
        --    Default = false;
        --    Callback = function(v)


        --    end
        --})

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
    local BhopEnabled = false;
    local SpeedhackEnabled = false;
    local SpeedSpeed = 1;
    local ModDetector = false;
    local VFlySpeed = 1;

    local flyturnedon = false
    local flyconnections = {}

    local stopflying = function()
        flyturnedon = false
        for i, v in flyconnections do
            v:Disconnect()
        end
        table.clear(flyconnections)
    end

    local startflying = function()
        stopflying()

        local char = LocalPlayer.Character

        if not char then
            return
        end

        local root = char:FindFirstChild('HumanoidRootPart')

        if not root then
            return
        end

        flyturnedon = true

        local controls = {
            F = 0,
            B = 0,
            L = 0,
            R = 0,
            Q = 0,
            E = 0
        }

        local bg = Instance.new('BodyGyro')
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = root.CFrame
        bg.Parent = root

        local bv = Instance.new('BodyVelocity')
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root

        task.spawn(function()
            repeat
                task.wait()
                local spd = VFlySpeed * 50
                local cam = workspace.CurrentCamera

                if controls.L + controls.R ~= 0 or controls.F + controls.B ~= 0 or controls.Q + controls.E ~= 0 then
                    bv.Velocity = (cam.CFrame.LookVector * (controls.F + controls.B) + (cam.CFrame * CFrame.new(controls.L + controls.R, (controls.F + controls.B + controls.Q + controls.E) * 0.2, 0).p - cam.CFrame.p)) * spd
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end

                bg.CFrame = cam.CFrame
            until not flyturnedon

            bg:Destroy()
            bv:Destroy()
        end)

        table.insert(flyconnections, UserInputService.InputBegan:Connect(function(input, processed)
            if processed then
                return
            end

            local s = VFlySpeed
            if input.KeyCode == Enum.KeyCode.W then
                controls.F = s
            elseif input.KeyCode == Enum.KeyCode.S then
                controls.B = -s
            elseif input.KeyCode == Enum.KeyCode.A then
                controls.L = -s
            elseif input.KeyCode == Enum.KeyCode.D then
                controls.R = s
            elseif input.KeyCode == Enum.KeyCode.E then
                controls.Q = s * 2
            elseif input.KeyCode == Enum.KeyCode.Q then
                controls.E = -s * 2
            end
        end))

        table.insert(flyconnections, UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                controls.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then
                controls.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then
                controls.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then
                controls.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then
                controls.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then
                controls.E = 0
            end
        end))
    end

    --#region logic

        RunService.Heartbeat:Connect(function(delta)
            if SpeedhackEnabled and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
                LocalPlayer.Character:TranslateBy(humanoid.MoveDirection * (SpeedSpeed) * delta * 10)
            end

            if BhopEnabled then
                local Char = LocalPlayer.Character

                if Char and Char:FindFirstChild("Humanoid") then
                    if Char:FindFirstChild("Humanoid").MoveDirection.Magnitude > 0 then
                        Char:FindFirstChild("Humanoid").Jump = true
                    end
                end
            end
        end)

        local IsModRole = function(plr)
            local works, groups = pcall(function()
                return GroupService:GetGroupsAsync(plr.UserId)
            end)

            if not works then
                return false
            end

            for i, v in groups do
                if v.Id == 32519006 and v.Rank > 1 then
                    return true, v.Role
                end
            end

            return false
        end

        local GetMods = function()
            if ModDetector then
                for i, v in Players:GetPlayers() do
                    local IsMod, role = IsModRole(v)

                    if IsMod then
                        for i = 0, 10, 1 do
                            Library:Notification({
                                Name = "Mod detected! " .. v.Name .. " is a " .. role;
                                Time = 10;
                            })
                            task.wait()
                        end
                    end
                end
            end
        end

        Players.PlayerAdded:Connect(function(v)
            local IsMod, role = IsModRole(v)

            if IsMod then
                for i = 0, 10, 1 do
                    Library:Notification({
                        Name = "Mod detected! " .. v.Name .. " is a " .. role;
                        Time = 10;
                    })
                    task.wait()
                end
            end
        end)

    --#endregion



    --#region toggles

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

        Sections.movement:Toggle({
            Name = 'vehicle fly';
            Flag = 'fly';
            Default = false;
            Callback = function(v)
                if v then
                    startflying()
                else
                    stopflying()
                end
            end
        })

        Sections.movement:Slider({
            Name = 'fly speed';
            Flag = 'flyspeed';
            Default = 1;
            Min = 0.1;
            Max = 10;
            Decimals = 1;
            Callback = function(v)
                VFlySpeed = v;
            end
        })
        Sections.movement:Label({Name = "fly bind"}):Keybind({
            Flag = "flybind";
            Mode = "Toggle";
            Default = Enum.KeyCode.F;
            Callback = function(Value)
                if Value then
                    startflying()
                else
                    stopflying()
                end
            end
        })

        Sections.miscexploits:Toggle({
            Name = 'mod detector';
            Flag = 'moddtc';
            Default = false;
            Callback = function(v)
                ModDetector = v;
                GetMods()
            end
        })

    --#endregion

end



Window:InitWindow()
