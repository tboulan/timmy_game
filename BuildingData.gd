extends Node
enum Buildings { BASE, MINE, GREENHOUSE, SOLAR_PANEL}

# --- Resources ---
# none			= 0
# food			= 1
# metal			= 2
# oxygen		= 3
# energy		= 4


var base = Building.new(Buildings.BASE, preload("res://Sprites/Base.png"), 0, 0, 0, 0)
var mine = Building.new(Buildings.MINE, preload("res://Sprites/Mine.png"), 2, 1, 4, 1)
var greenhouse = Building.new(Buildings.GREENHOUSE, preload("res://Sprites/Greenhouse.png"), 1, 1, 0, 0)
var solarPanel = Building.new(Buildings.SOLAR_PANEL, preload("res://Sprites/SolarPanel.png"), 4, 1, 0, 0)
# var tree = Building.new(5, preload("res://Sprites/Trees1.png"), 0, 0,0 ,0)



class Building:
	# building type
	var type : int
	# building texture
	var iconTexture : Texture
	# resource the building produces
	var prodResource : int = 0
	var prodResourceAmount : int
	# resource the building needs to be maintained
	var upkeepResource : int = 0
	var upkeepResourceAmount : int
	func _init (type, iconTexture, prodResource, prodResourceAmount, upkeepResource, upkeepResourceAmount):
		self.type = type
		self.iconTexture = iconTexture
		self.prodResource = prodResource
		self.prodResourceAmount = prodResourceAmount
		self.upkeepResource = upkeepResource
		self.upkeepResourceAmount = upkeepResourceAmount
