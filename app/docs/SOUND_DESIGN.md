# BEZY V1 Sound Design Map

## Current state

There are no audio assets or playback dependency in the project. Despite its
name, `SoundService` currently provides haptic feedback only. The saved “Sound”
preference does not control any audible output yet.

## Creative direction

BEZY should sound bright, precise, clever, and energetic—not childish or like a
casino. Use a small shared palette of glassy digital clicks, warm synth notes,
and short directional whooshes. Reuse a three- or four-note BEZY sonic motif in
the launch sting, stage completion, and major unlocks to build brand recognition.

Audio must reinforce visible feedback and must never be the only way to
understand game state.

## V1 required sound set

| File | Trigger | Purpose | Existing hook |
|---|---|---|---|
| `ui_tap.wav` | Primary button, mode, world, stage | Responsive UI confirmation | `tileTap()` is already called in navigation |
| `tile_enter_01.wav`–`03.wav` | Enter ordinary number tile | Progress rhythm; rotate/pitch variants | `tileTap()` in gameplay |
| `tile_backtrack.wav` | Remove last path tile | Clear reversal feedback | `tileBacktrack()` |
| `move_invalid.wav` | Wall, illegal entry, overshoot | Short, soft warning—not punitive | `invalidMove()` |
| `teleport.wav` | Teleport departure/arrival | Spatial transition | `trampolineBounce()` |
| `gate_open.wav` | Gate becomes passable / entered | Ability confirmation | `gatePass()` |
| `target_reached.wav` | Exact total enters target | Immediate success confirmation | add before victory sequence |
| `victory_sting.wav` | Stage solved | 1–2 second branded celebration | `victory()` |
| `stage_unlock.wav` | Next stage becomes available | Reward and progression | add to world-map unlock sequence |
| `timer_warning.wav` | 10 seconds remaining | Urgency without anxiety | add to challenge timer |
| `timer_final_tick.wav` | Last 3 seconds | Precise countdown | add to challenge timer |
| `time_up.wav` | Timer reaches zero | Clear neutral failure | add to challenge timer |

## Special-cell layer

These can follow after the core set, but each should have a recognizable sonic
identity:

| File | Event / sound character |
|---|---|
| `joker_reveal.wav` | Two-note sparkle when choices appear |
| `joker_choose.wav` | Confident selected-value note |
| `ice_slide.wav` | Short loop/sequence while sliding; stop cleanly on landing |
| `mirror.wav` | Reversed chime or audible flip |
| `clone.wav` | One note duplicated with a tiny delay |
| `zero.wav` | Fast downward dissolve to silence |
| `black_hole.wav` | Low, brief suction sound; avoid horror styling |
| `bomb.wav` | Compact soft impact, never a realistic explosion |
| `lonely_unlock.wav` | Four small tones resolving into one warm note |
| `hint.wav` | Subtle “idea” shimmer |
| `solution_preview.wav` | Quiet route sweep; do not compete with tile sounds |
| `star_earned.wav` | One concise reward accent per awarded star |

## Background music recommendation

Use background music, but keep it optional and restrained:

- One seamless 60–90 second puzzle loop is enough for V1.
- Calm electronic/marimba/synth texture, approximately 80–105 BPM.
- No vocals and no dominant melody that competes with arithmetic decisions.
- Duck or pause it under instruction dialogs, countdown warnings, and victory.
- Add separate **Music** and **Sound effects** switches. Do not use the current
  single Sound switch for both; users often want effects without music.
- Remember both preferences locally and pause music when the app backgrounds.

Music is useful for emotional bonding and brand memory, but the branded sonic
motif and excellent interaction effects are higher priority than a long track.
If schedule or licensing is tight, ship V1 with SFX plus the victory/launch motif
and add background music in a later update.

## Asset delivery specification

- Supply original or commercially licensed audio only; keep license receipts.
- Master at 48 kHz, 24-bit WAV.
- Short effects: mono WAV, tightly trimmed, generally 80–700 ms.
- Stings: stereo WAV, generally 1–2 seconds.
- Music: seamless stereo master plus a compressed mobile export, with loop
  points documented.
- Avoid clipping; leave headroom and normalize the family consistently.
- Provide dry files without reverb tails that prevent responsive playback,
  except where the tail is part of the intentional effect.

Place final files under:

```text
assets/audio/sfx/
assets/audio/music/
```

## Implementation plan

1. Product owner supplies/approves the core sound set and confirms licenses.
2. Add a mobile audio package with low-latency asset playback and pooling.
3. Extend `SoundService` so every existing method plays its mapped asset while
   preserving haptics.
4. Add new explicit methods for special cells, timer events, hints, unlocks,
   and music lifecycle.
5. Split stored settings into `sfxEnabled` and `musicEnabled`, migrate the old
   Sound preference, and add two localized controls.
6. Preload frequently used effects at startup; never block gameplay on audio.
7. Test Bluetooth, device silent mode, background/foreground, interruptions,
   rapid tile entry, low-end Android devices, and iOS hardware.

## Acceptance criteria

- No noticeable delay on tile entry.
- Repeated rapid moves do not cut off or distort essential sounds.
- Music loops without a click or gap.
- No sound plays when its category is disabled.
- App pause/background immediately stops or pauses music.
- Every audible event has matching visual feedback.
- SFX remain clear over music at comfortable phone-speaker volume.
