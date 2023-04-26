extends Control


onready var edit = $grid/col0/gdcfg/vbox/hbox/LineEdit
onready var dir = Directory.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _check_gdcfg():
	var resultEl = $grid/col0/gdcfg/vbox/hbox2/Result
	var id = edit.text
	if !dir.file_exists("res://q/%s/_question.gdcfg" % id):
		resultEl.text = "file does not exist"
		return
	var cfg = ConfigFile.new()
	var err = cfg.load("res://q/%s/_question.gdcfg" % id)
	if !err == OK:
		resultEl.text = "ConfigFile load error %d" % err
	resultEl.text = "ConfigFile loaded successfully"
	var detailEl = $grid/col0/gdcfg/vbox/ScrollContainer/Label
	detailEl.text = "---start of ConfigFile---"
	for s in cfg.get_sections():
		detailEl.text += "\n[%s]" % s
		for k in cfg.get_section_keys(s):
			detailEl.text += "\n  %s = %s" % [k, cfg.get_value(s, k)]
	detailEl.text += "\n---end of ConfigFile---"
