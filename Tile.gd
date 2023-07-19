extends Area2D

# is this the starting tile?
# a Base building will be placed here at the start of the game
@export var startTile = false

# Outages; set outage then also set tempOutage or permOutage
var outage: bool = false
var tempOutage: bool = false	# not enough power or people
var permOutage: bool = false 	# if all trees or hills used up

# can we place a building on this tile?
var canPlaceBuilding: bool = false

# what building is here?
var buildingType : Data.Buildings = Data.Buildings.NONE

# components
@onready var highlight: Sprite2D = get_node("Highlight")
@onready var buildingIcon: Sprite2D = get_node("BuildingIcon")
@onready var buildingFade: AnimationPlayer = get_node("BuildingFade")
@onready var turnRed: AnimationPlayer = get_node("RedAlert")

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
func place_building(buildingTexture, type): #, addbuilding=true):
	#hasBuilding = addbuilding
	# don't fade in base/rocks/trees
	var from_end : bool = true
	if type > Data.Buildings.BASE:
		from_end = false
	buildingFade.play("building_fade_in", -1, 1.0, from_end)
	buildingIcon.texture = buildingTexture
	buildingType = type
	#if type == Data.Buildings.BASE:
	#	turnRed.play("red_alert")


func get_building_type() -> Data.Buildings:
	return buildingType


func reset():
	#hasBuilding = false
	buildingIcon.texture = null
	buildingType = Data.Buildings.NONE


# called when an input event takes place on the tile
func _on_Tile_input_event(_viewport, event, _shape_idx):
	# did we click on this tile with our mouse?
	if event is InputEventMouseButton and event.pressed:
		var gameManager = get_node("/root/MainScene")
		# if we can place a building down on this tile, then do so
		if gameManager.currentlyPlacingBuilding and canPlaceBuilding:
			gameManager.place_building(self)
