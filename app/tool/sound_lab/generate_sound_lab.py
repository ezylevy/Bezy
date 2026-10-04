"""BEZY Sound Lab: synthesizes three original sound palettes for every in-game
cue so the product owner can audition and pick per cue.

    python generate_sound_lab.py            -> writes app/sound_lab/{A,B,C}/*.wav

Palettes
  A  Crystal Neon   - FM glass bells, shimmer, airy reverb
  B  Warm Arcade    - soft pulse waves, pitch glides, 8-bit noise
  C  Organic Magic  - marimba / kalimba plucks, wood, wind, bells

Every cue is built from the BEZY motif B4-E5-F#5-B5 where it makes sense, so
the brand is recognizable across launch, unlock and victory. Only numpy is
needed; output is 44.1 kHz 16-bit mono, peak-normalized, deterministic.
"""
import os
import wave

import numpy as np

SR = 44100
RNG = np.random.default_rng(20261004)
OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'sound_lab')

NOTE = {'C4': 261.63, 'E4': 329.63, 'G4': 392.0, 'A4': 440.0, 'B3': 246.94,
        'B4': 493.88, 'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'F#5': 739.99,
        'G5': 783.99, 'G#5': 830.61, 'A5': 880.0, 'B5': 987.77, 'C6': 1046.5,
        'E6': 1318.5, 'F#6': 1480.0, 'B6': 1975.5}
MOTIF = ['B4', 'E5', 'F#5', 'B5']


# ---------------------------------------------------------------- helpers
def t_axis(dur):
    return np.arange(int(SR * dur)) / SR


def silence(dur):
    return np.zeros(int(SR * dur))


def env_exp(n, decay, attack=0.004):
    t = np.arange(n) / SR
    a = np.clip(t / attack, 0, 1) if attack > 0 else 1
    return a * np.exp(-t / decay)


def mix(*parts):
    """parts: (signal, start_seconds) pairs."""
    end = max(int(start * SR) + len(sig) for sig, start in parts)
    out = np.zeros(end)
    for sig, start in parts:
        i = int(start * SR)
        out[i:i + len(sig)] += sig
    return out


def fft_filter(x, low=None, high=None):
    """Smooth spectral band-pass (low/high cutoffs in Hz)."""
    n = len(x)
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / SR)
    gain = np.ones_like(f)
    if high:
        gain *= 1 / (1 + (f / high) ** 4)
    if low:
        gain *= 1 / (1 + (low / np.maximum(f, 1)) ** 4)
    return np.fft.irfft(spec * gain, n)


def reverb(x, amount, length=0.9):
    if amount <= 0:
        return x
    n = int(SR * length)
    ir = RNG.standard_normal(n) * np.exp(-np.arange(n) / SR / (length / 5))
    ir = fft_filter(ir, high=6000)
    ir /= np.max(np.abs(ir)) + 1e-9
    size = len(x) + n
    wet = np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)
    wet /= np.max(np.abs(wet)) + 1e-9
    dry = np.concatenate([x, np.zeros(n)])
    return dry + amount * wet * (np.max(np.abs(x)) + 1e-9)


def sweep_phase(f0, f1, dur, curve='exp'):
    n = int(SR * dur)
    k = np.linspace(0, 1, n)
    f = f0 * (f1 / f0) ** k if curve == 'exp' else f0 + (f1 - f0) * k
    return 2 * np.pi * np.cumsum(f) / SR, f


def noise(dur):
    return RNG.standard_normal(int(SR * dur))


def finish(x, peak=0.89):
    x = np.asarray(x, dtype=float)
    # Trim the inaudible reverb tail (below about -54 dB of the peak).
    loud = np.nonzero(np.abs(x) > np.max(np.abs(x)) * 0.002)[0]
    if len(loud):
        x = x[:loud[-1] + int(0.02 * SR)]
    fade = min(len(x), int(0.012 * SR))
    x[-fade:] *= np.linspace(1, 0, fade)
    x -= np.mean(x)
    m = np.max(np.abs(x)) + 1e-9
    return x / m * peak


def write(path, x):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = (finish(x) * 32767).astype('<i2')
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


# ---------------------------------------------------------------- palettes
class Palette:
    rev = 0.3

    def tone(self, f, dur, vel=1.0):
        raise NotImplementedError

    def note(self, name, dur=0.4, vel=1.0):
        return self.tone(NOTE[name], dur, vel)

    def seq(self, names, step, dur=0.4, vel=1.0, accel=1.0):
        parts, t = [], 0.0
        for i, n in enumerate(names):
            parts.append((self.note(n, dur, vel), t))
            t += step * (accel ** i)
        return mix(*parts)

    def chord(self, names, dur=0.9, vel=0.8):
        return mix(*[(self.note(n, dur, vel), 0.0) for n in names])

    def click(self):
        raise NotImplementedError

    def thud(self, f=110, dur=0.22):
        t = t_axis(dur)
        ph, _ = sweep_phase(f * 1.6, f, dur)
        return np.sin(ph) * env_exp(len(t), 0.06, 0.002)

    def swoosh(self, dur, f0, f1):
        n = noise(dur)
        k = np.linspace(0, 1, len(n))
        out = np.zeros_like(n)
        bands = 8
        for b in range(bands):
            seg = slice(int(b * len(n) / bands), int((b + 1) * len(n) / bands))
            fc = f0 * (f1 / f0) ** (b / (bands - 1))
            out[seg] = fft_filter(n, low=fc * 0.6, high=fc * 1.6)[seg]
        return out * np.sin(np.pi * k) ** 1.5

    def fx(self, x):
        # Short cues get a short room so taps stay snappy.
        length = min(0.9, max(0.25, len(x) / SR * 1.2))
        return reverb(x, self.rev, length)


class CrystalNeon(Palette):
    key, title = 'A', 'Crystal Neon'
    rev = 0.45

    def tone(self, f, dur, vel=1.0):
        t = t_axis(dur + 0.35)
        mod_env = np.exp(-t / 0.18)
        car = np.sin(2 * np.pi * f * t + 2.2 * mod_env * np.sin(2 * np.pi * f * 3.5 * t))
        car += 0.35 * np.sin(2 * np.pi * f * 2.01 * t) * np.exp(-t / 0.25)
        car += 0.2 * np.sin(2 * np.pi * f * 1.003 * t)
        return vel * car * env_exp(len(t), dur * 0.7, 0.003)

    def click(self):
        t = t_axis(0.07)
        return np.sin(2 * np.pi * 2600 * t) * env_exp(len(t), 0.012, 0.001) + \
            0.4 * fft_filter(noise(0.07), low=4000) * env_exp(len(t), 0.006, 0.0005)


class WarmArcade(Palette):
    key, title = 'B', 'Warm Arcade'
    rev = 0.12

    def tone(self, f, dur, vel=1.0, glide=1.0):
        t = t_axis(dur)
        ph, _ = sweep_phase(f * glide, f, dur) if glide != 1.0 else (2 * np.pi * f * t, None)
        sq = np.sign(np.sin(ph)) * 0.6 + 0.4 * np.sin(ph)
        x = fft_filter(sq, high=3800)
        env = np.clip(t / 0.003, 0, 1) * np.where(t < dur * 0.6, 1.0, np.exp(-(t - dur * 0.6) / (dur * 0.18)))
        return vel * x * env

    def click(self):
        t = t_axis(0.045)
        return np.sign(np.sin(2 * np.pi * 1500 * t)) * env_exp(len(t), 0.015, 0.0005)

    def thud(self, f=110, dur=0.2):
        t = t_axis(dur)
        ph, _ = sweep_phase(f * 2.5, f * 0.8, dur)
        return fft_filter(np.sign(np.sin(ph)), high=1200) * env_exp(len(t), 0.07, 0.001)


class OrganicMagic(Palette):
    key, title = 'C', 'Organic Magic'
    rev = 0.3

    def tone(self, f, dur, vel=1.0):
        t = t_axis(dur + 0.25)
        x = np.sin(2 * np.pi * f * t) * np.exp(-t / (dur * 0.55))
        x += 0.35 * np.sin(2 * np.pi * f * 3.98 * t) * np.exp(-t / (dur * 0.12))
        x += 0.12 * np.sin(2 * np.pi * f * 9.9 * t) * np.exp(-t / 0.02)
        return vel * x * np.clip(t / 0.002, 0, 1)

    def click(self):
        t = t_axis(0.06)
        body = np.sin(2 * np.pi * 1150 * t) * env_exp(len(t), 0.012, 0.0005)
        tick = fft_filter(noise(0.06), low=1500, high=6000) * env_exp(len(t), 0.004, 0.0003)
        return body + 0.6 * tick


PALETTES = [CrystalNeon(), WarmArcade(), OrganicMagic()]


# ---------------------------------------------------------------- cues
def sparkle(p, base='B5', count=4, step=0.045, vel=0.45):
    names = ['B5', 'E6', 'F#6', 'B6'] if base == 'B5' else ['E5', 'B5', 'E6', 'B6']
    return p.seq(names[:count], step, dur=0.18, vel=vel)


def warp(p, f0, f1, dur, vel=1.0):
    ph, f = sweep_phase(f0, f1, dur)
    t = t_axis(dur)
    if isinstance(p, WarmArcade):
        x = fft_filter(np.sign(np.sin(ph)), high=3000)
    elif isinstance(p, CrystalNeon):
        x = np.sin(ph + 1.5 * np.sin(ph * 2.5))
    else:
        x = np.sin(ph) + 0.3 * np.sin(ph * 2)
    return vel * x * np.sin(np.pi * np.linspace(0, 1, len(t))) ** 0.6


CUES = {
    'app_launch': ('פתיחת האפליקציה', lambda p: mix(
        (p.seq(MOTIF, 0.11, dur=0.35), 0), (p.chord(MOTIF, 1.1, 0.7), 0.46),
        (sparkle(p, vel=0.3), 0.5))),
    'ui_tap': ('לחיצה בתפריט', lambda p: p.click()),
    'toggle_on': ('הפעלת צליל/רטט', lambda p: p.seq(['E5', 'B5'], 0.07, dur=0.16, vel=0.8)),
    'tile_start': ('בחירת שער כניסה', lambda p: mix(
        (p.seq(['B4', 'E5', 'B5'], 0.05, dur=0.22), 0), (sparkle(p, count=2, vel=0.3), 0.12))),
    'move_invalid': ('צעד לא חוקי', lambda p: p.seq(['E4', 'C4'], 0.09, dur=0.14, vel=0.7)),
    'wall_blocked': ('התנגשות בחומה', lambda p: mix((p.thud(95), 0), (p.click() * 0.4, 0))),
    'gate_closed': ('שער נעול (תנאי לא מתקיים)', lambda p: mix(
        (p.click() * 0.7, 0), (p.click() * 0.5, 0.07), (p.note('C4', 0.18, 0.5), 0.02))),
    'lonely_locked': ('תא בודד נעול', lambda p: mix((p.note('G4', 0.2, 0.5), 0), (p.click() * 0.5, 0.0))),
    'reset': ('איפוס לוח', lambda p: warp(p, 1300, 260, 0.36, 0.8)),
    'hint': ('רמז', lambda p: mix((sparkle(p, base='E5', count=3, step=0.06, vel=0.7), 0))),
    'solution_preview': ('תצוגת פתרון', lambda p: mix(
        (warp(p, 300, 900, 0.3, 0.35), 0), (p.note('E5', 0.4, 0.6), 0.22))),
    'solution_step': ('צעד בהצגת פתרון', lambda p: p.note('B5', 0.12, 0.6)),
    'message_report': ('חלון הודעה מאויר', lambda p: mix(
        (p.note('G5', 0.12, 0.8), 0), (p.note('C6', 0.32, 0.9), 0.12),
        (warp(p, 1046, 1180, 0.25, 0.25), 0.16))),
    'target_reached': ('הגעה ליעד', lambda p: mix(
        (p.chord(['B4', 'E5', 'G#5'], 0.6, 0.8), 0), (p.note('B5', 0.5, 0.6), 0.06))),
    'victory_sting': ('ניצחון בשלב', lambda p: mix(
        (p.seq(MOTIF, 0.12, dur=0.4), 0), (p.chord(MOTIF + ['E6'], 1.3, 0.8), 0.5),
        (sparkle(p, vel=0.45), 0.55), (sparkle(p, vel=0.35), 0.85))),
    'star_earned': ('כוכב', lambda p: mix((p.note('B6', 0.3, 0.8), 0), (p.note('F#6', 0.2, 0.3), 0.04))),
    'stage_unlock': ('פתיחת שלב חדש', lambda p: mix(
        (warp(p, 220, 1000, 0.45, 0.5), 0), (p.seq(MOTIF, 0.06, dur=0.3), 0.42),
        (p.chord(MOTIF, 0.8, 0.6), 0.62))),
    'map_open': ('כניסה למפה', lambda p: mix((p.swoosh(0.45, 400, 3000) * 0.6, 0), (p.note('E5', 0.4, 0.5), 0.3))),
    'locked_stage': ('שלב נעול', lambda p: mix((p.thud(140, 0.16), 0), (p.thud(120, 0.16), 0.12))),
    'joker_reveal': ('ג׳וקר - הצגת אפשרויות', lambda p: mix(
        (p.seq(['E5', 'B5'], 0.08, dur=0.25), 0), (sparkle(p, vel=0.35), 0.1))),
    'joker_choose': ('ג׳וקר - בחירה', lambda p: p.chord(['E5', 'B5'], 0.35, 0.9)),
    'ice_slide': ('החלקה על קרח', lambda p: mix(
        (p.swoosh(0.5, 2500, 6000) * 0.7, 0), (p.note('E6', 0.3, 0.3), 0.05))),
    'mirror': ('מראה', lambda p: mix((p.note('E5', 0.3)[::-1] * 0.8, 0), (p.note('E5', 0.3), 0.3))),
    'clone': ('שכפול', lambda p: mix((p.note('B5', 0.25), 0), (p.note('B5', 0.25, 0.6), 0.09),
                                    (p.note('B5', 0.25, 0.35), 0.18))),
    'zero': ('תא אפס', lambda p: warp(p, 900, 120, 0.4, 0.8) * np.linspace(1, 0, int(SR * 0.4)) ** 0.5),
    'black_hole': ('חור שחור', lambda p: mix(
        (warp(p, 400, 60, 0.5, 0.8), 0), (p.swoosh(0.5, 3000, 300)[::-1] * 0.4, 0))),
    'bomb': ('פצצה', lambda p: mix(
        (fft_filter(noise(0.35), high=900) * env_exp(int(SR * 0.35), 0.07, 0.002), 0), (p.thud(70, 0.3), 0))),
    'teleport': ('דלת טלפורט', lambda p: mix(
        (warp(p, 300, 1800, 0.18, 0.7), 0), (warp(p, 1800, 500, 0.2, 0.5), 0.18), (sparkle(p, vel=0.3), 0.3))),
    'gate_open': ('מעבר בשער חכם', lambda p: mix(
        (p.seq(['E5', 'B5'], 0.07, dur=0.3), 0), (sparkle(p, count=3, vel=0.3), 0.12))),
    'lonely_unlock': ('שחרור תא בודד', lambda p: mix(
        (p.seq(['E5', 'F#5', 'G#5', 'B5'], 0.07, dur=0.2, vel=0.6), 0), (p.chord(['E5', 'B5'], 0.6, 0.7), 0.3))),
}


def main():
    for p in PALETTES:
        for name, (_, recipe) in CUES.items():
            write(os.path.join(OUT, p.key, f'{name}.wav'), p.fx(recipe(p)))
        print(p.key, p.title, 'done')


if __name__ == '__main__':
    main()
