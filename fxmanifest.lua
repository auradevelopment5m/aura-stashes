fx_version 'cerulean'
game 'gta5'

name 'aura-stashes'
author 'v0'
version '1.0.0'
description 'A stash creation system with multi-framework support'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'modules/shared/*.lua'
}

client_scripts {
  'bridge/client/*.lua',
  'modules/client/*.lua',
  'client/*.lua'
}

server_scripts {
  'bridge/server/*.lua',
  'modules/server/*.lua',
  'server/*.lua'
}

ui_page 'ui/index.html'

files {
  'ui/index.html',
  'ui/styles.css',
  'ui/app.js'
}

lua54 'yes'
