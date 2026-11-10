@tool
extends Node3D

var block_mesh_generator: BlockMeshGenerator = BlockMeshGenerator.new()

@onready var block_preview: MeshInstance3D = %BlockPreview

var chunks: Dictionary = {}
var chunk_meshes: Dictionary = {}

func _ready() -> void:

    set_block(Vector3i(14, 0, 0), BlockTypes.Type.STONE)
    set_block(Vector3i(15, 0, 0), BlockTypes.Type.STONE)
    set_block(Vector3i(16, 0, 0), BlockTypes.Type.GRASS)
    set_block(Vector3i(17, 0, 0), BlockTypes.Type.DIRT)
    set_block(Vector3i(-1, 0, 0), BlockTypes.Type.GRASS)

    for chunk_coords in chunks.keys():

        render_chunk(chunk_coords)

    set_block(Vector3i(-1, 0, 0), BlockTypes.Type.AIR)
    set_block(Vector3i(-2, 0, 0), BlockTypes.Type.STONE)

func get_chunk_coords(block_position: Vector3i) -> Vector2i:

    var chunk_x: int = floori(block_position.x / float(ChunkData.CHUNK_SIZE))
    var chunk_z: int = floori(block_position.z / float(ChunkData.CHUNK_SIZE))

    return Vector2i(chunk_x, chunk_z)

func get_local_block_position(block_position: Vector3i) -> Vector3i:

    var local_x: int = posmod(block_position.x, ChunkData.CHUNK_SIZE)
    var local_z: int = posmod(block_position.z, ChunkData.CHUNK_SIZE)

    return Vector3i(local_x, block_position.y, local_z)

func get_chunk(chunk_coords: Vector2i) -> ChunkData:

    if chunks.has(chunk_coords):

        return chunks[chunk_coords]

    var chunk_data: ChunkData = ChunkData.new()

    chunk_data.chunk_coords = chunk_coords
    chunks[chunk_coords] = chunk_data

    return chunk_data

func set_block(block_position: Vector3i, block_type: BlockTypes.Type) -> void:

    var chunk_coords: Vector2i = get_chunk_coords(block_position)
    var chunk_data: ChunkData = get_chunk(chunk_coords)

    var local_position: Vector3i = get_local_block_position(block_position)

    chunk_data.set_block(local_position, block_type)

    if chunk_meshes.has(chunk_coords):

        render_chunk(chunk_coords)

func get_block(block_position: Vector3i) -> BlockTypes.Type:

    var chunk_coords: Vector2i = get_chunk_coords(block_position)

    if not chunks.has(chunk_coords):

        return BlockTypes.Type.AIR

    var chunk_data: ChunkData = chunks[chunk_coords]

    var local_position: Vector3i = get_local_block_position(block_position)

    return chunk_data.get_block(local_position)

func render_chunk(chunk_coords: Vector2i) -> void:

    if not chunks.has(chunk_coords):

        return

    var mesh_instance: MeshInstance3D

    var chunk_data: ChunkData = chunks[chunk_coords]

    if chunk_meshes.has(chunk_coords):

        mesh_instance = chunk_meshes[chunk_coords]

        mesh_instance.mesh = block_mesh_generator.build_chunk_mesh(chunk_data.blocks, chunk_coords, Callable(self, "get_block"))

        return

    var mesh: ArrayMesh = block_mesh_generator.build_chunk_mesh(chunk_data.blocks, chunk_coords, Callable(self, "get_block"))

    mesh_instance = MeshInstance3D.new()

    mesh_instance.position = Vector3(chunk_coords.x * ChunkData.CHUNK_SIZE, 0, chunk_coords.y* ChunkData.CHUNK_SIZE)
    mesh_instance.mesh = mesh
    mesh_instance.material_override = block_preview.material_override

    add_child(mesh_instance)
    chunk_meshes[chunk_coords] = mesh_instance