# 工作日志 · 像素田园

本文件按时间顺序追加，**只追加不重写历史**。每次完成一项（或一个批次）就补一条记录。

记录格式（表格统一列）：

| 日期 | 批次/条目 | 状态 | 提交 | 验证 | 部署 | 遗留 |

字段说明：

- 状态：`已完成` / `部分完成` / `阻塞`
- 提交：短 hash；文档类提交也记录
- 验证：本地实际做过的检查（写明端口/环境/结论）
- 部署：备份文件名 + 线上探测结果；未部署写 `未部署`
- 遗留：本项未覆盖的问题，写清楚给下一批次

---

## 第 1 批次（补记）

**批次目标**：把「幸存者-like 战斗演示」推进到「可玩的像素农场最小闭环」——修资产管线、接真实输入、加 3×3 农场、加本地存档。

**计划文档**：`docs/PLAN-01.md`

| 日期 | 批次/条目 | 状态 | 提交 | 验证 | 部署 | 遗留 |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-11-04 | B1 资产管线修复 | 已完成 | `ffed105` | 脚本内无 `E:/tools/pixijs-dev` 硬编码；重生成 `demo/assets/sv/manifest.json`，`total` 8→12（新增 tree/bush/rock/flowerbed）；线上 manifest 200 / 2114B | 2026-11-04 随批次部署 | 仅重生成清单，未重跑 PNG 生成（Aseprite CLI 批处理未执行） |
| 2026-11-04 | B2 真实输入与暂停 | 已完成 | `c5c643f` | WASD/方向键移动、Esc 暂停冻结逻辑、Pointer 虚拟摇杆；`node --check` 通过；入口页文案改为「进入游戏 / WASD / 方向键 移动 · Esc 暂停」 | 2026-11-04 随批次部署 | 触屏摇杆未在真机验证（仅逻辑层检查） |
| 2026-11-04 | B3 3×3 地块 + 3 种作物 | 已完成 | `1ee1388` | 萝卜/小麦/番茄播种→生长→成熟→收获→金币+经验闭环；1/2/3 选种、空格交互、生长阶段视觉差异 | 2026-11-04 随批次部署 | 作物为程序化绘制，未接入美术资源；无浇水/土地升级 |
| 2026-11-04 | B4 localStorage 存档 v1 | 已完成 | `bc83c7f` | 注入 `coins=90` 存档→加载显示 90；空格收获后 114 并落盘；刷新恢复 114 且地块状态保留；损坏数据回退新档；隔离端口 8767 验证 | 2026-11-04 随批次部署 | 多标签页同源存档互相覆盖未处理（纳入第 2 批次 B5） |
| 2026-11-04 | 第 1 批次部署 | 已完成 | — | 旧 `deploy.cmd`：161 文件 / 102.3 KB，HTTP 200 / 48.3 KB；抽查 play.html（49459B，含 `farmhud`、`pixel-farm-save-v1`）、`assets/sv/manifest.json`（200，total=12）、`gallery.html`、`assets/char/villager/down/walk/frame_0.png` 均 200 | 备份 `/tmp/play.bykc.click-backup-202611041045.tgz`（42K）；`https://play.bykc.click/play.html` 200 | 部署脚本清空目录式覆盖、无自动回滚（纳入第 2 批次 B6） |

**第 1 批次验证结论**：本地静态服务（独立端口隔离同源存储）加载无逻辑报错，控制台仅有导航期 `net::ERR_ABORTED`；战斗、农场、存档三项功能互不干扰。线上部署后关键资源均可访问。

**第 1 批次遗留问题**（已转入第 2 批次或后续路线图）：

1. 多标签页同源存档冲突：`storage` 无同步，`visibilitychange` 回写会让旧标签覆盖新进度。
2. 触屏摇杆未真机验证：仅验证事件绑定与逻辑，未在手机浏览器实测。
3. PNG 生成未重跑：只重生成 manifest，`gen_*.lua` 已在 Aseprite 里可运行但未批量执行。
4. 部署可靠性：`deploy.py` 先 `rm -rf` 站点目录再解压，失败无回滚。
5. 仓库杂项：`demo/assets/char/README.txt` 已由用户单独提交（`1390140`）；`_aseprite_test/` 仍为未跟踪目录，未处理。

---

## 第 2 批次

计划文档：`docs/PLAN-02.md`

| 日期 | 批次/条目 | 状态 | 提交 | 验证 | 部署 | 遗留 |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-11-04 | B5 多标签页存档锁 | 已完成 | `e57ac43` | 本地 8771：第二个标签页显示「另一个标签页正在游戏」遮罩；点击「在此标签页继续」后接管并恢复游戏；两标签控制台无 `LOOP ERR` / `ERR:` / `TypeError`（仅导航期 `net::ERR_ABORTED`） | 随第 2 批次统一部署 | 接管会载入最近存档，本局进行中的敌人/弹幕被重置（已在遮罩文案说明）；隐身模式下 `storage` 事件可能不触发，此时退化为心跳锁（8s 过期） |
| 2026-11-04 | B6 部署原子切换 | 已完成 | `1bce16e` | `py_compile` 通过；切换逻辑：上传带时间戳 zip → 解压到 `play.bykc.click.releases/<时间戳>` → 真实目录改为 `prev-dir-<时间戳>` 保留 → 软链指向新 release；线上验证 `play.html` + `manifest.json`，失败自动回滚并保留最近 3 个版本 | 部署阶段验证（见下） | 首次部署会把原真实目录转成软链，需 nginx 允许跟随软链（默认可跟随）；回滚依赖 `prev-dir-*` / `prev-target-*.txt` 未被清理 |
| 2026-11-04 | B7 昼夜双循环（M1 第一步） | 已完成 | `e833d4e` | 本地 8771：HUD「阶段」白天 45s 倒计时递减 → 夜晚出现敌人 → 约 35s 后回到白天，金币 100→118（夜战 9 杀 ×2 结算）；控制台无 `LOOP ERR`；阶段字段向后兼容（旧档缺省按白天） | 随第 2 批次统一部署 | 白天不出敌人会放慢升级，夜晚难度曲线待用实机数值再调；未做结算面板 UI（仅飘字）；夜晚仅用 Canvas 压暗滤镜，无美术资源 |

**第 2 批次验证结论**：B5/B7 均在本地 8771 静态服务下完成端到端浏览器验证；B6 的切换与回滚脚本在部署阶段实机验证。

**第 2 批次遗留问题**：

1. 部署脚本仍是「软链 + 保留目录」而非双活切换，切换瞬间存在极短的路径解析窗口（毫秒级）。
2. `_scripts/` 仍被打进发布包（历史行为，本批次未处理）。
3. 触屏摇杆仍未经真机验证。

**第 2 批次部署记录（2026-11-04）**

| 项 | 结果 |
| --- | --- |
| 远程备份 | `/tmp/play.bykc.click-backup-202611041109.tgz`（48K，部署前 tar） |
| 旧方式确认 | `python deploy-legacy.py`：161 文件 / 104.8 KB，`play.html` HTTP 200 / 55.2 KB（确认原链路可用后才切换） |
| 回滚逻辑沙箱验证 | 服务器 `/tmp/pf-atomic-test` 模拟「真实目录 → prev-dir → 软链 → 回滚」，输出 `after-switch: NEW` / `after-rollback: OLD`，PASS |
| 新方式部署 | `python deploy.py`：release `20261104111000`；`/var/www/play.bykc.click` 已变为软链指向该 release；原目录保留为 `releases/prev-dir-20261104111000` |
| 新方式验证 | `play.html` 200 / 55.2 KB；`assets/sv/manifest.json` 200 / 2114B；`assets/char/manifest.json` 200；`villager/down/walk/frame_0.png` 200；`gallery.html` 200 |
| 内容抽查 | 线上 `play.html` 含 `pixel-farm-lock-v1`、`startNight`、`清晨结算`、`pixel-farm-save-v1` |
| 回滚方式 | `ssh aliyun-ab "rm -f /var/www/play.bykc.click && mv /var/www/play.bykc.click.releases/prev-dir-20261104111000 /var/www/play.bykc.click"`；或解压备份 tgz |

---

## 第 3 批次

计划文档：`docs/PLAN-03.md`

**批次开始（2026-11-04）**：范围 B8 商店经济最小闭环、B9 清晨结算面板、B10 昼夜数值节奏调整、B11 发布包排除 `_scripts/`。批次边界与「不做的事」见计划文档；本批次不触碰 `demo/assets/char/README.txt`、`_aseprite_test/`、`.gitignore`，不 push。

| 日期 | 批次/条目 | 状态 | 提交 | 验证 | 部署 | 遗留 |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-11-04 | B8 商店经济最小闭环 | 已完成 | `c03e7c2`（计划 `8c07f8f`） | `node --check` 通过；快速模式切换前做过一次浏览器实测：买萝卜种子 100→90、种子 5→6，零库存卖出提示「没有可卖的 萝卜」且金币不变，刷新后数值保持（PASS）。切换快速模式后不再复测 | 随批次部署 | 商店用 B 键随时打开（无摊位/店员），昼夜均可交易；种子价格即 `CROPS.cost`，无浮动 |
| 2026-11-04 | B9 清晨结算面板 | 已完成 | `0b3bca9` | `node --check` 通过；代码复核：`killEnemy` 仅在 `phase==='night'` 时 `nightKills++`，`startDay()` 用同一值结算 ×2。浏览器实测两次均为 0 击杀（均从「夜晚末段」存档恢复，非全夜样本），未作为通过依据。**验证按用户要求跳过（快速模式）** | 随批次部署 | 结算面板会暂停游戏，需玩家确认；击杀奖励规则固定 ×2，未做面板动画 |
| 2026-11-04 | B10 昼夜数值节奏调整 | 已完成 | `63a06e4` | `node --check` 通过；数值表见 `docs/PLAN-03.md`（白天 50s / 夜晚 40s、白天每 4s 一只弱敌、夜晚 0.9s→0.30s、Boss/夜间 HP 按天数 ×1.10）。**验证按用户要求跳过（快速模式）**；风险已提示用户：白天有敌人会改变「纯种田」体验，梯度需实机再调 | 随批次部署 | 白天弱敌与夜晚强度未做实机调参；`pickType` 仍按 `gameTime` 解锁高阶敌人 |
| 2026-11-04 | B11 发布包排除 `_scripts/` | 已完成 | `035dc4f` | `py_compile` 通过；本地统计打包文件数 161→153（排除 8 个脚本文件）。**验证按用户要求跳过（快速模式）**，线上仅做发布探测 | 随批次部署 | 仅排除 `_scripts`，其余生成物未处理 |

**第 3 批次验证说明**：按用户「快速开发」要求，自本节起不再启动浏览器/自动化交互验证，仅保留 `node --check`、`py_compile` 与部署后 HTTP 状态码探测；涉及交互的验收项在 WORKLOG 标注「验证按用户要求跳过（快速模式）」，不记为「已验证通过」。

**第 3 批次部署记录（2026-11-04）**

| 项 | 结果 |
| --- | --- |
| 远程备份 | `/tmp/play.bykc.click-backup-202611041149-full.tgz`（51K，`tar czhf` 解引用软链） |
| 备份踩坑 | 首次按旧命令 `tar czf ... play.bykc.click` 只得到 147B：docroot 已是软链，tar 只打包了链接本身。**软链化 docroot 后备份必须加 `-h`** |
| 部署方式 | `python deploy.py`（release + 软链原子切换），release `20261104114950` |
| 打包 | 153 个文件 / 93.2 KB（B11 生效，原 161） |
| 发布探测 | `https://play.bykc.click/play.html` 200 / 62.1 KB；`https://play.bykc.click/assets/sv/manifest.json` 200 / 2.1 KB（快速模式仅查这两项，未抽查图片/角色帧） |
| 上一版 | `20261104111000` |
| 回滚命令 | `ssh aliyun-ab "ln -sfn /var/www/play.bykc.click.releases/20261104111000 /var/www/play.bykc.click"`；或解压 `/tmp/play.bykc.click-backup-202611041149-full.tgz` |

**_scripts 去留调查（2026-11-04，结论：保留）**

- 盘点：`demo/_scripts/` 共 8 个文件，均为开发期资产生成脚本——6 个 Aseprite Lua（`gen_all` / `gen_chars_4dir` / `gen_more_chars` / `gen_props` / `gen_villager` / `gen_villager_16`，输出到 `demo/assets/sv|char`）+ 2 个 manifest 生成器（`gen_sv_manifest.py` / `gen_char_manifest.py`）。
- 引用情况：运行时（`play.html`、`gallery.html`）与部署脚本均不引用 `_scripts/`；B11 已将其排除出发布包（153 文件）。
- 跟踪状态：`git ls-files demo/_scripts` 返回 8 条，全部已跟踪，删除可从历史恢复。
- 结论：**不过时，不删除**。Lua 脚本是 ROADMAP「美术与内容规划」中唯一的 PNG 生成管线（不是被 manifest 生成器替代，而是互补），B1 刚修过其路径；manifest 生成器用于新增素材时登记。B11 的打包排除规则继续保留。
- 建议：后续可把 `_scripts/` 移出 `demo/`（如 `tools/art/`），发布包自然不含脚本，届时可删掉排除逻辑。

**批次开始（2026-11-04，第 4 批次）**：目标「任何人 clone 后具备完整开发与发布能力」。范围：B12 仓库自洽审计、B13 补齐仓库内容（含 `_scripts` 迁移到 `tools/art/`）、B14 前置条件文档化（`docs/SETUP.md`）、B15 克隆验证；收尾部署一次。计划见 `docs/PLAN-04.md`。快速模式继续：不做浏览器交互验证，只做静态检查与命令行验证；不 push。

**第 4 批次记录**

| 日期 | 批次/条目 | 状态 | 提交 | 验证 | 部署 | 遗留 |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-11-04 | B12 仓库自洽审计 | 已完成 | `e470a40` | 审计 `git ls-files`（172 项）、`git status --short --ignored`、`git check-ignore -v docs/WORKLOG.md`（无输出，docs 已入库）；缺口汇总见 `docs/AUDIT-04.md`。**验证按用户要求跳过浏览器交互（快速模式）** | 未部署 | 根 `README.md` 被忽略、`package.json` 为 pixi.js 遗留、无 CI/测试，均需用户决定 |
| 2026-11-04 | B13 补齐仓库内容 | 已完成 | `a19888f` | `git mv` 8 个脚本到 `tools/art/`；`py_compile` 通过；在 `%TEMP%` 下运行两个 manifest 生成器，均正确定位 `demo/assets/...`（生成物仅时间戳变化，已还原）；`deploy.py` 删除 `_scripts` 过滤后打包仍 153 个文件；`demo/assets/char/README.txt` 与 ROADMAP 路径引用已同步。Lua 脚本未实际执行（需 Aseprite，快速模式不做）。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | Lua 脚本仍要求「以仓库根为工作目录」（已写入 SETUP）；`.gitignore` 未加 `__pycache__`（用户文件不改写） |
| 2026-11-04 | B14 前置条件文档化 | 已完成 | `9eaa3fe` | 新增 `docs/SETUP.md`：环境版本（Node 24.19.0 / Python 3.12.10）、Aseprite 路径与 Lua 运行方式、`aliyun-ab` SSH 别名与自检、远程 releases+软链结构、部署/备份/回滚命令、10 类常见故障（含 `tar czhf`）。路径与迁移后的 `tools/art/` 一致。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | SSH 主机/IP 属既有信息已文档化；私钥正文未写入 |
| 2026-11-04 | B15 克隆验证 | 已完成 | `320f378` | 克隆到 `%TEMP%\pixel-farm-clone-20261104120217`：`git ls-files` 174 条与源仓库 `Compare-Object` 无差异；`demo/play.html`、`assets/sv|char/manifest.json`、`tools/art/gen_all.lua`、`deploy.py` 齐全；内联 module `node --check` 通过；`py_compile` 通过；克隆内打包 153 文件；在 `%TEMP%` 运行两个 manifest 生成器成功；`demo/_scripts` 不存在、`tools/art` 8 个文件；`deploy.py` 无 `_scripts` 引用。因无 `--dry-run`，未执行上传，也未 push。差异：源工作区 `.screenshots/`（空目录）与 `.trae-html-share-packages/*.zip`（被忽略）不在克隆中，均非必需。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | 克隆者仍需本机 SSH 别名/密钥与 Aseprite（已写入 SETUP）；无 CI/测试 |

**第 4 批次部署记录（2026-11-04）**

| 项 | 结果 |
| --- | --- |
| 远程备份 | `/tmp/play.bykc.click-backup-202611041203-full.tgz`（42K，`tar czhf` 解引用软链） |
| 部署方式 | `python deploy.py`（release + 软链原子切换），release `20261104120319` |
| 打包 | 153 个文件 / 93.2 KB。B13 把脚本移出 `demo/` 并删掉 `deploy.py` 的 `_scripts` 过滤，**发布内容与上一版一致**（脚本此前已被 B11 排除，线上无新增/缺失文件） |
| 发布探测 | `https://play.bykc.click/play.html` 200 / 63623B；`https://play.bykc.click/assets/sv/manifest.json` 200 / 2221B（快速模式仅查这两项） |
| 上一版 | `20261104114950`；当前保留 3 版（`20261104120319` / `20261104114950` / `20261104111000`） |
| 回滚命令 | `ssh aliyun-ab "ln -sfn /var/www/play.bykc.click.releases/20261104114950 /var/www/play.bykc.click"`；或从 `/tmp/play.bykc.click-backup-202611041203-full.tgz` 恢复 |
| 备份注意 | 软链 docroot 必须 `tar czhf`（`-h`），否则只打包 147B 链接本体 |

**批次开始（2026-11-04，第 5 批次）**：目标「补齐入口、仓库卫生与自检，并做一项最小玩法增量」。范围：B16 根 README 与忽略规则、B17 pixi.js `package.json` 取证处理、B18 忽略与换行、B19 `tools/check_repo.py` 烟雾测试、B20 作物品类扩展 + 价格浮动；收尾先跑 `check_repo.py` 再部署。计划见 `docs/PLAN-05.md`。快速模式继续：不做浏览器交互验证，不 push。

**第 5 批次记录**

| 日期 | 批次/条目 | 状态 | 提交 | 验证 | 部署 | 遗留 |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-11-04 | B16 根 README 与忽略规则 | 已完成 | `2e4a54c` | `.gitignore` 移除 `README.md` 一行；`git check-ignore -v README.md` 无输出（退出码 1）；新增根 `README.md`（项目简介、本地运行、操作、docs 三链接、素材/部署入口、零依赖说明）。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | README 操作键位先写 `1`–`3`，B20 扩到 5 作物时同步更新 |
| 2026-11-04 | B17 pixi.js 遗留 package.json | 已完成（按规则保留） | `c7e34c5` | 取证：`git ls-files package.json` 已跟踪；`git grep -n -i 'package\.json'` 命中 README / AUDIT-04 / PLAN-04 / PLAN-05 / ROADMAP / SETUP / WORKLOG 共 15 处，均为说明性引用，无脚本/部署依赖。按用户「发现引用则保留并加注」规则 **不删除**；`SETUP.md` 补充「可 `git rm` 且历史可恢复」，README 已注明勿 `npm install`。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | 若你确认无保留价值，可下一批次 `git rm package.json` 并同步清理文档引用 |
| 2026-11-04 | B18 忽略与换行 | 已完成 | `1b1b751` + `1b250da` | `.gitignore` 增 `__pycache__/`、`*.pyc`、`.pytest_cache/`；新增 `.gitattributes`（`* text=auto`、`*.png binary`、`*.zip binary`）。首次提交发现 `.gitattributes` 本身被旧规则忽略，追加 `1b250da` 移除忽略项后入库。`git check-ignore -v` 命中三类缓存；`git check-attr` 显示 PNG/ZIP `binary: set`、README `text: auto`。SETUP 更新 `__pycache__` 说明并补 LF→CRLF 故障行。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | 未主动重写全仓换行，历史文件首次规范化仍可能提示一次 |
| 2026-11-04 | B19 仓库烟雾检查 | 已完成 | `05ad03e` | 新增 `tools/check_repo.py`；首次运行 `python tools/check_repo.py` 退出 0，5/5 通过（play.html 63623B / sv 12 项 3 分类 / char 5 角色 90 帧 / art 8 脚本 / 入口 6 文件）；在临时副本删除 `gen_villager_16.lua` 后退出 1 并输出缺失项，失败路径有效。README 与 SETUP 已写入用法。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | 无 |
| 2026-11-04 | B20 作物品类扩展 + 价格浮动 | 已完成 | 见本行提交 | `CROPS` 由 3 种扩到 5 种（玉米：种子 6 / 基础卖价 15 / 14s / 3XP；南瓜：45 / 120 / 64s / 16XP）；初始种子 `[5,3,2,2,0]`；商店新增行情列，显示今日卖价与 ↑/↓/=；`1`–`5` 选种；旧存档 3 长度库存数组自动补 0（`5,3,2` → `5,3,2,0,0`），不丢原数量；卖出按 `sellPrice(i)`（`dayNumber` 确定性 ±10%）结算。验证：内联 module `node --check` 通过；`python tools/check_repo.py` 5/5；价格公式抽检 day1 `26,40,64,16,126` → day2 `25,36,71,16,112`；旧档补零分支通过。**验证按用户要求跳过浏览器（快速模式）** | 未部署 | 未实机调参；移动端触屏适配留待下一批次 |


