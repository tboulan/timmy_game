extends Node

enum Buildings {NONE, BASE, MINE, GREENHOUSE, SOLAR_PANEL}
enum Resources {NONE, FOOD, METAL, ENERGY}

var base = Building.new(Buildings.BASE, preload("res://Sprites/Base.png"), 
		Resources.NONE, 0, Resources.NONE, 0)
var mine = Building.new(Buildings.MINE, preload("res://Sprites/Mine.png"), 
		Resources.METAL, 1, Resources.ENERGY, 1)
var greenhouse = Building.new(Buildings.GREENHOUSE, preload("res://Sprites/Greenhouse.png"), 
		Resources.FOOD, 1, Resources.ENERGY, 1)
var solarPanel = Building.new(Buildings.SOLAR_PANEL, preload("res://Sprites/SolarPanel.png"), 
		Resources.ENERGY, 1, Resources.NONE, 0)


class Building:
	# building type
	var type : Buildings
	# building texture
	var iconTexture : Texture
	# resource the building produces
	var prodResource : Resources
	var prodResourceAmount : int
	# resource the building needs to be maintained
	var upkeepResource : Resources
	var upkeepResourceAmount : int
	func _init (type, iconTexture, prodResource, prodResourceAmount, upkeepResource, upkeepResourceAmount):
		self.type = type
		self.iconTexture = iconTexture
		self.prodResource = prodResource
		self.prodResourceAmount = prodResourceAmount
		self.upkeepResource = upkeepResource
		self.upkeepResourceAmount = upkeepResourceAmount
