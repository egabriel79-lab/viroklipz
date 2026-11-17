class CoinPackage {
  final String id;
  final int coins;
  final int bonus;
  final String priceText;

  const CoinPackage({
    required this.id,
    required this.coins,
    required this.bonus,
    required this.priceText,
  });

  int get totalCoins => coins + bonus;
}

const List<CoinPackage> kCoinPackages = [
  CoinPackage(id: 'pkg_10', coins: 10, bonus: 5, priceText: 'USD 0,08'),
  CoinPackage(id: 'pkg_50', coins: 50, bonus: 15, priceText: 'USD 0,39'),
  CoinPackage(id: 'pkg_100', coins: 100, bonus: 30, priceText: 'USD 0,79'),
  CoinPackage(id: 'pkg_500', coins: 500, bonus: 150, priceText: 'USD 3,99'),
  CoinPackage(id: 'pkg_1000', coins: 1000, bonus: 300, priceText: 'USD 7,99'),
  CoinPackage(id: 'pkg_2000', coins: 2000, bonus: 600, priceText: 'USD 14,99'),
];