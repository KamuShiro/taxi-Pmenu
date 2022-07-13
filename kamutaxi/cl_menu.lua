ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
	    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	    Citizen.Wait(0)
    end  
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
    Citizen.Wait(5000)
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- FACTURE ----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

function OpenBillingMenu()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'facture',
        {
            title = 'Donner une facture'
        },
        function(data, menu)

            local amount = tonumber(data.value)

            if amount == nil or amount <= 0 then
                ESX.ShowNotification('Montant invalide')
            else
                menu.close()

                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 3.0 then
                    ESX.ShowNotification('Pas de joueurs proche')
                else
                    local playerPed        = PlayerPedId()

                    Citizen.CreateThread(function()
                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                        Citizen.Wait(5000)
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'LS Taxi', amount)
                        ESX.ShowNotification("~r~Vous avez bien envoyer la facture")
                    end)
                end
            end
        end,
        function(data, menu)
            menu.close()
    end)
end

local function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(10)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Menu F6 ----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local announce = {
    "Ouvert",
    "Fermer"
}

local menuf6 = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "MENU INTERACTION TAXI" },
    Data = { currentMenu = "Liste des actions :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
            local btn = btn.name
         
            if btn == "Facturation" then   
                OpenBillingMenu()
            elseif slide == 1 and btn == "Annonce" then
                TriggerServerEvent("taxi:ouvert")
            elseif slide == 2 and btn == "Annonce" then
                TriggerServerEvent("taxi:fermer")
            elseif btn == "Passer une annonce" then -- Marche si vous possèder le /twt
                CloseMenu()
                local msg = KeyboardInput("Ecrivez votre annonce", "", 100)
                ExecutCommand("twt " ..msg)
            end 
    end,
},
    Menu = {
        ["Liste des actions :"] = {
            b = {
                {name = "Annonce", slidemax = announce},
                {name = "Facturation", ask = '>>', askX = true},
                {name = "Passer une annonce", ask = '>>', askX = true},
            }
        }
    }
} 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(0,167) and PlayerData.job and PlayerData.job.name == 'taxi' then
			CreateMenu(menuf6)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Action boss ------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
local bossmenu = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Action patron" },
    Data = { currentMenu = "Liste des actions :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
            local btn = btn.name
         
            if btn == "Deposer de l'argent" then   
                local amount = KeyboardInput("Montant", "", 10)
                amount = tonumber(amount)
                if amount ~= nil then
                    ESX.ShowNotification('Montant invalide')
                else
                    TriggerServerEvent("esx_society:depositMoney", "taxi", amount)
                    ESX.ShownNotification('Vous avez deposer :' ..amount)
                end
            elseif btn == "Prendre de l'argent" then
                local amount = KeyboardInput("Montant", "", 10)
                amount = tonumber(amount)
                if amount ~= nil then
                    ESX.ShowNotification('Montant invalide')
                else
                    TriggerServerEvent("esx_society:withdrawMoney", "taxi", amount)
                    ESX.ShowNotification('Vous avez prit :' ..amount)
                end
            end 
    end,
},
    Menu = {
        ["Liste des actions :"] = {
            b = {
                {name = "Deposer de l'argent", ask = '>>', askX = true},
                {name = "Prendre de l'argent", ask = '>>', askX = true},
            }
        }
    }
}

local boss = {
    {x = 905.64, y = -164.13, z = 74.10}
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(boss) do
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, boss[k].x, boss[k].y, boss[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'taxi' and PlayerData.job.grade.name == "boss" then
                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_PICKUP~ pour accéder au action boss~s~")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(bossmenu)
         end end end end end)  

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Coffre entreprise ------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

function OpenGetStockspharmaMenu()
	ESX.TriggerServerCallback('taxi:prendreitem', function(items)
		local elements = {}

		for i=1, #items, 1 do
            table.insert(elements, {
                label = 'x' .. items[i].count .. ' ' .. items[i].label,
                value = items[i].name
            })
        end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'police',
			title    = 'stockage',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                css      = 'police',
				title = 'quantitÃ©'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantitÃ© invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('taxi:prendreitems', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStockspharmaMenu()
	ESX.TriggerServerCallback('taxi:inventairejoueur', function(inventory)
		local elements = {}

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

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'taxi',
			title    = 'inventaire',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
                css      = 'taxi',
				title = 'quantitÃ©'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantitÃ© invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('taxi:stockitem', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

         -----------------------------------------------------------------------------------------------------------------
---------------------------------------------- GARAGE -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local voiture = {
    Base = { Header = {"banner", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "GARAGE" },
    Data = { currentMenu = "Liste des vÃ©hicules :", "taxi"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Voiture de Fonction" then   
                spawnCar("taxi")
            elseif btn.name == "Voiture Patron" and PlayerData.job.grade_name  == 'boss' then
                spawnCar("baller")
            end 
    end,
},
    Menu = {
        ["Liste des vÃ©hicules :"] = {
            b = {
                {name = "Voiture de Fonction", ask = '>>', askX = true},
                {name = "Voiture Patron", ask = '>>', askX = true},
            }
        }
    }
} 


function spawnCar(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)   
    end


    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, 917.09, -170.55, 74.48, 97.13, true, false)   ---- spawn du vehicule (position)
    ESX.ShowNotification('~g~GarageÂ¦~s~\nVous avez sorti ~h~~y~un/une~s~ ~y~'..GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))..'')
    TriggerServerEvent('esx_vehiclelock:givekey', 'no', plate)
    SetEntityAsNoLongerNeeded(vehicle)
    SetVehicleNumberPlateText(vehicle, "taxi")





end 

local garagetaxi = { 
    {x=913.47, y=-161.95, z=74.62} -- Point pour sortir le vehicule
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(garagetaxi) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garagetaxi[k].x, garagetaxi[k].y, garagetaxi[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'taxi'  then
                DrawMarker(23, 913.47, -161.95, 74.62, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 0.9, 179, 229, 252, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour accÃ©der au ~y~Garage~s~")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(voiture)
         end end end end end)

-------------------------------------------------------- Suppression -------------------------------------------------------

local range = { 
    {x=898.88, y=-180.272, z=73.81} -- Suppression pos
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(range) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, range[k].x, range[k].y, range[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'taxi'  then
                DrawMarker(23, -711.69, 277.86, 83.28, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 0.9, 179, 229, 252, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour ranger ton ~y~Vehicule~s~")
                if IsControlJustPressed(1,38) then 			
                    TriggerEvent('esx:deleteVehicle')
         end end end end end)
       



         
-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- BLIPS -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


local blips = {
    {title="Taxi", colour=64, id=79, x = 894.56, y=-179.73, z=74.70},
}

Citizen.CreateThread(function()    
	Citizen.Wait(5000)    
  local bool = true     
  if bool then    
		 for _, info in pairs(blips) do      
			 info.blip = AddBlipForCoord(info.x, info.y, info.z)
						 SetBlipSprite(info.blip, info.id)
						 SetBlipDisplay(info.blip, 4)
						 SetBlipScale(info.blip, 0.7)
						 SetBlipColour(info.blip, info.colour)
						 SetBlipAsShortRange(info.blip, true)
						 BeginTextCommandSetBlipName("STRING")
						 AddTextComponentString(info.title)
						 EndTextCommandSetBlipName(info.blip)
		 end        
	 bool = false     
   end
end)



