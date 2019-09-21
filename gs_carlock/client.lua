ESX                           = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

end)
Citizen.CreateThread(function()
  local dict = "anim@mp_player_intmenu@key_fob@"
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Citizen.Wait(0)
  end
  while true do
    Citizen.Wait(0)
	if (IsControlJustPressed(1, Config.CarLock.ControlKey)) then
		local coords = GetEntityCoords(GetPlayerPed(-1))
		local hasAlreadyLocked = false
		cars = ESX.Game.GetVehiclesInArea(coords, 30)
		local carstrie = {}
		local cars_dist = {}		
		notowned = 0
		if #cars == 0 then
			ESX.ShowNotification(Config.CarLock.NotCarOwner)
		else
			for j=1, #cars, 1 do
				local coordscar = GetEntityCoords(cars[j])
				local distance = Vdist(coordscar.x, coordscar.y, coordscar.z, coords.x, coords.y, coords.z)
				table.insert(cars_dist, {cars[j], distance})
			end
			for k=1, #cars_dist, 1 do
				local z = -1
				local distance, car = 999
				for l=1, #cars_dist, 1 do
					if cars_dist[l][2] < distance then
						distance = cars_dist[l][2]
						car = cars_dist[l][1]
						z = l
					end
				end
				if z ~= -1 then
					table.remove(cars_dist, z)
					table.insert(carstrie, car)
				end
			end
			for i=1, #carstrie, 1 do
				local plate = ESX.Math.Trim(GetVehicleNumberPlateText(carstrie[i]))
				ESX.TriggerServerCallback('CarLock:isVehicleOwner', function(owner)
					if owner and hasAlreadyLocked ~= true then
						local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(carstrie[i]))
						vehicleLabel = GetLabelText(vehicleLabel)
						local lock = GetVehicleDoorLockStatus(carstrie[i])
						if lock == 1 or lock == 0 then
							SetVehicleDoorShut(carstrie[i], 0, false)
							SetVehicleDoorShut(carstrie[i], 1, false)
							SetVehicleDoorShut(carstrie[i], 2, false)
							SetVehicleDoorShut(carstrie[i], 3, false)
							SetVehicleDoorsLocked(carstrie[i], 2)
							PlayVehicleDoorCloseSound(carstrie[i], 1)
							
							showHelpNotification("~BLIP_134~ " .. Config.CarLock.CarLocked)
							if not IsPedInAnyVehicle(PlayerPedId(), true) then
								TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
							end
							if Config.CarLock.CarBleepOnOpen then
								TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carlock', Config.CarLock.CarBleepVolume) 
							end
							if Config.CarLock.BlinkingLighstON then
								Citizen.Wait(100)
								SetVehicleLights(carstrie[i], 2)
								Citizen.Wait(200)
								SetVehicleLights(carstrie[i], 1)
								Citizen.Wait(200)
								SetVehicleLights(carstrie[i], 2)
								Citizen.Wait(200)
								SetVehicleLights(carstrie[i], 1)
								Citizen.Wait(200)
								SetVehicleLights(carstrie[i], 2)
								Citizen.Wait(200)
								SetVehicleLights(carstrie[i], 0)
							end
							hasAlreadyLocked = true
						elseif lock == 2 then
							SetVehicleDoorsLocked(carstrie[i], 1)
							PlayVehicleDoorOpenSound(carstrie[i], 0)
							
							showHelpNotification("~BLIP_134~ " .. Config.CarLock.CarOpen)
							if not IsPedInAnyVehicle(PlayerPedId(), true) then
								TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
							end
							if Config.CarLock.CarBleepOnClose then
								TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carlock', Config.CarLock.CarBleepVolume)
							end 
							if Config.CarLock.BlinkingLighstON then
								SetVehicleLights(carstrie[i], 2)
								Citizen.Wait(100)
								SetVehicleLights(carstrie[i], 1)
								Citizen.Wait(100)
								SetVehicleLights(carstrie[i], 2)
								Citizen.Wait(100)
								SetVehicleLights(carstrie[i], 0)
							end
							hasAlreadyLocked = true
						end
					else
						notowned = notowned + 1
					end
					if notowned == #carstrie then
						showHelpNotification("~BLIP_INFO_ICON~ " .. Config.CarLock.NotCarOwner)
					end	
				end, plate)
			end			
		end
	end
  end
end)

Citizen.CreateThread(function()
	local ped = GetPlayerPed(-1)
	local vehFront = VehicleInFront()
	local vehCoord = GetEntityCoords(vehFront)
	local pedCoord = GetEntityCoords(ped)
	local distanceToVeh = GetDistanceBetweenCoords(pedCoord, vehCoord, 1)
	local lockStatus  = GetVehicleDoorLockStatus(vehFront)
    while true do
		Citizen.Wait(10)
		if Config.CarLock.TextBovenVoertuig then
			if distanceToVeh <= 10.0 then
				if not IsPedInAnyVehicle(ped, true) and not IsPedDeadOrDying(ped, 1) and not IsPlayerDead(ped) then
					if lockStatus == 1 then
						CarTextOpen(vehCoord.x, vehCoord.y, vehCoord.z -0.5, "Open", 4, 0.05, 0.05)
					else
						CarTextGesloten(vehCoord.x, vehCoord.y, vehCoord.z -0.5, "Gesloten", 4, 0.05, 0.05)
					end
				end
			end
		end
    end
end)

function CarTextOpen(x,y,z,textInput,fontId,scaleX,scaleY)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov   
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	SetTextColour(104, 234, 106, 0.8)
	SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(textInput)
	SetDrawOrigin(x,y,z+2, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end

function CarTextGesloten(x,y,z,textInput,fontId,scaleX,scaleY)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov   
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	SetTextColour(204, 0, 0, 0.8)
	SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(textInput)
	SetDrawOrigin(x,y,z+2, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end

function VehicleInFront()
    local vehicle, distance = ESX.Game.GetClosestVehicle()
    if vehicle ~= nil and distance < 3 then
        return vehicle
    else 
        return 0 
    end
end

Citizen.CreateThread(function()
  local resetSpeedOnEnter = true
  while true do
    Citizen.Wait(0)
    local playerPed = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerPed,false)
	if Config.CarLock.BegrenzerAAN then
		if GetPedInVehicleSeat(vehicle, -1) == playerPed and IsPedInAnyVehicle(playerPed, false) then
			
		if resetSpeedOnEnter then
			maxSpeed = GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
			SetEntityMaxSpeed(vehicle, maxSpeed)
			resetSpeedOnEnter = false
		end
		-- Zet Begrenzer UIT
		if IsControlJustReleased(0,Config.CarLock.BegrenzerKey) and IsControlPressed(0,131) then
			maxSpeed = GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
			SetEntityMaxSpeed(vehicle, maxSpeed)
			showHelpNotification("~BLIP_12~ Begrenzer ~b~uitgeschakeld", 2000)
		-- Zet Begrenzer AAN
		elseif IsControlJustReleased(0,Config.CarLock.BegrenzerKey) then
			cruise = GetEntitySpeed(vehicle)
			SetEntityMaxSpeed(vehicle, cruise)
			cruise = math.floor(cruise * 3.6 + 0.5)
			showHelpNotification("~BLIP_11~ Begrenzer staat op ~b~"..cruise.."~w~ km/h", 4000)
		end
		else
		resetSpeedOnEnter = true
		end
	end
  end
end)

function showHelpNotification(msg,time)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
	DrawSubtitleTimed(time, 1)
end