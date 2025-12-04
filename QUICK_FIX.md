# Quick Fix for Community Feature

Your errors in 2 minutes:

## Step 1: Deploy Simple Rules

Your current rules are wide-open. Use these simpler rules to keep everything working + add community support.

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Go to **Firestore Database** > **Rules**
3. Copy contents from `firestore_rules/firestore_simple.rules`
4. Paste into editor (replace all)
5. Click **Publish**

## Step 2: Reseed Community Data

```bash
cd scripts

# Delete old data (wrong format)
npm run seed:delete

# Seed new data (correct format)
npm run seed
```

## Step 3: Restart App

```bash
flutter run
```

## What Changed

### Old Rules (insecure)
```javascript
allow read, write: if request.auth.uid != null;  // Everything wide-open
```

### New Simple Rules
```javascript
// Users - can access own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Bikes - keeps your existing behavior (all authenticated)
match /bikes/{userId}/userBikes/{bikeId} {
  allow read, write: if request.auth != null;
}

// Community - NEW (everyone can browse)
match /community_settings/{settingId} {
  allow read: if request.auth != null;  // Everyone can browse
  allow create: if isPro();              // Pro can share
  allow update, delete: if request.auth != null;
}
```

## Expected Behavior After Fix

### Community Tab:
- ✅ Loads 50 settings
- ✅ Search works
- ✅ Filter works
- ✅ Import works
- ✅ View counts increment

### Bikes/Settings:
- ✅ Everything works as before
- ✅ Cloud sync for all (will restrict to Pro later)

## The JSON Error Fix

I also fixed `ComponentSetting.fromJson()` to handle null values safely, and updated the seed script to use the correct field names:

**Before (seed script):**
```javascript
{
  hsc: "12",  // Wrong - lowercase
  lsc: "8",
  // Missing sag, springRate, preload
}
```

**After (seed script):**
```javascript
{
  sag: "25",
  springRate: null,
  preload: null,
  HSC: "12",  // Correct - uppercase
  LSC: "8",
  HSR: "15",
  LSR: "10",
  spacers: "1",
}
```

That's it! Your community feature should work now.

---

## Later: Upgrade to Secure Rules

When ready for production, use `firestore_rules/firestore.rules` which has:
- Pro-gated cloud sync for bikes/settings
- Proper permission checks
- Prevents metric manipulation
- User isolation
