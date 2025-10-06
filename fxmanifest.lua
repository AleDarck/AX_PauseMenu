fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'AXStudio'
description 'AX Pause Menu - ESX 1.11.4'
version '2.0.0'

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
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

dependencies {
  'es_extended',
  'oxmysql',
  'ox_lib'
}