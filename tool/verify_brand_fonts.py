"""Check supplied TTF cmap coverage against both localized catalogs; no dependencies."""
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def glyph(data, offset, codepoint):
    u16 = lambda pos: struct.unpack_from('>H', data, pos)[0]
    u32 = lambda pos: struct.unpack_from('>I', data, pos)[0]
    fmt = u16(offset)
    if fmt == 12:
        for group in range(u32(offset + 12)):
            start, end, first = struct.unpack_from('>III', data, offset + 16 + group * 12)
            if start <= codepoint <= end:
                return first + codepoint - start
    if fmt == 4 and codepoint <= 0xFFFF:
        count = u16(offset + 6) // 2
        ends = offset + 14
        starts = ends + count * 2 + 2
        deltas = starts + count * 2
        ranges = deltas + count * 2
        for segment in range(count):
            start, end = u16(starts + segment * 2), u16(ends + segment * 2)
            if start <= codepoint <= end:
                delta = u16(deltas + segment * 2)
                address = ranges + segment * 2
                distance = u16(address)
                if not distance:
                    return (codepoint + delta) & 0xFFFF
                index = u16(address + distance + (codepoint - start) * 2)
                return (index + delta) & 0xFFFF if index else 0
    return 0

catalogs = [json.loads((ROOT / f'lib/l10n/app_{code}.arb').read_text(encoding='utf-8')) for code in ['en', 'vi']]
required = {ord(char) for catalog in catalogs for key, value in catalog.items()
            if not key.startswith('@') and isinstance(value, str)
            for char in value if char.isprintable()}
coverage = {}
for family in ['sora', 'inter']:
    data = (ROOT / f'assets/fonts/{family}-variable.ttf').read_bytes()
    tables = {}
    for index in range(struct.unpack_from('>H', data, 4)[0]):
        tag, _, offset, _ = struct.unpack_from('>4sIII', data, 12 + index * 16)
        tables[tag] = offset
    cmap = tables[b'cmap']
    subtables = [cmap + struct.unpack_from('>HHI', data, cmap + 4 + index * 8)[2]
                 for index in range(struct.unpack_from('>H', data, cmap + 2)[0])]
    missing = sorted(cp for cp in required if not any(glyph(data, offset, cp) for offset in subtables))
    coverage[family] = required - set(missing)
    fvar = tables[b'fvar']
    axis_offset, _, axis_count, axis_size = struct.unpack_from('>HHHH', data, fvar + 4)
    axes = {}
    for index in range(axis_count):
        tag, low, default, high = struct.unpack_from('>4siii', data, fvar + axis_offset + index * axis_size)
        axes[tag.decode()] = [value / 65536 for value in (low, default, high)]
    print(f'{family}: {len(required) - len(missing)}/{len(required)} localized characters supported; variable axes {axes}')
    if missing:
        print('  Missing codepoints: ' + ', '.join(f'U+{cp:04X}' for cp in missing))
missing = required - coverage['inter']
assert not missing, 'Body/fallback font is missing localized characters: ' + ', '.join(f'U+{cp:04X}' for cp in missing)
print('PASS: Inter covers body text and every missing Sora glyph; heading fallback is required.')
