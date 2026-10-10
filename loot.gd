extends Area3D
var kind="ammo"
var amount=30
func _ready():
    var m=MeshInstance3D.new(); var b=BoxMesh.new(); b.size=Vector3(.45,.45,.45); m.mesh=b
    var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.95,.72,.08); m.material_override=mat; add_child(m)
    var c=CollisionShape3D.new(); var s=SphereShape3D.new(); s.radius=.8; c.shape=s; add_child(c)
    body_entered.connect(_collect)
func _collect(body):
    if body.has_method("collect_ammo"):
        body.collect_ammo(amount); queue_free()
