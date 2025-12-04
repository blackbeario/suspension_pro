# Firebase Access: Free vs Pro Users

## Overview
This document explains how Firebase access is controlled for Free vs Pro users across the app.

## Core Principle
**Free users ONLY use Hive (local storage). Pro users sync with Firebase.**

## Implementation

### Bikes

**File**: [lib/features/bikes/domain/bikes_notifier.dart](lib/features/bikes/domain/bikes_notifier.dart)

#### bikesStream Provider (Lines 14-28)
```dart
@riverpod
Stream<List<Bike>> bikesStream(Ref ref) {
  // Only stream from Firebase if user is Pro
  final userState = ref.watch(userNotifierProvider);

  if (!userState.isPro) {
    // Free users: return empty stream (use Hive only)
    return Stream.value([]);
  }

  // Pro users: stream from Firebase
  final db = ref.watch(databaseServiceProvider);
  return db.streamBikes();
}
```

**How it works**:
- Checks `userState.isPro` on every call
- Free users: Returns empty stream → No Firebase reads
- Pro users: Returns Firebase stream → Real-time sync

#### BikesNotifier.build() (Lines 33-77)
```dart
@override
BikesState build() {
  // IMPORTANT: Load bikes from Hive immediately on initialization
  // This ensures bikes are available right away for import dialogs, etc.
  final initialBikes = _getBikesFromHive();

  // Listen to bikes stream and smart-merge with Hive
  ref.listen(bikesStreamProvider, ...);

  // Return initial state with bikes from Hive
  return BikesState(bikes: initialBikes);
}
```

**Key changes**:
1. **Loads bikes from Hive immediately** on initialization
2. Listens to `bikesStreamProvider` (which returns empty stream for free users)
3. Free users: Stream emits empty array → No Firebase sync
4. Pro users: Stream emits Firebase data → Smart merge into Hive

**Result**:
- ✅ Free users: Hive-only, no Firebase reads/writes
- ✅ Pro users: Hive + Firebase sync
- ✅ Import dialog works immediately for both (bikes loaded from Hive)

### Settings

**File**: [lib/features/bikes/domain/settings_notifier.dart](lib/features/bikes/domain/settings_notifier.dart)

#### settingsStream Provider (Lines 14-24)
```dart
@riverpod
Stream<List<Setting>> settingsStream(Ref ref, String bikeId) {
  final isPro = ref.watch(purchaseNotifierProvider).isPro;

  if (!isPro) {
    // Free users: return empty stream, no Firebase access
    return Stream.value([]);
  }

  final db = ref.watch(databaseServiceProvider);
  return db.streamSettings(bikeId);
}
```

**Same pattern as bikes**: Free users get empty stream, Pro users get Firebase stream.

### Community Settings

**File**: [lib/features/community/domain/community_notifier.dart](lib/features/community/domain/community_notifier.dart)

Community settings work differently because they're **read-only** for all users:

#### Free Users
- **Cache**: Top 100 most-imported settings (cached in Hive)
- **Search**: Local search within cached 100 settings
- **Cost**: 1 Firebase read on app launch (fetches top 100)

#### Pro Users
- **Cache**: Same top 100 cached locally
- **Search**: Can trigger `searchAllSettings()` to query Firebase for top 500
- **Cost**: 1 read on launch + optional Firebase searches

**Pro Search Feature** (Lines 228-274):
```dart
Future<List<CommunitySetting>> searchAllSettings(String query) async {
  // Pro feature: Search beyond cached top 100
  final snapshot = await FirebaseFirestore.instance
      .collection('community_settings')
      .orderBy('imports', descending: true)
      .limit(500) // Search top 500 settings
      .get();

  // Apply multi-word search logic
  final filtered = allSettings.where((s) { ... }).toList();
  return filtered;
}
```

**UI prompts when search returns 0-2 results**:
- Free users: "Upgrade to search all settings" → Shows paywall
- Pro users: "Search All" button → Calls `searchAllSettings()`

## Firebase Cost Analysis

### Free Users
- **Bikes**: 0 reads (Hive only)
- **Settings**: 0 reads (Hive only)
- **Community**: 1 read on launch (top 100 cache)
- **Total**: ~1 read per app session

### Pro Users
- **Bikes**: Real-time stream (~1 read per change)
- **Settings**: Real-time stream per bike (~1 read per change per bike)
- **Community**: 1 read on launch + optional searches (~1 read per search)
- **Total**: Variable based on usage, estimated 5-20 reads per session

**Cost**: ~$0.10/month for 100 Pro users with moderate usage

## Future Considerations

### Sharing Settings to Community (Pro Feature - Phase 2)
When Pro users share their settings to community:
- Should increment `imports`/`views` counters
- Should NOT count against their Firebase quota (server-side write)
- Implement as Cloud Function to avoid client-side writes

### Offline Mode
Current implementation already supports offline:
- Free users: Always work (Hive-only)
- Pro users: Work offline (Hive), sync when online (Firebase)

### Subscription Expiry
When Pro subscription expires:
- `userState.isPro` → `false`
- Stream providers return empty streams
- User keeps local Hive data
- No more Firebase sync

**Important**: User doesn't lose their data! Hive persists locally.

## Testing Checklist

### Free Users
- [ ] Can create/edit/delete bikes (Hive only)
- [ ] Can create/edit/delete settings (Hive only)
- [ ] Import dialog shows bikes immediately
- [ ] Community browser works (top 100 cache)
- [ ] No Firebase streams active (check logs)
- [ ] No Firebase writes attempted

### Pro Users
- [ ] Bikes sync to/from Firebase
- [ ] Settings sync to/from Firebase
- [ ] Import dialog shows bikes immediately
- [ ] Community "Search All" button works
- [ ] Firebase streams active (check logs)
- [ ] Changes sync across devices

### Subscription Changes
- [ ] Upgrading Free → Pro: Firebase sync starts
- [ ] Downgrading Pro → Free: Firebase sync stops, Hive data persists
- [ ] No data loss on downgrade

## Migration Notes

### Existing Free Users
No migration needed - already using Hive-only mode.

### Existing Pro Users
No migration needed - Firebase sync continues working.

### New Users
Start as Free (Hive-only) by default, can upgrade to Pro (Firebase sync) anytime.
