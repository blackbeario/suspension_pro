# Community Feature Setup Checklist

Quick checklist to get the Community feature up and running with test data.

## ✅ Pre-Setup Checklist

- [ ] Firebase project exists
- [ ] Flutter app is connected to Firebase
- [ ] Node.js is installed (`node --version`)
- [ ] You have Firebase project admin access

## 🔧 Setup Steps

### 1. Install Script Dependencies
```bash
cd scripts
npm install
```
- [ ] Dependencies installed successfully

### 2. Get Firebase Service Account Key
1. Firebase Console → Your Project → ⚙️ Settings → Service Accounts
2. Click "Generate New Private Key"
3. Save as `scripts/serviceAccountKey.json`
4. Verify file exists: `ls scripts/serviceAccountKey.json`

- [ ] Service account key downloaded
- [ ] Saved to correct location
- [ ] File is in .gitignore (check: `git status` should NOT show it)

### 3. Deploy Firestore Security Rules
**Option A: Firebase Console (Recommended)**
1. Firebase Console → Firestore Database → Rules
2. Copy rules from `firestore_rules/community_rules.txt`
3. Paste into rules editor (add to existing rules)
4. Click "Publish"

**Option B: Firebase CLI**
```bash
firebase deploy --only firestore:rules
```

- [ ] Security rules deployed
- [ ] Rules include `community_settings` collection

### 4. Seed Test Data
```bash
cd scripts
npm run seed
```

Expected output:
```
🌱 Starting to seed community settings...
✅ Created setting 1/50: ...
...
✨ Successfully seeded 50 community settings!
```

- [ ] Seed script ran successfully
- [ ] Created 50 settings

### 5. Verify in Firebase Console
1. Firebase Console → Firestore Database
2. Look for `community_settings` collection
3. Click to see 50+ documents

- [ ] Collection exists
- [ ] Documents visible
- [ ] Sample data looks correct

### 6. Test in App (Free User)
```bash
flutter run
```

1. Launch app with Free user account
2. Navigate to Community tab (should be visible in bottom nav)
3. Test these features:

- [ ] Settings load and display
- [ ] Search bar works (try "Fox", "Whistler", etc.)
- [ ] Filter by fork brand (tap sort icon → filter chips)
- [ ] Filter by shock brand
- [ ] Sort options work (Most Imported, Most Upvoted, etc.)
- [ ] Tap a setting to see details
- [ ] Import button appears (create a bike first if needed)
- [ ] Import works (select bike from dialog)
- [ ] Pull to refresh works
- [ ] Offline mode works (turn off wifi, app should show cached data)

### 7. Test Edge Cases

- [ ] Empty search shows "No results" message
- [ ] Clearing filters works
- [ ] Settings with no location still display
- [ ] View count increments (check Firebase Console after viewing)
- [ ] Import count increments (check after importing)

## 🎯 Success Criteria

You should be able to:
- ✅ See 50+ community settings in the app
- ✅ Search and find specific settings
- ✅ Filter by component brands
- ✅ View detailed suspension values
- ✅ Import settings to your bikes
- ✅ Browse offline with cached data

## 🐛 Common Issues

### No data showing in app
**Fix:**
```bash
# 1. Check Firebase Console - is data there?
# 2. Check app logs
flutter run -v

# 3. Try manual refresh (pull down on list)
# 4. Restart app
```

### "Permission denied" errors
**Fix:**
```bash
# 1. Check rules deployed
firebase deploy --only firestore:rules

# 2. Verify user is authenticated
# 3. Check user has proper auth token
```

### Seed script fails
**Fix:**
```bash
# 1. Check service account key exists
ls scripts/serviceAccountKey.json

# 2. Reinstall dependencies
cd scripts
rm -rf node_modules
npm install

# 3. Verify Firebase project ID in key matches your project
```

### Imports not working
**Fix:**
```bash
# 1. Create a bike first in the app
# 2. Check bikesNotifierProvider is available
# 3. Review import logic (currently stubbed in community_notifier.dart)
```

## 🧹 Cleanup (When Done Testing)

To remove all test data:
```bash
cd scripts
npm run seed:delete
```

## 📚 Reference Documentation

- Full setup guide: [FIREBASE_COMMUNITY_SETUP.md](FIREBASE_COMMUNITY_SETUP.md)
- Feature plan: [COMMUNITY_FEATURE_PLAN.md](COMMUNITY_FEATURE_PLAN.md)
- Scripts README: [scripts/README.md](../scripts/README.md)

## 🚀 Next Steps After Testing

Once basic functionality is verified:

1. **Implement Full Import Logic** (currently stubbed)
   - File: `lib/features/community/domain/community_notifier.dart`
   - Method: `importSetting()`
   - TODO: Create Setting from CommunitySetting and save to bike

2. **Add Analytics** (track feature usage)
   - Track searches
   - Track imports
   - Track popular components

3. **Phase 2: Pro Features** (future)
   - Sharing own settings
   - Upvote/downvote
   - GPS proximity search

4. **Production Readiness**
   - Create Firebase indexes (when prompted)
   - Add error tracking
   - Add loading states
   - Add retry logic for failed fetches

---

**Questions?** Check the [FIREBASE_COMMUNITY_SETUP.md](FIREBASE_COMMUNITY_SETUP.md) for detailed troubleshooting.
