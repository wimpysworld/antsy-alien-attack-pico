# Antsy Alien Attack Pico 👾🛸💥

A *"sequel"* to [Antsy Alien Attack](https://github.com/wimpysworld/antsy-alien-attack).

- Use [pico-8](https://www.lexaloffle.com/pico-8.php) because I want to learn it.
- Vertical shooter
- 1-UP or 2-UP
- Asteroid belt to each wave (mini-game)
  - Hyperspeed, no weapons
- 5 waves each with a boss
- Post wave status report
- 5 (or more) distinct alien enemies
- 1 life governed by HP meter
- "Juice"
- Publish Linux builds
 - `.deb`, Snap and Flatpak
 - GitHub workflow for Itch.io

## Pickups ⚡️

- Weapon upgrades
  - Faster speed
  - Shorter cool down
  - More damage
  - Wider spray patterns
- Shields
- Weapons block
  - Wipeout alien projectiles and prevent fire for some seconds
- Smartbomb
  - Damage all aliens and wipeout all alien projectiles
- Power
  - Charges the generator
  - Fully charged generator yeilds player HP
  - Hold second button to release a smart bomb

## Design 📐

- 1-UP accent is green, 2-UP accent is red.
- Alien projectiles will always be yellow/orange
- Subtle parallax starfield backdrop
  - Helps make projectiles visible
  - More sprites for actors and projectiles
- Minimal player HUD due to 128x128
- Target 60FPS on low-power handhelds
- Use particle system to overcome sprite bank limits
- Hitbox collision detection to preserve performance budget

## Risks 🚨

- Time
- pico-8 token limit
- pico-8 performance budget
- Time
- Flatpak and publishing in Flathub
- Level "design"
- Time
- Juicy enough
- pico-8 sprite bank size
- Finding suitable sfx and gfx
- Time

## Outcomes 🤞

- Reference for packaging/distribution pico-8 games to Linux users
- pico-8 tooling to use for making more games
- Learn some basic juicing and game feel mechanics
- Fun

# TODO

## Engine ⚙️

- [ ] Text renderer
- [ ] State system
- [ ] Actors object
- [ ] Weapons object
- [ ] Super simple sprite system with collision detection
- [ ] Bitwise controller system
- [ ] uint32 handler

## Menus & Game State 🎛️

- [ ] Main screen with Tux
- [ ] Credits
- [ ] Help
- [ ] Game Over
- [ ] Game Win
- [ ] Toggle 30/60 FPS
- [ ] Toggle music
- [ ] Persist Hiscore

## Juice 🧃

- [ ] Particle system

## Build tools 🛠️

- [ ] Linux, Windows, macOS, Raspberry Pi binaries
- [ ] `.deb`
- [ ] Snap
- [ ] Flatpak

## Player 🚀

- [ ] Weapon patterns
- [ ] Collider handling
- [ ] HUD
- [ ] Player performance/skill tracking

## Aliens 👾

- [ ] Attack patterns
- [ ] Weapon patterns
- [ ] Boss patterns

## Levels 🗺️

- [ ] Asteroid field
- [ ] Post-wave report

## Stretch Goals 💪

- [ ] Predictable wave patterns/timings
- [ ] Sprite rotatation and zooming
- [ ] Ship velocity/friction
- [ ] Scene change transitions/wipes
- [ ] Hiscore table

# Graphics Discovery 🖌️

Think about portability to 8x8 or 16x16 sprites with fixed pico-8 16-color palette.

- https://opengameart.org/content/modular-ships
- https://opengameart.org/content/bullet-collection-2-m484-games
- https://opengameart.org/content/shmup-ships
- https://opengameart.org/content/space-ship-shooter-pixel-art-assets
- https://opengameart.org/content/retro-spaceships
- https://opengameart.org/content/1616-ship-collection
- https://opengameart.org/content/space-war-man-platform-shmup-set
- https://opengameart.org/content/rotating-coin
- https://opengameart.org/content/super-dead-space-gunner-merc-redux-platform-shmup-hero
- https://opengameart.org/content/some-invaders

# SFX Discovery 🔊

SFX 35 to 63 are free after the music is added.

# Music Discovery 🎹

Gruber has two carts with music selection that can be used in games. This is
what I've picked:

## From Vol 1

1. pat 00 - 05
2. pat 06 - 13
3. pat 14 - 17
4. pat 18 - 23  Use as Game Theme
5. pat 24 - 29
6. pat 30 - 35
7. pat 36 - 41
8. pat 42 - 45	Use as Boss Fight
9.  pat 46 - 47
10. pat 48 - 54
11. pat 55 - 58
12. pat 59 - 63

## From Vol 2

1. pat 00 - 06  Use as Game Win
2. pat 07 - 12
3. pat 13 - 20  Use as In Game
4. pat 21 - 30
5. pat 31 - 39
6. pat 40 - 42
7. pat 43 - 48  Use as Game Over
8. pat 49 - 55
9. pat 56 - 61  Use for Asteroids

## Music patterns

I used Renoiser to make a new cart with the following music patterns. Not
feasible to add music for the asteroid belt, there would not be sufficient
SFX slots left over.

pat 0  - Attract
pat 6  - In Game
pat 14 - Boss Fight
pat 18 - Game Win
pat 24 - Game Over

