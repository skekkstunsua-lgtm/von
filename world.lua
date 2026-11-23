local module = {
    connections = {}; -- key : inst .. prop -> RBXScriptConnection
    oldvalues = {}; -- key : inst .. prop -> value to restore
    hasold = {}; -- key : inst .. prop -> boolean
    settings = {}; -- key : inst .. prop -> settings val
    instTable = {}; -- key : name -> Instance
}

function module.SetInstanceTable(tbl: {any})
    module.instTable = tbl;
end;

local function differs(a, b)
    if typeof(a) == "number" and typeof(b) == "number" then
        return math.abs(a - b) > 1e-4;
    end;
    return a ~= b;
end;

local function apply(obj, prop, k)
    local t = module.settings[k];
    if t ~= nil and differs(obj[prop], t) then
        obj[prop] = t;
    end;
end;

local function enableConnection(inst, prop)
    local obj = module.instTable[inst];
    if not obj then
        return;
    end;

    local k = inst .. prop;
    local conn = module.connections[k];

    if conn then
        conn:Disconnect();
    end;

    if not module.hasold[k] then
        module.oldvalues[k] = obj[prop];
        module.hasold[k] = true;
    end;

    module.connections[k] = obj:GetPropertyChangedSignal(prop):Connect(function()
        apply(obj, prop, k);
    end);
    apply(obj, prop, k);
end;

local function disableConnection(inst, prop)
    local obj = module.instTable[inst];
    if not obj then
        return;
    end;

    local k = inst .. prop;
    local conn = module.connections[k];

    if conn then
        conn:Disconnect();
        module.connections[k] = nil;
    end;

    if module.hasold[k] then
        pcall(function()
            obj[prop] = module.oldvalues[k];
        end);
        module.oldvalues[k] = nil;
        module.hasold[k] = nil;
    end;
end;

function module.SetConnection(inst: string, prop: string, toggle: boolean)
    if toggle then
        enableConnection(inst, prop);
    elseif toggle == false then
        disableConnection(inst, prop);
    end;
end;

function module.SetSetting(inst: string, prop: string, value: any)
    if inst and prop and value ~= nil then
        local k = inst .. prop;
        module.settings[k] = value;
        local obj = module.instTable[inst];
        if module.connections[k] and obj then
            apply(obj, prop, k);
        end;
    end;
end;

return module;
