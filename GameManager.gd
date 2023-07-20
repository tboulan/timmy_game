extends Node2D

# are we currently placing down a building?
var currentlyPlacingBuilding : bool = false

# type of building we're currently placing
var buildingToPlace : Data.Buildings

# current amount of each resource we have
var curPeople:	int = 10
var curFood:	int = 50
var curMetal:	int = 20
var curEnergy:	int = 15

# amount of each resource we get each turn
var foodPerTurn:	int = 0
var metalPerTurn:	int = 0
var energyPerTurn:	int = 0
var peoplePerTurn:	int = 0
var curTurn:	int = 0 # 0 will display Year: 1, Month: 1

# components
@onready var ui : Node = get_node("UI")
@onready var map : Node = get_node("Tiles")


func _ready():
	# updates the UI when the game starts
	ui.update_resource_text()
	ui.on_end_turn()


# called when the player ends the turn
func end_turn():
   # check for things that could reduce our resources
	curFood = curFood - curPeople  # People eat food
	food_problems_check()   	
	energy_problems_check()
	people_reproduce_check()
	# update our current resource amounts
	curFood += foodPerTurn
	curMetal += metalPerTurn
	curEnergy += energyPerTurn
	map.trees_hills_depleted_check()   # Tress next to food vats may be expended
	reset_resources_above_99()
	curTurn += 1  # increase current turn
	ui.update_resource_text()  
	ui.on_end_turn()
	peoplePerTurn = 0 # reset to 0 if we reproduced this turn 
	map.end_temporary_outage()  # restore buildings shutdown due to low power/people


func energy_problems_check():
	# if energy is less than zero, shut off some buildings
	if curEnergy < 0: 
		var number = map.start_temporary_outage(abs(curEnergy))
		var warning = str("Energy less than zero! number of buildings to turn off ", abs(number))
		print(warning)
		OS.alert(warning, 'Low on Energy')
		curEnergy = 0  # reset energy to zero


func reset_resources_above_99():
	if curFood > 99:	curFood = 99
	if curMetal > 99:	curMetal = 99
	if curEnergy > 99:	curEnergy = 99
	if curPeople > 99:	curPeople = 99  # Add "You WIN Screen" for 99 people?


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
	var numberDead : int = int(randi() % curPeople / 2.0) + 1
	var warning = str("You ran out of food, ", numberDead, " died!  But you do get ", numberDead, " more food.")
	print(warning)
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
		OS.alert('No legal placement for that building.\nLose a turn due to incompetence!', 'Building Placement Error')


func not_enough_metal_for_building():
	OS.alert('Not enough metal for that building.\nLose a turn due to incompetence!', 'Low on Metal')


# called when we place a building down on the grid
func place_building (tileToPlaceOn):
	currentlyPlacingBuilding = false
	var texture : Texture
	var enoughResources : bool = true
	match buildingToPlace:
		Data.Buildings.MINE:
			if curMetal < 4:
				enoughResources = false
				not_enough_metal_for_building()
			else:	
				curMetal = curMetal - 4  
				texture = Data.mine.iconTexture
				update_resource_per_turn(Data.mine.prodResource, Data.mine.prodResourceAmount)
				update_resource_per_turn(Data.mine.upkeepResource, -Data.mine.upkeepResourceAmount)
		Data.Buildings.VATS:
			if curMetal < 3:
				enoughResources = false
				not_enough_metal_for_building()
			else:
				curMetal = curMetal - 3 
				texture = Data.vats.iconTexture
				update_resource_per_turn(Data.vats.prodResource, Data.vats.prodResourceAmount)
				update_resource_per_turn(Data.vats.upkeepResource, -Data.vats.upkeepResourceAmount)
		Data.Buildings.SOLAR:
			if curMetal < 2:
				enoughResources = false
				not_enough_metal_for_building()
			else:	
				curMetal = curMetal - 2 
				texture = Data.solar.iconTexture
				update_resource_per_turn(Data.solar.prodResource, Data.solar.prodResourceAmount)
				update_resource_per_turn(Data.solar.upkeepResource, -Data.solar.upkeepResourceAmount)
		Data.Buildings.CONNECTOR:
			if curMetal < 1:
				enoughResources = false
				not_enough_metal_for_building()
			else:	
				curMetal = curMetal - 1 
				texture = Data.connector.iconTexture
				update_resource_per_turn(Data.connector.prodResource, Data.connector.prodResourceAmount)
				update_resource_per_turn(Data.connector.upkeepResource, -Data.connector.upkeepResourceAmount)
		_:
			printerr("unknown buildingToPlace in GameManger.place_building")	
	# place the building on the map
	if enoughResources:
		map.place_building(tileToPlaceOn, texture, buildingToPlace)
	else: 
		map.disable_tile_highlights()	
	# update the UI to show changes immediately
	ui.update_resource_text()

# adds an amount to a certain resource per turn
func update_resource_per_turn(resource, amount):
	match resource:
		Data.Resources.NONE:
			return
		Data.Resources.FOOD:
			foodPerTurn += amount
		Data.Resources.METAL:
			metalPerTurn += amount
		Data.Resources.ENERGY:
			energyPerTurn += amount
		_:
			printerr("unknown resource in GameManger.add_to_resource_per_turn")	
