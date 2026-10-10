extends Node3D
var yaw=0.0
var pitch=-0.10
var sensitivity=0.010
var dragging=false
func _unhandled_input(e):
    if e is InputEventMouseButton and e.button_index==MOUSE_BUTTON_LEFT:
        dragging=e.pressed
    elif e is InputEventMouseMotion and dragging:
        _look(e.relative)
    elif e is InputEventScreenDrag:
        # Right side is camera zone; left side belongs to joystick.
        if e.position.x>360: _look(e.relative)
func _look(d):
    yaw-=d.x*sensitivity
    pitch=clamp(pitch-d.y*sensitivity,-0.78,0.48)
    rotation.y=yaw
    rotation.x=pitch
