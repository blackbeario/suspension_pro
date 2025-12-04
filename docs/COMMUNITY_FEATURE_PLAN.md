# Community Feature - Implementation Plan

**Date:** 2025-12-03
**Status:** Planning Phase
**Related Docs:** [SYNC_STRATEGY.md](SYNC_STRATEGY.md), [ARCHITECTURE_STANDARD.md](../ARCHITECTURE_STANDARD.md)

---

## 📋 Executive Summary

The Community feature allows riders to browse and share suspension settings. This implements Phase 5 from SYNC_STRATEGY.md with a clear free/Pro tier split.

### Key Objectives:
1. **Free Tier**: Browse, search, filter, and import community settings
2. **Pro Tier**: Contribute settings with location/trail data, vote on settings, GPS proximity search
3. **Future Integration**: When Metrx feature is built, Pro users can contribute roughness/heatmap data

---

## 🎯 Feature Scope

### Free Tier Features (Phase 1)
- ✅ Browse all community settings
- ✅ Search by bike components (fork/shock brand/model/year)
- ✅ Filter by trail type (bike park, XC, enduro, DH, etc.)
- ✅ View setting details (suspension values, tire pressures, notes)
- ✅ Import setting to own bike (creates local copy)
- ✅ View contributor username and submission date
- ✅ Basic sorting (newest, most popular)

### Pro Tier Features (Phase 2)
- ⭐ Contribute new settings to community
- ⭐ Add location/trail name to contributions
- ⭐ GPS proximity search ("Show settings near me")
- ⭐ Upvote/downvote settings (weighted votes for Pro users)
- ⭐ Edit/delete own contributions
- ⭐ Report inappropriate content

### Future Pro Features (Phase 3 - After Metrx)
- 🔮 Attach roughness scores to settings
- 🔮 Attach heatmap data to settings
- 🔮 A/B comparison view with community settings
- 🔮 Trail-specific recommendations based on GPS history

---

## 🗄️ Firebase Database Schema

### Collection: `/community_settings`

```javascript
{
  // Document ID: auto-generated
  "settingId": "auto-generated-id",

  // User attribution
  "userId": "firebase-uid",
  "userName": "john_doe",
  "isPro": true, // Was user Pro when contributing?

  // Bike components (searchable)
  "fork": {
    "year": "2023",
    "brand": "Fox",
    "model": "38 Factory",
    "travel": "170",
    "damper": "GRIP2",
    "offset": "44",
    "wheelsize": "29"
  },
  "shock": {
    "year": "2023",
    "brand": "Fox",
    "model": "DHX2 Factory",
    "stroke": "65x230",
    "damper": "3-position"
  },

  // Suspension settings (the actual data)
  "forkSettings": {
    "hsc": "10",
    "lsc": "8",
    "hsr": "6",
    "lsr": "5",
    "springRate": "110 psi",
    "tokens": "2"
  },
  "shockSettings": {
    "hsc": "8",
    "lsc": "10",
    "hsr": "5",
    "lsr": "6",
    "springRate": "210 psi"
  },

  // Tire pressures
  "frontTire": "23 psi",
  "rearTire": "25 psi",

  // Rider context
  "riderWeight": "180 lbs",
  "notes": "Dialed in for Whistler A-Line, fast and plush",

  // Location data (Pro only)
  "location": {
    "name": "Whistler Bike Park - A-Line",
    "geohash": "c2b2q8cu", // For proximity queries
    "lat": 50.1163,
    "lng": -122.9574,
    "trailType": "bike_park" // enum: bike_park, xc, enduro, dh, all_mountain
  },

  // Future Metrx data (Pro only, added later)
  "metrxData": {
    "roughnessScore": 7.2, // 0-10 scale
    "hasHeatmap": true,
    "recordingId": "metrx-session-id" // Link to separate Metrx collection
  },

  // Engagement metrics
  "upvotes": 42,
  "downvotes": 3,
  "imports": 156, // How many times imported
  "views": 890,

  // Timestamps
  "created": Timestamp,
  "updated": Timestamp,

  // Moderation
  "flagCount": 0,
  "isHidden": false // Admin can hide inappropriate content
}
```

### Collection: `/community_votes` (Pro only)
```javascript
{
  "settingId": "community-setting-id",
  "userId": "firebase-uid",
  "vote": 1, // 1 for upvote, -1 for downvote
  "created": Timestamp
}
```

### Firestore Indexes Required
```javascript
// Index 1: Search by fork brand + model
fork.brand ASC, fork.model ASC, created DESC

// Index 2: Search by shock brand + model
shock.brand ASC, shock.model ASC, created DESC

// Index 3: Filter by trail type
location.trailType ASC, created DESC

// Index 4: Sort by popularity
upvotes DESC, created DESC

// Index 5: Geohash proximity (Pro feature)
location.geohash ASC, created DESC
```

---

## 📁 File Structure

```
lib/features/community/
├── domain/
│   ├── models/
│   │   ├── community_setting.dart         # Main model
│   │   ├── community_setting.g.dart       # Hive adapter (for caching)
│   │   ├── location_data.dart             # Location sub-model
│   │   └── metrx_preview.dart             # Future: Metrx data preview
│   ├── community_notifier.dart            # State management
│   └── community_state.dart               # UI state model
├── presentation/
│   ├── screens/
│   │   ├── community_browser_screen.dart  # Main browse/search screen
│   │   ├── community_setting_detail.dart  # Detail view
│   │   └── contribute_setting_screen.dart # Pro: submit new setting
│   ├── widgets/
│   │   ├── setting_card.dart              # List item widget
│   │   ├── search_filters.dart            # Search/filter UI
│   │   ├── location_picker.dart           # Pro: pick trail location
│   │   └── vote_buttons.dart              # Pro: upvote/downvote
│   └── view_models/
│       ├── community_browser_view_model.dart
│       └── contribute_view_model.dart     # Pro contribution logic
└── data/                                   # Empty per MVVM pattern
```

---

## 🎨 UI/UX Design

### Screen 1: Community Browser (Free + Pro)

**Layout:**
```
┌─────────────────────────────────────┐
│  Community Settings       [Filter]  │ ← AppBar with filter button
├─────────────────────────────────────┤
│  Search: [________________] 🔍      │ ← Search bar
│  Sort: [Newest ▼]  Type: [All ▼]   │ ← Sorting & filtering
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ 2023 Fox 38 / DHX2          │   │ ← Setting card
│  │ Whistler A-Line             │   │
│  │ ⬆️ 42  👁️ 890  📥 156        │   │
│  │ by: john_doe                │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ 2024 RockShox Lyrik / Super │   │
│  │ XC Trail - Local            │   │
│  │ ⬆️ 28  👁️ 450  📥 89         │   │
│  │ by: trailshredder           │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  [➕ Contribute Setting] ⭐ Pro     │ ← FAB (shows paywall for free)
└─────────────────────────────────────┘
```

**Interactions:**
- Tap card → View detail screen
- Tap Filter → Show FilterSheet (component brands, trail types, sort)
- Tap "Contribute" (Free) → Show PaywallScreen
- Tap "Contribute" (Pro) → Navigate to ContributeScreen

### Screen 2: Setting Detail (Free + Pro)

**Layout:**
```
┌─────────────────────────────────────┐
│  ← 2023 Fox 38 / DHX2        [⋮]   │ ← AppBar with menu
├─────────────────────────────────────┤
│  📍 Whistler A-Line (Bike Park)    │ ← Location (if provided)
│  👤 by john_doe • 3 weeks ago      │ ← Attribution
│  ⬆️ 42  ⬇️ 3  👁️ 890  📥 156        │ ← Stats
├─────────────────────────────────────┤
│  FORK: 2023 Fox 38 Factory         │
│  Travel: 170mm | Damper: GRIP2     │
│  HSC: 10  LSC: 8  HSR: 6  LSR: 5   │
│  Air: 110 psi | Tokens: 2          │
├─────────────────────────────────────┤
│  SHOCK: 2023 Fox DHX2 Factory      │
│  Stroke: 65x230 | Damper: 3-pos    │
│  HSC: 8  LSC: 10  HSR: 5  LSR: 6   │
│  Air: 210 psi                      │
├─────────────────────────────────────┤
│  TIRES                             │
│  Front: 23 psi | Rear: 25 psi      │
├─────────────────────────────────────┤
│  NOTES                             │
│  Dialed in for A-Line, fast and    │
│  plush over the big hits           │
├─────────────────────────────────────┤
│  [⬆️ Upvote] [⬇️ Downvote] ⭐ Pro  │ ← Vote buttons (Pro)
│  [📥 Import to My Bike]            │ ← Always available
└─────────────────────────────────────┘
```

**Interactions:**
- Tap "Import" → Show bike selector, then import
- Tap "Upvote" (Free) → Show PaywallScreen
- Tap "Upvote" (Pro) → Increment vote, update UI
- Menu (⋮) → Report, Share (future), Edit (if owner)

### Screen 3: Contribute Setting (Pro Only)

**Layout:**
```
┌─────────────────────────────────────┐
│  ← Contribute Setting        [Save] │
├─────────────────────────────────────┤
│  SELECT BIKE TO SHARE               │
│  ┌─────────────────────────────┐   │
│  │ ◉ 2023 Nomad (Fox 38/DHX2)  │   │ ← Radio select
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ○ 2022 5010 (Pike/SIDLuxe)  │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  SELECT SETTING TO SHARE            │
│  ┌─────────────────────────────┐   │
│  │ ◉ A-Line Setup              │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ○ XC Trail                  │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  LOCATION (Optional)                │
│  Trail Name: [Whistler A-Line   ]  │
│  Trail Type: [Bike Park       ▼]   │
│  📍 Use Current Location            │ ← Gets GPS coords
├─────────────────────────────────────┤
│  NOTES (Optional)                   │
│  [Fast and plush...            ]   │
│  [                             ]   │
└─────────────────────────────────────┘
```

---

## 🔐 Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Community settings - read: everyone, write: Pro only
    match /community_settings/{settingId} {
      // Anyone can read
      allow read: if true;

      // Only Pro users can create
      allow create: if request.auth != null
                    && request.auth.uid != null
                    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isPro == true
                    && request.resource.data.userId == request.auth.uid;

      // Only owner can update/delete
      allow update, delete: if request.auth != null
                             && resource.data.userId == request.auth.uid;
    }

    // Community votes - Pro only
    match /community_votes/{voteId} {
      // Users can read their own votes
      allow read: if request.auth != null
                  && request.auth.uid == resource.data.userId;

      // Only Pro users can vote
      allow create, update: if request.auth != null
                            && request.auth.uid != null
                            && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isPro == true
                            && request.resource.data.userId == request.auth.uid;

      allow delete: if request.auth != null
                    && resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 🏗️ Implementation Phases

### Phase 1: Free Tier MVP (Week 1-2)
**Goal:** Free users can browse and import community settings

#### Tasks:
1. ✅ Create data models
   - [ ] `community_setting.dart` with Hive adapter
   - [ ] `location_data.dart` model
   - [ ] `community_state.dart` for UI state

2. ✅ Firebase integration
   - [ ] Add Firestore security rules
   - [ ] Create Firestore indexes
   - [ ] Seed database with 10-20 sample settings

3. ✅ Community Browser Screen
   - [ ] Fetch settings from Firestore (stream)
   - [ ] Display as scrollable list (SettingCard widgets)
   - [ ] Search by fork/shock brand/model
   - [ ] Filter by trail type
   - [ ] Sort by newest/popular

4. ✅ Setting Detail Screen
   - [ ] Display all setting data
   - [ ] Show location (if available)
   - [ ] Show contributor info
   - [ ] Import button → select bike → create local copy

5. ✅ Offline support
   - [ ] Cache viewed settings in Hive
   - [ ] Show cached settings when offline
   - [ ] "Offline" indicator

6. ✅ Navigation
   - [ ] Replace `_CommunityPlaceholder` in app_router.dart
   - [ ] Add route for detail screen

### Phase 2: Pro Contributions (Week 3-4)
**Goal:** Pro users can contribute settings

#### Tasks:
1. ✅ Contribute Screen (Pro only)
   - [ ] Select bike from user's bikes
   - [ ] Select setting from bike's settings
   - [ ] Location picker (manual + GPS)
   - [ ] Trail type selector
   - [ ] Notes field
   - [ ] Submit to Firestore

2. ✅ Voting System (Pro only)
   - [ ] Upvote/downvote buttons on detail screen
   - [ ] Save vote to `/community_votes`
   - [ ] Update aggregated counts on setting
   - [ ] Show user's current vote state

3. ✅ GPS Proximity Search (Pro only)
   - [ ] Request location permission
   - [ ] Query by geohash prefix
   - [ ] Sort by distance
   - [ ] "Near Me" filter toggle

4. ✅ Pro Feature Gates
   - [ ] Contribute button → ProFeatureGate
   - [ ] Vote buttons → checkProFeature()
   - [ ] GPS search → ProFeatureGate

5. ✅ Edit/Delete Own Settings
   - [ ] Menu (⋮) on detail screen
   - [ ] Edit → reuse contribute screen
   - [ ] Delete → confirmation dialog

### Phase 3: Polish & Moderation (Week 5)
**Goal:** Production-ready quality

#### Tasks:
1. ✅ Content Moderation
   - [ ] Report button (all users)
   - [ ] Flag count tracking
   - [ ] Admin dashboard to hide flagged content

2. ✅ UI/UX Polish
   - [ ] Loading states
   - [ ] Error handling
   - [ ] Empty states ("No settings found")
   - [ ] Animations

3. ✅ Testing
   - [ ] Free user flow (browse, search, import)
   - [ ] Pro user flow (contribute, vote, GPS search)
   - [ ] Offline behavior
   - [ ] Security rules validation

4. ✅ Analytics
   - [ ] Track imports (most popular settings)
   - [ ] Track searches (popular components)
   - [ ] Track GPS usage

---

## 🎯 Success Metrics

### Free Tier Engagement
- **Target:** 50% of free users browse community within first week
- **Metric:** Community screen views
- **Target:** 20% import rate (views → imports)

### Pro Conversion
- **Target:** 15% of free users upgrade after viewing community
- **Metric:** Paywall impressions from community feature
- **Target:** 30% of Pro users contribute at least 1 setting

### Content Growth
- **Target:** 100 community settings in first month
- **Target:** Average 5 imports per setting
- **Target:** <5% flag rate (quality content)

---

## 🔮 Future Enhancements (Post-Metrx)

1. **Roughness Integration**
   - Attach Metrx roughness scores to settings
   - Filter by roughness level (smooth, moderate, rough)
   - Compare your roughness to community average

2. **A/B Comparison**
   - Compare your setting to community setting
   - Side-by-side heatmap view
   - Quantitative difference analysis

3. **Trail Recommendations**
   - "Settings for this trail" based on GPS history
   - Auto-suggest settings when recording near known trails

4. **Social Features**
   - Follow favorite contributors
   - Setting collections/playlists
   - Comments on settings

---

## 🚨 Risks & Mitigation

### Risk 1: Spam/Low-Quality Content
**Mitigation:**
- Pro-only contribution gate
- Voting system to surface quality
- Report/flag mechanism
- Admin moderation tools

### Risk 2: Empty Community (Cold Start)
**Mitigation:**
- Seed with 20 high-quality settings
- Encourage Beta users to contribute
- Import popular settings from forums/Reddit

### Risk 3: Privacy Concerns (GPS Data)
**Mitigation:**
- Make location completely optional
- Round GPS coordinates to ~100m precision
- Clear privacy messaging

### Risk 4: Firestore Costs
**Mitigation:**
- Implement pagination (20 per page)
- Cache aggressively in Hive
- Optimize queries with indexes

---

## 📚 Technical Decisions

### Why Firestore Instead of Realtime Database?
- Better querying (compound indexes)
- Better security rules
- Better offline support
- Scalable for 10k+ settings

### Why Geohash for Proximity?
- Efficient prefix queries
- No complex geo calculations
- Well-supported in Firestore

### Why Separate Votes Collection?
- Prevents race conditions on vote counts
- Easier to track user vote history
- Can implement vote weight (Pro = 2x)

### Why Hive Caching?
- Offline browsing
- Instant UI updates
- Reduce Firestore reads (cost)

---

## 🎓 Learning Resources

- [Firestore Geohash Queries](https://firebase.google.com/docs/firestore/solutions/geoqueries)
- [Flutter GeoLocator Package](https://pub.dev/packages/geolocator)
- [Geohash Dart Package](https://pub.dev/packages/geohash)

---

**Document Version:** 1.0
**Last Updated:** 2025-12-03
**Author:** Community Feature Planning
**Status:** Ready for Implementation ✅
