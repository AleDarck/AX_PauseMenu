let DISCORD_ID = null;

// Manejar mensajes adicionales
window.addEventListener('message', (event) => {
  let data = event.data;

  if (data.type === 'open') {
    showMenu();
    updateMenu(data.data);
  } else if (data.type === 'close') {
    hideMenu();
  } else if (data.type === 'update') {
    updateMenu(data.data);
  } else if (data.type === 'openExitModal') {
    document.getElementById('exit-modal').style.display = 'flex';
  } else if (data.type === 'openRobosModal') {
    openRobosModal(data.robos, data.normas, data.policiasOnDuty);
  }
})

// Modal Exit
document.getElementById('cambiar-personaje-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/cambiarPersonaje`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
  document.getElementById('exit-modal').style.display = 'none';
})

document.getElementById('salir-servidor-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/salirServidor`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
})

document.getElementById('cancelar-exit-btn').addEventListener('click', () => {
  document.getElementById('exit-modal').style.display = 'none';
})

// Modal Robos
function openRobosModal(robos, normas, policiasOnDuty) {
  const robosList = document.getElementById('robos-list');
  robosList.innerHTML = '';
  
  robos.forEach(robo => {
    const disponible = policiasOnDuty >= robo.policiasRequeridos;
    const roboItem = document.createElement('div');
    roboItem.className = `robo-item ${disponible ? 'disponible' : 'no-disponible'}`;
    
    roboItem.innerHTML = `
      <span class="robo-name">${robo.nombre}</span>
      <span class="robo-status ${disponible ? 'disponible' : 'no-disponible'}">
        ${disponible ? 'Disponible' : 'No Disponible'} (${policiasOnDuty}/${robo.policiasRequeridos})
      </span>
    `;
    
    robosList.appendChild(roboItem);
  });
  
  document.getElementById('normas-content').innerText = normas;
  document.getElementById('robos-modal').style.display = 'flex';
}

document.getElementById('close-robos-btn').addEventListener('click', () => {
  document.getElementById('robos-modal').style.display = 'none';
})

const updateMenu = (data) => {
  // Actualizar nombre del jugador
  document.getElementById('player-name').innerText = data.playerName || 'Desconocido';
  
  // Actualizar banco
  document.getElementById('text-bank').innerText = '$' + (data.bank || 0).toLocaleString();
  
  // Actualizar trabajo
  document.getElementById('job-name').innerText = data.playerJob || 'Desempleado';
  
  // Actualizar rango
  document.getElementById('job-rank').innerText = data.playerRank || 'Sin rango';
  
  // Actualizar ID
  document.getElementById('player-id').innerText = data.playerId || '0';
  
  // Actualizar Vicoins con formato
  document.getElementById('text-vicoin').innerText = (data.vicoins || 0).toLocaleString();
  
  // Actualizar usuarios online
  document.getElementById('online-players').innerText = data.onlinePlayers + '/' + data.maxPlayers;
  
  // Actualizar estadísticas (sin decimales)
  document.getElementById('stat-driving').innerText = Math.floor(data.skills?.driving || 0) + '%';
  document.getElementById('stat-shooting').innerText = Math.floor(data.skills?.shooting || 0) + '%';
  document.getElementById('stat-stamina').innerText = Math.floor(data.skills?.condition || 0) + '%';
  document.getElementById('stat-strength').innerText = Math.floor(data.skills?.strenght || 0) + '%';
  
  // Actualizar servicios
  if (data.servicios) {
    updateServicios(data.servicios);
  }
  
  // Actualizar negocios y servicios especiales
  if (data.negocios || data.serviciosEspeciales) {
    updateNegociosYServicios(data.negocios, data.serviciosEspeciales);
  }
}

// Nueva función combinada
function updateNegociosYServicios(negocios, serviciosEspeciales) {
  const negociosList = document.getElementById('negocios-list');
  negociosList.innerHTML = '';
  
  // Primero agregar servicios especiales (Taxi, etc)
  if (serviciosEspeciales && serviciosEspeciales.length > 0) {
    serviciosEspeciales.forEach(servicio => {
      if (servicio.mostrar) {
        const servicioCard = document.createElement('div');
        servicioCard.className = 'servicio-especial-card';
        
        servicioCard.innerHTML = `
          <img src="${servicio.icono}" class="servicio-especial-logo" alt="${servicio.nombre}" onerror="this.src='images/guest.png'">
          <div class="servicio-especial-nombre">${servicio.nombre}</div>
          <div class="servicio-especial-buttons">
            <div class="servicio-especial-btn btn-llamar" data-comando="${servicio.comandoLlamar}">
              <i class="fa-solid fa-phone"></i>
            </div>
            <div class="servicio-especial-btn btn-ubicacion" data-coords='${JSON.stringify(servicio.coords)}' data-nombre="${servicio.nombre}">
              <i class="fa-solid fa-location-dot"></i>
            </div>
          </div>
        `;
        
        negociosList.appendChild(servicioCard);
      }
    });
  }
  
  // Luego agregar negocios
  if (negocios && negocios.length > 0) {
    negocios.forEach(negocio => {
      const abierto = negocio.open || negocio.isOpen || false;
      const nombre = negocio.label || negocio.name || negocio.nombre || 'Sin nombre';
      const logo = negocio.logo || negocio.image || 'images/guest.png';
      const coords = negocio.coords || negocio.coordenadas || null;
      
      const negocioCard = document.createElement('div');
      negocioCard.className = `negocio-card ${abierto ? 'abierto' : 'cerrado'}`;
      
      negocioCard.innerHTML = `
        <img src="${logo}" class="negocio-logo" alt="${nombre}" onerror="this.src='images/guest.png'">
        <div class="negocio-nombre">${nombre}</div>
        <div class="negocio-ubicacion-btn" data-coords='${JSON.stringify(coords)}' data-nombre="${nombre}">
          <i class="fa-solid fa-location-dot"></i>
        </div>
      `;
      
      negociosList.appendChild(negocioCard);
    });
  }
  
  if ((!negocios || negocios.length === 0) && (!serviciosEspeciales || serviciosEspeciales.length === 0)) {
    negociosList.innerHTML = '<div style="text-align: center; opacity: 0.6; padding: 20px;">No hay servicios disponibles</div>';
  }
  
  // Event listeners para botones de llamar
  document.querySelectorAll('.btn-llamar').forEach(btn => {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      const comando = this.getAttribute('data-comando');
      
      fetch(`https://AX_PauseMenu/ejecutarComando`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ comando: comando })
      });
    });
  });
  
  // Event listeners para botones de ubicación (negocios y servicios especiales)
  document.querySelectorAll('.negocio-ubicacion-btn, .btn-ubicacion').forEach(btn => {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      const coordsStr = this.getAttribute('data-coords');
      const nombre = this.getAttribute('data-nombre');
      
      try {
        const coords = JSON.parse(coordsStr);
        
        if (coords && coords.x && coords.y) {
          fetch(`https://AX_PauseMenu/marcarNegocio`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ coords: coords, nombre: nombre })
          });
        }
      } catch(error) {
        console.error('Error al marcar ubicación:', error);
      }
    });
  });
}

// Función para actualizar negocios
function updateNegocios(negocios) {
  const negociosList = document.getElementById('negocios-list');
  negociosList.innerHTML = '';
  
  if (!negocios || negocios.length === 0) {
    negociosList.innerHTML = '<div style="text-align: center; opacity: 0.6; padding: 20px;">No hay negocios disponibles</div>';
    return;
  }
  
  negocios.forEach(negocio => {
    const abierto = negocio.open || negocio.isOpen || false;
    const nombre = negocio.label || negocio.name || negocio.nombre || 'Sin nombre';
    const logo = negocio.logo || negocio.image || 'images/guest.png';
    const coords = negocio.coords || negocio.coordenadas || null;
    
    const negocioCard = document.createElement('div');
    negocioCard.className = `negocio-card ${abierto ? 'abierto' : 'cerrado'}`;
    
    negocioCard.innerHTML = `
      <img src="${logo}" class="negocio-logo" alt="${nombre}" onerror="this.src='images/guest.png'">
      <div class="negocio-nombre">${nombre}</div>
      <div class="negocio-ubicacion-btn" data-coords='${JSON.stringify(coords)}' data-nombre="${nombre}">
        <i class="fa-solid fa-location-dot"></i>
      </div>
    `;
    
    negociosList.appendChild(negocioCard);
  });
  
  // Agregar event listeners a los botones de ubicación
  document.querySelectorAll('.negocio-ubicacion-btn').forEach(btn => {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      const coordsStr = this.getAttribute('data-coords');
      const nombre = this.getAttribute('data-nombre');
      
      try {
        const coords = JSON.parse(coordsStr);
        
        if (coords && coords.x && coords.y) {
          fetch(`https://AX_PauseMenu/marcarNegocio`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ coords: coords, nombre: nombre })
          });
        }
      } catch(error) {
        console.error('Error al marcar negocio:', error);
      }
    });
  });
}

function updateServicios(servicios) {
  const serviciosList = document.getElementById('servicios-list');
  serviciosList.innerHTML = '';
  
  const serviciosConfig = [
    { job: 'police', titulo: 'VCPD-POLICIA', icono: 'images/police.png', clase: 'police' },
    { job: 'ambulance', titulo: 'EMS-MEDICOS', icono: 'images/ems.png', clase: 'ambulance' },
    { job: 'taxi', titulo: 'TAXI-DOWNTOWN', icono: 'images/taxi.png', clase: 'taxi' }
  ];
  
  serviciosConfig.forEach(servicio => {
    const count = servicios[servicio.job] || 0;
    const disponible = count > 0;
    
    const servicioCard = document.createElement('div');
    servicioCard.className = `servicio-card ${servicio.clase}`;
    
    servicioCard.innerHTML = `
      <div class="servicio-card-content">
        <img src="${servicio.icono}" class="servicio-icon-img" alt="${servicio.titulo}">
        <div class="servicio-info">
          <div class="servicio-titulo">${servicio.titulo}</div>
          <div class="servicio-estado ${disponible ? 'disponible' : 'no-disponible'}">
            ${disponible ? 'Disponible: ' + count : 'No Disponible'}
          </div>
        </div>
      </div>
    `;
    
    serviciosList.appendChild(servicioCard);
  });
}

const hideMenu = () => {
  document.getElementById('page').style.display = 'none';
  document.getElementById('page').style.backgroundColor = 'transparent';
}

const showMenu = () => {
  document.getElementById('page').style.display = 'flex';
  document.getElementById('page').style.backgroundColor = 'rgba(17, 17, 17, 0.74)';
}

// Botón de ajustes
document.getElementById('settings-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/settings`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
  });
})

// Botón de mapa
document.getElementById('map-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/map`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
  });
})

// Botón de salir
document.getElementById('exit-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/exit`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
  });
})

// Botón SERVICIOS
document.getElementById('servicios-general-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/servicios`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
})

// Botón RACING
document.getElementById('racing-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/racing`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
})

// Botón REPORTAR
document.getElementById('reportar-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/report`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
})

// Botón DAILY
document.getElementById('daily-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/daily`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
})

// Botón ROCKSTAR EDITOR
document.getElementById('editor-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/editor`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
})

// Botón ROBOS
document.getElementById('robos-btn').addEventListener('click', () => {
  fetch(`https://AX_PauseMenu/robos`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
})

// Cerrar con ESC
document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') {
    // Cerrar modales si están abiertos
    const exitModal = document.getElementById('exit-modal');
    const robosModal = document.getElementById('robos-modal');
    
    if (exitModal.style.display === 'flex') {
      exitModal.style.display = 'none';
      return;
    }
    
    if (robosModal.style.display === 'flex') {
      robosModal.style.display = 'none';
      return;
    }
    
    // Si no hay modales abiertos, cerrar el pause menu
    hideMenu();
    fetch(`https://AX_PauseMenu/close`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    });
  }
})

// Inicialización
document.addEventListener('DOMContentLoaded', () => {
  fetch(`https://AX_PauseMenu/ready`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
  });
  getAvatar();
});

// Obtener avatar de Discord
async function getAvatar() {
  fetch(`https://AX_PauseMenu/GetDiscordAvatar`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
  }).then((res) => {
    res.json().then((data) => {
      let avatar = data.avatar;
      DISCORD_ID = data.discord_id;

      if (avatar && DISCORD_ID) {
        if (avatar.startsWith('a_')) {
          avatar = `https://cdn.discordapp.com/avatars/${DISCORD_ID}/${data.avatar}.gif`;
        } else {
          avatar = `https://cdn.discordapp.com/avatars/${DISCORD_ID}/${data.avatar}.png`;
        }
      } else {
        avatar = "images/esxLogo2.png";
      }
        
      document.getElementById('player-avatar').src = avatar;
    }).catch((error) => {
      console.log('Error al obtener avatar:', error);
      document.getElementById('player-avatar').src = "images/esxLogo2.png";
    });
  }).catch((error) => {
    console.log('Error en la petición de avatar:', error);
    document.getElementById('player-avatar').src = "images/esxLogo2.png";
  });
}