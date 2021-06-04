extends Panel

var slotList : Array

export var MAX_SLOT = 30
const itemSlotClass = preload("res://ItemSlot.gd")

onready var itemDisplayer = $"../ItemPrecision"
onready var allInventoriesManager = get_node("..")

var isPlanet
var weightLabel = null #only for player
var valueLabel = null #only for player

var itemOffset = Vector2(-1, -1)


func _ready():
	var slots = $InventoryScroller/ItemSlot
	for _i in range(MAX_SLOT):
		var slot = itemSlotClass.new()
		slot.connect("mouse_entered", self, "mouse_enter_slot", [slot])
		slot.connect("mouse_exited" , self, "mouse_exit_slot" , [slot])
		slot.connect("gui_input"    , self, "slot_input"      , [slot])
		slotList.append(slot)
		slots.add_child(slot)

func mouse_enter_slot(slot):
	if slot.item:
		itemDisplayer.displayItem(slot.item)

func mouse_exit_slot(slot):
	if slot.item:
		itemDisplayer.hideItem(slot.item)

func slot_input(event : InputEvent, slot : itemSlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if allInventoriesManager.heldItem:
				if !slot.item:
					slot.putItem(allInventoriesManager.heldItem);
					allInventoriesManager.heldItem = null;
					addWeightValue(slot.item)
				else:
					var tempItem = slot.item;
					slot.pickItem();
					subWeightValue(tempItem)
					tempItem.rect_global_position = event.global_position - itemOffset;
					slot.putItem(allInventoriesManager.heldItem);
					addWeightValue(slot.item)
					allInventoriesManager.heldItem = tempItem;
			elif slot.item:
				allInventoriesManager.heldItem = slot.item;
				slot.pickItem();
				subWeightValue(allInventoriesManager.heldItem)
				allInventoriesManager.heldItem.rect_global_position = event.global_position - itemOffset;
		elif event.button_index == BUTTON_RIGHT && !event.pressed:
			if slot.item:
				var freeSlot  = allInventoriesManager.getPlayerFreeSlot() if isPlanet else allInventoriesManager.getPlanetFreeSlot()
				if freeSlot:
					var item = slot.item;
					allInventoriesManager.swapItemWeightValue(item, isPlanet)
					slot.pickItem();
					freeSlot.putItem(item);
					itemDisplayer.hide()

func _input(event):
	if allInventoriesManager.heldItem:
		allInventoriesManager.heldItem.rect_global_position = event.global_position - itemOffset;

func addWeightValue(item):
	if not isPlanet:
		var currentWeight = int(weightLabel.get_text())
		currentWeight += item.giveWeight()
		weightLabel.set_text(str(currentWeight))

		var currentValue = int(valueLabel.get_text())
		currentValue += item.giveValue()
		valueLabel.set_text(str(currentValue))

func subWeightValue(item):
	if not isPlanet:
		var currentWeight = int(weightLabel.get_text())
		currentWeight -= item.giveWeight()
		weightLabel.set_text(str(currentWeight))

		var currentValue = int(valueLabel.get_text())
		currentValue -= item.giveValue()
		valueLabel.set_text(str(currentValue))

func getFreeSlot():
	for slot in slotList:
		if !slot.item:
			return slot
	return null
