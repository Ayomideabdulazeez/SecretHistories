extends Tree

var node_to_view : Dictionary = {}

export var success_color : Color = Color.forestgreen
export var running_color : Color = Color.darkgoldenrod
export var failed_color : Color = Color.red
export var skip_color : Color = Color.darkgray

func _ready() -> void:
	pass # Replace with function body.


func initialize_tree(root_node : BTNode):
	clear()
	var root_item = create_item()

func clear_debug_view():
	clear()
	node_to_view.clear()



func create_tree_item_for_node(node : BTNode, parent : TreeItem) -> TreeItem:
	var tree_item : TreeItem = create_item(parent)
	tree_item.set_text(0, node.name)
	return tree_item
