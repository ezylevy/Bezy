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

## Complete in-app cue inventory

This is the implementation checklist for every place where sound can improve
feedback, excitement, or brand recognition. `P0` is required for the first
sound-enabled release, `P1` is the next polish pass, and `P2` is optional.

### App, navigation, and settings

| Priority | Location / event | Cue |
|---|---|---|
| P0 | App reaches the home screen | Very short BEZY launch motif; play once per cold launch |
| P0 | Main card, primary button, stage, mode, help, close, and back action | Shared `ui_tap` family |
| P1 | Sound or haptics setting enabled | Bright confirmation toggle |
| P1 | Sound or haptics setting disabled | Muted/downward toggle; do not play after SFX has been disabled |
| P1 | Open the campaign map / focus into the large map | Soft directional whoosh |
| P0 | Locked stage tapped | Gentle locked/error cue |
| P0 | Stage lock changes to unlock/free | Unlock rise followed by the BEZY motif |
| P1 | Learning/Challenge mode changes | Two related but distinct mode accents |
| P2 | External privacy page opens or fails | Neutral open cue / soft warning |

### Core board interaction

| Priority | Location / event | Cue |
|---|---|---|
| P0 | Valid start tile selected | Start pulse, stronger than an ordinary tile |
| P0 | Ordinary tile entered | One of 3 subtle click/note variants; pitch may follow the running sum |
| P0 | Finger backtracks or Undo is pressed | Short reverse click |
| P0 | Reset pressed | Fast descending reset sweep |
| P0 | Illegal non-adjacent move | Soft invalid tick |
| P0 | Wall touched | Dry blocked knock, distinct from arithmetic failure |
| P0 | Gate rejects the current sum | Closed electronic latch |
| P0 | Center entered with the wrong sum / overshoot | Short neutral arithmetic warning |
| P0 | Exact target is reached before the victory dialog | Target-lock confirmation |
| P0 | Board solved | Branded victory sting |
| P1 | Each star appears in the victory dialog | One reward accent per star, rising slightly |
| P1 | Personal-best/minimum-moves result | Extra shimmer layered after the victory sting |
| P0 | Next level, replay, or return to map | Shared navigation cue |

### Special cells

| Priority | Location / event | Cue |
|---|---|---|
| P0 | Teleporting door entered | Departure whoosh immediately followed by arrival ping at the destination |
| P0 | Smart gate accepts the current state | Gate-open latch |
| P0 | Joker choices appear | Two-note reveal sparkle |
| P0 | Joker value selected | Firm selection tone reflecting the chosen option |
| P1 | Ice movement starts / crosses cells / lands | Light sliding texture with a clean landing stop |
| P1 | Mirror applies its operation | Reversed or reflected chime |
| P1 | Clone applies its operation | A note repeated with a short delay |
| P1 | Zero resets the running value | Quick dissolve down to silence |
| P1 | Black hole removes possible directions | Brief suction followed by a single surviving-direction ping |
| P1 | Bomb destroys a neighboring cell | Compact synthetic impact; never a realistic explosion |
| P1 | Lonely cell is still locked | Four unresolved ticks |
| P1 | Lonely cell becomes enterable / is crossed | Four ticks resolving to one warm note |

### Guidance, learning, and dialogs

| Priority | Location / event | Cue |
|---|---|---|
| P1 | Basic or special-cell explanation opens | Quiet teaching chime; no repetition while paging dialogs |
| P1 | “Do not show again” checked | Small checkbox confirmation |
| P0 | Hint requested and found | Subtle idea shimmer |
| P0 | Hint requested but no continuation exists | Soft neutral warning |
| P1 | Guided-solution dialog opens | Solver reveal cue |
| P1 | Previous/next solution step | Low-volume step tick |
| P1 | Automatic solution playback starts, pauses, or finishes | Start/pause transport cues and a completion accent |
| P0 | “Apply this solution” pressed | Reset sweep first, then quiet route-step cues during playback |
| P2 | Status/message dialog appears | One unobtrusive notification tone; never repeat on rebuild |

### Challenge and lifecycle

| Priority | Location / event | Cue |
|---|---|---|
| P1 | Challenge countdown begins | Very light start cue |
| P0 | Ten seconds remain | Warning accent once |
| P0 | Final three seconds | One precise tick per second |
| P0 | Time reaches zero | Clear neutral time-up cue |
| P1 | App goes to background / returns | Pause and resume music with a short fade; no SFX needed |
| P1 | Dialog, tutorial, countdown warning, or victory overlays music | Duck music by roughly 6–10 dB |

Avoid sounds for passive scrolling, map panning, pinch zooming, every timer
second before the warning window, or purely decorative animation. Those would
create fatigue and make meaningful cues less clear.

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
