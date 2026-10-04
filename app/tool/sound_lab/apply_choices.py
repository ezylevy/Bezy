"""Copies the chosen Sound Lab variants into assets/audio/sfx.

    python apply_choices.py choices.txt

choices.txt is the text from the Sound Lab "copy choices" button, with lines
like `ui_tap=A` (rounds 1-2: A, B, D, E) or `hint=R3-2` (round 3, take 2).
Cues marked `?` keep their current sound.
"""
import os
import shutil
import sys

HERE = os.path.dirname(__file__)
LAB = os.path.join(HERE, '..', '..', 'sound_lab')
SFX = os.path.join(HERE, '..', '..', 'assets', 'audio', 'sfx')

applied = 0
for line in open(sys.argv[1], encoding='utf-8'):
    if '=' not in line:
        continue
    cue, pick = (part.strip() for part in line.split('=', 1))
    if pick.startswith('R3-'):
        src = os.path.join(LAB, 'R3', f'{cue}_{pick[3:]}.wav')
    elif pick in ('A', 'B', 'C', 'D', 'E', 'F'):
        src = os.path.join(LAB, pick, f'{cue}.wav')
    else:
        print('keep current:', cue)
        continue
    shutil.copyfile(src, os.path.join(SFX, f'{cue}.wav'))
    applied += 1
    print(f'{cue:18} <- {pick}')
print('applied', applied, 'cues')
