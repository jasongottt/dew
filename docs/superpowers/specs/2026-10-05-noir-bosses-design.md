# Noir bosses

This follows Prairie King's shape: a mob boss you fight twice (the Duelist), then something weird behind the mob (the Man in the Rain).

## Boss levels

- **Setup:** `level.gd` gets `@export var boss_scene: PackedScene`. When it's set:
  - no wave timer and no normal spawns (the spawner is turned off);
  - the boss is placed at `SHOP_TILE`;
  - the HUD's top bar shows boss health / max health instead of time;
  - the exit opens once the boss and everything it summoned are dead.
- **Bosses are in the `enemies` group and the `bosses` group.**
- **When you die mid-fight:** after the freeze, normal enemies and enemy bullets are cleared, but the boss stays at its current health. It's idle for 2s after you respawn.
- **Making a boss level:** no new levels are created. Duplicate `lvl1` in the editor and set Boss Scene.

## Power-ups against bosses

- **Lightning, and a heads on the lucky coin:** 10 damage to each boss instead of killing it. `die(false)` callers check the `bosses` group.
- **Partner's ghost:** 1 damage per touch, at most every 0.5s.
- **Flashbulb:** freezes the boss for 3s, like other enemies.
- **Fog:** the boss stops aiming and wanders.
- **Flare:** the boss aims at its `target()`.
- **Coat and whiskey:** absorb boss bullets through `take_hit()`.

## The Duelist

`duelist.tscn` (1st fight) and `duelist2.tscn`, which inherits it with `second_fight = true`.

| | 1st fight | 2nd fight |
|---|---|---|
| HP | 50 | 100 |
| Movement | Dashes at 500 to one of 6 fixed spots spread around the arena, picking one at least 120 from you | same |
| Aim | Aim line follows his target for 0.5s, then locks and brightens for 0.4s | follows 0.4s, locked 0.3s |
| Shots | 3 shots, 0.15s apart, along the locked line at speed 300 | Two lines, one on the target and one offset 30° to a random side. 3 shots along each, speed 360. |
| Every 3rd round | Fan: 5 shots spread from −30° to +30° around the target, instead of the normal shots | 7-shot fan, −45° to +45° |

A round is: dash, aim, shoot, then pause 0.6s.

## The Man in the Rain

`man_in_the_rain.tscn`. His level should have `dark` on; the boss forces it on if the level forgot.

- **150 HP.** Drifts toward you at speed 40, ignoring walls. Touching him kills you, as with any enemy.
- **Visible and hittable only while lit:**
  - for 1s after any of his lightning strikes;
  - while your whiteout is above 0.3;
  - within 100 of you.

  When unlit, he's hidden and not on any collision layer bullets can hit, so bullets pass through.
- **Lightning:**
  - every 4s, he places 3 strike marks, one under you and two at random open floor spots;
  - they strike 1.5s later, with radius 40, killing you or any enemy under them;
  - they use the same mark sprite as the lightning power-up;
  - each strike adds whiteout 0.6, which is what makes him visible.
- **Summons:** every 10s, 2 Shadows from the edge.
- **Below 75 HP:** 5 marks every 3s.

## Structure

- **`boss.gd`** extends `basic_enemy.gd`. It overrides `die()` so it only dies at 0 HP, and adds:
  - `damage_boss(amount)`;
  - `idle_for(seconds)`;
  - `max_health`, for the HUD.
- **`duelist.gd` and `man_in_the_rain.gd`** extend `boss.gd`.
- **Strike marks:**
  - `lightning.gd` gets `@export var time_left` (default 2.0) and is reused for the boss's marks;
  - the power-up's mark already kills enemies under it;
  - no strike mark, the power-up's or the boss's, ever damages a boss. The lightning power-up's 10 boss damage happens once, when it's used.
- **Level helper `random_spot()`:** any floor tile without an object. Also used by the Lookout.

## Placeholders

- **The Duelist:** your goon sprite tinted white.
- **The Man in the Rain:** your goon sprite blacked out, at 2× scale (5.0, which is still an even 4 screen pixels per art pixel).
- **The aim lines:** Line2D, red, turning white when locked.

## Testing

Headless test scripts:
- boss level setup: no timer, HUD shows boss health, the exit opens only when the boss is dead;
- the boss keeps its health through your death;
- the Duelist's dash spots, aim and lock timings, shot counts, fan every 3rd round, and the second-fight differences;
- the Man in the Rain's visibility rules (bullets pass through when unlit and hit when lit), mark count, timing and placement, damage to you, summons, and the faster phase below 75 HP;
- the power-up exceptions above.
