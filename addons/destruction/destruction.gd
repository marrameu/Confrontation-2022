@tool
extends Node

"""
Handles destruction of the parent node

When `destroy` is called, the parent node gets removed
and shards are added to the `shard_container`. A `shard_template` is used
to configure how the `shard_scene` will be converted to `RigidBodies`.
"""

@export var shard_template : PackedScene = preload("res://addons/destruction/ShardTemplates/DefaultShardTemplate.tscn")
@export var shard_scene : PackedScene
@export var shard_container := @"../../" :
	get:
		return shard_container # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_shard_container

const DestructionUtils = preload("res://addons/destruction/DestructionUtils.gd")

func destroy() -> void:
	var shards := DestructionUtils.create_shards(shard_scene.instantiate(), shard_template)
	get_node(shard_container).add_child(shards)
	shards.global_transform.origin = get_parent().global_transform.origin
	get_parent().queue_free()


func set_shard_container(to : NodePath) -> void:
	shard_container = to
	update_configuration_warnings()


func _notification(what : int) -> void:
	if what == NOTIFICATION_PATH_RENAMED:
		update_configuration_warnings()


func _get_configuration_warnings() -> String:
	return "The shard container is a PhysicsBody3D or has a PhysicsBody3D as a parent. This will make the shards added to it behave in unexpected ways." if get_node(shard_container) is PhysicsBody3D or _has_parent_of_type(get_node(shard_container), PhysicsBody3D) else ""


static func _has_parent_of_type(node : Node, type) -> bool:
	if not node.get_parent():
		return false
	if node.get_parent() is type:
		return true
	return _has_parent_of_type(node.get_parent(), type)
