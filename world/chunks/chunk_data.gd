extends RefCounted
class_name ChunkData

const CHUNK_SIZE: int = 16
const WORLD_HEIGHT: int = 128

var chunk_coords: Vector2i

var blocks: Dictionary = {}

func set_block(local_position: Vector3i, block_type: BlockTypes.Type) -> void:

    if block_type == BlockTypes.Type.AIR:

        blocks.erase(local_position)
    else:
        blocks[local_position] = block_type

func get_block(local_position: Vector3i) -> BlockTypes.Type:

    return blocks.get(local_position, BlockTypes.Type.AIR)