-- From Asta, if any question, find me here: https://discord.gg/ZUZdMzQ
net.log("Autokick script loading... Please wait...")

local SW = {}

function SW.onMissionLoadEnd()
	os.remove(lfs.writedir()..[[TKhistory.csv]]) --Useless to keep it and it's better the for loop to work on a small file (performance)
end


function SW.onGameEvent(eventName,arg1,arg2,arg3,arg4)
	if eventName == "friendly_fire" then -- playerID, weaponName, victimPlayerID
		if arg1 ~= arg3 then -- Not trigging if a player is damaging himself
			if arg2 == nil or arg2 == '' then -- If the weapon use was a gun, it's empty, so I specify it was with gun.
				arg2 = "gun"
			end
			local tkDetected = string.format("\n%s;%s;%s;%s;%s;%s;%s", os.time(), arg1, net.get_player_info(arg1, 'name'), net.get_player_info(arg1, 'ucid'), net.get_player_info(arg3, 'name'), net.get_player_info(arg3, 'ucid'), arg2)
			local tkCSV = lfs.writedir()..[[TKhistory.csv]]
			logTK(tkCSV, tkDetected) -- CSV file in "\Saved Games\DCS.openbeta"
			net.send_chat_to("@"..net.get_player_info(arg3, 'name').." type 'kick' [2all] in the next 30s to kick @"..net.get_player_info(arg1, 'name').." for TK.", arg3)
		end
	end
end

function SW.onChatMessage(message, from)
	if message == "kick" then
		local readTKFile = io.open(lfs.writedir().."/TKhistory.csv", "r")
		for line in readTKFile:lines() do
			if line ~= nil and line ~= '' and line ~= ' ' then
				local iterator = 0
				local tkDate = ""
				local killerID = ""
				local victimName = ""
				local victimUcid = ""
				local weapons = ""
				for content in string.gmatch(line, "[^;]+") do --Parsing the CSV
					iterator = iterator + 1
					if iterator == 1 then 
						tkDate = content
					elseif iterator == 2 then
						killerID = content
					elseif iterator == 5 then
						victimName = content
					elseif iterator == 6 then
						victimUcid = content
					elseif iterator == 7 then
						weapons = content
					end
				end

				if net.get_player_info(from, 'ucid') == victimUcid then -- Check if the player asking the kick is really a victim
					if tkDate+30 >= os.time() then -- Delay of 30 seconds
						kickPlayerForTK(killerID, weapons, victimName)
					end
				end
			end
		end
		readTKFile:close()
	end
end 



function kickPlayerForTK(pPlayerID, pWeaponName, pVictimPlayerName) 
	
	local kickMessage = "The player "..net.get_player_info(pPlayerID, 'name').." has been kicked for friendlyfiring/teamkilling "..pVictimPlayerName.." with "..pWeaponName.." at "..os.date("%Y%m%d%H%M%S").."!"..",,"..DCS.getModelTime()
	
	local textCSV = string.format("\n%s", kickMessage)
	local fileKickHistory = lfs.writedir()..[[TK_kick_history.csv]]
	logTK(fileKickHistory, textCSV) -- CSV file in "\Saved Games\DCS.openbeta"
	
	net.kick(pPlayerID,"Dear "..net.get_player_info(pPlayerID, 'name')..", the player "..pVictimPlayerName.." decided to kick you for friendlyfiring/teamkilling him with "..pWeaponName.."! You can reconnect, but be aware the admin will know about it.")
end

function logTK(filename, data)
	local file = io.open(filename, "a")
	if file then
		file:write(data)
		file:close()
	end
end

DCS.setUserCallbacks(SW)
 
net.log("Autokick script loaded!")