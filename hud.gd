extends CanvasLayer

var p
var joy=Vector2.ZERO
var center=Vector2(135,585)
var active=-1
var msg_time=0.0

func _ready():
    p=get_parent().get_node("Player")
    _label("VOLOX",Vector2(28,18),28)
    _label("BATTLE ROYALE",Vector2(31,50),12)
    _label("",Vector2(28,82),18,"hp")
    _label("",Vector2(28,112),16,"armor")
    _label("",Vector2(28,142),18,"ammo")
    _label("",Vector2(28,172),16,"zone")
    _label("DRAG RIGHT SIDE TO LOOK",Vector2(475,28),13)
    _button("FIRE",Vector2(1070,535),Vector2(165,70),func(): p.shoot())
    _button("RELOAD",Vector2(1070,615),Vector2(165,52),func(): p.start_reload())
    _button("JUMP",Vector2(890,615),Vector2(150,52),func(): p.do_jump())
    var sprint=_button("SPRINT",Vector2(890,535),Vector2(150,52),func(): p.set_sprint(true))
    sprint.button_up.connect(func(): p.set_sprint(false))
    queue_redraw()

func _label(txt,pos,size,n=""):
    var l=Label.new(); l.text=txt; l.position=pos; l.add_theme_font_size_override("font_size",size)
    if n!="": l.name=n
    add_child(l)

func _button(txt,pos,size,fn):
    var b=Button.new(); b.text=txt; b.position=pos; b.size=size
    b.add_theme_font_size_override("font_size",18); b.pressed.connect(fn); add_child(b); return b

func _process(delta):
    if p:
        p.set_move(joy)
        $hp.text="♥  HP  %d / 100"%int(p.hp)
        $armor.text="◆  ARMOR  %d"%int(p.armor)
        
    $ammo.text = "AMMO %02d / %03d" % [p.ammo, p.reserve]

        $zone.text="◉  SAFE ZONE  %dm"%int(get_parent().zone_radius)
    msg_time=max(0.,msg_time-delta)
    queue_redraw()

func _input(e):
    if e is InputEventScreenTouch:
        if e.pressed and e.position.x<330 and e.position.y>420:
            active=e.index; joy=((e.position-center)/85).limit_length(1)
        elif not e.pressed and e.index==active:
            active=-1; joy=Vector2.ZERO
    elif e is InputEventScreenDrag and e.index==active:
        joy=((e.position-center)/85).limit_length(1)
    elif e is InputEventMouseButton and e.button_index==MOUSE_BUTTON_LEFT and e.pressed:
        p.shoot()

func _draw():
    draw_circle(center,85,Color(.02,.03,.05,.50))
    draw_circle(center+joy*50,30,Color(.85,.9,1,.80))
    draw_arc(center,85,0,TAU,48,Color(1,1,1,.38),3)
    # center crosshair
    var c=Vector2(640,360)
    draw_line(c-Vector2(14,0),c-Vector2(4,0),Color(1,1,1,.9),2)
    draw_line(c+Vector2(4,0),c+Vector2(14,0),Color(1,1,1,.9),2)
    draw_line(c-Vector2(0,14),c-Vector2(0,4),Color(1,1,1,.9),2)
    draw_line(c+Vector2(0,4),c+Vector2(0,14),Color(1,1,1,.9),2)
