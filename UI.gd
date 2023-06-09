extends Control

# container holding the building buttons
@onready var buildingButtons : Node = get_node("BuildingButtons")

# text displaying the food and metal resources
@onready var foodMetalText : Label = get_node("FoodMetalText")

# text displaying the oxygen and energy resources
@onready var peopleEnergyText : Label = get_node("PeopleEnergyText")

# text showing our current turn
@onready var curTurnText : Label = get_node("TurnText")

# game manager object in order to access those functions and values
@onready var gameManager : Node = get_node("/root/MainScene")

# called when a turn is over - resets the UI
func on_end_turn():
	# updates the cur turn text (year/month) and enable the building buttons
	curTurnText.text = str(gameManager.curTurn / 12 + 1) + "\n" + str(gameManager.curTurn % 12 + 1)
	buildingButtons.visible = true

# updates the resource text to show the current values
func update_resource_text():
	# set the food and metal text
	var foodMetal = ""
	# sets the text, e.g. "13 (+5)"
	foodMetal += str(gameManager.curFood) + " (" + ("+" if gameManager.foodPerTurn >= 0 else "") \
		+ str(gameManager.foodPerTurn) + ")"
	foodMetal += "\n"
	foodMetal += str(gameManager.curMetal) + " (" + ("+" if gameManager.metalPerTurn >= 0 else "") \
		+ str(gameManager.metalPerTurn) + ")"  
	foodMetalText.text = foodMetal

	# set the oxygen and energy text
	var peopleEnergy = ""
	# set the text, e.g. "13 (+5)"
	peopleEnergy += str(gameManager.curPeople) + " (" + ("+" if gameManager.peoplePerTurn >= 0 else "") + str(gameManager.peoplePerTurn) + ")"
	peopleEnergy += "\n"
	peopleEnergy += str(gameManager.curEnergy) + " (" + ("+" if gameManager.energyPerTurn >= 0 else "") + str(gameManager.energyPerTurn) + ")"
	peopleEnergyText.text = peopleEnergy


# called when the Mine building button is pressed
func _on_mine_button_pressed():
	buildingButtons.visible = false
	gameManager.on_select_building(Data.Buildings.MINE)

# called when the VATS building button is pressed
func _on_vats_button_pressed():
	buildingButtons.visible = false
	gameManager.on_select_building(Data.Buildings.VATS)

# called when the Solar Panel building button is pressed
func _on_solar_button_pressed():
	buildingButtons.visible = false
	gameManager.on_select_building(Data.Buildings.SOLAR)

# called when the Inter-Connector button is pressed
func _on_connector_button_pressed():
	buildingButtons.visible = false
	gameManager.on_select_building(Data.Buildings.CONNECTOR)


func _on_end_turn_button_pressed():
	gameManager.end_turn()
