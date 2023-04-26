extends Node

# all the tiles in the game
var allTiles : Array

# all the tiles which have buildings on them
var tilesWithBuildings : Array

#Maybe - all tiles with terrain, or all rock/all trees

# size of a tile
var tileSize : float = 64.0

# Called when the node enters the scene tree for the first time.
func _ready ():
	# when we're initialized, get all of the tiles
	allTiles = get_tree().get_nodes_in_group("Tiles")
	# place random mountains
	
	# find the start tile and place the Base building
	for x in range(allTiles.size()):
		if allTiles[x].startTile == true:
			place_building(allTiles[x], BuildingData.base.iconTexture, 0)


# returns a tile at the given position - returns null if no tile is found
#**** might have to remove allTiles[x].hasBuilding == false sometime?
func get_tile_at_position(position):
	# loop through all of the tiles
	for x in range(allTiles.size()):
		# if the tile matches our given position, return it
		if allTiles[x].position == position and allTiles[x].hasBuilding == false:
			return allTiles[x]
	return null


# highlights the tiles we can place buildings on
func highlight_available_tiles(building_to_place: int):
	# loop through all of the tiles with buildings
	for x in range(tilesWithBuildings.size()):
		if tilesWithBuildings[x].get_building_type() == building_to_place:
			continue
		# get the tile north, south, east and west of this one
		var northTile = get_tile_at_position(tilesWithBuildings[x].position + Vector2(0, tileSize))
		var southTile = get_tile_at_position(tilesWithBuildings[x].position + Vector2(0, -tileSize))
		var eastTile = get_tile_at_position(tilesWithBuildings[x].position + Vector2(tileSize, 0))
		var westTile = get_tile_at_position(tilesWithBuildings[x].position + Vector2(-tileSize, 0))
		
		#print("N: ", typeof(northTile), ", S: ", southTile, ", E: ", eastTile, ", W: ", westTile)
		# if the directional tiles aren't null, 
		# toggle their highlight - allowing us to build
		if northTile != null:
			northTile.toggle_highlight(true)
		if southTile != null:
			southTile.toggle_highlight(true)
		if eastTile != null:
			eastTile.toggle_highlight(true)
		if westTile != null:
			westTile.toggle_highlight(true)

# disables all of the tile highlights
func disable_tile_highlights():
	for x in range(allTiles.size()):
		allTiles[x].toggle_highlight(false)
		
# places down a building on the map
func place_building(tile, texture, buildingType):
	tilesWithBuildings.append(tile)
	tile.place_building(texture, buildingType)
	disable_tile_highlights()


