# Noir power-ups

Replaces the Prairie King power-ups (machine gun, shotgun, wagon wheel, sheriff badge, nuke, smoke bomb, tombstone) with a noir set built around light and weather, where most power-ups come with a catch.

## Rules

- A catch costs time, cash, speed or sight, never a life. The one exception is lightning in a bottle, whose strike is telegraphed.
- Every power-up is useful on lit levels. Light-based ones also light things up on dark levels.
- Unchanged: one held slot, Space to use, picking one up while the slot is full uses it at once, cash (1 and 5) and extra life drops, drops blink and vanish after 10s.

## Power-ups

| Key | Name | Effect | Catch |
|---|---|---|---|
| `coffee` | Black coffee | Speed ×1.5 for 15s | none |
| `sawed_off` | Sawed-off | 12s. Each shot fires 5 pellets at −30°, −15°, 0°, +15°, +30° from your aim. Normal fire rate, range and damage per pellet. | none |
| `ghost` | Partner's ghost | Circles you (radius 60) for 10s. Any enemy he touches dies and can drop items. | none |
| `flashbulb` | Flashbulb | Every enemy freezes for 3s. On dark levels the scene lights up fully, then fades back over 1s. | A white overlay covers the screen, fading from full to clear over 1s |
| `lightning` | Lightning in a bottle | Every enemy dies, with no drops | A warning mark appears where you stand. After 2s, lightning strikes it: anything within 40 of the mark is hit, and so are you if you're there. |
| `fog` | Fog bank | 6s. Enemies stop chasing and wander in random directions. | A dark overlay leaves only a clear circle (radius 120) around you |
| `flare` | Road flare | Dropped at your feet and lasts 6s. Enemies (flying ones too) chase the nearest flare instead of you. Gives off light on dark levels. | Enemies bunch up where you dropped it |
| `lucky_coin` | Lucky coin | 50/50. Heads: every enemy dies, with no drops. | Tails: one enemy spawns on every gate tile at once (12), picked from the level's enemy list. "HEADS"/"TAILS" shows over you for 1s. |
| `trench_coat` | Trench coat | Worn until something hits you. The hit takes the coat, you blink invincible for 1.5s, and you lose no life. A second coat does nothing while you're wearing one. | You're 20% slower while wearing it |
| `whiskey` | Whiskey | Invincible for 5s | Movement drifts: velocity eases toward your input rather than snapping to it |

**Drop odds (relative):**
- Cash and life: `coin` 40, `coin5` 8, `life` 2
- Common: `coffee` 5, `sawed_off` 5
- Middle: `flashbulb` 4, `fog` 4, `flare` 4, `trench_coat` 3, `whiskey` 3, `lucky_coin` 3
- Rare: `ghost` 2, `lightning` 2

**Shop:** the trench coat replaces the sheriff badge as the second extra item, at 10 cash. It goes through the normal pickup path (held slot, or used at once).

## Structure

- **`scripts/powerups.gd`**, on a new `Powerups` node under the player. Holds the durations and `use(kind)`, and spawns the flare, ghost and lightning mark. All power-up behaviour lives here.
- **`Player.gd`** keeps:
  - movement and shooting;
  - the `effects` timers and `has_effect()`;
  - `pick_up()` for cash, life and the slot, handing power-ups to `$Powerups.use()`;
  - a new `take_hit()`, the single entry point for anything that hurts the player. It does nothing while invincible or on whiskey, uses up the coat if one is worn, and otherwise calls `die()`.

  The enemy-touch check and the lightning strike both go through `take_hit()`. Speed takes coffee and the coat into account; whiskey changes how velocity is applied. A `whiteout` value (0 to 1) decays each frame and drives the flash.
- **Enemies** get `target()`, which returns the nearest flare if one exists, otherwise the player. While `flashbulb` is active they don't move. While `fog` is active, step enemies pick a random direction for each step and flying enemies drift in a random direction. All tombstone and smoke code is removed.
- **New scenes:**
  - `flare.tscn`: in the `flares` group, with a Sprite2D and a PointLight2D that's on only on dark levels.
  - `ghost.tscn`: an Area2D that orbits the player and kills any enemy it overlaps.
  - `lightning.tscn`: the blinking mark; when it strikes, it adds whiteout and checks the radius.
- **HUD** gets two overlays below the existing HUD nodes, both read from the player each frame:
  - `Whiteout`: a white ColorRect whose alpha comes from the player's `whiteout`;
  - `Fog`: a ColorRect with a small shader for the dark overlay and clear circle, centred on the player, visible while `fog` is active.
- **Spawner** gets `spawn_at(tile)`, which `spawn_enemy()` now uses, and `rush()`, which spawns one enemy on every gate tile.
- **Level** gets `@export var dark := false`. When on:
  - a CanvasModulate darkens the scene; the colour is a placeholder `Color(0.15, 0.15, 0.2)` for you to tune;
  - the player's existing PointLight2D is switched on, and enemies switch theirs on in `_ready`;
  - the CanvasModulate colour blends toward white by the player's `whiteout`, which is how the flashbulb lights the scene.

  `lvl1` stays lit.

## Placeholders (slots for your art)

- **Item icons:** letter squares in `sprites/items/` for each new key. `coffee.png` stays. The old seven icons are deleted.
- **In-world sprites:** `sprites/flare.png`, `sprites/ghost.png`, `sprites/lightning_mark.png`.
- **No art file:** the whiteout, the fog circle, the HEADS/TAILS label (default font), and the coat and whiskey tints on the player.

## Testing

Headless test scripts, as before, with one check per effect and one per catch:
- the coat absorbs exactly one hit;
- whiskey blocks hits;
- the lightning strike hits you only inside its radius;
- enemies follow the flare, freeze under the flashbulb and wander in fog;
- tails spawns 12 enemies;
- the sawed-off fires 5 pellets;
- the ghost kills on touch;
- the shop sells the coat.

The earlier loop tests must still pass.
