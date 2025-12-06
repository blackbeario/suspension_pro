import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/community/domain/community_notifier.dart';
import 'package:ridemetrx/features/community/domain/models/community_setting.dart';
import 'package:ridemetrx/features/community/domain/models/community_state.dart';
import 'package:ridemetrx/features/community/presentation/widgets/setting_card.dart';
import 'package:ridemetrx/features/connectivity/domain/connectivity_notifier.dart';
import 'package:ridemetrx/features/purchases/presentation/screens/paywall_screen.dart';

/// Community Settings Browser Screen
/// Allows free users to browse, search, and import community settings
class CommunityBrowserScreen extends ConsumerStatefulWidget {
  const CommunityBrowserScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunityBrowserScreen> createState() => _CommunityBrowserScreenState();
}

class _CommunityBrowserScreenState extends ConsumerState<CommunityBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Firebase search state (Pro feature)
  bool _isSearchingFirebase = false;
  List<CommunitySetting>? _firebaseResults;

  // Quick filters expanded state
  bool _quickFiltersExpanded = false;

  @override
  void initState() {
    super.initState();
    // Fetch settings on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityNotifierProvider.notifier).fetchSettings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Search all settings in Firebase (Pro feature)
  Future<void> _searchAllSettingsInFirebase() async {
    // final userState = ref.read(userNotifierProvider);
    final query = _searchController.text;

    if (query.isEmpty) return;

    setState(() {
      _isSearchingFirebase = true;
    });

    try {
      final results = await ref.read(communityNotifierProvider.notifier).searchAllSettings(query);

      setState(() {
        _firebaseResults = results;
        _isSearchingFirebase = false;
      });

      // Show snackbar with results count
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${results.length} settings in full database'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSearchingFirebase = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show upgrade dialog for free users
  void _showUpgradeDialog() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('Upgrade to Pro'),
          ],
        ),
        content: Container(
          // color: Colors.yellow,
          child: const Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Free users can search the top 100 settings', style: TextStyle(fontSize: 11)),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('With a Pro subscription you can:'),
                  SizedBox(height: 8),
                  Text('• Search ALL community settings', textAlign: TextAlign.left),
                  Text('• Upvote and downvote settings', textAlign: TextAlign.left),
                  Text('• Share your settings and heatmaps', textAlign: TextAlign.left),
                  Text('• Access advanced filters and sorting', textAlign: TextAlign.left),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // go to paywall
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PaywallScreen(),
                ));
              },
              icon: const Icon(Icons.star),
              label: const Text('Upgrade Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Settings'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(communityNotifierProvider.notifier).fetchSettings();
            },
          ),
          // Filter menu
          PopupMenuButton<CommunitySortBy>(
            icon: const Icon(Icons.sort),
            onSelected: (sortBy) {
              ref.read(communityNotifierProvider.notifier).setSortBy(sortBy);
            },
            itemBuilder: (context) => CommunitySortBy.values.map((sortBy) {
              return PopupMenuItem(
                value: sortBy,
                child: Row(
                  children: [
                    Text(sortBy.icon),
                    const SizedBox(width: 8),
                    Text(sortBy.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(state),

          // Filter chips
          if (state.hasActiveFilters) _buildFilterChips(state),

          // Offline indicator banner
          if (!state.isLoading && state.error == null && state.settings.isNotEmpty) _buildOfflineIndicator(state),

          // Content area
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(CommunityState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by bike, user, components, location, or notes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(communityNotifierProvider.notifier).clearFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (query) {
              ref.read(communityNotifierProvider.notifier).setSearchQuery(query.isEmpty ? null : query);
            },
          ),
        ),
        // Quick filter chips
        if (state.settings.isNotEmpty) _buildQuickFilterChips(state),
      ],
    );
  }

  Widget _buildQuickFilterChips(CommunityState state) {
    final forkBrands = state.availableForkBrands.take(5).toList();
    final shockBrands = state.availableShockBrands.take(5).toList();

    if (forkBrands.isEmpty && shockBrands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _quickFiltersExpanded = !_quickFiltersExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _quickFiltersExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Filters',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filter by popular forks and shocks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible filter chips
          if (_quickFiltersExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (forkBrands.isNotEmpty) ...[
                    Text(
                      'Popular Forks',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: forkBrands.map((brand) {
                        final isSelected = state.selectedForkBrand == brand;
                        return ActionChip(
                          label: Text(brand),
                          backgroundColor: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          onPressed: () {
                            ref.read(communityNotifierProvider.notifier).setForkBrandFilter(
                                  isSelected ? null : brand,
                                );
                            setState(() {
                              _firebaseResults = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (shockBrands.isNotEmpty) const SizedBox(height: 16),
                  ],
                  if (shockBrands.isNotEmpty) ...[
                    Text(
                      'Popular Shocks',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: shockBrands.map((brand) {
                        final isSelected = state.selectedShockBrand == brand;
                        return ActionChip(
                          label: Text(brand),
                          backgroundColor: isSelected ? Colors.purple.shade100 : Colors.grey.shade100,
                          side: BorderSide(
                            color: isSelected ? Colors.purple : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          onPressed: () {
                            ref.read(communityNotifierProvider.notifier).setShockBrandFilter(
                                  isSelected ? null : brand,
                                );
                            setState(() {
                              _firebaseResults = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(CommunityState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Fork brand filter
          if (state.selectedForkBrand != null)
            _buildFilterChip(
              label: 'Fork: ${state.selectedForkBrand}',
              onDeleted: () {
                ref.read(communityNotifierProvider.notifier).setForkBrandFilter(null);
                setState(() {
                  _firebaseResults = null;
                });
              },
            ),

          // Shock brand filter
          if (state.selectedShockBrand != null)
            _buildFilterChip(
              label: 'Shock: ${state.selectedShockBrand}',
              onDeleted: () {
                ref.read(communityNotifierProvider.notifier).setShockBrandFilter(null);
                setState(() {
                  _firebaseResults = null;
                });
              },
            ),

          // Clear all button
          if (state.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ActionChip(
                label: const Text('Clear All'),
                onPressed: () {
                  _searchController.clear();
                  ref.read(communityNotifierProvider.notifier).clearFilters();
                  setState(() {
                    _firebaseResults = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 18),
      ),
    );
  }

  Widget _buildContent(CommunityState state) {
    if (state.isLoading && state.settings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(communityNotifierProvider.notifier).fetchSettings();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show Firebase results if available, otherwise show local filtered results
    final displaySettings = _firebaseResults ?? state.filteredSettings;
    final isShowingFirebaseResults = _firebaseResults != null;

    if (displaySettings.isEmpty && !_shouldShowSearchAllButton(state)) {
      // Only show empty state if we're NOT in a search scenario where Firebase might help
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              state.hasActiveFilters ? 'No settings match your filters' : 'No community settings available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            if (state.hasActiveFilters) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(communityNotifierProvider.notifier).clearFilters();
                  setState(() {
                    _firebaseResults = null;
                  });
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Show "Search All Settings" prompt when results are limited and user is searching
        if (_shouldShowSearchAllButton(state)) _buildSearchAllPrompt(),

        // Show Firebase results indicator
        if (isShowingFirebaseResults) _buildFirebaseResultsIndicator(displaySettings.length),

        // Results list or empty state with search prompt
        Expanded(
          child: _isSearchingFirebase
              ? const Center(child: CircularProgressIndicator())
              : displaySettings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No settings found in cache',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching the full database above',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(communityNotifierProvider.notifier).fetchSettings();
                        setState(() {
                          _firebaseResults = null;
                        });
                      },
                      child: ListView.builder(
                        itemCount: displaySettings.length,
                        itemBuilder: (context, index) {
                          final setting = displaySettings[index];
                          return SettingCard(setting: setting);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  /// Check if we should show the "Search All Settings" button
  bool _shouldShowSearchAllButton(CommunityState state) {
    // Show if:
    // 1. User is searching (has a search query)
    // 2. Results are limited (0-2 results) - could be more in full database
    // 3. Not already showing Firebase results
    // 4. Not currently searching Firebase
    return state.searchQuery != null &&
        state.searchQuery!.isNotEmpty &&
        state.filteredSettings.length <= 2 &&
        _firebaseResults == null &&
        !_isSearchingFirebase;
  }

  /// Build the "Search All Settings" prompt
  Widget _buildSearchAllPrompt() {
    final userState = ref.watch(userNotifierProvider);
    final isPro = userState.isPro;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPro ? [Colors.blue.shade50, Colors.blue.shade100] : [Colors.amber.shade50, Colors.amber.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPro ? Colors.blue.shade300 : Colors.amber.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPro ? Icons.search : Icons.star,
            color: isPro ? Colors.blue.shade700 : Colors.amber.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro ? 'Limited results in cache' : 'Search all settings?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isPro ? Colors.blue.shade900 : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPro ? 'Search the full database for more results' : 'Upgrade to Pro to search beyond top 100',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPro ? Colors.blue.shade700 : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: isPro ? _searchAllSettingsInFirebase : _showUpgradeDialog,
            icon: Icon(isPro ? Icons.search : Icons.star, size: 16),
            label: Text(isPro ? 'Search All' : 'Upgrade'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPro ? Colors.blue : Colors.amber,
              foregroundColor: isPro ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// Build indicator showing Firebase search results
  Widget _buildFirebaseResultsIndicator(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(
            Icons.cloud_done,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing $count results from full database',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _firebaseResults = null;
              });
            },
            child: Text(
              'Back to cache',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator(CommunityState state) {
    final isConnected = ref.watch(connectivityNotifierProvider);

    // Show banner when offline and have cached data
    if (isConnected || state.settings.isEmpty) {
      return const SizedBox.shrink();
    }

    final settingCount = state.settings.length;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline - Showing $settingCount cached settings. Connect for latest updates.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
