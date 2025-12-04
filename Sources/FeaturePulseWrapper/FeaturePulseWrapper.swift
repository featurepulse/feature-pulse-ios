// Wrapper module for FeaturePulse XCFramework
// This module ensures SPM can properly link the binary framework
// and exposes the StableID dependency that's compiled into the binary

@_exported import StableID

// Note: The FeaturePulse module from the XCFramework is automatically available
// when this package is imported. Users can use:
//   import FeaturePulse
