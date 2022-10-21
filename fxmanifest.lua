fx_version 'cerulean'

game 'gta5'

author 'Horizon'

description 'Jacks laptop and hacking resource'

version '1.0.1'

shared_script {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
	'@PolyZone/CircleZone.lua'
}

server_script {
    'server/server.lua'
}
client_script {
    'client/client.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/styles/*.css',
	'html/js/*.js',
	'html/assets/*.png',
	'html/assets/*.jpg',
	'html/assets/shop/*.png',
	'html/assets/shop/*.jpg',
	'html/assets/*.svg',
	'html/assets/audio/*.mp3',
	'html/assets/audio/*.wav',
}

lua54 'yes'