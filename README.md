# Antsy Alien Attack Pico 👾🛸💥

A *"sequel"* to [Antsy Alien Attack](https://github.com/wimpysworld/antsy-alien-attack) to be developed during [Linux Game Jam 2023](https://itch.io/jam/linux-game-jam2023) 🐧 using [pico-8](https://www.lexaloffle.com/pico-8.php) because I want to learn it 🧑‍🎓

## Game design 📐

- Vertical shooter
- 1-UP or 2-UP
- 5 waves each with a boss
- Post-wave status report
- 5 (or more) distinct alien enemies
- 1 life governed by HP meter
- Mini-games between waves
  - Asteroid belt - Go fast, don't die
  - Power spree - A few seconds to grab fast-moving power-ups
    - Both run at hyper-speed with no weapons
  - None shall pass - don't miss any aliens
  - Cargo escort - protect the cargo ship
- "Juice"
- Publish Linux builds
 - `.deb`, Snap and Flatpak

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
  - A fully charged generator yields player HP
  - Hold the second button to release a smart bomb

## Technical considerations 🧠

- 1-UP accent is green, 2-UP accent is red
- Alien projectiles will always be yellow/orange
- Subtle parallax starfield backdrop
  - Helps make projectiles visible
  - More sprites for actors and projectiles
- Minimal player HUD due to 128x128
- Target 60FPS on low-power handhelds
- Use particle system to overcome sprite bank limits
- Use palette swaps to overcome sprite bank limits
- Hitbox collision detection to preserve performance budget

## Risks 🚨

- Time
- pico-8 token limit
- pico-8 performance budget
- Flatpak and publishing in Flathub
- Level "design"
- Time
- Juicy enough
- pico-8 sprite bank size
- Finding suitable sfx and gfx
- pico-8 optimisations create ugly code 🍝
- Time

## Outcomes 🤞

- Reference for packaging/distributing pico-8 games to Linux users
- pico-8 tooling to use for making more games
- Learn some basic juicing and game-feel mechanics
- Fun

# License 👨‍⚖️

The game code will be licensed under the MIT license, but I'll be using graphics, sounds and music from other sources and they have their own licenses.

- All player ship is from [Krystian Majewski](https://www.lexaloffle.com/bbs/?uid=16423) and released under the [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.
- All the music is from [Gruber](https://www.lexaloffle.com/bbs/?uid=11292) and released under the [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.
- Most of the SFX are from [Gruber](https://www.lexaloffle.com/bbs/?uid=11292) and released under the [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.

# TODO

## Engine ⚙️

- [ ] Text renderer
- [ ] State system
- [ ] Actors object
- [ ] Weapons object
- [ ] Super simple sprite system with collision detection
- [ ] Bitwise controller system
- [ ] uint32 handler
- [ ] SFX channel allocator

## Menus & Game State 🎛️

- [ ] Main screen with Tux
- [ ] Credits
- [ ] Help
- [ ] Game Over
- [ ] Game Win
- [ ] Toggle music
- [ ] Persist Hiscore

## Juice 🧃

- [ ] Particle system
- [ ] Screen shake

## Build tools 🛠️

- [ ] Linux, Raspberry Pi, Windows, & macOS binaries
- [ ] `.deb`
- [ ] Snap
- [ ] Flatpak (*stretch goal*)
- [ ] AppImage (*stretch goal*)

## Player 🚀

- [ ] Controls and movement
- [ ] Collider handling
- [ ] HUD
- [ ] Pickups
  - [ ] Shields
  - [ ] Weapon upgrade: faster speed, shorter cool down, more damage
  - [ ] Weapon patterns; more devastation
  - [ ] Weapons block; wipeout alien projectiles and prevent fire for some time
  - [ ] Smartbomb; damage all aliens and wipeout all alien projectiles
  - [ ] Power; charges the generator.
    - [ ] A fully charged generator yields player HP
    - [ ] Hold the second button to release a smart bomb

## Aliens 👾

- [ ] Alien types
- [ ] Attack patterns
- [ ] Weapon patterns
- [ ] Boss patterns

## Levels 🗺️

- [ ] Asteroid belt - Go fast, don't die
- [ ] Power spree - A few seconds to grab fast-moving power-ups
- [ ] None shall pass - don't miss any aliens
- [ ] Cargo escort - protect the cargo ship
- [ ] Rock on - more rocks than you can avoid, lots of shield boosts
- [ ] Peekaboo - Aliens appear briefly, fire and leave
- [ ] Canyon run - narrow canyon with lots of rocks at speed (*stretch goal*)
- [ ] Tunnel through - make a path through the rocks (*stretch goal*)

## Publishing 🕹️

- [x] GitHub page
- [ ] Itch.io page
- [ ] Snapstore page

## Stretch Goals 💪

- [ ] Player performance/skill tracking with post-wave report
- [ ] Publish in Flathub page
- [ ] Predictable wave patterns/timings
- [ ] Sprite rotation and zooming
- [ ] Ship velocity/friction
- [ ] Scene change transitions/wipes
- [ ] Formation "animations"
- [ ] Player gravity-guided pick-ups
- [ ] Pick-up animations

# Graphics Discovery 🖌️

Think about portability to 8x8 or 16x16 sprites with the fixed pico-8 16 colour palette.

- https://opengameart.org/content/modular-ships
- https://opengameart.org/content/1616-ship-collection
- https://opengameart.org/content/bullet-collection-2-m484-games
- https://opengameart.org/content/shmup-ships
- https://opengameart.org/content/space-ship-shooter-pixel-art-assets
- https://opengameart.org/content/retro-spaceships
- https://opengameart.org/content/space-war-man-platform-shmup-set
- https://opengameart.org/content/super-dead-space-gunner-merc-redux-platform-shmup-hero
- https://opengameart.org/content/some-invaders

# Music Discovery 🎹

[Gruber](https://www.lexaloffle.com/bbs/?uid=11292) has two carts with music selection that can be used in games. This is what I've picked:

## From [Pico-8 Tunes Vol. 1](https://www.lexaloffle.com/bbs/?tid=29008)

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

## From [Pico-8 Tunes Vol. 2](https://www.lexaloffle.com/bbs/?tid=33675)

1. pat 00 - 06  Use as Game Win
2. pat 07 - 12
3. pat 13 - 20  Use as In Game
4. pat 21 - 30
5. pat 31 - 39
6. pat 40 - 42
7. pat 43 - 48  Use as Game Over (not enough instrument space)
8. pat 49 - 55
9. pat 56 - 61  Use for Asteroids (not enough instrument space)

## Music patterns

I used [Renoiser](https://www.lexaloffle.com/bbs/?tid=36922) to make a new cart with the following music patterns. Not feasible to add music for the asteroid belt, there would not be sufficient SFX slots left over.

- pat 0  - Attract
- pat 6  - In Game
- pat 14 - Boss Fight
- pat 18 - Game Win

# SFX Discovery 🔊

SFX 35 to 63 are free after the music is added. Only two channels are available for SFX so none of them can be particularly long running.

[Gruber](https://www.lexaloffle.com/bbs/?uid=11292) also has a [Pico-8 SFX Pack](https://www.lexaloffle.com/bbs/?tid=34367) he's created for various pico-8 games.

## SFX slots and origins

Here are the SFX slot numbers and what the corresponding SFX is used for. Any that start with "From" indicate which slot in the Pico-8 SFX Pack they were sourced from.

- 0 : UI Move          : From 8
- 1 : UI Action        : From 11
- 2 : 1-UP Fire        : Mine
- 3 : 2-UP Fire        : Mine
- 4 : Alien Fire       : Mine
- 5 : Hit              : Mine
- 6 : Explosion 1      : From 21
- 7 : Explosion 2      : From 25
- 8 : Explosion 3      : Mine
- 9 : Pickup Item      : From 56
- 10: Shields Up       : From 48
- 11: Generator Power  : From 51
- 12: Smartbomb        : From 45
- 13: Weapons Disabled : From 40

# Development tools 🧑‍💻

All development was done on Linux workstations, running either [NixOS](https://nixos.org) ❄️  or [elementary OS](https://elementary.io/). I decided to use pico-8 directly for all development, and the following tools to help with the process:

- [PICO-8 CRT effect HTML template](https://github.com/carlc27843/pico8-crt-plate)
- [Renoiser](https://www.lexaloffle.com/bbs/?tid=36922)
- [respriter](https://www.lexaloffle.com/bbs/?tid=35255)

