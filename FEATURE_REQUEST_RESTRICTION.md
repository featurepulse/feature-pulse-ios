# Feature Request Restriction - Implementation Complete

## Overview
Added support for restricting feature request creation to paying users only. This feature allows developers to gate feature submission behind a subscription while still allowing free users to vote.

## Backend API (Already Live)
- ✅ Database migration applied
- ✅ Dashboard toggle in Project Settings
- ✅ API endpoints updated (GET & POST `/api/sdk/feature-requests`)
- ✅ Returns `permissions.can_create_feature_request` in GET response
- ✅ Returns 403 error with `paymentRequired` code in POST when restricted

## iOS SDK Changes

### New Files Created
1. **`Models/Permissions.swift`** - Permissions model
2. **`Models/RestrictionMode.swift`** - Restriction handling enum

### Modified Files
1. **`API/FeaturePulseAPI.swift`**
   - Updated `FeatureRequestsResponse` to include `permissions`
   - Added `paymentRequired` error case
   - Updated `fetchFeatureRequests()` to store permissions in config
   - Updated `submitFeatureRequest()` to handle 403 errors

2. **`Configuration/FeaturePulseConfiguration.swift`**
   - Added `permissions` property (auto-updated from API)
   - Added `subscriptionName` property (default: "Pro", for branded alerts)
   - Added `restrictionMode` property (nil = default alert)

3. **`Views/FeaturePulseView.swift`**
   - Added `handleFeatureRequestTap()` to check permissions
   - Added `handleRestriction()` to show alert or call callback
   - Added `getRestrictionMessage()` for branded vs generic messages
   - Added restriction alert

4. **`Localization/L10n.swift`**
   - Added `restrictionAlertTitle`
   - Added `restrictionGenericMessage`
   - Added `restrictionSubscriptionMessage(subscriptionName:)` function

## Usage Examples

### Example 1: Default Behavior (Alert)
```swift
// In your app initialization
FeaturePulseConfiguration.shared.apiKey = "your-api-key"

// That's it! Default behavior shows alert when restricted
// Shows: "Only Pro users can add feature requests..." (Pro is the default)
```

### Example 2: Custom Subscription Name (Alert)
```swift
// In your app initialization
FeaturePulseConfiguration.shared.restrictionMode = .alert(subscriptionName: "Premium")

// Shows: "Only Premium users can add feature requests..."
```

### Example 3: Custom Callback (Show Paywall)
```swift
// In your app initialization
FeaturePulseConfiguration.shared.restrictionMode = .callback {
    // Your custom logic - show paywall, navigate, etc.
    showPaywall()
}
```

## How It Works

1. **Permission Check**: When user taps "Request a Feature", the SDK checks `config.permissions.canCreateFeatureRequest`

2. **If Allowed**: Opens the feature request sheet normally

3. **If Restricted**:
   - **Default**: Shows alert with generic or branded message
   - **Callback Mode**: Calls developer's custom handler

4. **Backup Validation**: If user somehow bypasses the UI check, the API will return 403 and show the error

## Testing Checklist
- [ ] Test with restriction disabled (default behavior)
- [ ] Test with restriction enabled + free user → should show alert
- [ ] Test with restriction enabled + paying user → should allow creation
- [ ] Test default branded alert (with "Pro")
- [ ] Test custom subscription name (like "Premium")
- [ ] Test custom callback (show paywall)
- [ ] Test 403 error handling if API check fails

## Dashboard Configuration
1. Go to Project Settings
2. Find "Require Subscription to Create Feature Requests" toggle
3. Enable to restrict, disable to allow all users

## API Response Format

**GET `/api/sdk/feature-requests` Response:**
```json
{
  "success": true,
  "data": [...],
  "show_status": true,
  "permissions": {
    "can_create_feature_request": false
  }
}
```

**POST `/api/sdk/feature-requests` Error (403):**
```json
{
  "error": "PAYMENT_REQUIRED_TO_CREATE",
  "message": "Subscription required to create feature requests"
}
```

## Migration Notes
- **Backward Compatible**: Existing apps will continue to work without changes
- **Default**: `can_create_feature_request: true` (no restriction)
- **Opt-in**: Developers must enable restriction in dashboard
- **No Breaking Changes**: All new properties are optional

## Version
Added in: **v1.2.0** (Released: 2025-12-14)
