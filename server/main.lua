local QBCore = exports['qb-core']:GetCoreObject()

-- Check if the player has a rope in their inventory
RegisterNetEvent('qb_carry:server:checkRope', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		local ropeItem = Player.Functions.GetItemByName('rope')
		if ropeItem ~= nil and ropeItem.amount > 0 then
			TriggerClientEvent('qb_carry:client:trueRope', src)
		else
			TriggerClientEvent('qb_carry:client:falseRope', src)
		end
	end
end)

-- Remove one rope from the player's inventory
RegisterNetEvent('qb_carry:server:removeRope', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.RemoveItem('rope', 1)
		TriggerClientEvent('qb_carry:client:trueUsedRope', src)
	end
end)

-- Hostage sync: relay animation data to both participants
RegisterNetEvent('cmg3_animations:sync', function(target, animationLib, animationLib2, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget, attachFlag)
	TriggerClientEvent('cmg3_animations:syncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget, attachFlag)
	TriggerClientEvent('cmg3_animations:syncMe', source, animationLib, animation, length, controlFlagSrc, animFlagTarget)
end)

RegisterNetEvent('cmg3_animations:stop', function(targetSrc)
	TriggerClientEvent('cmg3_animations:cl_stop', targetSrc)
end)

-- Trigger the drag/lift animation on the target player
RegisterNetEvent('qb_carry:server:lyfter', function(target)
	local Player = QBCore.Functions.GetPlayer(target)
	if Player then
		TriggerClientEvent('qb_carry:client:upplyft', Player.PlayerData.source, source)
	end
end)

-- Carry (fireman carry) sync
RegisterNetEvent('cmg2_animations:sync', function(target, animationLib, animationLib2, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget)
	TriggerClientEvent('cmg2_animations:syncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget)
	TriggerClientEvent('cmg2_animations:syncMe', source, animationLib, animation, length, controlFlagSrc, animFlagTarget)
end)

RegisterNetEvent('cmg2_animations:stop', function(targetSrc)
	TriggerClientEvent('cmg2_animations:cl_stop', targetSrc)
end)

-- Notify a player that someone is trying to lift them
RegisterNetEvent('qb_carry:server:lyfteruppn', function(targetSrc)
	if QBCore.Functions.GetPlayer(targetSrc) then
		TriggerClientEvent('QBCore:Notify', targetSrc, 'Someone is trying to lift you up...', 'primary')
	end
end)

-- PiggyBack sync
RegisterNetEvent('qb_carry:server:sync', function(target, animationLib, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget)
	TriggerClientEvent('qb_carry:client:syncTarget', targetSrc, source, animationLib, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget)
	TriggerClientEvent('qb_carry:client:syncMe', source, animationLib, animation, length, controlFlagSrc, animFlagTarget)
end)

RegisterNetEvent('qb_carry:server:stop', function(targetSrc)
	TriggerClientEvent('qb_carry:client:cl_stop', targetSrc)
end)

print('qb_carry 2.0 by AOTCARIBBEAN - QBCore edition')

