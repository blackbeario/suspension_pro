import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paywall_view_model.g.dart';

@riverpod
class PaywallViewModel extends _$PaywallViewModel {
  @override
  void build() {
    // Stateless view model
  }

  /// Get monthly package from offering
  Package getMonthlyPackage(Offering offering) {
    final packages = offering.availablePackages;
    return packages.firstWhere(
      (p) => p.packageType == PackageType.monthly,
      orElse: () => packages.first,
    );
  }

  /// Get annual package from offering
  Package getAnnualPackage(Offering offering) {
    final packages = offering.availablePackages;
    return packages.firstWhere(
      (p) => p.packageType == PackageType.annual,
      orElse: () => packages.last,
    );
  }
}
