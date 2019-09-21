ESX               = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
print('^5DGSNL^1 gs_CarLock^7 Is Geladen...^1 v1.03 ^7(Script By DJS)')
ESX.RegisterServerCallback('CarLock:isVehicleOwner', function(source, cb, plate)
	local identifier = GetPlayerIdentifier(source, 0)

	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
		['@owner'] = identifier,
		['@plate'] = plate
	}, function(result)
		if result[1] then
			cb(result[1].owner == identifier)
		else
			cb(false)
		end
	end)
end)