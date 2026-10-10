extends Node3D

var player
var zone_radius=60.0
var zone_min=12.0
var zone_tick=0.0
var enemies=[]

func _ready():
    player=$Player
    _make_cover()
    _make_loot()
    _spawn_enemies()

func _box(pos,size,color):
    var b=StaticBody3D.new(); b.position=pos; add_child(b)
    var m=MeshInstance3D.new(); var x=BoxMesh.new(); x.size=size; m.mesh=x
    var mat=StandardMaterial3D.new(); mat.albedo_color=color; mat.roughness=.9; m.material_override=mat; b.add_child(m)
    var c=CollisionShape3D.new(); var s=BoxShape3D.new(); s.size=size; c.shape=s; b.add_child(c)

func _make_cover():
    for i in range(42):
        var p=Vector3(float((i*29)%120)-60,1.2,float((i*43)%120)-60)
        if p.length()<10: continue
        _box(p,Vector3(2.2,2.4,2.2),Color(.27,.17,.07))

func _make_loot():
    for i in range(14):
        var a=float(i)*0.45
        var p=Vector3(cos(a)*float(10+i*2.5),.5,sin(a)*float(10+i*2.5))
        var l=load("res://loot.gd").new()
        l.position=p; add_child(l)

func _spawn_enemies():
    for i in range(14):
        var e=CharacterBody3D.new(); e.name="Enemy_%02d"%i
        e.position=Vector3(float((i*21)%90)-45,1,float((i*37)%90)-45)
        e.set_script(load("res://enemy.gd")); add_child(e); enemies.append(e); e.setup(player)

func _process(delta):
    zone_tick+=delta
    if zone_tick>10 and zone_radius>zone_min:
        zone_tick=0; zone_radius=max(zone_min,zone_radius-3.0)
    if player and player.global_position.length()>zone_radius:
        player.take_damage(4.0*delta)
