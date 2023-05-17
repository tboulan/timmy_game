extends Node

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
			place_building(allTiles[x], BuildingData.base.iconTexture, BuildingData.Buildings.BASE)
			# remove trees and hills right next to base
			# (don't need null check, these must be in the middle of the map
			print("Base location: ", allTiles[x].position / Vector2(64, 64) + Vector2(.5, .5))
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
				if allTiles[x].hasBuilding == false:
					return allTiles[x]
			else:
				return allTiles[x]
	return null


# highlights the tiles we can place buildings on
func highlight_available_tiles(building_to_place: int):
	tileHighlights.clear()
	# loop through all of the tiles with buildings
	for x in range(tilesWithBuildings.size()):
		#can't place same building next to each other
		if tilesWithBuildings[x].get_building_type() == building_to_place:
			continue
		get_tiles_next_to_buildings(x)
		
	remove_same_building_highlights(building_to_place)
	
	match building_to_place:
		BuildingData.Buildings.MINE:
			remove_highlights_not_next_to_terrain(BuildingData.Buildings.HILL)
		BuildingData.Buildings.GREENHOUSE:
			remove_highlights_not_next_to_terrain(BuildingData.Buildings.TREE)
		BuildingData.Buildings.SOLAR_PANEL:
			remove_highlights_next_to_terrain()
		BuildingData.Buildings.CONNECTOR:
			pass  # no limitation on placing a connector
		_:
			print("unknown building in Map.remove_same_building_highlights(): ", building_to_place)			
	
	#check if tileHighlights is empty, then do error or repick building
	for x in range(tileHighlights.size()):
		tileHighlights[x].toggle_highlight(true)


func remove_highlights_not_next_to_terrain(type: BuildingData.Buildings):
	if tileHighlights.size() < 1: return
	for x in range(tileHighlights.size()-1, -1, -1):
		var remove = true
		for adjacent in adjacents:
			var tile = get_tile_at_position(tileHighlights[x].position + adjacent)
			if tile != null and tile.get_building_type() == type:
				remove = false
		if remove: tileHighlights.remove_at(x)

func remove_highlights_next_to_terrain():
	remove_same_building_highlights(BuildingData.Buildings.HILL)
	remove_same_building_highlights(BuildingData.Buildings.TREE)

func remove_same_building_highlights(building_to_place: int):
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
	for x in range(allTiles.size()):
		allTiles[x].toggle_highlight(false)


# places down a building on the map
func place_building(tile, texture, buildingType):
	if buildingType >= BuildingData.Buildings.BASE:   # don't add trees and hills
		tilesWithBuildings.append(tile)
	tile.place_building(texture, buildingType)
	disable_tile_highlights()


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
	
