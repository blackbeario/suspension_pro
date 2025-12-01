# RideMetrx - Sync & Monetization Strategy

**Date:** 2025-11-26 (Updated after rebrand)
**Status:** Ready for Phase 2 Implementation

---

## 📋 Executive Summary

This document outlines the strategic direction and technical implementation plan for RideMetrx's data synchronization and monetization strategy.

### Key Decisions Made:
1. **✅ COMPLETED: Rebranded to RideMetrx** - New bundle IDs, updated branding
2. **✅ COMPLETED: Removed AI features** - ChatGPT-based predictions were unreliable
3. **✅ COMPLETED: Updated IAP to subscriptions** - Pro tier pricing model
4. **Implement paid cloud sync** as part of Pro tier subscription
5. **Keep free tier fully functional** with Hive-only (unlimited bikes/settings)
6. **Community database (free)** for shared settings
7. **Maintenance tracking (free)** with manual entry
8. **Metrx feature (Pro)** - Roughness detection using accelerometer + GPS

---

## 🎯 Current State (Post-Rebrand)

### ✅ What's Been Completed:
- **App rebranded to RideMetrx** (`io.vibesoftware.ridemetrx`)
- **AI features removed** - Replaced with Community placeholder
- **Email/text sharing removed** - Will be replaced with Community sharing
- **Subscription model implemented** - Pro monthly ($2.99) & annual ($29.99)
- **Free tier established** - Unlimited bikes + settings (Hive-only)

### What Works Now:
- ✅ **Offline-first architecture** - Hive stores bikes and settings locally
- ✅ **Firebase → Hive sync** - Online data automatically syncs down to local storage
- ✅ **Settings always read from Hive** - UI displays local data (offline-capable)
- ✅ **Unlimited bikes/settings** - No artificial limits on free tier

### What's Still Missing:
- ❌ **Hive → Firebase sync** - Offline changes don't push to cloud on reconnect
- ❌ **Subscription paywall UI** - No UI to gate Pro features
- ❌ **Metrx feature** - Accelerometer-based roughness detection
- ❌ **Community database** - Shared settings browsing/contribution
- ❌ **Maintenance reminders** - Push notifications for service due dates

---

## 💰 Final Monetization Strategy

### Free Tier ("RideMetrx")
**What makes it better than competitors:**
- ✅ **Unlimited bikes** (vs competitor's 1 bike limit)
- ✅ **Unlimited settings** (locally in Hive)
- ✅ Full offline functionality
- ✅ **Browse community database** (free tier can view shared settings)
- ✅ **Import community setups**
- ✅ **Full maintenance logging** (manual entry + notifications)
- ✅ Basic manufacturer baseline settings

**Limitations:**
- ❌ No cloud sync (single device only)
- ❌ No Metrx roughness detection
- ❌ No Strava integration
- ❌ Can't contribute to community with heatmap data
- ❌ No automatic maintenance hour tracking

---

### Pro Tier ($2.99/month or $29.99/year)
**Value Proposition:** *"Turn your phone into a $300 ShockWiz alternative"*

**Core Features:**
- ☁️ **Cloud sync** across unlimited devices
- 📊 **Metrx: Roughness Heatmap** - Record rides with accelerometer analysis
- 🔄 **A/B Testing** - Compare settings changes objectively
- 🗺️ **Trail Context** - Strava/Trailforks integration for trail names
- 📈 **Automatic hour tracking** (Strava sync)
- 🔔 **Service reminder push notifications**
- 🌐 **Contribute heatmap data to community**
- 📍 **GPS proximity search** in community database
- 📸 **Cloud photo storage** for bikes

**Subscription Product IDs:**
- Monthly: `com.ridemetrx.pro.monthly` ($2.99/month)
- Annual: `com.ridemetrx.pro.annual` ($29.99/year)

---

## 🏗️ Technical Architecture Plan

### ✅ Phase 1: Rebrand + Cleanup (COMPLETED)

**Commit 1: Rebrand to RideMetrx**
- ✅ Updated package name and bundle IDs
- ✅ Updated all import statements (179 files)
- ✅ Updated display names and UI strings
- ✅ Bumped version to 0.2.0+1

**Commit 2: Remove AI Features**
- ✅ Deleted `lib/features/ai` directory
- ✅ Removed chat_gpt_sdk dependency
- ✅ Replaced AI navigation with Community placeholder
- ✅ Updated bottom nav icon

**Commit 3: Remove Old Sharing**
- ✅ Replaced ShareButton with "Coming Soon" snackbar
- ✅ Removed share() function and share_plus dependency

**Commit 4: Update IAP to Subscriptions**
- ✅ Replaced credits system with SubscriptionStatus
- ✅ Added subscription product IDs
- ✅ Updated PurchaseNotifier for subscription management

---

### ✅ Phase 2: Bi-Directional Sync (COMPLETED)

**Goal:** ✅ Implement Hive → Firebase sync when connectivity restored

**Completed Components:**

#### 2.1 ✅ Dirty Data Tracking
- ✅ `bike.dart:25-28` - Added `lastModified` and `isDirty` fields
- ✅ `setting.dart:32-35` - Added `lastModified` and `isDirty` fields
- ✅ Both models track when modified and if they need Firebase sync

#### 2.2 ✅ Connectivity Listener
- ✅ `main.dart:80-87` - Listens to connectivity changes
- ✅ Triggers `syncDirtyData()` when going from offline → online

#### 2.3 ✅ Sync Service
- ✅ `lib/core/services/sync_service.dart` - Full implementation
- ✅ Checks Pro subscription status (only Pro users sync to cloud)
- ✅ Pushes dirty Hive records to Firebase
- ✅ Marks records as clean after successful sync
- ✅ Includes `forceSyncAll()` for manual sync

#### 2.4 ✅ Error Handling (Added 2025-11-29)
- ✅ `settings_notifier.dart:100-136` - Catches Firebase sync failures
- ✅ `bikeform.dart:97-120` - Catches Firebase sync failures
- ✅ Both mark data as `isDirty: true` when Firebase sync fails
- ✅ Data will auto-sync when connectivity is restored

**How It Works:**
1. User edits bike/setting (online or offline)
2. Data saves to Hive immediately (UI updates instantly)
3. Tries to sync to Firebase
4. **If sync fails** → marks as `isDirty: true` in Hive
5. When connectivity restored → `SyncService` finds dirty records and syncs them
6. After successful sync → marks as `isDirty: false`

---

### ✅ Phase 3: Subscription Paywall UI (COMPLETED)

**Goal:** ✅ Gate cloud sync behind Pro subscription

**Completed Components:**

#### 3.1 ✅ Paywall Screen
- ✅ `paywall_screen.dart` - Full paywall UI implementation
- ✅ Lists all Pro features (cloud sync, Metrx, Strava, etc.)
- ✅ Shows monthly ($2.99) vs annual ($29.99) pricing from RevenueCat
- ✅ "Restore Purchases" button
- ✅ "Maybe Later" dismissal
- ✅ Purchase flow with loading states and error handling

#### 3.2 ✅ Pro Feature Gate Widget
- ✅ `pro_feature_gate.dart` - ProFeatureGate widget
- ✅ Helper functions: `checkProFeature()` and `showProUpgradeSnackbar()`
- ✅ Can show paywall screen or snackbar notification

#### 3.3 ✅ Conditional Sync
- ✅ `sync_service.dart:22-29` - Checks Pro status before syncing
- ✅ Free users stay local-only (no cloud sync)
- ✅ Pro users get automatic bi-directional sync

---

### Phase 4: Metrx Feature (Accelerometer + GPS)

**Goal:** Roughness detection heatmaps (Pro tier feature)

See `METRX_FEATURE.md` for full technical details from Gemini conversation.

**Key Components:**
- Phone accelerometer data capture (50Hz+)
- GPS coordinate tracking
- Spatial binning (10m segments)
- RMS vibration calculation
- A/B comparison between runs
- Strava/Trailforks API for trail names

---

### Phase 5: Community Database

**Goal:** Shared settings repository (free to browse, Pro to contribute with heatmaps)

**Firebase Structure:**
```
/community_settings/
  /{setting_id}/
    userId: "abc123"
    bikeComponents: { fork: "2023 Fox 38", shock: "DHX2" }
    location: {
      geohash: "9q8yy"
      name: "Whistler Bike Park"
      coordinates: { lat, lng }
    }
    trailType: "bike_park"
    settings: { fork: {...}, shock: {...} }
    roughnessScore: 7.2  // Pro users only
    upvotes: 42
    created: timestamp
```

**Free Tier:** Browse, search, import settings
**Pro Tier:** Contribute with heatmap data, GPS search, higher vote weight

---

### Phase 6: Maintenance Tracking

**Goal:** Service reminders and hour tracking

**Free Tier:**
- Manual entry of service dates
- Local push notifications for service due
- Service cost tracking

**Pro Tier:**
- Auto hour tracking via Strava
- Cloud backup of maintenance history
- Advanced analytics

---

## 📂 Updated File Structure

```
lib/
├── features/
│   ├── bikes/           (existing - manages bikes & settings)
│   ├── auth/            (existing - Firebase auth)
│   ├── connectivity/    (existing - offline detection)
│   ├── purchases/       (✅ UPDATED - now subscription-based)
│   │   ├── domain/
│   │   │   ├── purchase_state.dart (NEW: SubscriptionStatus)
│   │   │   └── purchase_notifier.dart (NEW: subscription logic)
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── paywall_screen.dart (TODO)
│   │       │   └── buy_credits.dart (LEGACY - to be removed)
│   │       └── widgets/
│   │           └── pro_feature_gate.dart (TODO)
│   ├── metrx/           (TODO - roughness detection)
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── ride_session.dart
│   │   │   │   └── roughness_segment.dart
│   │   │   └── metrx_service.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── record_screen.dart
│   │           └── heatmap_viewer.dart
│   └── community/       (TODO - shared settings)
│       ├── domain/
│       │   └── community_service.dart
│       └── presentation/
│           └── screens/
│               ├── community_browser.dart
│               └── setting_detail.dart
├── core/
│   ├── services/
│   │   ├── sync_service.dart (TODO - dirty data sync)
│   │   ├── hive_service.dart (existing)
│   │   └── db_service.dart (existing)
│   └── routing/
│       └── app_router.dart (✅ UPDATED - Community placeholder)
└── docs/
    ├── SYNC_STRATEGY.md (THIS FILE)
    └── METRX_FEATURE.md (TODO - accelerometer details)
```

---

## 🚀 Implementation Roadmap

### ✅ Completed (2025-11-26 to 2025-11-29)
1. ✅ Document current state (this file)
2. ✅ Create `METRX_FEATURE.md` from Gemini conversation
3. ✅ Add dirty tracking fields to Bike/Setting models
4. ✅ Create SyncService with subscription check
5. ✅ Implement paywall UI
6. ✅ Gate cloud sync behind Pro check
7. ✅ Add error handling for offline sync failures
8. ✅ Test subscription purchase flow with RevenueCat test products

### Immediate Next Steps (This Week)
1. ⬜ **Decide: Metrx vs Community first?**
2. ⬜ Configure IAP in App Store / Play Store (production)
3. ⬜ Improve paywall UI design (current version is functional but basic)

### Medium Term (1-2 Months)
1. ⬜ Metrx feature MVP (accelerometer recording)
2. ⬜ A/B comparison UI
3. ⬜ Strava API integration for trail names
4. ⬜ Heatmap visualization

### Long Term (3-6 Months)
1. ⬜ Community database implementation
2. ⬜ Maintenance tracking with notifications
3. ⬜ Advanced Metrx analytics

---

## 🧪 Testing Checklist

### Sync Testing
- [ ] Create bike while offline → comes online → appears in Firebase (Pro only)
- [ ] Edit setting while offline → comes online → updates Firebase (Pro only)
- [ ] Free user tries to edit → stays in Hive only
- [ ] Subscription expires → sync stops, local data remains

### Subscription Testing
- [ ] Free user sees paywall when accessing Pro features
- [ ] Purchase monthly subscription → Pro features unlock
- [ ] Subscription expires → graceful degradation to Free tier
- [ ] Restore purchases → Pro features re-enable

### Edge Cases
- [ ] Poor connectivity → sync retries with backoff
- [ ] Sync fails → data marked dirty for retry
- [ ] Large dataset (100+ bikes) → syncs efficiently without timeout

---

## 💬 Open Questions

### Business Decisions:
1. Should we offer a free trial? (e.g., 7 days Pro for new users)
2. Lifetime purchase option? (e.g., $99.99 one-time)
3. Student discount pricing?

### Technical Decisions:
1. Sync conflict resolution: last-write-wins vs manual merge UI?
2. Sync frequency: immediate vs batched (every 5 minutes)?
3. Offline grace period: 7 days vs 30 days for expired subscriptions?

---

## 📞 Firebase Configuration Notes

**Project:** `suspension-pro` (keep existing Firebase project)

**Before Deployment:**
1. Download new `GoogleService-Info.plist` with bundle ID `io.vibesoftware.ridemetrx`
2. Download new `google-services.json` with package `io.vibesoftware.ridemetrx`
3. Update Firebase Console app registration
4. No need to change Firestore database or storage bucket

---

## 📚 Related Documentation

- `METRX_FEATURE.md` - Technical details on accelerometer-based roughness detection
- `lib/features/purchases/domain/purchase_notifier.dart` - Subscription implementation
- Gemini conversation PDF - Original Metrx feature planning

---

**Document Version:** 2.0 (Post-Rebrand)
**Last Updated:** 2025-11-26
**Author:** Strategic planning + implementation tracking
