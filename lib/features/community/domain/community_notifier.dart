import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/features/bikes/presentation/view_models/settings_list_view_model.dart';
import 'package:ridemetrx/features/community/domain/models/community_setting.dart';
import 'package:ridemetrx/features/community/domain/models/community_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'community_notifier.g.dart';

/// Manages community settings state and operations
/// Handles fetching, caching, searching, and importing settings
@riverpod
class CommunityNotifier extends _$CommunityNotifier {
  static const String _hiveBoxName = 'community_settings';
  static const int _cacheExpiryHours = 24;

  @override
  CommunityState build() {
    // Initialize by loading cached data
    _loadCachedSettings();
    return CommunityState.initial();
  }

  /// Load cached settings from Hive on startup
  Future<void> _loadCachedSettings() async {
    try {
      final box = await Hive.openBox<CommunitySetting>(_hiveBoxName);
      final cachedSettings = box.values.toList();

      if (cachedSettings.isNotEmpty) {
        state = state.copyWithData(cachedSettings, isOfflineCache: true);
        print('CommunityNotifier: Loaded ${cachedSettings.length} cached settings');
      }

      // Fetch fresh data in background
      _fetchSettingsInBackground();
    } catch (e) {
      print('CommunityNotifier: Error loading cache: $e');
      // If cache fails, fetch from Firebase
      fetchSettings();
    }
  }

  /// Fetch settings in background without showing loading state
  Future<void> _fetchSettingsInBackground() async {
    try {
      final settings = await _fetchFromFirebase();
      await _cacheSettings(settings);
      state = state.copyWithData(settings, isOfflineCache: false);
    } catch (e) {
      print('CommunityNotifier: Background fetch failed: $e');
      // Silently fail - user still has cached data
    }
  }

  /// Fetch settings from Firebase (user-initiated)
  Future<void> fetchSettings() async {
    state = state.copyWithLoading();

    try {
      final settings = await _fetchFromFirebase();
      await _cacheSettings(settings);
      state = state.copyWithData(settings);
    } catch (e) {
      print('CommunityNotifier: Fetch error: $e');
      state = state.copyWithError('Failed to load community settings');
    }
  }

  /// Fetch settings from Firestore
  Future<List<CommunitySetting>> _fetchFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('community_settings')
        .orderBy('imports', descending: true)
        .limit(100) // Limit to top 100 most imported
        .get();

    return snapshot.docs.map((doc) => CommunitySetting.fromFirestore(doc)).toList();
  }

  /// Cache settings to Hive
  Future<void> _cacheSettings(List<CommunitySetting> settings) async {
    try {
      final box = await Hive.openBox<CommunitySetting>(_hiveBoxName);
      await box.clear();

      for (final setting in settings) {
        await box.put(setting.settingId, setting);
      }

      print('CommunityNotifier: Cached ${settings.length} settings');
    } catch (e) {
      print('CommunityNotifier: Cache error: $e');
    }
  }

  /// Update fork brand filter
  void setForkBrandFilter(String? brand) {
    state = state.copyWith(selectedForkBrand: brand);
  }

  /// Update shock brand filter
  void setShockBrandFilter(String? brand) {
    state = state.copyWith(selectedShockBrand: brand);
  }

  /// Update search query
  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update sort method
  void setSortBy(CommunitySortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.clearFilters();
  }

  /// Import a setting (creates a local copy)
  /// Returns the ID of the newly created setting
  Future<String> importSetting(
    CommunitySetting communitySetting,
    String newSettingName,
    String bikeId,
  ) async {
    try {
      final viewModel = ref.read(settingsListViewModelProvider.notifier);
      await viewModel.importCommunitySetting(
        communitySetting: communitySetting,
        newName: newSettingName,
        bikeId: bikeId,
      );

      // For now, just increment the import count
      await _incrementImportCount(communitySetting.settingId);

      return communitySetting.settingId; // Placeholder
    } catch (e) {
      print('CommunityNotifier: Import error: $e');
      rethrow;
    }
  }

  /// Increment view count when user views a setting
  Future<void> incrementViewCount(String settingId) async {
    try {
      await FirebaseFirestore.instance.collection('community_settings').doc(settingId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('CommunityNotifier: View count error: $e');
      // Silently fail - not critical
    }
  }

  /// Increment import count (called when user imports)
  Future<void> _incrementImportCount(String settingId) async {
    try {
      await FirebaseFirestore.instance.collection('community_settings').doc(settingId).update({
        'imports': FieldValue.increment(1),
      });

      // Update local cache
      final box = await Hive.openBox<CommunitySetting>(_hiveBoxName);
      final cached = box.get(settingId);
      if (cached != null) {
        final updated = cached.copyWith(imports: cached.imports + 1);
        await box.put(settingId, updated);
      }
    } catch (e) {
      print('CommunityNotifier: Import count error: $e');
      // Don't fail the import if this fails
    }
  }

  /// Upvote a setting (Pro feature - will be implemented in Phase 2)
  Future<void> upvoteSetting(String settingId) async {
    // TODO: Implement in Phase 2 (Pro features)
    throw UnimplementedError('Upvoting is a Pro feature (Phase 2)');
  }

  /// Downvote a setting (Pro feature - will be implemented in Phase 2)
  Future<void> downvoteSetting(String settingId) async {
    // TODO: Implement in Phase 2 (Pro features)
    throw UnimplementedError('Downvoting is a Pro feature (Phase 2)');
  }

  /// Share a user's setting to community (Pro feature - Phase 2)
  Future<void> shareSettingToCommunity(String settingId) async {
    // TODO: Implement in Phase 2 (Pro features)
    throw UnimplementedError('Sharing is a Pro feature (Phase 2)');
  }

  /// Clear expired cache
  Future<void> clearExpiredCache() async {
    try {
      final box = await Hive.openBox<CommunitySetting>(_hiveBoxName);
      final now = DateTime.now();

      final toRemove = <String>[];
      for (final setting in box.values) {
        final age = now.difference(setting.created);
        if (age.inHours > _cacheExpiryHours) {
          toRemove.add(setting.settingId);
        }
      }

      for (final id in toRemove) {
        await box.delete(id);
      }

      if (toRemove.isNotEmpty) {
        print('CommunityNotifier: Cleared ${toRemove.length} expired entries');
      }
    } catch (e) {
      print('CommunityNotifier: Cache cleanup error: $e');
    }
  }

  /// Search all settings in Firebase (Pro feature)
  /// Searches beyond the cached top 100 settings
  Future<List<CommunitySetting>> searchAllSettings(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // Split query into individual words for multi-term search
      final words = query.toLowerCase().split(' ').where((w) => w.isNotEmpty).toList();

      // Fetch all settings from Firebase (not just top 100)
      // Note: In production, you may want to add pagination or a reasonable limit
      final snapshot = await FirebaseFirestore.instance
          .collection('community_settings')
          .orderBy('imports', descending: true)
          .limit(500) // Search top 500 settings (more than the cached 100)
          .get();

      final allSettings = snapshot.docs.map((doc) => CommunitySetting.fromFirestore(doc)).toList();

      // Apply the same multi-word search logic as local search
      final filtered = allSettings.where((s) {
        final searchableText = [
          s.userName,
          s.bikeMake ?? '',
          s.bikeModel ?? '',
          s.fork?.brand ?? '',
          s.fork?.model ?? '',
          s.shock?.brand ?? '',
          s.shock?.model ?? '',
          s.notes ?? '',
          s.location?.name ?? '',
          s.location?.trailType ?? '',
        ].join(' ').toLowerCase();

        // Check if ALL words appear somewhere in the searchable text
        return words.every((word) => searchableText.contains(word));
      }).toList();

      print('CommunityNotifier: Firebase search found ${filtered.length} results for "$query"');
      return filtered;
    } catch (e) {
      print('CommunityNotifier: Firebase search error: $e');
      rethrow;
    }
  }
}
