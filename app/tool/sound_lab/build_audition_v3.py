"""Builds the round-3 audition page (kept picks + three takes per cue)."""
import base64
import json
import os

from generate_round3 import C

HERE = os.path.dirname(__file__)
MP3 = os.path.join(HERE, '..', '..', 'sound_lab', 'mp3')
ORDER = ['victory_sting', 'target_reached', 'star_earned', 'stage_unlock', 'app_launch',
         'message_report', 'hint', 'solution_preview', 'solution_step', 'ui_tap', 'toggle_on',
         'map_open', 'locked_stage', 'tile_start', 'move_invalid', 'wall_blocked', 'gate_closed',
         'gate_open', 'reset', 'joker_reveal', 'joker_choose', 'teleport', 'ice_slide', 'mirror',
         'clone', 'zero', 'black_hole', 'bomb', 'lonely_locked', 'lonely_unlock']
assert sorted(ORDER) == sorted(C)


def data(path):
    with open(path, 'rb') as fh:
        return 'data:audio/mpeg;base64,' + base64.b64encode(fh.read()).decode()


audio = {}
for key in 'ABDE':
    for cue in C:
        audio[f'{key}/{cue}'] = data(os.path.join(MP3, key, f'{cue}.mp3'))
for cue in C:
    for i in (1, 2, 3):
        audio[f'R3/{cue}_{i}'] = data(os.path.join(MP3, 'R3', f'{cue}_{i}.mp3'))
cues = [{'id': c, 'he': C[c][0], 'takes': [t[0] for t in C[c][1]]} for c in ORDER]
html = open(os.path.join(HERE, 'audition_template_v3.html'), encoding='utf-8').read()
html = html.replace('/*DATA*/', 'const AUDIO=' + json.dumps(audio) + ';const CUES=' + json.dumps(cues, ensure_ascii=False) + ';')
out = os.path.join(HERE, '..', '..', 'sound_lab', 'sound_lab_v3.html')
open(out, 'w', encoding='utf-8').write(html)
print(out, round(os.path.getsize(out) / 1e6, 1), 'MB')
