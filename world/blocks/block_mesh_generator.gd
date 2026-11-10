@tool
extends RefCounted
class_name BlockMeshGenerator

enum BlockFace {

    FRONT,
    BACK,
    LEFT,
    RIGHT,
    TOP,
    BOTTOM

}

func generate_block_vertices(face: BlockFace) -> PackedVector3Array:
    
    var vertices: PackedVector3Array = []

    match(face):

        BlockFace.FRONT:
            vertices = [
                Vector3(0, 0, 0),
                Vector3(0, 1, 0),
                Vector3(1, 1, 0),
                Vector3(1, 0, 0)
            ]

        BlockFace.BACK:
            vertices = [
                Vector3(1, 0, 1),
                Vector3(1, 1, 1),
                Vector3(0, 1, 1),
                Vector3(0, 0, 1)
            ]

        BlockFace.LEFT:
            vertices = [
                Vector3(0, 0, 1),
                Vector3(0, 1, 1),
                Vector3(0, 1, 0),
                Vector3(0, 0, 0)
            ]

        BlockFace.RIGHT:
            vertices = [
                Vector3(1, 0, 0),
                Vector3(1, 1, 0),
                Vector3(1, 1, 1),
                Vector3(1, 0, 1)
            ]

        BlockFace.TOP:
            vertices = [
                Vector3(0, 1, 1),
                Vector3(1, 1, 1),
                Vector3(1, 1, 0),
                Vector3(0, 1, 0)
            ]

        BlockFace.BOTTOM:
            vertices = [
                Vector3(0, 0, 0),
                Vector3(1, 0, 0),
                Vector3(1, 0, 1),
                Vector3(0, 0, 1)
            ]


    return vertices

func generate_block_indices() -> PackedInt32Array:

    var indices: PackedInt32Array = [
        0,
        2,
        1,
        0,
        3,
        2
    ]

    return indices

func build_block_mesh() -> ArrayMesh:

    var mesh: ArrayMesh = ArrayMesh.new()

    var vertices: PackedVector3Array = []
    var indices: PackedInt32Array = []

    var uvs: PackedVector2Array = []

    for face in BlockFace.values():

        var vertex_offset: int  = vertices.size()

        for index in generate_block_indices():

            indices.append(index + vertex_offset)

        vertices.append_array(generate_block_vertices(face))
        uvs.append_array(generate_block_uvs(Vector2i(1, 0)))

    var mesh_array: Array = []

    mesh_array.resize(Mesh.ARRAY_MAX)

    mesh_array[Mesh.ARRAY_VERTEX] = vertices
    mesh_array[Mesh.ARRAY_INDEX] = indices
    mesh_array[Mesh.ARRAY_TEX_UV] = uvs

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)

    return mesh

func generate_block_uvs(tile_coords: Vector2i) -> PackedVector2Array:

    var tile_size: float = 1.0 / 16.0
    var uv_offset: Vector2 = tile_coords * tile_size

    var uvs: PackedVector2Array = [
        Vector2(0, 1) * tile_size + uv_offset,
        Vector2(0, 0) * tile_size + uv_offset,
        Vector2(1, 0) * tile_size + uv_offset,
        Vector2(1, 1) * tile_size + uv_offset
    ]

    return uvs

func build_chunk_mesh(blocks: Dictionary, chunk_coords: Vector2i, get_world_block: Callable) -> ArrayMesh:

    var mesh: ArrayMesh = ArrayMesh.new()

    var vertices: PackedVector3Array = []
    var indices: PackedInt32Array = []

    var uvs: PackedVector2Array = []

    for block_position in blocks.keys():

        var global_position: Vector3i = Vector3i(chunk_coords.x * ChunkData.CHUNK_SIZE + block_position.x, block_position.y, chunk_coords.y * ChunkData.CHUNK_SIZE + block_position.z)

        for face in BlockFace.values():

            var block_type: BlockTypes.Type = blocks[block_position]
            var face_direction: Vector3i = get_face_direction(face)

            var neighbor_global_position: Vector3i = global_position + face_direction

            var neighbor_type: BlockTypes.Type = get_world_block.call(neighbor_global_position)

            if neighbor_type != BlockTypes.Type.AIR:

                continue

            var face_vertices: PackedVector3Array = generate_block_vertices(face)

            var vertex_offset: int  = vertices.size()

            for index in generate_block_indices():

                indices.append(index + vertex_offset)

            for vertex in face_vertices:

                vertices.append(Vector3(block_position) + vertex)

            uvs.append_array(generate_block_uvs(get_block_tile_coords(block_type, face)))
    
    var mesh_array: Array = []

    mesh_array.resize(Mesh.ARRAY_MAX)

    mesh_array[Mesh.ARRAY_VERTEX] = vertices
    mesh_array[Mesh.ARRAY_INDEX] = indices
    mesh_array[Mesh.ARRAY_TEX_UV] = uvs

    if indices.is_empty():

        return mesh

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
    
    return mesh

func get_face_direction(face: BlockFace) -> Vector3i:

    match(face):

        BlockFace.FRONT:
            return Vector3i(0, 0, -1)

        BlockFace.BACK:
            return Vector3i(0, 0, 1)

        BlockFace.LEFT:
            return Vector3i(-1, 0, 0)

        BlockFace.RIGHT:
            return Vector3i(1, 0, 0)

        BlockFace.TOP:
            return Vector3i(0, 1, 0)

        BlockFace.BOTTOM:
            return Vector3i(0, -1, 0)

    return Vector3i(0, 0, 0)

func get_block_tile_coords(block_type: BlockTypes.Type, face: BlockFace) -> Vector2i:

    match(block_type):

        BlockTypes.Type.GRASS:

            match(face):

                BlockFace.TOP:

                    return Vector2i(0, 0)

                BlockFace.BOTTOM:

                    return Vector2i(2, 0)

            
            return Vector2i(3, 0)

        BlockTypes.Type.STONE:

            return Vector2i(1, 0)

        BlockTypes.Type.DIRT:

            return Vector2i(2, 0)


    return Vector2i(1, 0)