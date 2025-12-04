# Firebase Community Feature Setup Guide

This guide walks you through setting up Firebase for the Community feature, adding security rules, and seeding test data.

## Prerequisites

- Firebase project already set up (you have this)
- Node.js installed (for running seed script)
- Firebase Admin SDK access

## Step 1: Install Dependencies for Seed Script

```bash
cd scripts
npm init -y
npm install firebase-admin
```

## Step 2: Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click the gear icon ⚙️ > **Project Settings**
4. Navigate to **Service Accounts** tab
5. Click **Generate New Private Key**
6. Save the downloaded JSON file as `serviceAccountKey.json` in the `scripts/` directory
7. **IMPORTANT:** Add `serviceAccountKey.json` to `.gitignore` (never commit this!)

```bash
# Add to .gitignore
echo "scripts/serviceAccountKey.json" >> .gitignore
```

## Step 3: Deploy Firestore Security Rules

### Option A: Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** > **Rules**
4. Copy the rules from `firestore_rules/community_rules.txt`
5. Add them to your existing rules file
6. Click **Publish**

### Option B: Firebase CLI

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not already done)
firebase init firestore

# Edit firestore.rules and add the community rules
# Then deploy
firebase deploy --only firestore:rules
```

## Step 4: Seed Test Data

Run the seed script to populate Firestore with 50 realistic community settings:

```bash
cd scripts
node seed_community_data.js
```

You should see output like:
```
🌱 Starting to seed community settings...

✅ Created setting 1/50: Sarah_MTB - Fox 38 Factory / Fox DHX2 Factory
✅ Created setting 2/50: Jake_Rider - RockShox ZEB Ultimate / Ohlins TTX Air
...
✅ Created setting 50/50: Sam_Shredder - Fox 36 Factory / RockShox Super Deluxe Ultimate

✨ Successfully seeded 50 community settings!
✅ Done!
```

## Step 5: Verify Data in Firebase Console

1. Go to **Firestore Database** in Firebase Console
2. You should see a new collection: `community_settings`
3. Browse the documents to verify the data

## Step 6: Test in the App

### Free User Testing
1. Run the app with a Free user account
2. Navigate to the Community tab
3. You should see 50+ community settings
4. Test features:
   - ✅ Browse settings
   - ✅ Search by user/component
   - ✅ Filter by fork/shock brand
   - ✅ Sort by different criteria
   - ✅ View setting details
   - ✅ Import settings to your bikes
   - ❌ Cannot share own settings (Pro only)

### Pro User Testing
1. Switch to a Pro user account (or upgrade test account)
2. Same features as Free, plus:
   - ✅ Can share own settings (Phase 2 - not yet implemented)
   - ✅ Can upvote/downvote (Phase 2 - not yet implemented)
   - ✅ GPS proximity search (Phase 2 - not yet implemented)

## Troubleshooting

### "Permission denied" errors in app
- Check Firestore security rules are deployed
- Verify user is authenticated
- Check user document has `isPro` field set correctly

### Seed script fails with authentication error
- Verify `serviceAccountKey.json` is in the correct location
- Check the service account has Firestore permissions
- Ensure you're using the correct Firebase project

### No data showing in app
- Check Flutter app is pointing to the correct Firebase project
- Verify seed script completed successfully
- Check Firebase Console to confirm data exists
- Look for errors in app logs (`flutter run -v`)

### Imports not working
- Check that bikes exist in the app first
- Verify `bikesNotifierProvider` is accessible
- Check import logic in `community_notifier.dart` (currently stubbed)

## Cleaning Up Test Data

To delete all community settings:

```bash
cd scripts
node seed_community_data.js --delete
```

## Next Steps

### Phase 2: Pro Features (Future)
When ready to implement Pro features, you'll need to:

1. **Sharing Settings**: Implement `shareSettingToCommunity()` in `community_notifier.dart`
2. **Voting**: Implement `upvoteSetting()` and `downvoteSetting()`
3. **GPS Search**: Add geohash query logic using `geoflutterfire` package
4. **Moderation**: Add reporting/flagging system

### Indexing (Important for Production)

Firebase will prompt you to create indexes when you run queries. Common indexes needed:

```
Collection: community_settings
Fields: imports (Descending), created (Descending)
Fields: upvotes (Descending), created (Descending)
Fields: views (Descending), created (Descending)
```

Create these in Firebase Console > Firestore > Indexes when Firebase prompts you.

## Security Checklist

- ✅ Service account key is NOT committed to git
- ✅ Firestore rules are deployed
- ✅ Free users can only read, not write
- ✅ Pro users can create/update their own settings
- ✅ Engagement metrics can only increment by 1
- ✅ Users can't modify other users' settings

## Seed Data Overview

The seed script creates:
- **50 community settings** with realistic data
- **8 different users** (mix of Pro and Free)
- **8 popular fork brands/models** (Fox, RockShox, Ohlins, Manitou)
- **7 popular shock brands/models** (Fox, RockShox, Ohlins, Cane Creek)
- **8 famous trail locations** (Whistler, Moab, Finale Ligure, etc.)
- **Realistic engagement metrics** (imports: 0-200, views: 0-1000+)
- **Random timestamps** (last 60 days)
- **Pro users get location data**, Free users don't

## Firebase Collection Structure

```
/community_settings/{settingId}
  ├── settingId: auto-generated
  ├── userId: "user123"
  ├── userName: "Sarah_MTB"
  ├── isPro: true
  ├── fork: { brand, model, year, travel, wheelsize }
  ├── shock: { brand, model, year, stroke }
  ├── forkSettings: { hsc, lsc, rebound, pressure, tokens }
  ├── shockSettings: { hsc, lsc, hsr, lsr, pressure, tokens }
  ├── frontTire: "25 psi"
  ├── rearTire: "27 psi"
  ├── riderWeight: "180 lbs"
  ├── notes: "Works great for fast, rough sections..."
  ├── location: { name, geohash, lat, lng, trailType } // Pro only
  ├── upvotes: 42
  ├── downvotes: 3
  ├── imports: 156
  ├── views: 890
  ├── created: Timestamp
  └── updated: Timestamp | null
```

## Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Review Firebase Console logs
3. Check Flutter app logs with `flutter run -v`
4. Verify security rules in Firebase Console

Happy testing! 🚀
