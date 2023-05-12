extends Area2D

# is this the starting tile?
# a Base building will be placed here at the start of the game
@export var startTile = false

# do we have a building on this tile?
var hasBuilding : bool = false

# can we place a building on this tile?
var canPlaceBuilding : bool = false

# what building is here?
var buildingType : int = BuildingData.Buildings.NONE

# components
@onready var highlight : Sprite2D = get_node("Highlight")
@onready var buildingIcon : Sprite2D = get_node("BuildingIcon")

# Called when the node enters the scene tree for the first time.
func _ready():
	# add the tile to the "Tiles" group when the node is initialized
	add_to_group("Tiles")

# turns on or off the green highlight
func toggle_highlight(toggle):
	highlight.visible = toggle
	canPlaceBuilding = toggle
	
	# called when a building is placed on the tile
# sets the tile's building texture to display it
func place_building(buildingTexture, type):
	hasBuilding = true
	buildingIcon.texture = buildingTexture
	buildingType = type
	print("buildingType: ", type)
	
func get_building_type() -> BuildingData.Buildings:
	return buildingType
	

# called when an input event takes place on the tile
func _on_Tile_input_event(_viewport, event, _shape_idx):
	# did we click on this tile with our mouse?
	if event is InputEventMouseButton and event.pressed:
		var gameManager = get_node("/root/MainScene")
		# if we can place a building down on this tile, then do so
		if gameManager.currentlyPlacingBuilding and canPlaceBuilding:
			gameManager.place_building(self)
