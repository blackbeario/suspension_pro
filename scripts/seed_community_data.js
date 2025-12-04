/**
 * Community Settings Seed Data Script
 *
 * This script populates Firestore with realistic community settings for testing
 *
 * SETUP:
 * 1. Install Firebase Admin SDK: npm install firebase-admin
 * 2. Download service account key from Firebase Console:
 *    Project Settings > Service Accounts > Generate New Private Key
 * 3. Save as serviceAccountKey.json in this scripts directory
 * 4. Run: node seed_community_data.js
 *
 * CLEANUP:
 * To delete all seed data, run: node seed_community_data.js --delete
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Helper to generate geohash for location (simplified version)
function generateGeohash(lat, lng) {
  // This is a simplified geohash - in production you'd use a proper library
  // For testing purposes, we'll create a basic 8-character hash
  const latStr = lat.toFixed(4).replace(/[.-]/g, '');
  const lngStr = lng.toFixed(4).replace(/[.-]/g, '');
  return `${latStr.slice(0, 4)}${lngStr.slice(0, 4)}`;
}

// Sample users (mix of Pro and Free)
const users = [
  { id: 'user1', name: 'Sarah_MTB', isPro: true },
  { id: 'user2', name: 'Jake_Rider', isPro: true },
  { id: 'user3', name: 'Alex_DH', isPro: false },
  { id: 'user4', name: 'Emma_Trails', isPro: true },
  { id: 'user5', name: 'Chris_Enduro', isPro: false },
  { id: 'user6', name: 'Taylor_Bike', isPro: true },
  { id: 'user7', name: 'Jordan_MTB', isPro: false },
  { id: 'user8', name: 'Sam_Shredder', isPro: true },
];

// Popular fork brands and models
const forks = [
  { brand: 'Fox', model: '38 Factory', year: '2023' },
  { brand: 'Fox', model: '36 Factory', year: '2023' },
  { brand: 'Fox', model: '40 Factory', year: '2022' },
  { brand: 'RockShox', model: 'ZEB Ultimate', year: '2023' },
  { brand: 'RockShox', model: 'Lyrik Ultimate', year: '2023' },
  { brand: 'RockShox', model: 'Pike Ultimate', year: '2022' },
  { brand: 'Ohlins', model: 'RXF38 M.2', year: '2023' },
  { brand: 'Manitou', model: 'Mezzer Pro', year: '2022' },
];

// Popular shock brands and models
const shocks = [
  { brand: 'Fox', model: 'DHX2 Factory', year: '2023' },
  { brand: 'Fox', model: 'Float X2 Factory', year: '2023' },
  { brand: 'Fox', model: 'Float DPX2 Factory', year: '2022' },
  { brand: 'RockShox', model: 'Super Deluxe Ultimate', year: '2023' },
  { brand: 'RockShox', model: 'Super Deluxe Select+', year: '2022' },
  { brand: 'Ohlins', model: 'TTX Air', year: '2023' },
  { brand: 'Cane Creek', model: 'DBair IL', year: '2022' },
];

// Popular bike makes and models (categorized by riding style)
const bikes = {
  enduro: [
    { make: 'Santa Cruz', model: 'Megatower' },
    { make: 'Specialized', model: 'Enduro' },
    { make: 'Trek', model: 'Slash' },
    { make: 'Yeti', model: 'SB165' },
    { make: 'Pivot', model: 'Firebird' },
    { make: 'Transition', model: 'Sentinel' },
    { make: 'Evil', model: 'Wreckoning' },
    { make: 'Ibis', model: 'Mojo HD5' },
  ],
  trail: [
    { make: 'Ibis', model: 'Ripmo' },
    { make: 'Santa Cruz', model: 'Bronson' },
    { make: 'Specialized', model: 'Stumpjumper' },
    { make: 'Trek', model: 'Fuel EX' },
    { make: 'Yeti', model: 'SB140' },
    { make: 'Pivot', model: 'Switchblade' },
    { make: 'Canyon', model: 'Spectral' },
    { make: 'Giant', model: 'Trance' },
  ],
  downhill: [
    { make: 'Santa Cruz', model: 'V10' },
    { make: 'YT', model: 'TUES' },
    { make: 'Specialized', model: 'Demo' },
    { make: 'Trek', model: 'Session' },
    { make: 'Commencal', model: 'Supreme' },
    { make: 'Norco', model: 'Aurum' },
    { make: 'Giant', model: 'Glory' },
  ],
};

// Famous trail locations
const locations = [
  { name: 'Whistler A-Line', lat: 50.1163, lng: -122.9574, trailType: 'bike_park' },
  { name: 'Moab Whole Enchilada', lat: 38.5733, lng: -109.5498, trailType: 'enduro' },
  { name: 'Finale Ligure DH', lat: 44.1697, lng: 8.3430, trailType: 'dh' },
  { name: 'Squamish Half Nelson', lat: 49.7016, lng: -123.1558, trailType: 'enduro' },
  { name: 'Pisgah Black Mountain', lat: 35.5951, lng: -82.5515, trailType: 'all_mountain' },
  { name: 'Sedona Hangover', lat: 34.8697, lng: -111.7610, trailType: 'enduro' },
  { name: 'Queenstown Skyline', lat: -45.0312, lng: 168.6626, trailType: 'bike_park' },
  { name: 'Northstar Flow Trail', lat: 39.2774, lng: -120.1214, trailType: 'bike_park' },
];

// Sample fork settings
function generateForkSettings() {
  min = 100;
  max = 200;
  return {
    sag: String(Math.floor(Math.random() * 10) + 20), // 20-30%
    springRate: String(Math.floor(Math.random() * 100)), // 100-200 lbs/in
    preload: null,
    HSC: String(Math.floor(Math.random() * 20) + 1),
    LSC: String(Math.floor(Math.random() * 20) + 1),
    HSR: String(Math.floor(Math.random() * 20) + 1),
    LSR: String(Math.floor(Math.random() * 20) + 1),
    spacers: String(Math.floor(Math.random() * 3)),
  };
}

// Sample shock settings
function generateShockSettings() {
  return {
    sag: String(Math.floor(Math.random() * 10) + 25), // 25-35%
    springRate: String(Math.floor(Math.random() * 100 + 100)), // 100-200 lbs/in
    preload: null,
    HSC: String(Math.floor(Math.random() * 20) + 1),
    LSC: String(Math.floor(Math.random() * 20) + 1),
    HSR: String(Math.floor(Math.random() * 20) + 1),
    LSR: String(Math.floor(Math.random() * 20) + 1),
    spacers: String(Math.floor(Math.random() * 3)),
  };
}

// Generate random rider weight
function generateRiderWeight() {
  const weights = ['150 lbs', '160 lbs', '170 lbs', '180 lbs', '190 lbs', '200 lbs'];
  return weights[Math.floor(Math.random() * weights.length)];
}

// Generate tire pressures
function generateTirePressures() {
  const frontPressure = Math.floor(Math.random() * 10) + 20; // 20-30 psi
  const rearPressure = frontPressure + Math.floor(Math.random() * 3) + 1; // 2-5 psi higher
  return {
    front: `${frontPressure} psi`,
    rear: `${rearPressure} psi`,
  };
}

// Determine bike category based on suspension components
function determineBikeCategory(fork, shock) {
  // DH bikes: 200mm+ fork travel or DHX2/Float X2 shock
  if (fork.model.includes('40') || shock.model.includes('DHX2') || shock.model.includes('X2')) {
    return 'downhill';
  }

  // Enduro bikes: 160-180mm forks with coil or aggressive air shocks
  if (fork.model.includes('38') || fork.model.includes('ZEB') ||
      shock.model.includes('Super Deluxe') || shock.model.includes('TTX')) {
    return 'enduro';
  }

  // Trail bikes: everything else
  return 'trail';
}

// Get bike make/model for the setup
function getBikeForSetup(fork, shock) {
  const category = determineBikeCategory(fork, shock);
  const categoryBikes = bikes[category];
  return categoryBikes[Math.floor(Math.random() * categoryBikes.length)];
}

// Sample notes
const noteTemplates = [
  "Works great for fast, rough sections. Very stable at speed.",
  "Dialed in for tech climbing and descending. Plush but supportive.",
  "Perfect for jump lines and flow trails. Tons of mid-stroke support.",
  "Aggressive setup for steep, chunky terrain. Not for XC!",
  "Balanced setup for all-day riding. Comfortable but efficient.",
  "Race setup - firm compression, fast rebound. For smooth tracks.",
  "Park setup with extra volume spacers for big hits.",
  "Trail setup optimized for mixed terrain and long rides.",
];

// Generate community settings
async function seedCommunitySettings() {
  console.log('🌱 Starting to seed community settings...\n');

  const batch = db.batch();
  const settingsRef = db.collection('community_settings');

  // Generate 50 realistic settings
  for (let i = 0; i < 50; i++) {
    const user = users[Math.floor(Math.random() * users.length)];
    const fork = forks[Math.floor(Math.random() * forks.length)];
    const shock = shocks[Math.floor(Math.random() * shocks.length)];
    const bike = getBikeForSetup(fork, shock);
    const location = user.isPro && Math.random() > 0.3
      ? locations[Math.floor(Math.random() * locations.length)]
      : null;
    const tirePressures = generateTirePressures();

    // Create timestamp with random offset (last 60 days)
    const daysAgo = Math.floor(Math.random() * 60);
    const created = new Date();
    created.setDate(created.getDate() - daysAgo);

    // Generate realistic engagement metrics
    const imports = Math.floor(Math.random() * 200);
    const upvotes = Math.floor(imports * 0.7 + Math.random() * 50);
    const downvotes = Math.floor(Math.random() * 10);
    const views = Math.floor(imports * 5 + Math.random() * 500);

    const setting = {
      userId: user.id,
      userName: user.name,
      isPro: user.isPro,

      // Fork component
      fork: {
        brand: fork.brand,
        model: fork.model,
        year: fork.year,
        travel: '170mm',
        wheelsize: '29"',
      },

      // Shock component
      shock: {
        brand: shock.brand,
        model: shock.model,
        year: shock.year,
        stroke: '65mm',
      },

      // Settings
      forkSettings: generateForkSettings(),
      shockSettings: generateShockSettings(),

      // Tire pressures
      frontTire: tirePressures.front,
      rearTire: tirePressures.rear,

      // Rider info
      riderWeight: generateRiderWeight(),
      notes: noteTemplates[Math.floor(Math.random() * noteTemplates.length)],

      // Bike info
      bikeMake: bike.make,
      bikeModel: bike.model,

      // Location (Pro only)
      ...(location && {
        location: {
          name: location.name,
          geohash: generateGeohash(location.lat, location.lng),
          lat: location.lat,
          lng: location.lng,
          trailType: location.trailType,
        }
      }),

      // Engagement metrics
      upvotes: upvotes,
      downvotes: downvotes,
      imports: imports,
      views: views,

      // Timestamps
      created: admin.firestore.Timestamp.fromDate(created),
      updated: null,
    };

    const docRef = settingsRef.doc();
    batch.set(docRef, setting);

    console.log(`✅ Created setting ${i + 1}/50: ${user.name} - ${bike.make} ${bike.model} (${fork.brand} ${fork.model} / ${shock.brand} ${shock.model})`);
  }

  await batch.commit();
  console.log('\n✨ Successfully seeded 50 community settings!');
}

// Delete all community settings
async function deleteAllSettings() {
  console.log('🗑️  Deleting all community settings...\n');

  const settingsRef = db.collection('community_settings');
  const snapshot = await settingsRef.get();

  const batch = db.batch();
  let count = 0;

  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
    count++;
  });

  await batch.commit();
  console.log(`✨ Deleted ${count} community settings!`);
}

// Main execution
async function main() {
  try {
    const args = process.argv.slice(2);

    if (args.includes('--delete')) {
      await deleteAllSettings();
    } else {
      await seedCommunitySettings();
    }

    console.log('\n✅ Done!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

main();
