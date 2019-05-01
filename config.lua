Config                        = {}
Config.DrawDistance           = 100
Config.MarkerSize             = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor            = {r = 102, g = 102, b = 204}
Config.RoomMenuMarkerColor    = {r = 102, g = 204, b = 102}
Config.MarkerType             = 23
Config.Zones                  = {}
Config.Properties             = {}
Config.EnablePlayerManagement = false -- If set to true you need esx_realestateagentjob
Config.Locale                 = 'en'

Config.Properties             = {}

--[[ Garage config ]]--

Config.Private_Garage = {
	DrawDistance = 100,
	Price = 100,
	BlipInfos = {
		Sprite = 290,
		Color = 56 
	}
}

Config.Garages = {
	Private = {	
		Pos = {x=-182.09, y=505.87, z=135.53},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'WildOatsDrive',
		Marker = 1,
		SpawnPoint = {
			Pos = {x=-190.02, y= 502.33, z= 133.33},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=324.63,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=-187.29, y=502.07, z=133.68},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23
		},
	},
	Private2 = {	
		Pos = {x=124.14, y=565.8, z=184.04},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'WhispymoundDrive',
		Marker = 1,
		SpawnPoint = {
			Pos = {x=125.72, y=569.55, z=182.26},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=275.99,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=131.98, y=565.59, z=182.94},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23,
		},	
	},
	
	Private3 = {	
		Pos = {x=378.4, y=431.72, z=144.11},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'NorthConkerAvenue2045',
		Marker = 23,
		SpawnPoint = {
			Pos = {x=383.03, y=432.88, z=142.78},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=260.0,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=391.54, y=429.56, z=142.84},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23
		},
	},
	
	Private4 = {	
		Pos = {x=-895.21, y=-345.27, z=34.53},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'RichardMajesticApt2',
		Marker = 1,
		SpawnPoint = {
			Pos = {x=-885.77, y=-345.57, z=33.58},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=204.39,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=-895.21, y=-345.27, z=33.58},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23
		},
		
	},
    
	Private5 = {	
		Pos = {x=-687.52, y=601.27, z=143.36},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'HillcrestAvenue2862',
		Marker = 1,
		SpawnPoint = {
			Pos = {x=-682.43, y=607.15, z=143.02},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=7.28,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=-683.47, y=601.96, z=142.66},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23,
			
		},
		
	},
	
	Private6 = {	
		Pos = {x=-1296.51, y=455.75, z=96.43},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'MadWayneThunder',
		Marker = 1,
		SpawnPoint = {
			Pos = {x=-1290.31, y=457.87, z=95.82},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=274.79,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=-1297.75, y=455.64, z=96.49},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23,
			
		},
		
	},
	
	Private7 = {	
		Pos = {x=-864.25, y=697.79, z=149.03},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'HillcrestAvenue2874',
		Marker = 1,
		SpawnPoint = {
			Pos = {x=-863.42, y=703.31, z=148.14},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=285.05,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=-864.25, y=697.79, z=149.08},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23
		},
	},
	
	Private8 = {
		Pos = {x=334.88, y=-557.46, z=40.0},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'HillcrestAvenue2868',
		Marker = 1,	
		SpawnPoint = {
			Pos = {x=-747.84, y=618.62, z=141.29},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=194.41,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=-753.91, y=627.24, z=141.68},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23
		},
	},
	
	Private9 = {
		Pos = {x=-619.33, y=53.53, z=42.79},
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Color = {r = 204, g = 204, b = 0},
		House = 'TinselTowersApt12',
		Marker = 1,	
		SpawnPoint = {
			Pos = {x=-619.95, y=60.29, z=42.79},
			Color = {r=0,g=255,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Heading=111.03,
			Marker = 23		
		},
		DeletePoint = {
			Pos = {x=-619.33, y=53.53, z=42.79},
			Color = {r=255,g=0,b=0},
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Marker = 23
		},
	}
}

