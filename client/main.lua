local QBCore = exports['qb-core']:GetCoreObject()

local piggyBackInProgress      = false
local carryingBackInProgress   = false
local isCarry                  = false
local hasRope                  = true
local IsLiftup                 = false
local holdingHostage           = false
local holdingHostageInProgress = false
local beingHeldHostage         = false
local canTakeHostage           = false
local foundWeapon              = nil

local hostageAllowedWeapons = {
	"WEAPON_PISTOL",
	"WEAPON_PISTOL50",
}

-- Rope inventory responses

RegisterNetEvent('qb_carry:client:trueRope', function()
	hasRope = true
end)

RegisterNetEvent('qb_carry:client:falseRope', function()
	hasRope = false
end)

-- Helper functions

function GetPlayers()
	local players = {}
	for i = 0, 255 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end
	return players
end

function GetClosestPlayer(radius)
	local players       = GetPlayers()
	local closestDist   = -1
	local closestPlayer = nil
	local ply           = GetPlayerPed(-1)
	local plyCoords     = GetEntityCoords(ply, 0)

	for _, value in ipairs(players) do
		local target = GetPlayerPed(value)
		if target ~= ply then
			local targetCoords = GetEntityCoords(target, 0)
			local distance = GetDistanceBetweenCoords(
				targetCoords['x'], targetCoords['y'], targetCoords['z'],
				plyCoords['x'],    plyCoords['y'],    plyCoords['z'], true)
			if closestDist == -1 or closestDist > distance then
				closestPlayer = value
				closestDist   = distance
			end
		end
	end

	if closestDist ~= -1 and closestDist <= radius then
		return closestPlayer
	end
	return nil
end

function DrawText3D(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	if onScreen then
		SetTextScale(0.19, 0.19)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 55)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x, _y)
	end
end

function LoadAnimationDictionary(animDict)
	while not HasAnimDictLoaded(animDict) do
		RequestAnimDict(animDict)
		Citizen.Wait(1)
	end
end

-- Action functions

function DragAction()
	TriggerServerEvent('qb_carry:server:checkRope')
	QBCore.Functions.Notify('You are lifting this person up...', 'primary')
	local closestPlayer = GetClosestPlayer(3)
	if closestPlayer ~= nil then
		TriggerServerEvent('qb_carry:server:lyfteruppn', GetPlayerServerId(closestPlayer))
	end
	Citizen.Wait(1000)
	if hasRope then
		local dict = "anim@heists@box_carry@"
		LoadAnimationDictionary(dict)
		local nearest = GetClosestPlayer(3)
		if nearest ~= nil then
			local plyCoords    = GetEntityCoords(GetPlayerPed(-1), 0)
			local targetCoords = GetEntityCoords(GetPlayerPed(nearest), 0)
			local distance = GetDistanceBetweenCoords(
				targetCoords['x'], targetCoords['y'], targetCoords['z'],
				plyCoords['x'],    plyCoords['y'],    plyCoords['z'], true)
			if distance <= 3.0 then
				TriggerServerEvent('qb_carry:server:lyfter', GetPlayerServerId(nearest))
				TaskPlayAnim(GetPlayerPed(-1), dict, "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
				isCarry = true
			else
				QBCore.Functions.Notify("No one is nearby...", 'error')
			end
		else
			QBCore.Functions.Notify("No one is nearby...", 'error')
		end
	end
end

function PiggyBackAction()
	if not piggyBackInProgress then
		piggyBackInProgress  = true
		local lib            = 'anim@arena@celeb@flat@paired@no_props@'
		local anim1          = 'piggyback_c_player_a'
		local anim2          = 'piggyback_c_player_b'
		local distans        = -0.07
		local distans2       = 0.0
		local height         = 0.45
		local spin           = 0.0
		local length         = 100000
		local controlFlagMe  = 49
		local controlFlagTgt = 33
		local animFlagTgt    = 1
		local nearest        = GetClosestPlayer(3)
		if nearest ~= nil then
			local target = GetPlayerServerId(nearest)
			TriggerServerEvent('qb_carry:server:sync', nearest, lib, anim1, anim2, distans, distans2, height, target, length, spin, controlFlagMe, controlFlagTgt, animFlagTgt)
		else
			piggyBackInProgress = false
			QBCore.Functions.Notify("No one is nearby...", 'error')
		end
	else
		piggyBackInProgress = false
		IsLiftup = false
		ClearPedSecondaryTask(GetPlayerPed(-1))
		DetachEntity(GetPlayerPed(-1), true, false)
		local nearest = GetClosestPlayer(3)
		if nearest ~= nil then
			TriggerServerEvent("qb_carry:server:stop", GetPlayerServerId(nearest))
		end
	end
end

function CarryAction()
	if not carryingBackInProgress then
		carryingBackInProgress = true
		local lib            = 'missfinale_c2mcs_1'
		local anim1          = 'fin_c2_mcs_1_camman'
		local lib2           = 'nm'
		local anim2          = 'firemans_carry'
		local distans        = 0.15
		local distans2       = 0.27
		local height         = 0.63
		local spin           = 0.0
		local length         = 100000
		local controlFlagMe  = 49
		local controlFlagTgt = 33
		local animFlagTgt    = 1
		local nearest        = GetClosestPlayer(3)
		if nearest ~= nil then
			local target = GetPlayerServerId(nearest)
			TriggerServerEvent('cmg2_animations:sync', nearest, lib, lib2, anim1, anim2, distans, distans2, height, target, length, spin, controlFlagMe, controlFlagTgt, animFlagTgt)
		else
			carryingBackInProgress = false
			QBCore.Functions.Notify("No one is nearby...", 'error')
		end
	else
		carryingBackInProgress = false
		ClearPedSecondaryTask(GetPlayerPed(-1))
		DetachEntity(GetPlayerPed(-1), true, false)
		local nearest = GetClosestPlayer(3)
		if nearest ~= nil then
			TriggerServerEvent("cmg2_animations:stop", GetPlayerServerId(nearest))
		end
	end
end

function TakeHostageAction()
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
	canTakeHostage = false
	foundWeapon    = nil
	for i = 1, #hostageAllowedWeapons do
		if HasPedGotWeapon(GetPlayerPed(-1), GetHashKey(hostageAllowedWeapons[i]), false) then
			canTakeHostage = true
			foundWeapon    = GetHashKey(hostageAllowedWeapons[i])
			break
		end
	end
	if not holdingHostageInProgress and canTakeHostage then
		local lib            = 'anim@gangops@hostage@'
		local anim1          = 'perp_idle'
		local lib2           = 'anim@gangops@hostage@'
		local anim2          = 'victim_idle'
		local distans        = 0.11
		local distans2       = -0.24
		local height         = 0.0
		local spin           = 0.0
		local length         = 100000
		local controlFlagMe  = 49
		local controlFlagTgt = 49
		local animFlagTgt    = 50
		local attachFlag     = true
		local nearest        = GetClosestPlayer(2)
		if nearest ~= nil then
			local target = GetPlayerServerId(nearest)
			SetCurrentPedWeapon(GetPlayerPed(-1), foundWeapon, true)
			holdingHostageInProgress = true
			holdingHostage           = true
			TriggerServerEvent('cmg3_animations:sync', nearest, lib, lib2, anim1, anim2, distans, distans2, height, target, length, spin, controlFlagMe, controlFlagTgt, animFlagTgt, attachFlag)
		else
			QBCore.Functions.Notify("No one nearby to take as hostage!", 'error')
		end
	end
end

function releaseHostage()
	local lib            = 'reaction@shove'
	local anim1          = 'shove_var_a'
	local lib2           = 'reaction@shove'
	local anim2          = 'shoved_back'
	local distans        = 0.11
	local distans2       = -0.24
	local height         = 0.0
	local spin           = 0.0
	local length         = 100000
	local controlFlagMe  = 120
	local controlFlagTgt = 0
	local animFlagTgt    = 1
	local attachFlag     = false
	local nearest        = GetClosestPlayer(2)
	if nearest ~= nil then
		local target = GetPlayerServerId(nearest)
		TriggerServerEvent('cmg3_animations:sync', nearest, lib, lib2, anim1, anim2, distans, distans2, height, target, length, spin, controlFlagMe, controlFlagTgt, animFlagTgt, attachFlag)
	end
end

function killHostage()
	local lib            = 'anim@gangops@hostage@'
	local anim1          = 'perp_fail'
	local lib2           = 'anim@gangops@hostage@'
	local anim2          = 'victim_fail'
	local distans        = 0.11
	local distans2       = -0.24
	local height         = 0.0
	local spin           = 0.0
	local length         = 0.2
	local controlFlagMe  = 168
	local controlFlagTgt = 0
	local animFlagTgt    = 1
	local attachFlag     = false
	local nearest        = GetClosestPlayer(2)
	if nearest ~= nil then
		local target = GetPlayerServerId(nearest)
		TriggerServerEvent('cmg3_animations:sync', nearest, lib, lib2, anim1, anim2, distans, distans2, height, target, length, spin, controlFlagMe, controlFlagTgt, animFlagTgt, attachFlag)
	end
end

-- Open carrying menu (qb-menu)

function OpenCarryMenu()
	exports['qb-menu']:openMenu({
		{
			header       = "4 Carrying Types",
			isMenuHeader = true,
		},
		{
			header = "Drag",
			txt    = "Drag the closest player",
			params = { event = "qb_carry:client:menuDrag" },
		},
		{
			header = "PiggyBack",
			txt    = "Piggyback the closest player",
			params = { event = "qb_carry:client:menuPiggyBack" },
		},
		{
			header = "Carry",
			txt    = "Carry the closest player (fireman carry)",
			params = { event = "qb_carry:client:menuCarry" },
		},
		{
			header = "Take Hostage",
			txt    = "Take the closest player hostage (requires a pistol)",
			params = { event = "qb_carry:client:menuTakeHostage" },
		},
	})
end

-- Menu item event handlers
RegisterNetEvent('qb_carry:client:menuDrag',        function() DragAction()        end)
RegisterNetEvent('qb_carry:client:menuPiggyBack',   function() PiggyBackAction()   end)
RegisterNetEvent('qb_carry:client:menuCarry',       function() CarryAction()       end)
RegisterNetEvent('qb_carry:client:menuTakeHostage', function() TakeHostageAction() end)

-- Network events received by this client

-- Drag: target receives this to attach + play idle animation
RegisterNetEvent('qb_carry:client:upplyft', function(target)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	local lPed      = GetPlayerPed(-1)
	if not isCarry then
		LoadAnimationDictionary("amb@code_human_in_car_idles@generic@ps@base")
		TaskPlayAnim(lPed, "amb@code_human_in_car_idles@generic@ps@base", "base", 8.0, -8, -1, 33, 0, 0, 40, 0)
		AttachEntityToEntity(lPed, targetPed, 9816, 0.015, 0.38, 0.11, 0.9, 0.30, 90.0, false, false, false, false, 2, false)
		isCarry  = true
		IsLiftup = true
	else
		DetachEntity(lPed, true, false)
		ClearPedTasksImmediately(targetPed)
		ClearPedTasksImmediately(lPed)
		isCarry  = false
		IsLiftup = false
	end
end)

-- PiggyBack: target animation + attach
RegisterNetEvent('qb_carry:client:syncTarget', function(target, animationLib, animation2, distans, distans2, height, length, spin, controlFlag)
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	piggyBackInProgress = true
	LoadAnimationDictionary(animationLib)
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(playerPed, targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
end)

-- PiggyBack: initiator animation
RegisterNetEvent('qb_carry:client:syncMe', function(animationLib, animation, length, controlFlag)
	local playerPed = GetPlayerPed(-1)
	LoadAnimationDictionary(animationLib)
	Wait(500)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	Citizen.Wait(length)
end)

RegisterNetEvent('qb_carry:client:cl_stop', function()
	piggyBackInProgress = false
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
end)

-- Carry (fireman carry): target animation + attach
RegisterNetEvent('cmg2_animations:syncTarget', function(target, animationLib, animation2, distans, distans2, height, length, spin, controlFlag)
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	carryingBackInProgress = true
	LoadAnimationDictionary(animationLib)
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(playerPed, targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
end)

-- Carry (fireman carry): initiator animation
RegisterNetEvent('cmg2_animations:syncMe', function(animationLib, animation, length, controlFlag)
	local playerPed = GetPlayerPed(-1)
	LoadAnimationDictionary(animationLib)
	Wait(500)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	Citizen.Wait(length)
end)

RegisterNetEvent('cmg2_animations:cl_stop', function()
	carryingBackInProgress = false
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
end)

-- Hostage: target receives this to attach + play animation
RegisterNetEvent('cmg3_animations:syncTarget', function(target, animationLib, animation2, distans, distans2, height, length, spin, controlFlag, animFlagTarget, attach)
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	holdingHostageInProgress = not holdingHostageInProgress
	beingHeldHostage         = not beingHeldHostage
	LoadAnimationDictionary(animationLib)
	if spin == nil then spin = 180.0 end
	if attach then
		AttachEntityToEntity(playerPed, targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	end
	if controlFlag == nil then controlFlag = 0 end
	if animation2 == "victim_fail" then
		SetEntityHealth(playerPed, 0)
		TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
		beingHeldHostage         = false
		holdingHostageInProgress = false
	elseif animation2 == "shoved_back" then
		holdingHostageInProgress = false
		TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
		beingHeldHostage = false
	else
		TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
		beingHeldHostage = false
	end
end)

-- Hostage: initiator animation
RegisterNetEvent('cmg3_animations:syncMe', function(animationLib, animation, length, controlFlag)
	local playerPed = GetPlayerPed(-1)
	ClearPedSecondaryTask(playerPed)
	LoadAnimationDictionary(animationLib)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	if animation == "perp_fail" then
		SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, 0)
		holdingHostageInProgress = false
	end
	if animation == "shove_var_a" then
		Wait(900)
		ClearPedSecondaryTask(playerPed)
		holdingHostageInProgress = false
	end
end)

RegisterNetEvent('cmg3_animations:cl_stop', function()
	holdingHostageInProgress = false
	beingHeldHostage         = false
	holdingHostage           = false
	ClearPedSecondaryTask(GetPlayerPed(-1))
	DetachEntity(GetPlayerPed(-1), true, false)
end)

-- Key binding: F9 opens the carry menu

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustReleased(0, 56) then -- F9
			OpenCarryMenu()
		end
	end
end)

-- Hostage holding loop

Citizen.CreateThread(function()
	while true do
		if holdingHostage then
			if GetEntityHealth(GetPlayerPed(-1)) <= 102 then
				holdingHostage           = false
				holdingHostageInProgress = false
				local nearest = GetClosestPlayer(2)
				if nearest ~= nil then
					TriggerServerEvent("cmg3_animations:stop", GetPlayerServerId(nearest))
				end
				Wait(100)
				releaseHostage()
			end
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 25, true)
			DisableControlAction(0, 47, true)
			DisableControlAction(0, 58, true)
			DisablePlayerFiring(GetPlayerPed(-1), true)
			local playerCoords = GetEntityCoords(GetPlayerPed(-1))
			DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z, "Press [G] to release, [H] to kill")
			if IsDisabledControlJustPressed(0, 47) then
				holdingHostage           = false
				holdingHostageInProgress = false
				local nearest = GetClosestPlayer(2)
				if nearest ~= nil then
					TriggerServerEvent("cmg3_animations:stop", GetPlayerServerId(nearest))
				end
				Wait(100)
				releaseHostage()
			elseif IsDisabledControlJustPressed(0, 74) then
				holdingHostage           = false
				holdingHostageInProgress = false
				local nearest = GetClosestPlayer(2)
				if nearest ~= nil then
					TriggerServerEvent("cmg3_animations:stop", GetPlayerServerId(nearest))
				end
				killHostage()
			end
		end
		if beingHeldHostage then
			DisableControlAction(0, 21, true)
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 25, true)
			DisableControlAction(0, 47, true)
			DisableControlAction(0, 58, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 143, true)
			DisableControlAction(0, 75, true)
			DisableControlAction(27, 75, true)
			DisableControlAction(0, 22, true)
			DisableControlAction(0, 32, true)
			DisableControlAction(0, 268, true)
			DisableControlAction(0, 33, true)
			DisableControlAction(0, 269, true)
			DisableControlAction(0, 34, true)
			DisableControlAction(0, 270, true)
			DisableControlAction(0, 35, true)
			DisableControlAction(0, 271, true)
		end
		Wait(0)
	end
end)

-- Disable movement while being dragged

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsLiftup then
			DisableControlAction(2, 56, true)
		else
			Citizen.Wait(500)
		end
	end
end)
