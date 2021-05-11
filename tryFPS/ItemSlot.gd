extends Panel

var item = null
var style

func _init():
	mouse_filter = Control.MOUSE_FILTER_PASS;
	rect_min_size = Vector2(75, 75);
	style = StyleBoxFlat.new();
	refreshColors();
	style.set_border_width_all(2);
	set('custom_styles/panel', style);

func pickItem():
	item.pickItem();
	remove_child(item);
	get_tree().get_root().add_child(item);
	item = null;
	refreshColors();

func putItem(newItem):
	item = newItem;
	item.putItem();
	get_tree().get_root().remove_child(item);
	add_child(item);
	refreshColors();

func refreshColors():
	if not item:
		style.bg_color = Color("#8B7258");
		style.border_color = Color("#534434");
