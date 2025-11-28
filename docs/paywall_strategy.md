# Paywall Display Strategy

## Overview

RideMetrx implements a non-intrusive, user-respectful paywall strategy that encourages Pro subscriptions without alienating free users. This document outlines the implementation, configuration, and reasoning behind our approach.

## Philosophy

**Goal**: Convert free users to Pro subscribers while maintaining a positive user experience.

**Principles**:
- Show the paywall at meaningful moments (first use, milestones)
- Respect user decisions (long cooldowns after dismissal)
- Never interrupt active workflows
- Automatically stop showing once subscribed

## Implementation

### Core Component: PaywallDisplayManager

**Location**: `lib/features/purchases/domain/paywall_display_manager.dart`

This service manages all paywall display logic using SharedPreferences for persistent, user-specific tracking.

#### Key Methods

```dart
// Check if paywall should be displayed
static Future<bool> shouldShowPaywall({
  required bool isPro,
  required bool hasNoBikes,
})

// Record when paywall is shown
static Future<void> recordPaywallShown()

// Record when user dismisses paywall
static Future<void> recordPaywallDismissed()

// Reset tracking (called when user subscribes)
static Future<void> resetPaywallTracking()

// Get current status for debugging
static Future<Map<String, dynamic>> getDisplayStatus()
```

### Display Rules

#### 1. Never Show to Pro Users
```dart
if (isPro) return false;
```
Pro users will never see the paywall, regardless of other conditions.

#### 2. First-Time Users
New users with no bikes always see the paywall on first app use. This is an onboarding moment where they're learning the app and understand the value proposition.

#### 3. Cooldown Periods
After dismissal, the paywall respects cooldown periods:

- **Standard Cooldown**: 7 days minimum between shows
- **Extended Cooldown**: 30 days after 2+ dismissals

#### 4. User-Specific Tracking
All tracking uses Firebase UID, ensuring:
- Data persists across app reinstalls (if user re-authenticates)
- Each user has independent tracking
- No cross-device spam (device-independent)

## Configuration

### Adjustable Constants

Located in `PaywallDisplayManager`:

```dart
// Minimum days between normal shows
static const int _minDaysBetweenShows = 7;

// Number of dismissals before extended pause
static const int _maxDismissBeforePause = 2;

// Days to wait after multiple dismissals
static const int _extendedPauseDays = 30;
```

### Tuning Recommendations

**More Aggressive** (higher conversion, higher churn risk):
```dart
static const int _minDaysBetweenShows = 3;
static const int _maxDismissBeforePause = 3;
static const int _extendedPauseDays = 14;
```

**Less Aggressive** (lower conversion, better retention):
```dart
static const int _minDaysBetweenShows = 14;
static const int _maxDismissBeforePause = 1;
static const int _extendedPauseDays = 60;
```

## User Flow

### New User Journey

```
Day 0: User signs up, opens app
  ↓
  Sees "Welcome" card with 3 tasks:
  - Complete Profile
  - Add Your First Bike
  - Go Pro! ← Paywall shown
  ↓
  User taps "Maybe Later"
  ↓
  recordPaywallDismissed() called
  dismiss_count = 1
  ↓
Day 1-6: Paywall hidden
  ↓
Day 7: Paywall shows again (if still not Pro)
  ↓
  User dismisses again
  ↓
  dismiss_count = 2
  ↓
Day 8-37: Extended cooldown (30 days)
  ↓
Day 38: Paywall shows again
  ↓
  User subscribes!
  ↓
  resetPaywallTracking() called
  Paywall never shows again ✅
```

### Subscription Event

When user purchases Pro (anywhere in the app):
1. `PurchaseNotifier._updateSubscriptionStatus()` detects Pro status
2. `PaywallDisplayManager.resetPaywallTracking()` is called
3. All tracking data cleared
4. Paywall permanently hidden

## Integration Points

### 1. OfflineBikesList Widget

**Location**: `lib/features/bikes/presentation/widgets/offline_bikes_list.dart`

Checks on initialization whether to show the "Go Pro!" action:

```dart
Future<void> _checkPaywallDisplay() async {
  final user = ref.read(userNotifierProvider);
  final shouldShow = await PaywallDisplayManager.shouldShowPaywall(
    isPro: user.isPro,
    hasNoBikes: widget.bikes.isEmpty,
  );

  if (mounted) {
    setState(() => shouldShowPaywall = shouldShow);
  }
}
```

Conditionally renders the paywall action:

```dart
if (shouldShowPaywall)
  ConnectivityWidgetWrapper(
    child: NewUserAction(
      title: 'Go Pro!',
      icon: Icon(Icons.monetization_on_outlined),
      screen: PaywallScreen(
        onDismiss: () async {
          await PaywallDisplayManager.recordPaywallDismissed();
        },
      ),
    ),
  ),
```

### 2. PaywallScreen

**Location**: `lib/features/purchases/presentation/screens/paywall_screen.dart`

Records display and dismissal:

```dart
@override
void initState() {
  super.initState();
  // ... fetch offerings ...

  // Record that paywall was shown
  PaywallDisplayManager.recordPaywallShown();
}

// In "Maybe Later" button:
onPressed: () {
  widget.onDismiss?.call();  // Calls recordPaywallDismissed()
  context.pop();
}
```

### 3. PurchaseNotifier

**Location**: `lib/features/purchases/domain/purchase_notifier.dart`

Resets tracking when user becomes Pro:

```dart
void _updateSubscriptionStatus(CustomerInfo customerInfo) {
  // ... check entitlements ...

  if (hasPro) {
    // ... update state ...

    // Reset paywall tracking since user is now Pro
    PaywallDisplayManager.resetPaywallTracking();
  }
}
```

## Data Storage

### SharedPreferences Keys

All keys are namespaced with Firebase UID:

```dart
'paywall_last_shown_$userId'    // Timestamp (milliseconds since epoch)
'paywall_dismiss_count_$userId' // Integer count
```

### Data Lifecycle

**Created**: First time paywall is shown or dismissed
**Updated**: Each show/dismiss event
**Deleted**: When user subscribes to Pro

## Testing

### Manual Testing

1. **First-time experience**:
   ```dart
   // Delete app, sign up as new user
   // Verify paywall shows in welcome card
   ```

2. **Dismiss behavior**:
   ```dart
   // Tap "Maybe Later"
   // Verify paywall hidden for 7 days
   // Fast-forward device date +7 days
   // Verify paywall shows again
   ```

3. **Subscription flow**:
   ```dart
   // Subscribe to Pro
   // Verify paywall never shows again
   // Check SharedPreferences keys are deleted
   ```

### Debug Helper

Get current status for any user:

```dart
final status = await PaywallDisplayManager.getDisplayStatus();
print(status);
```

Example output:
```json
{
  "last_shown": "2024-01-15T10:30:00.000Z",
  "days_since_last_shown": 5,
  "dismiss_count": 1,
  "min_days_between_shows": 7
}
```

Or for never-shown users:
```json
{
  "never_shown": true,
  "dismiss_count": 0
}
```

## Future Enhancements

### Potential Additions

1. **Milestone-Based Triggers**:
   ```dart
   // Show after user adds 3rd bike
   // Show after 10 rides recorded
   // Show after first Strava sync
   ```

2. **Feature-Gated Paywall**:
   ```dart
   // Show when accessing Pro-only features
   PaywallScreen(featureName: 'Strava Integration')
   ```

3. **A/B Testing**:
   ```dart
   // Test different cooldown periods
   // Track conversion rates
   ```

4. **Analytics Integration**:
   ```dart
   // Log paywall impressions
   // Track dismiss vs. subscribe rates
   // Measure time-to-conversion
   ```

## Best Practices

### DO ✅
- Show at natural pauses (onboarding, after completing tasks)
- Respect user decisions with long cooldowns
- Make dismissal easy and obvious
- Highlight specific value propositions
- Reset tracking when users subscribe

### DON'T ❌
- Interrupt active workflows
- Show immediately after dismissal
- Make dismissal difficult or hidden
- Show to Pro users
- Use generic "Upgrade Now" messages

## Comparison to Industry Standards

### Good Examples
- **Things 3**: Shows Pro benefits during onboarding, respects dismissal
- **Bear**: Gentle reminders after creating many notes
- **Carrot Weather**: Feature-gated with clear value prop

### Bad Examples
- **Aggressive Apps**: Daily popups, forced full-screen interruptions
- **Deceptive Patterns**: Hidden dismiss buttons, fake "limited time" offers
- **Spam Behavior**: Shows every app open

## Metrics to Monitor

Track these metrics to optimize the strategy:

1. **Conversion Rate**: % of free users who subscribe
2. **Dismissal Rate**: % who dismiss vs. engage
3. **Time to Conversion**: Days from first show to purchase
4. **Churn Correlation**: Does paywall frequency affect retention?
5. **Cooldown Effectiveness**: Optimal days between shows

## Support

For issues or questions about the paywall strategy:

1. Check `PaywallDisplayManager.getDisplayStatus()` for current state
2. Review logs in console (prefix: `PaywallDisplayManager:`)
3. Verify SharedPreferences keys for user
4. Confirm RevenueCat integration is working

## Related Documentation

- [RevenueCat Integration](./revenuecat_integration.md)
- [Subscription Management](./subscription_management.md)
- [User State Architecture](./user_state.md)
