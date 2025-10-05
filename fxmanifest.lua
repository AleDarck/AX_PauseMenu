fx_version 'cerulean'
games { 'gta5' }

author 'AXStudio'
description 'Pause Menu'

version '1.2.0'

lua54 'yes'

client_scripts {
  'client.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'server.lua'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

files {
  'html/index.html',
  'html/style.css',
  'html/script.js',
  'html/images/*.png',
  'html/images/*.jpg',
  'html/images/*.gif',
}

ui_page 'html/index.html'