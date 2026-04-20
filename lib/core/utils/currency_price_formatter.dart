import 'package:currency_converter/currency.dart';
import 'package:currency_converter/currency_converter.dart';
import 'package:intl/intl.dart';

class CurrencyPriceFormatter {
  CurrencyPriceFormatter._();

  static final Map<String, double> _usdRateCache = <String, double>{};

  static Future<String> formatFromUsd({
    required String amountText,
    required String currencyCode,
  }) async {
    final double amount = double.tryParse(amountText.trim()) ?? 0;
    final String normalizedCode = currencyCode.trim().toUpperCase();
    final Currency? targetCurrency = _mapCurrency(normalizedCode);
    if (targetCurrency == null) {
      return _format(amount: amount, currencyCode: 'USD');
    }

    if (targetCurrency == Currency.usd) {
      return _format(amount: amount, currencyCode: 'USD');
    }

    final double rate = await _getUsdRate(targetCurrency) ?? 1;
    final double converted = amount * rate;
    return _format(amount: converted, currencyCode: normalizedCode);
  }

  static Future<String> formatPriceLine({
    required String salePriceUsd,
    required String normalPriceUsd,
    required String currencyCode,
  }) async {
    final String salePrice = await formatFromUsd(
      amountText: salePriceUsd,
      currencyCode: currencyCode,
    );
    final String normalPrice = await formatFromUsd(
      amountText: normalPriceUsd,
      currencyCode: currencyCode,
    );
    return 'Sale $salePrice · Normal $normalPrice';
  }

  static Future<double?> _getUsdRate(Currency to) async {
    final String key = to.name.toUpperCase();
    if (_usdRateCache.containsKey(key)) {
      return _usdRateCache[key];
    }

    final double? rate = await CurrencyConverter.convert(
      from: Currency.usd,
      to: to,
      amount: 1,
      withoutRounding: true,
    );
    if (rate != null) {
      _usdRateCache[key] = rate;
    }
    return rate;
  }

  static String _format({
    required double amount,
    required String currencyCode,
  }) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_US',
      name: currencyCode,
      decimalDigits: amount >= 1000 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static Currency? _mapCurrency(String code) {
    switch (code) {
      case 'USD':
        return Currency.usd;
      case 'IDR':
        return Currency.idr;
      case 'EUR':
        return Currency.eur;
      case 'JPY':
        return Currency.jpy;
      default:
        return null;
    }
  }
}
