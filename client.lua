function PlayDropSound(pos)
	-- PlaySoundFrontend(-1, 'Sonic_Drop_Rings', 'DLC_SONIC_SOUNDS', 1)
	local soundId = GetSoundId()
	PlaySoundFromCoord(soundId, "Sonic_Drop_Rings", pos.x, pos.y, pos.z, "DLC_SONIC_SOUNDS", 0, 0, 0)
	ReleaseSoundId(soundId)
end

function PlayPickSound()
	PlaySoundFrontend(-1, 'Sonic_Pick_Rings', 'DLC_SONIC_SOUNDS', 1)
	-- local soundId = GetSoundId()
	-- PlaySoundFromCoord(soundId, "Sonic_Pick_Rings", pos.x, pos.y, pos.z, "DLC_SONIC_SOUNDS", 0, 0, 0)
	-- ReleaseSoundId(soundId)
end

RequestScriptAudioBank('dlc_sonic/sonic', 0)

function DrawSprite3D(textureDict, textureName, x, y, z, width, height, heading, red, green, blue, alpha)
    x = x + math.sin(math.rad(-heading-90.0)) * (width*0.5)
    y = y + math.cos(math.rad(-heading-90.0)) * (width*0.5)
    --z = z -0.5

    local offX = math.sin(math.rad(-heading+90)) * width
    local offY = math.cos(math.rad(-heading+90)) * width

    DrawSpritePoly(
        x+offX, y+offY, z, -- bottom right
        x, y, z+height, -- top left
        x, y, z, -- bottom left
        red, green, blue, alpha,
        textureDict,
        textureName,
        1.0, 0.0, 0.0,
        0.0, -1.0, 0.0,
        0.0, 0.0, 1.0)
        
    DrawSpritePoly(
        x, y, z+height, -- top left
        x+offX, y+offY, z, -- bottom right
        x+offX, y+offY, z+height, -- top right
        red, green, blue, alpha,
        textureDict,
        textureName,
        -1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0)
end

RequestStreamedTextureDict("ring")

function CreateRing(pos, vel)
    local spread = 0.5 + (math.random() * 0.5)
    local rot = math.random(0,360)
    local x = math.sin(math.rad(rot)) * 2.0 * spread
    local y = math.cos(math.rad(rot)) * 2.0 * spread
    local ring = {
        pos = pos + vector3(x*0.1, y*0.1, 0.0),
        life = {
            start = GetGameTimer(),
            duration = 10000,
        },
        size = vector2(0.5, 0.5),
        vel = vector3(x, y, 2.0 * spread) + (vel*0.25),
        picked = false
    }

    CreateThread(function()
        while GetGameTimer() < ring.life.start + ring.life.duration do Wait(0)
            if not ring.picked then
                ring.pos = ring.pos + ring.vel * GetFrameTime() * 4.0
            end
            ring.vel = ring.vel / vector3(1.015, 1.015, 1.0)
            ring.vel = ring.vel - vector3(0.0, 0.0, 0.1)

            local ray = StartExpensiveSynchronousShapeTestLosProbe(ring.pos.x, ring.pos.y, ring.pos.z, ring.pos.x, ring.pos.y, ring.pos.z - (ring.size.y/2), -1, -1, 0)
            local ret1, hit, _end, ret2, hitEnt = GetShapeTestResult(ray)

            hit = _end ~= vector3(0,0,0)

            if hit and ring.vel.z < 0.0 then 
                ring.vel = ring.vel * vector3(1.0, 1.0, -0.5)
                --DrawLine(ring.pos.x, ring.pos.y, ring.pos.z, ring.pos.x, ring.pos.y, ring.pos.z - (ring.size.y/2), 255, 255, 255, 255)
            end
			
            DrawLightWithRange(ring.pos.x, ring.pos.y, ring.pos.z, 255, 255, 102, 2.0, 0.5)

            local bit = math.floor((GetGameTimer() % 400)/100)+1
            if ring.picked then
                DrawSprite3D("ring", "star"..bit, ring.pos.x, ring.pos.y, ring.pos.z, ring.size.x, ring.size.y, GetFinalRenderedCamRot().z, 255, 255, 255, 255)
            else
                DrawSprite3D("ring", "ring"..bit, ring.pos.x, ring.pos.y, ring.pos.z, ring.size.x, ring.size.y, GetFinalRenderedCamRot().z, 255, 255, 255, 255)
            end

            if not IsEntityDead(PlayerPedId()) and not ring.picked and GetGameTimer() - ring.life.start > 500 and #(GetEntityCoords(PlayerPedId()) - ring.pos) < 1.0 then
                PlayPickSound()
                ring.picked = true
                ring.life.start = GetGameTimer()
                ring.life.duration = 500
                ring.vel = vector3(0.0, 0.0, 0.0)
                --exports["money"]:GiveMoney(1)
            end
        end
    end)
end

RegisterNetEvent("kgv:sonic:SpawnRings")
AddEventHandler("kgv:sonic:SpawnRings", function(client)
	local ped = GetPlayerPed(GetPlayerFromServerId(client))
	local pos = GetEntityCoords(ped)
	local vel = GetEntityVelocity(ped)
	for i=1,32 do
		CreateRing(pos, vel)
	end
end)

-- RegisterNetEvent('respawn:clKillMessage')
-- AddEventHandler("respawn:clKillMessage", function(killer, victim)
	-- local ped = GetPlayerPed(GetPlayerFromServerId(victim))
	-- local pos = GetEntityCoords(ped)
	-- local vel = GetEntityVelocity(ped)
	-- for i=1,32 do
		-- CreateRing(pos, vel)
	-- end
-- end)

CreateThread(function()
	while true do Wait(0)
		repeat Wait(0) until IsEntityDead(PlayerPedId())
		TriggerServerEvent("kgv:sonic:ReportDeath")
		repeat Wait(0) until not IsEntityDead(PlayerPedId())
	end
end)

CreateThread(function()
    while true do Wait(0)
        local pool = GetGamePool("CPed")
        for i,v in pairs(pool) do
            if not IsPedAPlayer(v) and IsEntityDead(v) and not Entity(v).state.ringed then
			Wait(100)
				local pos = GetEntityCoords(v)
				PlayDropSound(pos)
                for i=0,GetPedMoney(v) do
                    CreateRing(pos, GetEntityVelocity(v))
                end
                Entity(v).state.ringed = true
            end
        end
    end
end)
