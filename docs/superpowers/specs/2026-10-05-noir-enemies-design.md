# Noir enemies

You're fighting the mob, with weirder things creeping in on later and dark levels. Several enemy types shoot, each in its own way. Every shot is telegraphed and slow enough to see, because one hit kills you.

## Rules

- Enemy bullets travel at 160 (yours travel at 350) unless stated otherwise. Walls stop them. They hit you through `take_hit()`, so the coat and whiskey absorb them.
- Every gunman gives a visible warning before or while firing.
- Speeds are in game units per second. The goon is 75, you're 200.
- Each level picks its own enemies through the spawner's `enemy_scenes` list. `lvl1` keeps goons only.

## Roster

| Scene | HP | Speed | Behaviour | Warning |
|---|---|---|---|---|
| `basicEnemy` (Goon) | 1 | 75 | Unchanged: jerky 45° steps toward its target | — |
| `enforcer` | 3 | 50 | Steps like the goon. Bumping into another enemy shoves it one step away. Bumping into a dug-in Lookout knocks its cover over, and the Lookout dies with no drop. | — |
| `runner` | 2 | 150 | Goon movement, faster | — |
| `gunsel` | 2 | 70 | Goon movement. When the angle to his target is within 10° of one of the 8 directions, he stops, aims for 0.5s, and fires one bullet along that direction. 2s cooldown. | Red tint while aiming |
| `tommyGunner` | 3 | 45 | Goon movement. Every 3s, without stopping, fires 3 bullets 0.12s apart, each aimed at his target ±10°. | Sprite shakes for 0.4s first |
| `sniper` | 2 | 0 | Never leaves the gateway tile he spawns on, so he stays under the dark cover. Every 4s he locks onto his target's position at that moment, shows the aim line for 1s, then fires one bullet at 400 along it. | Thin red aim line, 1s |
| `lookout` | 2, then 6 | 75 | Picks a random open floor tile at least 3 tiles (120) from you and walks there. Then he digs in: stops for good, his HP becomes 6, and a cover sprite shows. Every 3s while dug in, he fires 4 bullets (up, down, left, right). | Flashes for 0.4s before each volley |
| `shadow` | 1 | 60 | Flies straight at its target through walls. Spawns anywhere around the edge. Dark levels: visible only where Light2D lights reach (light-only material), and fully visible while the flashbulb whiteout is above 0.3. Lit levels: drawn at 35% opacity. | — |
| `mannequin` | 3 | 110 | Goon movement, but only while you're moving (your velocity above 1). Freezes the instant you stop. | — |
| `stiff` | 6 | 35 | Goon movement. `group_size = 3`: the spawner puts one on each tile of the same gateway. | — |
| `crow` | 1 | 220 | `group_size = 3`. Spawns from a random point around the edge, as a line of 3, 50 apart. Flies straight at where you were when it spawned, ignoring walls. Off-screen it's removed (no death mark, no drop) and no longer counts as an enemy. | — |

## Black cat

- A level checkbox, `black_cat` (on for `lvl1` for now). While the level's wave is running, the cat appears every 25–45s.
- It runs from a random gateway to the opposite one at speed 140, then disappears.
- While it's on screen, enemies' `target()` returns the nearest cat or flare, whichever is closer, instead of you.
- An enemy that touches the cat dies, with normal drops.
- It's not in the `enemies` group, so bullets, lightning, the lucky coin and you pass through or ignore it.

## How power-ups affect enemies

- **Flashbulb:** freezes all movement, aim timers, warnings and enemy bullets in flight for its 3s.
- **Fog:** enemies wander as before. Gunmen don't start new shots, and a shot already being aimed is cancelled.
- **Flare:** gunmen aim at their `target()`, so they shoot at the flare.
- **Lightning and a heads on the lucky coin:** kill every enemy, including Snipers and dug-in Lookouts.
- **Partner's ghost:** kills on touch, as before.
- **Your death:** after the freeze, enemy bullets are removed along with the enemies.

## Structure

- **`basic_enemy.gd`** stays the shared base, and gains:
  - `frozen()`: true while the flashbulb is active;
  - cats in `target()`;
  - a `bumped(other)` hook, called for each enemy it collides with during a step;
  - `shove(direction)`: starts a step in that direction;
  - an `@export var group_size := 1` and an `@export var edge_spawn := false` for the spawner.
- **One script per new behaviour**, each extending `basic_enemy.gd`: `enforcer.gd`, `gunsel.gd`, `tommy_gunner.gd`, `sniper.gd`, `lookout.gd`, `shadow.gd`, `mannequin.gd`, `crow.gd`. Runner and Stiff are scene settings only.
- **Scenes** inherit `basicEnemy.tscn`. `toughEnemy`, `fastEnemy` and `flyingEnemy` are deleted (replaced by `enforcer`, `runner` and `shadow`).
- **`enemyBullet.tscn` / `enemy_bullet.gd`:**
  - an Area2D with layer 0 and mask 4 (you, and walls);
  - in the `enemy_bullets` group;
  - its `speed` can be set per shot;
  - it doesn't move while the flashbulb is active.
- **Spawner:**
  - for `edge_spawn` enemies, picks a random point on the rectangle one tile outside the arena walls;
  - for `group_size > 1`, spawns the whole group (same gateway for Stiff, a line for Crows).
- **Level:**
  - the `black_cat` checkbox and its timer;
  - removes the `enemy_bullets` group along with enemies after a death.
- **`blackCat.tscn` / `black_cat.gd`:** an Area2D in the `cats` group that kills enemies it overlaps.

## Placeholders

- **Tinted copies of the goon sprite:**
  - Enforcer (dark red), Runner (orange), Gunsel (grey, so his red aiming warning stands out), Tommy-gunner (purple), Sniper (blue), Lookout (yellow);
  - Shadow (black), Mannequin (pale), Stiff (grey-green).
- **New letter squares:** `sprites/crow.png`, `sprites/cat.png`, `sprites/cover.png`.
- **Enemy bullets:** your bullet sprite tinted red.
- **No art file:** the aim line (a Line2D) and the tint, shake and flash warnings.

## Testing

Headless test scripts:
- each enemy's HP, speed and pattern;
- warning timings;
- the Gunsel only fires when lined up; the Sniper's line is locked and can be dodged;
- the Lookout's dig-in and 4-way volley;
- the Enforcer's shove and knocking over the Lookout's cover;
- Shadow visibility on dark and lit levels;
- the Mannequin's movement only while you move;
- groups;
- Crows leaving without blocking the exit;
- the cat's lure, kill, pass-through and timing;
- every power-up interaction above;
- bullets cleared on death.

Existing suites must still pass.
