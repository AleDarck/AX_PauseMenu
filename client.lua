ESX = exports["es_extended"]:getSharedObject()
-- Variables locales
local isNuiReady = false
local inPauseMenu = false

-- Registrar comando si está habilitado
if Config.EnableCommand then
  RegisterCommand(Config.Command, function()
    PauseMenu()
  end, false)
  
  TriggerEvent('chat:removeSuggestion', '/' .. Config.Command)

  if Config.EnableKeyMapping then
    RegisterKeyMapping(Config.Command, 'Abrir Pause Menu', 'keyboard', Config.KeyMapping)
  end
end

-- Función principal del Pause Menu
function PauseMenu()
  -- Prevenir apertura si el menú nativo está activo
  if IsPauseMenuActive() then 
    SetPauseMenuActive(true)
    SetNuiFocus(true, true)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'), 0, -1)
    return
  end

  -- Prevenir apertura si ya hay focus en NUI
  if IsNuiFocused() then 
    return
  end

  -- Verificar que NUI esté listo
  if not isNuiReady then
    return
  end

  -- Si el menú ya está abierto, cerrarlo
  if inPauseMenu then
    SendNUIMessage({
      type = "close"
    })
    return
  end

  -- Obtener datos del jugador del servidor
  local playerData = lib.callback.await('AX_PauseMenu:GetPlayerData', false)
  
  if not playerData then
    print('[AX_PauseMenu] Error: No se pudieron obtener los datos del jugador')
    return
  end

  -- Abrir el menú
  inPauseMenu = true
  SendNUIMessage({
    type = "open",
    data = playerData
  })
  SetNuiFocus(true, true)
  TriggerEvent('AX_PauseMenu:OpenPauseMenu', playerData)
  TriggerScreenblurFadeIn(5000)
end

-- Callback cuando NUI está listo
RegisterNUICallback('ready', function(data, cb)
  isNuiReady = true
  TriggerEvent('AX_PauseMenu:NuiReady')
  cb('ok')
end)

-- Callback para cerrar el menú
RegisterNUICallback('close', function(data, cb)
  inPauseMenu = false
  SetNuiFocus(false, false)
  SendNUIMessage({
    type = "close"
  })
  
  TriggerScreenblurFadeOut(5000)
  TriggerEvent('AX_PauseMenu:OnClose')
  cb('ok')
end)

-- Callback para abrir ajustes
RegisterNUICallback('settings', function(data, cb)
  ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'), 1, -1) 
  TriggerScreenblurFadeOut(5000)
  SetNuiFocus(false, false)
  TriggerEvent('AX_PauseMenu:OnButtonClicked', 'settings')
  SendNUIMessage({
    type = "close"
  })
  inPauseMenu = false
  cb('ok')
end)

-- Callback para salir del servidor
RegisterNUICallback('exit', function(data, cb)
  TriggerServerEvent('AX_PauseMenu:QuitServer')
  SetNuiFocus(false, false)
  cb('ok')
end)

-- Callback para abrir mapa
RegisterNUICallback('map', function(data, cb)
  TriggerScreenblurFadeOut(5000)
  SetNuiFocus(false, false)
  TriggerEvent('AX_PauseMenu:OnButtonClicked', 'map')
  SendNUIMessage({
    type = "close"
  })
  inPauseMenu = false
  ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'), 1, -1) 
  cb('ok')
end)

-- Callback para abrir reglas
RegisterNUICallback('rules', function(data, cb)
  TriggerEvent('AX_PauseMenu:OnButtonClicked', 'rules')
  cb('ok')
end)

-- Thread para deshabilitar el menú nativo de pausa
CreateThread(function()
  while true do 
    SetPauseMenuActive(false) 
    Wait(Config.PauseMenuTick)
    if IsPauseMenuActive() then
      SetNuiFocus(false, false)
    end
  end
end)

-- Callback para obtener avatar de Discord
RegisterNUICallback('GetDiscordAvatar', function(data, cb)
  local discord_avatar = lib.callback.await('AX_PauseMenu:GetDiscordAvatar', false)
  if not discord_avatar then
    cb({
      avatar = nil,
      discord_id = nil
    })
    return
  end
  cb({
    avatar = discord_avatar.avatar,
    discord_id = discord_avatar.discord_id,
  })
end)