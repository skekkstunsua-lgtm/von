if not game:IsLoaded() then 
    game.Loaded:Wait()
end

if game.GameId == 111958650 then -- arsenal
    loadstring(game:HttpGet('https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/Arsenal.lua'))()
elseif game.GameId == 5091490171 then -- jailbird
    if game.PlaceId == 14772802900 then 
        game.Players.LocalPlayer:Kick("please dont load in lobby! :)")
        return 
    end 
    loadstring(game:HttpGet('https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/jailbird.lua'))()
elseif game.GameId == 4750561026 then  -- cold war
    loadstring(game:HttpGet('https://raw.githubusercontent.com/skekkstunsua-lgtm/von/refs/heads/main/coldwar.lua'))()
else
    game.Players.LocalPlayer:Kick("game is unsupported. "..game.GameId)
    return
end
