# -*- coding: utf-8 -*-
"""仓库烟雾检查: 关键文件、素材 manifest 一致性与工具脚本齐全度.

用法: python tools/check_repo.py
退出码 0 = 全部通过, 1 = 存在失败项.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEMO = ROOT / 'demo'
CHAR_DIR = DEMO / 'assets' / 'char'
SV_DIR = DEMO / 'assets' / 'sv'

ART_SCRIPTS = [
    'gen_all.lua',
    'gen_chars_4dir.lua',
    'gen_more_chars.lua',
    'gen_props.lua',
    'gen_villager.lua',
    'gen_villager_16.lua',
    'gen_sv_manifest.py',
    'gen_char_manifest.py',
]

results = []


def check(name, func):
    try:
        detail = func()
        results.append((True, name, detail or ''))
    except Exception as exc:  # noqa: BLE001 - 冒烟脚本需要汇总所有失败
        results.append((False, name, str(exc)))


def require(cond, msg):
    if not cond:
        raise AssertionError(msg)


def check_play_html():
    path = DEMO / 'play.html'
    require(path.is_file(), '缺少 demo/play.html')
    text = path.read_text(encoding='utf-8')
    for needle in ('<script type="module">', 'assets/char/manifest.json', 'pixel-farm-save-v1'):
        require(needle in text, 'play.html 缺少关键引用: ' + needle)
    return f'{path.stat().st_size} B'


def check_sv_manifest():
    path = SV_DIR / 'manifest.json'
    require(path.is_file(), '缺少 demo/assets/sv/manifest.json')
    data = json.loads(path.read_text(encoding='utf-8'))
    categories = data.get('categories') or {}
    require(isinstance(categories, dict) and categories, 'categories 为空')
    items = [item for rows in categories.values() for item in rows]
    require(isinstance(data.get('total'), int), 'total 不是整数')
    require(data['total'] == len(items), f"total={data['total']} 与分类条目 {len(items)} 不一致")
    files = {item.get('file') for item in items}
    require(len(files) == len(items), 'manifest 中存在重复 file')
    on_disk = {p.name for p in SV_DIR.glob('*.png') if not p.name.startswith('_')}
    require(data['total'] == len(on_disk), f"total={data['total']} 与磁盘 PNG {len(on_disk)} 不一致")
    missing = sorted(name for name in files if not (SV_DIR / name).is_file())
    require(not missing, 'manifest 引用的文件不存在: ' + ', '.join(missing))
    return f"{data['total']} 项 / {len(categories)} 分类"


def check_char_manifest():
    path = CHAR_DIR / 'manifest.json'
    require(path.is_file(), '缺少 demo/assets/char/manifest.json')
    data = json.loads(path.read_text(encoding='utf-8'))
    characters = data.get('characters')
    require(isinstance(characters, dict) and characters, 'characters 为空')
    frames = 0
    missing = []
    for name, directions in characters.items():
        require(isinstance(directions, dict) and directions, f'角色 {name} 无方向数据')
        for actions in directions.values():
            require(isinstance(actions, dict) and actions, f'角色 {name} 无动作数据')
            for files in actions.values():
                require(isinstance(files, list) and files, f'角色 {name} 动作帧为空')
                for filename in files:
                    frames += 1
                    if not (CHAR_DIR / name / filename).is_file():
                        missing.append(f'{name}/{filename}')
    require(not missing, f'{len(missing)} 个帧文件缺失，例如: ' + ', '.join(missing[:5]))
    return f'{len(characters)} 角色 / {frames} 帧'


def check_art_scripts():
    art = ROOT / 'tools' / 'art'
    require(art.is_dir(), '缺少 tools/art/')
    missing = [name for name in ART_SCRIPTS if not (art / name).is_file()]
    require(not missing, '缺少美术脚本: ' + ', '.join(missing))
    return f'{len(ART_SCRIPTS)} 个脚本'


def check_entry_files():
    required = ['README.md', 'demo/index.html', 'demo/gallery.html', 'deploy.py', 'deploy.cmd', 'docs/SETUP.md']
    missing = [name for name in required if not (ROOT / name).is_file()]
    require(not missing, '缺少入口/发布文件: ' + ', '.join(missing))
    return f'{len(required)} 个文件'


def main():
    check('play.html 关键引用', check_play_html)
    check('sv manifest 一致性', check_sv_manifest)
    check('char manifest 完整性', check_char_manifest)
    check('tools/art 脚本齐全', check_art_scripts)
    check('入口与发布文件', check_entry_files)

    failed = 0
    for ok, name, detail in results:
        prefix = '[OK]  ' if ok else '[FAIL]'
        line = f'{prefix} {name}'
        if detail:
            line += f' ({detail})'
        print(line)
        if not ok:
            failed += 1
    print(f'\n{len(results) - failed}/{len(results)} 项通过')
    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
