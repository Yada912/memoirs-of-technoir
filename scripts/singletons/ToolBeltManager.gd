extends Node

## ToolBeltManager Singleton
## Tracks currently active tool and broadcasts tool switching events.

signal tool_changed(new_tool_id: String, old_tool_id: String)

const TOOL_HAND: String = "hand"
const TOOL_SCREWDRIVER: String = "screwdriver"
const TOOL_CLEANER: String = "cleaner_brush"
const TOOL_WRENCH: String = "wrench"

var current_tool: String = TOOL_HAND

const TOOL_METADATA: Dictionary = {
	TOOL_HAND: {
		"id": TOOL_HAND,
		"name": "Inspection Hand",
		"icon_label": "✋",
		"desc": "Rotate and inspect components, pull detached parts."
	},
	TOOL_SCREWDRIVER: {
		"id": TOOL_SCREWDRIVER,
		"name": "Screwdriver",
		"icon_label": "🪛",
		"desc": "Unfasten precision slotted/phillips machine screws."
	},
	TOOL_CLEANER: {
		"id": TOOL_CLEANER,
		"name": "Cleaning Brush",
		"icon_label": "🧹",
		"desc": "Brush away dust, grime, and debris from seized bearings."
	},
	TOOL_WRENCH: {
		"id": TOOL_WRENCH,
		"name": "Small Wrench",
		"icon_label": "🔧",
		"desc": "Loosen lock nuts and tension collars."
	}
}

func equip_tool(tool_id: String) -> void:
	if not TOOL_METADATA.has(tool_id):
		tool_id = TOOL_HAND
		
	if current_tool != tool_id:
		var prev: String = current_tool
		current_tool = tool_id
		AudioManager.play_click(1.2)
		tool_changed.emit(current_tool, prev)

func get_active_tool() -> String:
	return current_tool

func get_active_tool_info() -> Dictionary:
	return TOOL_METADATA.get(current_tool, {})

func reset_to_hand() -> void:
	equip_tool(TOOL_HAND)
