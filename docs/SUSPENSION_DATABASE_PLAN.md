# Suspension Component Database - Implementation Plan

## 🎯 Overview

Create a comprehensive database of current suspension products (forks & shocks) to enable:
- Easy component selection when adding bikes
- Consistent product naming across the app
- Baseline settings recommendations by rider weight
- Better community filtering by exact products
- Future compatibility checks and upgrade suggestions

---

## 📊 Feasibility Assessment

### ✅ Highly Feasible (95% Confidence)

#### Component Database
- **200-300 current products** (2020-2024 model years)
- **Accurate specs** from manufacturer websites
- **Coverage:**
  - Fox (38, 36, 40, 34, 32, Float X2, DHX2, Float DPX2, etc.)
  - RockShox (ZEB, Lyrik, Pike, Yari, Boxxer, Super Deluxe, Vivid, etc.)
  - Ohlins (RXF36, RXF38, TTX, DH38, etc.)
  - Manitou (Mezzer, Mattoc, Machete, Dorado, McLeod, etc.)
  - DVO (Diamond, Onyx, Jade, Topaz, etc.)
  - Cane Creek (Helm, DBair, DB8, VALT, etc.)
  - EXT (Era, Storia, Arma, etc.)
  - MRP (Ribbon, Stage)

### ⚠️ Possible with Caveats (60-70% Confidence)

#### Baseline Settings Recommendations
- **Can provide:** Manufacturer air pressure charts
- **Can provide:** Conservative damping starting points
- **Cannot provide:** Terrain-specific tuning
- **Cannot provide:** Bike-specific kinematics adjustments
- **Cannot provide:** Personal preference tuning

**Solution:** Provide baseline starting points with clear disclaimers

---

## 🗄️ Data Structure

### Firestore Collection: `suspension_products`

```javascript
/suspension_products/{productId}
{
  // Core Identity
  type: "fork" | "shock",
  brand: "Fox",
  model: "38 Factory",
  year: "2023",
  category: "Enduro/DH" | "Trail" | "XC" | "DH",

  // Technical Specs
  specs: {
    // Fork-specific
    travel: ["160mm", "170mm", "180mm"],
    wheelSizes: ["27.5\"", "29\""],
    damperType: "GRIP2",
    springType: "Air" | "Coil",
    axleStandard: "15x110mm Kabolt",
    tubeType: "34mm",

    // Shock-specific
    eyeToEye: "230mm",
    stroke: "65mm",
    mountType: "Trunnion" | "Standard",
  },

  // Metadata
  discontinued: false,
  msrp: 1299,
  weight: "2,290g (29\", 170mm)",
  imageUrl: "https://...",

  // Baseline Settings
  baselineSettings: {
    airPressureChart: [
      { weight: "150 lbs", psi: "65-70" },
      { weight: "160 lbs", psi: "70-75" },
      { weight: "170 lbs", psi: "75-80" },
      { weight: "180 lbs", psi: "80-85" },
      { weight: "190 lbs", psi: "85-90" },
      { weight: "200 lbs", psi: "90-95" },
    ],
    defaultRebound: "12 clicks from full fast",
    defaultCompression: {
      HSC: "12 clicks from full firm",
      LSC: "10 clicks from full firm"
    },
    recommendedSag: "20-25%",
    volumeSpacers: {
      recommended: 1,
      note: "Add spacers for more progression"
    }
  },

  // Features
  features: [
    "EVOL Air Spring",
    "Kashima Coating",
    "Tool-free adjustments",
    "High-speed & low-speed compression"
  ],

  // Links
  manufacturerUrl: "https://...",
  manualUrl: "https://..."
}
```

---

## 🎨 UI/UX Flow

### Adding a Bike

```
AddBikeScreen
  ↓
Tap "Select Fork"
  ↓
SuspensionPickerScreen (type: 'fork')
  ├── Search: "Fox 38"
  ├── Filter by Brand: [Fox] [RockShox] [Ohlins] [All]
  ├── Filter by Category: [XC] [Trail] [Enduro] [DH]
  ├── Filter by Wheel Size: [27.5"] [29"]
  ├── Filter by Travel: [120-140mm] [140-160mm] [160-180mm] [180mm+]
  │
  └── Results:
       ┌─────────────────────────────────────────┐
       │ Fox 38 Factory (2023)                   │
       │ Enduro/DH • 160-180mm • 29"            │
       │ GRIP2 Damper • $1,299                   │
       └─────────────────────────────────────────┘
       ┌─────────────────────────────────────────┐
       │ Fox 36 Factory (2023)                   │
       │ Trail/Enduro • 140-170mm • 29"         │
       │ GRIP2 Damper • $1,099                   │
       └─────────────────────────────────────────┘

Tap to Select
  ↓
Product Detail Sheet
  ├── Full Specs
  ├── "Create Baseline Setting?" Button
  │   └── Enter Rider Weight: [180 lbs]
  │       ↓
  │       Shows calculated air pressure: 82 psi
  │       Shows default damping: HSC 12, LSC 10, etc.
  │       ↓
  │       "Create Setting" → Auto-creates first setting
  │
  └── "Select This Fork" → Saves to bike
```

### Viewing Component in App

```
BikeDetailScreen
  ├── Fork: Fox 38 Factory (2023)
  │   └── Tap to view specs
  │       ├── Travel: 170mm
  │       ├── Damper: GRIP2
  │       ├── MSRP: $1,299
  │       └── "View Community Settings for this Fork" →
  │           Filters community by exact product
  │
  └── Shock: Fox DHX2 Factory (2023)
      └── Similar detail view
```

---

## 💻 Implementation Components

### 1. Data Models

```dart
// lib/features/suspension/domain/models/suspension_product.dart

enum SuspensionType { fork, shock }
enum SuspensionCategory { xc, trail, enduro, dh, downhill }
enum SpringType { air, coil }

class SuspensionProduct {
  final String id;
  final SuspensionType type;
  final String brand;
  final String model;
  final String year;
  final SuspensionCategory category;
  final SuspensionSpecs specs;
  final BaselineSettings? baselineSettings;
  final int? msrp;
  final String? weight;
  final bool discontinued;
  final String? imageUrl;
  final List<String> features;

  // Methods
  String get displayName => '$year $brand $model';
  String get shortName => '$brand $model';
}

class SuspensionSpecs {
  // Fork specs
  final List<String>? travel;
  final List<String>? wheelSizes;
  final String? damperType;
  final String? tubeType;
  final String? axleStandard;

  // Shock specs
  final String? eyeToEye;
  final String? stroke;
  final String? mountType;

  // Common
  final SpringType springType;
}

class BaselineSettings {
  final List<AirPressurePoint> airPressureChart;
  final String defaultRebound;
  final CompressionDefaults defaultCompression;
  final String recommendedSag;
  final VolumeSpacerInfo? volumeSpacers;
}
```

### 2. Picker Screen

```dart
// lib/features/suspension/presentation/screens/suspension_picker_screen.dart

class SuspensionPickerScreen extends ConsumerStatefulWidget {
  final SuspensionType type; // fork or shock
  final Function(SuspensionProduct) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${type == SuspensionType.fork ? 'Fork' : 'Shock'}'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          SearchBar(
            onChanged: (query) => _filterProducts(query),
          ),

          // Active filters chips
          if (_hasActiveFilters)
            FilterChipsRow(
              filters: _activeFilters,
              onRemove: _removeFilter,
            ),

          // Products list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => _showProductDetail(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. Baseline Settings Generator

```dart
// lib/features/suspension/domain/services/baseline_settings_service.dart

class BaselineSettingsService {

  /// Generate a baseline ComponentSetting for a product and rider weight
  ComponentSetting generateBaselineSetting({
    required SuspensionProduct product,
    required String riderWeight,
    String? ridingStyle, // Optional: 'xc', 'trail', 'enduro', 'park'
  }) {
    if (product.baselineSettings == null) {
      throw Exception('No baseline settings available for this product');
    }

    final baseline = product.baselineSettings!;

    // Interpolate air pressure from chart
    final airPressure = _interpolateAirPressure(
      baseline.airPressureChart,
      riderWeight,
    );

    // Parse default damping settings
    final reboundClicks = _parseClicks(baseline.defaultRebound);
    final hscClicks = _parseClicks(baseline.defaultCompression.hsc);
    final lscClicks = _parseClicks(baseline.defaultCompression.lsc);

    // Calculate sag percentage
    final sagPercent = _parseSagRange(baseline.recommendedSag).middle;

    return ComponentSetting(
      sag: sagPercent.toString(),
      springRate: null, // Not applicable for air
      preload: null,
      hsc: hscClicks.toString(),
      lsc: lscClicks.toString(),
      hsr: reboundClicks.toString(), // HSR same as general rebound
      lsr: reboundClicks.toString(), // LSR same as general rebound
      volume_spacers: baseline.volumeSpacers?.recommended.toString(),
    );
  }

  String _interpolateAirPressure(
    List<AirPressurePoint> chart,
    String riderWeight,
  ) {
    // Parse weight (e.g., "180 lbs" → 180)
    final weight = int.parse(riderWeight.split(' ').first);

    // Find closest points in chart
    // ... interpolation logic ...

    return calculatedPsi.toString();
  }
}
```

### 4. Notifier/Provider

```dart
// lib/features/suspension/domain/suspension_products_notifier.dart

@riverpod
class SuspensionProductsNotifier extends _$SuspensionProductsNotifier {
  @override
  Future<List<SuspensionProduct>> build() async {
    return await _fetchProducts();
  }

  Future<List<SuspensionProduct>> _fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('suspension_products')
        .where('discontinued', isEqualTo: false)
        .orderBy('brand')
        .orderBy('model')
        .get();

    return snapshot.docs
        .map((doc) => SuspensionProduct.fromFirestore(doc))
        .toList();
  }

  List<SuspensionProduct> filterByType(SuspensionType type) {
    return state.value?.where((p) => p.type == type).toList() ?? [];
  }

  List<SuspensionProduct> searchProducts(String query) {
    // Search by brand, model, year
    // ...
  }
}
```

---

## 📅 Implementation Phases

### Phase 1: Database Creation (Week 1)
- [ ] Research and compile suspension products data
- [ ] Create JSON database with ~200 products
- [ ] Validate accuracy (spot-check popular models)
- [ ] Create Firestore schema
- [ ] Build seed script
- [ ] Deploy to Firestore

**Deliverable:** `suspension_products` collection in Firestore

### Phase 2: Basic Picker UI (Week 2)
- [ ] Create `SuspensionProduct` domain model
- [ ] Build `SuspensionPickerScreen` with search/filter
- [ ] Add product card UI
- [ ] Implement product detail sheet
- [ ] Integrate with bike creation flow

**Deliverable:** Users can select fork/shock from database when adding bike

### Phase 3: Baseline Settings (Week 3)
- [ ] Create `BaselineSettingsService`
- [ ] Implement air pressure interpolation
- [ ] Build "Create Baseline Setting" dialog
- [ ] Add rider weight input
- [ ] Generate `ComponentSetting` from baseline
- [ ] Add disclaimers and education

**Deliverable:** Users can generate baseline settings for their weight

### Phase 4: Integration & Polish (Week 4)
- [ ] Update existing bike edit flow
- [ ] Add "View Community Settings for this Product" filter
- [ ] Add product images (optional)
- [ ] Implement product comparison
- [ ] Add compatibility checks (wheel size, etc.)
- [ ] Add "Popular Products" section

**Deliverable:** Full feature integration across app

---

## ⏱️ Time Estimates

| Phase | Task | Hours |
|-------|------|-------|
| 1 | Research & data compilation | 4-6 |
| 1 | JSON structuring & validation | 2 |
| 1 | Firestore schema & seed script | 1-2 |
| 2 | Domain models | 2 |
| 2 | Picker UI | 3-4 |
| 2 | Product detail sheet | 1-2 |
| 2 | Integration with bike flow | 2 |
| 3 | Baseline settings service | 2-3 |
| 3 | Weight input & calculation | 1-2 |
| 3 | UI for baseline generation | 2 |
| 4 | Community filter integration | 1-2 |
| 4 | Compatibility checks | 2-3 |
| 4 | Polish & testing | 3-4 |
| **Total** | | **26-37 hours** |

---

## 🎯 Success Metrics

### User Experience
- ✅ Users can find their fork/shock in <30 seconds
- ✅ 90%+ of popular products are in database
- ✅ Baseline settings are within ±5 psi of manufacturer recommendations
- ✅ Reduced typos/inconsistencies in product naming

### Technical
- ✅ Search results return in <200ms
- ✅ Picker UI loads in <1 second
- ✅ Baseline generation is instant (<100ms)

### Business
- ✅ Increased completion rate for bike setup
- ✅ Better data for community filtering
- ✅ Foundation for future Pro features

---

## 🚀 Future Enhancements

### Pro Features (Post-MVP)
1. **Upgrade Recommendations**
   - "Users with similar setups upgraded to..."
   - Price comparison
   - Performance improvements

2. **Compatibility Checker**
   - Fork travel vs. frame geometry
   - Shock stroke vs. frame leverage
   - Warning for mismatches

3. **Tune Assistant**
   - "Your pressure seems high for your weight"
   - "Try adding a volume spacer for more progression"
   - Track changes and suggest adjustments

4. **Price Tracking**
   - Alert when products go on sale
   - Used market value estimates
   - Upgrade ROI calculator

### Community Features
1. **Product Popularity Stats**
   - "Fox 38 is used by 23% of riders"
   - "Most popular for Enduro category"

2. **Product Reviews/Notes**
   - Users can add notes about products
   - "Requires frequent servicing"
   - "Works great for heavier riders"

---

## 📋 Data Accuracy Strategy

### What We Guarantee (95%+):
- ✅ Product names, brands, model years
- ✅ Travel options, wheel sizes
- ✅ Damper types (GRIP2, Charger 3, etc.)
- ✅ General categories (XC/Trail/Enduro/DH)
- ✅ MSRP (as of compilation date)

### What Requires Disclaimers:
- ⚠️ Baseline air pressure (manufacturer starting point)
- ⚠️ Damping settings (adjust to preference/terrain)
- ⚠️ Pricing (MSRP, may vary by retailer)

### What We Cannot Provide:
- ❌ Aftermarket tuning service specs
- ❌ Proprietary shop tuning guides
- ❌ Rider-specific "perfect" settings
- ❌ Every obscure/discontinued product

---

## 🔍 Sample Products

### Forks (Top 10 Most Popular)
1. Fox 38 Factory (2023-2024) - $1,299
2. Fox 36 Factory (2023-2024) - $1,099
3. RockShox ZEB Ultimate (2023-2024) - $1,150
4. RockShox Lyrik Ultimate (2023-2024) - $999
5. Fox 40 Factory (2023-2024) - $1,599
6. RockShox Boxxer Ultimate (2023-2024) - $1,299
7. Ohlins RXF38 M.2 (2023) - $1,399
8. Manitou Mezzer Pro (2022-2023) - $899
9. Fox 34 Factory (2023-2024) - $949
10. RockShox Pike Ultimate (2023-2024) - $899

### Shocks (Top 10 Most Popular)
1. Fox Float X2 Factory (2023-2024) - $849
2. Fox DHX2 Factory (2023-2024) - $949
3. RockShox Super Deluxe Ultimate (2023-2024) - $799
4. Fox Float DPX2 Factory (2022-2023) - $649
5. RockShox Super Deluxe Select+ (2023) - $549
6. Ohlins TTX Air (2023) - $899
7. Cane Creek DBair IL (2022-2023) - $699
8. RockShox Vivid Ultimate (2023) - $899
9. DVO Topaz Air (2023) - $599
10. EXT Storia LOK (2023) - $999

---

## 📝 Next Steps

When ready to implement:

1. **Review this plan** - Confirm scope and priorities
2. **Start with Phase 1** - Database creation (can be done independently)
3. **Validate sample data** - Review ~20 products for accuracy
4. **Begin UI work** - Once data structure is confirmed
5. **Iterate based on feedback** - Add/adjust as needed

---

## 💭 Open Questions

1. **Image hosting?** Store product images or link to manufacturer sites?
2. **Update frequency?** How often should we refresh the database (yearly, quarterly)?
3. **User contributions?** Allow users to suggest missing products?
4. **Coil spring support?** Include spring rate charts for coil shocks?
5. **International pricing?** USD only or multi-currency?

---

**Status:** Ready for implementation
**Priority:** High (post-Community feature)
**Estimated Start:** After Phase 1 Community testing complete
