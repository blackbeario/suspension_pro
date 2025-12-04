import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';
import 'package:ridemetrx/core/hive_helper/fields/location_data_fields.dart';

part 'location_data.g.dart';

/// Location data for community settings
/// Includes trail name, geohash for proximity queries, and trail type
@HiveType(typeId: HiveTypes.locationData, adapterName: HiveAdapters.locationData)
class LocationData {
  @HiveField(LocationDataFields.name)
  final String? name; // e.g., "Whistler Bike Park - A-Line"

  @HiveField(LocationDataFields.geohash)
  final String? geohash; // For proximity queries

  @HiveField(LocationDataFields.lat)
  final double? lat;

  @HiveField(LocationDataFields.lng)
  final double? lng;

  @HiveField(LocationDataFields.trailType)
  final String? trailType; // bike_park, xc, enduro, dh, all_mountain

  LocationData({
    this.name,
    this.geohash,
    this.lat,
    this.lng,
    this.trailType,
  });

  /// Create from Firestore map
  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      name: map['name'] as String?,
      geohash: map['geohash'] as String?,
      lat: map['lat'] as double?,
      lng: map['lng'] as double?,
      trailType: map['trailType'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (geohash != null) 'geohash': geohash,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (trailType != null) 'trailType': trailType,
    };
  }

  /// Get display string for trail type
  String get trailTypeDisplay {
    switch (trailType) {
      case 'bike_park':
        return 'Bike Park';
      case 'xc':
        return 'XC';
      case 'enduro':
        return 'Enduro';
      case 'dh':
        return 'Downhill';
      case 'all_mountain':
        return 'All Mountain';
      default:
        return 'Unknown';
    }
  }
}
