local QBCore = exports['qb-core']:GetCoreObject()

local ATMsOnCooldown = {}
local networks = {}

local IPtoPlayerSource = {}

local listenersOnNet = {}
--[[
    {
        ["netIP"]= {
            playersrc,
            playersrc2
        }
    }
]]

--functions
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    --resource started
    --populate list of networks from config. Networks can be added to live
    for i, k in pairs(Config.Routers) do
        networks[k.routerip] = k
    end
end)

Citizen.CreateThread(function()
    while true do 
        for routerIP, net in pairs(networks) do
            --send packets to clietns, receive packets
            if routerIP == "222.200.27.81" then
                for clientIP, k in pairs(net.connectedClients) do
                    TriggerEvent('ph-laptop:server:sendHeartBeatPacket', clientIP, routerIP, "Source: " .. clientIP.. " Destination: ".. routerIP.. " Protocol: TCP" .. " Data: TCP HEARBEAT, NET: GREEN SEC")
                end
                
            end
            
        end
        Citizen.Wait(2000)
    end
    
end)



--usable items

QBCore.Functions.CreateUseableItem('laptop' , function(source, item)
    TriggerClientEvent('ph-laptop:client:openLaptop', source)
 end)
 QBCore.Functions.CreateUseableItem('markedbills' , function(source, item)
    TriggerClientEvent('markedbills:UseMarkedbills', source)
 end)

QBCore.Functions.CreateCallback('ph-laptop:server:GetDate', function(_, cb)
    local datenow = os.date("%y/%m/%d %X")
    cb(datenow)
end)

RegisterNetEvent('ph-laptop:server:startpacketsniff', function(source, reachableNets)
    print("starting sniffing")
    for _, k in pairs(reachableNets) do
        if listenersOnNet[k.routerip] == nil then listenersOnNet[k.routerip] = {} end
        table.insert(listenersOnNet[k.routerip], source)
        print("added listener to", k.routerip)
    end
end)
RegisterNetEvent('ph-laptop:server:stoppacketsniff', function(source, reachableNets)
    print("stopped sniffing")
    for i, k in pairs(listenersOnNet) do
        for j,l in pairs(k) do 
            if l==source then
                table.remove(listenersOnNet[i], j)
                print("removed listenr from ", i)
            end
        end
    end
end)

RegisterNetEvent('ph-laptop:server:sendHeartBeatPacket',function(sourceIP, targetIP, packetData)
    for i, k in pairs(listenersOnNet) do
        if i == sourceIP or i == targetIP then 
            for _, src in pairs(k) do
                TriggerClientEvent('ph-laptop:client:capturePacket', src, packetData)
            end
        end
    end
end)
RegisterNetEvent('ph-laptop:server:sendServicePacket', function(source, sourceIP, targetIP, packetData, request)
    if request then 
        for i, k in pairs(listenersOnNet) do
            if i == sourceIP or i == targetIP then 
                for _, src in pairs(k) do
                    TriggerClientEvent('ph-laptop:client:capturePacket', src, packetData)
                end
               
            end
        end
        if sourceIP == "54.64.98.4" and targetIP == "222.200.27.81" then
            --send reply
            TriggerEvent('ph-laptop:server:sendServicePacket', source, "222.200.27.81", "54.64.98.4", "Source: " .. "222.200.27.81".. " Destination: ".. "54.64.98.4".. " Protocol: UDP" .. " Data: REPLY CREDENTIAL CHECK " .. source .. " GREEN SEC RESULT: DENY", false)
        end
    else
        for i, k in pairs(listenersOnNet) do
            if i == sourceIP or i == targetIP then 
                for _, src in pairs(k) do
                    TriggerClientEvent('ph-laptop:client:capturePacket', src, packetData)
                end
               
            end
        end
        if sourceIP == "222.200.27.81" and targetIP=="54.64.98.4" then
            print(packetData)
            if packetData== "ource: 222.200.27.81 Destination: 54.64.98.4 Protocol: UDP Data: REPLY CREDENTIAL CHECK " .. source .. " GREEN SEC RESULT: ACCEPT" then
                TriggerClientEvent('ph-laptop:client:unlockFirstNukeDoor', source)

            end
        end
    end
  
end)
RegisterNetEvent('ph-laptop:server:ftpgetdata', function(filename,filetype)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local laptoptable = player.PlayerData.metadata["laptopdata"]
    if filename == "atm" then
        table.insert(laptoptable,""..filename..".txt")
        player.Functions.SetMetaData("laptopdata",laptoptable)
    end
end)

--connect, disconnect and get clients
RegisterNetEvent('ph-laptop:server:connectToNet', function(source, netIP, clientIP, clientDeviceName)
    if networks[netIP] == nil then networks[netIP] = {routerip = netIP, routerRange = 10, user="", pass="", displayName="New Network", connectedClients = {}} end

    networks[netIP].connectedClients[clientIP] = {deviceName = clientDeviceName}
    --table.insert(networks[netIP].connectedClients, clientIP)

    IPtoPlayerSource[clientIP] = source
end)
QBCore.Functions.CreateCallback('ph-laptop:server:getNetClients', function(_, cb, netIP)
    cb(networks[netIP].connectedClients)
end)
QBCore.Functions.CreateCallback('ph-laptop:server:getNetworks', function(_, cb)
    cb(networks)
end)

RegisterNetEvent('ph-laptop:server:disconnectFromNet', function(source, netIP, clientIP)
   -- table.remove(networks[netIP].connectedClients, indexOf(networks[netIP].connectedClients, clientIP))
    networks[netIP].connectedClients[clientIP] = nil
    IPtoPlayerSource[clientIP] = nil
end)

RegisterNetEvent('ph-laptop:server:disconnectTargetFromNet', function(source, netIP, clientIP, targetIP)
    networks[netIP].connectedClients[targetIP] = nil
    --Tell client hes been disconnected 
    local playersrc = IPtoPlayerSource[targetIP]
    IPtoPlayerSource[targetIP] = nil
    print(source)
    if playersrc == nil then
        TriggerClientEvent('ph-laptop:client:disconnectNonPlayerFromNet', source, targetIP)
    else
        TriggerClientEvent('ph-laptop:client:disconnectFromNet', playersrc)
    end
    
end)

RegisterNetEvent('ph-laptop:server:exchangeMarkedBills', function()
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem("markedbills", 1)
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items["markedbills"], "remove", 1)

    Player.Functions.AddItem('cryptostick', 2, nil, {["quality"] = 100}) 
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['cryptostick'], "add", 2)
end)

RegisterNetEvent('ph-laptop:server:unlockDoomsdayDoor', function()
    TriggerClientEvent('ph-laptop:client:doomsdaydooropen', -1)
end)

RegisterNetEvent('ph-laptop:server:loginAttempt', function(site, user, pass)
    print("logging in")
    local matches = MySQL.query.await("SELECT password FROM websitelogins WHERE websitename=:sentSite AND username=:sentuser LIMIT 1;", 
    {
        sentSite = site,
        sentuser = user,
    })
    if not matches or not matches[1] then
        --username doesnt exist on this website
        print("username not on site")
    else
        --username exists, check password
        print("found sql pass:", matches[1].password)
        if matches[1].password == pass then
            print("correct")
        else
            print("wrong")
        end
    end
end)

RegisterNetEvent('ph-laptop:server:getBlackMarketItems', function()
    local items = {}

    for i,k in pairs(Config.AvailableLocalItems) do
        items[#items+1] = {
            localitem =  true,
            index = i,

            item = k.item,
            iteminfo = k.iteminfo,
            quantity_left = k.quantity_left,
            price = k.price,
            title = k.title,
            imagelink = k.imagelink,
        }
    end

    --read from SQL for player advertisements
    --items = items[#items+1] = {}
    TriggerClientEvent('ph-laptop:client:returnBlackMarketItems', source, items)
end)

QBCore.Functions.CreateCallback('ph-laptop:server:getPostData', function(source, cb, data)
    local locIndex = data.localIndex
    local playIndex = data.playerIndex
    print("both null")
    print(data)
    print("loc:", locIndex)
    print("play", playIndex)
    if not locIndex and not playIndex then return cb({}) end
    local src = source
    print("looking for ad data")

    if locIndex then
        print("send back ad data")
        return cb(Config.AvailableLocalItems[locIndex])
    elseif playIndex then
        --query sql at index, give item data
        return cb({})
    end
    
end)


QBCore.Functions.CreateCallback('ph-laptop:server:searchQuery', function(source, cb, query)
    if not query then return cb({}) end
    local src = source
    local result = {}
    for i, k in pairs(Config.Websites) do
        if string.match(i, query) or string.match(k.link, query) then
            result[#result+1] = {
                sitename = i,
                sitedata = k
            }
        end
    end

    return cb(result)
end)

--immediately return first address found
QBCore.Functions.CreateCallback('ph-laptop:server:searchAddress', function(source, cb, address)
    if not address then return cb({}) end
    local src = source
    local result = {}
    for i, k in pairs(Config.Websites) do
        if k.link == address then
            result[#result+1] = {
                sitename = i,
                sitedata = k
            }
            return cb(result)
        end
    end

    if Config.BlackMarketSite.link == address then
        result[#result+1] = {
            sitename = "slikroad",
            sitedata = Config.BlackMarketSite
        }
        return cb(result)
    end

    return cb(result)
end)
