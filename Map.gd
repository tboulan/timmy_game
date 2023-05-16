extends Node

# all the tiles in the game
var allTiles : Array

# all the tiles which have buildings on them
var tilesWithBuildings : Array

# tiles with buildings to be checked if legal
var tilesToHighlight : Array


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
	
	place_trees_and_hills()
	
	# find the start tile and place the Base building
	for x in range(allTiles.size()):
		if allTiles[x].startTile == true:
			# Base building
			place_building(allTiles[x], BuildingData.base.iconTexture, BuildingData.Buildings.BASE)
			
			# remove trees and hills next to base
			# (don't need null check, these must be in the middle of the map
			for adjacent in adjacents:
				get_tile_at_position2(allTiles[x].position + adjacent).reset()



# returns a tile at the given position - returns null if no tile is found
#**** might have to remove allTiles[x].hasBuilding == false sometime?
func get_tile_at_position(position):
	# loop through all of the tiles
	for x in range(allTiles.size()):
		# if the tile matches our given position, return it
		if allTiles[x].position == position and allTiles[x].hasBuilding == false:
			return allTiles[x]
	return null


func get_tile_at_position2(position):
	# loop through all of the tiles
	for x in range(allTiles.size()):
		# if the tile matches our given position, return it
		if allTiles[x].position == position:
			return allTiles[x]
	return null


# highlights the tiles we can place buildings on
func highlight_available_tiles(building_to_place: int):
	tilesToHighlight.clear()
	# loop through all of the tiles with buildings
	for x in range(tilesWithBuildings.size()):
		#can't place same building next to each other
		if tilesWithBuildings[x].get_building_type() == building_to_place:
			continue
		# get the tile north, south, east and west of this one
		for adjacent in adjacents:
			var tile = get_tile_at_position(tilesWithBuildings[x].position + adjacent)	
			# if not null, toggle their highlight - allowing us to build
			if tile != null:
				tilesToHighlight.append(tile)
				#tile.toggle_highlight(true)
	for x in range(tilesToHighlight.size()-1, 0, -1):
		# get the tile north, south, east and west of this one
		for adjacent in adjacents:
			var tile = get_tile_at_position(tilesToHighlight[x].position + adjacent)
			if tile!= null and tile.get_building_type() == building_to_place:
				tilesToHighlight.remove_at(x)


# disables all of the tile highlights
func disable_tile_highlights():
	for x in range(allTiles.size()):
		allTiles[x].toggle_highlight(false)
		
# places down a building on the map
func place_building(tile, texture, buildingType):
	if buildingType >= 0:   # don't add trees and hills
		tilesWithBuildings.append(tile)
	tile.place_building(texture, buildingType)
	disable_tile_highlights()


func place_trees_and_hills():
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
	
