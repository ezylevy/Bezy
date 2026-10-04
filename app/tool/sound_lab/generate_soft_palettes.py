"""BEZY Sound Lab, round 2: three soft, warm palettes (D, E, F).

Owner feedback on round 1: too sharp and too "video game". These palettes
avoid square waves, hard transients and bright highs: every attack is at
least 6 ms, everything is low-passed around 3-4 kHz, and the timbres come
from acoustic instruments rather than game consoles.

  D  Handpan      - steel handpan tuned to the BEZY motif, warm ring
  E  Felt & Wood  - felted piano / soft celesta with a wooden body
  F  Air & Water  - singing bowls, water drops, soft breath textures
"""
import os

import numpy as np

import generate_sound_lab as lab
from generate_sound_lab import (CUES, NOTE, SR, env_exp, fft_filter, mix, noise,
                                reverb, sweep_phase, t_axis, write)


def soft_env(n, attack, decay):
    t = np.arange(n) / SR
    a = 0.5 - 0.5 * np.cos(np.pi * np.clip(t / attack, 0, 1))  # rounded attack
    return a * np.exp(-t / decay)


class Soft(lab.Palette):
    cutoff = 3600
    sparkle_notes = ['B4', 'E5', 'F#5', 'B5']

    def fx(self, x):
        length = min(1.4, max(0.35, len(x) / SR * 1.5))
        return fft_filter(reverb(x, self.rev, length), high=self.cutoff)

    def warp_wave(self, f0, f1, dur, vel=1.0):
        ph, _ = sweep_phase(f0, f1, dur)
        n = len(ph)
        return vel * np.sin(ph) * np.sin(np.pi * np.linspace(0, 1, n)) ** 1.2

    def thud(self, f=110, dur=0.25):
        t = t_axis(dur)
        ph, _ = sweep_phase(f * 1.25, f, dur)
        return np.sin(ph) * soft_env(len(t), 0.008, 0.07)

    def swoosh(self, dur, f0, f1):
        return fft_filter(super().swoosh(dur, f0, f1), high=2500) * 0.6


class Handpan(Soft):
    key, title = 'D', 'Handpan'
    rev = 0.5

    def tone(self, f, dur, vel=1.0):
        t = t_axis(dur + 0.6)
        n = len(t)
        x = np.sin(2 * np.pi * f * t) * soft_env(n, 0.008, dur * 1.1)
        x += 0.45 * np.sin(2 * np.pi * f * 2.0 * t + 0.4) * soft_env(n, 0.006, dur * 0.6)
        x += 0.22 * np.sin(2 * np.pi * f * 2.99 * t) * soft_env(n, 0.006, dur * 0.35)
        # Slight beating between two close partials gives the steel shimmer.
        x += 0.18 * np.sin(2 * np.pi * f * 1.004 * t) * soft_env(n, 0.01, dur * 1.2)
        return vel * x

    def click(self):
        t = t_axis(0.16)
        f = NOTE['E5']
        return np.sin(2 * np.pi * f * t) * soft_env(len(t), 0.006, 0.04) * 0.7


class FeltWood(Soft):
    key, title = 'E', 'Felt & Wood'
    rev = 0.35
    cutoff = 3000

    def tone(self, f, dur, vel=1.0):
        t = t_axis(dur + 0.4)
        n = len(t)
        x = np.sin(2 * np.pi * f * t) * soft_env(n, 0.012, dur * 0.8)
        x += 0.25 * np.sin(2 * np.pi * f * 2 * t) * soft_env(n, 0.012, dur * 0.35)
        x += 0.08 * np.sin(2 * np.pi * f * 3 * t) * soft_env(n, 0.012, dur * 0.2)
        felt = fft_filter(noise(dur + 0.4), high=350) * soft_env(n, 0.004, 0.025) * 0.25
        return vel * (x + felt)

    def click(self):
        t = t_axis(0.12)
        body = np.sin(2 * np.pi * 620 * t) * soft_env(len(t), 0.006, 0.025)
        wood = fft_filter(noise(0.12), low=300, high=1400) * soft_env(len(t), 0.003, 0.012) * 0.35
        return body + wood


class AirWater(Soft):
    key, title = 'F', 'Air & Water'
    rev = 0.55
    cutoff = 3200

    def tone(self, f, dur, vel=1.0):
        # Singing bowl: two close partials beating slowly + soft overtone.
        t = t_axis(dur + 0.7)
        n = len(t)
        x = np.sin(2 * np.pi * f * t) + 0.8 * np.sin(2 * np.pi * f * 1.006 * t)
        x += 0.25 * np.sin(2 * np.pi * f * 2.71 * t) * np.exp(-t / (dur * 0.4))
        return vel * 0.6 * x * soft_env(n, 0.02, dur * 1.2)

    def click(self):
        # Water drop: a short rounded upward pitch blip.
        dur = 0.11
        ph, _ = sweep_phase(700, 1300, dur)
        return np.sin(ph) * soft_env(len(ph), 0.004, 0.03)

    def swoosh(self, dur, f0, f1):
        breath = fft_filter(noise(dur), low=f0 * 0.5, high=min(f1, 2200))
        k = np.linspace(0, 1, len(breath))
        return breath * np.sin(np.pi * k) ** 2 * 0.55


SOFT = [Handpan(), FeltWood(), AirWater()]


def main():
    # Route round-1 helpers to the soft versions of each palette.
    lab.warp = lambda p, f0, f1, dur, vel=1.0: p.warp_wave(f0, f1, dur, vel)
    lab.sparkle = lambda p, base='B5', count=4, step=0.045, vel=0.45: p.seq(
        p.sparkle_notes[:count], step * 1.6, dur=0.35, vel=vel * 0.8)
    for p in SOFT:
        for name, (_, recipe) in CUES.items():
            write(os.path.join(lab.OUT, p.key, f'{name}.wav'), p.fx(recipe(p)))
        print(p.key, p.title, 'done')


if __name__ == '__main__':
    main()
