"""BEZY Sound Lab, round 3: a distinct sound concept for every cue.

Owner feedback on round 2: the sounds were too similar to each other and
still grating. Round 3 gives each cue its own instrument and idea
(xylophone run for success, quiet blip for messages, magic harp for hints,
military drum and bugle for the solution, ...), with three takes per cue.
Everything is synthesized here from scratch (original, licence-free).
"""
import os
import wave

import numpy as np

from generate_sound_lab import SR, fft_filter, mix, noise, reverb, t_axis

OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'sound_lab', 'R3')
N = {'G3': 196.0, 'C4': 261.63, 'D4': 293.66, 'E4': 329.63, 'F4': 349.23, 'G4': 392.0,
     'A4': 440.0, 'B4': 493.88, 'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'F#5': 739.99,
     'G5': 783.99, 'A5': 880.0, 'B5': 987.77, 'C6': 1046.5, 'D6': 1174.7, 'E6': 1318.5,
     'G6': 1568.0, 'A3': 220.0, 'E3': 164.81, 'C3': 130.81, 'B3': 246.94, 'F#4': 369.99}


def env(n, a, d):
    t = np.arange(n) / SR
    return (0.5 - 0.5 * np.cos(np.pi * np.clip(t / a, 0, 1))) * np.exp(-t / d)


def f(n):
    return N[n] if isinstance(n, str) else n


def xylophone(n, dur=0.5, vel=1.0):
    fr = f(n); t = t_axis(dur); m = len(t)
    x = np.sin(2 * np.pi * fr * t) * env(m, 0.002, 0.16)
    x += 0.5 * np.sin(2 * np.pi * fr * 3.93 * t) * env(m, 0.002, 0.05)
    x += 0.15 * np.sin(2 * np.pi * fr * 9.3 * t) * env(m, 0.001, 0.012)
    return vel * x


def glock(n, dur=1.0, vel=1.0):
    fr = f(n); t = t_axis(dur); m = len(t)
    x = np.sin(2 * np.pi * fr * t) * env(m, 0.002, 0.45)
    x += 0.3 * np.sin(2 * np.pi * fr * 2.76 * t) * env(m, 0.002, 0.15)
    x += 0.12 * np.sin(2 * np.pi * fr * 5.4 * t) * env(m, 0.002, 0.05)
    return vel * x


def musicbox(n, dur=0.9, vel=1.0):
    fr = f(n); t = t_axis(dur); m = len(t)
    x = np.sin(2 * np.pi * fr * t) + 0.2 * np.sin(2 * np.pi * fr * 2.0 * t + 1) \
        + 0.12 * np.sin(2 * np.pi * fr * 4.2 * t) * np.exp(-t / 0.08)
    return vel * x * env(m, 0.003, 0.35)


def marimba(n, dur=0.7, vel=1.0):
    fr = f(n); t = t_axis(dur); m = len(t)
    x = np.sin(2 * np.pi * fr * t) * env(m, 0.004, 0.3)
    x += 0.25 * np.sin(2 * np.pi * fr * 4 * t) * env(m, 0.003, 0.05)
    return vel * x


def pluck(n, dur=1.0, vel=1.0, bright=0.5, decay=0.996):
    """Karplus-Strong string (harp-like), vectorized one period at a time."""
    fr = f(n); period = max(2, int(round(SR / fr))); total = int(SR * dur)
    seed = np.random.default_rng(int(fr)).uniform(-1, 1, period * 4)
    out = np.zeros(total + 2 * period)
    out[:period] = fft_filter(seed, high=2000 + 6000 * bright)[:period]
    i = period
    while i < total:
        prev = out[i - period:i]
        shifted = np.concatenate(([out[i - period - 1] if i > period else prev[0]], prev[:-1]))
        out[i:i + period] = decay * 0.5 * (prev + shifted)
        i += period
    return vel * out[:total] * env(total, 0.002, dur * 0.5)


def kalimba(n, dur=0.8, vel=1.0):
    fr = f(n); t = t_axis(dur); m = len(t)
    x = np.sin(2 * np.pi * fr * t) * env(m, 0.003, 0.3)
    x += 0.3 * np.sin(2 * np.pi * fr * 5.9 * t) * env(m, 0.002, 0.03)
    return vel * x


def brass(n, dur=0.35, vel=1.0, attack=0.03):
    """Bugle-like: additive saw harmonics, slow attack, light vibrato."""
    fr = f(n); t = t_axis(dur)
    vib = 1 + 0.004 * np.sin(2 * np.pi * 5.5 * t) * np.clip(t / 0.15, 0, 1)
    ph = 2 * np.pi * fr * np.cumsum(vib) / SR
    x = sum(np.sin(k * ph) / k for k in range(1, 9))
    shape = np.clip(t / attack, 0, 1) * np.clip((dur - t) / 0.06, 0, 1)
    return vel * fft_filter(x, high=2600) * shape


def snare(vel=1.0, dur=0.18):
    t = t_axis(dur); m = len(t)
    body = np.sin(2 * np.pi * 185 * t) * env(m, 0.001, 0.03)
    wires = fft_filter(noise(dur), low=1500, high=7000) * env(m, 0.001, 0.06)
    return vel * (0.6 * body + 0.7 * wires)


def snare_roll(dur=0.7, rate=26, vel=0.6):
    parts, t = [], 0.0
    while t < dur:
        parts.append((snare(vel * (0.4 + 0.6 * t / dur), 0.1), t)); t += 1 / rate
    return mix(*parts)


def timpani(n='C3', dur=1.0, vel=1.0):
    fr = f(n); t = t_axis(dur); m = len(t)
    ph = 2 * np.pi * np.cumsum(fr * (1 + 0.08 * np.exp(-t / 0.04))) / SR
    x = np.sin(ph) * env(m, 0.004, 0.35) + 0.3 * np.sin(1.5 * ph) * env(m, 0.004, 0.15)
    x += 0.3 * fft_filter(noise(dur), high=500) * env(m, 0.002, 0.03)
    return vel * x


def woodblock(fr=820, vel=1.0):
    t = t_axis(0.12); m = len(t)
    return vel * (np.sin(2 * np.pi * fr * t) * env(m, 0.001, 0.02)
                  + 0.35 * np.sin(2 * np.pi * fr * 2.7 * t) * env(m, 0.001, 0.008))


def knock(vel=1.0):
    t = t_axis(0.15); m = len(t)
    return vel * (np.sin(2 * np.pi * 140 * t) * env(m, 0.002, 0.04)
                  + 0.5 * fft_filter(noise(0.15), high=900) * env(m, 0.001, 0.02))


def triangle_inst(vel=1.0, dur=1.2):
    t = t_axis(dur); m = len(t)
    x = sum(a * np.sin(2 * np.pi * fr * t) for fr, a in [(2100, 1), (5200, 0.4), (7900, 0.2)])
    return vel * fft_filter(x * env(m, 0.002, 0.4), high=7000)


def bubble(f0=500, f1=1100, dur=0.09, vel=1.0):
    t = t_axis(dur); m = len(t)
    fr = f0 * (f1 / f0) ** (t / dur)
    return vel * np.sin(2 * np.pi * np.cumsum(fr) / SR) * env(m, 0.003, dur * 0.4)


def whoosh(dur=0.5, f0=300, f1=2000, vel=1.0):
    nz = noise(dur); m = len(nz); k = np.linspace(0, 1, m)
    out = np.zeros(m); bands = 10
    for b in range(bands):
        s = slice(b * m // bands, (b + 1) * m // bands)
        fc = f0 * (f1 / f0) ** (b / (bands - 1))
        out[s] = fft_filter(nz, low=fc * 0.7, high=fc * 1.4)[s]
    return vel * out * np.sin(np.pi * k) ** 1.5


def flutter(dur=0.35, rate=22, vel=1.0, low=800, high=5000):
    """Page flip / card shuffle: noise gated by fast ticks."""
    nz = fft_filter(noise(dur), low=low, high=high); t = t_axis(dur)
    am = (0.5 + 0.5 * np.sign(np.sin(2 * np.pi * rate * t))) * np.exp(-((t - dur / 2) ** 2) / (dur / 3) ** 2)
    return vel * nz * am


def glide(n0, n1, dur, inst='sine', vel=1.0):
    f0, f1 = f(n0), f(n1); t = t_axis(dur); m = len(t)
    ph = 2 * np.pi * np.cumsum(f0 * (f1 / f0) ** (t / dur)) / SR
    x = np.sin(ph) + (0.3 * np.sin(2 * ph) if inst == 'warm' else 0)
    return vel * x * env(m, 0.01, dur * 0.6)


def seq(inst, notes, step, **kw):
    return mix(*[(inst(n, **kw), i * step) for i, n in enumerate(notes)])


def chord(inst, notes, **kw):
    return mix(*[(inst(n, **kw), 0) for n in notes])


def room(x, amt=0.25, length=0.8):
    return reverb(x, amt, length)


C = {}
# Each cue: (Hebrew name, [(take description, builder, peak level), x3]).
C['victory_sting'] = ('ניצחון בשלב', [
    ('קסילופון: 5 תווים עולים', lambda: room(seq(xylophone, ['C5', 'D5', 'E5', 'G5', 'C6'], 0.11, dur=0.9)), 0.85),
    ('קסילופון: 4 עולים וסיום כפול', lambda: room(mix(
        (seq(xylophone, ['G4', 'C5', 'E5', 'G5'], 0.1, dur=0.8), 0), (chord(xylophone, ['C6', 'E5'], dur=1.0), 0.42))), 0.85),
    ('קסילופון: ריצה של 5 ותוף חגיגי', lambda: room(mix(
        (seq(xylophone, ['E5', 'G5', 'A5', 'C6', 'E6'], 0.08, dur=0.8), 0), (timpani('C3', 0.9, 0.5), 0.36))), 0.85),
])
C['target_reached'] = ('הגעה ליעד', [
    ('גלוקנשפיל: שלושה פעמונים', lambda: room(seq(glock, ['E5', 'G5', 'C6'], 0.09, dur=1.0)), 0.75),
    ('פעמון בודד וחם', lambda: room(glock('G5', 1.4), 0.4), 0.7),
    ('מרימבה: אקורד מתגלגל', lambda: room(seq(marimba, ['C5', 'E5', 'G5'], 0.04, dur=0.9)), 0.75),
])
C['message_report'] = ('חלון הודעה', [
    ('בועה שקטה', lambda: bubble(420, 760, 0.12), 0.4),
    ('שני תווי מרימבה רכים', lambda: room(seq(marimba, ['G4', 'C5'], 0.09, dur=0.5, vel=0.8), 0.15), 0.45),
    ('פעמון קטן ושקט', lambda: room(musicbox('E5', 0.7, 0.7), 0.2), 0.4),
])
C['hint'] = ('רמז', [
    ('נבל קסום: גליסנדו עולה', lambda: room(seq(pluck, ['C5', 'D5', 'E5', 'G5', 'A5', 'C6', 'D6', 'E6'], 0.035, dur=1.0, bright=0.7), 0.4), 0.7),
    ('עץ פעמונים קסום', lambda: room(seq(glock, ['E6', 'D6', 'G6', 'C6', 'A5', 'E6'], 0.05, dur=0.9, vel=0.5), 0.45), 0.6),
    ('צלסטה מנצנצת', lambda: room(seq(musicbox, ['G5', 'B5', 'D6', 'G6'], 0.07, dur=0.9), 0.4), 0.65),
])
C['solution_preview'] = ('פתרון יזום', [
    ('צבאי: תופי מצעד וחצוצרה', lambda: room(mix((snare_roll(0.55, vel=0.5), 0),
        (seq(brass, ['G4', 'C5', 'E5'], 0.16, dur=0.18), 0.55), (brass('G5', 0.5), 1.03)), 0.15), 0.8),
    ('צבאי: קריאת חצוצרה "הקשב"', lambda: room(mix((brass('C5', 0.14), 0), (brass('C5', 0.14), 0.17),
        (brass('E5', 0.14), 0.34), (brass('G5', 0.55), 0.51)), 0.15), 0.8),
    ('צבאי: תיפוף מצעד ושני תופים גדולים', lambda: room(mix((snare(0.6), 0), (snare(0.4), 0.12), (snare(0.6), 0.24),
        (snare_roll(0.4, vel=0.45), 0.36), (timpani('C3', 0.8, 0.8), 0.8), (timpani('G3', 0.8, 0.8), 1.05)), 0.15), 0.8),
])
C['solution_step'] = ('צעד בהצגת הפתרון', [
    ('טפיחת תוף סנר', lambda: snare(0.7, 0.12), 0.45),
    ('מקל על שפת התוף', lambda: woodblock(1100, 0.8), 0.4),
    ('תוף טום רך', lambda: timpani('G3', 0.3, 0.7), 0.45),
])
C['app_launch'] = ('פתיחת האפליקציה', [
    ('תיבת נגינה: מוטיב BEZY', lambda: room(seq(musicbox, ['B4', 'E5', 'F#5', 'B5'], 0.16, dur=1.2), 0.35), 0.75),
    ('קלימבה: מוטיב BEZY', lambda: room(seq(kalimba, ['B4', 'E5', 'F#5', 'B5'], 0.14, dur=1.0), 0.3), 0.75),
    ('נבל: מוטיב BEZY ואקורד', lambda: room(mix((seq(pluck, ['B3', 'E4', 'F#4', 'B4'], 0.13, dur=1.3), 0),
        (chord(pluck, ['E5', 'B5'], dur=1.4, vel=0.6), 0.55)), 0.35), 0.75),
])
C['ui_tap'] = ('לחיצה בתפריט', [
    ('נקישת חרוז עץ', lambda: woodblock(950, 0.7), 0.4),
    ('בועה קטנה', lambda: bubble(600, 900, 0.06), 0.35),
    ('טיפת מרימבה', lambda: marimba('E5', 0.2, 0.8), 0.4),
])
C['toggle_on'] = ('הפעלת צליל/רטט', [
    ('מתג: טיק-טק', lambda: mix((woodblock(900, 0.6), 0), (woodblock(1200, 0.7), 0.07)), 0.45),
    ('פעמון קטן', lambda: glock('B5', 0.5, 0.7), 0.45),
    ('שני תווי קלימבה עולים', lambda: seq(kalimba, ['E5', 'B5'], 0.07, dur=0.4), 0.45),
])
C['map_open'] = ('כניסה למפה', [
    ('פריסת מפה מנייר', lambda: mix((flutter(0.4, 18, 0.6, 600, 4000), 0), (whoosh(0.5, 300, 1500, 0.5), 0.05)), 0.55),
    ('משב רוח רך', lambda: whoosh(0.7, 250, 1400), 0.5),
    ('דף מתהפך ונבל קצר', lambda: mix((flutter(0.25, 25, 0.6), 0), (seq(pluck, ['E4', 'B4'], 0.08, dur=0.8), 0.18)), 0.55),
])
C['locked_stage'] = ('שלב נעול', [
    ('דפיקה כפולה על דלת עץ', lambda: mix((knock(1), 0), (knock(0.85), 0.16)), 0.55),
    ('מנעול קטן מקשקש', lambda: mix(*[(woodblock(1800 + 200 * (i % 2), 0.5), i * 0.05) for i in range(4)]), 0.45),
    ('שני תווים נמוכים "אה-אה"', lambda: room(seq(marimba, ['E4', 'C4'], 0.15, dur=0.4), 0.15), 0.5),
])
C['tile_start'] = ('בחירת שער כניסה', [
    ('פריטת נבל', lambda: room(pluck('E5', 0.9, bright=0.6), 0.2), 0.6),
    ('טיפת מים מתנגנת', lambda: mix((bubble(500, 1000, 0.1), 0), (kalimba('B5', 0.5, 0.5), 0.05)), 0.55),
    ('פעמון שער', lambda: room(glock('E5', 0.9, 0.9), 0.25), 0.55),
])
C['move_invalid'] = ('צעד לא חוקי', [
    ('קפיץ גומי נמוך "בוינג"', lambda: glide('C4', 'G3', 0.25, 'warm'), 0.45),
    ('פריטת בס עמומה', lambda: fft_filter(pluck('E3', 0.4, bright=0.1), high=900), 0.5),
    ('גוש עץ נמוך', lambda: woodblock(420, 0.9), 0.45),
])
C['wall_blocked'] = ('התנגשות בחומה', [
    ('חבטה עמומה בכרית', lambda: fft_filter(timpani('A3', 0.25, 0.9), high=600), 0.55),
    ('נקישה על אבן', lambda: mix((knock(0.9), 0), (woodblock(300, 0.4), 0)), 0.5),
    ('תוף עמום', lambda: timpani('E3', 0.35, 0.8), 0.5),
])
C['gate_closed'] = ('שער נעול', [
    ('מנעול נוקש פעמיים', lambda: mix((woodblock(1500, 0.6), 0), (woodblock(1300, 0.6), 0.09)), 0.45),
    ('פיציקטו נמוך כפול', lambda: fft_filter(seq(pluck, ['D4', 'D4'], 0.12, dur=0.35, bright=0.2), high=1500), 0.5),
    ('שרשרת קטנה', lambda: flutter(0.25, 30, 0.8, 2000, 6000), 0.35),
])
C['gate_open'] = ('מעבר בשער חכם', [
    ('פעמון דלת "דינג-דונג"', lambda: room(seq(glock, ['E5', 'C5'], 0.22, dur=1.0)), 0.6),
    ('נבל עולה קצר', lambda: room(seq(pluck, ['C5', 'E5', 'G5'], 0.05, dur=0.9)), 0.6),
    ('קלימבה נפתחת', lambda: room(seq(kalimba, ['G4', 'D5', 'G5'], 0.06, dur=0.7)), 0.6),
])
C['reset'] = ('איפוס לוח', [
    ('הרצה אחורה של קלטת', lambda: mix(*[(glide(n, f(n) * 0.35, 0.4, 'warm', 0.6), 0) for n in ['C5', 'E5', 'G5']]), 0.55),
    ('טאטוא מטאטא', lambda: mix((flutter(0.3, 12, 0.8, 500, 3000), 0), (flutter(0.3, 12, 0.6, 500, 3000), 0.28)), 0.5),
    ('ערבוב קלפים', lambda: flutter(0.45, 32, 1.0, 1200, 6000), 0.45),
])
C['star_earned'] = ('כוכב', [
    ('משולש מתכת', lambda: triangle_inst(0.8, 1.0), 0.4),
    ('פעמון גלוקנשפיל גבוה', lambda: glock('C6', 0.9, 0.9), 0.5),
    ('תיבת נגינה: תו בודד', lambda: musicbox('G5', 0.8), 0.5),
])
C['stage_unlock'] = ('פתיחת שלב חדש', [
    ('מפתח במנעול ונבל עולה', lambda: room(mix((woodblock(1600, 0.6), 0), (woodblock(1200, 0.7), 0.08),
        (seq(pluck, ['C5', 'E5', 'G5', 'C6', 'E6'], 0.05, dur=1.1), 0.2)), 0.35), 0.7),
    ('פנפרה קצרה של חצוצרה', lambda: room(mix((brass('C5', 0.12), 0), (brass('E5', 0.12), 0.13),
        (brass('G5', 0.45), 0.26)), 0.2), 0.7),
    ('גלוקנשפיל: ארבעה פעמונים עולים', lambda: room(seq(glock, ['B4', 'E5', 'F#5', 'B5'], 0.09, dur=1.1), 0.3), 0.7),
])
C['joker_reveal'] = ('ג׳וקר: הצגת אפשרויות', [
    ('קלפים נפרשים', lambda: flutter(0.4, 26, 0.9, 1000, 5000), 0.5),
    ('קוסם: "טה-דה" בנבל ופעמון', lambda: room(mix((seq(pluck, ['G4', 'C5', 'E5'], 0.04, dur=0.8), 0), (glock('C6', 0.9, 0.6), 0.14))), 0.6),
    ('מרימבה שובבה', lambda: room(seq(marimba, ['E5', 'G5', 'E5', 'C6'], 0.07, dur=0.5), 0.15), 0.55),
])
C['joker_choose'] = ('ג׳וקר: בחירה', [
    ('קלף נחבט על השולחן', lambda: mix((fft_filter(noise(0.05), low=800, high=4000) * env(int(SR * 0.05), 0.001, 0.01), 0), (knock(0.5), 0)), 0.5),
    ('קלימבה: תו בטוח', lambda: kalimba('G5', 0.6), 0.5),
    ('שני פעמונים יחד', lambda: chord(glock, ['E5', 'B5'], dur=0.8, vel=0.7), 0.5),
])
C['teleport'] = ('דלת טלפורט', [
    ('שאיבה ונחיתה "ווּפ"', lambda: room(mix((glide('C4', 'C6', 0.18, 'warm'), 0), (glide('C6', 'G4', 0.22, 'warm', 0.7), 0.18))), 0.55),
    ('מצילה הפוכה ופעמון', lambda: room(mix((whoosh(0.45, 2000, 6000)[::-1] * 0.6, 0), (glock('E6', 0.7, 0.6), 0.43))), 0.5),
    ('פורטל קסום: נבל יורד', lambda: room(seq(pluck, ['C6', 'A5', 'G5', 'E5', 'D5', 'C5'], 0.03, dur=0.8), 0.35), 0.55),
])
C['ice_slide'] = ('החלקה על קרח', [
    ('החלקת מחליק על קרח', lambda: whoosh(0.5, 2500, 5000, 0.8), 0.4),
    ('כוס זכוכית מחליקה', lambda: glide('E6', 'G6', 0.45), 0.35),
    ('פעמוני רוח יורדים', lambda: room(seq(glock, ['G6', 'E6', 'D6', 'C6'], 0.05, dur=0.6, vel=0.5), 0.3), 0.4),
])
C['mirror'] = ('מראה', [
    ('פעמון הפוך ואז אמיתי', lambda: mix((glock('E5', 0.6)[::-1] * 0.7, 0), (glock('E5', 0.8), 0.6)), 0.55),
    ('פינג-פונג בין שני פעמונים', lambda: seq(glock, ['E5', 'B5', 'E5', 'B5'], 0.09, dur=0.6, vel=0.6), 0.5),
    ('גל מים', lambda: room(glide('C5', 'E5', 0.4, 'warm', 0.8) * (1 + 0.5 * np.sin(2 * np.pi * 12 * t_axis(0.4))), 0.3), 0.5),
])
C['clone'] = ('שכפול', [
    ('הד: פופ פופ פופ', lambda: mix((bubble(500, 900, 0.08), 0), (bubble(500, 900, 0.08, 0.6), 0.12), (bubble(500, 900, 0.08, 0.35), 0.24)), 0.5),
    ('מרימבה מוכפלת', lambda: mix((marimba('G5', 0.4), 0), (marimba('G5', 0.4, 0.55), 0.1)), 0.5),
    ('קלימבה עם הד', lambda: room(mix((kalimba('D5', 0.5), 0), (kalimba('D5', 0.5, 0.5), 0.14), (kalimba('D5', 0.5, 0.25), 0.28)), 0.2), 0.5),
])
C['zero'] = ('תא אפס', [
    ('בועת סבון מתפוצצת', lambda: mix((bubble(900, 1500, 0.05), 0), (fft_filter(noise(0.06), low=1500) * env(int(SR * 0.06), 0.001, 0.008) * 0.4, 0.05)), 0.45),
    ('בלון שמתרוקן', lambda: glide('G4', 'C3', 0.5, 'warm'), 0.45),
    ('"פוף" של אבק', lambda: fft_filter(noise(0.35), high=1200) * env(int(SR * 0.35), 0.02, 0.08), 0.45),
])
C['black_hole'] = ('חור שחור', [
    ('ניקוז מים עמוק', lambda: mix((glide('C4', 'C3', 0.6, 'warm', 0.7), 0), (whoosh(0.6, 1500, 200, 0.4), 0)), 0.55),
    ('שאיבת שואב רכה', lambda: whoosh(0.6, 3000, 300)[::-1], 0.5),
    ('גונג נמוך הפוך', lambda: room(timpani('C3', 0.8))[::-1][-int(SR * 0.8):], 0.55),
])
C['bomb'] = ('פצצה', [
    ('פקק שקופץ', lambda: mix((bubble(300, 900, 0.04), 0), (fft_filter(noise(0.1), low=600, high=3000) * env(int(SR * 0.1), 0.001, 0.02) * 0.6, 0)), 0.55),
    ('מכת טימפני', lambda: room(timpani('C3', 0.9)), 0.6),
    ('בום רחוק ועמום', lambda: room(fft_filter(timpani('A3', 0.7) + 0.6 * noise(0.7) * env(int(SR * 0.7), 0.005, 0.12), high=500), 0.4), 0.6),
])
C['lonely_locked'] = ('תא בודד נעול', [
    ('תו חליל בודד ונמוך', lambda: glide('E4', 'E4', 0.5, 'warm', 0.7), 0.4),
    ('פעמון עמום', lambda: fft_filter(glock('C5', 0.6), high=1500), 0.45),
    ('נקישה ותו קלימבה נמוך', lambda: mix((woodblock(700, 0.5), 0), (kalimba('C4', 0.6, 0.8), 0.04)), 0.45),
])
C['lonely_unlock'] = ('שחרור תא בודד', [
    ('תיבת נגינה: 4 צעדים ופתרון', lambda: room(mix((seq(musicbox, ['C5', 'D5', 'E5', 'F4'], 0.11, dur=0.6), 0), (chord(musicbox, ['E5', 'G5', 'C6'], dur=1.1), 0.46)), 0.3), 0.65),
    ('נבל: עלייה ואקורד חם', lambda: room(mix((seq(pluck, ['G4', 'A4', 'B4', 'D5'], 0.08, dur=0.7), 0), (chord(pluck, ['G4', 'D5', 'G5'], dur=1.2), 0.35)), 0.3), 0.65),
    ('מרימבה: ארבעה ומנוחה', lambda: room(mix((seq(marimba, ['E5', 'D5', 'C5', 'D5'], 0.09, dur=0.5), 0), (marimba('E5', 0.9), 0.38)), 0.25), 0.65),
])


def write_wav(path, x, peak):
    x = np.asarray(x, float)
    loud = np.nonzero(np.abs(x) > np.max(np.abs(x)) * 0.003)[0]
    x = x[:loud[-1] + int(0.03 * SR)]
    fade = min(len(x), int(0.015 * SR))
    x[-fade:] *= np.linspace(1, 0, fade)
    x = fft_filter(x - x.mean(), high=8000)
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype('<i2').tobytes())


def main():
    for cue, (_, takes) in C.items():
        for i, (_, build, peak) in enumerate(takes, 1):
            write_wav(os.path.join(OUT, f'{cue}_{i}.wav'), build(), peak)
    print('round 3 written:', len(C), 'cues')


if __name__ == '__main__':
    main()
