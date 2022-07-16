
RegisterServerEvent("kgv:sonic:ReportDeath")
AddEventHandler("kgv:sonic:ReportDeath", function()
	TriggerClientEvent("kgv:sonic:SpawnRings", -1, source)
end)