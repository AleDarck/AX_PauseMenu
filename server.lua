ESX = exports["es_extended"]:getSharedObject()
-- Verificar que ESX esté cargado
if not ESX then
  print('^1[ERROR] AX_PauseMenu: ESX no está cargado. Verifica que es_extended esté iniciado antes que este script.^7')
  return
end

-- Callback para obtener datos del jugador
lib.callback.register('AX_PauseMenu:GetPlayerData', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  
  if not xPlayer then
    print('^1[ERROR] AX_PauseMenu: No se pudo obtener xPlayer para el jugador ' .. source .. '^7')
    return nil
  end

  local playerData = {
    playerJob = Config.GetJob and Config.GetJob(source) or 'Desempleado',
    playerJob2 = Config.GetJob2 and Config.GetJob2(source) or nil,
    playerName = Config.GetPlayerName and Config.GetPlayerName(source) or xPlayer.getName(),
    citizenId = Config.GetPlayerIdentifier and Config.GetPlayerIdentifier(source) or 'UNKNOWN',
    onlinePlayers = #ESX.GetExtendedPlayers(),
    discordLink = Config.DiscordLink or 'https://discord.gg/ejemplo',
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

-- Log de inicio
print('^2[AX_PauseMenu]^7 Script iniciado correctamente para ESX 1.11.4')