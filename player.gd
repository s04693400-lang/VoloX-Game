extends CharacterBody3D

signal stats_changed
signal shot_fired

var hp=100.0
var armor=50.0
var ammo=30
var reserve=120
var fire_cd=0.0
var reload_cd=0.0
var move_input=Vector2.ZERO
var sprinting=false
var body_root
var camera_rig
var gun
var muzzle_flash=0.0
var anim_t=0.0

func _ready():
    camera_rig=$CameraRig
    _build_character()

func _mat(c):
    var m=StandardMaterial3D.new(); m.albedo_color=c; m.roughness=.8; return m

func _part(n,p,s,mat):
    var x=MeshInstance3D.new(); x.name=n
    var b=BoxMesh.new(); b.size=s; x.mesh=b; x.position=p; x.material_override=mat
    body_root.add_child(x); return x

func _build_character():
    body_root=Node3D.new(); body_root.name="Humanoid"; add_child(body_root)
    var suit=_mat(Color(.07,.28,.72)); var skin=_mat(Color(.88,.61,.43)); var dark=_mat(Color(.035,.045,.06))
    _part("Torso",Vector3(0,.55,0),Vector3(.72,.9,.42),suit)
    _part("Head",Vector3(0,1.22,0),Vector3(.42,.42,.42),skin)
    _part("ArmL",Vector3(-.52,.58,0),Vector3(.22,.75,.22),suit)
    _part("ArmR",Vector3(.52,.58,0),Vector3(.22,.75,.22),suit)
    _part("LegL",Vector3(-.22,-.12,0),Vector3(.25,.82,.25),dark)
    _part("LegR",Vector3(.22,-.12,0),Vector3(.25,.82,.25),dark)
    gun=MeshInstance3D.new(); gun.name="Rifle"
    var rb=BoxMesh.new(); rb.size=Vector3(.16,.16,.9); gun.mesh=rb; gun.position=Vector3(.55,.48,-.45)
    gun.material_override=_mat(Color(.04,.05,.06)); body_root.add_child(gun)

func set_move(v): move_input=v.limit_length(1.0)
func set_sprint(v): sprinting=v
func do_jump():
    if is_on_floor(): velocity.y=7.2

func _physics_process(delta):
    fire_cd=max(0.,fire_cd-delta); muzzle_flash=max(0.,muzzle_flash-delta)
    if reload_cd>0:
        reload_cd-=delta
        if reload_cd<=0:
            var n=min(30-ammo,reserve); ammo+=n; reserve-=n
    var k=Vector2(Input.get_axis("ui_left","ui_right"),Input.get_axis("ui_up","ui_down"))
    if move_input.length()<.05: move_input=k.limit_length(1)
    var f=-camera_rig.global_transform.basis.z; var r=camera_rig.global_transform.basis.x
    f.y=0; r.y=0; f=f.normalized(); r=r.normalized()
    var dir=(r*move_input.x+f*move_input.y).normalized()
    var speed=8.2 if sprinting else 5.6
    velocity.x=move_toward(velocity.x,dir.x*speed,20*delta)
    velocity.z=move_toward(velocity.z,dir.z*speed,20*delta)
    if dir.length()>.05: rotation.y=lerp_angle(rotation.y,atan2(dir.x,dir.z),14*delta)
    if not is_on_floor(): velocity.y-=18*delta
    else: velocity.y=-.5
    move_and_slide()
    anim_t+=delta*(11 if dir.length()>.05 else 2)
    var s=sin(anim_t)*(.5 if dir.length()>.05 else .015)
    $Humanoid/ArmL.rotation.x=s; $Humanoid/ArmR.rotation.x=-s
    $Humanoid/LegL.rotation.x=-s; $Humanoid/LegR.rotation.x=s
    if dir.length()>.05: body_root.position.y=abs(sin(anim_t*2))*.025
    stats_changed.emit()

func shoot():
    if ammo<=0 or fire_cd>0 or reload_cd>0: return
    ammo-=1; fire_cd=.11; muzzle_flash=.05
    var cam=$CameraRig/Camera
    var from=cam.global_position
    var to=from+(-cam.global_transform.basis.z)*240
    var hit=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,to))
    if hit and hit.collider and hit.collider.has_method("take_damage"):
        hit.collider.take_damage(25)
    shot_fired.emit()
    stats_changed.emit()

func start_reload():
    if ammo<30 and reserve>0 and reload_cd<=0: reload_cd=1.35

func take_damage(d):
    var absorbed=min(armor,d*.65); armor-=absorbed
    hp=max(0,hp-(d-absorbed)); stats_changed.emit()
