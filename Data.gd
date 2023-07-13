extends Node

enum Buildings {HILL=-2, TREE, NONE, BASE, MINE, VATS, SOLAR, CONNECTOR}
enum Resources {NONE, FOOD, METAL, ENERGY}

# ID, Image, resource produced, amount, resource consumed, amount
var base = Building.new(Buildings.BASE, preload("res://Sprites/Base.png"), 
		Resources.NONE, 0, Resources.NONE, 0)
var mine = Building.new(Buildings.MINE, preload("res://Sprites/Mine.png"), 
		Resources.METAL, 1, Resources.ENERGY, 1)
var vats = Building.new(Buildings.VATS, preload("res://Sprites/Vats.png"), 
		Resources.FOOD, 2, Resources.ENERGY, 1)
var solar = Building.new(Buildings.SOLAR, preload("res://Sprites/Solar.png"), 
		Resources.ENERGY, 2, Resources.NONE, 0)
var connector = Building.new(Buildings.CONNECTOR, preload("res://Sprites/Connector.png"), 
		Resources.NONE, 0, Resources.NONE, 0)

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
	func _init (newType, iTexture, pResource, pResourceAmount, uResource, uResourceAmount):
		self.type = newType
		self.iconTexture = iTexture
		self.prodResource = pResource
		self.prodResourceAmount = pResourceAmount
		self.upkeepResource = uResource
		self.upkeepResourceAmount = uResourceAmount
