# FeaturePulse Demo

This is a minimal SwiftUI app that consumes the local SDK package.

## Run

1. Open `FeaturePulseDemo.xcodeproj` in Xcode.
2. Select the `FeaturePulseDemo` scheme.
3. Run with the local mock API, or set `FEATUREPULSE_USE_MOCKS=0` and add `FEATUREPULSE_API_KEY` to connect to a real project.
4. Run on an iOS 17+ simulator.

The demo shows the SDK in a tab, a modal sheet, and a CTA banner. Mock mode uses `http://127.0.0.1:8765` by default and the Xcode target starts the local mock server automatically during Debug builds. The server returns local feature requests, vote updates, submissions, user sync, and activity tracking responses. Set `FEATUREPULSE_BASE_URL` to use a different local server URL.
