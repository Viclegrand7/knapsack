extends Panel

onready var description = $ItemDescription
onready var itemName = $CategoryName/ItemName

func toggleDisplay():
# warning-ignore:standalone_ternary
	hide() if is_visible_in_tree() else show()

func displayItem(item):
	show()
	itemName.set_text(item.giveName())
	description.set_text("Weight : %d\nValue : %d\n%s" % [item.giveWeight(), item.giveValue(), item.giveDescription()])

func hideItem(_item):
	if is_visible_in_tree():
		hide()
