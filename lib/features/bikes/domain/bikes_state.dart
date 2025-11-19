import 'package:suspension_pro/features/bikes/domain/models/bike.dart';

class BikesState {
  final List<Bike> bikes;
  final bool isLoading;
  final String? errorMessage;
  final bool isSyncing;

  const BikesState({
    this.bikes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSyncing = false,
  });

  BikesState copyWith({
    List<Bike>? bikes,
    bool? isLoading,
    String? errorMessage,
    bool? isSyncing,
    bool clearError = false,
  }) {
    return BikesState(
      bikes: bikes ?? this.bikes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  bool get hasBikes => bikes.isNotEmpty;
}
