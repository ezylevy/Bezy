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
for key in 'ABDEF':
    for cue in CUES:
        with open(os.path.join(LAB, 'mp3', key, f'{cue}.mp3'), 'rb') as f:
            audio[f'{key}/{cue}'] = 'data:audio/mpeg;base64,' + base64.b64encode(f.read()).decode()

palettes = [
    {'key': 'D', 'name': 'הנג', 'en': 'Handpan', 'desc': 'תוף פלדה מכוון למוטיב של BEZY, צלצול חם ועגול'},
    {'key': 'E', 'name': 'לבד ועץ', 'en': 'Felt & Wood', 'desc': 'פסנתר עם פטישי לבד וצלסטה רכה על גוף עץ'},
    {'key': 'F', 'name': 'אוויר ומים', 'en': 'Air & Water', 'desc': 'קערות שירה, טיפות מים ונשימה רכה'},
]
groups = [{'title': t, 'cues': [{'id': c, 'he': CUES[c][0]} for c in ids]} for t, ids in GROUPS]

html = open(os.path.join(HERE, 'audition_template_v2.html'), encoding='utf-8').read()
html = html.replace('/*DATA*/', 'const AUDIO=' + json.dumps(audio) + ';const PALETTES=' +
                    json.dumps(palettes, ensure_ascii=False) + ';const GROUPS=' +
                    json.dumps(groups, ensure_ascii=False) + ';')
out = os.path.join(LAB, 'sound_lab_v2.html')
open(out, 'w', encoding='utf-8').write(html)
print(out, round(os.path.getsize(out) / 1e6, 1), 'MB')
