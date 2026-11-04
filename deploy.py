# -*- coding: utf-8 -*-
"""像素田园 · 一键部署 (原子切换版)

流程: 打包 -> 上传带时间戳的 zip -> 解压到独立 release 目录 -> 软链原子切换 docroot
      -> 线上验证 -> 失败自动回滚到上一版
用法: 双击 deploy.cmd, 或 python deploy.py
旧式(清空覆盖, 无回滚)保留在 deploy-legacy.py, 仅作应急对比。
"""
import os, sys, subprocess, zipfile, tempfile, time, urllib.request

if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

ROOT         = os.path.dirname(os.path.abspath(__file__))
DEMO_DIR     = os.path.join(ROOT, 'demo')
STAMP        = time.strftime('%Y%m%d%H%M%S')
ZIP_PATH     = os.path.join(tempfile.gettempdir(), f'pixel-farm-dist-{STAMP}.zip')

REMOTE_HOST  = 'aliyun-ab'
REMOTE_TMP   = f'/tmp/pixel-farm-dist-{STAMP}.zip'
REMOTE_DIR   = '/var/www/play.bykc.click'                 # docroot, 部署后为软链
RELEASES_DIR = '/var/www/play.bykc.click.releases'        # 每次部署一个独立目录
RELEASE_DIR  = f'{RELEASES_DIR}/{STAMP}'
KEEP_RELEASES = 3

URL          = 'https://play.bykc.click/play.html'
MANIFEST_URL = 'https://play.bykc.click/assets/sv/manifest.json'


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


def ssh(cmd, timeout=90):
    return run_native(['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10',
                       REMOTE_HOST, cmd], timeout=timeout)


def http_check(url, min_bytes=1, must_contain=None):
    """返回 (ok, 描述)"""
    try:
        req = urllib.request.Request(url + ('&' if '?' in url else '?') + 'v=' + STAMP,
                                     headers={'Cache-Control': 'no-cache'})
        with urllib.request.urlopen(req, timeout=15) as r:
            body = r.read()
            if r.status != 200:
                return (False, f'HTTP {r.status}')
            if len(body) < min_bytes:
                return (False, f'内容过小 {len(body)}B')
            if must_contain and must_contain.encode() not in body:
                return (False, f'内容缺少标记 {must_contain}')
            return (True, f'HTTP 200, {len(body)/1024:.1f} KB')
    except Exception as e:
        return (False, str(e))


def main():
    print()
    print('=' * 52)
    print('  像素田园 · 原子部署')
    print(f'  release: {STAMP}')
    print('=' * 52)
    print()

    if not os.path.isdir(DEMO_DIR):
        fail(f'demo 目录不存在: {DEMO_DIR}')
        return 1

    # [1/6] 打包
    step('1/6 打包 demo/ ...')
    if os.path.exists(ZIP_PATH):
        os.remove(ZIP_PATH)
    try:
        n = 0
        with zipfile.ZipFile(ZIP_PATH, 'w', zipfile.ZIP_DEFLATED) as z:
            for rt, ds, fs in os.walk(DEMO_DIR):
                ds[:] = [d for d in ds if d != '_scripts']   # 生成脚本不进发布包
                for f in fs:
                    full = os.path.join(rt, f)
                    rel = os.path.relpath(full, DEMO_DIR).replace(os.sep, '/')
                    z.write(full, rel)
                    n += 1
        ok(f'{ZIP_PATH}  ({n} 文件, {os.path.getsize(ZIP_PATH)/1024:.1f} KB)')
    except Exception as e:
        fail(f'打包失败: {e}')
        return 1

    # [2/6] 上传
    step(f'2/6 上传到 {REMOTE_HOST} ...')
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

    # [3/6] 远端解压到独立 release 目录 (此时线上仍是旧版本)
    step('3/6 服务器解压到 release 目录 ...')
    prep = (
        f'set -e; '
        f'mkdir -p {RELEASES_DIR}; '
        f'rm -rf {RELEASE_DIR}; mkdir -p {RELEASE_DIR}; '
        f'unzip -q -o {REMOTE_TMP} -d {RELEASE_DIR}; '
        f'chown -R www-data:www-data {RELEASE_DIR}; '
        f'find {RELEASE_DIR} -type f | wc -l'
    )
    code, out, err = ssh(prep)
    if code != 0:
        fail(f'解压失败 (exit {code})')
        print('     ', (err or out).strip()[:300])
        return 1
    nums = [l.strip() for l in out.splitlines() if l.strip().isdigit()]
    ok(f'{nums[-1] if nums else "?"} 个文件 -> {RELEASE_DIR}')

    # [4/6] 原子切换: 真实目录 -> 保留为 prev-dir; 软链 -> 记录旧目标后改指向
    step('4/6 切换 docroot ...')
    switch = (
        f'set -e; '
        f'if [ -L {REMOTE_DIR} ]; then '
        f'  readlink -f {REMOTE_DIR} > {RELEASES_DIR}/prev-target-{STAMP}.txt; '
        f'  ln -sfn {RELEASE_DIR} {REMOTE_DIR}; '
        f'elif [ -d {REMOTE_DIR} ]; then '
        f'  rm -rf {RELEASES_DIR}/prev-dir-{STAMP}; '
        f'  mv {REMOTE_DIR} {RELEASES_DIR}/prev-dir-{STAMP}; '
        f'  ln -s {RELEASE_DIR} {REMOTE_DIR}; '
        f'else '
        f'  ln -s {RELEASE_DIR} {REMOTE_DIR}; '
        f'fi; '
        f'echo SWITCH_OK; readlink -f {REMOTE_DIR}'
    )
    code, out, err = ssh(switch)
    if code != 0 or 'SWITCH_OK' not in out:
        fail(f'切换失败 (exit {code})')
        print('     ', (err or out).strip()[:300])
        print('      线上仍是上一版(切换未完成)')
        return 1
    ok(f'{REMOTE_DIR} -> {RELEASE_DIR}')

    # [5/6] 线上验证, 失败则回滚
    step('5/6 验证线上 ...')
    checks = [
        ('play.html', URL, 10240, 'pixel-farm-save-v1'),
        ('manifest.json', MANIFEST_URL, 100, '"total"'),
    ]
    passed = True
    for name, url, minb, mark in checks:
        good, desc = http_check(url, minb, mark)
        print(f'      {"OK " if good else "FAIL"} {name}: {desc}', flush=True)
        if not good:
            passed = False

    if not passed:
        fail('验证未通过, 回滚到上一版 ...')
        rollback = (
            f'set -e; '
            f'if [ -L {REMOTE_DIR} ]; then rm -f {REMOTE_DIR}; fi; '
            f'if [ -d {RELEASES_DIR}/prev-dir-{STAMP} ]; then '
            f'  mv {RELEASES_DIR}/prev-dir-{STAMP} {REMOTE_DIR}; '
            f'elif [ -f {RELEASES_DIR}/prev-target-{STAMP}.txt ]; then '
            f'  ln -sfn "$(cat {RELEASES_DIR}/prev-target-{STAMP}.txt)" {REMOTE_DIR}; '
            f'fi; '
            f'echo ROLLBACK_DONE'
        )
        code, out, err = ssh(rollback)
        if code == 0 and 'ROLLBACK_DONE' in out:
            ok('已回滚, 线上应为上一版')
        else:
            fail(f'回滚失败 (exit {code}): {(err or out).strip()[:200]}')
        print('      本机 zip:', ZIP_PATH)
        return 1

    # [6/6] 清理: 只保留最近 KEEP_RELEASES 个版本目录
    step(f'6/6 清理旧版本 (保留 {KEEP_RELEASES} 个) ...')
    prune = (
        f'ls -1dt {RELEASES_DIR}/* 2>/dev/null | grep -E "/[0-9]{{14}}$" | tail -n +{KEEP_RELEASES + 1} | xargs -r rm -rf; '
        f'rm -f {REMOTE_TMP}; '
        f'ls -1dt {RELEASES_DIR}/* 2>/dev/null | head -n 5'
    )
    code, out, err = ssh(prune)
    if code != 0:
        print(f'      ! 清理失败(不影响结果): {(err or out).strip()[:200]}', flush=True)
    else:
        ok('剩余版本: ' + ' '.join(x.strip() for x in out.splitlines() if x.strip())[:200])

    print()
    print('=' * 52)
    print(f'  部署完成: {URL}')
    print(f'  回滚方式: 软链指回 {RELEASES_DIR}/prev-*')
    print('  Ctrl+Shift+R 强刷')
    print('=' * 52)
    print()
    return 0


if __name__ == '__main__':
    sys.exit(main())
