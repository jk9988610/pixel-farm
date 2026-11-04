# 第 4 批次 · 仓库自洽审计（B12）

审计时间：2026-11-04 · 审计对象：`E:\tools\pixel-farm`（HEAD `a48e3f3`）
目的：判断「其他人 `git clone` 后能否独立开发与发布」，并找出能力缺口。

## 1. 已跟踪文件（172 个，按用途聚合）

| 分类 | 路径 | 数量 | 是否复现所必需 |
| --- | --- | --- | --- |
| 游戏本体 | `demo/play.html` / `gallery.html` / `index.html` | 3 | 必需（运行与试玩入口） |
| 角色素材 | `demo/assets/char/**`（5 角色 × 90 方向帧 + 45 通用帧 + `manifest.json` + `README.txt`） | 137 | 必需（`play.html` 启动时加载） |
| 场景素材 | `demo/assets/sv/**`（12 PNG + `manifest.json`） | 13 | 必需（`gallery.html` / 场景渲染） |
| 美术与索引脚本 | `demo/_scripts/**`（6 Lua + 2 Python） | 8 | 开发必需（PNG 再生成与 manifest 登记），运行时不加载 |
| 部署 | `deploy.py` / `deploy-legacy.py` / `deploy.cmd` | 3 | 发布必需（原子部署 / 应急旧式 / Windows 双击入口） |
| 文档 | `docs/ROADMAP.md`、`PLAN-01..04`、`WORKLOG.md`、本文件 | 7 | 开发必需（路线、批次记录、进度） |
| 仓库配置 | `.gitignore` | 1 | 必需（避免构建/本地产物入库） |
| 遗留元数据 | `package.json`（pixi.js 8.22.0 的清单，非本项目依赖） | 1 | 非必需（游戏零运行时依赖，仅历史遗留） |

结论：**运行与发布所需文件已全部入库**；`package.json` 不参与运行，是否清理需用户决定。

## 2. 未跟踪 / 被忽略文件

| 路径 | 状态 | 判断 |
| --- | --- | --- |
| `.screenshots/.tmp` | 空目录，未跟踪 | 本机截图工具残留，非必需，不入库 |
| `.trae-html-share-packages/demo/*.zip` | 被 `.gitignore:96 (*.zip)` 忽略 | 编辑器分享产物，非必需，不入库 |
| `_aseprite_test/` | 已不存在 | 无需处理 |
| `docs/` | 已跟踪（`git check-ignore -v docs/WORKLOG.md` 无输出） | 历史问题已由用户修复，无缺口 |
| `demo/assets/char/README.txt` | 已跟踪且工作区无 diff（`1390140`） | 无未提交改动 |

`git status --short` 为空，无未提交改动；`.gitignore` 已是用户提交的版本，本批次不改写其内容。

## 3. 能力缺口清单

| 编号 | 缺口 | 影响 | 处理 |
| --- | --- | --- | --- |
| G1 | 美术生成脚本位于发布目录 `demo/_scripts/` | 打包需额外排除规则；新脚本容易漏排、误上线 | B13 迁移到 `tools/art/`，删除 `deploy.py` 排除逻辑 |
| G2 | 部署依赖本机 SSH 别名 `aliyun-ab` 与 `~/.ssh/id_ed25519` | 新克隆者不知道改哪里、如何自检 | B14 写入 `docs/SETUP.md`（别名、密钥、连通性自检） |
| G3 | Aseprite 位于仓库外 `E:\tools\Aseprite-1.3.18.6-x64\aseprite.exe` | 无法重新生成 PNG，也不知道脚本怎么跑 | B14 写入工具链与运行命令 |
| G4 | 仓库根无 `README.md`（且被 `.gitignore` 的 `README.md` 规则忽略） | 克隆者缺少入口指引 | 新增 `docs/SETUP.md` 作为入口；是否放开根 README 需用户决定（涉及改 `.gitignore`） |
| G5 | `deploy.py` 无 `--dry-run` | 无法在无 SSH 环境下完整演练 | B15 只复刻打包步骤并说明不推送；文档写明 |
| G6 | 被跟踪的 `package.json` 是 pixi.js 元数据 | 让克隆者误以为需要 npm 安装 | 暂不删除（需用户决定），SETUP 明确「零运行时依赖」 |
| G7 | 无测试 / CI | 回归只能人工静态检查 | 本批次不处理（ROADMAP T11），克隆验证用静态检查兜底 |
| G8 | 无 `.gitattributes`，Git 提示 LF→CRLF | 跨平台换行可能产生噪音 diff | 非能力缺口；本批次不改，记录待决 |
| G9 | `deploy-legacy.py` 为清空覆盖式旧部署 | 误用可能造成线上短暂不可用 | 保留作应急，SETUP 明确标注「不要默认使用」 |

## 4. 本机前置条件（仓库外）

| 项 | 当前值 | 用途 |
| --- | --- | --- |
| Node.js | v24.19.0 | 仅用于 `node --check` 静态检查；游戏无运行时依赖 |
| Python | 3.12.10 | 部署脚本与 manifest 生成器 |
| OpenSSH 客户端 | Windows 自带 `ssh` / `scp` | 部署与远程维护 |
| SSH 别名 | `aliyun-ab` → `root@8.133.252.224`，`~/.ssh/id_ed25519` | 部署目标 |
| Aseprite | `E:\tools\Aseprite-1.3.18.6-x64\aseprite.exe` | 重新生成 PNG 素材 |
| 远程目录 | `/var/www/play.bykc.click`（软链）→ `/var/www/play.bykc.click.releases/<时间戳>` | 原子发布 |

以上内容将在 B14 固化到 `docs/SETUP.md`，使克隆者不依赖本机口头经验。
