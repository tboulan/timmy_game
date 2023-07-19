extends Node

# for printing grid tile X and Y
# print("   x: ", tiles[x].position.x/64+.5, "  y: ", tiles[x].position.y/64+.5, \
#    res: ", tiles[x].buildingIcon.texture.resource_path, "  rand: ", rand) 

# game manager object in order to access those functions and values
@onready var gameManager : Node = get_node("/root/MainScene")

# all the tiles in the game
var allTiles : Array

# all the tiles which have buildings on them
var tilesWithBuildings : Array

# tiles where buildings could be placed
var tileHighlights : Array

# size of a tile
var tileSize : float = 64.0

# for finding tiles north, south, east and westof selected tile
var adjacents = [
	Vector2(0, tileSize), Vector2(0, -tileSize), # north, south
	Vector2(tileSize, 0), Vector2(-tileSize, 0), # east, west
]

# Called when the node enters the scene tree for the first time.
func _ready ():
	# when we're initialized, get all of the tiles
	allTiles = get_tree().get_nodes_in_group("Tiles")
	
	place_random_trees_and_hills()
	
	# find the start tile and place the Base building
	for x in range(allTiles.size()):
		if allTiles[x].startTile == true:
			# Base building
			place_building(allTiles[x], Data.base.iconTexture, Data.Buildings.BASE)
			# remove trees and hills right next to base
			# (don't need null check, these must be in the middle of the map
			for adjacent in adjacents:
				get_tile_at_position(allTiles[x].position + adjacent).reset()
			break # don't have to search remaining tiles


# returns a tile at the given position - returns null if no tile is found
func get_tile_at_position(position, add_building_check: bool = false):
	# loop through all of the tiles
	for x in range(allTiles.size()):
		# if the tile matches our given position, return it
		if allTiles[x].position == position:
			if add_building_check:
				if allTiles[x].buildingType == Data.Buildings.NONE:
					return allTiles[x]
			else:
				return allTiles[x]
	return null


func get_x_tiles_next_to_y(building: Data.Buildings, terrain: Data.Buildings) -> Array:
	# could use this to make trees/hills depleted_check smaller
	var foundTiles: Array = []
	for x in range(tilesWithBuildings.size()):
		if tilesWithBuildings[x].get_building_type() == building and \
			tilesWithBuildings[x].outage == false:
			for adjacent in adjacents:
				var tile = get_tile_at_position(tilesWithBuildings[x].position + adjacent)
				if tile != null and tile.get_building_type() == terrain:
					foundTiles.append(tile)
					break  # finding one is enough
	return foundTiles


func trees_hills_depleted_check():
	# trees depletion check, find trees next to food vat
	var tiles = get_x_tiles_next_to_y(Data.Buildings.VATS, Data.Buildings.TREE)
	for x in range(tiles.size()):
		var rand = randi() % 100 
		if rand == 0:  # 1% chance of delpletion
			remove_building(tiles[x], \
				load(tiles[x].buildingIcon.texture.resource_path.replace(".png", "d.png")), \
				Data.Buildings.NONE)
			# I should remove resources, mark tile with outage + permOutage
	# hills depletion check, find trees next to food vat
	tiles = get_x_tiles_next_to_y(Data.Buildings.MINE, Data.Buildings.HILL)
	for x in range(tiles.size()):
		var rand = randi() % 100 
		if rand == 0:  # 1% chance of delpletion
			remove_building(tiles[x], \
				load(tiles[x].buildingIcon.texture.resource_path.replace(".png", "d.png")), \
				Data.Buildings.NONE)
			# I should remove resources, mark tile with outage + permOutage


func highlight_available_tiles(building_to_place: Data.Buildings) -> int:
	# highlights the tiles we can place buildings on
	tileHighlights.clear()
	# loop through all of the tiles with buildings
	for x in range(tilesWithBuildings.size()):
		#can't place same building next to each other
		if tilesWithBuildings[x].get_building_type() == building_to_place:
			continue
		get_tiles_next_to_buildings(x)
		
	remove_same_building_highlights(building_to_place)
	
	match building_to_place:
		Data.Buildings.MINE:
			remove_highlights_not_next_to_terrain(Data.Buildings.HILL)
		Data.Buildings.VATS:
			remove_highlights_not_next_to_terrain(Data.Buildings.TREE)
		Data.Buildings.SOLAR:
			remove_highlights_next_to_terrain()
		Data.Buildings.CONNECTOR:
			pass  # no limitation on placing a connector
		_:
			print("unknown building in Map.remove_same_building_highlights(): ", building_to_place)			
	
	for x in range(tileHighlights.size()):
		tileHighlights[x].toggle_highlight(true)

	#return number of tileHighlights for error checking
	return tileHighlights.size()


func remove_highlights_not_next_to_terrain(type: Data.Buildings):
	if tileHighlights.size() < 1: return
	for x in range(tileHighlights.size()-1, -1, -1):
		var remove = true
		for adjacent in adjacents:
			var tile = get_tile_at_position(tileHighlights[x].position + adjacent)
			if tile != null and tile.get_building_type() == type:
				remove = false
		if remove: tileHighlights.remove_at(x)


func remove_highlights_next_to_terrain():
	remove_same_building_highlights(Data.Buildings.HILL)
	remove_same_building_highlights(Data.Buildings.TREE)


func remove_same_building_highlights(building_to_place: Data.Buildings):
	if tileHighlights.size() < 1: return
	for x in range(tileHighlights.size()-1, -1, -1):
		var remove = false
		for adjacent in adjacents:
			var tile = get_tile_at_position(tileHighlights[x].position + adjacent)
			if tile != null and tile.get_building_type() == building_to_place:
				remove = true
		if remove: tileHighlights.remove_at(x)


func get_tiles_next_to_buildings(x: int):
	for adjacent in adjacents:
		var tile = get_tile_at_position(tilesWithBuildings[x].position + adjacent, true)	
		# if not null, add to highlight array - allowing us to build
		if tile != null:
			tileHighlights.append(tile)


# disables all of the tile highlights
func disable_tile_highlights():
	for i in range(allTiles.size()):
		allTiles[i].toggle_highlight(false)


# places down a building on the map
func place_building(tile, texture, buildingType):
	if buildingType >= Data.Buildings.BASE:   # don't add trees and hills
		tilesWithBuildings.append(tile)
	tile.place_building(texture, buildingType)
	disable_tile_highlights()


# filter for finding working mines and food vats
func working_m_and_g(tile):
	return ((tile.buildingType == Data.Buildings.MINE or 
		tile.buildingType == Data.Buildings.VATS) and 
		!tile.outage)


# filter for finding mines and food vats turned off due to outage
func temp_outage_m_and_g(tile):
	return ((tile.buildingType == Data.Buildings.MINE or 
		tile.buildingType == Data.Buildings.VATS) and 
		tile.outage)


func end_temporary_outage():
	var m_and_g: Array
	#var tile 
	m_and_g = tilesWithBuildings.filter(temp_outage_m_and_g)
	print("in end temp outage, m_and_g size: ", m_and_g.size())
	if m_and_g.size() < 1: return   # for debugging, this can be removed
	for tile in m_and_g:
		if tile.tempOutage == true:
			tile.tempOutage = false
			tile.turnRed.stop(true)  #play("red_alert")
			if tile.permOutage == false:
				tile.outage = false
				# add back food or metal here
				match tile.buildingType:
					Data.Buildings.MINE:
						gameManager.update_resource_per_turn(Data.Resources.METAL, Data.MINE_PROD_AMOUNT)
						gameManager.update_resource_per_turn(Data.Resources.ENERGY, -Data.MINE_UPKEEP_AMOUNT)
					Data.Buildings.VATS:
						gameManager.update_resource_per_turn(Data.Resources.METAL, Data.MINE_PROD_AMOUNT)
						gameManager.update_resource_per_turn(Data.Resources.ENERGY, -Data.MINE_UPKEEP_AMOUNT)
	

func start_temporary_outage(number: int) -> int:
	#if low on power (or people?), shut down some buildings
	var tile 
	var m_and_g: Array
	m_and_g = tilesWithBuildings.filter(working_m_and_g)
	print("m_and_g size: ", m_and_g.size())
	if m_and_g.size() < number:
		# not enough buildings to turm off, turn off all of them
		number = m_and_g.size()
	m_and_g.shuffle()
	for i in range(number):
		tile = m_and_g[i]
		tile.outage = true
		tile.tempOutage = true
		tile.turnRed.play("red_alert")
		print("   x: ", tile.position.x/64+.5, "  y: ", tile.position.y/64+.5, \
			"res: ", tile.buildingIcon.texture.resource_path) 
		# subtract food or metal here
		match tile.buildingType:
			Data.Buildings.MINE:
				gameManager.update_resource_per_turn(Data.Resources.METAL, -Data.MINE_PROD_AMOUNT)
				gameManager.update_resource_per_turn(Data.Resources.ENERGY, Data.MINE_UPKEEP_AMOUNT)
			Data.Buildings.VATS:
				gameManager.update_resource_per_turn(Data.Resources.METAL, -Data.MINE_PROD_AMOUNT)
				gameManager.update_resource_per_turn(Data.Resources.ENERGY, Data.MINE_UPKEEP_AMOUNT)
	return number

#remove a building from the map
func remove_building(tile, texture, buildingType):
	tilesWithBuildings.erase(tile)
	tile.place_building(texture, buildingType)
	

func place_random_trees_and_hills():
	# Three different looking trees to be picked at random
	var tree1 = preload("res://Sprites/Tree1.png")
	var tree2 = preload("res://Sprites/Tree2.png")
	var tree3 = preload("res://Sprites/Tree3.png")

	# Three different looking hills to be picked at random
	var hill1 = preload("res://Sprites/Hill1.png")
	var hill2 = preload("res://Sprites/Hill2.png")
	var hill3 = preload("res://Sprites/Hill3.png")

	# Place random hills and trees
	for x in range(1, 20):
		place_building(allTiles.pick_random(), [tree1, tree2, tree3].pick_random(), -1)	
		place_building(allTiles.pick_random(), [hill1, hill2, hill3].pick_random(), -2)	
	
