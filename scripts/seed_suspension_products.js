const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Check for --delete flag
const shouldDelete = process.argv.includes('--delete');

// Generate unique ID from product properties
function generateProductId(product) {
  const brand = product.brand.toLowerCase().replace(/[^a-z0-9]/g, '_');
  const model = product.model.toLowerCase().replace(/[^a-z0-9]/g, '_');
  const year = product.year;
  const type = product.type;
  return `${brand}_${model}_${year}_${type}`;
}

async function deleteSuspensionProducts() {
  try {
    console.log('🗑️  Deleting all suspension products from Firebase...\n');

    const productsRef = db.collection('suspension_products');
    const snapshot = await productsRef.get();

    if (snapshot.empty) {
      console.log('✅ No products found in Firebase. Nothing to delete.\n');
      return;
    }

    console.log(`📦 Found ${snapshot.size} products to delete\n`);

    // Firestore has a limit of 500 operations per batch
    const BATCH_SIZE = 500;
    let batch = db.batch();
    let operationCount = 0;
    let totalDeleted = 0;

    for (const doc of snapshot.docs) {
      batch.delete(doc.ref);
      operationCount++;
      totalDeleted++;

      if (operationCount >= BATCH_SIZE) {
        await batch.commit();
        console.log(`✅ Deleted batch of ${operationCount} products`);
        batch = db.batch();
        operationCount = 0;
      }
    }

    // Commit any remaining operations
    if (operationCount > 0) {
      await batch.commit();
      console.log(`✅ Deleted final batch of ${operationCount} products`);
    }

    // Delete metadata document
    const metadataRef = db.collection('metadata').doc('suspension_products');
    await metadataRef.delete();

    console.log(`\n✅ Successfully deleted ${totalDeleted} products from Firebase`);
    console.log('✅ Deleted metadata document');
    console.log('\n🎉 Cleanup complete!');

  } catch (error) {
    console.error('❌ Error deleting suspension products:', error);
    process.exit(1);
  }
}

async function seedSuspensionProducts() {
  try {
    console.log('🚀 Starting suspension products seed...\n');

    // Read the suspension products JSON file
    const jsonPath = path.join(__dirname, '../assets/data/suspension_products.json');
    const jsonData = fs.readFileSync(jsonPath, 'utf8');
    const products = JSON.parse(jsonData);

    console.log(`📦 Found ${products.length} products in JSON file\n`);

    // Get current version from metadata (if exists)
    const metadataRef = db.collection('metadata').doc('suspension_products');
    const metadataDoc = await metadataRef.get();
    const currentVersion = metadataDoc.exists ? metadataDoc.data().version || 0 : 0;
    const newVersion = currentVersion + 1;

    console.log(`📊 Current version: ${currentVersion}`);
    console.log(`📊 New version: ${newVersion}\n`);

    // Firestore has a limit of 500 operations per batch
    const BATCH_SIZE = 500;
    let batch = db.batch();
    let operationCount = 0;
    let totalUploaded = 0;

    // Add timestamp for tracking
    const timestamp = admin.firestore.FieldValue.serverTimestamp();

    // Process each product
    for (const product of products) {
      const productId = generateProductId(product);
      const productRef = db.collection('suspension_products').doc(productId);

      // Add product data with version and timestamps
      const productData = {
        ...product,
        id: productId,
        version: newVersion,
        createdAt: timestamp,
        updatedAt: timestamp
      };

      batch.set(productRef, productData);
      operationCount++;
      totalUploaded++;

      // Commit batch if we hit the limit
      if (operationCount >= BATCH_SIZE) {
        await batch.commit();
        console.log(`✅ Committed batch of ${operationCount} products`);
        batch = db.batch();
        operationCount = 0;
      }
    }

    // Commit any remaining operations
    if (operationCount > 0) {
      await batch.commit();
      console.log(`✅ Committed final batch of ${operationCount} products`);
    }

    // Update metadata document
    await metadataRef.set({
      version: newVersion,
      totalProducts: products.length,
      lastUpdated: timestamp,
      updatedBy: 'seed_script',
      description: 'Suspension products database with version tracking'
    });

    console.log(`\n✅ Successfully uploaded ${totalUploaded} products to Firebase`);
    console.log(`📊 Version updated to: ${newVersion}`);
    console.log('\n🎉 Seed complete!');
    console.log('\nNext steps:');
    console.log('1. Open Firebase Console > Firestore Database');
    console.log('2. Check "suspension_products" collection');
    console.log('3. Check "metadata/suspension_products" document');

  } catch (error) {
    console.error('❌ Error seeding suspension products:', error);
    process.exit(1);
  }
}

// Run the appropriate function based on flag
async function main() {
  try {
    if (shouldDelete) {
      await deleteSuspensionProducts();
    } else {
      await seedSuspensionProducts();
    }
  } finally {
    // Clean up
    await admin.app().delete();
  }
}

main();
