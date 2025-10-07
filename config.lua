Config = {}

Config.BotToken = 'MTE4MDY1NjA3NjAyNzMzMDYwMg.GtEntC.TP_rlG1XiQAXqQEX_2BFFDxt_zZ-G4TN203XPA' -- Opcional: Si está vacío, se mostrará imagen por defecto

Config.PauseMenuTick = 5

-- [[ COMANDO ]]
Config.EnableCommand = true
Config.Command = 'pausemenu'
Config.EnableKeyMapping = true -- Solo funciona si EnableCommand es true
Config.KeyMapping = 'ESCAPE'

Config.ExitFunction = function(src)
  DropPlayer(src, 'Has salido del servidor.')
end

-- [[ SERVICIOS DE EMERGENCIA ]] --
Config.ServiciosEmergencia = {'police', 'ambulance'}

-- [[ ROBOS DISPONIBLES ]] --
Config.Robos = {
  {
    nombre = 'BANCO CENTRAL',
    policiasRequeridos = 2
  },
  {
    nombre = 'JOYERÍA',
    policiasRequeridos = 3
  },
  {
    nombre = 'BANCO FLEECA',
    policiasRequeridos = 1
  },
  {
    nombre = 'PACIFIC STANDARD',
    policiasRequeridos = 4
  }
}

Config.NormasRobos = [[
- Respetar el cooldown entre robos
- Máximo 4 personas por robo
- No utilizar vehículos blindados
- Respetar el rol policial
- No combatir en zonas seguras
- Seguir las indicaciones del staff
]]

-- [[ SERVICIOS DISPONIBLES ]] --
Config.ServiciosInfo = {
  {
    job = 'police',
    titulo = 'VCPD-POLICIA',
    icono = 'images/police.png',
    clase = 'police'
  },
  {
    job = 'ambulance',
    titulo = 'EMS-MEDICOS',
    icono = 'images/ems.png',
    clase = 'ambulance'
  },
  {
    job = 'taxi',
    titulo = 'TAXI-DOWNTOWN',
    icono = 'images/taxi.png',
    clase = 'taxi'
  }
}

-- [[ SERVICIOS ESPECIALES (TAXI, ETC) ]] --
Config.ServiciosEspeciales = {
  {
    id = 'taxi',
    nombre = 'TAXI DOWNTOWN',
    icono = 'images/downtowncabco.png',
    comandoLlamar = 'solitaxi',
    coords = {x = 903.9229, y = -166.0759, z = 74.0921}, -- Coordenadas del taxi
    mostrar = true
  }
}

-- [[ IMAGEN POR DEFECTO PARA NEGOCIOS ]] --
Config.DefaultBusinessImage = 'images/guest.png'

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