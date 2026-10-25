/// Formats a number the way JavaScript's `String(n)` does, so `10.0` renders
/// as `10` and `20 / 3` as `6.666666666666667`.
String jsNum(num value) {
  if (value is int) return value.toString();
  final d = value.toDouble();
  if (d.isNaN) return 'NaN';
  if (d.isInfinite) return d > 0 ? 'Infinity' : '-Infinity';
  if (d == d.truncateToDouble() && d.abs() < 1e21) {
    return d == 0 ? '0' : d.toInt().toString();
  }
  return d.toString();
}

/// JavaScript `Number.prototype.toFixed(2)`.
String toFixed2(num value) => value.toStringAsFixed(2);

/// JavaScript `+text || 0` for numeric inputs.
double parseJsNumber(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  final parsed = double.tryParse(trimmed);
  if (parsed == null || parsed.isNaN) return 0;
  return parsed;
}
