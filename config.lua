Config = {}

--machine has storage on ftp
Config.HackerHideout = {
    ip = "48.74.175.84",
    ram = 4,
    user="root",
    pass="1916200",
    deviceName="DoorLock"
}

Config.Atm = { --client to arcadius fleeca office
    [1] = {
        location = vector3(89.82, 2.28, 68.31),
        ip =  "204.67.248.146",
        response = "Location: Spanish Ave and Alta Street, IP: 204.67.248.146",
        user="hacked",
        pass="oculum",
        filesystem = {
           "oculum.exe"
        },
    }
    
}

Config.Routers = {
    [1] = {
        location = vector3(-583.0, 228.83, 79.4),
        routerip = "192.168.1.1",
        routerRange = 10,
        user="root",
        pass="1916200",
        displayName = "oculumNet",
        connectedClients = {
            ["48.74.175.84"] = {
                deviceName = "Door Lock",
            },
        },
        openPorts = {
            [20]=true, --ssh
            [21]=true, --ftp
            [22]=true,  --ftp
            [80]=false  --http
        },
        staticARPTable=false,
        filesystem = {
            Atm = {"atm.txt"},
            CCTV = {}
        },
    },
    [2] = { -- fleeca arcadius office
        location = vector3(-142.46, -596.03, 48.02),
        routerip = "10.1.1.48",
        routerRange = 30,
        user="fleecaadmin",
        pass="1984fleecahawicksandy",
        displayName = "FleecaArcadius",
        connectedClients = {
            ["204.67.248.146"] = {
                deviceName = "Fleeca ATM Hawick-Spanish"
            }
        },
        openPorts = {

        },
        staticARPTable=true,
        filesystem = {},
    },
    [3] = { -- burgershot free
        location = vector3(-1190.46, -888.45, 13.97),
        routerip = "197.208.31.201",
        routerRange = 30,
        user="burgershot",
        pass="",
        displayName = "Burgershot-FREE",
        connectedClients = {
            
        },
        openPorts = {

        },
        staticARPTable=false,
        filesystem = {},
    },
    [4] = { -- weis fiery wok free
        location = vector3(-661.88, -885.58, 24.64),
        routerip = "32.175.22.17",
        routerRange = 30,
        user="weis",
        pass="",
        displayName = "WeisFiery-FREE",
        connectedClients = {
            
        },
        openPorts = {

        },
        staticARPTable=false,
        filesystem = {},
    },
    [5] = { -- uwu cafe wifi
        location = vector3(-582.21, -1058.81, 22.34),
        routerip = "41.235.75.39",
        routerRange = 30,
        user="catluver",
        pass="",
        displayName = "ILuvCats",
        connectedClients = {
            
        },
        openPorts = {
            [20]=true, --ssh
            [21]=false, --ftp
            [22]=false,  --ftp
            [80]=false  --http
        },
        staticARPTable=false,
        filesystem = {},
    },
    [6] = { -- brean cafe
        location = vector3(120.93, -1037.36, 29.28),
        routerip = "232.64.213.113",
        routerRange = 30,
        user="bean",
        pass="",
        displayName = "morning_bean",
        connectedClients = {
            
        },
        openPorts = {

        },
        staticARPTable=false,
        filesystem = {},
    },
}


Config.Websites = {
    ["burgershot"] = {
        link = "www.burgershot.com",
        description = "Welcome to burgershot, we sell everything from bu...",
        homeIcon = "https://cdn.discordapp.com/attachments/1024130279784337438/1024157755533180959/unknown.png",
        ["site"]={
            backgroundColor = "",
            firstImage = "",
            secondSideImage = "",

        }
    }
}

Config.HomepageSites = {
    "burgershot",
}

Config.BlackMarketSite = {
    link = "silkroadwt1oui8s.onion"
}
--items you can get from blackmarket from locals per tsunami
Config.AvailableLocalItems = {
    {
        item = "weapon_microsmg",
        iteminfo = {serie = ""},
        quantity_left = 3,
        price = 3, --crypto
        title = "Micro SMG, serial removed",
        imagelink = "https://cdn.discordapp.com/attachments/995302330671046706/1026557573396168815/screenshot.jpg",
    },
    {
        item="coke_brick",
        iteminfo={},
        quantity_left = 8,
        price = 1.6, --crypto
        title = "Coke key",
        imagelink = "https://cdn.discordapp.com/attachments/1024130279784337438/1026552121438523524/coke.png",
    },
    {
        item="coke_brick",
        iteminfo={},
        quantity_left = 8,
        price = 1.9, --crypto
        title = "Coke key, pure",
        imagelink = "https://cdn.discordapp.com/attachments/1024130279784337438/1026552121438523524/coke.png",
    },
    {
        item="weapon_stickybomb",
        iteminfo={},
        quantity_left = 3,
        price = 11.4, --crypto
        title = "Mil-Grade High Explosives",
        imagelink = "https://cdn.discordapp.com/attachments/995302330671046706/1026558328421224598/screenshot.jpg",
    },
    {
        item="--stolenhousekey--",
        iteminfo={},
        quantity_left = 3,
        price = 11.4, --crypto
        title = "House key - 14 Picture Perfect",
        imagelink = "https://cdn.discordapp.com/attachments/995302330671046706/1026557879781699594/screenshot.jpg",
    },
}
