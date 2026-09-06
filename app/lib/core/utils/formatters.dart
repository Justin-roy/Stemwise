import 'package:intl/intl.dart';

/// Display formatters (rounding happens only for display — spec §16, §90).
class Fmt {
  Fmt._();

  static final NumberFormat _currency =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0);
  static final NumberFormat _currencyCents =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
  static final NumberFormat _plain = NumberFormat('#,##0', 'en_US');

  static String money(num value) => _currency.format(value);
  static String moneyCents(num value) => _currencyCents.format(value);
  static String number(num value) => _plain.format(value);
  static String percent(num value, {int decimals = 0}) =>
      '${value.toStringAsFixed(decimals)}%';

  /// Signed money for what-if deltas (spec §31 — never color alone).
  static String signedMoney(num value) {
    if (value == 0) return '\$0';
    final sign = value > 0 ? '+ ' : '- ';
    return '$sign${_currency.format(value.abs())}';
  }
}
