import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';
import 'package:ridemetrx/core/hive_helper/fields/community_setting_fields.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/features/bikes/domain/models/component_setting.dart';
import 'package:ridemetrx/features/community/domain/models/location_data.dart';

part 'community_setting.g.dart';

/// Community-shared suspension setting
/// Cached in Hive for offline browsing
@HiveType(typeId: HiveTypes.communitySetting, adapterName: HiveAdapters.communitySetting)
class CommunitySetting {
  @HiveField(CommunitySettingFields.settingId)
  final String settingId;

  @HiveField(CommunitySettingFields.userId)
  final String userId;

  @HiveField(CommunitySettingFields.userName)
  final String userName;

  @HiveField(CommunitySettingFields.isPro)
  final bool isPro;

  // Bike components (for searching/filtering)
  @HiveField(CommunitySettingFields.fork)
  final Fork? fork;

  @HiveField(CommunitySettingFields.shock)
  final Shock? shock;

  // Suspension settings (the actual data)
  @HiveField(CommunitySettingFields.forkSettings)
  final ComponentSetting? forkSettings;

  @HiveField(CommunitySettingFields.shockSettings)
  final ComponentSetting? shockSettings;

  // Tire pressures
  @HiveField(CommunitySettingFields.frontTire)
  final String? frontTire;

  @HiveField(CommunitySettingFields.rearTire)
  final String? rearTire;

  // Rider context
  @HiveField(CommunitySettingFields.riderWeight)
  final String? riderWeight;

  @HiveField(CommunitySettingFields.notes)
  final String? notes;

  // Location data (Pro only)
  @HiveField(CommunitySettingFields.location)
  final LocationData? location;

  // Engagement metrics
  @HiveField(CommunitySettingFields.upvotes)
  final int upvotes;

  @HiveField(CommunitySettingFields.downvotes)
  final int downvotes;

  @HiveField(CommunitySettingFields.imports)
  final int imports;

  @HiveField(CommunitySettingFields.views)
  final int views;

  // Timestamps
  @HiveField(CommunitySettingFields.created)
  final DateTime created;

  @HiveField(CommunitySettingFields.updated)
  final DateTime? updated;

  // Bike info (helpful context for users)
  @HiveField(CommunitySettingFields.bikeMake)
  final String? bikeMake;

  @HiveField(CommunitySettingFields.bikeModel)
  final String? bikeModel;

  CommunitySetting({
    required this.settingId,
    required this.userId,
    required this.userName,
    required this.isPro,
    this.fork,
    this.shock,
    this.forkSettings,
    this.shockSettings,
    this.frontTire,
    this.rearTire,
    this.riderWeight,
    this.notes,
    this.location,
    this.upvotes = 0,
    this.downvotes = 0,
    this.imports = 0,
    this.views = 0,
    required this.created,
    this.updated,
    this.bikeMake,
    this.bikeModel,
  });

  /// Create from Firestore document
  factory CommunitySetting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CommunitySetting(
      settingId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      isPro: data['isPro'] ?? false,
      fork: data['fork'] != null ? _forkFromJson(doc.id, data['fork']) : null,
      shock: data['shock'] != null ? _shockFromJson(doc.id, data['shock']) : null,
      forkSettings: data['forkSettings'] != null
          ? ComponentSetting.fromJson(data['forkSettings'])
          : null,
      shockSettings: data['shockSettings'] != null
          ? ComponentSetting.fromJson(data['shockSettings'])
          : null,
      frontTire: data['frontTire'] as String?,
      rearTire: data['rearTire'] as String?,
      riderWeight: data['riderWeight'] as String?,
      notes: data['notes'] as String?,
      location: data['location'] != null
          ? LocationData.fromMap(data['location'])
          : null,
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      imports: data['imports'] ?? 0,
      views: data['views'] ?? 0,
      created: data['created'] != null
          ? (data['created'] as Timestamp).toDate()
          : DateTime.now(),
      updated: data['updated'] != null
          ? (data['updated'] as Timestamp).toDate()
          : null,
      bikeMake: data['bikeMake'] as String?,
      bikeModel: data['bikeModel'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'isPro': isPro,
      if (fork != null) 'fork': _forkToJson(fork!),
      if (shock != null) 'shock': _shockToJson(shock!),
      if (forkSettings != null) 'forkSettings': forkSettings!.toJson(),
      if (shockSettings != null) 'shockSettings': shockSettings!.toJson(),
      if (frontTire != null) 'frontTire': frontTire,
      if (rearTire != null) 'rearTire': rearTire,
      if (riderWeight != null) 'riderWeight': riderWeight,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location!.toMap(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'imports': imports,
      'views': views,
      'created': Timestamp.fromDate(created),
      if (updated != null) 'updated': Timestamp.fromDate(updated!),
      if (bikeMake != null) 'bikeMake': bikeMake,
      if (bikeModel != null) 'bikeModel': bikeModel,
    };
  }

  /// Get bike components display string
  String get componentsDisplay {
    final List<String> parts = [];

    if (fork != null) {
      parts.add('${fork!.brand} ${fork!.model}');
    }
    if (shock != null) {
      parts.add('${shock!.brand} ${shock!.model}');
    }

    return parts.isEmpty ? 'Unknown Setup' : parts.join(' / ');
  }

  /// Get short display string for components
  String get shortComponentsDisplay {
    if (fork != null && shock != null) {
      return '${fork!.year} ${fork!.brand} / ${shock!.brand}'.trim();
    } else if (fork != null) {
      return '${fork!.year} ${fork!.brand} ${fork!.model}'.trim();
    } else if (shock != null) {
      return '${shock!.year} ${shock!.brand} ${shock!.model}'.trim();
    }
    return 'Unknown Setup';
  }

  /// Get location display string
  String get locationDisplay {
    if (location?.name != null) {
      return location!.name!;
    } else if (location?.trailType != null) {
      return location!.trailTypeDisplay;
    }
    return 'Location not specified';
  }

  /// Get bike display string
  String get bikeDisplay {
    if (bikeMake != null && bikeModel != null) {
      return '$bikeMake $bikeModel';
    } else if (bikeMake != null) {
      return bikeMake!;
    } else if (bikeModel != null) {
      return bikeModel!;
    }
    return 'Bike not specified';
  }

  /// Copy with updated fields
  CommunitySetting copyWith({
    String? settingId,
    String? userId,
    String? userName,
    bool? isPro,
    Fork? fork,
    Shock? shock,
    ComponentSetting? forkSettings,
    ComponentSetting? shockSettings,
    String? frontTire,
    String? rearTire,
    String? riderWeight,
    String? notes,
    LocationData? location,
    int? upvotes,
    int? downvotes,
    int? imports,
    int? views,
    DateTime? created,
    DateTime? updated,
    String? bikeMake,
    String? bikeModel,
  }) {
    return CommunitySetting(
      settingId: settingId ?? this.settingId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isPro: isPro ?? this.isPro,
      fork: fork ?? this.fork,
      shock: shock ?? this.shock,
      forkSettings: forkSettings ?? this.forkSettings,
      shockSettings: shockSettings ?? this.shockSettings,
      frontTire: frontTire ?? this.frontTire,
      rearTire: rearTire ?? this.rearTire,
      riderWeight: riderWeight ?? this.riderWeight,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      imports: imports ?? this.imports,
      views: views ?? this.views,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      bikeMake: bikeMake ?? this.bikeMake,
      bikeModel: bikeModel ?? this.bikeModel,
    );
  }

  /// Helper to convert Fork from JSON (Fork.fromJson requires bikeId)
  static Fork _forkFromJson(String settingId, Map<String, dynamic> json) {
    return Fork.fromJson(settingId, json);
  }

  /// Helper to convert Shock from JSON (Shock.fromJson requires bikeId)
  static Shock _shockFromJson(String settingId, Map<String, dynamic> json) {
    return Shock.fromJson(settingId, json);
  }

  /// Helper to convert Fork to JSON (Fork doesn't have toJson method)
  static Map<String, dynamic> _forkToJson(Fork fork) {
    return {
      'brand': fork.brand,
      'model': fork.model,
      'year': fork.year,
      'travel': fork.travel,
      'damper': fork.damper,
      'offset': fork.offset,
      'wheelsize': fork.wheelsize,
      'spacers': fork.spacers,
      'spacing': fork.spacing,
      'serialNumber': fork.serialNumber,
    };
  }

  /// Helper to convert Shock to JSON (Shock doesn't have toJson method)
  static Map<String, dynamic> _shockToJson(Shock shock) {
    return {
      'brand': shock.brand,
      'model': shock.model,
      'year': shock.year,
      'stroke': shock.stroke,
      'spacers': shock.spacers,
      'serialNumber': shock.serialNumber,
    };
  }
}
