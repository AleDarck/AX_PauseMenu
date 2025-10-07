ESX = exports["es_extended"]:getSharedObject()
-- Verificar que ESX esté cargado
if not ESX then
  print('^1[ERROR] AX_PauseMenu: ESX no está cargado. Verifica que es_extended esté iniciado antes que este script.^7')
  return
end

lib.callback.register('AX_PauseMenu:GetPlayerData', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  
  if not xPlayer then
    print('^1[ERROR] AX_PauseMenu: No se pudo obtener xPlayer para el jugador ' .. source .. '^7')
    return nil
  end

  -- Obtener dinero del banco
  local bank = xPlayer.getAccount('bank').money or 0
  
  -- Obtener vicoins de la base de datos
  local vicoins = MySQL.scalar.await('SELECT vicoin FROM users WHERE identifier = ?', {xPlayer.identifier}) or 0
  
  -- Obtener job y rank
  local job = xPlayer.getJob()
  local jobLabel = job.label or 'Desempleado'
  local jobRank = job.grade_label or 'Sin rango'
  
  -- Obtener ID del jugador (source)
  local playerId = source
  
  -- Contar jugadores online
  local onlinePlayers = #ESX.GetExtendedPlayers()
  local maxPlayers = GetConvarInt('sv_maxclients', 128)
  
  -- Obtener contador de servicios
  local servicios = {}

  -- Police
  local policeTable = exports['origen_police']:GetPlayersInDuty('police')
  if policeTable and type(policeTable) == 'table' then
    servicios['police'] = #policeTable
  else
    servicios['police'] = 0
  end

  -- Ambulance
  local ambulanceTable = exports['origen_police']:GetPlayersInDuty('ambulance')
  if ambulanceTable and type(ambulanceTable) == 'table' then
    servicios['ambulance'] = #ambulanceTable
  else
    servicios['ambulance'] = 0
  end

  -- Taxi
  local taxiCount = exports['AX_TaxiJob']:GetTaxisOnDuty()
  if taxiCount and type(taxiCount) == 'number' then
    servicios['taxi'] = taxiCount
  else
    servicios['taxi'] = 0
  end

  -- Obtener negocios
  local negocios = exports['AX_BusinessTab']:GetAllBusinesses() or {}
  local serviciosEspeciales = Config.ServiciosEspeciales or {}

  local playerData = {
    playerName = Config.GetPlayerName and Config.GetPlayerName(source) or xPlayer.getName(),
    bank = bank,
    playerJob = jobLabel,
    playerRank = jobRank,
    playerId = playerId,
    vicoins = vicoins,
    onlinePlayers = onlinePlayers,
    maxPlayers = maxPlayers,
    citizenId = Config.GetPlayerIdentifier and Config.GetPlayerIdentifier(source) or 'UNKNOWN',
    servicios = servicios,
    negocios = negocios,
    serviciosEspeciales = serviciosEspeciales
  }

  return playerData
end)

-- Función para obtener Discord ID del jugador
function GetDiscordID(src)
  local identifiers = GetPlayerIdentifiers(src)
  local discord = nil

  for i = 1, #identifiers do
    if string.match(identifiers[i], 'discord:') then
      discord = identifiers[i]
      discord = string.gsub(discord, 'discord:', '')
      break
    end
  end

  return discord
end

-- Función para solicitar datos de Discord API
function RequestDiscord(discord_id)
  if not Config.BotToken or Config.BotToken == '' then
    return nil
  end

  local request_url = 'https://discord.com/api/v10/users/' .. discord_id
  local prom = promise:new()
  
  PerformHttpRequest(request_url, function(statusCode, response, headers)
    if statusCode == 200 then
      local data = response and json.decode(response) or nil
      prom:resolve(data)
    else
      prom:resolve(nil)
    end
  end, 'GET', '', { 
    ['Authorization'] = 'Bot ' .. Config.BotToken 
  })
  
  return Citizen.Await(prom)
end

-- Callback para obtener avatar de Discord
lib.callback.register('AX_PauseMenu:GetDiscordAvatar', function(source)
  local discord_id = GetDiscordID(source)
  
  if not discord_id then 
    return {
      avatar = nil,
      discord_id = nil
    }
  end
  
  local response = RequestDiscord(discord_id)
  
  if not response then 
    return { 
      avatar = nil,
      discord_id = discord_id
    }
  end
  
  return {
    avatar = response.avatar or nil,
    discord_id = discord_id
  }
end)

-- Evento para salir del servidor
RegisterServerEvent('AX_PauseMenu:QuitServer')
AddEventHandler('AX_PauseMenu:QuitServer', function()
  local src = source
  Config.ExitFunction(src)
end)

-- Comando de administrador para recargar el menú de un jugador (opcional)
ESX.RegisterCommand('reloadpausemenu', 'admin', function(xPlayer, args, showError)
  local targetId = args.playerId
  
  if not targetId then
    xPlayer.showNotification('Uso: /reloadpausemenu [ID]')
    return
  end
  
  local targetPlayer = ESX.GetPlayerFromId(targetId)
  
  if not targetPlayer then
    xPlayer.showNotification('Jugador no encontrado')
    return
  end
  
  TriggerClientEvent('chat:addMessage', xPlayer.source, {
    args = {'Sistema', 'Menú de pausa recargado para el jugador ' .. targetId}
  })
end, false, {help = 'Recargar el menú de pausa de un jugador', validate = true, arguments = {
  {name = 'playerId', help = 'ID del jugador', type = 'number'}
}})

-- Callback para contar policías de servicio (para robos)
lib.callback.register('AX_PauseMenu:GetPoliciasCount', function(source)
  local policeTable = exports['origen_police']:GetPlayersInDuty('police')
  local ambulanceTable = exports['origen_police']:GetPlayersInDuty('ambulance')
  
  local policeCount = 0
  local ambulanceCount = 0
  
  -- Contar policías
  if policeTable and type(policeTable) == 'table' then
    policeCount = #policeTable
  end
  
  -- Contar ambulancias
  if ambulanceTable and type(ambulanceTable) == 'table' then
    ambulanceCount = #ambulanceTable
  end
  
  return policeCount + ambulanceCount
end)

-- Callback para contar jugadores por trabajo (para servicios)
lib.callback.register('AX_PauseMenu:GetServiciosCount', function(source)
  local servicios = {}
  
  -- Police
  local policeTable = exports['origen_police']:GetPlayersInDuty('police')
  if policeTable and type(policeTable) == 'table' then
    servicios['police'] = #policeTable
  else
    servicios['police'] = 0
  end
  
  -- Ambulance
  local ambulanceTable = exports['origen_police']:GetPlayersInDuty('ambulance')
  if ambulanceTable and type(ambulanceTable) == 'table' then
    servicios['ambulance'] = #ambulanceTable
  else
    servicios['ambulance'] = 0
  end
  
  -- Realestate cuenta manualmente
  local realestateCount = 0
  local players = ESX.GetExtendedPlayers()
  for _, xPlayer in pairs(players) do
    if xPlayer.job.name == 'realestate' then
      realestateCount = realestateCount + 1
    end
  end
  servicios['realestate'] = realestateCount
  
  return servicios
end)

-- Callback para contar jugadores por trabajo (para servicios)
lib.callback.register('AX_PauseMenu:GetServiciosCount', function(source)
  local servicios = {}
  
  -- Police y Ambulance usan origen_police export
  servicios['police'] = exports['origen_police']:GetPlayersInDuty('police') or 0
  servicios['ambulance'] = exports['origen_police']:GetPlayersInDuty('ambulance') or 0
  
  -- Realestate cuenta manualmente
  local realestateCount = 0
  local players = ESX.GetExtendedPlayers()
  for _, xPlayer in pairs(players) do
    if xPlayer.job.name == 'realestate' then
      realestateCount = realestateCount + 1
    end
  end
  servicios['realestate'] = realestateCount
  
  return servicios
end)

-- Callback para obtener todos los negocios
lib.callback.register('AX_PauseMenu:GetNegocios', function(source)
  local businesses = exports['AX_BusinessTab']:GetAllBusinesses()
  
  if not businesses then
    return {}
  end
  
  return businesses
end)

-- Log de inicio
print('^2[AX_PauseMenu]^7 Script iniciado correctamente para ESX 1.11.4')