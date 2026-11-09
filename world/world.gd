@tool
extends Node3D

enum BlockType {

    AIR,
    STONE,
    DIRT,
    GRASS

}

var blocks: Dictionary = {}

var block_mesh_generator: BlockMeshGenerator = BlockMeshGenerator.new()

@onready var block_preview: MeshInstance3D = %BlockPreview

func _ready() -> void:

    block_preview.mesh = block_mesh_generator.build_block_mesh()

func set_block(block_position: Vector3i, block_type: BlockType) -> void:

    if block_type == BlockType.AIR:

        blocks.erase(block_position)
    else:
        blocks[block_position] = block_type

func get_block(block_position: Vector3i) -> BlockType:

    return blocks.get(block_position, BlockType.AIR)