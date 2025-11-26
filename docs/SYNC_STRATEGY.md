# Suspension Pro - Sync & Monetization Strategy

**Date:** 2025-11-23
**Status:** Planning Phase - Ready for Implementation

---

## 📋 Executive Summary

This document outlines the strategic direction and technical implementation plan for Suspension Pro's data synchronization and monetization strategy.

### Key Decisions Made:
1. **Implement paid cloud sync** as part of a Pro tier subscription
2. **Keep free tier fully functional** with Hive-only (local) storage
3. **Deprecate or reframe AI features** (ChatGPT-based predictions are unreliable)
4. **Focus on data persistence & history** as core value proposition
5. **Build toward community database** for shared settings (future feature)

---

## 🎯 Current State Analysis

### What Works Now:
- ✅ **Offline-first architecture** - Hive stores bikes and settings locally
- ✅ **Firebase → Hive sync** - Online data automatically syncs down to local storage
- ✅ **Settings always read from Hive** - UI displays local data (offline-capable)
- ✅ **Share feature exists** - Settings can be shared via email/text

### What's Missing:
- ❌ **Hive → Firebase sync** - Offline changes don't push to cloud on reconnect
- ❌ **Dirty data tracking** - No way to know which Hive records were modified offline
- ❌ **Reconnection listener** - App doesn't trigger sync when connectivity restored
- ❌ **Subscription/paywall logic** - No IAP subscription tier (only AI consumables)

### Critical Code Evidence:

**Settings Read from Hive Only:**
```dart
// lib/features/bikes/presentation/screens/settings_list.dart:33-36
getSettings() async {
  settings = await _getBikeSettingsFromHive(widget.bike.id);
  setState(() {});
}
```

**Firebase → Hive Sync (One-Way):**
```dart
// lib/features/bikes/domain/bikes_notifier.dart:34-38
bikesStreamAsync.when(
  data: (bikes) {
    for (var bike in bikes) {
      HiveService().putIntoBox('bikes', bike.id, bike, false);
      _syncBikeSettings(bike.id);
    }
  },
  // ...
);
```

**Offline Updates Don't Sync:**
```dart
// lib/core/services/db_service.dart:158-174
if (await ConnectivityWrapper.instance.isConnected) {
  // Updates Firebase
} else {
  // TODO: Add to workmanager background tasks
  debugPrint('offline - try later');
}
```

**Hive Won't Overwrite Local Changes:**
```dart
// lib/core/services/hive_service.dart:26-28
if (!box.containsKey(key) || overwrite) {
  await box.put(key, object);
}
```

---

## 💰 Monetization Strategy

### Free Tier (Hive-Only)
**What Users Get:**
- Unlimited local bike/settings storage
- Manual settings entry and editing
- Basic manufacturer baseline settings
- All core features (bikes, forks, shocks, settings)
- Manual export/import for backup (JSON files)

**Limitations:**
- No cloud sync (single device only)
- No settings history/comparison
- No maintenance tracking
- No community database access
- Photos stored locally only

### Pro Tier ($3.99/month or $24.99/year)
**Premium Features:**
- ☁️ **Cloud sync** across unlimited devices
- 📊 **Settings history** - Compare changes over time
- 🔧 **Maintenance tracking** - Service reminders, hour tracking
- 📷 **Cloud photo storage** - Bike images synced via Firebase Storage
- 🗺️ **Location-tagged settings** - GPS-tagged for trail-specific setups
- 🌐 **Community database access** - Browse/search shared settings
- ✅ **Priority support**

### AI Features (Separate/Optional)
**Current Status:** Exists but unreliable
**Recommendation:** Deprecate or reframe as "experimental"

**Options:**
1. **Remove entirely** - Focus on proven features
2. **Keep as bonus** - Include in Pro tier with lowered expectations
3. **Consumable add-on** - $0.99 for 10 queries, marketed as "quick starter tool"

**Why AI Doesn't Work:**
- No training data (no massive dataset of perfect suspension settings)
- ChatGPT hallucinates confident-sounding but inconsistent answers
- Too many variables (terrain, skill, preference, conditions)
- Users will discover inconsistency and lose trust

---

## 🏗️ Technical Architecture Plan

### Phase 1: Bi-Directional Sync (IMMEDIATE PRIORITY)

**Goal:** Implement Hive → Firebase sync when connectivity restored

**Components Needed:**

#### 1.1 Dirty Data Tracking
Add metadata to Hive models to track offline modifications:

```dart
// Add to Bike, Setting, Fork, Shock models
@HiveField(X)
DateTime? lastModified;

@HiveField(Y)
bool isDirty; // true if modified while offline
```

#### 1.2 Connectivity Listener
Listen for connectivity changes and trigger sync:

```dart
// In ConnectivityNotifier or new SyncService
ref.listen(connectivityNotifierProvider, (previous, current) {
  if (previous == false && current == true) {
    // Just came back online
    _syncDirtyData();
  }
});
```

#### 1.3 Sync Service
Create dedicated service to push dirty Hive data to Firebase:

```dart
class SyncService {
  Future<void> syncDirtyBikes() async {
    final box = Hive.box<Bike>('bikes');
    final dirtyBikes = box.values.where((b) => b.isDirty);

    for (final bike in dirtyBikes) {
      await _db.addUpdateBike(bike);
      bike.isDirty = false;
      await box.put(bike.id, bike);
    }
  }

  Future<void> syncDirtySettings() async {
    final box = Hive.box<Setting>('settings');
    final dirtySettings = box.values.where((s) => s.isDirty);

    for (final setting in dirtySettings) {
      await _db.updateSetting(setting);
      setting.isDirty = false;
      await box.put('${setting.bike}-${setting.id}', setting);
    }
  }
}
```

#### 1.4 Mark Data as Dirty on Offline Edits
Update `HiveService.putIntoBox()` and direct Hive writes:

```dart
void putIntoBox<T>(String boxName, String key, T object, bool overwrite) async {
  final box = await Hive.box<T>(boxName);

  // Mark as dirty if offline
  if (object is Bike || object is Setting) {
    object.isDirty = !(await ConnectivityWrapper.instance.isConnected);
    object.lastModified = DateTime.now();
  }

  if (!box.containsKey(key) || overwrite) {
    await box.put(key, object);
  }
}
```

**Files to Modify:**
- `lib/features/bikes/domain/models/bike.dart` - Add dirty tracking fields
- `lib/features/bikes/domain/models/setting.dart` - Add dirty tracking fields
- `lib/core/services/hive_service.dart` - Mark data as dirty
- `lib/core/services/sync_service.dart` - **NEW FILE** - Sync logic
- `lib/features/connectivity/domain/connectivity_notifier.dart` - Trigger sync on reconnect

**Testing Strategy:**
1. Create bike/setting while offline
2. Verify `isDirty = true` in Hive
3. Restore connectivity
4. Verify data appears in Firebase
5. Verify `isDirty = false` after sync

---

### Phase 2: Subscription & Paywall (NEXT PRIORITY)

**Goal:** Implement Pro tier subscription with IAP

**Components Needed:**

#### 2.1 Subscription State Management
Create Riverpod provider to track subscription status:

```dart
@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionState build() {
    _checkSubscriptionStatus();
    return SubscriptionState.free;
  }

  Future<void> _checkSubscriptionStatus() async {
    // Query InAppPurchase for active subscription
    // Update state to .pro or .free
  }
}

enum SubscriptionState {
  free,
  pro,
  loading,
}
```

#### 2.2 Paywall UI Components
Create reusable paywall widget:

```dart
class ProFeatureGate extends ConsumerWidget {
  final Widget child;
  final String featureName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionNotifierProvider);

    if (subState == SubscriptionState.pro) {
      return child;
    }

    return PaywallScreen(featureName: featureName);
  }
}
```

#### 2.3 Conditional Sync Behavior
Only sync to cloud for Pro users:

```dart
Future<void> syncDirtyData() async {
  final subState = ref.read(subscriptionNotifierProvider);

  if (subState != SubscriptionState.pro) {
    debugPrint('Sync requires Pro subscription');
    return;
  }

  await _syncDirtyBikes();
  await _syncDirtySettings();
}
```

**Files to Create:**
- `lib/features/purchases/domain/subscription_notifier.dart` - Subscription state
- `lib/features/purchases/presentation/widgets/paywall_screen.dart` - Paywall UI
- `lib/features/purchases/presentation/widgets/pro_feature_gate.dart` - Wrapper widget

**Files to Modify:**
- `lib/core/services/sync_service.dart` - Check subscription before sync
- `lib/features/bikes/presentation/screens/bikes_list_screen.dart` - Show Pro badge/upsell
- `pubspec.yaml` - May need RevenueCat or Purchases SDK

---

### Phase 3: Settings History & Comparison (FUTURE)

**Goal:** Track and visualize setting changes over time

**Data Structure:**
```dart
class SettingHistory {
  final String id;
  final String settingId;
  final String bikeId;
  final DateTime timestamp;
  final ComponentSetting fork;
  final ComponentSetting shock;
  final String? location;
  final String? notes;
}
```

**Features:**
- Timeline view of all changes to a setting
- Side-by-side comparison ("Before vs After")
- Chart showing LSC/HSC/LSR/HSR trends over time
- Location tags from GPS ("Moab settings" vs "Home trails")

---

### Phase 4: Maintenance Tracking (FUTURE)

**Goal:** Remind users when suspension service is due

**Data Structure:**
```dart
class MaintenanceRecord {
  final String id;
  final String bikeId;
  final String component; // 'fork' or 'shock'
  final ServiceType type; // lowerLeg, airCan, fullRebuild
  final DateTime date;
  final double cost;
  final String? notes;
  final int hoursAtService;
}

class ComponentUsage {
  final String bikeId;
  final String component;
  final int totalHours;
  final DateTime lastService;
  final ServiceType lastServiceType;

  // Calculated properties
  int get hoursSinceService => totalHours - hoursAtLastService;
  bool get lowerLegDue => hoursSinceService >= 50;
  bool get airCanDue => hoursSinceService >= 100;
}
```

**Features:**
- Manual hour tracking or Strava integration
- Service reminders (push notifications)
- Service cost tracking
- Resale value (proof of maintenance)

---

### Phase 5: Community Database (FUTURE)

**Goal:** Shared settings repository searchable by trail/location/components

**Firebase Structure:**
```
/community_settings/
  /{setting_id}/
    userId: "abc123"
    bikeComponents: {
      fork: "2023 Fox 38 Factory"
      shock: "2023 Fox DHX2"
    }
    location: {
      geohash: "9q8yy"  // For proximity queries
      name: "Whistler Bike Park"
      coordinates: { lat: 50.1163, lng: -122.9574 }
    }
    trailType: "bike_park"
    riderWeight: 180
    settings: {
      fork: { LSC: 12, HSC: 10, LSR: 8, HSR: 6, springRate: 0.9 }
      shock: { LSC: 8, HSC: 5, LSR: 10, HSR: 8, springRate: 450 }
    }
    upvotes: 42
    downvotes: 3
    created: timestamp
```

**Query Methods:**
1. **GPS Proximity:** "Settings used within 5 miles"
2. **Trail Name:** Search by user-entered trail name
3. **Trail Type:** Filter by DH / Enduro / XC / Park
4. **Component Match:** "Other 2023 Fox 38 users"

**Features:**
- Share to community (replaces email share)
- Browse by location (map view)
- Vote on settings (quality filter)
- Reputation system (trusted contributors)

**Integration with Existing Share Feature:**
Current: Generate text with settings → share via email/SMS
New: Add button "Share to Community" → uploads to Firestore

---

## 🚀 Implementation Roadmap

### Immediate Next Steps (This Week)
1. ✅ Document current state (this file)
2. ⬜ Add dirty tracking fields to Bike/Setting models
3. ⬜ Update Hive adapters (run build_runner)
4. ⬜ Create SyncService with dirty data sync logic
5. ⬜ Add connectivity listener to trigger sync
6. ⬜ Test offline → online sync flow

### Short Term (Next 2-4 Weeks)
1. ⬜ Implement subscription state management
2. ⬜ Build paywall UI components
3. ⬜ Add subscription check to sync service
4. ⬜ Configure IAP products in App Store / Play Store
5. ⬜ Test free tier vs Pro tier behavior

### Medium Term (1-2 Months)
1. ⬜ Settings history tracking
2. ⬜ Comparison UI (before/after views)
3. ⬜ Location tagging (GPS integration)
4. ⬜ Polish Pro tier onboarding

### Long Term (3-6 Months)
1. ⬜ Maintenance tracking system
2. ⬜ Service reminders (push notifications)
3. ⬜ Community database MVP
4. ⬜ Map-based settings discovery

---

## 🔧 Key Technical Considerations

### Conflict Resolution Strategy
**Scenario:** User modifies same setting on two devices while offline

**Approach:** Last-write-wins (simplest)
- Use `lastModified` timestamp
- Most recent change overwrites older
- No merge conflict UI (too complex for MVP)

**Future:** Could add manual conflict resolution UI if users request it

### Data Migration Plan
**Challenge:** Existing users have Hive data without dirty tracking fields

**Solution:**
1. Add fields with default values (`isDirty = false`, `lastModified = null`)
2. Run one-time migration on app startup to set `lastModified = DateTime.now()`
3. Hive adapters will handle missing fields gracefully

### Subscription Grace Period
**Challenge:** User's subscription expires mid-ride (offline)

**Solution:**
- Cache subscription status in Hive
- Use 7-day grace period before disabling Pro features
- Allow viewing synced data even after expiration (no new syncs)

### Free Tier Data Retention
**Challenge:** User downgrades from Pro to Free

**Solution:**
- Keep all data in Hive (don't delete)
- Stop syncing to Firebase (no new cloud saves)
- Offer one-time manual export (JSON backup)
- Re-enable sync if they re-subscribe

---

## 📂 File Structure Overview

```
lib/
├── features/
│   ├── bikes/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── bike.dart (ADD: isDirty, lastModified)
│   │   │   │   ├── setting.dart (ADD: isDirty, lastModified)
│   │   │   │   ├── fork.dart (ADD: isDirty, lastModified)
│   │   │   │   └── shock.dart (ADD: isDirty, lastModified)
│   │   │   └── bikes_notifier.dart (MODIFY: use SyncService)
│   │   └── presentation/
│   │       └── screens/
│   │           └── bikes_list_screen.dart (ADD: Pro upsell UI)
│   ├── connectivity/
│   │   ├── domain/
│   │   │   └── connectivity_notifier.dart (MODIFY: trigger sync)
│   │   └── presentation/
│   │       └── widgets/
│   │           └── connectivity_widget_wrapper.dart (MODIFY: show sync status)
│   └── purchases/
│       ├── domain/
│       │   └── subscription_notifier.dart (NEW: Pro tier state)
│       └── presentation/
│           ├── screens/
│           │   └── paywall_screen.dart (NEW: subscription UI)
│           └── widgets/
│               └── pro_feature_gate.dart (NEW: paywall wrapper)
├── core/
│   ├── services/
│   │   ├── sync_service.dart (NEW: dirty data sync logic)
│   │   ├── hive_service.dart (MODIFY: mark dirty on write)
│   │   └── db_service.dart (MODIFY: remove TODO, use SyncService)
│   └── providers/
│       └── service_providers.dart (ADD: syncServiceProvider)
└── SYNC_STRATEGY.md (THIS FILE)
```

---

## 🧪 Testing Checklist

### Sync Testing
- [ ] Create bike while offline → comes online → appears in Firebase
- [ ] Edit setting while offline → comes online → updates in Firebase
- [ ] Delete bike while offline → comes online → deletes from Firebase
- [ ] Modify same setting on two devices offline → last write wins
- [ ] Airplane mode → make changes → disable airplane mode → auto-sync

### Subscription Testing
- [ ] Free user tries to access Pro feature → sees paywall
- [ ] Purchase subscription → Pro features unlock immediately
- [ ] Subscription expires → reverts to Free tier gracefully
- [ ] Restore purchases → Pro features re-enable

### Edge Cases
- [ ] Poor connectivity (spotty signal) → retries sync
- [ ] Sync fails → shows error, marks data still dirty
- [ ] App force-quit during sync → resumes on next launch
- [ ] Large dataset (100+ bikes/settings) → syncs efficiently

---

## 💬 Open Questions / Future Decisions

### To Decide Later:
1. **Subscription pricing:** $3.99/mo vs $24.99/yr vs different tiers?
2. **AI feature fate:** Remove entirely or keep as Pro bonus?
3. **Community database moderation:** How to handle spam/bad data?
4. **Strava integration:** Worth the API complexity for hour tracking?
5. **Platform priority:** iOS first, then Android? Or simultaneous?

### User Research Needed:
1. Would users pay $25/year for cloud sync + history?
2. Is maintenance tracking valuable enough to drive subscriptions?
3. Do riders actually use multiple devices (phone + tablet)?
4. Would community database see adoption (network effects)?

---

## 📞 Contact / Handoff Notes

**For Next Claude Session:**

Use this prompt to resume:

```
I'm working on Suspension Pro, a Flutter app for mountain bike suspension settings.
We've been discussing implementing bi-directional Hive ↔ Firebase sync and a paid
subscription model.

Please read SYNC_STRATEGY.md in the project root for full context, then help me
implement Phase 1 (dirty data tracking and sync service).

Current branch: mvvm_refactor_claude
Recent work: Fixed ConnectivityWidgetWrapper to use Riverpod instead of Provider
```

**Key Context Files:**
- This file: `/Users/jfraz/Sites/suspension_pro/SYNC_STRATEGY.md`
- Bikes data flow: `lib/features/bikes/domain/bikes_notifier.dart`
- Settings UI: `lib/features/bikes/presentation/screens/settings_list.dart`
- Database service: `lib/core/services/db_service.dart`
- Hive service: `lib/core/services/hive_service.dart`

**Branch:** `mvvm_refactor_claude`
**Last Commit:** 923047c (Test claude refactor for mvvm pattern)

---

## 📚 Additional Resources

### Firebase Queries for Community Database
- [Geohash for proximity queries](https://firebase.google.com/docs/firestore/solutions/geoqueries)
- [Compound indexes for multi-field queries](https://firebase.google.com/docs/firestore/query-data/indexing)

### Subscription Management
- [RevenueCat](https://www.revenuecat.com/) - Simplifies cross-platform IAP
- [in_app_purchase](https://pub.dev/packages/in_app_purchase) - Already using this

### Offline-First Patterns
- [Hive best practices](https://docs.hivedb.dev/#/)
- [Optimistic UI updates](https://www.apollographql.com/docs/react/performance/optimistic-ui/)

---

**Document Version:** 1.0
**Last Updated:** 2025-11-23
**Author:** Strategic planning session with Claude (Sonnet 4.5)
