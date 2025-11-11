Config = {}

Config.BotToken = '' -- Opcional: Si está vacío, se mostrará imagen por defecto

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
    nombre = 'ROBO ATMs',
    policiasRequeridos = 3
  },
  {
    nombre = 'BADULAKES',
    policiasRequeridos = 3
  },
  {
    nombre = 'BANCO PEQUEÑO',
    policiasRequeridos = 5
  },
  {
    nombre = 'JOYERIA',
    policiasRequeridos = 5
  },
  {
    nombre = 'MAZE BANK',
    policiasRequeridos = 8
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

Config.NormasFacturas = [[
- Las facturas deben pagarse en un plazo máximo establecido.
- El impago de facturas puede resultar en sanciones adicionales.
- Puedes pagar las facturas directamente desde este menú.
- El dinero se tomará automáticamente de tu cuenta bancaria.
- Si no tienes fondos suficientes, no podrás pagar la factura.
- Contacta con la facción correspondiente si hay algún error.
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
  },
  {
    job = 'dynasty8',
    titulo = 'DYNASTY 8',
    icono = 'images/dynasty8.png',
    clase = 'dynasty8'
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