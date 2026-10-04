"""Builds a self-contained audition page (audio embedded as data URIs)."""
import base64
import json
import os

from generate_sound_lab import CUES, PALETTES

HERE = os.path.dirname(__file__)
LAB = os.path.join(HERE, '..', '..', 'sound_lab')

GROUPS = [
    ('מותג ורגעי שיא', ['app_launch', 'victory_sting', 'stage_unlock', 'target_reached', 'star_earned']),
    ('ניווט וממשק', ['ui_tap', 'toggle_on', 'map_open', 'locked_stage', 'message_report']),
    ('משחק על הלוח', ['tile_start', 'move_invalid', 'wall_blocked', 'gate_closed', 'gate_open',
                      'reset', 'hint', 'solution_preview', 'solution_step']),
    ('תאים מיוחדים', ['joker_reveal', 'joker_choose', 'teleport', 'ice_slide', 'mirror', 'clone',
                      'zero', 'black_hole', 'bomb', 'lonely_locked', 'lonely_unlock']),
]
assert sorted(sum((g[1] for g in GROUPS), [])) == sorted(CUES), 'every cue must be grouped'

audio = {}
for p in PALETTES:
    for cue in CUES:
        with open(os.path.join(LAB, p.key, f'{cue}.wav'), 'rb') as f:
            audio[f'{p.key}/{cue}'] = 'data:audio/wav;base64,' + base64.b64encode(f.read()).decode()

palettes = [
    {'key': 'A', 'name': 'קריסטל ניאון', 'en': 'Crystal Neon', 'desc': 'פעמוני זכוכית, נצנוץ והדהוד אוורירי'},
    {'key': 'B', 'name': 'ארקייד חם', 'en': 'Warm Arcade', 'desc': 'גלי סינת׳ רכים, גלישות צליל ו-8 ביט'},
    {'key': 'C', 'name': 'קסם אורגני', 'en': 'Organic Magic', 'desc': 'מרימבה, עץ, רוח ופעמונים'},
]
groups = [{'title': t, 'cues': [{'id': c, 'he': CUES[c][0]} for c in ids]} for t, ids in GROUPS]

html = open(os.path.join(HERE, 'audition_template.html'), encoding='utf-8').read()
html = html.replace('/*DATA*/', 'const AUDIO=' + json.dumps(audio) + ';const PALETTES=' +
                    json.dumps(palettes, ensure_ascii=False) + ';const GROUPS=' +
                    json.dumps(groups, ensure_ascii=False) + ';')
out = os.path.join(LAB, 'sound_lab.html')
open(out, 'w', encoding='utf-8').write(html)
print(out, round(os.path.getsize(out) / 1e6, 1), 'MB')
