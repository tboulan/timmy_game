extends Node2D

# current amount of each resource we have
var curFood : int = 0
var curMetal : int = 0
var curOxygen : int = 0
var curEnergy : int = 0

# amount of each resource we get each turn
var foodPerTurn : int = 0
var metalPerTurn : int = 0
var oxygenPerTurn : int = 0
var energyPerTurn : int = 0
var curTurn : int = 1

# are we currently placing down a building?
var currentlyPlacingBuilding : bool = false

# type of building we're currently placing
var buildingToPlace : int

# components
@onready var ui : Node = get_node("UI")
@onready var map : Node = get_node("Tiles")

func _ready():

	# updates the UI when the game starts
	ui.update_resource_text()
	ui.on_end_turn()

# called when the player ends the turn
func end_turn():
	# update our current resource amounts
	curFood += foodPerTurn
	curMetal += metalPerTurn
	curOxygen += oxygenPerTurn
	curEnergy += energyPerTurn
	# increase current turn
	curTurn += 1
	# update the UI
	ui.update_resource_text()
	ui.on_end_turn()

# called when we've selected a building to place
func on_select_building (buildingType):
	currentlyPlacingBuilding = true
	buildingToPlace = buildingType
	# highlight the tiles we can place a building on 
	# pass building type to prevent identical
	map.highlight_available_tiles(buildingType) 

# called when we place a building down on the grid
func place_building (tileToPlaceOn):
	currentlyPlacingBuilding = false
	var texture : Texture
	match buildingToPlace:
		BuildingData.Buildings.MINE:
			texture = BuildingData.mine.iconTexture
			add_to_resource_per_turn(BuildingData.mine.prodResource, BuildingData.mine.prodResourceAmount)
			add_to_resource_per_turn(BuildingData.mine.upkeepResource, -BuildingData.mine.upkeepResourceAmount)
		BuildingData.Buildings.GREENHOUSE:
			texture = BuildingData.greenhouse.iconTexture
			add_to_resource_per_turn(BuildingData.greenhouse.prodResource, BuildingData.greenhouse.prodResourceAmount)
			add_to_resource_per_turn(BuildingData.greenhouse.upkeepResource, -BuildingData.greenhouse.upkeepResourceAmount)
		BuildingData.Buildings.SOLAR_PANEL:
			texture = BuildingData.solarpanel.iconTexture
			add_to_resource_per_turn(BuildingData.solarpanel.prodResource, BuildingData.solarpanel.prodResourceAmount)
			add_to_resource_per_turn(BuildingData.solarpanel.upkeepResource, -BuildingData.solarpanel.upkeepResourceAmount)
		_:
			printerr("unkown buildingToPlace in GameManger.place_building")	
	# place the building on the map
	map.place_building(tileToPlaceOn, texture, buildingToPlace)
	# update the UI to show changes immediately
	ui.update_resource_text()

# adds an amount to a certain resource per turn
func add_to_resource_per_turn (resource, amount):

	# resource 0 means none, so return
	if resource == 0:
		return
	elif resource == 1:
		foodPerTurn += amount
	elif resource == 2:
		metalPerTurn += amount
	elif resource == 3:
		oxygenPerTurn += amount
	elif resource == 4:
		energyPerTurn += amount
