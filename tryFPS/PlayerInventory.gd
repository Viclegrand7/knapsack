extends Panel

var slotList : Array
var heldItem = null

export var MAX_SLOT = 30
const itemSlotClass = preload("res://ItemSlot.gd")

onready var itemDisplayer = $"../ItemPrecision"

var itemOffset : Vector2

func _ready():
	var slots = $PlayerInventoryScroller/ItemSlot
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

func slot_gui_input(event : InputEvent, slot : itemSlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if heldItem:
				if !slot.item:
					slot.putItem(heldItem);
					heldItem = null;
				else:
					var tempItem = slot.item;
					slot.pickItem();
					tempItem.rect_global_position = event.global_position - itemOffset;
					slot.putItem(heldItem);
					heldItem = tempItem;
			elif slot.item:
					var tempItem = slot.item;
					slot.pickItem();
					tempItem.rect_global_position = event.global_position - itemOffset;
		elif event.button_index == BUTTON_RIGHT && !event.pressed:
			if slot.item:
				var freeSlot = getFreeSlot();
				if freeSlot:
					var item = slot.item;
					slot.pickItem();
					freeSlot.putItem(item);
			else:
				if slot.item:
					var itemSlotType = slot.item.slotType;
					var panelSlot = characterPanel.getSlotByType(slot.item.slotType);
					if itemSlotType == Global.SlotType.SLOT_RING:
						if panelSlot[0].item && panelSlot[1].item:
							var panelItem = panelSlot[0].item;
							panelSlot[0].removeItem();
							var slotItem = slot.item;
							slot.removeItem();
							slot.setItem(panelItem);
							panelSlot[0].setItem(slotItem);
							pass
						elif !panelSlot[0].item && panelSlot[1].item || !panelSlot[0].item && !panelSlot[1].item:
							var tempItem = slot.item;
							slot.removeItem();
							panelSlot[0].equipItem(tempItem);
						elif panelSlot[0].item && !panelSlot[1].item:
							var tempItem = slot.item;
							slot.removeItem();
							panelSlot[1].equipItem(tempItem);
							pass
					else:
						if panelSlot.item:
							var panelItem = panelSlot.item;
							panelSlot.removeItem();
							var slotItem = slot.item;
							slot.removeItem();
							slot.setItem(panelItem);
							panelSlot.setItem(slotItem);
						else:
							var tempItem = slot.item;
							slot.removeItem();
							panelSlot.equipItem(tempItem);


