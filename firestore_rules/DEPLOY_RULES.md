# Deploy Firestore Security Rules

## Quick Fix for Permission Errors

Your app is getting permission denied errors because Firestore rules need to be updated.

## Option 1: Firebase Console (Fastest - 2 minutes)

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Firestore Database** > **Rules**
4. **Copy entire contents** of `firestore_rules/firestore.rules`
5. **Paste** into the rules editor (replace everything)
6. Click **Publish**

## Option 2: Firebase CLI

```bash
# Copy the rules file to project root
cp firestore_rules/firestore.rules firestore.rules

# Deploy
firebase deploy --only firestore:rules
```

## What These Rules Do

### Users Collection
- ✅ Users can read/write their own user document
- ❌ Cannot access other users' data

### Bikes Collection (Pro only - Cloud Sync)
```
/bikes/{userId}/userBikes/{bikeId}
```
- ✅ **Pro users:** Full CRUD on their own bikes
- ❌ **Free users:** No cloud access (Hive-only mode)

### Settings Collection (Pro only - Cloud Sync)
```
/bikes/{userId}/userBikes/{bikeId}/settings/{settingId}
```
- ✅ **Pro users:** Full CRUD on their own settings
- ❌ **Free users:** No cloud access (Hive-only mode)

### Community Settings (All users can browse)
```
/community_settings/{settingId}
```
- ✅ **All users:** Can read/browse
- ✅ **All users:** Can increment views/imports
- ✅ **Pro users:** Can create/update/delete their own
- ❌ **Free users:** Cannot create/modify

## Verify Rules Are Working

After deploying, test in your app:

### As Free User:
```dart
// Should work ✅
- Read user document
- Browse community settings
- Increment view/import counts

// Should fail (Hive-only mode) ❌
- Access bikes collection in Firestore
- Access settings collection in Firestore
```

### As Pro User:
```dart
// Should work ✅
- All Free user features
- Cloud sync bikes
- Cloud sync settings
- Create community settings
```

## Current Error Fix

The error you're seeing:
```
[cloud_firestore/permission-denied] The caller does not have permission
```

This happens because:
1. Free users trying to access cloud bikes/settings (should use Hive only)
2. Missing rules for community_settings collection

**After deploying these rules**, the errors should go away because:
- Free users will be properly blocked from cloud access
- Community browsing will work for everyone
- Your app logic already handles this with `isPro` checks

## Testing After Deployment

### Test 1: Free User
```bash
flutter run
# Navigate to Community tab
# Should see settings list ✅
```

### Test 2: Pro User
```bash
flutter run
# Check bikes sync to cloud ✅
# Check settings sync to cloud ✅
# Browse community ✅
```

## Troubleshooting

**Still getting permission errors after deploy?**

1. **Wait 30 seconds** - Rules can take time to propagate
2. **Restart app** - Force a new connection
3. **Check Firebase Console** - Verify rules are published
4. **Check user.isPro** - Verify value is set correctly

**Free user errors persist?**

This is expected! Free users should NOT access Firestore for bikes/settings. Your app should:
```dart
// In sync_service.dart
final isPro = ref.read(purchaseNotifierProvider).isPro;
if (!isPro) {
  print('User is not Pro, skipping cloud sync'); // ✅ This is correct!
  return;
}
```

The error is actually your app trying to sync when it shouldn't. The rules are protecting the data correctly.

## Next Steps

After deploying rules:
1. Verify community browsing works
2. Check that Pro users can sync
3. Verify Free users get blocked (this is correct behavior)
4. Update app logic to suppress permission errors for Free users
