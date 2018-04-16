extends MeshInstance

var ori = Vector3(0,0,0)

func _process(delta):
	ori.x += delta
	ori.z += delta * 0.1
	set_rotation( ori )

func _ready():
	set_process( true )
	pass
