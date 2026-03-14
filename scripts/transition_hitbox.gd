extends Area2D

# We export this so you can reuse this exact same script/node 
# to transition from level 1 to level 2 later!
@export_file("*.tscn") var next_scene_path: String

func _ready() -> void:
    # Connect the collision signal
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    # Check if the object entering is the player. 
    # Your level_0 code shows your player is already in the "player" group!
    if body.is_in_group("player"):
        if next_scene_path != "":
            print("Transitioning to: ", next_scene_path)
            get_tree().change_scene_to_file(next_scene_path)
        else:
            push_warning("No next scene path set for this transition zone!")
