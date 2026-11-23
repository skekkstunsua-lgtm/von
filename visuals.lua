local module = {
    rconnection = {
        playeraddedcons = {};
        playerremovingcons = {};
        charaddedcons = {}

    }; -- nil | RBXScriptConnection
    settings = {
        bha = {
            enabled = false;
            Color3 = Color3.new(1, 1, 1);
            Transparency = 0;
            AlwaysOnTop = true;
        }; -- key prop -> value;
        hl = {
            enabled = false;
        }; -- key prop -> value;
    };
};

local allowed = {}
for _, n in {
    "Head", "Left Arm", "Left Leg", "Right Arm", "Right Leg", "Torso",
    "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
} do
    allowed[n] = true
end
module.allowedparts = allowed;
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;

local c_Cache = {
    bha = {};
    hl = {};
};

function applyProps(inst, props)
    for prop, val in props do
        if tostring(prop) == "enabled" then continue; end;
        inst[prop] = val;
    end;
end;

function doBHA(char)
    for _, inst in char:GetChildren() do
        if inst:IsA("BasePart") and module.allowedparts[inst.Name] then
            if inst:FindFirstChild("bha_cham") then continue; end;
            local bhaInst = Instance.new("BoxHandleAdornment");
            bhaInst.Name = "bha_cham";
            applyProps(bhaInst, module.settings.bha);
            bhaInst.Adornee = inst;
            bhaInst.Size = inst.Size + Vector3.new(0.01, 0.01, 0.01);
            bhaInst.Parent = inst;
            table.insert(c_Cache.bha, bhaInst);
        end;
    end;
end;

function doHL(char)

end;

function updateBHA()
    for i = #c_Cache.bha, 1, -1 do
        if not c_Cache.bha[i].Parent then
            table.remove(c_Cache.bha, i);
        end;
    end;

    if not module.settings.bha.enabled then
        module.clear("bha");
        return;
    end;

    if #c_Cache.bha == 0 then
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character then
                doBHA(plr.Character);
            end;
        end;
    else
        for _, inst in c_Cache.bha do
            applyProps(inst, module.settings.bha);
        end;
    end;
end;

function updateHL()
    if not module.settings.hl.enabled then
        module.clear("hl");
        return;
    end;
end;


function module.update(kind: nil | "bha" | "hl")
    if not kind then
        updateBHA();
        updateHL();
    end;
    if kind == "bha" then
        updateBHA();
    elseif kind == "hl" then
        updateHL();
    end;
end;

function module.clear(kind: "bha" | "hl")
    for _, v in c_Cache[kind] do
        v:Destroy();
    end;
    table.clear(c_Cache[kind]);
end;

function hookPlayer(plr)
    if plr == LocalPlayer then return; end;

    local function onChar(modl)
        task.defer(function()
            task.wait(1)
            if module.settings.bha.enabled then
                doBHA(modl);
            end;
            if module.settings.hl.enabled then
                doHL(modl);
            end;
        end);
    end;

    local plr_charadded = plr.CharacterAdded:Connect(onChar);
    module.rconnection.charaddedcons[plr.Name] = plr_charadded;

    if plr.Character then
        if module.settings.bha.enabled then
            doBHA(plr.Character);
        end;
        if module.settings.hl.enabled then
            doHL(plr.Character);
        end;
    end;
end;

do
    for _, plr in Players:GetPlayers() do
        hookPlayer(plr);
    end;
    module.rconnection.playerremovingcons[1] = Players.PlayerRemoving:Connect(function(plr, rsn)
        local con = module.rconnection.charaddedcons[plr.Name];
        if con then
            con:Disconnect();
            module.rconnection.charaddedcons[plr.Name] = nil;
        end;
    end);
    module.rconnection.playeraddedcons[1] = Players.PlayerAdded:Connect(hookPlayer);
end


return module;
