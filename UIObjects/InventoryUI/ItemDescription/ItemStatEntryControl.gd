class_name ItemStatEntryControl extends RichTextLabel

const TITLE_VALUE_SEPARATOR = " | "

var item_stat_entry : ItemStatEntry



func assign_item_stat_entry(new_item_stat_entry : ItemStatEntry):
	item_stat_entry = new_item_stat_entry
	build_from_item_stat_entry()


func build_from_item_stat_entry():
	var title_text = item_stat_entry.stat_title
	var stat_value_colour_open_tag = " [color=#" + item_stat_entry.stat_value_colour.to_html(false) + "]"
	var value_text = item_stat_entry.stat_value
	
	var final_text = title_text + TITLE_VALUE_SEPARATOR + stat_value_colour_open_tag + value_text
	text = final_text
