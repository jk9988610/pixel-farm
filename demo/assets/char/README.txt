角色帧目录规范

assets/char/
└── <角色名>/            (如 villager, knight)
    ├── idle/           (站立循环, 建议 2-4 帧)
    │   ├── frame_0.png
    │   ├── frame_1.png
    │   └── ...
    ├── walk/           (走路循环, 建议 4-6 帧)
    │   └── frame_0.png ...
    └── jump/           (跳跃, 建议 2-3 帧: 起跳/空中/落地)
        └── frame_0.png ...

规范:
- 每帧尺寸必须相同 (建议 32x32 或 32x48)
- 只画朝右, 代码自动翻转
- 帧文件名任意, 按字典序排序 (frame_0, frame_1, ... 最稳)
- 画完跑 _scripts/gen_char_manifest.py 更新 manifest.json
- 刷新 play.html 立刻能播

支持的动作名 (全部可选, 有哪个播哪个):
  idle, walk, jump, run, attack, hurt, die
