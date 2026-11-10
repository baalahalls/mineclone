@tool
extends Node3D

var blocks: Dictionary = {}

var block_mesh_generator: BlockMeshGenerator = BlockMeshGenerator.new()

@onready var block_preview: MeshInstance3D = %BlockPreview

func _ready() -> void:

    set_block(Vector3i(-2, 0, -3), BlockTypes.Type.STONE)
    set_block(Vector3i(-1, 0, -3), BlockTypes.Type.DIRT)
    set_block(Vector3i(0, 0, -3), BlockTypes.Type.GRASS)
    set_block(Vector3i(1, 0, -3), BlockTypes.Type.DIRT)
    set_block(Vector3i(2, 0, -3), BlockTypes.Type.STONE)

    block_preview.mesh = block_mesh_generator.build_world_mesh(blocks)

func set_block(block_position: Vector3i, block_type: BlockTypes.Type) -> void:

    if block_type == BlockTypes.Type.AIR:

        blocks.erase(block_position)
    else:
        blocks[block_position] = block_type

func get_block(block_position: Vector3i) -> BlockTypes.Type:

    return blocks.get(block_position, BlockTypes.Type.AIR)