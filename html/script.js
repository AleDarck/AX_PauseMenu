let DISCORD_ID = null;

window.addEventListener('message', (event) => {
  let data = event.data;

  if (data.type === 'open') {
    showMenu();
    updateMenu(data.data);
  } else if (data.type === 'close') {
    hideMenu();
  } else if (data.type === 'update') {
    updateMenu(data.data);
  }
})

const updateMenu = (data) => {
  // Actualizar nombre del jugador
  document.getElementById('player-name').innerText = data.playerName || 'Desconocido';
  
  // Actualizar trabajo principal
  const job1Text = data.playerJob || 'Desempleado';
  document.getElementById('job1name').innerText = job1Text;
  
  // Actualizar trabajo secundario si existe
  if (data.playerJob2 && data.playerJob2 !== 'Unemployed - Unemployed' && data.playerJob2 !== 'Desempleado - Desempleado') {
    document.getElementById('job2').style.display = 'flex';
    document.getElementById('job2name').innerText = data.playerJob2;
  } else {
    document.getElementById('job2').style.display = 'none';
  }
  
  // Actualizar Citizen ID
  document.getElementById('citizen-id').innerText = data.citizenId || 'UNKNOWN';
  
  // Actualizar link de Discord en el footer
  if (data.discordLink) {
    document.getElementById('last-login').innerText = data.discordLink;
  }
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

// Cerrar con ESC
document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') {
    hideMenu();
    fetch(`https://AX_PauseMenu/close`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
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
        avatar = "images/guest.png";
      }
        
      document.getElementById('player-avatar').src = avatar;
    }).catch((error) => {
      console.log('Error al obtener avatar:', error);
      document.getElementById('player-avatar').src = "images/guest.png";
    });
  }).catch((error) => {
    console.log('Error en la petición de avatar:', error);
    document.getElementById('player-avatar').src = "images/guest.png";
  });
}