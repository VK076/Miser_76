/// Currency class to manage different country currencies
class Currency {
  final String code;      // e.g., 'USD', 'EUR', 'INR'
  final String symbol;    // e.g., '$', '€', '₹'
  final String name;      // e.g., 'US Dollar', 'Indian Rupee'
  final String country;   // e.g., 'United States', 'India'

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.country,
  });

  @override
  String toString() => '$symbol $code';
}

class CurrencyManager {
  // Available currencies
  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    country: 'United States',
  );

  static const Currency eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    country: 'European Union',
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    country: 'United Kingdom',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    country: 'Japan',
  );

  static const Currency inr = Currency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    country: 'India',
  );

  static const Currency aud = Currency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
    country: 'Australia',
  );

  static const Currency cad = Currency(
    code: 'CAD',
    symbol: 'C\$',
    name: 'Canadian Dollar',
    country: 'Canada',
  );

  static const Currency chf = Currency(
    code: 'CHF',
    symbol: 'CHF',
    name: 'Swiss Franc',
    country: 'Switzerland',
  );

  static const Currency cny = Currency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
    country: 'China',
  );

  static const Currency sek = Currency(
    code: 'SEK',
    symbol: 'kr',
    name: 'Swedish Krona',
    country: 'Sweden',
  );

  static const Currency nzd = Currency(
    code: 'NZD',
    symbol: 'NZ\$',
    name: 'New Zealand Dollar',
    country: 'New Zealand',
  );

  static const Currency sgd = Currency(
    code: 'SGD',
    symbol: 'S\$',
    name: 'Singapore Dollar',
    country: 'Singapore',
  );

  // List of all available currencies
  static const List<Currency> allCurrencies = [
    usd, eur, gbp, jpy, inr, aud, cad, chf, cny, sek, nzd, sgd,
  ];

  /// Get currency by code (e.g., 'USD')
  static Currency getCurrencyByCode(String code) {
    try {
      return allCurrencies.firstWhere(
        (currency) => currency.code == code,
      );
    } catch (e) {
      return usd; // Default to USD if not found
    }
  }

  /// Get all currency codes
  static List<String> getAllCodes() {
    return allCurrencies.map((currency) => currency.code).toList();
  }

  /// Get all currency display names (for dropdowns)
  static List<String> getAllCurrencyNames() {
    return allCurrencies.map((c) => '${c.symbol} ${c.code} - ${c.name}').toList();
  }
}
