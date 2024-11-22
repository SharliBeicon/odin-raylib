package main
import rl "vendor:raylib"

TilesetGallery :: map[TilesetKind]Tileset

tileset_gallery_load :: proc() -> TilesetGallery {
    gallery := make(TilesetGallery)

    gallery[.Player] = tileset_load(
        "assets/Factions/Knights/Troops/Warrior/Blue/Warrior_Blue.png",
        8,
        6,
    )
    gallery[.FlatGround] = tileset_load("assets/Terrain/Ground/Tilemap_Flat.png", 5, 10)

    return gallery
}

tileset_gallery_unload :: proc(gallery: TilesetGallery) {
    for _, tileset in gallery {
        tileset_unload(tileset)
    }
    delete(gallery)
}

TilesetKind :: enum {
    Player,
    FlatGround,
}

Tileset :: struct {
    rows:          i16,
    cols:          i16,
    texture:       rl.Texture2D,
    selected_tile: rl.Rectangle,
}

tileset_load :: proc(path: cstring, rows: i16, cols: i16) -> Tileset {
    texture := rl.LoadTexture(path)
    return {
        rows,
        cols,
        texture,
        rl.Rectangle{0.0, 0.0, f32(texture.width) / f32(cols), f32(texture.height) / f32(rows)},
    }
}

tileset_unload :: proc(tileset: Tileset) {
    rl.UnloadTexture(tileset.texture)
}

tileset_select_tile :: proc(tileset: ^Tileset, row: i16, col: i16) {
    assert(row < tileset.rows && col < tileset.cols)

    tileset.selected_tile.x = (f32(tileset.texture.width) / f32(tileset.cols)) * f32(col)
    tileset.selected_tile.y = (f32(tileset.texture.height) / f32(tileset.rows)) * f32(row)
}

// Return true when ends an animation loop
tileset_update :: proc(
    player: ^Tileset,
    frames_counter: ^i16,
    current_frame: ^i16,
    row: i16,
) -> bool {
    if frames_counter^ > TARGET_FPS / 12 {
        frames_counter^ = 0
        current_frame^ += 1
        if current_frame^ >= player.cols {
            current_frame^ = 0
        }
        tileset_select_tile(player, row, current_frame^)
    }
    frames_counter^ += 1

    return current_frame^ == i16(player.cols - 1)
}
