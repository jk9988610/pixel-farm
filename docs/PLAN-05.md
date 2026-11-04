# 第 5 批次计划（PLAN-05）

上游：[ROADMAP.md](ROADMAP.md) · 上一批次：[PLAN-04.md](PLAN-04.md) · 记录：[WORKLOG.md](WORKLOG.md) · 环境：[SETUP.md](SETUP.md)

## 批次总目标

第 4 批次解决了「克隆后能不能开发/发布」，本批次补齐**入口、仓库卫生与自检**，并做一项最小玩法增量：

- B16 根 `README.md` 与忽略规则：让克隆者第一眼知道项目是什么、怎么跑、怎么发；
- B17 清理（或按规则保留）pixi.js 遗留根 `package.json`，并留下结论；
- B18 忽略与换行：`__pycache__` 等本地缓存不入库，统一换行策略；
- B19 轻量烟雾测试 `tools/check_repo.py`，用非零退出码兜底；
- B20 玩法推进：作物/种子品类扩展 + 价格浮动（单批次可消化，优先于移动端适配）。

顺序 **B16 → B17 → B18 → B19 → B20**；每项单独 commit，WORKLOG 同批追加；收尾先跑 `check_repo.py` 再部署。

---

## B16 · 根 `README.md` 与忽略规则

| 项 | 内容 |
| --- | --- |
| 目标 | 从 `.gitignore` 移除对根 `README.md` 的忽略；新增简短 `README.md`，指向 `docs/SETUP.md` / `docs/ROADMAP.md` / `docs/WORKLOG.md`，说明项目定位、本地运行、部署入口。 |
| 理由 | 克隆者在仓库根看到的第一份文件应是入口；目前只有 `docs/` 深处有说明，且 `.gitignore` 的 `README.md` 规则会让根 README 无法正常入库。 |
| 验收标准 | ① `git check-ignore -v README.md` 无输出；② `README.md` 已被跟踪；③ 内容含三条文档链接与 `python tools/check_repo.py`（B19 后补）；④ `git status` 无 `.gitignore` 之外的意外改动。 |
| 涉及文件 | `.gitignore`、`README.md`（新增）、`docs/WORKLOG.md` |
| 风险 / 可恢复性 | 仅删除 `.gitignore` 中一行 `README.md` 与新增文档，`git revert` 即可回到原状；不会影响已有被忽略规则。 |

## B17 · pixi.js 遗留 `package.json`

| 项 | 内容 |
| --- | --- |
| 目标 | 按用户规则先取证：`grep` 全仓引用 + `git ls-files package.json`；**若存在任何引用则保留并加注**，不强删。 |
| 已知情况 | `package.json` 已被跟踪（PixiJS 8.22.0 上游快照，游戏零依赖）；`docs/ROADMAP.md:6,36`、`docs/SETUP.md:21`、`docs/AUDIT-04.md` 均有说明性引用。 |
| 验收标准 | ① WORKLOG 给出 grep 证据；② 若保留，在 `README.md` 与 `SETUP.md` 明确「上游快照、勿 npm install、可从历史恢复」；③ 不产生任何功能性依赖变化。 |
| 涉及文件 | `README.md`、`docs/SETUP.md`、`docs/WORKLOG.md`（若保留则不改 `package.json`） |
| 风险 / 可恢复性 | 保留为零风险；若后续确认可删，`git rm package.json` 单独提交即可，历史随时可恢复。 |

## B18 · 忽略与换行

| 项 | 内容 |
| --- | --- |
| 目标 | `.gitignore` 增 `__pycache__/`、`.pytest_cache/`、`*.pyc`；新增 `.gitattributes`：`* text=auto`，`*.png` / `*.zip` 标 `binary`。 |
| 理由 | `py_compile` 会产生未跟踪缓存（第 4 批次手工清理过）；Git 反复提示 LF→CRLF，需要统一策略避免跨平台噪音。 |
| 验收标准 | ① `git check-ignore -v __pycache__/x.pyc` 命中；② `.gitattributes` 被跟踪且规则包含 `* text=auto`、`*.png binary`、`*.zip binary`；③ 说明「首次提交后仍可能出现 CRLF 提示，属正常」写入 SETUP。 |
| 涉及文件 | `.gitignore`、`.gitattributes`（新增）、`docs/SETUP.md`、`docs/WORKLOG.md` |
| 风险 / 可恢复性 | 仅新增忽略与属性规则；`git revert` 可撤销。`text=auto` 不会改写已提交内容，首次规范化可能产生一次换行 diff（本批次不主动重写全仓）。 |

## B19 · 烟雾测试 `tools/check_repo.py`

| 项 | 内容 |
| --- | --- |
| 目标 | 新增零依赖 Python 脚本，检查仓库关键文件与 manifest 一致性，失败非零退出。 |
| 检查项 | ① `demo/play.html` 存在且含 `<script type="module">`、`assets/char/manifest.json`、`pixel-farm-save-v1`；② `demo/assets/sv/manifest.json` 可解析，`total` 等于分类条目总和、等于磁盘 PNG 数（排除 `_` 前缀），且每个 `file` 存在；③ `demo/assets/char/manifest.json` 可解析、`characters` 非空、每个列出文件存在；④ `tools/art/` 8 个脚本齐全；⑤ `demo/gallery.html`、`deploy.py`、`deploy.cmd` 存在。 |
| 验收标准 | ① `python tools/check_repo.py` 退出码 0 并逐项打印 `[OK]`；② 人为缺失/篡改一项时退出码 1（可在临时副本验证，不改仓库）；③ 用法写入 `SETUP.md` 与 WORKLOG。 |
| 涉及文件 | `tools/check_repo.py`（新增）、`docs/SETUP.md`、`docs/WORKLOG.md` |
| 风险 / 可恢复性 | 纯只读脚本，删除即回退；不写任何文件。 |

## B20 · 作物品类扩展 + 价格浮动（玩法最小增量）

| 项 | 内容 |
| --- | --- |
| 目标 | 作物从 3 种扩到 5 种（新增「玉米」「南瓜」），商店数据表化；卖出价按天数做确定性浮动（约 ±10%），商店显示今日价与相对昨日的涨跌箭头。 |
| 理由 | 现有 3 作物在 50 秒白天内选择单一；新增快熟低收益与慢熟高收益两档，配合每日行情形成最小经济决策。改动集中在 `CROPS` 常量、商店渲染、存档库存数组，单批次可控；移动端适配涉及输入与布局，留待下一批次。 |
| 数值 | 玉米：种子 6 金 / 基础卖价 15 / 生长 14s / XP 3；南瓜：种子 45 金 / 基础卖价 120 / 生长 64s / XP 16；初始种子 `[5,3,2,2,0]`。行情系数 `1 + 0.10·sin(天数 + 索引)`，取整且不低于 1。 |
| 验收标准 | ① 商店 5 行，含买入价、种子/作物持有量、今日卖出价与 ↑/↓/= 趋势；② 卖出按今日价结算并提示单价；③ `1`–`5` 选种，HUD 显示 5 种种子与作物；④ 旧存档（长度 3 库存数组）可加载，缺失品类补 0、不丢失原 3 类数量；⑤ 天数变化后行情变化，刷新后数量保持（行情由 `dayNumber` 重算，不额外存档）；⑥ 负数金币/负库存仍被拦截。 |
| 涉及文件 | `demo/play.html`、`docs/WORKLOG.md` |
| 验证方式 | 快速模式：`node --check` 提取内联脚本 + `python tools/check_repo.py`；不启动浏览器。读取代码确认旧档迁移分支。 |
| 风险 / 可恢复性 | 存档兼容通过补零读取，旧档不会损坏；全部改动在单文件内，`git revert` 可完整回退。 |

---

## 本批次明确不做的事

- 不做移动端触屏适配（留给下一批次，B20 已选经济扩展）。
- 不删除 `package.json`（若 B17 取证发现引用则按规则保留）。
- 不重写全仓换行（只加 `.gitattributes`，避免大规模无意义 diff）。
- 不改昼夜/战斗数值、不改部署脚本、不 push。
- 不做浏览器交互验证（快速模式）。

## 提交与收尾

- 计划提交：`docs: 新增第 5 批次计划`（含 WORKLOG 批次开始）。
- 每项单独 commit：`docs: 新增根 README 并放开忽略` / `docs: 说明 pixi.js package.json 为上游快照`（若保留）/ `chore: 增加 Python 缓存忽略与换行属性` / `test: 新增仓库烟雾检查脚本` / `feat: 扩展作物品类并加入每日行情`。
- 收尾：`python tools/check_repo.py` → 远程 `tar czhf` 备份 → `python deploy.py` → 探测 `play.html` 与 `assets/sv/manifest.json` → WORKLOG 追加部署记录与回滚命令。
