# Firebase Admin Scripts

Quick setup and seed data scripts for RideMetrx.

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Get Service Account Key
1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate New Private Key"
3. Save as `serviceAccountKey.json` in this directory
4. **Never commit this file!** (it's already in .gitignore)

### 3. Seed Community Data
```bash
npm run seed
```

This creates 50 realistic community settings with:
- 8 different users (Pro and Free mix)
- Popular fork/shock brands (Fox, RockShox, Ohlins, etc.)
- Famous trail locations (Whistler, Moab, Finale Ligure, etc.)
- Realistic engagement metrics
- Random timestamps (last 60 days)

### 4. Delete All Seed Data (Cleanup)
```bash
npm run seed:delete
```

## Verify in Firebase Console

After seeding:
1. Open Firebase Console > Firestore Database
2. Look for `community_settings` collection
3. Should see 50 documents

## Troubleshooting

**Error: Cannot find module 'firebase-admin'**
```bash
npm install
```

**Error: Could not load the default credentials**
- Check `serviceAccountKey.json` exists in this directory
- Verify it's the correct service account key from Firebase
- Make sure it has proper permissions

**Error: Permission denied**
- Check Firestore security rules are deployed
- Verify your Firebase project is correct

## Scripts

- `npm run seed` - Create 50 community settings
- `npm run seed:delete` - Delete all community settings

## What Gets Created

Each community setting includes:
```json
{
  "userId": "user1",
  "userName": "Sarah_MTB",
  "isPro": true,
  "fork": {
    "brand": "Fox",
    "model": "38 Factory",
    "year": "2023",
    "travel": "170mm",
    "wheelsize": "29\""
  },
  "shock": {
    "brand": "Fox",
    "model": "DHX2 Factory",
    "year": "2023",
    "stroke": "65mm"
  },
  "forkSettings": {
    "hsc": "12",
    "lsc": "8",
    "rebound": "15",
    "pressure": "75",
    "tokens": "1"
  },
  "shockSettings": {
    "hsc": "10",
    "lsc": "6",
    "hsr": "12",
    "lsr": "8",
    "pressure": "200",
    "tokens": "2"
  },
  "frontTire": "25 psi",
  "rearTire": "27 psi",
  "riderWeight": "180 lbs",
  "notes": "Works great for fast, rough sections. Very stable at speed.",
  "location": {
    "name": "Whistler A-Line",
    "geohash": "c2b2q8cu",
    "lat": 50.1163,
    "lng": -122.9574,
    "trailType": "bike_park"
  },
  "upvotes": 42,
  "downvotes": 3,
  "imports": 156,
  "views": 890,
  "created": "2024-10-15T...",
  "updated": null
}
```

## Next Steps

After seeding data:
1. Deploy Firestore security rules (see [FIREBASE_COMMUNITY_SETUP.md](../docs/FIREBASE_COMMUNITY_SETUP.md))
2. Run the app and test the Community tab
3. Try searching, filtering, and importing settings
