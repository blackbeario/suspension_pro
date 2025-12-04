# Pro Firebase Search Feature

## Overview
This feature allows Pro users to search ALL community settings in Firebase (beyond the cached top 100), while offering an upgrade prompt for Free users.

## Implementation Details

### 1. Backend Method (CommunityNotifier)

**File**: [lib/features/community/domain/community_notifier.dart:228-274](lib/features/community/domain/community_notifier.dart#L228-L274)

```dart
Future<List<CommunitySetting>> searchAllSettings(String query)
```

**What it does**:
- Fetches top 500 settings from Firebase (vs. 100 cached locally)
- Applies the same multi-word search logic as local search
- Returns filtered results matching ALL search terms

**Cost implications**:
- ~1 Firebase read operation per search (fetches 500 docs)
- Estimated cost: $0.10/month for 100 Pro users doing 10 searches/month each

### 2. UI Components

**File**: [lib/features/community/presentation/screens/community_browser_screen.dart](lib/features/community/presentation/screens/community_browser_screen.dart)

#### A. Search All Button Prompt
Shows when:
- User is searching (has a search query)
- Local results are limited (0-2 results)
- Not already showing Firebase results

**Why 0-2 results?**: Even with 0 results in the cache, there might be matching settings in the full database outside the top 100 most-imported settings.

**Pro users see**: Blue card with "Search All" button
**Free users see**: Amber card with "Upgrade" button

#### B. Firebase Results Indicator
Shows when displaying Firebase search results:
- Blue banner indicating "Showing X results from full database"
- "Back to cache" button to return to local results

#### C. Upgrade Dialog
Modal dialog for Free users explaining Pro benefits:
- Search all settings (not just top 100)
- Upvote/downvote settings
- Share settings to community
- Advanced filters

## User Flows

### Pro User Flow:
1. User searches for "Norco DPX2"
2. Sees 2 local results
3. Blue prompt appears: "Limited results in cache"
4. Clicks "Search All" button
5. Loading spinner shows while searching Firebase
6. Results update with Firebase data
7. Blue banner shows: "Showing X results from full database"
8. User can click "Back to cache" to return to local results

### Free User Flow:
1. User searches for "Norco DPX2"
2. Sees 2 local results
3. Amber prompt appears: "Want to search all settings?"
4. Clicks "Upgrade" button
5. Upgrade dialog shows Pro benefits
6. User can upgrade or dismiss dialog

## State Management

**Local component state**:
- `_isSearchingFirebase`: Boolean tracking search in progress
- `_firebaseResults`: Nullable list of settings from Firebase search

**Why local state?**:
- Firebase search is a one-time action per query
- Results don't need to persist across app sessions
- Keeps CommunityState clean and focused on cached data

## Testing Checklist

### For Pro Users:
- [ ] Search returns < 3 results → "Search All" button appears
- [ ] Clicking "Search All" → Shows loading spinner
- [ ] Firebase search completes → Results update and banner shows
- [ ] "Back to cache" button → Returns to local results
- [ ] Pull to refresh → Clears Firebase results and refetches cache
- [ ] Clear filters → Clears Firebase results

### For Free Users:
- [ ] Search returns < 3 results → "Upgrade" button appears
- [ ] Clicking "Upgrade" → Shows upgrade dialog
- [ ] Dialog shows all Pro benefits
- [ ] "Maybe Later" → Closes dialog
- [ ] "Upgrade Now" → Shows "coming soon" message (TODO: implement)

### Edge Cases:
- [ ] Firebase search fails → Shows error snackbar
- [ ] No network connection → Error handled gracefully
- [ ] Empty search query → Firebase search returns empty array
- [ ] Firebase returns 0 results → Empty state shows

## Future Enhancements

1. **Analytics**: Track how often users use Pro search
2. **Caching**: Cache recent Firebase search results for faster repeat searches
3. **Pagination**: For searches with > 500 results, add pagination
4. **Search History**: Save recent searches for quick access
5. **Upgrade Screen**: Build full upgrade/payment flow
6. **Advanced Filters**: Allow Pro users to filter Firebase results by date, location, etc.

## Monetization Value

**Clear Pro Feature Differentiator**:
- Free users: Top 100 most-imported settings (instant, cached)
- Pro users: Full database search (500+ settings, Firebase query)

**Upgrade Trigger**:
- Shows upgrade prompt at the exact moment of user need (limited results)
- Clear value proposition: "Search beyond top 100"

**Cost-Effective**:
- ~$0.10/month for 100 Pro users
- Minimal server load (client-side filtering)
- Scalable to thousands of Pro users
