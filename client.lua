function PlayDropSound(pos)
	-- PlaySoundFrontend(-1, 'Sonic_Drop_Rings', 'DLC_SONIC_SOUNDS', 1)
	-- local soundId = GetSoundId()
	-- PlaySoundFromCoord(soundId, "Sonic_Drop_Rings", pos.x, pos.y, pos.z, "DLC_SONIC_SOUNDS", 0, 0, 0)
	-- ReleaseSoundId(soundId)
    PlaySoundFromCoord(-1, "Sonic_Drop_Rings", pos.x, pos.y, pos.z, "DLC_SONIC_SOUNDS", 0, 0, 0)
end

function PlayPickSound()
	PlaySoundFrontend(-1, 'Sonic_Pick_Rings', 'DLC_SONIC_SOUNDS', 1)
	-- local soundId = GetSoundId()
	-- PlaySoundFromCoord(soundId, "Sonic_Pick_Rings", pos.x, pos.y, pos.z, "DLC_SONIC_SOUNDS", 0, 0, 0)
	-- ReleaseSoundId(soundId)
end

RequestScriptAudioBank('dlc_sonic/sonic')


function DrawSprite3D(textureDict, textureName, x, y, z, width, height, heading, red, green, blue, alpha)
    x += math.sin(math.rad(-heading-90.0)) * (width*0.5)
    y += math.cos(math.rad(-heading-90.0)) * (width*0.5)
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

function getVelocityPoint( posX, posY, posZ, pointX, pointY, pointZ, strength )
	local vectorX = posX-pointX
	local vectorY = posY-pointY
	local vectorZ = posZ-pointZ
	local length = ( vectorX^2 + vectorY^2 + vectorZ^2 )^0.5
	
	local propX = vectorX^2 / length^2
	local propY = vectorY^2 / length^2
	local propZ = vectorZ^2 / length^2
		
	local finalX = ( strength^2 * propX )^0.5
	local finalY = ( strength^2 * propY )^0.5
	local finalZ = ( strength^2 * propZ )^0.5
	
	if vectorX > 0 then finalX = finalX * -1 end
	if vectorY > 0 then finalY = finalY * -1 end
	if vectorZ > 0 then finalZ = finalZ * -1 end
	
	return finalX, finalY, finalZ
end

function CreateRing(pos, vel)
    CreateThread(function()
		Wait(math.random(0, 5) * 100)
		local spread = 0.5 + (math.random() * 0.5)
		local rot = math.random(0,360)
		local x = math.sin(math.rad(rot)) * 2.0 * spread
		local y = math.cos(math.rad(rot)) * 2.0 * spread
		local ring = {
			pos = pos + vector3(x*0.1, y*0.1, 0.0),
			life = {
				start = GetGameTimer(),
				duration = math.random(7, 10) * 1000,
			},
			size = 0.5,
			vel = vector3(x, y, 2.0 * spread) + (vel*0.25),
			picked = false
		}
        while GetGameTimer() < ring.life.start + ring.life.duration do Wait(0)
			
			-- PHYSICS
            if not ring.picked then
                ring.pos += ring.vel * GetFrameTime() * 2.0
            end
            ring.vel /= vector3(1.015, 1.015, 1.0)
            ring.vel -= vector3(0.0, 0.0, 0.1)
			
			local ringRadius = ring.size/2
			local ringOrigin = ring.pos + vector3(0.0, 0.0, ringRadius)
			
			local rayStart = ringOrigin
			
			local rayEnd = rayStart + vector3(-ringRadius, 0.0, 0.0)
            local ray = StartExpensiveSynchronousShapeTestLosProbe(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, -1, 0)
            local ret1, hit, _end, ret2, hitEnt = GetShapeTestResult(ray)
			hitL = hit ~= 0
			
			local rayEnd = rayStart + vector3(ringRadius, 0.0, 0.0)
            local ray = StartExpensiveSynchronousShapeTestLosProbe(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, -1, 0)
            local ret1, hit, _end, ret2, hitEnt = GetShapeTestResult(ray)
			hitR = hit ~= 0
			
			local rayEnd = rayStart + vector3(0.0, ringRadius, 0.0)
            local ray = StartExpensiveSynchronousShapeTestLosProbe(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, -1, 0)
            local ret1, hit, _end, ret2, hitEnt = GetShapeTestResult(ray)
			hitF = hit ~= 0
			
			local rayEnd = rayStart + vector3(0.0, -ringRadius, 0.0)
            local ray = StartExpensiveSynchronousShapeTestLosProbe(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, -1, 0)
            local ret1, hit, _end, ret2, hitEnt = GetShapeTestResult(ray)
			hitB = hit ~= 0
			
			local rayEnd = rayStart + vector3(0.0, 0.0, ringRadius)
            local ray = StartExpensiveSynchronousShapeTestLosProbe(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, -1, 0)
            local ret1, hit, _end, ret2, hitEnt = GetShapeTestResult(ray)
			hitU = hit ~= 0
			
			local rayEnd = rayStart + vector3(0.0, 0.0, -ringRadius)
            local ray = StartExpensiveSynchronousShapeTestLosProbe(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, -1, 0)
            local ret1, hit, _end, ret2, hitEnt = GetShapeTestResult(ray)
			hitD = hit ~= 0
			
			local hit = hitU or hitD or hitL or hitR or hitF or hitB
			
			-- DrawLine(ringOrigin, ringOrigin + vector3(ringRadius, 0.0, 0.0), 255, 0, 0, 255)
			-- DrawLine(ringOrigin, ringOrigin + vector3(-ringRadius, 0.0, 0.0), 255, 0, 0, 255)
			-- DrawLine(ringOrigin, ringOrigin + vector3(0.0, ringRadius, 0.0), 0, 255, 0, 255)
			-- DrawLine(ringOrigin, ringOrigin + vector3(0.0, -ringRadius, 0.0), 0, 255, 0, 255)
			-- DrawLine(ringOrigin, ringOrigin + vector3(0.0, 0.0, ringRadius), 0, 0, 255, 255)
			-- DrawLine(ringOrigin, ringOrigin + vector3(0.0, 0.0, -ringRadius), 0, 0, 255, 255)
			-- DrawMarker(28, ringOrigin, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ringRadius, ringRadius, ringRadius, 255, 255, 255, 50)
			
            -- if hit ~= 0 and _end ~= vector3(0,0,0) then
            if hit then
				local final = vector3((hitL or hitR) and -1.0 or 1.0, (hitF or hitB) and -1.0 or 1.0, (hitU or hitD) and -0.75 or 1.0)
				
				ring.vel *= final
			
				-- if #(rayStart - _end) < #ring.size/2 then
					-- ring.vel *= vector3(1.0, 1.0, -0.5)
					-- ring.vel *= -0.5
					-- ring.vel = getVelocityPoint(rayStart.x, rayStart.y, rayStart.z, _end.x, _end.y, _end.z, -#ring.vel)
					-- DrawLine(rayStart, _end, 0, 255, 0, 255)
				-- end
            end
			
			-- VISUAL
            DrawLightWithRange(ring.pos.x, ring.pos.y, ring.pos.z, 255, 255, 102, 2.0, 0.5)

			local tex = "ring"
            local bit = math.floor(((GetGameTimer() - ring.life.start) % 400)/100)+1
            if ring.picked then
                tex = "star"
            end
			
			DrawSprite3D("ring", tex..bit, ring.pos.x, ring.pos.y, ring.pos.z, ring.size, ring.size, GetFinalRenderedCamRot().z, 255, 255, 255, 255)

			-- DESPAWN
            if not IsEntityDead(PlayerPedId()) and not ring.picked and GetGameTimer() - ring.life.start > 500 and #(GetEntityCoords(PlayerPedId()) - ring.pos) < 1.0 then
                PlayPickSound()
                ring.picked = true
                ring.life.start = GetGameTimer()
                ring.life.duration = 500
                ring.vel = vector3(0.0, 0.0, 0.0)
            end
        end
    end)
end

RegisterNetEvent("kgv:sonic:SpawnRings")
AddEventHandler("kgv:sonic:SpawnRings", function(client)
	if client ~= -1 then
		local ped = GetPlayerPed(GetPlayerFromServerId(client))
		local pos = GetEntityCoords(ped)
		local vel = GetEntityVelocity(ped)
		for i=1,32 do
			CreateRing(pos, vel)
		end
	end
end)

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
                local vel = GetEntityVelocity(v)
				PlayDropSound(pos)
                for i=0,GetPedMoney(v) do
                    CreateRing(pos, vel)
                end
                Entity(v).state.ringed = true
            end
        end
    end
end)
