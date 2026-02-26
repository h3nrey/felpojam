extends Resource
class_name Document

@export var paper_type: Types.PaperType
@export var service_type: Types.ServiceType
@export var is_stamped: bool = false

func _init(paper := Types.PaperType.HELL, service := Types.ServiceType.DEATH):
	paper_type = paper
	service_type = service
