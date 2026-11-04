# 像素田园 · AI 幸存者

纯原生 Canvas 2D 的像素农场 + 幸存者玩法原型：白天种田、夜晚防守，作物收获后进商店换金币。**零运行时依赖、无构建步骤**，`demo/` 下的静态文件就是全部产物。

## 快速开始

```powershell
git clone https://github.com/jk9988610/pixel-farm.git
cd pixel-farm
python -m http.server 8772 --directory demo
```

浏览器打开 <http://localhost:8772/index.html>（不要直接双击 `file://`，浏览器会拦截本地 `fetch`）。

操作：`WASD` / 方向键移动 · `空格` 播种/收获 · `1`–`3` 选种 · `B` 商店 · `Esc` 暂停。

## 文档

- [docs/SETUP.md](docs/SETUP.md)：环境要求、素材生成、静态检查、部署与回滚、常见故障
- [docs/ROADMAP.md](docs/ROADMAP.md)：长期路线与已解决问题
- [docs/WORKLOG.md](docs/WORKLOG.md)：批次进度、提交与部署记录

## 开发与发布

```powershell
python tools/check_repo.py               # 仓库烟雾检查（发布前必跑）
python tools/art/gen_sv_manifest.py      # 新增场景素材后重建索引
python tools/art/gen_char_manifest.py    # 新增角色帧后重建索引
python deploy.py                         # 原子部署（需本机 SSH 别名 aliyun-ab）
```

游戏本身没有 npm 依赖，不需要 `npm install`；根 `package.json` 是上游 pixi.js 仓库的历史快照，与本项目无关。
