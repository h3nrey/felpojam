extends Node

@export var hell_death: Texture2D
@export var hell_marriage: Texture2D
@export var hell_inheritance: Texture2D

@export var paradise_death: Texture2D
@export var paradise_marriage: Texture2D
@export var paradise_inheritance: Texture2D

@export var stamped_overlay: Texture2D

func get_texture(doc: Document) -> Texture2D:
	match doc.paper_type:
		Types.PaperType.HELL: 
			match doc.service_type:
				Types.ServiceType.DEATH: return hell_death
				Types.ServiceType.MARRIAGE: return hell_marriage
				Types.ServiceType.INHERITANCE: return hell_inheritance
		
		Types.PaperType.PARADISE:
			match doc.service_type:
				Types.ServiceType.DEATH: return paradise_death
				Types.ServiceType.MARRIAGE: return paradise_marriage
				Types.ServiceType.INHERITANCE: return paradise_inheritance
	
	return null


func get_texture_by_strings(paper_type: String, service_type: String) -> Texture2D:
	var key = paper_type + "_" + service_type
	match key:
		"hell_death": return hell_death
		"hell_marriage": return hell_marriage
		"hell_inheritance": return hell_inheritance
		"paradise_death": return paradise_death
		"paradise_marriage": return paradise_marriage
		"paradise_inheritance": return paradise_inheritance
	return null
