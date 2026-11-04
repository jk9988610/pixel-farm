# -*- coding: utf-8 -*-
import os, json, time

CHAR_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'char')
MANIFEST = os.path.join(CHAR_DIR, 'manifest.json')

DIRECTIONS = ['down', 'up', 'side']
ACTIONS = ['idle', 'walk', 'jump']

characters = {}
for cname in sorted(os.listdir(CHAR_DIR)):
    cpath = os.path.join(CHAR_DIR, cname)
    if not os.path.isdir(cpath): continue
    char = {}
    for d in DIRECTIONS:
        ddir = os.path.join(cpath, d)
        if not os.path.isdir(ddir): continue
        dirData = {}
        for action in ACTIONS:
            adir = os.path.join(ddir, action)
            if not os.path.isdir(adir): continue
            frames = sorted(f for f in os.listdir(adir)
                           if f.endswith('.png') and not f.startswith('_'))
            if frames:
                dirData[action] = [f'{d}/{action}/{f}' for f in frames]
        if dirData:
            char[d] = dirData
    if char:
        characters[cname] = char

manifest = {
    'generated': time.strftime('%Y-%m-%d %H:%M:%S'),
    'characters': characters,
}

with open(MANIFEST, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)

print(f'manifest: {MANIFEST}')
print(f'characters: {len(characters)}')
for cname, dirs in characters.items():
    print(f'  {cname}: {list(dirs.keys())}')
