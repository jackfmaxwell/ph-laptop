
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

local display = false
local bootupdone = false -- initialized laptop, can be skipped

local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local tabletAnim = "base"
local tabletProp = 'prop_cs_tablet'
local tabletBone = 60309
local tabletOffset = vector3(0.03, 0.002, -0.0)
local tabletRot = vector3(10.0, 160.0, 0.0)

local requiredItems = {[1] = {name = QBCore.Shared.Items["markedbills"]["name"], image = QBCore.Shared.Items["markedbills"]["image"]}}

local requiredItems2 = {[1] = {name = QBCore.Shared.Items["drill"]["name"], image = QBCore.Shared.Items["drill"]["image"]}}
--for help cmd
local commandList ={
    [1] = {
        ["label"] = "echo",
        ["use"] = ""
    },
    [2] = {
        ["label"] = "clear",
        ["use"] = ""
    },
    [3] = {
        ["label"] = "airodump-ng",
        ["use"] = "capture nearby net traffic | Usage: (-blank-) -- Search Acess Points     |    (targetRouter) -- Search Connected Hosts"
    },
    [4] = {
        ["label"] = "nmap",
        ["use"] = "net analysis"
    },
    [5] = {
        ["label"] = "arpspoof",
        ["use"] = "ARP table attack using IP addresses | Usage: -t (targetHost) (targetRouter)"
    },
    [6] = {
        ["label"] = "airmon-ng",
        ["use"] = "view laptop network cards"
    },
    [7] = {
        ["label"] = "ftp",
        ["use"] = "file transfer protocol | must be connected to network, begins ftp session"
    },
    [8] = {
        ["label"] = "ssh",
        ["use"] = "secure shell | must be connected to network, begins ssh session"
    },
    [9] = {
        ["label"] = "ipconfig",
        ["use"] = "view nework configuration values"
    },
    [10] = {
        ["label"] = "ping",
        ["use"] = ""
    },
    [11] = {
        ["label"] = "cat",
        ["use"] = ""
    },
    [12] = {
        ["label"] = "ls",
        ["use"] = ""
    },
    [13] = {
        ["label"] = "cd",
        ["use"] = ""
    },
    [14] = {
        ["label"] = "mkdir",
        ["use"] = ""
    },
    [15] = {
        ["label"] = "wireshark",
        ["use"] = "Usage: -i specify interface, -w specify output file name"
    },
    [16] = {
        ["label"] = "packetforge-ng",
        ["use"] = "Usage: -s specify spoofed source, -t specify target, 3rd argument is packet data"
    },


}

-- Infinitys Goblem Varibles
local sessionActive = false
local windowcommands = 1
-- end

local netInterfacesMonitorMode = {
    ["wlan0"] = false,
} -- which interfaces are in monitor mode

--checks nearby networks
local reachableNetworks = {} -- this is for storing the static networks, so polyzone checks

--connected network, set from nearby nets
local connectedNetwork = nil; --we can use the routerip to lookup in server nets to see live network with actual clients not static setup
--the net we are attempted to connect to
local attemptedConnectNet = {}
local ourIP = nil -- the IP for the net we are currently connected to (generated on join, destroyed on leave)

--holds ssh session details, generated on creation, destroyed on leave
local sshConnection = {}

--TEMP GOBLIN VARIABLES
local locLaptopData = {}
local hackedATMLoc = vector(0,0,0) --vector3(90.22, 2.18, 68.29)

--DOOMSDAY TEMP VAR

local doorLocked = true
local keypadPanelOff = false


--generic functions
function integer(self, a, b)
	if a == nil and b == nil then
		return math.random(0, 100)
	end
	if b == nil then
		return math.random(a)
	end
	return math.random(a, b)
end
function ipv4(self)
	local str = ''
	for i=1, 4 do
		str = str .. integer(0, 255)
		if i ~= 4 then str = str .. '.' end
	end
	return str
end
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t, cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
    end
    return t
 
end
function all_trim(s)
    return s:match( "^%s*(.-)%s*$" )
end
---
--open and close laptop
function doAnimation()
    if not display then return end
    -- Animation
    RequestAnimDict(tabletDict)
    while not HasAnimDictLoaded(tabletDict) do Citizen.Wait(100) end
    -- Model
    RequestModel(tabletProp)
    while not HasModelLoaded(tabletProp) do Citizen.Wait(100) end

    local plyPed = PlayerPedId()

    local tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)

    local tabletBoneIndex = GetPedBoneIndex(plyPed, tabletBone)

    AttachEntityToEntity(tabletObj, plyPed, tabletBoneIndex, tabletOffset.x, tabletOffset.y, tabletOffset.z, tabletRot.x, tabletRot.y, tabletRot.z, true, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(tabletProp)

    CreateThread(function()
        while display do
            Wait(0)
            if not IsEntityPlayingAnim(plyPed, tabletDict, tabletAnim, 3) then
                TaskPlayAnim(plyPed, tabletDict, tabletAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
        end
        ClearPedSecondaryTask(plyPed)
        Wait(250)
        DetachEntity(tabletObj, true, false)
        DeleteEntity(tabletObj)
    end)
end
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type="openlaptop",
        status = bool
    })
    doAnimation()
end

-- opens hacker door then closes after delay
function hackerHideoutDoorCooldown()
    print("Runs")
    local id = GetPlayerServerId(PlayerId())
    TriggerServerEvent('qb-doorlock:server:updateState', 'cryptodoor-7581954', false, id, false, true, true, true)
    Wait(6000)
    local id = GetPlayerServerId(PlayerId())
    TriggerServerEvent('qb-doorlock:server:updateState', 'cryptodoor-7581954', true, id, false, true, true, true)
end

--open laptop, show CLI if have oculum
RegisterNetEvent('ph-laptop:client:openLaptop', function ()
    display = not display
    SetDisplay(display)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
		if HasItem then
            SendNUIMessage({
                type="showCLI"
            })
           
        end
	  end, 'cryptostick')
   
end)

--hack a specfic indexed ATM
function setATMHacked(index)
    local hackedATM = CircleZone:Create(Config.Atm[index].location, 1.0, {
        name = 'hackedATM'..index,
        heading = 90.0,
        minZ = Config.Atm[index].location.z - 0.2,
        maxZ = Config.Atm[index].location.z + 1,
        debugPoly = false
    })
    hackedATM:onPlayerInOut(function(inside)
        if inside then
            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        else
            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
        end

    end)
    hackedATMLoc = Config.Atm[index].location
end

--use marked bills 
RegisterNetEvent('markedbills:UseMarkedbills', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = #(pos - hackedATMLoc)
    if dist < 1.5 then
        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
        exports['ps-ui']:Circle(function(success)
            if success then
                ClearPedTasks(PlayerPedId())
                QBCore.Functions.Notify("Exchanged marked bills", "error")
                print("id ", GetPlayerServerId(PlayerPedId()))
                TriggerServerEvent('ph-laptop:server:exchangeMarkedBills', GetPlayerServerId(PlayerPedId()))
               
            else
                PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
                ClearPedTasks(PlayerPedId())
            end
        end, 3, 60)

    end
end)


RegisterNetEvent('ph-laptop:client:ftpwindow', function(command)
    if connectedNetwork == nil then
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ftp: Network is unreachable") 
        sessionActive = false
        SendNUIMessage({
                type="setCursorName",
                data = ">"
        })
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "221 Goodbye.")
        return
    end
    local cmd = split(command, " ")[1]
    local args = split(command:sub(string.len(cmd)+1), " ")
    if cmd == "exit" then 
        sessionActive = false
        SendNUIMessage({
                type="setCursorName",
                data = ">"
        })
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "221 Goodbye.")
    end

    if windowcommands == 1 then
        SendNUIMessage({
            type="setCursorName",
            data = "ftp>"
        })
        if cmd == "anonymous" then
            print("sucseful")
            windowcommands = 2
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "230 Login successful. <br> Remote system type is UNIX. <br> Using Binary mode to transfer files.")
        else
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "530 This FTP server is anonymous only. <br> Login failed.")
            sessionActive = false
            SendNUIMessage({
                type="setCursorName",
                data = ">"
            })
        end
    
    elseif windowcommands == 2 then
        QBCore.Functions.TriggerCallback('ph-laptop:server:GetDate', function(result)
            if cmd == "ls" then                                 
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "227 Entering Passive Mode (48.74.175.84). <br> 150 Here comes the directory lising. <br> -rw-r--r--    1 ftp      ftp            "..result.."  Atm <br>  -rw-r--r--    1 ftp      ftp            "..result.."  CCTV <br> 226 Directory send OK. ")
            elseif cmd == "cd" then
                if args[1] == "Atm" then 
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "250 Directory successfully changed.")
                    windowcommands = 3
                elseif args[1] == "CCTV" then 
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "250 Directory successfully changed.")
                    windowcommands = 4
                else
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "550 Failed to change directory.")
                end
            end
        end)
    elseif windowcommands == 3 then
        if cmd == "ls" then
            QBCore.Functions.TriggerCallback('ph-laptop:server:GetDate', function(result)
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " 227 Entering Passive Mode (48.74.175.84). <br> 150 Here comes the directory listing. <br> -rw-r--r--    1 ftp      ftp            "..result.."  atm.txt <br> 226 Directory send OK. ")
            end)
        elseif cmd == "cd" then
            if args[1] == "/" then 
                windowcommands = 2
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "250 Directory successfully changed.")
            else
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "550 Failed to change directory.")

            end
        elseif cmd == "get" then 
            if args[1] == "atm.txt" then 
                TriggerServerEvent('ph-laptop:server:ftpgetdata','atm')
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "local: atm.txt remote: atm.txt <br> 227 Entering Passive Mode (48.74.175.84). <br> 150 Opening BINARY mode data connection fro atm.txt (21 bytes). <br> 226 Transfer complete. <br> 21 bytes received in 0.00 secs (136.2645 kB/s)")
                locLaptopData["atm.txt"] = {"Spanish and Hawick"}
            else 
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "local: "..args[1].."  remote:  " ..args[1].." <br> 227 Entering Passive Mode (48.74.175.84). <br> 550 Failed to open file.")
            end
        end
    end
    
end)

RegisterNetEvent('ph-laptop:client:sshwindow', function(command)
    if connectedNetwork == nil then
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ssh: Network is unreachable") 
        sessionActive = false
        SendNUIMessage({
                type="setCursorName",
                data = ">"
        })
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "logout <br> Connection to "..sshConnection.hostName .."@"..sshConnection.ip .." closed.")
        return
    end
    local cmd = split(command, " ")[1]
    local args = split(command:sub(string.len(cmd)+1), " ")
    if cmd == "exit" then 
        sessionActive = false
        SendNUIMessage({
                type="setCursorName",
                data = ">"
        })
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "logout <br> Connection to "..sshConnection.hostName .."@"..sshConnection.ip .." closed.")
    end

    if windowcommands == 1 then
        SendNUIMessage({
            type="setCursorName",
            data = "ssh:"
        })
        if cmd == sshConnection.hostName then
            windowcommands = 2
            SendNUIMessage({
                type="setCursorName",
                data = "Enter password (ssh):"
            })
        else
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Incorrect login credentials, disconnecting...")
            sessionActive = false
            SendNUIMessage({
                type="setCursorName",
                data = ">"
            })
        end
    
    elseif windowcommands == 2 then
        if cmd == sshConnection.pass then
            windowcommands=3
            SendNUIMessage({
                type="setCursorName",
                data = "ssh>"
            })
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Successful connection to "..sshConnection.hostName .."@"..sshConnection.ip .." opened.")
        else 
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Incorrect login credentials, disconnecting...")
            sessionActive = false
            SendNUIMessage({
                type="setCursorName",
                data = ">"
            })
        end
    elseif windowcommands == 3 then
        if cmd == "ls" then
            if sshConnection.ip == "204.67.248.146" and sshConnection.hostName == "hacked" then
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "oculum.exe")
            else
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "")
            end
        elseif cmd == "run" then
            if args[1]=="oculum.exe" then
                if sshConnection.ip == "204.67.248.146" and sshConnection.hostName == "hacked" then
                    --run atm exe
                    exports['ps-dispatch'].PowerOutage(sshConnection.location)
                    for i=math.random(7,12),1,-1 do
                        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Executing oculum.exe on " .. sshConnection.ip .."...")
                        Citizen.Wait(math.random(20,200))
                    end
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "oculum.exe sucessfully executed.")
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ATM system rebooting...")
                    setATMHacked(sshConnection.index)
                    local ticks = math.random(20,38)
                    for i=1,ticks do
                        local percentage = tonumber(string.format("%.0f", (i/ticks)*100))
                        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Rebooting... ("..percentage.."%")
                        Citizen.Wait(math.random(3000,6000))
                    end
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "------FLEECA BANK SYSTEMS-----")
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "------------------------------")
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", sshConnection.ip .. " ATM fully rebooted. Status: fully operational")
                    hackedATMLoc = vector3(0,0,0)
                else
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "exe not found")
                end

            else
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "exe not found")
            end
        end
        
       
    end
    
end)
local currentPCAPFile = {}
RegisterNetEvent('ph-laptop:client:unlockFirstNukeDoor', function()
    TriggerServerEvent('qb-doorlock:server:updateState', 'CentralRoomEntrance', false, GetPlayerServerId(PlayerId()), false, true, true, true)
    Wait(6000)
    TriggerServerEvent('qb-doorlock:server:updateState', 'CentralRoomEntrance', true, GetPlayerServerId(PlayerId()), false, true, true, true)
end)
RegisterNetEvent('ph-laptop:client:capturePacket', function(packetData)
    table.insert(currentPCAPFile, packetData)
end)

RegisterNetEvent('ph-laptop:client:handleCommand', function(command)
    local cmd = split(command, " ")[1]
    local args = split(command:sub(string.len(cmd)+1), " ")
    local player = QBCore.Functions.GetPlayerData()
    
    if cmd=="help" then
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Available commands:")
        for _, cmd in pairs(commandList) do
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", cmd.label)
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "--"..cmd.use)
        end
    elseif cmd == "echo" then
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", args)
    elseif cmd=="clear" then
        TriggerEvent('ph-laptop:client:sendCommandResponse', "clear", {})
        bootupdone = true
    elseif cmd=="ping" then
        if args[1]==nil then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "No target specified.") return end
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Pinging " .. args[1] .. " with 32 bytes of data:")
        local packetsSent = math.random(3,5)
        -- we arent connected
        if connectedNetwork == nil then
            for i=packetsSent,1,-1 do
                local ping = math.random(16,60)
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "PING: transmit failed. General failure.")
                Citizen.Wait(math.random(40,200))
            end
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " Packets: Sent = "..packetsSent..", Received = 0, Lost = "..packetsSent.." (100% loss)")
        else  --we are connected, check if target network or client exists
            if args[1] == connectedNetwork.routerip then
                for i=packetsSent,1,-1 do
                    local ping = math.random(16,60)
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Reply from " .. args[1] .. ": time="..ping.."ms")
                    Citizen.Wait(math.random(20,200))
                end
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " Packets: Sent = "..packetsSent..", Received = "..packetsSent..", Lost = 0 (0% loss)")
            else
                QBCore.Functions.TriggerCallback('ph-laptop:server:getNetClients', function(result)
                    if result then
                        local foundTarget = false
                        for o,p in pairs(result) do
                            if o==args[1] then
                                foundTarget = true
                                for i=packetsSent,1,-1 do
                                    local ping = math.random(16,60)
                                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Reply from " .. args[1] .. ": time="..ping.."ms")
                                    Citizen.Wait(math.random(20,200))
                                end
                                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " Packets: Sent = "..packetsSent..", Received = "..packetsSent..", Lost = 0 (0% loss)")
                            end
                        end
                        if not foundTarget then
                            for i=packetsSent,1,-1 do
                                local ping = math.random(16,60)
                                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Reply from " .. args[1] .. ": Destination host unreachable.")
                                Citizen.Wait(math.random(40,200))
                            end
                            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " Packets: Sent = "..packetsSent..", Received = 0, Lost = "..packetsSent.." (100% loss)")
                        end
                    else
                        for i=packetsSent,1,-1 do
                            local ping = math.random(16,60)
                            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Reply from " .. args[1] .. ": Destination host unreachable.")
                            Citizen.Wait(math.random(40,200))
                        end
                        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " Packets: Sent = "..packetsSent..", Received = 0, Lost = "..packetsSent.." (100% loss)")
                    end
                end, connectedNetwork.routerip)
            end
        end
    elseif cmd=="airodump-ng" then
        if args[1]==nil then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "No interface specified.") return end
        if args[1] and args[2]==nil then
            if netInterfacesMonitorMode[args[1]] then 
                for k, v in pairs(reachableNetworks) do
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Router: "..v.routerip)
                end
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "--------End of airodump--------")
            else
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Interface " ..args[1])
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "failed: No such device")
            end
        elseif args[1] and args[2] then
            local target = all_trim(args[2])
            if netInterfacesMonitorMode[args[1]] then 
                local foundRouter = false
                for i, reachableNetStruct in pairs(reachableNetworks) do
                    if reachableNetStruct.routerip == target then
                        foundRouter = true 
                       --for clientIP, clientObject in pairs(reachableNetStruct.connectedClients) do
                        --    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Client: "..clientIP)
                       -- end
                        QBCore.Functions.TriggerCallback('ph-laptop:server:getNetClients', function(result)
                            if result then
                                for o,p in pairs(result) do
                                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Client: "..o)
                                end
                            end
                        end, reachableNetStruct.routerip)
                    end
                end
                if not foundRouter then
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Gateway not found " .. target)
                end
            else
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Interface " ..args[1])
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "failed: No such device")

            end
        end

   -- elseif cmd=="aireplay-ng" then 
    --    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " MAC adresses unimplemented") return end
    elseif cmd=="airmon-ng" then
        if args[1]==nil then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "| PHY &nbsp; | Interface &nbsp; | Driver &nbsp; | Chipset")
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "| phy0 &nbsp; | wlan0 &nbsp; | brcmsmac &nbsp; | Broadcom on bcma bus, information limited")
        elseif args[1]=="start" and netInterfacesMonitorMode[args[2]]~=nil then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "| PHY &nbsp; | Interface &nbsp; | Driver &nbsp; | Chipset")
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "| phy0 &nbsp; | wlan0 &nbsp; | brcmsmac &nbsp; | Broadcom on bcma bus, information limited")
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "&nbsp; &nbsp; (monitor mode enabled) &nbsp;")
            netInterfacesMonitorMode[args[2]] = true
        else
            local interface = "undefined"
            if args~=nil and args[2]~=nil then interface = args[2] end
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Interface " ..interface)
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "failed: No such device")
        end
    elseif cmd=="ipconfig" then
        if connectedNetwork == nil then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "No connection to network")
            return
        else
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Wireless Connection")
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "IP Address  .   .   .   .   "..ourIP)
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Default Gateway  .   .   .   .   "..connectedNetwork.routerip)
        end
    elseif cmd=="wireshark" then
        -- -i interface     -w output file
        if args[1]~="-i" then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Interface flag unset") return end
        if not netInterfacesMonitorMode[args[2]] then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Interface " ..args[2])
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "failed: No such device")
            return
        end
        if args[3]~="-w" then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Ouput file flag unset") return end
        if args[4]==nil then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Missing arg: output file") return end
       
        TriggerServerEvent('ph-laptop:server:startpacketsniff', GetPlayerServerId(PlayerId()), reachableNetworks)
        currentPCAPFile = {}
        for i=7,1,-1 do
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Capturing on '" .. args[2].."'")
            Citizen.Wait(1000)
        end

        locLaptopData[args[4]..".pcap"] = currentPCAPFile
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Wireshark complete. File added: " .. args[4] ..".pcap")
        TriggerServerEvent('ph-laptop:server:stoppacketsniff', GetPlayerServerId(PlayerId()), reachableNetworks)
    elseif cmd=="packetforge-ng" then
        if args[1]~="-s" then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Spoofed source flag unset") return end
        if args[3]~="-t" then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Target flag unset") return end

        if args[5]==nil then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Packet data empty") return end
        local packetData = command:sub(string.len(cmd)+1 + string.len(args[2])+1 + string.len(args[4])+1 + 4 + 4)
        print(packetData)
        TriggerServerEvent('ph-laptop:server:sendServicePacket', GetPlayerServerId(PlayerId()), args[2], args[4], packetData, false)

    elseif cmd=="arpspoof" then
        if args[1] ~="-t" then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Target flag unset") return end
        local computer = all_trim(args[2])
        local gateway = all_trim(args[3])
        --local gateway = split(split(args, "-t")[2], " ")[2]
        if not (computer and gateway) then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Missing target (Host or Router)")
        else
            QBCore.Functions.TriggerCallback('ph-laptop:server:getNetworks', function(result)
                    if result then
                        local routerFound = false
                        for routerip, net in pairs(result) do
                            if routerip==gateway then
                                routerFound = true
                                local foundComp = false
                                for i, client in pairs(net.connectedClients) do
                                    if i == computer then
                                        foundComp = true
                                        for j=math.random(7,16),1,-1 do
                                            if (j%2)==0 then
                                                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "MAC  MAC2    0806    42: arp reply ".. computer)
                                            else 
                                                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "MAC  MAC2    0806    42: arp reply ".. gateway)
                                            end
                                            Citizen.Wait(math.random(20,200))
                                        end
                                        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Target unresponsive at: " .. computer)
                                        TriggerServerEvent('ph-laptop:server:disconnectTargetFromNet', GetPlayerServerId(PlayerId()), routerip, ourIP, computer)
                                    end
                                end
                                if not foundComp then
                                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Target not found " .. computer)
                                end
                            end
                        end
                        if not routerFound then
                            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Gateway not found " .. gateway)
                        end
                    else
                        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Destination unreachable.")
                    end
                end) 
        end
    elseif cmd=="nmap" then
        local target = all_trim(args[1])
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Nmap 7.92 ( https://nmap.org )")
        if connectedNetwork == nil then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "No connection to network")
        else
            if not target then
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Usage: nmap [Scan Type(s)] [Options] {target specification}            ")
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Missing target")
            else
                QBCore.Functions.TriggerCallback('ph-laptop:server:getNetworks', function(result)
                    if result then
                        local foundTarget = false
                        for routerip, net in pairs(result) do
                            if routerip==target then
                                foundTarget = true
                                local numClients = 1
                                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Host is up (0.075s latency).")
                                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", " PORT   STATE SERVICE")
                                for i, port in pairs(net.openPorts) do
                                    local service = "ssh"
                                    if i==22 and port==true then service ="ssh" end
                                    if (i==20 or i==21) and port==true then service ="ftp" end
                                    if i==80 and port==true then service ="http" end
                                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", i.."/tcp open  "..service)
                                end
                                for i, client in pairs(net.connectedClients) do
                                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Nmap scan report for " ..i .." | " ..client.deviceName.." |")
                                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Host is up (0.00050s latency)")
                                    numClients +=1
                                end
                            end
                        end
                        if not foundTarget then
                            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Destination unreachable.")
                        end
                    else
                        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Destination unreachable.")
                    end
                end) 
            end
        end
        
    elseif cmd == "ftp" then
        if connectedNetwork == nil then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ftp: Network is unreachable") 
            return
        else
            if args[1] ~="-p" then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ftp: missing flags") end
            local ftpip = args[2]
            if ftpip == Config.HackerHideout.ip then
                sessionActive = "ftp"
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Connected to " ..ftpip.. ". <br> 220 (vsFTPd 3.0.3)")
                SendNUIMessage({
                    type="setCursorName",
                    data = "Name ("..ftpip..":root):"
                })
                windowcommands = 1
                --TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "Name ("..ftpip..":root):")
            else
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ftp:  " ..ftpip.. ": Name or service not known") 
            end
        end
    elseif cmd == "ls" then
        for i, k in pairs(locLaptopData) do 
            print(i)
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", i)
        end
    
    elseif cmd == "cat" then
        local foundFile = false
        for i, k in pairs(locLaptopData) do 
            if args[1] == i then
                foundFile = true

                for _, packet in pairs(k) do
                    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", packet)
                end
               
            end
            
        end

        if not foundFile then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "cat:"..args[1]..": No such file or directory")
        end
        --[[
          if args[1] == "atm.txt" and locLaptopData.atm == true then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", Config.Atm[1].response)
        else 
            
        end
        ]]
      
    elseif cmd == "ssh" then
        if connectedNetwork == nil then
            TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ssh: Network is unreachable") 
            return
        end
        if not args[1] then TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ssh: missing host") end
        local host = args[1]
        local hostFound=false
        for k, v in pairs(Config.Routers) do
            if host==v.routerip then
                -- found
                hostFound=true
                sessionActive = "ssh"
                sshConnection.hostName = v.user
                sshConnection.ip = v.routerip
                sshConnection.pass = v.pass
                sshConnection.location = v.location
                sshConnection.index = -1
                SendNUIMessage({
                    type="setCursorName",
                    data = "Enter User ID (ssh):"
                })
                windowcommands = 1
            end
        end
        if not hostFound then
            for k, v in pairs(Config.Atm) do
                if host == v.ip then
                    hostFound =true
                    sessionActive = "ssh"
                    sshConnection.hostName = v.user
                    sshConnection.ip = v.ip
                    sshConnection.pass = v.pass
                    sshConnection.location = v.location
                    sshConnection.index = k
                    SendNUIMessage({
                        type="setCursorName",
                        data = "Enter User ID (ssh):"
                    })
                    windowcommands = 1
                    --found
                end
            end

            if not hostFound then
                TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", "ssh: connect to host " ..host.. " port 22: Network is unreachable") 
            end
        end
    else
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", {cmd.. ": command not found"})
    end
    
end)

RegisterNetEvent('ph-laptop:client:sendCommandResponse', function(actionName, args)
    SendNUIMessage({ type = actionName, data = args})
end)

RegisterNetEvent('ph-laptop:client:connectToNet', function(reachableNetworksIndex)
    local index = tonumber(reachableNetworksIndex)
    if reachableNetworks[index]==nil then  
        SendNUIMessage({
            type="couldNotConnect"
        }) 
    else
        if connectedNetwork ~=nil then
            if connectedNetwork.displayName==reachableNetworks[index].displayName then
                SendNUIMessage({type="disconnect", networks=reachableNetworks})
                TriggerServerEvent('ph-laptop:server:disconnectFromNet', GetPlayerServerId(PlayerId()), connectedNetwork.routerip, ourIP)
                connectedNetwork = nil
                ourIP=nil
                return
            end
        end
        if reachableNetworks[index].pass=="" then
            --free wifi
            connectedNetwork = reachableNetworks[index]
            ourIP = ipv4()
            SendNUIMessage({ type = "connectToNet", netIndex=index, networks=reachableNetworks})
            TriggerServerEvent('ph-laptop:server:connectToNet', GetPlayerServerId(PlayerId()), connectedNetwork.routerip, ourIP, "Unset")
        else
            attemptedConnectNet.pass=reachableNetworks[index].pass
            attemptedConnectNet.net = reachableNetworks[index]
            attemptedConnectNet.index = index
            SendNUIMessage({
                type="requestNetPassword"
            }) 
        end
        
    end
end)

RegisterNetEvent('ph-laptop:client:disconnectFromNet', function()
    print("runs")
    SendNUIMessage({type="disconnect", networks=reachableNetworks})
    connectedNetwork = nil
    ourIP=nil
end)

RegisterNetEvent('ph-laptop:client:disconnectNonPlayerFromNet', function(targetIP)
    print("disconnect non player: ", targetIP)
    if targetIP == Config.HackerHideout.ip then
        print("disconnect door!")
        hackerHideoutDoorCooldown()
        return
    end
end)

-- NUI
RegisterNUICallback('passwordSubmit', function(data)
    local password = data.Pass
    print(password)
    if password == attemptedConnectNet.pass then
        connectedNetwork = attemptedConnectNet.net
        ourIP = ipv4()
        SendNUIMessage({ type = "connectToNet", netIndex=attemptedConnectNet.index, networks=reachableNetworks})
        TriggerServerEvent('ph-laptop:server:connectToNet', GetPlayerServerId(PlayerId()), connectedNetwork.routerip, ourIP)
    else
        SendNUIMessage({ type = "couldNotConnect"})
        SendNUIMessage({type="closePasswordEntry"})
    end
    attemptedConnectNet = {}
end)
RegisterNUICallback('connect', function (data)
    TriggerEvent('ph-laptop:client:connectToNet', data.netIndex)
end)

RegisterNUICallback('openedTerminal', function()
    if bootupdone then return end 
    for i=40,1,-1 do
        if bootupdone then break end
        TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", {"[       OK      ] Started 0x"..math.random(11111111,99999999).. "..."})
        Citizen.Wait(math.random(30,300))
    end
    bootupdone = true
    TriggerEvent('ph-laptop:client:sendCommandResponse', "commandResponse", {"Initialization complete."})
end)

RegisterNUICallback('submitCommand', function(data)
    if sessionActive == false then
        TriggerEvent('ph-laptop:client:handleCommand', data.Command)
    elseif sessionActive == "ftp" then
        TriggerEvent('ph-laptop:client:ftpwindow', data.Command)
    elseif sessionActive == "ssh" then
        TriggerEvent('ph-laptop:client:sshwindow', data.Command)
    end
end)

RegisterNUICallback('searchQuery', function(data, cb)
    --search data.query
    local p = nil
    local searchQueryPromise = function(data)
        if p then return end
        p = promise.new()
        QBCore.Functions.TriggerCallback('ph-laptop:server:searchQuery', function(result)
            p:resolve(result)
        end, data)
        return Citizen.Await(p)
    end
    local result = searchQueryPromise(data.query)

    p = nil
    return cb(result)
end)
RegisterNUICallback('searchAddress', function(data, cb)
    --search data.query
    local p = nil
    local searchAddressPromise = function(data)
        if p then return end
        p = promise.new()
        QBCore.Functions.TriggerCallback('ph-laptop:server:searchAddress', function(result)
            p:resolve(result)
        end, data)
        return Citizen.Await(p)
    end
    local result = searchAddressPromise(data.address)

    p = nil
    return cb(result)
end)

RegisterNUICallback('getBlackMarketItems', function(data)
    print("gert items")
    TriggerServerEvent('ph-laptop:server:getBlackMarketItems')
end)
RegisterNetEvent('ph-laptop:client:returnBlackMarketItems', function(items)
    print("return items")
    SendNUIMessage({type="blackmarketitems", data=items})
end)
RegisterNUICallback('getPostingData', function(data, cb)
    print("get data")

    local p = nil
    local getPostDataPromise = function(data)
        if p then return end
        p = promise.new()
        QBCore.Functions.TriggerCallback('ph-laptop:server:getPostData', function(result)
            p:resolve(result)
        end, data)
        return Citizen.Await(p)
    end
    local result = getPostDataPromise(data)

    p = nil
    return cb(result)
end)

RegisterNUICallback('internetHomepage', function()
    --Read from cnofig websites
    local homepageSites = {}
    for _,k in pairs(Config.HomepageSites) do
        --build homepage icon for k
        homepageSites[#homepageSites+1] = {
            sitename = k,
            img = Config.Websites[k].homeIcon
        }
    end
    SendNUIMessage({type="loadHomePage", data=homepageSites})
end)

RegisterNUICallback('loginAttempt', function(data)
    print("login")
    TriggerServerEvent('ph-laptop:server:loginAttempt', data.website, data.username, data.pass)
end)

RegisterNUICallback('openlaptop', function (data)
    SetDisplay(false)
end)

RegisterNUICallback('exit', function (data)
    SetDisplay(false)
end)



-- Threads
CreateThread(function ()
    while display do
        Wait(0)
        DisableControlAction(0, 1, display)
        DisableControlAction(0, 2, display)
        DisableControlAction(0, 142, display)
        DisableControlAction(0, 18, display)
        DisableControlAction(0, 322, display)
        DisableControlAction(0, 106, display)
    end
end)

--network zones
CreateThread(function()
    --these are the networks
    for index, object in pairs(Config.Routers) do
        local routerZone = CircleZone:Create(Config.Routers[index].location, Config.Routers[index].routerRange, {
            name = 'routerZone'..index,
            heading = 90.0,
            minZ = Config.Routers[index].location.z - 0.2,
            maxZ = Config.Routers[index].location.z + 1,
            debugPoly = false
        })
        routerZone:onPlayerInOut(function(inside)
            if inside then
                table.insert(reachableNetworks, Config.Routers[index])
            else
               table.remove(reachableNetworks, indexOf(reachableNetworks,Config.Routers[index]))
            end
            SendNUIMessage({--update networks
                type="updateNearbyNets",
                networks = reachableNetworks
            })
            
        end)
    
    end
    
end)

--hacker stash
CreateThread(function()
    exports["qb-target"]:AddCircleZone("hackerroomstash", vector3(-578.62, 229.82, 74.89), 1.0,{
        name = "hackerroomstash",
        debugPoly = false,

    }, {
        options = {
                {
                    label = "Oculum Hacker Stash",
                    icon = "fas fa-box-open",
                    action = function()
                        TriggerServerEvent("inventory:server:OpenInventory", "stash", "OculumHackerStash_")
                        TriggerEvent("inventory:client:SetCurrentStash", "OculumHackerStash_")
                    end,
                }
        },
        distance = 1.5
    })
end)


RegisterNetEvent('ph-laptop:client:scanCredentials', function()
    --PlayerPedId would be parameter, is biometric information in database, if so open door
    --send packet
    print("send credentials")
    TriggerServerEvent('ph-laptop:server:sendServicePacket',GetPlayerServerId(PlayerId()),"54.64.98.4", "222.200.27.81", "Source: " .. "54.64.98.4".. " Destination: ".. "222.200.27.81".. " Protocol: UDP" .. " Data: REQUEST CREDENTIAL CHECK " .. GetPlayerServerId(PlayerId()) .. " GREEN SEC", true)
end)


RegisterNetEvent('drill:UseDrill', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = #(pos - vector3(-354.13, 4824.74, 144.3))
    if dist < 1.5 then
        exports['ps-ui']:Circle(function(success)
            if success then
                ClearPedTasks(PlayerPedId())
                keypadPanelOff = true
            else
                PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
                ClearPedTasks(PlayerPedId())
            end
        end, 5, 20)
    end
end)

--[[
    
RegisterNetEvent('ph-laptop:client:enterDoomsday', function()
    StartPlayerTeleport(PlayerId(), 1256.11, 4796.48, -39.05, 0.0, false, true, true)

    while IsPlayerTeleportActive() do
    Citizen.Wait(0)
    end
end)

RegisterNetEvent('ph-laptop:client:exitDoomsday', function()
    StartPlayerTeleport(PlayerId(), -354.5, 4825.74, 144.3, 0.0, false, true, true)

    while IsPlayerTeleportActive() do
    Citizen.Wait(0)
    end
end)
RegisterNetEvent('ph-laptop:client:doomsdaydooropen', function()
    doorLocked=false
end)
CreateThread(function()
    exports["qb-target"]:AddCircleZone("doomsdaydoor1", vector3(-354.5, 4825.74, 144.3), 0.7,{
        name = "doomsdaydoor1",
        debugPoly = false,

    }, {
        options = {
                {
                    label = "Enter Door",
                    icon = "fas fa-door-open",
                    action = function()
                       if not doorLocked then
                            TriggerEvent('ph-laptop:client:enterDoomsday')
                       else
                            QBCore.Functions.Notify("Door is locked", "error")
                       end
                    end,
                }
        },
        distance = 1
    })
    exports["qb-target"]:AddCircleZone("doomsdaydoorkeypad", vector3(-354.13, 4824.74, 144.3), 0.8,{
        name = "doomsdaydoorkeypad",
        debugPoly = false,

    }, {
        options = {
                {
                    label = "Enter Code",
                    icon = "fas fa-keyboard",
                    action = function()
                        --open keypad
                       exports['ps-ui']:Keypad(function(success)
                        print(success)
                            if success then
                               if success == Config.DoomsdayOuterDoorCode then
                                    doorLocked=false
                                    QBCore.Functions.Notify("Door unlocks...", "error")
                                    TriggerServerEvent('ph-laptop:server:unlockDoomsdayDoor')
                                    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 7, vector3(-354.13, 4824.74, 144.3), "DoorOpen", 0.3)
                               end
                               
                            end
                       end)
                       
                    end,
                },
                {
                    label = "Override Keypad",
                    icon = "fas fa-project-diagram",
                    action = function()
                        --open keypad
                        if not keypadPanelOff then
                            QBCore.Functions.Notify("Keypad panel must be removed to get access", "error")
                        else
                            exports['ps-ui']:VarHack(function(success)
                                if success then
                                   doorLocked=false
                                else
                                    print("fail")
                                end
                             end, 4, 3) -- Number of Blocks, Time (seconds)
                        end
                       
                    end,
                }
                
        },
        distance = 1
    })
    local keypadLoc = CircleZone:Create(vector3(-354.13, 4824.74, 144.3), 0.8, {
        name = "doomsdaydoorkeypad",
        debugPoly = false,
        heading = 90.0,
        minZ = 144.3 - 0.2,
        maxZ = 144.3 + 1,
    })
    keypadLoc:onPlayerInOut(function(inside)
        if inside then
            TriggerEvent('inventory:client:requiredItems', requiredItems2, true)
        else
            TriggerEvent('inventory:client:requiredItems', requiredItems2, false)
        end

    end)

    exports["qb-target"]:AddCircleZone("exitdoomsday",  vector3(1255.82, 4796.49, -39.05), 3,{
        name = "exitdoomsdaydoor1",
        debugPoly = false,

    }, {
        options = {
                {
                    label = "Leave",
                    icon = "fas fa-door-open",
                    action = function()
                        TriggerEvent('ph-laptop:client:exitDoomsday')
                    end,
                }
        },
        distance = 3
    })

    exports["qb-target"]:AddCircleZone("scan-credentialsDoomsday2",  vector3(258.37, 6130.48, -159.42), 1,{
        name = "scan-credentialsDoomsday2",
        debugPoly = false,

    }, {
        options = {
                {
                    label = "Scan Biometric Credentials",
                    icon = "fas fa-fingerprint",
                    action = function()
                        TriggerEvent('ph-laptop:client:scanCredentials')
                    end,
                }
        },
        distance = 1
    })
   
end)
]]

