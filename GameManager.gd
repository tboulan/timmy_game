extends Node2D

# current amount of each resource we have
var curPeople : int = 10
var curFood : int = 50
var curMetal : int = 20
var curEnergy : int = 15

# amount of each resource we get each turn
var foodPerTurn : int = 0
var metalPerTurn : int = 0
var energyPerTurn : int = 0
var peoplePerTurn : int = 0
var curTurn : int = 0 # 0 will display Year: 1, Month: 1

# are we currently placing down a building?
var currentlyPlacingBuilding : bool = false

# type of building we're currently placing
var buildingToPlace : BuildingData.Buildings


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
	curEnergy += energyPerTurn
	resource_maximums_check()
	# People eat food
	curFood = curFood - curPeople
	food_problems_check()
	people_reproduce_check()
	map.trees_depleted_check()   # Tress next to food vats may be expended
	# increase current turn
	curTurn += 1
	# update the UI
	ui.update_resource_text()
	ui.on_end_turn()
	peoplePerTurn = 0 # reset to 0 if we reproduced this turn 


func resource_maximums_check():
	if curFood > 99:
		curFood = 99
	if curMetal > 99:
		curMetal = 99
	if curEnergy > 99:
		curEnergy = 99
	if curPeople > 99:
		# Add "You WIN Screen"
		pass


func people_reproduce_check():
	var numberBetween1and100 = randi() % 100 + 1
	#printerr("reproduce check: curPeople: ", curPeople, " - number 1to100: ", numberBetween1and100)
	if numberBetween1and100 <= curPeople:
		curPeople += 1
		peoplePerTurn = 1

func food_problems_check():
	# if you run out of food up to half the people die
	if curFood >= 0:
		return
	var numberDead = randi() % (curPeople / 2) + 1  #warning-ignore:integer_division
	var warning = str("we've run out of food, ", numberDead, " died!  But you do get ", numberDead, " more food.")
	printerr(warning)
	OS.alert(warning, 'People died from Starvation')
	curPeople = curPeople - numberDead
	curFood = numberDead


# called when we've selected a building to place
func on_select_building(buildingType):
	currentlyPlacingBuilding = true
	buildingToPlace = buildingType
	# highlight the tiles we can place a building on 
	# pass building type to prevent identical	
	if map.highlight_available_tiles(buildingType) == 0:
		# no tiles were highlighted, so no legal placement
		printerr("error - placing building not possible for building type ", buildingType, "...")
		OS.alert('No legal placement for that building.\nLose a turn due to incompetence!', 'Building Placement Error')

# called when we place a building down on the grid
func place_building (tileToPlaceOn):
	currentlyPlacingBuilding = false
	var texture : Texture
	match buildingToPlace:
		BuildingData.Buildings.MINE:
			curMetal = curMetal - 4  
			texture = BuildingData.mine.iconTexture
			add_to_resource_per_turn(BuildingData.mine.prodResource, BuildingData.mine.prodResourceAmount)
			add_to_resource_per_turn(BuildingData.mine.upkeepResource, -BuildingData.mine.upkeepResourceAmount)
		BuildingData.Buildings.GREENHOUSE:
			curMetal = curMetal - 3 
			texture = BuildingData.greenhouse.iconTexture
			add_to_resource_per_turn(BuildingData.greenhouse.prodResource, BuildingData.greenhouse.prodResourceAmount)
			add_to_resource_per_turn(BuildingData.greenhouse.upkeepResource, -BuildingData.greenhouse.upkeepResourceAmount)
		BuildingData.Buildings.SOLAR_PANEL:
			curMetal = curMetal - 2 
			texture = BuildingData.solarPanel.iconTexture
			add_to_resource_per_turn(BuildingData.solarPanel.prodResource, BuildingData.solarPanel.prodResourceAmount)
			add_to_resource_per_turn(BuildingData.solarPanel.upkeepResource, -BuildingData.solarPanel.upkeepResourceAmount)
		BuildingData.Buildings.CONNECTOR:
			curMetal = curMetal - 1 
			texture = BuildingData.connector.iconTexture
			add_to_resource_per_turn(BuildingData.connector.prodResource, BuildingData.connector.prodResourceAmount)
			add_to_resource_per_turn(BuildingData.connector.upkeepResource, -BuildingData.connector.upkeepResourceAmount)
		_:
			printerr("unknown buildingToPlace in GameManger.place_building")	
	# place the building on the map
	map.place_building(tileToPlaceOn, texture, buildingToPlace)
	# update the UI to show changes immediately
	ui.update_resource_text()

# adds an amount to a certain resource per turn
func add_to_resource_per_turn(resource, amount):
	# resource 0 means none, so return
	match resource:
		BuildingData.Resources.NONE:
			return
		BuildingData.Resources.FOOD:
			foodPerTurn += amount
		BuildingData.Resources.METAL:
			metalPerTurn += amount
		BuildingData.Resources.ENERGY:
			energyPerTurn += amount
		_:
			printerr("unknown resource in GameManger.add_to_resource_per_turn")	
