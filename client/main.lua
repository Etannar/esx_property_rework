local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX                           = nil
local OwnedProperties         = {}
local Blips                   = {}
local CurrentProperty         = nil
local CurrentPropertyOwner    = nil
local LastProperty            = nil
local LastPart                = nil
local HasAlreadyEnteredMarker = false
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local FirstSpawn              = true
local HasChest                = false
local ownedPropertyName		  = nil
local setProperties			  = false
local playerSpawn			  = false
local ServerOwnedProperties   = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.TriggerServerCallback('esx_property:getProperties', function(properties)
		Config.Properties = properties
		--CreateBlips()
	end)
	playerSpawn = true
	
	--ESX.TriggerServerCallback('esx_property:getOwnedProperties', function(ownedProperties)
	--	for i=1, #ownedProperties, 1 do
	--		SetPropertyOwned(ownedProperties[i], true)
	--	end
	--end)
end)

-- only used when script is restarting mid-session
RegisterNetEvent('esx_property:sendProperties')
AddEventHandler('esx_property:sendProperties', function(properties)
	Config.Properties = properties
	--CreateBlips()

	ESX.TriggerServerCallback('esx_property:getOwnedProperties', function(ownedProperties)
		for i=1, #ownedProperties, 1 do
			SetPropertyOwned(ownedProperties[i], true)
		end
	end)
end)

function DrawSub(text, time)
	ClearPrints()
	SetTextEntry_2('STRING')
	AddTextComponentString(text)
	DrawSubtitleTimed(time, 1)
end

function CreateBlips()
	for i=1, #Config.Properties, 1 do
		local property = Config.Properties[i]

		if property.entering then
			Blips[property.name] = AddBlipForCoord(property.entering.x, property.entering.y, property.entering.z)

			SetBlipSprite (Blips[property.name], 369)
			SetBlipDisplay(Blips[property.name], 4)
			SetBlipScale  (Blips[property.name], 1.0)
			SetBlipAsShortRange(Blips[property.name], true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('free_prop'))
			EndTextCommandSetBlipName(Blips[property.name])
		end
	end
end

function GetProperties()
	return Config.Properties
end

function GetProperty(name)
	for i=1, #Config.Properties, 1 do
		if Config.Properties[i].name == name then
			return Config.Properties[i]
		end
	end
end

function GetGateway(property)
	for i=1, #Config.Properties, 1 do
		local property2 = Config.Properties[i]

		if property2.isGateway and property2.name == property.gateway then
			return property2
		end
	end
end

function GetGatewayProperties(property)
	local properties = {}

	for i=1, #Config.Properties, 1 do
		if Config.Properties[i].gateway == property.name then
			table.insert(properties, Config.Properties[i])
		end
	end

	return properties
end

function EnterProperty(name, owner)
	local property       = GetProperty(name)
	local playerPed      = PlayerPedId()
	CurrentProperty      = property
	CurrentPropertyOwner = owner

	for i=1, #Config.Properties, 1 do
		if Config.Properties[i].name ~= name then
			Config.Properties[i].disabled = true
		end
	end

	TriggerServerEvent('esx_property:saveLastProperty', name)

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		for i=1, #property.ipls, 1 do
			RequestIpl(property.ipls[i])

			while not IsIplActive(property.ipls[i]) do
				Citizen.Wait(0)
			end
		end

		SetEntityCoords(playerPed, property.inside.x, property.inside.y, property.inside.z)
		DoScreenFadeIn(800)
		DrawSub(property.label, 5000)
	end)

end

function ExitProperty(name)
	local property  = GetProperty(name)
	local playerPed = PlayerPedId()
	local outside   = nil
	CurrentProperty = nil

	if property.isSingle then
		outside = property.outside
	else
		outside = GetGateway(property).outside
	end

	TriggerServerEvent('esx_property:deleteLastProperty')

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		SetEntityCoords(playerPed, outside.x, outside.y, outside.z)

		for i=1, #property.ipls, 1 do
			RemoveIpl(property.ipls[i])
		end

		for i=1, #Config.Properties, 1 do
			Config.Properties[i].disabled = false
		end

		DoScreenFadeIn(800)
	end)
end

function SetPropertyOwned(name, owned)
	local property     = GetProperty(name)
	local entering     = nil
	local enteringName = nil

	if property.isSingle then
		entering     = property.entering
		enteringName = property.name
	else
		local gateway = GetGateway(property)
		entering      = gateway.entering
		enteringName  = gateway.name
	end

	if owned then

		OwnedProperties[name] = true
		RemoveBlip(Blips[enteringName])

		Blips[enteringName] = AddBlipForCoord(entering.x, entering.y, entering.z)
		SetBlipSprite(Blips[enteringName], 357)
		SetBlipAsShortRange(Blips[enteringName], true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('property'))
		EndTextCommandSetBlipName(Blips[enteringName])

	else

		OwnedProperties[name] = nil
		local found = false

		for k,v in pairs(OwnedProperties) do
			local _property = GetProperty(k)
			local _gateway  = GetGateway(_property)

			if _gateway then
				if _gateway.name == enteringName then
					found = true
					break
				end
			end
		end

		if not found then
			RemoveBlip(Blips[enteringName])
		end
	end
end

function PropertyIsOwned(property)
	if ServerOwnedProperties[property.name] == true then
		return true
	end
	return false
end

function PropertyIsOwnedUser(property)
	if OwnedProperties[property.name] == true then
		return true
	end
	return false
end

function GarageIsOwnedUser(property)
	if OwnedProperties[property] == true then
		return true
	end
	return false
end

function OpenPropertyMenu(property)
	local elements = {}

	if PropertyIsOwned(property) then
		table.insert(elements, {label = _U('enter'), value = 'enter'})

		if not Config.EnablePlayerManagement then
			table.insert(elements, {label = _U('leave'), value = 'leave'})
		end
	else
		if not Config.EnablePlayerManagement then
			table.insert(elements, {label = _U('buy'), value = 'buy'})
			table.insert(elements, {label = _U('rent'), value = 'rent'})
		end

		table.insert(elements, {label = _U('visit'), value = 'visit'})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'property',
	{
		title    = property.label,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		menu.close()

		if data.current.value == 'enter' then
			--TriggerEvent('instance:create', 'property', {property = property.name, owner = ESX.GetPlayerData().identifier})
		elseif data.current.value == 'leave' then
			OwnedProperties[property.name] = false
			ServerOwnedProperties[property.name] = false
			TriggerServerEvent('esx_property:removeOwnedProperty', property.name)
		elseif data.current.value == 'buy' then
			TriggerServerEvent('esx_property:buyProperty', property.name)
		elseif data.current.value == 'rent' then
			TriggerServerEvent('esx_property:rentProperty', property.name)
		--elseif data.current.value == 'visit' then
			--TriggerEvent('instance:create', 'property', {property = property.name, owner = ESX.GetPlayerData().identifier})
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'property_menu'
		CurrentActionMsg  = _U('press_to_menu')
		CurrentActionData = {property = property}
	end)
end

function OpenGatewayMenu(property)
	if Config.EnablePlayerManagement then
		OpenGatewayOwnedPropertiesMenu(gatewayProperties)
	else

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gateway',
		{
			title    = property.name,
			align    = 'top-left',
			elements = {
				{label = _U('owned_properties'),    value = 'owned_properties'},
				{label = _U('available_properties'), value = 'available_properties'}
			}
		}, function(data, menu)
			if data.current.value == 'owned_properties' then
				OpenGatewayOwnedPropertiesMenu(property)
			elseif data.current.value == 'available_properties' then
				OpenGatewayAvailablePropertiesMenu(property)
			end
		end, function(data, menu)
			menu.close()

			CurrentAction     = 'gateway_menu'
			CurrentActionMsg  = _U('press_to_menu')
			CurrentActionData = {property = property}
		end)

	end
end

function OpenGatewayOwnedPropertiesMenu(property)
	local gatewayProperties = GetGatewayProperties(property)
	local elements          = {}

	for i=1, #gatewayProperties, 1 do
		if PropertyIsOwnedUser(gatewayProperties[i]) then
			table.insert(elements, {
				label = gatewayProperties[i].label,
				value = gatewayProperties[i].name
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gateway_owned_properties',
	{
		title    = property.name .. ' - ' .. _U('owned_properties'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		menu.close()

		local elements = {
			{label = _U('enter'), value = 'enter'}
		}

		if not Config.EnablePlayerManagement then
			table.insert(elements, {label = _U('leave'), value = 'leave'})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gateway_owned_properties_actions',
		{
			title    = data.current.label,
			align    = 'top-left',
			elements = elements
		}, function(data2, menu2)
			menu2.close()

			if data2.current.value == 'enter' then
				--TriggerEvent('instance:create', 'property', {property = data.current.value, owner = ESX.GetPlayerData().identifier})
				local prop = data.current.value
				local owner = ESX.GetPlayerData().identifier
				displayCloset(prop, owner)
				ESX.UI.Menu.CloseAll()
			elseif data2.current.value == 'leave' then
				OwnedProperties[data.current.value] = false
				ServerOwnedProperties[data.current.value] = false
				TriggerServerEvent('esx_property:removeOwnedProperty', data.current.value)
			end
		end, function(data2, menu2)
			menu2.close()
		end)

	end, function(data, menu)
		menu.close()
	end)
end

function displayCloset(property, owner)
	
	--local isOwned = true
	--HasChest = true
	ownedPropertyName = property
end

function OpenGatewayAvailablePropertiesMenu(property)
	local gatewayProperties = GetGatewayProperties(property)
	local elements          = {}

	for i=1, #gatewayProperties, 1 do
		if not PropertyIsOwned(gatewayProperties[i]) then
			table.insert(elements, {
				label = gatewayProperties[i].label .. ' $' .. ESX.Math.GroupDigits(gatewayProperties[i].price),
				value = gatewayProperties[i].name,
				price = gatewayProperties[i].price
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gateway_available_properties',
	{
		title    = property.name .. ' - ' .. _U('available_properties'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gateway_available_properties_actions',
		{
			title    = property.label .. ' - ' .. _U('available_properties'),
			align    = 'top-left',
			elements = {
				{label = _U('buy'), value = 'buy'},
				{label = _U('rent'), value = 'rent'},
				{label = _U('visit'), value = 'visit'}
			}
		}, function(data2, menu2)
			menu2.close()

			if data2.current.value == 'buy' then
				TriggerServerEvent('esx_property:buyProperty', data.current.value)
			elseif data2.current.value == 'rent' then
				TriggerServerEvent('esx_property:rentProperty', data.current.value)
			elseif data2.current.value == 'visit' then
				--TriggerEvent('instance:create', 'property', {property = data.current.value, owner = ESX.GetPlayerData().identifier})
			end
		end, function(data2, menu2)
			menu2.close()
		end)

	end, function(data, menu)
		menu.close()
	end)
end

function OpenRoomMenu(property, owner)
	local entering = nil
	local elements = {}

	if property.isSingle then
		entering = property.entering
	else
		entering = GetGateway(property).entering
	end

	--table.insert(elements, {label = _U('invite_player'),  value = 'invite_player'})

	if CurrentPropertyOwner == owner then
		table.insert(elements, {label = _U('player_clothes'), value = 'player_dressing'})
		table.insert(elements, {label = _U('remove_cloth'), value = 'remove_cloth'})
	end

	table.insert(elements, {label = _U('remove_object'),  value = 'room_inventory'})
	table.insert(elements, {label = _U('deposit_object'), value = 'player_inventory'})

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room',
	{
		title    = property.label,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'invite_player' then

			local playersInArea = ESX.Game.GetPlayersInArea(entering, 10.0)
			local elements      = {}

			for i=1, #playersInArea, 1 do
				if playersInArea[i] ~= PlayerId() then
					table.insert(elements, {label = GetPlayerName(playersInArea[i]), value = playersInArea[i]})
				end
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room_invite',
			{
				title    = property.label .. ' - ' .. _U('invite'),
				align    = 'top-left',
				elements = elements,
			}, function(data2, menu2)
				--TriggerEvent('instance:invite', 'property', GetPlayerServerId(data2.current.value), {property = property.name, owner = owner})
				ESX.ShowNotification(_U('you_invited', GetPlayerName(data2.current.value)))
			end, function(data2, menu2)
				menu2.close()
			end)

		elseif data.current.value == 'player_dressing' then

			ESX.TriggerServerCallback('esx_property:getPlayerDressing', function(dressing)
				local elements = {}

				for i=1, #dressing, 1 do
					table.insert(elements, {
						label = dressing[i],
						value = i
					})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing',
				{
					title    = property.label .. ' - ' .. _U('player_clothes'),
					align    = 'top-left',
					elements = elements
				}, function(data2, menu2)

					TriggerEvent('skinchanger:getSkin', function(skin)
						ESX.TriggerServerCallback('esx_property:getPlayerOutfit', function(clothes)
							TriggerEvent('skinchanger:loadClothes', skin, clothes)
							TriggerEvent('esx_skin:setLastSkin', skin)

							TriggerEvent('skinchanger:getSkin', function(skin)
								TriggerServerEvent('esx_skin:save', skin)
							end)
						end, data2.current.value)
					end)

				end, function(data2, menu2)
					menu2.close()
				end)
			end)

		elseif data.current.value == 'remove_cloth' then

			ESX.TriggerServerCallback('esx_property:getPlayerDressing', function(dressing)
				local elements = {}

				for i=1, #dressing, 1 do
					table.insert(elements, {
						label = dressing[i],
						value = i
					})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove_cloth', {
					title    = property.label .. ' - ' .. _U('remove_cloth'),
					align    = 'top-left',
					elements = elements
				}, function(data2, menu2)
					menu2.close()
					TriggerServerEvent('esx_property:removeOutfit', data2.current.value)
					ESX.ShowNotification(_U('removed_cloth'))
				end, function(data2, menu2)
					menu2.close()
				end)
			end)

		elseif data.current.value == 'room_inventory' then
			OpenRoomInventoryMenu(property, owner)
		elseif data.current.value == 'player_inventory' then
			OpenPlayerInventoryMenu(property, owner)
		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'room_menu'
		CurrentActionMsg  = _U('press_to_menu')
		CurrentActionData = {property = property, owner = owner}
	end)
end

function OpenRoomInventoryMenu(property, owner)

	ESX.TriggerServerCallback('esx_property:getPropertyInventory', function(inventory)

		local elements = {}

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = ESX.GetWeaponLabel(weapon.name) .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room_inventory',
		{
			title    = property.label .. ' - ' .. _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)

			if data.current.type == 'item_weapon' then

				menu.close()

				TriggerServerEvent('esx_property:getItem', owner, data.current.type, data.current.value, data.current.ammo)
				ESX.SetTimeout(300, function()
					OpenRoomInventoryMenu(property, owner)
				end)

			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'get_item_count', {
					title = _U('amount')
				}, function(data2, menu)

					local quantity = tonumber(data2.value)
					if quantity == nil then
						ESX.ShowNotification(_U('amount_invalid'))
					else
						menu.close()

						TriggerServerEvent('esx_property:getItem', owner, data.current.type, data.current.value, quantity)
						ESX.SetTimeout(300, function()
							OpenRoomInventoryMenu(property, owner)
						end)
					end

				end, function(data2,menu)
					menu.close()
				end)

			end

		end, function(data, menu)
			menu.close()
		end)

	end, owner)

end

function OpenPlayerInventoryMenu(property, owner)

	ESX.TriggerServerCallback('esx_property:getPlayerInventory', function(inventory)

		local elements = {}

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type  = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type  = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = weapon.label .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_inventory',
		{
			title    = property.label .. ' - ' .. _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)

			if data.current.type == 'item_weapon' then

				menu.close()
				TriggerServerEvent('esx_property:putItem', owner, 'item_weapon', data.current.value, data.current.ammo)

				ESX.SetTimeout(300, function()
					OpenPlayerInventoryMenu(property, owner)
				end)

			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_count', {
					title = _U('amount')
				}, function(data2, menu2)

					local quantity = tonumber(data2.value)

					if quantity == nil then
						ESX.ShowNotification(_U('amount_invalid'))
					else

						menu2.close()

						TriggerServerEvent('esx_property:putItem', owner, 'item_standard', data.current.value, tonumber(data2.value))
						ESX.SetTimeout(300, function()
							OpenPlayerInventoryMenu(property, owner)
						end)
					end

				end, function(data2, menu2)
					menu2.close()
				end)

			end

		end, function(data, menu)
			menu.close()
		end)

	end)

end

AddEventHandler('playerSpawned', function()
	if FirstSpawn then

		Citizen.CreateThread(function()

			while not ESX.IsPlayerLoaded() do
				Citizen.Wait(0)
			end

			ESX.TriggerServerCallback('esx_property:getLastProperty', function(propertyName)
				if propertyName then
					if propertyName ~= '' then
						local property = GetProperty(propertyName)

						for i=1, #property.ipls, 1 do
							RequestIpl(property.ipls[i])
				
							while not IsIplActive(property.ipls[i]) do
								Citizen.Wait(0)
							end
						end

						--TriggerEvent('instance:create', 'property', {property = propertyName, owner = ESX.GetPlayerData().identifier})
					end
				end
			end)
		end)

		FirstSpawn = false
	end
end)

AddEventHandler('esx_property:getProperties', function(cb)
	cb(GetProperties())
end)

AddEventHandler('esx_property:getProperty', function(name, cb)
	cb(GetProperty(name))
end)

AddEventHandler('esx_property:getGateway', function(property, cb)
	cb(GetGateway(property))
end)

RegisterNetEvent('esx_property:setPropertyOwned')
AddEventHandler('esx_property:setPropertyOwned', function(name, owned)
	SetPropertyOwned(name, owned)
end)

RegisterNetEvent('esx_property:setServerPropertyOwned')
AddEventHandler('esx_property:setServerPropertyOwned', function(name, owned)
	ServerOwnedProperties[name] = true
	--SetServerPropertyOwned(name, owned)
end)

AddEventHandler('esx_property:hasEnteredMarker', function(name, part)
	local property = GetProperty(name)

	if part == 'entering' then
		if property.isSingle then
			CurrentAction     = 'property_menu'
			CurrentActionMsg  = _U('press_to_menu')
			CurrentActionData = {property = property}
		else
			CurrentAction     = 'gateway_menu'
			CurrentActionMsg  = _U('press_to_menu')
			CurrentActionData = {property = property}
		end
	elseif part == 'exit' then
		CurrentAction     = 'room_exit'
		CurrentActionMsg  = _U('press_to_exit')
		CurrentActionData = {propertyName = name}
	elseif part == 'roomMenu' then
		CurrentAction     = 'room_menu'
		CurrentActionMsg  = _U('press_to_menu')
		CurrentActionData = {property = property, owner = CurrentPropertyOwner}
	end
end)

AddEventHandler('esx_property:hasExitedMarker', function(name, part)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

-- Enter / Exit marker events & Draw markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep = false, true
		local currentProperty, currentPart

		for i=1, #Config.Properties, 1 do
			local property = Config.Properties[i]

			-- Entering
			if property.entering and not property.disabled then
				local distance = GetDistanceBetweenCoords(coords, property.entering.x, property.entering.y, property.entering.z, true)

				if distance < Config.DrawDistance then
					DrawMarker(Config.MarkerType, property.entering.x, property.entering.y, property.entering.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
					letSleep = false
				end

				if distance < Config.MarkerSize.x then
					isInMarker      = true
					currentProperty = property.name
					currentPart     = 'entering'
				end
			end

			-- Exit
			if property.exit and not property.disabled then
				local distance = GetDistanceBetweenCoords(coords, property.exit.x, property.exit.y, property.exit.z, true)

				if distance < Config.DrawDistance then
					DrawMarker(Config.MarkerType, property.exit.x, property.exit.y, property.exit.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
					letSleep = false
				end

				if distance < Config.MarkerSize.x then
					isInMarker      = true
					currentProperty = property.name
					currentPart     = 'exit'
				end
			end

			-- Room menu
			if property.roomMenu and PropertyIsOwnedUser(property) then
				local distance = GetDistanceBetweenCoords(coords, property.roomMenu.x, property.roomMenu.y, property.roomMenu.z, true)

				if distance < Config.DrawDistance then
					local z = tonumber(property.roomMenu.z) + 0.05
					DrawMarker(Config.MarkerType, property.roomMenu.x, property.roomMenu.y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.RoomMenuMarkerColor.r, Config.RoomMenuMarkerColor.g, Config.RoomMenuMarkerColor.b, 100, false, true, 2, false, nil, nil, false)
					letSleep = false
				end

				if distance < Config.MarkerSize.x then
					isInMarker      = true
					currentProperty = property.name
					currentPart     = 'roomMenu'
				end
			end
		end

		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastProperty ~= currentProperty or LastPart ~= currentPart) ) then
			HasAlreadyEnteredMarker = true
			LastProperty            = currentProperty
			LastPart                = currentPart

			TriggerEvent('esx_property:hasEnteredMarker', currentProperty, currentPart)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_property:hasExitedMarker', LastProperty, LastPart)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) then

				if CurrentAction == 'property_menu' then
					OpenPropertyMenu(CurrentActionData.property)
				elseif CurrentAction == 'gateway_menu' then
					if Config.EnablePlayerManagement then
						OpenGatewayOwnedPropertiesMenu(CurrentActionData.property)
					else
						OpenGatewayMenu(CurrentActionData.property)
					end
				elseif CurrentAction == 'room_menu' then
					OpenRoomMenu(CurrentActionData.property, CurrentActionData.owner)
				elseif CurrentAction == 'room_exit' then
					--TriggerEvent('instance:leave')
					--HasChest = false
					ownedPropertyName = nil
				end
				if CurrentAction == 'spawn' then
					OpenMenuGarage('spawn')
				end
				if CurrentAction == 'delete' then
					OpenMenuGarage('delete')
				end

				CurrentAction = nil

			end
		else
			if setProperties == false and playerSpawn == true then
				setProperties = true
				playerSpawn = false
				TriggerServerEvent('esx_property:getOwnedProperties', GetPlayerPed(-1))
				--TriggerServerEvent('esx_property:getServerOwnedProperties', GetPlayerPed(-1))
			end
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		TriggerServerEvent('esx_property:getServerOwnedProperties', GetPlayerPed(-1))
		Citizen.Wait(60000)
	end
end)

--[[

Private Garage Section

]]--

function privateBlips(zoneValues)


local blip = AddBlipForCoord(zoneValues.Pos.x, zoneValues.Pos.y, zoneValues.Pos.z)
SetBlipSprite (blip, Config.BlipInfos.Sprite)
SetBlipDisplay(blip, 4)
SetBlipScale  (blip, 1.2)
SetBlipColour (blip, Config.BlipInfos.Color)
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString('Private Garage')
EndTextCommandSetBlipName(blip)

end

function OpenMenuGarage(PointType)

	ESX.UI.Menu.CloseAll()

	local elements = {}

	if PointType == 'spawn' then
		table.insert(elements,{label = "List of vehicles", value = 'list_vehicles'})
	end

	if PointType == 'delete' then
		table.insert(elements,{label = "Store your vehicle", value = 'stock_vehicle'})
	end

	if PointType == 'pound' then
		table.insert(elements,{label = "Pay $100 to get vehicle", value = 'return_vehicle'})
	end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'garage_menu',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'list_vehicles') then
				ListVehiclesMenu()
			end
			if(data.current.value == 'stock_vehicle') then
				StockVehicleMenu()
			end
			if(data.current.value == 'return_vehicle') then
				ReturnVehicleMenu()
			end

			local playerPed = GetPlayerPed(-1)
			SpawnVehicle(data.current.value)

		end,
		function(data, menu)
			menu.close()
			
		end
	)	
end
	
function ListVehiclesMenu()
	local elements = {}

	ESX.TriggerServerCallback('esx_property_garage:getVehicles', function(vehicles)

		for _,v in pairs(vehicles) do

			local hashVehicule = v.vehicle.model
    		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
    		local labelvehicle
			local plate = v.plate

    		if(v.state)then
    		labelvehicle = vehicleName.. ' (' .. plate .. '): Garage'
    		else
    		labelvehicle = vehicleName.. ' (' .. plate .. '): Impounded'
    		end	
			table.insert(elements, {label =labelvehicle , value = v})
			
		end
		local c = 0
		for _,a in pairs(vehicles) do
			if (a.state) then
				c = c + 1
			else
				c = c - 1
			end
		end

	
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			if(data.current.value.state)then
				menu.close()
				if c > 0 then
					SpawnVehicle(data.current.value.vehicle, data.current.value.plate)
					SetVehicleFuelLevel(data.current.vehicle, 90.0)
				else
					TriggerEvent('esx:showNotification', 'You already took out a vehicle!')
				end
			else
				TriggerEvent('esx:showNotification', 'Vehicle stored')
			end
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
	)	
	end)
end

function reparation(prix,vehicle,vehicleProps)
	
	ESX.UI.Menu.CloseAll()

	local elements = {
		{label = "Fix the vehicle for ($"..prix..")", value = 'yes'},
		{label = "Call a mechanic", value = 'no'},
	}
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'delete_menu',
		{
			title    = 'Damaged Vehicle',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'yes') then
				TriggerServerEvent('esx_property_garage:payhealth', prix)
				ranger(vehicle,vehicleProps)
			end
			if(data.current.value == 'no') then
				ESX.ShowNotification('See a mechanic')
			end

		end,
		function(data, menu)
			menu.close()
			
		end
	)	
end

function ranger(vehicle,vehicleProps)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('esx_property_garage:modifystate', vehicleProps.plate, true)
	TriggerEvent('esx:showNotification', 'Your vehicle is in the garage')
end

function StockVehicleMenu()
	local playerPed  = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed,  false) then

		local playerPed = GetPlayerPed(-1)
    	local coords    = GetEntityCoords(playerPed)
    	local vehicle = GetVehiclePedIsIn(playerPed,false)     
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local current 	    = GetPlayersLastVehicle(GetPlayerPed(-1), true)
		local engineHealth  = GetVehicleEngineHealth(current)
		local plate = vehicleProps.plate

		ESX.TriggerServerCallback('esx_property_garage:stockv',function(valid)

			if (valid) then
				TriggerServerEvent('esx_property_garage:debug', vehicle)
				if engineHealth < 990 then
				local fraisRep= 600		      
				reparation(fraisRep,vehicle,vehicleProps)
			else
				ranger(vehicle,vehicleProps)
				end	
			else
				TriggerEvent('esx:showNotification', 'You cannot store this vehicle')
			end
		end,vehicleProps)
	else
		TriggerEvent('esx:showNotification', 'No vehicle to store')
	end

end

function SpawnVehicle(vehicle, plate)

	ESX.Game.SpawnVehicle(vehicle.model,{
		x=this_Garage.SpawnPoint.Pos.x ,
		y=this_Garage.SpawnPoint.Pos.y,
		z=this_Garage.SpawnPoint.Pos.z + 1											
		},this_Garage.SpawnPoint.Heading, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		SetVehRadioStation(callback_vehicle, "OFF")
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		end)
		

	TriggerServerEvent('esx_property_garage:modifystate', plate, false)

end

function SpawnPoundedVehicle(vehicle, plate)

	ESX.Game.SpawnVehicle(vehicle.model, {
		x = this_Garage.SpawnMunicipalPoundPoint.Pos.x ,
		y = this_Garage.SpawnMunicipalPoundPoint.Pos.y,
		z = this_Garage.SpawnMunicipalPoundPoint.Pos.z + 1											
		},180, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		end)
	TriggerServerEvent('esx_property_garage:modifystate', plate, true)

	ESX.SetTimeout(10000, function()
		TriggerServerEvent('esx_property_garage:modifystate', plate, false)
	end)

end

AddEventHandler('esx_property_garage:hasEnteredMarker', function(zone)

	if zone == 'spawn' then
		CurrentAction     = 'spawn'
		CurrentActionMsg  = "Press ~INPUT_PICKUP~ to take out vehicle"
		CurrentActionData = {}
	end

	if zone == 'delete' then
		CurrentAction     = 'delete'
		CurrentActionMsg  = "Press ~INPUT_PICKUP~ to store the vehicle"
		CurrentActionData = {}
	end
	
	if zone == 'pound' then
		CurrentAction     = 'pound_action_menu'
		CurrentActionMsg  = "Press ~INPUT_PICKUP~ to access impound"
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_property_garage:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

function ReturnVehicleMenu()

	ESX.TriggerServerCallback('esx_property_garage:getOutVehicles', function(vehicles)

		local elements = {}

		for _,v in pairs(vehicles) do

			local hashVehicule = v.model
    		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
    		local labelvehicle

    		labelvehicle = vehicleName..': Resume'
    	
			table.insert(elements, {label =labelvehicle , value = v})
			
		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'return_vehicle',
		{
			title    = 'Garage',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
	
			ESX.TriggerServerCallback('esx_property_garage:checkMoney', function(hasEnoughMoney)
				if hasEnoughMoney then
					
					if times == 0 then
						TriggerServerEvent('esx_property_garage:pay')
						SpawnPoundedVehicle(data.current.value, data.current.value.plate)
						times=times+1
					elseif times > 0 then
						ESX.SetTimeout(60000, function()
						times=0
						end)
					end
				else
					ESX.ShowNotification('You require more money')						
				end
			end)
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
		)	
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)		
		local coords = GetEntityCoords(GetPlayerPed(-1))			

		for k,v in pairs(Config.Garages) do
			if GarageIsOwnedUser(v.House) then 
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then		
					DrawMarker(v.SpawnPoint.Marker, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.SpawnPoint.Size.x, v.SpawnPoint.Size.y, v.SpawnPoint.Size.z, v.SpawnPoint.Color.r, v.SpawnPoint.Color.g, v.SpawnPoint.Color.b, 100, false, true, 2, false, false, false, false)	
					DrawMarker(v.DeletePoint.Marker, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.DeletePoint.Size.x, v.DeletePoint.Size.y, v.DeletePoint.Size.z, v.DeletePoint.Color.r, v.DeletePoint.Color.g, v.DeletePoint.Color.b, 100, false, true, 2, false, false, false, false)	
				end
			end
		end	
	end
end)

Citizen.CreateThread(function()
	local currentZone = 'garage'
	while true do

		Citizen.Wait(0)

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false
		

		for _,v in pairs(Config.Garages) do
			if GarageIsOwnedUser(v.House) then
				
				if(GetDistanceBetweenCoords(coords, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					this_Garage = v
					currentZone = 'spawn'
				end

				if(GetDistanceBetweenCoords(coords, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					this_Garage = v
					currentZone = 'delete'
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_property_garage:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_property_garage:hasExitedMarker', LastZone)
		end

	end
end)

