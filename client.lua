ESX = exports["es_extended"]:getSharedObject()
-- Variables locales
local isNuiReady = false
local inPauseMenu = false
local tabletProp = nil

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

-- Función para contar jugadores por trabajo
function ContarJugadoresPorTrabajo()
  local servicios = {}
  
  for _, servicio in ipairs(Config.ServiciosInfo) do
    servicios[servicio.job] = 0
  end
  
  return lib.callback.await('AX_PauseMenu:GetServiciosCount', false, servicios)
end

function PauseMenu()
  if IsPauseMenuActive() then 
    SetPauseMenuActive(true)
    SetNuiFocus(true, true)
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'), 0, -1)
    return
  end

  if IsNuiFocused() then 
    return
  end

  if not isNuiReady then
    return
  end

  if inPauseMenu then
    SendNUIMessage({ type = "close" })
    return
  end

  -- Reproducir animación de tablet con prop
  local playerPed = PlayerPedId()
  local dict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
  local prop = "prop_cs_tablet"
  
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Wait(10)
  end
  
  RequestModel(GetHashKey(prop))
  while not HasModelLoaded(GetHashKey(prop)) do
    Wait(10)
  end
  
  local tablet = CreateObject(GetHashKey(prop), 0, 0, 0, true, true, true)
  AttachEntityToEntity(tablet, playerPed, GetPedBoneIndex(playerPed, 60309), 0.03, 0.002, -0.0, 10.0, 160.0, 0.0, true, true, false, true, 1, true)
  
  TaskPlayAnim(playerPed, dict, "base", 8.0, -8.0, -1, 50, 0, false, false, false)
  
  -- Guardar referencia del prop para eliminarlo después
  tabletProp = tablet

  -- Obtener skills del gym
  local skills = {
    driving = exports["vms_gym"]:getSkill("driving") or 0,
    shooting = exports["vms_gym"]:getSkill("shooting") or 0,
    condition = exports["vms_gym"]:getSkill("condition") or 0,
    strenght = exports["vms_gym"]:getSkill("strenght") or 0
  }

  -- Obtener datos del jugador del servidor (incluye servicios)
  local playerData = lib.callback.await('AX_PauseMenu:GetPlayerData', false)
  
  if not playerData then
    print('[AX_PauseMenu] Error: No se pudieron obtener los datos del jugador')
    return
  end

  -- Agregar skills a playerData
  playerData.skills = skills

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
  
  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end
  
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

  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end

  inPauseMenu = false
  cb('ok')
end)

-- Callback para salir del servidor (ahora solo abre modal)
RegisterNUICallback('exit', function(data, cb)
  SendNUIMessage({
    type = "openExitModal"
  })
  cb('ok')
end)

-- Callback para cambiar personaje
RegisterNUICallback('cambiarPersonaje', function(data, cb)
  ExecuteCommand('logout')
  
  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end

  inPauseMenu = false
  SetNuiFocus(false, false)
  SendNUIMessage({ type = "close" })
  TriggerScreenblurFadeOut(5000)
  
  cb('ok')
end)

-- Callback para salir del servidor
RegisterNUICallback('salirServidor', function(data, cb)
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

  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end

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

-- Callback SERVICIOS
RegisterNUICallback('servicios', function(data, cb)
  local xPlayer = ESX.GetPlayerData()
  local job = xPlayer.job.name
  local isAuthorized = false
  
  for _, jobName in ipairs(Config.ServiciosEmergencia) do
    if job == jobName and xPlayer.job.grade >= 0 then
      isAuthorized = true
      break
    end
  end
  
  if isAuthorized then
    TriggerEvent("origen_police:client:OpenPoliceCad")
    
    -- Cerrar el pause menu
    inPauseMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "close" })
    TriggerScreenblurFadeOut(5000)
  else
    ESX.ShowNotification('No tienes el trabajo de policía ni EMS', 'error')
  end
  
  cb('ok')
end)

-- Callback RACING
RegisterNUICallback('racing', function(data, cb)
  exports.nx_racing:openTablet()
  
  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end

  -- Cerrar el pause menu
  inPauseMenu = false
  SetNuiFocus(false, false)
  SendNUIMessage({ type = "close" })
  TriggerScreenblurFadeOut(5000)
  
  cb('ok')
end)

-- Callback REPORTAR
RegisterNUICallback('report', function(data, cb)
  ExecuteCommand('report')
  
  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end

  -- Cerrar el pause menu
  inPauseMenu = false
  SetNuiFocus(false, false)
  SendNUIMessage({ type = "close" })
  TriggerScreenblurFadeOut(5000)
  
  cb('ok')
end)

-- Callback DAILY
RegisterNUICallback('daily', function(data, cb)
  ExecuteCommand('dailyreward')
  
  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end

  -- Cerrar el pause menu
  inPauseMenu = false
  SetNuiFocus(false, false)
  SendNUIMessage({ type = "close" })
  TriggerScreenblurFadeOut(5000)
  
  cb('ok')
end)

-- Callback ROCKSTAR EDITOR
RegisterNUICallback('editor', function(data, cb)
  ExecuteCommand('rockstar')
  
  -- Detener animación de tablet y eliminar prop
  local playerPed = PlayerPedId()
  ClearPedTasks(playerPed)
  if tabletProp then
    DeleteObject(tabletProp)
    tabletProp = nil
  end

  -- Cerrar el pause menu
  inPauseMenu = false
  SetNuiFocus(false, false)
  SendNUIMessage({ type = "close" })
  TriggerScreenblurFadeOut(5000)
  
  cb('ok')
end)

-- Callback ROBOS (corregido)
RegisterNUICallback('robos', function(data, cb)
  -- Obtener contador de policías desde el servidor
  local policiasOnDuty = lib.callback.await('AX_PauseMenu:GetPoliciasCount', false)
  
  -- Enviar datos al NUI
  SendNUIMessage({
    type = "openRobosModal",
    robos = Config.Robos,
    normas = Config.NormasRobos,
    policiasOnDuty = policiasOnDuty
  })
  
  cb('ok')
end)

-- Callback FACTURAS
RegisterNUICallback('facturas', function(data, cb)
  -- Obtener facturas desde el servidor
  lib.callback('AX_PauseMenu:GetFacturas', false, function(facturas)
    SendNUIMessage({
      type = "openFacturasModal",
      facturas = facturas,
      normas = Config.NormasFacturas
    })
  end)
  
  cb('ok')
end)

-- Callback PAGAR FACTURA
RegisterNUICallback('pagarFactura', function(data, cb)
  local facturaId = data.facturaId
  
  lib.callback('AX_PauseMenu:PagarFactura', false, function(success, message)
    if success then
      ESX.ShowNotification(message, 'success')
      -- Recargar facturas
      lib.callback('AX_PauseMenu:GetFacturas', false, function(facturas)
        SendNUIMessage({
          type = "openFacturasModal",
          facturas = facturas
        })
      end)
    else
      ESX.ShowNotification(message, 'error')
    end
  end, facturaId)
  
  cb('ok')
end)

-- Callback para marcar ubicación de negocio
RegisterNUICallback('marcarNegocio', function(data, cb)
  local coords = data.coords
  
  if coords and coords.x and coords.y then
    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z or 0.0)
    
    -- Crear blip en el mapa
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, 475)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.nombre or "Negocio")
    EndTextCommandSetBlipName(blip)
    
    -- Establecer waypoint (CORREGIDO)
    SetNewWaypoint(x, y)
    
    ESX.ShowNotification('Ubicación marcada: ' .. (data.nombre or 'Negocio'))
    
    -- Eliminar blip después de 30 segundos
    SetTimeout(30000, function()
      if DoesBlipExist(blip) then
        RemoveBlip(blip)
      end
    end)
  else
    ESX.ShowNotification('Error: Coordenadas inválidas', 'error')
  end
  
  cb('ok')
end)

-- Callback para ejecutar comandos
RegisterNUICallback('ejecutarComando', function(data, cb)
  if data.comando then
    ExecuteCommand(data.comando)
    ESX.ShowNotification('Solicitud enviada')
  end
  cb('ok')
end)