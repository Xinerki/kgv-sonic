
RegisterServerEvent("kgv:sonic:ReportDeath")
AddEventHandler("kgv:sonic:ReportDeath", function()
	-- print(source, GetPlayerName(source), 'ded')
	TriggerClientEvent("kgv:sonic:SpawnRings", -1, source)
end)