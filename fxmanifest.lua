fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
description 'A RedM framework'
author 'VORP' -- converted from the original C# vorp core by goncalobsccosta#9041

shared_scripts {
	'config.lua',
	'shared/customExports.lua',
	'translation/language.lua',
}

client_scripts {
	'client/ref/*.lua',
	'client/exports/*.lua',
	'client/coreactions.lua',
	'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/class/*.lua',
	'config/commands.lua',
	'server/*lua',
	'server/services/dbupdater/*.lua',
}

files {
	'ui/**/*',
}

ui_page 'ui/index.html'

version '2.4'
vorp_checker 'yes'
vorp_name '^4Resource version Check^3'
vorp_github 'https://github.com/VORPCORE/vorp-core-lua'


dependencies {
	'/onesync',
	'oxmysql',
	'/server:6231', -- there are new natives that only work on newer builds of redm
}
