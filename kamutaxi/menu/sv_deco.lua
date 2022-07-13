ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
TriggerEvent('esx_society:registerSociety', 'taxi', 'taxi', 'society_taxi', 'society_taxi', 'society_taxi', {type = 'public'})

RegisterServerEvent('taxi:ouvert')
AddEventHandler('taxi:ouvert', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'LS Taxi', '~b~Annonce', 'Le LS Taxi est ouvert !', 'CHAR_TAXI', 8)
	end
end)

RegisterServerEvent('taxi:fermer')
AddEventHandler('taxi:fermer', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'LS Taxi', '~b~Annonce', 'Le LS Taxi est fermer revenez plus tard !', 'CHAR_TAXI', 8)
	end
end)

RegisterNetEvent('taxi:stockitem')
AddEventHandler('taxi:stockitem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, "~y~Objet dÃ©posÃ© "..count..""..inventoryItem.label.."")
		else
			TriggerClientEvent('esx:showNotification', _source, "~r~quantitÃ© invalide")
		end
	end)
end)


ESX.RegisterServerCallback('taxi:inventairejoueur', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

ESX.RegisterServerCallback('taxi:prendreitem', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
		cb(inventory.items)
	end)
end)

-------------------- Stock

RegisterNetEvent('prendre:vodka')
AddEventHandler('prendre:vodka', function()

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = 0
    local xMoney = xPlayer.getMoney()

    if xMoney >= price then

        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem('vodka', 1)
    else
    end
end)
