-- ############################################### --
-- ## ██╗  ██╗███████╗██████╗ ███████╗██╗   ██╗ ## --
-- ## ██║ ██╔╝██╔════╝██╔══██╗██╔════╝██║   ██║ ## --
-- ## █████╔╝ █████╗  ██║  ██║█████╗  ██║   ██║ ## --
-- ## ██╔═██╗ ██╔══╝  ██║  ██║██╔══╝  ╚██╗ ██╔╝ ## --
-- ## ██║  ██╗██║     ██████╔╝███████╗ ╚████╔╝  ## --
-- ## ╚═╝  ╚═╝╚═╝     ╚═════╝ ╚══════╝  ╚═══╝   ## --
-- ## KF Pause Menu                             ## --
-- ## Developed by KFDev                        ## --
-- ## DISCORD:         https://discord.gg/kfdev ## --
-- ## TEBEX:           https://kfdev.tebex.io   ## --
-- ## DOCUMENATION:    https://docs.kfdev.it/   ## --
-- ############################################### --

Config = {}

-- [[ Framework ]] --
-- This is the framework you are using. 
-- This is used to determine some functions like Job fetching and more.
Config.Framework = 'esx' -- 'esx' or 'qbcore' (to work with qbox put 'qbcore')

-- [[ Discord Bot Token ]] --
-- This is required for image fetching from Discord API.
-- You can create a bot at https://discord.com/developers/applications
-- It's not needed to join the bot to your server, you just need the token.
Config.BotToken = '' -- Optional

-- [[ Pause Menu Tick ]] --
-- From my research the best value for performance is 5. Lower can alter the resmon up to 0.03ms
-- Higher value can cause the real gta v pause menu to open behind the custom one.
-- You can experiment with this value but I suggest to keep it around 3-5.
Config.PauseMenuTick = 5

-- [[ COMANDO ]]
Config.EnableCommand = true
Config.Command = 'pausemenu'
Config.EnableKeyMapping = true -- Solo funciona si EnableCommand es true
Config.KeyMapping = 'ESCAPE'

Config.ExitFunction = function(src)
  DropPlayer(src, 'Has salido del servidor.')
end


Config.DiscordLink = 'https://discord.gg/tu-servidor'
Config.RulesLink = 'https://docs.google.com/document/d/tu-documento-de-reglas'

-- [[ DATOS DEL JUGADOR ]] --

-- Obtener trabajo principal
Config.GetJob = function(src)
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return 'Desconocido' end
  
  local job = xPlayer.getJob()
  if not job then return 'Desempleado' end
  
  return job.label .. ' - ' .. job.grade_label
end

-- Obtener trabajo secundario (si tu servidor usa job2)
-- Por defecto está desactivado (nil)
-- Si tu ESX tiene job2, descomenta y configura esta función
Config.GetJob2 = nil
--[[
Config.GetJob2 = function(src)
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return nil end
  
  -- Ejemplo si tu ESX tiene job2
  local job2 = xPlayer.job2
  if not job2 or job2.name == 'unemployed' then
    return nil
  end
  
  return job2.label .. ' - ' .. job2.grade_label
end
]]

-- Obtener identificador del jugador
Config.GetPlayerIdentifier = function(src)
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return 'UNKNOWN' end
  
  -- Puedes usar el identifier completo o crear un ID personalizado
  -- Opción 1: Usar los últimos 8 caracteres del identifier
  local identifier = xPlayer.identifier
  return string.upper(string.sub(identifier, -8))
  
  -- Opción 2: Si tienes un sistema de Citizen ID personalizado en tu base de datos
  -- return MySQL.scalar.await('SELECT citizen_id FROM users WHERE identifier = ?', {identifier})
end

-- Obtener nombre del jugador
Config.GetPlayerName = function(src)
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return 'Desconocido' end
  
  return xPlayer.getName()
end