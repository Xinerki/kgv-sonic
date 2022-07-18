fx_version 'adamant'
game 'gta5'

name 'kgv-sonic'
description 'Sonic rings spewing out of any ex-living being.'

author 'mollyesbian - idea'
author 'Xinerki - making it a reality'
author 'Theodorito - all the mindless tasks'

server_script 'server.lua'
client_script 'client.lua'

files {
	'data/dlcsonic_sounds.dat54.rel',
	'dlc_sonic/sonic.awc',
}

data_file 'AUDIO_WAVEPACK' 'dlc_sonic'
data_file 'AUDIO_SOUNDDATA' 'data/dlcsonic_sounds.dat'

lua54 'on'
use_fxv2_oal 'ye'