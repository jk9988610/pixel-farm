# 第 4 批次计划（PLAN-04）

上游：[ROADMAP.md](ROADMAP.md) · 上一批次：[PLAN-03.md](PLAN-03.md) · 记录：[WORKLOG.md](WORKLOG.md)

## 批次总目标

让任何人 `git clone` 本仓库后，**具备完整的开发与发布能力**，不因缺少文件、目录位置或未文档化的前置条件而卡住：

- B12 仓库自洽审计：把已跟踪 / 未跟踪 / 未提交的文件全部盘一遍，逐类判断「是否复现所必需」，找出能力缺口；
- B13 补齐仓库内容：把必要文件纳入版本控制，把美术生成脚本移出发布目录并取消打包例外；
- B14 前置条件文档化：新增 `docs/SETUP.md`，写清工具链、SSH 别名、远程目录、部署与回滚、常见故障；
- B15 克隆验证：从本地仓库 `git clone` 到临时目录，在克隆目录里核对文件与静态检查，并跑打包步骤（不推送）。

顺序 **B12 → B13 → B14 → B15**：先审计出缺口，再补齐，再写文档，最后用「另一个目录的克隆」验证；收尾部署一次。

---

## B12 · 仓库自洽审计

| 项 | 内容 |
| --- | --- |
| 目标 | 产出一份可复核的清单：仓库里每个文件属于「运行必需 / 开发与美术必需 / 发布必需 / 仅历史记录 / 无关产物」，并明确哪些能力靠仓库外的本机条件。 |
| 验收标准 | ① 列出 `git ls-files` 全量分类（按目录、按用途聚合，不逐文件堆砌）；② 列出未跟踪与忽略项并判断是否需要入库；③ 至少找出 3 个「克隆后仍会卡住」的缺口并给出处理方式；④ 结论写入 `docs/AUDIT-04.md` 与 WORKLOG。 |
| 实现要点 | `git status --short --ignored`、`git check-ignore -v`、`git ls-files` 分组统计；对 `deploy.py`、`_scripts`、`.gitignore`、`README.txt`、`package.json`、`.screenshots/`、`.trae-html-share-packages/` 逐项判断。 |
| 涉及文件 | `docs/AUDIT-04.md`（新增）、`docs/WORKLOG.md` |
| 预估工作量 | 0.3 人日 |
| 风险 | 审计结论若把「用户自有改动」误判为可删除会造成返工 → 只记录、不删除用户未提交内容。 |

## B13 · 补齐仓库内容

| 项 | 内容 |
| --- | --- |
| 目标 | 克隆后目录即可开发：`docs/` 与 `.gitignore` 已在版本控制内（本项只复核，不改写用户内容）；`demo/_scripts` 迁移到 `tools/art/`，脚本内相对路径同步修正；`deploy.py` 删除 `_scripts` 打包例外；同步修正 `README.txt` 与 ROADMAP 中的路径引用。 |
| 验收标准 | ① `git check-ignore -v docs/WORKLOG.md` 无输出，`git status` 中 `.gitignore` 无未提交 diff；② `git ls-files tools/art` 为 8 条，`demo/_scripts` 为空；③ 两个 manifest 生成器在 `tools/art/` 下运行仍能定位 `demo/assets/...`；④ `deploy.py` 无 `_scripts` 过滤，打包仍为 153 个文件；⑤ `demo/assets/char/README.txt` 中的命令路径改为 `tools/art/...`。 |
| 实现要点 | `git mv demo/_scripts tools/art`；`gen_sv_manifest.py` / `gen_char_manifest.py` 的仓库根改为「脚本目录上两级」；Lua 脚本保持「以仓库根为工作目录」并写入 SETUP；删除 `deploy.py` 中 `ds[:] = [d for d in ds if d != '_scripts']`。 |
| 涉及文件 | `tools/art/*`（移动）、`deploy.py`、`demo/assets/char/README.txt`、`docs/ROADMAP.md`、`docs/WORKLOG.md` |
| 预估工作量 | 0.3 人日 |
| 风险 | 迁移后若脚本仍按旧目录推导路径，manifest 会写到错误位置 → 迁移后立即运行两个生成器验证（只校验路径，生成物留在克隆/工作区并核对，必要时还原时间戳变化）；不删除 Aseprite 生成脚本本身。 |

## B14 · 前置条件文档化

| 项 | 内容 |
| --- | --- |
| 目标 | 新增 `docs/SETUP.md`，让新环境按文档即可开发、生成素材、部署与回滚。 |
| 验收标准 | ① 写明 Node / Python 版本（本机 Node 24.19.0、Python 3.12.10）与「游戏零运行时依赖」；② 写明 Aseprite 路径 `E:\tools\Aseprite-1.3.18.6-x64\aseprite.exe` 及 Lua 脚本运行方式；③ 写明 SSH 别名 `aliyun-ab`（HostName / User / IdentityFile）与连通性自检；④ 写明远程 `releases` + 软链结构、保留 3 版；⑤ 写明部署、备份、回滚命令与常见故障（软链备份必须 `tar czhf`、BatchMode 免交互、缓存强刷等）。 |
| 实现要点 | 只写可复制执行的命令和路径，不写真实私钥内容；Windows PowerShell 语法；与本批次迁移后的 `tools/art/` 路径一致。 |
| 涉及文件 | `docs/SETUP.md`（新增）、`docs/WORKLOG.md` |
| 预估工作量 | 0.3 人日 |
| 风险 | 文档记录内网 IP / 用户名为既有信息，可接受；不得写入密钥正文。 |

## B15 · 克隆验证

| 项 | 内容 |
| --- | --- |
| 目标 | 用 `git clone E:\tools\pixel-farm <临时目录>` 得到一份「干净检出」，在克隆目录内验证可开发、可打包。 |
| 验收标准 | ① 克隆后 `git ls-files` 与源仓库一致；② `demo/play.html`、`demo/assets/sv/manifest.json`、`demo/assets/char/manifest.json` 均存在；③ 提取 `play.html` 内联 module 脚本后 `node --check` 通过；④ `python -m py_compile deploy.py deploy-legacy.py tools/art/*.py` 通过；⑤ 克隆目录内按 `deploy.py` 的打包逻辑统计为 153 个文件；⑥ 差异清单（工作区有、克隆后没有的文件）写入 WORKLOG。 |
| 实现要点 | 克隆到 `%TEMP%`；`deploy.py` 当前无 `--dry-run`，因此只复刻打包步骤（zip 写到临时目录）并说明不会 `scp` / 不推送；克隆目录内可运行 manifest 生成器验证路径。 |
| 涉及文件 | `docs/WORKLOG.md` |
| 预估工作量 | 0.2 人日 |
| 风险 | 本地克隆不受网络影响；若克隆目录缺少被忽略的工作区文件（如 `.screenshots/`），属预期，记录为「非必需」。 |

---

## 本批次明确不做的事

- 不改写 `.gitignore` 内容（用户已提交的版本保持原样），不重新引入 `docs` 忽略。
- 不删除 `demo/assets/char/README.txt`、不提交 `.screenshots/`、`.trae-html-share-packages/`、`_aseprite_test/`。
- 不删除被跟踪的 `package.json`（虽为 pixi.js 遗留，是否清理需用户决定）。
- 不新增测试框架 / CI / 运行时依赖，不做玩法改动。
- 不做浏览器交互验证（快速模式），只做静态检查、文件核对与必要的命令行验证。
- 不 push。

---

## 提交与验证策略

- 计划单独提交：`docs: 新增第 4 批次计划`（同时在 WORKLOG 记「批次开始」）。
- B12→B15 每项单独 commit，代码/文档与 WORKLOG 条目同批提交；禁止 `git add -A`，显式 `git add` 具体文件。
- 验证：`node --check`（提取内联 module 脚本）+ `py_compile`（Python 脚本）+ 克隆目录文件清单核对 + 打包文件数统计。
- 收尾部署：远程 `tar czhf` 备份 → `python deploy.py`（release + 软链，失败自动回滚）→ 探测 `play.html` 与 `assets/sv/manifest.json` 状态码 → WORKLOG 追加部署记录与回滚命令。
