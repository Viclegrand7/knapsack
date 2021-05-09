extends Resource
#class_name GameManager

const ressourcePath = "res://assets/items/"
const fileName = "statistics"

export var playerScore : int = 0 #Total value
export var playerInventory : Array = [] #Our current inventory, used to sell items

export var fullItemList : Array = [] #All the items we added ourself
export var itemStatisticsDictionary : Dictionary = {} #Their stats

export var vendorPossibilitiesInventory : Array = [] #No doubles, no item we just sold to him
export var vendorInventory : Array = [] #The actual inventory

#Exemple: 
#	"worm" : [
#				[30, 20, 45], /* <===== 3 valeurs possibles, choisies en random. Permet de représenter la richesse de la planète, le fiat que certaines ressources soient abondantes,... */
#				[5, 19, 12],  /* <===== 3 poids possibles, selon la planète (et sa gravite) */
#				"Si vous comptiez vous lancer dans l'élevage d'asticots, voilà le moment de commencer ! Mais s'il vous plaît, éloignez le de votre bouche..." /* <===== Description de l'objet */
#			 ]

signal planetInventoryInitialized #When the planet's inventory has been set up

func _ready():
	var file = File.new()
	file.open(ressourcePath + fileName, File.READ)
	var itemList = file.get_line()
	fullItemList = JSON.parse(itemList).result
	var dictionary = file.get_line()
	itemStatisticsDictionary = JSON.parse(dictionary).result
