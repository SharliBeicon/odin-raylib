package main

import "core:math"
import "core:time"
import rl "vendor:raylib"

WIDTH :: 1280
HEIGHT :: 768
TARGET_FPS :: 60

MOVE_FRAME_NS :: 350_000_000

main :: proc() {
    rl.SetTraceLogLevel(.ERROR)
    rl.SetConfigFlags({.MSAA_4X_HINT})

    rl.InitWindow(WIDTH, HEIGHT, "Tales of Teliteria")
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    gallery := tileset_gallery_load()
    defer tileset_gallery_unload(gallery)

    sword_attack_fx := rl.LoadSound("assets/audio/sfx/07_human_atk_sword_1.wav")
    defer rl.UnloadSound(sword_attack_fx)
    player_step_fx := rl.LoadSound("assets/audio/sfx/16_human_walk_stone_1.wav")
    defer rl.UnloadSound(player_step_fx)


    tileset_select_tile(&gallery[.FlatGround], 1, 1)

    player := Player {
        position       = {200.0, 350.0},
        frames_counter = 0,
        current_frame  = 0,
        attacking      = false,
    }

    camera := rl.Camera2D {
        target   = {
            player.position.x + math.abs(gallery[.Player].selected_tile.width) / 2,
            player.position.y + gallery[.Player].selected_tile.height / 2,
        },
        offset   = {WIDTH / 2, HEIGHT / 2},
        rotation = 0,
        zoom     = 1,
    }

    last_move_sound := time.now()._nsec
    rl.SetTargetFPS(TARGET_FPS)
    for !rl.WindowShouldClose() {
        free_all(context.temp_allocator)

        #partial switch player_update(&gallery[.Player], &player) {
        case .Movement:
            if time.now()._nsec - last_move_sound >= MOVE_FRAME_NS {
                rl.PlaySound(player_step_fx)
                last_move_sound = time.now()._nsec
            }
        case .Attack:
            rl.PlaySound(sword_attack_fx)
        }

        camera.target = {
            player.position.x + math.abs(gallery[.Player].selected_tile.width) / 2,
            player.position.y + gallery[.Player].selected_tile.height / 2,
        }

        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground({80, 144, 167, 255})
        rl.DrawFPS(10, 10)

        rl.BeginMode2D(camera)
        defer rl.EndMode2D()

        draw_ground(&gallery[.FlatGround])
        //Draw player
        rl.DrawTextureRec(
            gallery[.Player].texture,
            gallery[.Player].selected_tile,
            player.position,
            rl.WHITE,
        )
    }
}

draw_ground :: proc(ground: ^Tileset) {
    green_ground := true
    for i := 0; i < WIDTH; i += int(ground.texture.width / 10) {
        for j := 0; j < HEIGHT; j += int(ground.texture.height / 5) {
            rl.DrawTextureRec(ground.texture, ground.selected_tile, {f32(i), f32(j)}, rl.WHITE)
            green_ground = !green_ground
        }
    }
}
