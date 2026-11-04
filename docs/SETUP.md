# 开发与发布环境说明（SETUP）

适用仓库：`E:\tools\pixel-farm` · 线上地址：<https://play.bykc.click/play.html>
配套文档：[ROADMAP.md](ROADMAP.md) · [WORKLOG.md](WORKLOG.md) · [AUDIT-04.md](AUDIT-04.md)

## 1. 这是什么

纯原生 Canvas 2D 像素农场 + 幸存者玩法，**零运行时依赖**：没有 `npm install`、没有构建步骤，`demo/` 下的静态文件就是全部产物。部署 = 打包 `demo/` 上传到静态站点。

## 2. 环境要求

| 工具 | 版本 / 位置 | 是否必需 | 用途 |
| --- | --- | --- | --- |
| Git | 任意 | 必需 | 克隆与提交 |
| Python | 3.12.10（3.8+ 即可） | 发布/素材必需 | `deploy.py`、manifest 生成器 |
| OpenSSH 客户端 | Windows 自带 `ssh` / `scp` | 发布必需 | 上传与远程维护 |
| Node.js | v24.19.0（可选） | 开发可选 | 仅用于 `node --check` 静态检查 |
| Aseprite | `E:\tools\Aseprite-1.3.18.6-x64\aseprite.exe` | 改像素素材时必需 | 运行 Lua 生成脚本 |
| 浏览器 | Chrome / Edge 等 | 运行必需 | 打开 `demo/play.html` |

> `package.json` 是上游 pixi.js 的遗留元数据，与本项目无关，**不要**据此安装依赖。确需清理时可 `git rm package.json` 单独提交，文件仍可从 Git 历史恢复。

## 3. 获取与本地运行

```powershell
git clone https://github.com/jk9988610/pixel-farm.git
cd pixel-farm
```

`play.html` / `gallery.html` 会 `fetch` 同目录的 `assets/*/manifest.json`，**不能直接双击 `file://` 打开**（浏览器会拦截本地 fetch）。起一个静态服务：

```powershell
python -m http.server 8772 --directory demo
# 浏览器打开 http://localhost:8772/index.html
```

## 4. 目录结构

```
pixel-farm/
├── demo/                     # 唯一发布内容
│   ├── index.html            # 入口（画廊 / 试玩）
│   ├── gallery.html          # 素材画廊
│   ├── play.html             # 游戏本体（内联 module 脚本）
│   └── assets/
│       ├── char/             # 角色帧 + manifest.json
│       └── sv/               # 场景素材 + manifest.json
├── tools/art/                # 美术生成脚本（不发布）
│   ├── gen_*.lua             # Aseprite Lua，输出到 demo/assets/
│   ├── gen_char_manifest.py  # 扫描 char/ 生成 manifest
│   └── gen_sv_manifest.py    # 扫描 sv/ 生成 manifest
├── deploy.py                 # 原子部署（release + 软链，失败自动回滚）
├── deploy-legacy.py          # 旧式覆盖部署（仅应急，不要默认使用）
├── deploy.cmd                # Windows 双击入口
└── docs/                     # 路线、批次计划、工作日志
```

## 5. 素材生成（改像素画时）

Lua 脚本使用**相对仓库根**的输出路径，必须在仓库根执行：

```powershell
& "E:\tools\Aseprite-1.3.18.6-x64\aseprite.exe" -b --script tools/art/gen_all.lua
& "E:\tools\Aseprite-1.3.18.6-x64\aseprite.exe" -b --script tools/art/gen_chars_4dir.lua
```

| 脚本 | 输出 |
| --- | --- |
| `gen_all.lua` / `gen_props.lua` | `demo/assets/sv/` |
| `gen_chars_4dir.lua` / `gen_more_chars.lua` | `demo/assets/char/` |
| `gen_villager.lua` / `gen_villager_16.lua` | `demo/assets/char/villager/` |

生成 PNG 后重建索引（两个脚本从**自身位置**推导仓库根，任意目录执行均可）：

```powershell
python tools/art/gen_sv_manifest.py
python tools/art/gen_char_manifest.py
```

注意：
- `gen_sv_manifest.py` 的 `CATEGORY` 必须包含新素材名，否则脚本会报「未配置分类」并退出。
- `manifest.json` 的 `generated` 时间戳每次都会变，提交前可 `git checkout -- demo/assets/*/manifest.json` 还原，避免无意义 diff。
- `demo/assets/char/README.txt` 记录了角色帧命名与目录规范，新增角色先读它。

## 6. 修改代码后的静态检查

```powershell
# 1) 提取 play.html 的内联 module 脚本并做语法检查
$html = Get-Content demo/play.html -Raw
$m = [regex]::Match($html, '<script type="module">([\s\S]*?)</script>')
Set-Content -Encoding utf8 "$env:TEMP\play-check.mjs" $m.Groups[1].Value
node --check "$env:TEMP\play-check.mjs"

# 2) Python 语法检查
python -m py_compile deploy.py deploy-legacy.py tools/art/gen_sv_manifest.py tools/art/gen_char_manifest.py
```

`py_compile` 会生成 `__pycache__/`，属本地产物，**不要提交**（`.gitignore` 目前未收录该规则）。

## 7. 部署前置：SSH

部署依赖本机 SSH 别名 `aliyun-ab`。在 `C:\Users\<用户名>\.ssh\config` 中配置（**私钥不入库**）：

```sshconfig
Host aliyun-ab
  HostName 8.133.252.224
  User root
  IdentityFile ~/.ssh/id_ed25519
```

自检（`BatchMode=yes` 与 `deploy.py` 一致，不会弹交互）：

```powershell
ssh -o BatchMode=yes -o ConnectTimeout=10 aliyun-ab "echo SSH_OK"
```

返回 `SSH_OK` 才可部署；失败先检查别名、公钥是否已加入服务器 `~/.ssh/authorized_keys`、私钥权限。

## 8. 远程目录结构

```
/var/www/
├── play.bykc.click                      # docroot，软链 -> releases/<14位时间戳>
└── play.bykc.click.releases/
    ├── 20261104111000/                  # 历史 release（目录）
    ├── 20261104114950/                  # 当前 release（目录）
    ├── prev-dir-<时间戳>/               # 首次软链化时保留的原真实目录
    └── prev-target-<时间戳>.txt         # 切换前的软链目标
```

`deploy.py` 每次部署新建一个 release 目录，成功后原子切换软链；保留最近 **3** 个版本。

## 9. 部署

### 9.1 部署前备份（必须）

```powershell
ssh aliyun-ab "cd /var/www && tar czhf /tmp/play.bykc.click-backup-$(date +%Y%m%d%H%M)-full.tgz play.bykc.click"
ssh aliyun-ab "ls -lh /tmp/play.bykc.click-backup-*.tgz | tail -n 3"
```

**`-h`（`tar czhf`）不可省略**：docroot 已是软链，`tar czf` 只会打包 147 字节的链接本体，无法恢复站点内容。

### 9.2 执行

```powershell
python deploy.py        # 或双击 deploy.cmd
```

流程：打包 `demo/` → `scp` 上传 → 远端解压到独立 release → 软链切换 → HTTP 验证 → 失败自动回滚 → 清理旧版本。
`deploy.py` **没有 dry-run**；只想验证打包可在仓库根执行：

```powershell
python -c "import os; print(sum(len(fs) for _,_,fs in os.walk('demo')))"   # 当前应为 153
```

### 9.3 部署后验证

```powershell
curl.exe -s -o NUL -w "play %{http_code}\n" https://play.bykc.click/play.html
curl.exe -s -o NUL -w "sv   %{http_code}\n" https://play.bykc.click/assets/sv/manifest.json
```

浏览器打不开时先 `Ctrl+Shift+R` 强刷，再检查软链指向：

```powershell
ssh aliyun-ab "readlink -f /var/www/play.bykc.click"
```

### 9.4 回滚

```powershell
# 方式 A：软链指回上一版（最快）
ssh aliyun-ab "ln -sfn /var/www/play.bykc.click.releases/<上一版时间戳> /var/www/play.bykc.click"

# 方式 B：从备份恢复（前一步先移除软链，解压会得到同名目录）
ssh aliyun-ab "cd /var/www && rm -f play.bykc.click && tar xzhf /tmp/play.bykc.click-backup-<时间>.tgz"
```

`deploy-legacy.py` 是清空覆盖式旧脚本，**仅在原子部署全部失败时应急**，使用前同样先备份。

## 10. 常见故障

| 现象 | 原因 / 处理 |
| --- | --- |
| `ssh ... exit 255` | 别名不存在、私钥未加载、服务器未授权公钥；先跑第 7 节自检 |
| `scp 失败` | 同上；或远端 `/tmp` 不可写 |
| 远端 `unzip: command not found` | 服务器缺 `unzip`，安装后再部署；不要改回清空覆盖式 |
| 备份只有 147 B | 忘了 `-h`，重新用 `tar czhf` |
| 页面空白 / manifest 加载失败 | 用了 `file://` 打开；改起 `http.server`（第 3 节） |
| 改了代码线上没变 | 浏览器缓存；`Ctrl+Shift+R`，并确认 release 时间戳已更新 |
| `gen_sv_manifest.py` 报「未配置分类」 | 新 PNG 没登记到 `CATEGORY` |
| `__pycache__/` 出现在 `git status` | 静态检查产物，直接删除，不要提交 |
| 控制台中文乱码（Windows） | `deploy.py` 已设置 UTF-8；PowerShell 可先 `chcp 65001` |

## 11. 发布范围

- 发布包 = `demo/` 全部文件（当前 153 个，约 93 KB）。
- `tools/art/`、`docs/`、`deploy*.py`、`.aseprite` 源文件**不会**上线。
- 不推送远端仓库（`git push`）除非明确要求。
