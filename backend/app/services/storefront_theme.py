"""WordPress-style template importer.

Takes a ZIP (a WordPress theme folder, a static-site export, or any HTML
template bundle) and turns it into ONE self-contained HTML document:
relative CSS/JS are inlined, and binary assets (images, fonts, icons) are
base64-embedded as data URLs. The result is stored in a single settings row,
so it survives serverless filesystems and renders inside a sandboxed iframe.

It never executes downloaded code server-side — scripts only run later in the
store window's sandboxed iframe at the store owner's own request.
"""

from __future__ import annotations

import base64
import io
import posixpath
import re
import zipfile

MIME_TYPES = {
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'svg': 'image/svg+xml',
    'avif': 'image/avif',
    'bmp': 'image/bmp',
    'ico': 'image/x-icon',
    'woff': 'font/woff',
    'woff2': 'font/woff2',
    'ttf': 'font/ttf',
    'otf': 'font/otf',
    'eot': 'application/vnd.ms-fontobject',
}

MAX_ENTRY_SIZE = 3 * 1024 * 1024
MAX_TOTAL_SIZE = 30 * 1024 * 1024


class ThemeImportError(ValueError):
    """Friendly, user-facing import failure."""


def _safe_path(name: str) -> str:
    try:
        norm = name.replace('\\', '/')
    except Exception:
        norm = name
    if '..' in norm.split('/'):
        raise ThemeImportError('مسار غير صالح داخل الحزمة')
    if norm.startswith('/') or ':' in norm.split('/', 1)[0]:
        raise ThemeImportError('ملف غير صالح داخل الحزمة')
    parts = [p for p in norm.split('/') if p not in ('', '.')]
    if not parts:
        raise ThemeImportError('ملف غير صالح داخل الحزمة')
    return '/'.join(parts)


def _norm(base: str, rel: str) -> str | None:
    parts = [p for p in posixpath.normpath(posixpath.join(base, rel)).split('/') if p not in ('', '.')]
    return '/'.join(parts) if parts else None


def _ext_of(path: str) -> str:
    return path.rsplit('.', 1)[-1].lower() if '.' in path else ''


def _data_url(data: bytes, mime: str) -> str:
    return f'data:{mime};base64,{base64.b64encode(data).decode("ascii")}'


def _transform_css(css: str, css_path: str, files: dict[str, bytes]) -> str:
    """Rewrite url()/@import references inside a CSS file to be self-contained."""
    css_dir = css_path.rsplit('/', 1)[0] if '/' in css_path else ''

    def import_cb(m: re.Match) -> str:
        u = m.group(1).strip()
        if u.startswith(('http://', 'https://', '//', 'data:', '#')) or u.startswith('/'):
            return m.group(0)
        path = _norm(css_dir, u)
        if path in files and _ext_of(path) == 'css':
            inner = files[path].decode('utf-8-sig', 'replace')
            inner = inner.replace('<?php', '').replace('<?', '')
            return _transform_css(inner, path, files)
        return m.group(0)

    def url_cb(m: re.Match) -> str:
        u = m.group(1).strip()
        if u.startswith(('http://', 'https://', '//', 'data:', '#')) or u.startswith('/'):
            return m.group(0)
        path = _norm(css_dir, u)
        if path not in files:
            return m.group(0)
        data = files[path]
        ext = _ext_of(path)
        if ext in MIME_TYPES:
            return f'url(data:{MIME_TYPES[ext]};base64,{base64.b64encode(data).decode("ascii")})'
        return m.group(0)

    css = css.replace('<?php', '').replace('<?', '')
    css = re.sub(r"""@import\s+url\(\s*["']?([^"')]+)["']?\s*\)[^;]*;?""", import_cb, css, flags=re.IGNORECASE)
    css = re.sub(r"""@import\s+["']([^"']+)["']\s*;""", import_cb, css, flags=re.IGNORECASE)
    css = re.sub(r"""url\(\s*["']?([^"')]+)["']?\s*\)""", url_cb, css)
    return css


def import_theme_zip(contents: bytes, filename: str = 'theme.zip') -> dict:
    """Unpack a ZIP into a single self-contained HTML document."""
    if contents[:4] != b'PK\x03\x04' and contents[:4] != b'PK\x05\x06':
        raise ThemeImportError('الملف ليس ملف ZIP صالحاً')

    try:
        zf = zipfile.ZipFile(io.BytesIO(contents))
    except zipfile.BadZipFile:
        raise ThemeImportError('الملف ليس ملف ZIP صالحاً') from None

    files: dict[str, bytes] = {}
    total = 0
    for info in zf.infolist():
        try:
            nm = _safe_path(info.filename)
        except ThemeImportError:
            continue
        if info.is_dir() or nm.startswith('__MACOSX/') or nm.endswith('Thumbs.db'):
            continue
        data = zf.read(info)
        if len(data) > MAX_ENTRY_SIZE:
            continue
        total += len(data)
        if total > MAX_TOTAL_SIZE:
            raise ThemeImportError('حجم القالب كبير جداً (أقصى حد 30 ميجابايت)')
        files[nm] = data

    html_key: str | None = None
    indies = [k for k in files if k.endswith('/index.html') or k == 'index.html']
    if indies:
        html_key = sorted(indies, key=lambda s: (s.count('/'), len(s)))[0]
    else:
        htmls = [k for k in files if k.endswith('.htm') or k.endswith('.html')]
        if not htmls:
            raise ThemeImportError('لا يوجد ملف index.html داخل الحزمة')
        html_key = sorted(htmls, key=lambda s: (s.count('/'), len(s)))[0]

    base_dir = html_key.rsplit('/', 1)[0] if '/' in html_key else ''
    html = files[html_key].decode('utf-8-sig', 'replace')
    html = html.replace('<?php', '').replace('<?', '')
    name = re.search(r'<title[^>]*>(.*?)</title>', html, re.I | re.S)
    name = (name.group(1).strip() if name else (filename.rsplit('.', 1)[0] or 'قالب مستورد'))[:60]

    # Pass 1: inline local CSS/JS tags (drop the <link>/<script> wrapper).
    def tag_cb(m: re.Match) -> str:
        full = m.group(0)
        tag = m.group(1)
        attr = m.group(3)
        quote = m.group(4)
        ref = m.group(5)
        if attr == 'src' and tag == 'script':
            return full
        u = ref.strip()
        if u.startswith(('http://', 'https://', '//', 'data:', '#')) or u.startswith('/'):
            return full
        path = _norm(base_dir, u)
        if path not in files:
            return full
        ext = _ext_of(path)
        data = files[path]
        if ext == 'css':
            return '<style>\n' + _transform_css(data.decode('utf-8-sig', 'replace'), path, files) + '\n</style>'
        if ext == 'js':
            out = data.decode('utf-8-sig', 'replace').replace('</script', '<\\/script')
            return '<script>\n' + out + '\n</script>'
        return full

    html = re.sub(
        r'''<(link|script)\b([^>]*?)\s(href|src)\s*=\s*(["'])([^"']+)\4\s*/?\s*>''',
        tag_cb, html, flags=re.I | re.S,
    )

    # Pass 2: swap remaining local binary refs (images/fonts/icons) to data URLs.
    def swap_cb(m: re.Match) -> str:
        attr, quote, ref = m.groups()
        u = ref.strip()
        if u.startswith(('http://', 'https://', '//', 'data:', '#', 'mailto:', 'tel:', 'javascript:')) or u.startswith('/'):
            return m.group(0)
        path = _norm(base_dir, u)
        if path not in files:
            return m.group(0)
        ext = _ext_of(path)
        if ext not in MIME_TYPES:
            return m.group(0)
        return f'{attr}={quote}data:{MIME_TYPES[ext]};base64,{base64.b64encode(files[path]).decode("ascii")}{quote}'

    html = re.sub(r'''\b(src|href)\s*=\s*(["'])([^"']+)\2''', swap_cb, html)

    # srcset is common in exports — embed local candidates too.
    def srcset_cb(m: re.Match) -> str:
        body = m.group(1)
        parts = []
        for cand in body.split(','):
            tokens = cand.strip().split()
            if not tokens:
                continue
            url = tokens[0]
            if not url.startswith(('http://', 'https://', '//', 'data:')) and not url.startswith('/'):
                path = _norm(base_dir, url)
                if path in files and _ext_of(path) in MIME_TYPES:
                    url = _data_url(files[path], MIME_TYPES[_ext_of(path)])
            rest = tokens[1:]
            parts.append(' '.join([url] + rest) if rest else url)
        return 'srcset="' + ', '.join(parts) + '"'

    # srcset is common in exports — embed local candidates too.
    def srcset_cb(m: re.Match) -> str:
        return 'srcset="' + _srcset_body(m.group(1), base_dir, files) + '"'

    html = re.sub(r'''srcset\s*=\s*(["'])([^"']+)\1''', srcset_cb, html, flags=re.I)

    if len(html.encode('utf-8')) > 6 * 1024 * 1024:
        raise ThemeImportError('القالب الناتج كبير جداً (أقصى حد 6 ميجابايت)')

    return {
        'name': name,
        'html': html,
        'size': len(html.encode('utf-8')),
        'assets': len(files),
        'imported_at': None,  # filled by the router
    }


def _srcset_body(body: str, base_dir: str, files: dict[str, bytes]) -> str:
    parts = []
    for cand in body.split(','):
        tokens = cand.strip().split()
        if not tokens:
            continue
        url = tokens[0]
        if not url.startswith(('http://', 'https://', '//', 'data:')) and not url.startswith('/'):
            path = _norm(base_dir, url)
            if path in files and _ext_of(path) in MIME_TYPES:
                url = _data_url(files[path], MIME_TYPES[_ext_of(path)])
        parts.append(' '.join([url] + tokens[1:]) if len(tokens) > 1 else url)
    return ', '.join(parts)