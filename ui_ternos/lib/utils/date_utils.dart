String? normalizeFecha(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final isoFull = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');
  final m = isoFull.firstMatch(raw);
  if (m != null) return '${m.group(1)}-${m.group(2)}-${m.group(3)}';
  if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(raw)) {
    final p = raw.split('/');
    return '${p[2]}-${p[1]}-${p[0]}';
  }
  try {
    final dt = DateTime.parse(raw);
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return null;
  }
}
