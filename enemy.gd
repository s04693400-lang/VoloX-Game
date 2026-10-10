extends CharacterBody3D
var hp=100.0
var target
var home=Vector3.ZERO
var cd=0.0
var speed=3.5
var t=0.0

func setup(p): target=p; home=global_position
func _ready():
    var c=CollisionShape3D.new(); var s=CapsuleShape3D.new(); s.radius=.4; s.height=1.7; c.shape=s; add_child(c)
    var m=MeshInstance3D.new(); var cm=CapsuleMesh.new(); cm.radius=.4; cm.height=1.7; m.mesh=cm
    var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.68,.06,.07); m.material_override=mat; add_child(m)
func take_damage(d):
    hp-=d
    if hp<=0:
        queue_free()
func _physics_process(delta):
    if not target: return
    cd=max(0.,cd-delta); var dist=global_position.distance_to(target.global_position)
    if dist<22:
        var d=target.global_position-global_position; d.y=0
        if dist>5:
            d=d.normalized(); velocity.x=d.x*speed; velocity.z=d.z*speed
            look_at(global_position+d,Vector3.UP)
        else:
            velocity.x=0; velocity.z=0
            if cd<=0: target.take_damage(7); cd=.9
    else:
        t+=delta; var p=home+Vector3(cos(t)*5,0,sin(t)*5)
        var d=p-global_position; d.y=0
        if d.length()>.4:
            d=d.normalized(); velocity.x=d.x*1.7; velocity.z=d.z*1.7
    if not is_on_floor(): velocity.y-=18*delta
    else: velocity.y=-.5
    move_and_slide()
