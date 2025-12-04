import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';

part 'bikes_list_view_model.g.dart';

@riverpod
class BikesListViewModel extends _$BikesListViewModel {
  @override
  void build() {
    // Stateless view model
  }

  /// Format bike name for display
  /// Combines year model with bike name if available
  String formatBikeName(Bike bike) {
    if (bike.yearModel != null) {
      return '${bike.yearModel} ${bike.id}';
    }
    return bike.id;
  }
}
