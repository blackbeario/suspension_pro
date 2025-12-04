# Fix Permission Errors - Quick Guide

## Issues You're Seeing

```
[cloud_firestore/permission-denied] The caller does not have permission
NoSuchMethodError: The method '[]' was called on null
```

## Root Causes

1. **Firestore rules not deployed** - Community browsing blocked
2. **Free user accessing cloud** - Expected behavior, but noisy errors
3. **ComponentSetting JSON mismatch** - Seed data format issue

## 3-Step Fix

### Step 1: Update Firestore Rules (2 minutes)

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Go to **Firestore Database** > **Rules**
3. Copy all contents from `firestore_rules/firestore.rules`
4. Paste into rules editor (replace everything)
5. Click **Publish**
6. Wait 30 seconds for propagation

✅ **What this fixes:**
- Community browsing will work
- Free users properly blocked from cloud (Hive-only mode)
- Pro users can sync to cloud

### Step 2: Reseed Community Data

The seed data has been updated to match the ComponentSetting model.

```bash
# Delete old data
cd scripts
npm run seed:delete

# Seed new data with correct format
npm run seed
```

✅ **What this fixes:**
- NoSuchMethodError when loading settings
- Proper sag/HSC/LSC/HSR/LSR fields

### Step 3: Restart App

```bash
flutter run
```

## What You Should See After Fixes

### ✅ Free User (Expected Behavior)
```
# Console (these are NORMAL for free users)
BikesNotifier: Error loading bikes: [permission-denied]
BikesNotifier: Falling back to Hive data

# Community Tab
- Settings load successfully ✅
- Can browse, search, filter ✅
- Can view details ✅
- Can import settings ✅
```

### ✅ Pro User (Expected Behavior)
```
# Console
BikesNotifier: Syncing bikes to cloud ✅
SettingsNotifier: Syncing settings to cloud ✅

# Community Tab
- Everything Free users can do ✅
- Can share own settings (Phase 2) 🔜
```

## Understanding Permission Errors

### These Errors Are Normal for Free Users:
```dart
// Your app correctly handles this:
BikesNotifier: Error loading bikes: [permission-denied]
↓
Falls back to Hive (local-only mode) ✅
```

**Why?** Free users don't have cloud access - this is by design!

### These Errors Should Be Fixed:
```dart
// After deploying rules, this should work:
CommunityNotifier: Fetch error: [permission-denied] ❌
↓
After rules deploy:
CommunityNotifier: Loaded 50 settings ✅
```

## Optional: Suppress Free User Errors

If you want cleaner logs for free users, update these files:

### Option A: Silent Fallback (Recommended)
```dart
// In bikes_notifier.dart
error: (error, stack) {
  // Only log for Pro users
  if (ref.read(purchaseNotifierProvider).isPro) {
    print('BikesNotifier: Error loading bikes: $error');
  }
  // Silently fall back to Hive for free users
  final hiveBikes = _getBikesFromHive();
  ...
}
```

### Option B: Informative Message
```dart
error: (error, stack) {
  final isPro = ref.read(purchaseNotifierProvider).isPro;
  if (isPro) {
    print('BikesNotifier: Cloud sync error: $error');
  } else {
    print('BikesNotifier: Using local-only mode (upgrade to Pro for cloud sync)');
  }
  final hiveBikes = _getBikesFromHive();
  ...
}
```

## Verification Checklist

After completing all 3 steps:

- [ ] Firestore rules deployed (check Firebase Console)
- [ ] Community data reseeded (50 settings in Firestore)
- [ ] App restarted
- [ ] Community tab loads settings ✅
- [ ] Can search/filter settings ✅
- [ ] Can view setting details ✅
- [ ] Can import to bikes ✅
- [ ] Permission errors only for expected scenarios

## Still Having Issues?

### Community not loading?
```bash
# Check Firebase Console
# Verify community_settings collection exists with 50 docs

# Check app logs
flutter run -v
# Look for "CommunityNotifier" messages
```

### Bikes not syncing (Pro user)?
```bash
# Check user document in Firestore
# Verify isPro = true

# Check purchases provider
# Print ref.read(purchaseNotifierProvider).isPro
```

### JSON errors persist?
```bash
# Verify seed data format
# Check Firebase Console > community_settings > any document
# Should have: sag, HSC, LSC, HSR, LSR (uppercase)
```

## Summary

1. **Deploy rules** → Community browsing works
2. **Reseed data** → JSON parsing works
3. **Restart app** → Everything works

The permission errors for Free users are **expected and handled correctly** by your app's fallback to Hive. This is good architecture!
