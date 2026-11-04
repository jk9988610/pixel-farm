# -*- coding: utf-8 -*-
"""扫描 assets/sv 下的 PNG, 生成 gallery.html 使用的 manifest.json"""
import os, json, time, struct

SV_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'assets', 'sv')
MANIFEST = os.path.join(SV_DIR, 'manifest.json')

# 画廊目前只有「背景 / 花卉」两个分类标签, 新素材按语义归入其一
CATEGORY = {
    'cloud': '背景',
    'ground_tile': '背景',
    'hills_far': '背景',
    'hills_mid': '背景',
    'tree': '背景',
    'bush': '背景',
    'rock': '背景',
    'flower_red': '花卉',
    'flower_yellow': '花卉',
    'flower_blue': '花卉',
    'flower_pink': '花卉',
    'flowerbed': '花卉',
}


def png_size(path):
    with open(path, 'rb') as f:
        head = f.read(24)
    if head[:8] != b'\x89PNG\r\n\x1a\n' or head[12:16] != b'IHDR':
        raise ValueError(f'not a png: {path}')
    w, h = struct.unpack('>II', head[16:24])
    return w, h


def main():
    if not os.path.isdir(SV_DIR):
        raise SystemExit(f'sv dir not found: {SV_DIR}')

    categories = {'角色': [], '背景': [], '花卉': []}
    files = sorted(f for f in os.listdir(SV_DIR)
                   if f.lower().endswith('.png') and not f.startswith('_'))
    for f in files:
        name = os.path.splitext(f)[0]
        w, h = png_size(os.path.join(SV_DIR, f))
        cat = CATEGORY.get(name)
        if not cat:
            raise SystemExit(f'未配置分类: {name} (请在 CATEGORY 中补充)')
        categories[cat].append({
            'name': name,
            'file': f,
            'w': w,
            'h': h,
            'bytes': os.path.getsize(os.path.join(SV_DIR, f)),
            'category': cat,
        })

    manifest = {
        'site': '像素田园',
        'generated': time.strftime('%Y-%m-%d %H:%M:%S'),
        'total': len(files),
        'categories': categories,
    }
    with open(MANIFEST, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print(f'manifest: {MANIFEST}')
    print(f'total: {len(files)}')
    for cat, items in categories.items():
        print(f'  {cat}: {len(items)}')


if __name__ == '__main__':
    main()
