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