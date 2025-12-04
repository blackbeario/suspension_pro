import 'package:ridemetrx/features/community/domain/models/community_setting.dart';

/// UI state for the Community browser
/// Manages loading, error, and data states
class CommunityState {
  final List<CommunitySetting> settings;
  final bool isLoading;
  final String? error;
  final String? selectedForkBrand;
  final String? selectedShockBrand;
  final String? searchQuery;
  final CommunitySortBy sortBy;
  final bool isOfflineCache; // True if viewing cached data

  const CommunityState({
    this.settings = const [],
    this.isLoading = false,
    this.error,
    this.selectedForkBrand,
    this.selectedShockBrand,
    this.searchQuery,
    this.sortBy = CommunitySortBy.mostImports,
    this.isOfflineCache = false,
  });

  /// Create initial state
  factory CommunityState.initial() {
    return const CommunityState();
  }

  /// Create loading state
  CommunityState copyWithLoading() {
    return CommunityState(
      settings: settings,
      isLoading: true,
      error: null,
      selectedForkBrand: selectedForkBrand,
      selectedShockBrand: selectedShockBrand,
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
  }

  /// Create error state
  CommunityState copyWithError(String error) {
    return CommunityState(
      settings: settings,
      isLoading: false,
      error: error,
      selectedForkBrand: selectedForkBrand,
      selectedShockBrand: selectedShockBrand,
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
  }

  /// Create success state with data
  CommunityState copyWithData(List<CommunitySetting> settings, {bool isOfflineCache = false}) {
    return CommunityState(
      settings: settings,
      isLoading: false,
      error: null,
      selectedForkBrand: selectedForkBrand,
      selectedShockBrand: selectedShockBrand,
      searchQuery: searchQuery,
      sortBy: sortBy,
      isOfflineCache: isOfflineCache,
    );
  }

  /// Update filters
  CommunityState copyWith({
    List<CommunitySetting>? settings,
    bool? isLoading,
    String? error,
    Object? selectedForkBrand = _undefined,
    Object? selectedShockBrand = _undefined,
    Object? searchQuery = _undefined,
    CommunitySortBy? sortBy,
    bool? isOfflineCache,
  }) {
    return CommunityState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedForkBrand: selectedForkBrand == _undefined
          ? this.selectedForkBrand
          : selectedForkBrand as String?,
      selectedShockBrand: selectedShockBrand == _undefined
          ? this.selectedShockBrand
          : selectedShockBrand as String?,
      searchQuery: searchQuery == _undefined
          ? this.searchQuery
          : searchQuery as String?,
      sortBy: sortBy ?? this.sortBy,
      isOfflineCache: isOfflineCache ?? this.isOfflineCache,
    );
  }

  static const _undefined = Object();

  /// Clear all filters
  CommunityState clearFilters() {
    return CommunityState(
      settings: settings,
      isLoading: isLoading,
      error: error,
      selectedForkBrand: null,
      selectedShockBrand: null,
      searchQuery: null,
      sortBy: sortBy,
    );
  }

  /// Get filtered settings based on current filters
  List<CommunitySetting> get filteredSettings {
    var filtered = settings.toList();

    // Apply fork brand filter
    if (selectedForkBrand != null) {
      filtered = filtered
          .where((s) => s.fork?.brand == selectedForkBrand)
          .toList();
    }

    // Apply shock brand filter
    if (selectedShockBrand != null) {
      filtered = filtered
          .where((s) => s.shock?.brand == selectedShockBrand)
          .toList();
    }

    // Apply search query (multi-word search)
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();

      // Split query into words for multi-term search
      // e.g., "Norco DPX2" -> ["norco", "dpx2"]
      final words = query.split(' ').where((w) => w.isNotEmpty).toList();

      filtered = filtered.where((s) {
        // Combine all searchable fields into one string
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
    }

    // Apply sorting
    switch (sortBy) {
      case CommunitySortBy.mostImports:
        filtered.sort((a, b) => b.imports.compareTo(a.imports));
        break;
      case CommunitySortBy.mostUpvotes:
        filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
      case CommunitySortBy.newest:
        filtered.sort((a, b) => b.created.compareTo(a.created));
        break;
      case CommunitySortBy.mostViewed:
        filtered.sort((a, b) => b.views.compareTo(a.views));
        break;
    }

    return filtered;
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return selectedForkBrand != null ||
        selectedShockBrand != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }

  /// Get unique fork brands from settings
  List<String> get availableForkBrands {
    return settings
        .where((s) => s.fork != null)
        .map((s) => s.fork!.brand)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get unique shock brands from settings
  List<String> get availableShockBrands {
    return settings
        .where((s) => s.shock != null)
        .map((s) => s.shock!.brand)
        .toSet()
        .toList()
      ..sort();
  }
}

/// Sort options for community settings
enum CommunitySortBy {
  mostImports,
  mostUpvotes,
  newest,
  mostViewed,
}

extension CommunitySortByExtension on CommunitySortBy {
  String get displayName {
    switch (this) {
      case CommunitySortBy.mostImports:
        return 'Most Imported';
      case CommunitySortBy.mostUpvotes:
        return 'Most Upvoted';
      case CommunitySortBy.newest:
        return 'Newest';
      case CommunitySortBy.mostViewed:
        return 'Most Viewed';
    }
  }

  String get icon {
    switch (this) {
      case CommunitySortBy.mostImports:
        return '📥';
      case CommunitySortBy.mostUpvotes:
        return '👍';
      case CommunitySortBy.newest:
        return '🆕';
      case CommunitySortBy.mostViewed:
        return '👁';
    }
  }
}
