extends RefCounted

# ─────────────────────────────────────────────────────────────────────────────
#  SceneFader — transición a negro entre escenas SIN huecos.
#
#  El negro vive en la raíz del árbol (get_tree().root), no dentro de la escena,
#  así sobrevive al cambio de escena: no hay ni un frame en que se vea la escena
#  nueva "sin tapar" (ese era el destello).
#
#      const FaderScript = preload("res://scripts/common/ui/sceneFader.gd")
#
#      FaderScript.fadeOutAndChange(self, "res://scenes/nivel_1/Villa1.tscn")  # al salir
#      FaderScript.fadeIn(self)                                               # en _ready() de la escena nueva
#      FaderScript.coverNow(self)    # tapar de golpe (si la escena ya terminó su propio fundido a negro)
# ─────────────────────────────────────────────────────────────────────────────

const GROUP := "scene_fader"
const LAYER := 100

static func _find(tree: SceneTree) -> CanvasLayer:
	for n in tree.get_nodes_in_group(GROUP):
		if is_instance_valid(n) and not n.is_queued_for_deletion():
			return n as CanvasLayer
	return null

# Devuelve el rectángulo negro (lo crea si no existe, con la opacidad dada)
static func _rect(tree: SceneTree, alpha: float) -> ColorRect:
	var layer := _find(tree)
	if layer == null:
		layer = CanvasLayer.new()
		layer.layer = LAYER
		layer.add_to_group(GROUP)
		var r := ColorRect.new()
		r.name = "Rect"
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.color = Color(0, 0, 0, alpha)
		layer.add_child(r)
		tree.root.add_child(layer)
		r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return layer.get_node("Rect") as ColorRect

static func _kill(rect: ColorRect) -> void:
	if rect.has_meta("tw"):
		var old = rect.get_meta("tw")
		if old is Tween and old.is_valid():
			old.kill()

static func coverNow(node: Node) -> void:
	var rect := _rect(node.get_tree(), 1.0)
	_kill(rect)
	rect.color.a = 1.0

static func fadeOutAndChange(node: Node, scenePath: String, duration: float = 0.8) -> void:
	var tree := node.get_tree()
	var rect := _rect(tree, 0.0)
	_kill(rect)
	var tw := tree.create_tween()
	tw.tween_property(rect, "color:a", 1.0, duration)
	tw.tween_callback(func(): tree.change_scene_to_file(scenePath))
	rect.set_meta("tw", tw)

static func fadeIn(node: Node, duration: float = 0.8) -> void:
	var tree := node.get_tree()
	var layer := _find(tree)
	if layer == null:
		return   # no venimos de un fundido: nada que destapar
	var rect := layer.get_node("Rect") as ColorRect
	_kill(rect)
	rect.color.a = 1.0
	var tw := tree.create_tween()
	tw.tween_property(rect, "color:a", 0.0, duration)
	tw.tween_callback(layer.queue_free)
	rect.set_meta("tw", tw)
