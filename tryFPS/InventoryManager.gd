extends Control
#class_name GameManager

signal onButtonPressed

const ressourcePath = "res://assets/items/"
const fileName = "statistics"

export var playerScore : int = 0 #Total value
export var computerScore : int = 0
export var playerInventory : Array #Our current inventory, used to sell items

export var fullItemNamesList : Array#All the item names we added ourself
export var fullItemList : Array #All the items we added ourself
export var itemStatisticsDictionary : Dictionary #Their stats

export var vendorPossibilitiesInventory : Array #No doubles, no item we just sold to him
export var vendorInventory : Array #The actual inventory

export var difficultyKnapsack = 15

#Exemple: 
#	"worm" : [
#				[30, 20, 45], /* <===== 3 valeurs possibles, choisies en random. Permet de représenter la richesse de la planète, le fiat que certaines ressources soient abondantes,... */
#				[5, 19, 12],  /* <===== 3 poids possibles, selon la planète (et sa gravite) */
#				"Si vous comptiez vous lancer dans l'élevage d'asticots, voilà le moment de commencer ! Mais s'il vous plaît, éloignez le de votre bouche...", /* <===== Description de l'objet */
#				"worm.png"
#			 ]

var heldItem = null

onready var toolTip = $ItemPrecision
onready var planetInventoryManager = $PlanetInventory
onready var playerInventoryManager = $PlayerInventory

#signal planetInventoryInitialized #When the planet's inventory has been set up

func _ready():
	playerInventory = []
	fullItemNamesList  = []
	fullItemList = []
	itemStatisticsDictionary = {}
	vendorPossibilitiesInventory = []
	vendorInventory = []
	
	planetInventoryManager.isPlanet = true
	playerInventoryManager.isPlanet = false
	playerInventoryManager.weightLabel = $PlayerInventory/Weight/Label
	playerInventoryManager.valueLabel = $PlayerInventory/Value/Label

	var file = File.new()
	file.open(ressourcePath + fileName, File.READ)
	var itemList = file.get_line()
#	print(itemList)
	fullItemNamesList = JSON.parse(itemList).result
	var dictionary = file.get_line()
	itemStatisticsDictionary = JSON.parse(dictionary).result
	for i in fullItemNamesList:
		fullItemList.append(GenericItem.new(i, itemStatisticsDictionary[i][2], itemStatisticsDictionary[i][0], itemStatisticsDictionary[i][1], ressourcePath + itemStatisticsDictionary[i][3]))
#										name, 		description, 				values, 							weights, 						texturePath):
	randomize()

func createPlanetInventory():
	vendorPossibilitiesInventory = fullItemList.duplicate()
	if playerInventory.size():
		for i in playerInventory:
			#playerScore += i.giveValue()
			playerInventory.erase(i)
			vendorPossibilitiesInventory.erase(i)

	vendorInventory = []


	while vendorInventory.size() < difficultyKnapsack and vendorPossibilitiesInventory.size() > 0:
		var position = randi() % vendorPossibilitiesInventory.size()
		vendorInventory.append(vendorPossibilitiesInventory[position])
		vendorPossibilitiesInventory.remove(position)
	
	var planetGravity = 0
	
	var stringKnapsackValues = ""
	var stringKnapsackWeights = ""
	
	for i in vendorInventory:
		i.setWeightValue(planetGravity)
		var newSlot = getPlanetFreeSlot()
		newSlot.item = i
		newSlot.add_child(i)
		newSlot.refreshColors()
		stringKnapsackValues += "," + str(i.giveValue())
		stringKnapsackWeights += "," + str(i.giveWeight())
	get_node("/root/MotherNode").sendToServer("P" + str(vendorInventory.size()) + stringKnapsackWeights + stringKnapsackValues)

func createLootingInventory():
	vendorPossibilitiesInventory = fullItemList.duplicate()
	if playerInventory.size():
		for i in playerInventory:
			i.setWeightValue(0)
			vendorPossibilitiesInventory.erase(i)

	vendorInventory = []

	while vendorInventory.size() < difficultyKnapsack and vendorPossibilitiesInventory.size() > 0:
		var position = randi() % vendorPossibilitiesInventory.size()
		vendorInventory.append(vendorPossibilitiesInventory[position])
		vendorPossibilitiesInventory.remove(position)

	var planetGravity = 0

	for i in vendorInventory:
		i.setWeightValue(planetGravity)
		var newSlot = getPlanetFreeSlot()
		newSlot.item = i
		newSlot.add_child(i)
		newSlot.refreshColors()

func getPlanetFreeSlot():
	return planetInventoryManager.getFreeSlot()

func getPlayerFreeSlot():
	return playerInventoryManager.getFreeSlot()

func swapItemWeightValue(item, comesFromPlanet):
# warning-ignore:standalone_ternary
	playerInventoryManager.addWeightValue(item) if comesFromPlanet else playerInventoryManager.subWeightValue(item)

func _on_DoneButton_pressed():
	for slot in playerInventoryManager.slotList:
		if slot.item:
			playerInventory.append(slot.item)
			slot.remove_child(slot.item);
			slot.item = null;
			slot.refreshColors();
	for slot in planetInventoryManager.slotList:
		if slot.item:
			slot.remove_child(slot.item);
			slot.item = null;
			slot.refreshColors();
	playerInventoryManager.weightLabel.set_text("Weight: 0")
	get_node("/root/MotherNode").sendToServer("S" + str(playerScore))
	emit_signal("onButtonPressed")
	playerScore = int(playerInventoryManager.valueLabel.get_text())
	print(playerScore)
