extends Resource
class_name GenericItem

var itemName : String
var itemDescription : String
var itemValues : Array
var itemWeights : Array
var currentValue = null
var currentWeight = null
var texture

func initialize(name, description, values, weights, texturePath):
	itemName = name
	itemDescription = description
	itemValues = values
	itemWeights = weights
	texture = load(texturePath)

func setWeightValue(planetGravity):
	currentWeight = itemWeights[planetGravity]
	currentValue = itemValues[randi() % itemValues.size()]

func giveName():
	return itemName

func giveValue():
	return currentValue

func giveWeight():
	return currentWeight

func giveDescription():
	return itemDescription
