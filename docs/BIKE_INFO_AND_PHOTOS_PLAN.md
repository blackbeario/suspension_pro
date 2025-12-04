# Bike Make/Model and Photos - Implementation Plan

## Overview
Add bike make/model context to community settings, plus optional bike photos for Pro users who opt in.

## Current State
- ✅ `CommunitySetting` has fork/shock components
- ✅ `Bike` model has `bikePic` field (already exists!)
- ❌ No bike make/model info
- ❌ No user settings system
- ❌ No photo display in community

## Phase 1: Add Bike Make/Model (2-3 hours)

### 1.1 Update CommunitySetting Model
**File:** `lib/features/community/domain/models/community_setting.dart`

Add fields:
```dart
// Bike info (helpful context for users)
@HiveField(CommunitySettingFields.bikeMake)
final String? bikeMake;

@HiveField(CommunitySettingFields.bikeModel)
final String? bikeModel;
```

Update:
- Constructor
- `copyWith()`
- `fromFirestore()`
- `toFirestore()`
- Hive field constants

Add helper:
```dart
/// Get bike display string
String get bikeDisplay {
  if (bikeMake != null && bikeModel != null) {
    return '$bikeMake $bikeModel';
  } else if (bikeMake != null) {
    return bikeMake!;
  }
  return 'Bike not specified';
}
```

### 1.2 Update Seed Data
**File:** `scripts/seed_community_data.js`

Add realistic bike data:
```javascript
const bikes = {
  enduro: [
    { make: 'Santa Cruz', model: 'Megatower' },
    { make: 'Specialized', model: 'Enduro' },
    { make: 'Trek', model: 'Slash' },
    { make: 'Yeti', model: 'SB165' },
    { make: 'Pivot', model: 'Firebird' },
  ],
  trail: [
    { make: 'Ibis', model: 'Ripmo' },
    { make: 'Santa Cruz', model: 'Bronson' },
    { make: 'Specialized', model: 'Stumpjumper' },
    { make: 'Trek', model: 'Fuel EX' },
  ],
  downhill: [
    { make: 'Santa Cruz', model: 'V10' },
    { make: 'YT', model: 'TUES' },
    { make: 'Specialized', model: 'Demo' },
  ],
};

// In generateCommunitySetting():
const bikeCategory = /* determine from components */;
const bike = bikes[bikeCategory][Math.floor(Math.random() * bikes[bikeCategory].length)];

return {
  // ... existing fields
  bikeMake: bike.make,
  bikeModel: bike.model,
};
```

### 1.3 Update UI
**File:** `lib/features/community/presentation/widgets/setting_card.dart`

Add bike info to card:
```dart
// After user info
if (setting.bikeMake != null || setting.bikeModel != null)
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(Icons.pedal_bike, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          setting.bikeDisplay,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  ),
```

**File:** `lib/features/community/presentation/screens/setting_detail_screen.dart`

Add to header section:
```dart
// Bike Info Section
if (setting.bikeMake != null || setting.bikeModel != null)
  _buildInfoCard(
    title: 'Bike',
    icon: Icons.pedal_bike,
    content: setting.bikeDisplay,
  ),
```

### 1.4 Firestore Rules (Already Ready)
No changes needed - community_settings rules already allow read/update.

### 1.5 Hive Adapter
Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing Phase 1
- [ ] Reseed community data with bike make/model
- [ ] Verify settings display bike info in list
- [ ] Verify settings display bike info in detail view
- [ ] Verify search works with bike make/model
- [ ] Verify offline caching includes bike fields

---

## Phase 2: User Settings Infrastructure (4-6 hours)

### 2.1 Create AppSettings Model
**File:** `lib/features/settings/domain/models/app_settings.dart`

```dart
@HiveType(typeId: HiveTypes.appSettings)
class AppSettings {
  @HiveField(0)
  final bool showBikePhotos;

  @HiveField(1)
  final bool enablePushNotifications;

  @HiveField(2)
  final CacheSize cacheSize;

  @HiveField(3)
  final bool autoSyncEnabled;

  const AppSettings({
    this.showBikePhotos = false, // Default OFF for performance
    this.enablePushNotifications = false,
    this.cacheSize = CacheSize.medium,
    this.autoSyncEnabled = true,
  });

  // copyWith, toJson, fromJson...
}

enum CacheSize {
  small,   // 50 settings
  medium,  // 100 settings (default)
  large,   // 200 settings
}
```

### 2.2 Create SettingsNotifier
**File:** `lib/features/settings/domain/settings_notifier.dart`

```dart
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  static const _hiveBoxName = 'app_settings';

  @override
  Future<AppSettings> build() async {
    final box = await Hive.openBox<AppSettings>(_hiveBoxName);

    // Load from Hive
    final settings = box.get('settings');
    if (settings != null) {
      return settings;
    }

    // Default settings
    return const AppSettings();
  }

  Future<void> updateShowBikePhotos(bool value) async {
    final current = await future;
    final updated = current.copyWith(showBikePhotos: value);
    await _saveSettings(updated);
    state = AsyncData(updated);
  }

  // Similar methods for other settings...

  Future<void> _saveSettings(AppSettings settings) async {
    final box = await Hive.openBox<AppSettings>(_hiveBoxName);
    await box.put('settings', settings);

    // Pro users: sync to Firebase
    if (ref.read(purchaseNotifierProvider).isPro) {
      await _syncToFirebase(settings);
    }
  }

  Future<void> _syncToFirebase(AppSettings settings) async {
    final userId = ref.read(authNotifierProvider).value?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'appSettings': settings.toJson()}, SetOptions(merge: true));
  }
}
```

### 2.3 Create Settings Screen
**File:** `lib/features/settings/presentation/screens/settings_screen.dart`

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _buildSection(
              title: 'Community',
              children: [
                SwitchListTile(
                  title: const Text('Show Bike Photos'),
                  subtitle: const Text('Display photos in community settings (may affect performance)'),
                  value: settings.showBikePhotos,
                  onChanged: (value) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateShowBikePhotos(value);
                  },
                ),
              ],
            ),

            _buildSection(
              title: 'Sync',
              children: [
                SwitchListTile(
                  title: const Text('Auto-sync'),
                  subtitle: const Text('Automatically sync changes to cloud (Pro only)'),
                  value: settings.autoSyncEnabled,
                  enabled: ref.watch(purchaseNotifierProvider).isPro,
                  onChanged: (value) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateAutoSync(value);
                  },
                ),

                ListTile(
                  title: const Text('Cache Size'),
                  subtitle: Text('${settings.cacheSize.displayName} (${settings.cacheSize.settingsCount} settings)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show dialog to select cache size
                  },
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

### 2.4 Add Settings Button to App
**Options:**
1. Add to Community tab app bar
2. Add to Bikes tab app bar
3. Add to Profile/Account screen (if exists)
4. Add to bottom nav (if space)

### Testing Phase 2
- [ ] Settings screen loads correctly
- [ ] Toggles update settings in Hive
- [ ] Pro users sync settings to Firebase
- [ ] Free users use Hive-only mode
- [ ] Settings persist across app restarts

---

## Phase 3: Bike Photos (6-8 hours)

**Prerequisites:**
- ✅ Phase 1 complete (bike make/model)
- ✅ Phase 2 complete (user settings with `showBikePhotos` toggle)
- ✅ User explicitly opts in via settings

### 3.1 Update CommunitySetting Model
**File:** `lib/features/community/domain/models/community_setting.dart`

Add fields:
```dart
// Bike photos (Pro only, optional)
@HiveField(CommunitySettingFields.bikeThumbnailUrl)
final String? bikeThumbnailUrl;  // 150x150px, ~10KB

@HiveField(CommunitySettingFields.bikePhotoUrl)
final String? bikePhotoUrl;  // 800x800px, ~100KB
```

### 3.2 Firebase Storage Setup

**Storage Structure:**
```
/community_bikes/
  /{settingId}/
    thumbnail.jpg  (150x150, quality: 60)
    photo.jpg      (800x800, quality: 80)
```

**Storage Rules:**
```javascript
service firebase.storage {
  match /b/{bucket}/o {
    match /community_bikes/{settingId}/{file} {
      // Anyone can read
      allow read: if request.auth != null;

      // Pro users can upload their own
      allow write: if request.auth != null &&
                      isPro(request.auth.uid) &&
                      // Limit file size
                      request.resource.size < 2 * 1024 * 1024; // 2MB max
    }
  }
}
```

### 3.3 Image Processing Service
**File:** `lib/core/services/image_processing_service.dart`

```dart
class ImageProcessingService {
  /// Process image in isolate for better performance
  static Future<ProcessedImages> processImage(File imageFile) async {
    return compute(_processImageIsolate, imageFile.path);
  }

  static Future<ProcessedImages> _processImageIsolate(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Invalid image');

    // Create thumbnail (150x150)
    final thumbnail = img.copyResize(
      image,
      width: 150,
      height: 150,
      interpolation: img.Interpolation.average,
    );
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 60);

    // Create photo (800x800)
    final photo = img.copyResize(
      image,
      width: 800,
      height: 800,
      interpolation: img.Interpolation.average,
    );
    final photoBytes = img.encodeJpg(photo, quality: 80);

    return ProcessedImages(
      thumbnail: thumbnailBytes,
      photo: photoBytes,
    );
  }

  /// Upload processed images to Firebase Storage
  static Future<ImageUrls> uploadImages(
    String settingId,
    ProcessedImages images,
  ) async {
    final storage = FirebaseStorage.instance;
    final thumbnailRef = storage.ref('community_bikes/$settingId/thumbnail.jpg');
    final photoRef = storage.ref('community_bikes/$settingId/photo.jpg');

    // Upload in parallel
    await Future.wait([
      thumbnailRef.putData(images.thumbnail),
      photoRef.putData(images.photo),
    ]);

    // Get download URLs
    final thumbnailUrl = await thumbnailRef.getDownloadURL();
    final photoUrl = await photoRef.getDownloadURL();

    return ImageUrls(
      thumbnail: thumbnailUrl,
      photo: photoUrl,
    );
  }
}

class ProcessedImages {
  final Uint8List thumbnail;
  final Uint8List photo;

  ProcessedImages({required this.thumbnail, required this.photo});
}

class ImageUrls {
  final String thumbnail;
  final String photo;

  ImageUrls({required this.thumbnail, required this.photo});
}
```

### 3.4 Update SettingCard Widget
**File:** `lib/features/community/presentation/widgets/setting_card.dart`

```dart
// Only show if user opted in AND photo exists
Widget _buildBikePhoto(CommunitySetting setting, bool showPhotos) {
  if (!showPhotos || setting.bikeThumbnailUrl == null) {
    return const SizedBox.shrink();
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: CachedNetworkImage(
      imageUrl: setting.bikeThumbnailUrl!,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      memCacheWidth: 150,  // Cache at actual size
      memCacheHeight: 150,
      placeholder: (context, url) => Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: const Icon(Icons.pedal_bike, color: Colors.grey),
      ),
      errorWidget: (context, url, error) => Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    ),
  );
}

@override
Widget build(BuildContext context, WidgetRef ref) {
  final settings = ref.watch(settingsNotifierProvider).valueOrNull;
  final showPhotos = settings?.showBikePhotos ?? false;

  return Card(
    child: InkWell(
      onTap: () => _navigateToDetail(context, setting),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Photo on left (if enabled)
            _buildBikePhoto(setting, showPhotos),
            if (showPhotos && setting.bikeThumbnailUrl != null)
              const SizedBox(width: 12),

            // Rest of card content
            Expanded(
              child: Column(/* existing content */),
            ),
          ],
        ),
      ),
    ),
  );
}
```

### 3.5 Update Detail Screen
**File:** `lib/features/community/presentation/screens/setting_detail_screen.dart`

```dart
// Show larger photo at top of detail screen
Widget _buildBikePhoto(CommunitySetting setting, bool showPhotos) {
  if (!showPhotos || setting.bikePhotoUrl == null) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.all(16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: setting.bikePhotoUrl!,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        memCacheWidth: 800,
        memCacheHeight: 800,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 64),
        ),
      ),
    ),
  );
}
```

### 3.6 Add Photo Upload (Phase 2 - Pro Users Sharing)
This will be part of the "Share Settings" flow for Pro users.

When Pro user shares a setting:
1. Optionally select bike photo from gallery
2. Process in isolate (show loading)
3. Upload to Storage
4. Save URLs to Firestore

### Testing Phase 3
- [ ] User can toggle "Show Bike Photos" setting
- [ ] Photos only load when toggle is ON
- [ ] Thumbnails load efficiently in list (no jank)
- [ ] Full photos load in detail view
- [ ] Memory usage stays reasonable
- [ ] Offline mode works (gracefully fails, shows placeholder)
- [ ] Image processing in isolate doesn't block UI

---

## Performance Considerations

### Image Loading Best Practices
1. **Use `cached_network_image` package:**
   - Memory cache with limits
   - Disk cache for offline
   - Automatic retry logic

2. **Lazy loading in list:**
   - Only load visible items
   - Dispose images when scrolled out of view

3. **Memory limits:**
   ```dart
   CachedNetworkImageProvider(
     imageUrl,
     maxHeight: 150,
     maxWidth: 150,
   )
   ```

4. **Isolate for processing:**
   - Use `compute()` for image resizing
   - Don't block main thread

5. **User control:**
   - Default OFF for all users
   - Clear warning about performance impact
   - Easy toggle in settings

### Estimated Bundle Size Impact
- `cached_network_image`: +100KB
- `image` package: +500KB
- Total: ~600KB (acceptable)

### Estimated Performance Impact
- **With photos OFF:** No impact
- **With photos ON (thumbnails only in list):**
  - Initial load: +1-2 seconds (one-time network fetch)
  - Scrolling: Smooth (cached after first load)
  - Memory: +5-10MB (50 thumbnails @ ~10KB each)
- **Detail view (full photo):**
  - Load time: 1-2 seconds (one-time)
  - Memory: +100KB per photo

---

## Implementation Order

### Do Now (Phase 1)
✅ **Add bike make/model** - Low risk, high value, no performance impact

### Do Soon (Phase 2)
✅ **User settings infrastructure** - Foundation for many features

### Do Later (Phase 3)
🔜 **Bike photos** - Nice-to-have, implement carefully with user control

---

## Alternative: Start with Detail View Only

If you want to test photos without full settings infrastructure:

1. Skip user settings toggle initially
2. Only show full photo in detail view (not list)
3. Add toggle later when building settings screen

This gives you:
- ✅ Proof of concept for photos
- ✅ No performance impact on list view
- ✅ Can delay settings infrastructure
- ❌ All users see photos (can't opt out)

---

## Questions for You

1. **Priority:** Should we implement Phase 1 (bike make/model) now?
2. **Settings Screen:** Do you already have a settings/profile screen, or should we create one?
3. **Photos Timeline:** When do you want photos? (I'd suggest after settings infrastructure is ready)
4. **Photo Upload:** Will this be part of "Phase 2: Pro Sharing" feature, or separate?

Let me know which direction you want to go, and I'll start implementing!
