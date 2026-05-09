# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "iCloud同步" → iCloud capability required
- "每日记账提醒" / "通知提醒" → Push Notifications required
- "订阅" / "Pro版" / "StoreKit 2" → In-App Purchase required
- "Siri语音记账" / "Siri Shortcuts" → Siri required
- "Widget" → WidgetKit (no entitlement needed, code-level only)
- "生物识别锁定" / "FaceID/TouchID" → LocalAuthentication (no entitlement needed, code-level only)

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| In-App Purchase | ✅ Configured | Xcode project signing |
| Push Notifications | ✅ Configured | Xcode project signing |
| iCloud | ✅ Configured | Xcode project signing |
| Siri | ✅ Configured | Xcode project signing |

## Code-Level Features (No Entitlement Required)
| Feature | Framework | Status |
|---------|-----------|--------|
| Widget | WidgetKit | Will implement in code |
| Biometric Lock | LocalAuthentication | Will implement in code |
| CSV Export | Foundation | Will implement in code |
| CloudKit Sync | SwiftData + CloudKit | Will implement in code |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| App Store Connect IAP | ⏳ Pending | Create subscription products in App Store Connect after code generation |
| CloudKit Container | ⏳ Pending | Configure CloudKit container in Apple Developer Portal |
| Siri Intent Definition | ⏳ Pending | Add .intentdefinition file in code generation phase |

## No Configuration Needed
- HealthKit: Not a health app
- Location Services: No location features
- Camera/Photo Library: No camera features
- Sign in with Apple: No authentication required
- Apple Watch: Not in V1 scope
- Background Modes: Not needed for V1

## Verification
- Build succeeded after configuration: ⏳ Pending (will verify in Step 6)
- All entitlements correct: ⏳ Pending
