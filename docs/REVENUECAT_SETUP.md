# RevenueCat Setup Guide for RideMetrx

This guide walks you through setting up RevenueCat for RideMetrx Pro subscriptions.

## Overview

RideMetrx uses RevenueCat to manage in-app subscriptions. RevenueCat provides:
- Server-side receipt validation (no backend needed)
- Cross-platform subscription management
- Built-in analytics and metrics
- Free up to $2,500 Monthly Tracked Revenue (MTR)
- Automatic SHA-256 certificate compliance (required as of Jan 24, 2025)

## Prerequisites

- Apple Developer Account (for App Store Connect)
- Google Play Developer Account (for Google Play Console) - optional, for Android
- RevenueCat account (free at [app.revenuecat.com](https://app.revenuecat.com))

---

## Step 1: Create RevenueCat Account & App

1. Go to [https://app.revenuecat.com](https://app.revenuecat.com) and sign up
2. Create a new project called "RideMetrx"
3. Add an app:
   - **App name**: RideMetrx
   - **Bundle ID** (iOS): `io.vibesoftware.ridemetrx`
   - **Package name** (Android): `io.vibesoftware.ridemetrx`

---

## Step 2: Configure App Store Connect Products

### Create Subscriptions in App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app > **Features** > **In-App Purchases**
3. Click **+** to create a new subscription group:
   - **Reference Name**: RideMetrx Pro
   - **Group Name**: pro_subscriptions

4. Create two auto-renewable subscriptions:

#### Monthly Subscription
- **Product ID**: `io.vibesoftware.ridemetrx.pro.monthly`
- **Reference Name**: RideMetrx Pro Monthly
- **Subscription Group**: pro_subscriptions
- **Subscription Duration**: 1 Month
- **Price**: $2.99 USD (or your chosen price)
- **Localized Titles & Descriptions**:
  - **Display Name**: RideMetrx Pro (Monthly)
  - **Description**: Monthly subscription to RideMetrx Pro features including cloud sync, roughness detection, A/B testing, and Strava integration.

#### Annual Subscription
- **Product ID**: `io.vibesoftware.ridemetrx.pro.annual`
- **Reference Name**: RideMetrx Pro Annual
- **Subscription Group**: pro_subscriptions
- **Subscription Duration**: 1 Year
- **Price**: $29.99 USD (or your chosen price)
- **Localized Titles & Descriptions**:
  - **Display Name**: RideMetrx Pro (Annual)
  - **Description**: Annual subscription to RideMetrx Pro features including cloud sync, roughness detection, A/B testing, and Strava integration. Best value!

5. Submit for review (Apple requires subscriptions to be reviewed)

---

## Step 3: Configure RevenueCat Dashboard

### 3.1 Connect App Store

1. In RevenueCat dashboard, go to your app's settings
2. Navigate to **Platform Settings** > **App Store**
3. Click **Configure** and follow the instructions to:
   - Generate an App Store Connect API Key
   - Upload the API key to RevenueCat
   - RevenueCat will automatically sync your products

### 3.2 Create Entitlement

1. Go to **Entitlements** in the sidebar
2. Click **+ New**
3. Create entitlement:
   - **Identifier**: `pro`
   - **Display Name**: Pro Features
   - **Description**: Access to all RideMetrx Pro features

### 3.3 Create Products

1. Go to **Products** in the sidebar
2. Click **+ New** twice to create two products:

#### Product 1: Monthly
- **Identifier**: `pro_monthly`
- **Store Product ID** (iOS): `io.vibesoftware.ridemetrx.pro.monthly`
- **Type**: Subscription
- **Entitlements**: Select `pro`

#### Product 2: Annual
- **Identifier**: `pro_annual`
- **Store Product ID** (iOS): `io.vibesoftware.ridemetrx.pro.annual`
- **Type**: Subscription
- **Entitlements**: Select `pro`

### 3.4 Create Offering

1. Go to **Offerings** in the sidebar
2. Click **+ New**
3. Create offering:
   - **Identifier**: `default`
   - **Display Name**: Default Offering
   - **Description**: Default paywall offering
   - **Packages**:
     - Add package: `Monthly` → Product: `pro_monthly` → Package Type: `Monthly`
     - Add package: `Annual` → Product: `pro_annual` → Package Type: `Annual`
4. Set this as the **Current Offering**

---

## Step 4: Get API Keys

1. In RevenueCat dashboard, go to **Project Settings** > **API Keys**
2. Under **Public app-specific API keys**, copy:
   - **iOS**: `appl_xxxxxxxxxxxxxxxxxx`
   - **Android**: `goog_xxxxxxxxxxxxxxxxxx` (if applicable)

3. Add these keys to your `.env` file:

```bash
# RevenueCat API Keys
REVENUECAT_IOS_API_KEY=appl_xxxxxxxxxxxxxxxxxx
REVENUECAT_ANDROID_API_KEY=goog_xxxxxxxxxxxxxxxxxx
```

**⚠️ IMPORTANT**: Never commit the `.env` file to git. It's already in `.gitignore`.

---

## Step 5: Testing Subscriptions

### Test in Sandbox Environment

1. Create a **Sandbox Tester** account in App Store Connect:
   - Go to **Users and Access** > **Sandbox Testers**
   - Create a new tester with a unique email
   - **DO NOT** verify the email

2. On your test device:
   - Sign out of your real Apple ID in **Settings** > **App Store**
   - Run the app and navigate to the paywall
   - Attempt to purchase a subscription
   - You'll be prompted to sign in with your Sandbox tester account
   - Complete the purchase (no real money charged)

3. Verify in RevenueCat:
   - Go to **Dashboard** > **Customers**
   - Find your test user (by Firebase UID or RevenueCat anonymous ID)
   - Verify the subscription shows as active

### Restoring Purchases

Test the "Restore Purchases" button:
1. Delete and reinstall the app
2. Sign in with the same Firebase account
3. Navigate to paywall and tap "Restore Purchases"
4. Verify the subscription is restored

---

## Step 6: Production Checklist

Before going live:

- [ ] All subscriptions approved in App Store Connect
- [ ] RevenueCat connected to App Store with valid API key
- [ ] Entitlement `pro` configured
- [ ] Products `pro_monthly` and `pro_annual` created and linked
- [ ] Offering `default` created with both packages
- [ ] API keys added to `.env` file
- [ ] `.env` file added to `.gitignore`
- [ ] Tested purchase flow in sandbox
- [ ] Tested restore purchases flow
- [ ] Tested subscription features (cloud sync, etc.)
- [ ] Verified subscription status shows correctly in app

---

## Troubleshooting

### "No subscription options available"

- Check that you called `fetchOfferings()` in `PaywallScreen`
- Verify products are configured in RevenueCat dashboard
- Check RevenueCat logs in Xcode console for errors
- Ensure API key is correct in `.env` file

### "Purchase cancelled" error

- Normal behavior when user taps outside the purchase sheet
- No action needed

### "Purchase not allowed"

- User is in a region where subscriptions are not allowed
- Or user has restrictions enabled in Screen Time settings
- Or sandbox tester issue - create a new sandbox tester

### "Failed to load products"

- Check internet connection
- Verify RevenueCat API key is correct
- Check RevenueCat dashboard for service status
- Ensure products are synced from App Store Connect

### Subscription not syncing across devices

- Verify user is signed in to Firebase Auth on both devices
- Check that `SyncService` is configured to sync for Pro users
- Verify cloud sync is not disabled in settings

---

## Code Architecture

### Key Files

- `lib/features/purchases/domain/purchase_state.dart` - Subscription state model
- `lib/features/purchases/domain/purchase_notifier.dart` - Business logic
- `lib/features/purchases/presentation/screens/paywall_screen.dart` - Paywall UI
- `lib/features/purchases/presentation/widgets/pro_feature_gate.dart` - Feature gating widget
- `lib/core/services/sync_service.dart` - Cloud sync (Pro only)
- `lib/main.dart` - RevenueCat initialization

### How Subscription Status Works

1. App initializes RevenueCat SDK in `main.dart`
2. `PurchaseNotifier` checks subscription status via `Purchases.getCustomerInfo()`
3. Status is determined by checking for active `pro` entitlement
4. Status is cached in `SharedPreferences` for offline grace period
5. UI updates automatically via Riverpod state management
6. Features are gated using `ProFeatureGate` widget or `checkProFeature()` function

### Offline Handling

- Subscription status is cached locally in `SharedPreferences`
- If offline, cached status is used (with expiry date check)
- Grace period: Users can access Pro features offline until expiry date
- Once online, RevenueCat syncs the latest status

---

## Support & Resources

- **RevenueCat Docs**: [https://docs.revenuecat.com](https://docs.revenuecat.com)
- **Flutter SDK Docs**: [https://docs.revenuecat.com/docs/flutter](https://docs.revenuecat.com/docs/flutter)
- **RevenueCat Support**: [https://community.revenuecat.com](https://community.revenuecat.com)
- **App Store Guidelines**: [https://developer.apple.com/app-store/subscriptions/](https://developer.apple.com/app-store/subscriptions/)

---

## Migration Notes

This app was migrated from `in_app_purchase` to `purchases_flutter` (RevenueCat) because:
- Previous IAP implementation never worked and caused app rejection
- RevenueCat handles all receipt validation server-side (no backend needed)
- RevenueCat automatically handles SHA-256 certificate compliance
- Free for apps under $2,500 MTR/month
- Better error handling and user experience
- Cross-platform support (iOS and Android)
