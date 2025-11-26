# Metrx Feature - Accelerometer-Based Roughness Detection

**Date:** 2025-11-26
**Status:** Planning Phase - Based on Gemini Conversation
**Priority:** Pro Tier Killer Feature

---

## 📋 Overview

The Metrx feature uses phone accelerometer + GPS data to detect trail roughness and provide objective feedback on suspension performance. This is RideMetrx's **primary competitive advantage** - turning a $0 phone into a $300+ ShockWiz alternative.

### Value Proposition
> *"See what works. Not what you think worked."*

Riders constantly tweak suspension settings but have no objective way to measure improvement. Metrx solves the "subjectivity trap" by providing measurable data.

---

## 🎯 Core Concept

### The Problem
- Riders adjust compression/rebound based on feel
- "Feel" is subjective and inconsistent
- Can't compare settings objectively between runs
- No way to prove if changes actually helped

### The Solution
- Record accelerometer data (50Hz+) + GPS during ride
- Calculate "roughness score" for trail segments
- Compare A/B runs with different settings
- Show objective improvement (or lack thereof)

**Example Output:**
```
Run 2 vs Run 1
Speed: +1.5 mph 🚀
Vibration: -12% 🎯
Verdict: Better. Your changes improved compliance at speed.
```

---

## 🏗️ Technical Architecture

### Data Collection

#### Required Sensors:
1. **Accelerometer** (Z-axis vertical motion)
   - Sample rate: 50Hz minimum
   - Measures vibration that passes through fork/shock
   - Phone MUST be rigidly mounted (handlebar/stem)

2. **GPS** (location + speed)
   - Track position for trail mapping
   - Calculate speed for speed-adjusted scores
   - Match to Strava segments (optional)

#### Data Flow:
```
Start Ride
  ↓
Calibrate Phone Orientation (gravity detection)
  ↓
Record Loop (50Hz):
  - Read accelerometer Z-axis
  - Read GPS coordinates
  - Calculate distance from start
  - Timestamp all data
  ↓
End Ride
  ↓
Process Data:
  - Bin into 10m segments
  - Calculate RMS per segment
  - Generate roughness heatmap
  ↓
Display Results
```

---

### Data Processing

#### Spatial Binning
GPS drift means you can't match exact coordinates between runs. Solution: break trail into 10-meter chunks.

```dart
class RideSegment {
  double startDistance;
  double endDistance;
  double totalVibrationEnergy;
  int sampleCount;

  double get averageRoughness => totalVibrationEnergy / sampleCount;
}
```

**Why this works:**
- Run 1: slow through section (20 seconds)
- Run 2: fast through section (15 seconds)
- Both get binned to same 10m segment → comparable

#### Roughness Calculation

**RMS (Root Mean Square)** of vertical acceleration:

```dart
// For each sample
double gForce = (accelZ.abs() - 9.8).abs();
segment.totalVibrationEnergy += gForce;
segment.sampleCount++;

// After ride
double roughness = sqrt(totalEnergy / sampleCount);
```

#### Frequency Analysis

Different frequencies = different suspension adjustments:

| Frequency | Source | Suspension Setting |
|-----------|--------|-------------------|
| 0-3 Hz | Rider inputs (pumping, cornering) | Low Speed Compression/Rebound |
| 4-20 Hz | Trail features (roots, rocks) | High Speed Compression/Rebound |
| Spike >10G | Bottom-out | Add volume spacer or HSC |

---

### A/B Comparison

**The Killer Feature:** Compare two runs objectively.

#### Speed-Adjusted Scoring
Going faster naturally increases vibration. Must account for this:

```
Scenario A: +10% speed, +10% vibration = Neutral (no improvement)
Scenario B: +10% speed, same vibration = Win! (suspension working better)
Scenario C: Same speed, -20% vibration = Win! (settings improved)
```

#### Delta Visualization

Show difference per segment:

```
[Green bars] = Smoother than baseline
[Red bars] = Harsher than baseline
[Gray] = No significant change
```

User can see: "First half improved (flow trail) but second half worse (rock garden)"

---

## 🎨 User Experience

### Recording Flow

1. **Setup Screen**
   - Select bike
   - Current settings displayed
   - "Mount phone securely" reminder
   - Calibration button

2. **Calibration**
   - "Hold phone still for 3 seconds"
   - Detect gravity vector
   - Determine phone orientation
   - Store baseline

3. **Recording Screen**
   - Big START/STOP button
   - Real-time roughness indicator (simple meter)
   - Distance counter
   - Time elapsed
   - Battery warning if <20%

4. **Results Screen**
   - Summary card (speed, vibration, verdict)
   - Heatmap visualization (color-coded trail)
   - Segment list (tap to see details)
   - "Compare to Previous Run" button
   - "Share to Community" (Pro only)

---

### Heatmap Visualization

**Color-coded trail map:**

```
Green   = Smooth (fork/shock absorbing well)
Yellow  = Moderate
Orange  = Rough
Red     = Very harsh (bottom-outs or poor damping)
```

**Tap segment for details:**
```
Meters 240-250 (Rock Garden)
Roughness: 8.2 / 10
Speed: 12 mph
Recommendation: Increase HSC 2 clicks
```

---

## 🔧 Implementation Details

### Flutter Packages Needed

```yaml
dependencies:
  sensors_plus: ^latest  # Accelerometer access
  geolocator: ^latest    # GPS tracking
  location: ^latest      # Background location
  fl_chart: ^latest      # Heatmap visualization
```

### Data Models

```dart
class RideSession {
  final String id;
  final String bikeId;
  final DateTime startTime;
  final DateTime endTime;
  final List<RideSegment> segments;
  final String? trailName;  // From Strava
  final double avgSpeed;
  final double totalDistance;
}

class RideSegment {
  final double startDistance;
  final double endDistance;
  final LatLng location;
  final double roughnessScore;  // 0-10 scale
  final double avgSpeed;
  final int sampleCount;
}

class SensorDataPoint {
  final DateTime timestamp;
  final double accelZ;      // Vertical acceleration
  final double gyroX;       // Optional: pitch/roll
  final LatLng? location;   // May be null between GPS updates
  final double? speed;
}
```

---

### Calibration Logic

```dart
Future<void> calibrateOrientation() async {
  // Collect 3 seconds of accelerometer data while stationary
  List<Vector3> samples = [];

  await for (var event in accelerometerEvents) {
    samples.add(Vector3(event.x, event.y, event.z));
    if (samples.length >= 150) break;  // 50Hz * 3 sec
  }

  // Average to find gravity vector
  Vector3 gravity = samples.reduce((a, b) => a + b) / samples.length;

  // Store rotation matrix to convert phone coords → bike coords
  _gravityVector = gravity.normalized();
}
```

---

### Recording Service

```dart
class MetrxRecordingService {
  StreamSubscription? _accelSub;
  StreamSubscription? _gpsSub;
  List<SensorDataPoint> _rawData = [];

  Future<void> startRecording() async {
    _accelSub = accelerometerEvents.listen((event) {
      _rawData.add(SensorDataPoint(
        timestamp: DateTime.now(),
        accelZ: _projectToGravity(event),  // Project to vertical axis
      ));
    });

    _gpsSub = Geolocator.getPositionStream().listen((pos) {
      // Match GPS to most recent accel sample
      _rawData.last.location = LatLng(pos.latitude, pos.longitude);
      _rawData.last.speed = pos.speed;
    });
  }

  Future<RideSession> stopRecording() async {
    await _accelSub?.cancel();
    await _gpsSub?.cancel();

    // Process raw data into segments
    return _processRawData(_rawData);
  }
}
```

---

## 🚀 MVP Implementation Plan

### Phase 1: Basic Recording (Week 1-2)
- ✅ Accelerometer data capture
- ✅ GPS tracking
- ✅ Calibration screen
- ✅ Simple recording UI
- ✅ Save to Hive

### Phase 2: Processing (Week 3-4)
- ✅ Spatial binning algorithm
- ✅ RMS calculation
- ✅ Roughness scoring (0-10 scale)
- ✅ Basic visualization (list view)

### Phase 3: Comparison (Week 5-6)
- ✅ A/B comparison logic
- ✅ Delta calculation
- ✅ Speed adjustment
- ✅ Verdict generator

### Phase 4: Polish (Week 7-8)
- ✅ Heatmap visualization
- ✅ Trail name lookup (Strava API)
- ✅ Share to community
- ✅ Recommendations engine

---

## ⚠️ Technical Challenges & Solutions

### Challenge 1: Phone Mounting
**Problem:** Phone in pocket = useless data (body absorbs vibration)

**Solution:**
- Onboarding tutorial: "You must mount phone to bike"
- Calibration step validates mounting (detect if phone moves during calibration)
- Warning if mounting seems loose (excessive rotational movement)

### Challenge 2: Battery Drain
**Problem:** 50Hz sampling + GPS = heavy battery use

**Solutions:**
- Battery check before start (<20% = warning)
- Reduce GPS frequency (1Hz is enough)
- Pause recording when stopped (detect via GPS speed = 0)
- Background mode optimization

### Challenge 3: Data Volume
**Problem:** 50Hz * 60min = 180,000 samples

**Solutions:**
- Don't store raw samples (process on-the-fly)
- Only store per-segment aggregates
- Typical ride: 50 segments * 100 bytes = 5KB (tiny!)

### Challenge 4: GPS Drift
**Problem:** GPS accuracy ±3-5 meters

**Solution:**
- 10m segments are larger than drift margin
- Use Kalman filter for GPS smoothing (optional)
- Accept that precision isn't perfect (it's relative comparison that matters)

---

## 🎯 Success Metrics

### User Engagement
- % of rides recorded with Metrx
- Average recordings per user per month
- A/B comparison usage rate

### Conversion
- Free → Pro conversion from Metrx paywall
- "Metrx convinced me to upgrade" survey responses

### Technical
- Recording completion rate (start → finish without crash)
- Average data processing time (<5 seconds)
- Battery drain per hour (<15%)

---

## 📊 Competitive Analysis

| Feature | ShockWiz ($300) | Motion Inst. ($1000+) | RideMetrx Pro |
|---------|-----------------|------------------------|---------------|
| **Hardware** | External sensor | External sensor | Your phone |
| **Cost** | $300 | $1000+ | $30/year |
| **Setup Time** | 10 min install | 20 min install | 30 sec mount |
| **Data** | Fork/shock specific | Multi-sensor | Aggregate vibration |
| **Accuracy** | Very high | Highest | Good enough |
| **A/B Testing** | Yes | Yes | ✅ Yes |
| **Trail Context** | No | Limited | ✅ Strava integration |
| **Community** | No | No | ✅ Share heatmaps |

**Our Position:** 80% of the value for 10% of the cost.

---

## 🔮 Future Enhancements

### Short Term
- Export to CSV for analysis in Excel
- Compare across multiple bikes
- "Best settings" leaderboard per trail

### Medium Term
- Machine learning: predict optimal settings
- Integration with suspension service intervals
- Shock dyno correlation (partner with Vorsprung?)

### Long Term
- Bluetooth integration with ShockWiz (for users who have both)
- Professional rider partnerships for baseline data
- Suspension manufacturer partnerships (Fox/RockShox API access)

---

## 📚 References

- Original Gemini conversation PDF (in project root)
- ShockWiz user manual (competitor research)
- Flutter sensors_plus documentation
- Strava API v3 documentation

---

**Document Version:** 1.0
**Last Updated:** 2025-11-26
**Status:** Ready for development
