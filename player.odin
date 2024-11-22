package main

import rl "vendor:raylib"

Player :: struct {
    position:       rl.Vector2,
    frames_counter: i16,
    current_frame:  i16,
    attacking:      bool,
}

PlayerAction :: enum {
    Idle,
    Attack,
    Movement,
}

player_update :: proc(player_tileset: ^Tileset, player: ^Player) -> PlayerAction {
    new_position := player.position
    movement := false

    if player.attacking {
        if tileset_update(player_tileset, &player.frames_counter, &player.current_frame, 2) {
            player.attacking = false
        }
    } else {
        if rl.IsKeyPressed(.SPACE) {
            player.current_frame = 0
            player.attacking = true
            return .Attack
        }

        if rl.IsKeyDown(.LEFT) {
            movement = true
            new_position.x -= 4
            if player_tileset.selected_tile.width >= 0 do player_tileset.selected_tile.width *= -1
        }
        if rl.IsKeyDown(.RIGHT) {
            movement = true
            new_position.x += 4
            if player_tileset.selected_tile.width < 0 do player_tileset.selected_tile.width *= -1
        }
        if rl.IsKeyDown(.UP) {
            movement = true
            new_position.y -= 4
        }
        if rl.IsKeyDown(.DOWN) {
            movement = true
            new_position.y += 4
        }
        if !movement {
            _ = tileset_update(player_tileset, &player.frames_counter, &player.current_frame, 0)
        } else {
            _ = tileset_update(player_tileset, &player.frames_counter, &player.current_frame, 1)
            player.position = rl.Vector2MoveTowards(player.position, new_position, 4)
            return .Movement
        }
    }
    return .Idle
}
