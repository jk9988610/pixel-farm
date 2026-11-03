# -*- coding: utf-8 -*-
"""像素田园 · 一键部署 (Python 版)
用法: 双击 deploy.cmd, 或 python deploy.py
"""
import os, sys, subprocess, zipfile, tempfile, urllib.request

if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

ROOT        = os.path.dirname(os.path.abspath(__file__))
DEMO_DIR    = os.path.join(ROOT, 'demo')
ZIP_PATH    = os.path.join(tempfile.gettempdir(), 'pixel-farm-dist.zip')
REMOTE_HOST = 'aliyun-ab'
REMOTE_TMP  = '/tmp/pixel-farm-dist.zip'
REMOTE_DIR  = '/var/www/play.bykc.click'
URL         = 'https://play.bykc.click/play.html'


def step(msg):
    print(f'[{msg}]', flush=True)

def ok(msg):
    print(f'      -> {msg}', flush=True)

def fail(msg):
    print(f'[ERR] {msg}', flush=True)

def run_native(argv, timeout=60):
    """跑原生命令, 返回 (code, stdout, stderr)"""
    try:
        r = subprocess.run(argv, capture_output=True, timeout=timeout)
        return (r.returncode,
                (r.stdout or b'').decode('utf-8', errors='replace'),
                (r.stderr or b'').decode('utf-8', errors='replace'))
    except subprocess.TimeoutExpired:
        return (-1, '', f'timeout {timeout}s')
    except Exception as e:
        return (-1, '', str(e))


def main():
    print()
    print('=' * 42)
    print('  像素田园 · 一键部署')
    print('=' * 42)
    print()

    # 前置
    if not os.path.isdir(DEMO_DIR):
        fail(f'demo 目录不存在: {DEMO_DIR}')
        return 1

    # [1/4] 打包
    step('1/4 打包 demo/ ...')
    if os.path.exists(ZIP_PATH):
        os.remove(ZIP_PATH)
    try:
        n = 0
        with zipfile.ZipFile(ZIP_PATH, 'w', zipfile.ZIP_DEFLATED) as z:
            for rt, ds, fs in os.walk(DEMO_DIR):
                for f in fs:
                    full = os.path.join(rt, f)
                    rel = os.path.relpath(full, DEMO_DIR).replace(os.sep, '/')
                    z.write(full, rel)
                    n += 1
        sz = os.path.getsize(ZIP_PATH) / 1024
        ok(f'{ZIP_PATH}  ({n} 文件, {sz:.1f} KB)')
    except Exception as e:
        fail(f'打包失败: {e}')
        return 1

    # [2/4] 上传
    step(f'2/4 上传到 {REMOTE_HOST} ...')
    code, out, err = run_native(
        ['scp', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10',
         ZIP_PATH, f'{REMOTE_HOST}:{REMOTE_TMP}'],
        timeout=60
    )
    if code != 0:
        fail(f'scp 失败 (exit {code})')
        print('     ', err.strip()[:300])
        return 1
    ok(f'{REMOTE_HOST}:{REMOTE_TMP}')

    # [3/4] 服务器解压
    step('3/4 服务器解压 ...')
    cmd = (
        f'rm -rf {REMOTE_DIR}/* && cd {REMOTE_DIR} && '
        f'unzip -q -o {REMOTE_TMP} && '
        f'chown -R www-data:www-data {REMOTE_DIR} && '
        f'find . -type f | wc -l'
    )
    code, out, err = run_native(
        ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10',
         REMOTE_HOST, cmd],
        timeout=60
    )
    if code != 0:
        fail(f'ssh 失败 (exit {code})')
        print('     ', err.strip()[:300])
        return 1
    # 拿最后一行数字
    nums = [l.strip() for l in out.splitlines() if l.strip().isdigit()]
    count = nums[-1] if nums else '?'
    ok(f'{count} 个文件 -> {REMOTE_DIR}')

    # [4/4] 验证
    step('4/4 验证线上 ...')
    try:
        req = urllib.request.Request(URL, headers={'Cache-Control': 'no-cache'})
        with urllib.request.urlopen(req, timeout=10) as r:
            sz = len(r.read())
            ok(f'HTTP {r.status}, {sz/1024:.1f} KB')
    except Exception as e:
        print(f'      ! 验证失败 (不影响部署): {e}', flush=True)

    print()
    print('=' * 42)
    print(f'  部署完成: {URL}')
    print('  Ctrl+Shift+R 强刷')
    print('=' * 42)
    print()
    return 0


if __name__ == '__main__':
    sys.exit(main())
