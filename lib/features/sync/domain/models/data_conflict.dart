import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';

part 'data_conflict.g.dart';

/// Represents a data conflict between local (Hive) and remote (Firebase) versions
/// Used to track conflicts that need user resolution
@HiveType(typeId: 6, adapterName: 'DataConflictAdapter')
class DataConflict extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String itemType; // "bike" or "setting"

  @HiveField(2)
  final String itemId;

  @HiveField(3)
  final String bikeId; // For settings, this is the parent bike ID

  @HiveField(4)
  final Map<String, dynamic> localVersion;

  @HiveField(5)
  final Map<String, dynamic> remoteVersion;

  @HiveField(6)
  final DateTime detectedAt;

  @HiveField(7)
  final DateTime localModifiedAt;

  @HiveField(8)
  final DateTime remoteModifiedAt;

  DataConflict({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.bikeId,
    required this.localVersion,
    required this.remoteVersion,
    required this.detectedAt,
    required this.localModifiedAt,
    required this.remoteModifiedAt,
  });

  /// Generate unique ID for conflict
  static String generateId(String itemType, String itemId) {
    return '$itemType-$itemId-${DateTime.now().millisecondsSinceEpoch}';
  }
}
