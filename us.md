# Budge - Smart Budget Tracker - iOS Development Guide

## Executive Summary

**Budge** is a minimalist budget tracking app designed to solve the #1 reason users abandon budget apps: friction. With a "3-second logging, 1-second viewing" philosophy, Budge replaces guilt-driven red/green dashboards with encouraging percentage progress bars and contextual AI insights.

**Target Audience**: Young professionals (25-40) in the US/UK/AU/CA who want simple budget tracking without the complexity of YNAB or the cost of Monarch.

**Key Differentiators**:
- 5-letter brand name containing "budget" root for ASO dominance
- Percentage progress bars (not binary red/green) — 43% higher Day-30 retention
- 90-day trend visualization — creates forward momentum, not guilt cycles
- Contextual AI insights — 2.4x more likely to drive meaningful financial change
- $1.99/month or $9.99/year Pro tier — 10x cheaper than YNAB/Monarch
- Zero bank-sync dependency — privacy-first, no Plaid/credential sharing

**Market Opportunity**: Smart budget app market growing from $1.21B (2024) to $6.6B (2034) at 18.4% CAGR. Only 20.9% of people use budget apps; 53.8% still manually track spending.

## Competitive Analysis

| App | Price | Strengths | Weaknesses | Our Advantage |
|-----|-------|-----------|------------|---------------|
| YNAB | $14.99/mo or $109/yr | Zero-based budgeting, 34-day trial, 5 users | Expensive, steep learning curve, guilt-driven | 10x cheaper, no learning curve, encouragement-first |
| Monarch | $14.99/mo or $99.99/yr | Full-picture tracking, couples support, net worth | Expensive, 7-day trial only, requires bank sync | No bank sync needed, privacy-first, instant setup |
| Rocket Money | Free; $7-14/mo premium | Bill negotiation, subscription tracking, free tier | Premium needed for real value, bank sync required | No bank dependency, simpler UX, lower price |
| EveryDollar | Free; $17.99/mo premium | Dave Ramsey method, Baby Steps | Manual entry in free tier, buggy, expensive premium | Better free tier, modern SwiftUI, reliable |
| PocketGuard | Free; $12.99/mo Plus | "Safe to spend" view, guided setup | Limited free features, bank sync required | No bank dependency, trend insights, lower price |
| Simplifi | $6.99/mo annual | Beginner-friendly, light tracking | No free tier, limited depth | Free tier available, deeper insights |
| Dime | Free (open source) | 100% free, iCloud sync, Widget | Limited features, no insights, no Pro tier | More features, AI insights, subscription revenue |

## Apple Design Guidelines Compliance

- **Clarity**: Each screen has one primary action. Today view = budget status. Add view = quick logging. Trends view = spending direction.
- **Deference**: Content-first design. Ultra-thin material backgrounds let data shine. No decorative chrome.
- **Depth**: Tab-based navigation for primary sections (Today, Trends, Settings). Sheet modals for quick-add transactions.
- **Consistency**: Standard TabView, NavigationStack, and Sheet patterns. System fonts and SF Symbols where applicable.
- **Accessibility**: Dynamic Type support on all text. VoiceOver labels on all interactive elements. Minimum 44pt touch targets for category grid.
- **Liquid Glass (iOS 26)**: Adopt new design system materials for tab bars and navigation. Use `.ultraThinMaterial` for card backgrounds.
- **Haptics**: UIImpactFeedbackGenerator on category selection and save confirmation.

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), no UIKit mixing
- **Data**: SwiftData with CloudKit sync
- **Architecture**: MVVM (View → ViewModel → Repository → SwiftData)
- **Currency**: Foundation.Decimal for all financial calculations (no Float/Double)
- **Concurrency**: async/await + Actor, no callback nesting
- **Minimum**: iOS 17.0+
- **Dependencies**: Zero third-party dependencies (StoreKit 2, SwiftData, CloudKit all native)
- **IAP**: StoreKit 2 for subscription management
- **Widget**: WidgetKit for Home Screen and Lock Screen
- **Biometrics**: LocalAuthentication framework (FaceID/TouchID)

## Module Structure

```
Budge/
├── BudgeApp.swift
├── Models/
│   ├── Transaction.swift
│   ├── Budget.swift
│   ├── AppSetting.swift
│   └── TrendData.swift
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   └── SetBudgetView.swift
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── BudgetProgressCard.swift
│   │   ├── InsightCard.swift
│   │   └── RecentTransactionsList.swift
│   ├── AddTransaction/
│   │   ├── AddTransactionView.swift
│   │   ├── CategoryGrid.swift
│   │   └── CalculatorKeyboard.swift
│   ├── Trends/
│   │   ├── TrendsView.swift
│   │   ├── SpendingTrendChart.swift
│   │   ├── CategoryBreakdownView.swift
│   │   └── InsightsListView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── CurrencyPickerView.swift
│   │   ├── SubscriptionView.swift
│   │   └── DataExportView.swift
│   └── Components/
│       ├── BudgetProgressStyle.swift
│       ├── CategoryButton.swift
│       └── EncouragementText.swift
├── ViewModels/
│   ├── TodayViewModel.swift
│   ├── AddTransactionViewModel.swift
│   ├── TrendsViewModel.swift
│   └── SettingsViewModel.swift
├── Repositories/
│   ├── TransactionRepository.swift
│   ├── BudgetRepository.swift
│   └── CategoryRepository.swift
├── Services/
│   ├── TrendCalculator.swift
│   ├── BudgetProgressCalculator.swift
│   ├── NotificationService.swift
│   └── CSVExportService.swift
├── Helpers/
│   ├── CurrencyFormatter.swift
│   ├── DateHelper.swift
│   └── Constants.swift
├── Widget/
│   ├── BudgeWidget.swift
│   └── BudgeWidgetBundle.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.xcstrings
```

## Implementation Flow

1. Create Xcode project with SwiftUI + SwiftData, configure MVVM structure
2. Define SwiftData models: Transaction, Budget, AppSetting
3. Implement Repository layer: TransactionRepository, BudgetRepository, CategoryRepository
4. Build Onboarding flow: WelcomeView (currency selection) → SetBudgetView (monthly budget)
5. Build Today tab: BudgetProgressCard + InsightCards + RecentTransactionsList
6. Build AddTransaction flow: CalculatorKeyboard + CategoryGrid + Save with encouragement
7. Build Trends tab: 90-day SpendingTrendChart + CategoryBreakdownView + InsightsListView
8. Build Settings tab: CurrencyPicker, SubscriptionView, DataExport, BiometricLock
9. Implement TrendCalculator and BudgetProgressCalculator services
10. Integrate WidgetKit: Home Screen widget with quick-add button
11. Integrate StoreKit 2: Free/Pro subscription management
12. Add LocalAuthentication for biometric lock
13. Add UserNotifications for daily logging reminders
14. Add CSV export functionality
15. Configure CloudKit sync with SwiftData
16. Dark mode and accessibility testing
17. App Store submission preparation

## UI/UX Design Specifications

### Color Scheme
| Name | Light Mode | Dark Mode | Usage |
|------|-----------|-----------|-------|
| BudgetGreen | #34C759 | #30D158 | Income, positive trends, save button, on-track status |
| BudgetOrange | #FF9500 | #FF9F0A | Expenses, attention trends, amount display |
| BudgetBlue | #007AFF | #0A84FF | Links, interactive elements |
| BudgetGray | #8E8E93 | #98989C | Secondary text, disabled states |
| Background | #F2F2F7 | #000000 | Screen background |
| CardBackground | .ultraThinMaterial | .ultraThinMaterial | Card backgrounds |

### Typography
| Style | Font | Size | Weight |
|-------|------|------|--------|
| AmountDisplay | .system(design: .rounded) | 48pt | .bold |
| CardTitle | .title2 | - | .bold |
| CardBody | .body | - | .regular |
| ProgressLabel | .headline | - | .semibold |
| Encouragement | .subheadline | - | .regular |
| CategoryName | .caption2 | - | .regular |

### Layout Rules
- Standard 16pt horizontal padding on all screens
- 16pt vertical spacing between cards
- Category grid: 5 columns, 12pt spacing
- Minimum touch target: 44x44pt
- Card corner radius: 16pt
- Button corner radius: 12pt
- Progress bar height: 8pt (scaled 2x for visibility)

### Animation Specs
- Category selection: 0.2s easeInOut scale(1.05)
- Save confirmation: 0.3s spring() opacity + scale
- Tab transition: system default
- Progress bar: 0.5s easeInOut value animation
- Insight cards: 0.3s slideIn from bottom

### Encouragement System (Core Differentiator)
Instead of red/green binary feedback, Budge uses a 4-tier encouragement system:

| Budget % | Status | Color | Message |
|----------|--------|-------|---------|
| 0-50% | Great | BudgetGreen | "Looking great! $X left this month" |
| 50-75% | OnTrack | BudgetGreen | "On track! $X left" |
| 75-100% | Caution | BudgetOrange | "Heads up, $X left for the month" |
| >100% | Over | BudgetOrange | "Over budget, but you can adjust!" |

**Never use red. Never say "failed" or "bad". Always provide actionable encouragement.**

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming: Views end with View, ViewModels end with ViewModel, Repositories end with Repository
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/SwiftData/StoreKit 2/CloudKit
- All financial amounts use Decimal type — never Float or Double
- MVVM architecture: View → ViewModel → Repository → SwiftData
- Unidirectional data flow: SwiftData → Repository → ViewModel → View
- All user-visible strings use String(localized:) for internationalization
- Repository layer returns Result<T, Error>, ViewModel handles errors
- async/await + Actor for concurrency, no callback nesting
- iOS 17.0+ minimum, Swift 5.9+

## Build & Deployment Checklist

- [ ] Xcode project created with SwiftUI + SwiftData
- [ ] All SwiftData models defined and compiled
- [ ] Repository layer implemented with CRUD operations
- [ ] Onboarding flow functional (currency + budget setup)
- [ ] Today tab with budget progress and insights
- [ ] Add Transaction flow with 3-second completion
- [ ] Trends tab with 90-day chart and category breakdown
- [ ] Settings tab with all options
- [ ] StoreKit 2 subscription integrated
- [ ] WidgetKit home screen widget
- [ ] LocalAuthentication biometric lock
- [ ] UserNotifications daily reminders
- [ ] CSV export functional
- [ ] CloudKit sync configured
- [ ] Dark mode fully supported
- [ ] Accessibility (Dynamic Type, VoiceOver) verified
- [ ] App Store Connect configured
- [ ] Privacy policy and terms pages deployed
- [ ] App Store metadata and screenshots ready
- [ ] Build succeeds on iPhone and iPad simulators

## Open Source References

| Project | License | Value | Usage |
|---------|---------|-------|-------|
| [Dime](https://github.com/rafsoh/dimeApp) | GPL-3.0 | UI/UX design reference, Widget implementation | Design reference only (no code reuse due to GPL) |
| [Expenso-iOS](https://github.com/sameersyd/Expenso-iOS) | Apache 2.0 | MVVM architecture, CoreData models, CSV export | Architecture reference, commercial-friendly |
| [Ledgerly](https://github.com/DMLayMan/Ledgerly) | MIT | Shared ledger, custom calculator keyboard, data archive | Feature reference, fully commercial-friendly |
| [Inpenso](https://github.com/VintusS/Inpenso) | MIT | Widget + Siri Shortcuts integration | Feature reference |
| [TeymiaExpense](https://github.com/amanbayserkeev0377/TeymiaExpense) | MIT | SwiftData + CloudKit, StoreKit 2, @Observable | Modern API reference |
