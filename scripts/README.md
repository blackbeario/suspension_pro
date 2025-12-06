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

---

# Suspension Products Seed Script

Upload the suspension products database from local JSON to Firebase Firestore.

## Usage

```bash
# Seed suspension products to Firebase
cd scripts
npm run seed:suspension

# Delete all suspension products from Firebase
npm run seed:suspension:delete
```

## What It Does

### Seeding (`npm run seed:suspension`)
1. **Reads** `assets/data/suspension_products.json` (158 products covering 2015-2025)
2. **Generates** unique IDs for each product (brand_model_year_type)
3. **Upserts** products to Firebase collection `suspension_products` (creates new, updates existing)
4. **Tracks** version number for incremental updates
5. **Updates** metadata document with version and timestamp

**Note:** Running the seed script multiple times will:
- Update existing products with matching IDs
- Add new products from the JSON
- Leave orphaned products (in Firebase but not in JSON) untouched

### Deleting (`npm run seed:suspension:delete`)
1. **Fetches** all products from Firebase collection `suspension_products`
2. **Deletes** all products in batches
3. **Deletes** metadata document
4. **Use this** for a clean slate or when testing

## Version Tracking

Each run increments the version number, allowing the app to:
- Check if updates are available (weekly background check)
- Download only new/changed products
- Track data evolution like git commits

## Firebase Structure

```
suspension_products/
  ├── fox_38_factory_2025_fork/
  │   ├── id: "fox_38_factory_2025_fork"
  │   ├── brand: "Fox"
  │   ├── model: "38 Factory"
  │   ├── year: "2025"
  │   ├── type: "fork"
  │   ├── category: "enduro"
  │   ├── specs: {...}
  │   ├── baselineSettings: {...}
  │   ├── version: 1
  │   ├── createdAt: Timestamp
  │   └── updatedAt: Timestamp
  │
  └── ... (157 more products)

metadata/
  └── suspension_products/
      ├── version: 1
      ├── totalProducts: 60
      ├── lastUpdated: Timestamp
      └── updatedBy: "seed_script"
```

## Current Coverage

**158 products** spanning 2015-2025:
- **Brands**: Fox, RockShox, Marzocchi, Manitou, Öhlins, DVO, EXT, MRP, Cane Creek, X-Fusion, DNM
- **Years**: 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025
- **Types**: Forks and Shocks
- **Levels**: Factory, Performance, Ultimate, Select, Pro, RL, RC, Rhythm, R

## Adding New Products

1. Edit `assets/data/suspension_products.json`
2. Add new product objects following the existing format (see existing products for examples)
3. Run the seed script from the scripts directory:
```bash
cd scripts
npm run seed:suspension
```
4. Version auto-increments, apps pull updates on next weekly check

**Example product format:**
```json
{
  "type": "fork",
  "brand": "Fox",
  "model": "38 Factory",
  "year": "2026",
  "category": "enduro",
  "specs": {
    "travel": ["160mm", "170mm", "180mm"],
    "wheelSizes": ["27.5\"", "29\""],
    "damperType": "GRIP X3",
    "springType": "air",
    "tubeType": "38mm",
    "axleStandard": "15x110mm Kabolt"
  },
  "baselineSettings": {
    "airPressureChart": [...],
    "defaultRebound": "12 clicks from full fast",
    "defaultCompression": {...},
    "recommendedSag": "20-25%"
  },
  "discontinued": false,
  "msrp": 1499,
  "weight": "2200g (29\", 170mm)",
  "features": [...]
}
```

## Incremental Updates

The app checks for updates weekly (background, non-blocking):
- Local version: 1
- Firebase version: 2
- → Downloads update silently

This allows continuous database expansion without requiring app updates.

## Future: Pro User Contributions

Planned feature: Allow Pro users to submit new products via the app, which you can review, add to JSON, and re-seed to Firebase. This crowdsources the database expansion.
