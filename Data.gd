extends Node

enum Buildings {HILL=-2, TREE, NONE, BASE, MINE, VATS, SOLAR, CONNECTOR}
enum Resources {NONE, FOOD, METAL, ENERGY}

const MINE_PROD_AMOUNT = 1
const VATS_PROD_AMOUNT = 2
const SOLAR_PROD_AMOUNT = 2

const MINE_UPKEEP_AMOUNT = 1
const VATS_UPKEEP_AMOUNT = 1

# ID, Image, resource produced and amount, resource consumed and amount
var base = Building.new(Buildings.BASE, preload("res://Sprites/Base.png"), 
		Resources.NONE, 0, Resources.NONE, 0)
var mine = Building.new(Buildings.MINE, preload("res://Sprites/Mine.png"), 
		Resources.METAL, MINE_PROD_AMOUNT, Resources.ENERGY, MINE_UPKEEP_AMOUNT)
var vats = Building.new(Buildings.VATS, preload("res://Sprites/Vats.png"), 
		Resources.FOOD, VATS_PROD_AMOUNT, Resources.ENERGY, VATS_UPKEEP_AMOUNT)
var solar = Building.new(Buildings.SOLAR, preload("res://Sprites/Solar.png"), 
		Resources.ENERGY,SOLAR_PROD_AMOUNT, Resources.NONE, 0)
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
