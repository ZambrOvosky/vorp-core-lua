local firstSpawn = true
local active = false
local HealthData = {}
local pvp = Config.PVP
local multiplierHealth, multiplierStamina
local T = Translation[Lang].MessageOfSystem

-- FUNCTIONS
function CoreAction.Utils.TogglePVP()
    pvp = not pvp
    TriggerEvent("vorp:setPVPUi", pvp)
    return pvp
end

function CoreAction.Utils.setPVP()
    local playerHash = joaat("PLAYER")
    NetworkSetFriendlyFireOption(pvp)

    if not active then
        if pvp then
            SetRelationshipBetweenGroups(5, playerHash, playerHash)
        else
            SetRelationshipBetweenGroups(1, playerHash, playerHash)
        end
    else
        SetRelationshipBetweenGroups(1, playerHash, playerHash)
    end
end

local function MapCheck()
    local player = PlayerPedId()
    local playerOnMout = IsPedOnMount(player)
    local playerOnVeh = IsPedInAnyVehicle(player, false)
    if Config.enableTypeRadar then
        if not playerOnMout and not playerOnVeh then
            SetMinimapType(Config.mapTypeOnFoot)
        elseif playerOnMout or playerOnVeh then
            SetMinimapType(Config.mapTypeOnMount)
        end
    end
end

function CoreAction.Player.TeleportToCoords(coords, heading)
    local playerPedId = PlayerPedId()
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    SetEntityCoords(playerPedId, coords.x, coords.y, coords.z, true, true, true, false)
    if heading then
        SetEntityHeading(playerPedId, heading)
    end
    repeat Wait(100) until HasCollisionLoadedAroundEntity(playerPedId)
end

-- PLAYERSPAWN
AddEventHandler('playerSpawned', function()
    Wait(500)
    TriggerServerEvent('vorp_core:instanceplayers', tonumber(GetPlayerServerId(PlayerId())) + 45557)
    Wait(2000)
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Hold, T.Load, T.Almost) --_DISPLAY_LOADING_SCREENS
    DisplayRadar(false)
    SetMinimapHideFow(false)
    Wait(2000)
    TriggerServerEvent("vorp:playerSpawn")
    Wait(9000)
    ShutdownLoadingScreen()
    SetEntityCanBeDamaged(PlayerPedId(), false)
    CreateThread(function()
        while firstSpawn do
            Wait(0)
            DisableControlAction(0, `INPUT_MP_TEXT_CHAT_ALL`, true)
            DisableControlAction(0, `INPUT_QUICK_USE_ITEM`, true)
        end
    end)
end)

--EVENTS character Innitialize
RegisterNetEvent('vorp:initCharacter', function(coords, heading, isdead)
    CoreAction.Player.TeleportToCoords(coords, heading)

    if isdead then
        if not Config.CombatLogDeath then
            if Config.Loadinscreen then
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.forcedrespawn, T.forced, T.Almost)
            end
            TriggerServerEvent("vorp:PlayerForceRespawn")
            TriggerEvent("vorp:PlayerForceRespawn")
            CoreAction.Player.RespawnPlayer()
            Wait(Config.LoadinScreenTimer)
            Wait(1000)
            ShutdownLoadingScreen()
            Wait(7000)
            CoreAction.Admin.HealPlayer()
        else
            if Config.Loadinscreen then
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Holddead, T.Loaddead, T.Almost)
            end
            Wait(10000)
            TriggerEvent("vorp_inventory:CloseInv")
            Wait(4000)
            SetEntityHealth(PlayerPedId(), 0, 0)
            ShutdownLoadingScreen()
        end
    else
        local PlayerId = PlayerId()
        if Config.Loadinscreen then
            Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Hold, T.Load, T.Almost)
            Wait(Config.LoadinScreenTimer)
            Wait(1000)
            ShutdownLoadingScreen()
        end

        if not Config.HealthRecharge.enable then
            Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId, 0.0) -- SetPlayerHealthRechargeMultiplier
        else
            Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId, Config.HealthRecharge.multiplier)
            multiplierHealth = Citizen.InvokeNative(0x22CD23BB0C45E0CD, PlayerId) -- GetPlayerHealthRechargeMultiplier
        end

        if not Config.StaminaRecharge.enable then
            Citizen.InvokeNative(0xFECA17CF3343694B, PlayerId, 0.0) -- SetPlayerStaminaRechargeMultiplier
        else
            Citizen.InvokeNative(0xFECA17CF3343694B, PlayerId, Config.StaminaRecharge.multiplier)
            multiplierStamina = Citizen.InvokeNative(0x617D3494AD58200F, PlayerId) -- GetPlayerStaminaRechargeMultiplier
        end

        if Config.SavePlayersStatus then
            TriggerServerEvent("vorp:GetValues")
            Wait(10000)
            local player = PlayerPedId()
            Citizen.InvokeNative(0xC6258F41D86676E0, player, 0, HealthData.hInner)
            SetEntityHealth(player, HealthData.hOuter + HealthData.hInner, 0)
            Citizen.InvokeNative(0xC6258F41D86676E0, player, 1, HealthData.sInner)
            Citizen.InvokeNative(0x675680D089BFA21F, player, HealthData.sOuter / 1065353215 * 100)
            HealthData = {}
        else
            CoreAction.Admin.HealPlayer()
        end
    end
end)

-- PLAYER SPAWN AFTER SELECT CHARACTER
RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler("vorp:SelectedCharacter", function()
    firstSpawn = false
    local PlayerPed = PlayerPedId()
    local PlayerId = PlayerId()
    CoreAction.Utils.setPVP()
    SetEntityCanBeDamaged(PlayerPed, true)
    Citizen.InvokeNative(0xA63FCAD3A6FEC6D2, PlayerId, Config.ActiveEagleEye)
    Citizen.InvokeNative(0x95EE1DEE1DCD9070, PlayerId, Config.ActiveDeadEye)
    TriggerEvent("vorp:showUi", not Config.HideUi)
    DisplayRadar(true)
    SetMinimapHideFow(true)
    TriggerServerEvent("vorp:chatSuggestion")
    TriggerServerEvent('vorp_core:instanceplayers', 0) -- remove instanced players
    TriggerServerEvent("vorp:SaveDate")
    Wait(10000)
    -- GUARMA SPAWN
    local pedCoords = GetEntityCoords(PlayerPed)
    local area = Citizen.InvokeNative(0x43AD8FC02B429D33, pedCoords, 10)
    if area == -512529193 then
        Citizen.InvokeNative(0xA657EC9DBC6CC900, 1935063277)
        Citizen.InvokeNative(0xE8770EE02AEE45C2, 1)
        Citizen.InvokeNative(0x74E2261D2A66849A, true)
    end
end)

RegisterNetEvent("vorp:GetHealthFromCore")
AddEventHandler("vorp:GetHealthFromCore", function(healthData)
    HealthData = healthData
end)

-- THREADS
CreateThread(function()
    while true do
        Wait(0)

        local pped = PlayerPedId()
        DisableControlAction(0, 0x580C4473, true) -- Disable hud
        DisableControlAction(0, 0xCF8A4ECA, true) -- Disable hud
        DisableControlAction(0, 0x9CC7A1A4, true) -- disable special ability when open hud
        DisableControlAction(0, 0x1F6D95E5, true) -- diable f4 key that contains HUD

        if not firstSpawn then
            if IsControlPressed(0, 0xCEFD9220) then
                active = true
                CoreAction.Utils.setPVP()
                Wait(4000)
            end

            if not IsPedOnMount(pped) and not IsPedInAnyVehicle(pped, false) and active then
                active = false
                CoreAction.Utils.setPVP()
            elseif active and IsPedOnMount(pped) or IsPedInAnyVehicle(pped, false) then
                if IsPedInAnyVehicle(pped, false) then

                elseif GetPedInVehicleSeat(GetMount(pped), -1) == pped then
                    active = false
                    CoreAction.Utils.setPVP()
                end
            else
                CoreAction.Utils.setPVP()
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(3000)

        if not firstSpawn then
            MapCheck()
            if not Config.onesync then
                local player = PlayerPedId()
                local playerCoords = GetEntityCoords(player, true, true)
                local playerHeading = GetEntityHeading(player)
                TriggerServerEvent("vorp:saveLastCoords", playerCoords, playerHeading)
            end
        end
    end
end)

CreateThread(function()
    while Config.SavePlayersStatus do
        Wait(1000)
        local player = PlayerPedId()
        local innerCoreHealth = Citizen.InvokeNative(0x36731AC041289BB1, player, 0)
        local outerCoreStamina = Citizen.InvokeNative(0x22F2A386D43048A9, player)
        local innerCoreStamina = Citizen.InvokeNative(0x36731AC041289BB1, player, 1)
        local getHealth = GetEntityHealth(player)
        TriggerServerEvent("vorp:HealthCached", getHealth, innerCoreHealth, outerCoreStamina, innerCoreStamina)
    end
end)

CreateThread(function()
    while Config.SavePlayersStatus do
        local player = PlayerPedId()
        Wait(300000) -- wont be accurate as it waits for too long
        local innerCoreHealth = Citizen.InvokeNative(0x36731AC041289BB1, player, 0, Citizen.ResultAsInteger())
        local outerCoreStamina = Citizen.InvokeNative(0x22F2A386D43048A9, player)
        local innerCoreStamina = Citizen.InvokeNative(0x36731AC041289BB1, player, 1, Citizen.ResultAsInteger())
        local getHealth = GetEntityHealth(player)
        local innerHealth = tonumber(innerCoreHealth)
        local innerStamina = tonumber(innerCoreStamina)
        TriggerServerEvent("vorp:SaveHealth", getHealth, innerHealth)
        TriggerServerEvent("vorp:SaveStamina", outerCoreStamina, innerStamina)
    end
end)

CreateThread(function()
    while Config.SavePlayersHours do
        Wait(6000 * 5)
        TriggerServerEvent("vorp:SaveHours")
    end
end)

-- APPLY HEALTHRECHARGE WHEN CHARACTER RC
CreateThread(function()
    while true do
        if not firstSpawn then
            local PlayerId = PlayerId()
            local multiplierH = Citizen.InvokeNative(0x22CD23BB0C45E0CD, PlayerId) -- GetPlayerHealthRechargeMultiplier

            if multiplierHealth and multiplierHealth ~= multiplierH then
                Wait(500)
                Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId, Config.HealthRecharge.multiplier) -- SetPlayerHealthRechargeMultiplier
            elseif not multiplierHealth and multiplierH then
                Wait(500)
                Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId, 0.0) -- SetPlayerHealthRechargeMultiplier
            end

            local multiplierS = Citizen.InvokeNative(0x617D3494AD58200F, PlayerId) -- GetPlayerStaminaRechargeMultiplier

            if multiplierStamina and multiplierStamina ~= multiplierS then
                Wait(500)
                Citizen.InvokeNative(0xFECA17CF3343694B, PlayerId, Config.StaminaRecharge.multiplier) -- SetPlayerStaminaRechargeMultiplier
            elseif not multiplierStamina and multiplierS then
                Wait(500)
                Citizen.InvokeNative(0xFECA17CF3343694B, PlayerId, 0.0) -- SetPlayerStaminaRechargeMultiplier
            end
        end
        Wait(500)
    end
end)