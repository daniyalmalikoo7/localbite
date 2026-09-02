# LocalBite

A food-discovery app for independent Sydney CBD street vendors, built in Flutter.

Most street stalls cannot get onto a delivery platform: registration assumes a fixed address, set
trading hours and online payment, and a cart on Pitt Street has none of those. LocalBite lets vendors
manage their own listing instead, so someone walking around at lunchtime can see what is actually
open and where it is.

> ICT725 User Experience and Mobile Application Development — Assessment 4
> Malik Muhammad Daniyal Ahmed (20035852)

## Screens

| Discover | Vendor Detail | Search & Filter | Saved |
|---|---|---|---|
| ![Discover](docs/screenshots/01-home-discover.png) | ![Detail](docs/screenshots/02-vendor-detail.png) | ![Filter](docs/screenshots/03-search-filter.png) | ![Saved](docs/screenshots/04-saved-vendors.png) |

The same code adapts to a tablet, swapping the bottom bar for a navigation rail and showing the list
and detail side by side:

![Tablet two-pane](docs/screenshots/05-tablet-two-pane.png)

## What is implemented

| Feature | Status | Where |
|---|---|---|
| Vendor discovery by proximity and food type | Done | `screens/discover/`, `domain/vendor_query.dart` |
| Real-time open/closed status | Done | `domain/opening_hours.dart`, `state/clock_controller.dart` |
| Time-of-day reviews (Breakfast/Lunch/Dinner) | Done | `screens/vendor_detail/`, `state/reviews_controller.dart` |
| Saved vendors with live status | Done | `screens/saved/`, `state/saved_controller.dart` |
| Search & filter across five dimensions | Done | `screens/search_filter/` |
| Write a review | Done | `screens/vendor_detail/write_review_sheet.dart` |
| Live queue estimate | Done | `domain/queue_estimate.dart` |
| Responsive phone / tablet / landscape layouts | Done | `theme/breakpoints.dart`, `widgets/adaptive_nav.dart` |
| Loading, error and retry states | Done | `widgets/skeleton.dart`, `widgets/error_retry.dart`, `state/load_state.dart` |
| Map tab | Not built | placeholder screen |
| Profile and accounts | Not built | placeholder screen |
| Saving across app restarts | Not built | in-memory only |
| Real vendor backend and device GPS | Not built | seeded repository, fixed CBD origin |

## Running it

The app targets iOS, web and macOS from one codebase.

```bash
flutter pub get
flutter run -d <device-id>
```

```bash
flutter analyze && flutter test
flutter test integration_test/app_test.dart -d <device-id>
```

76 unit and widget tests pass, plus 5 end-to-end tests that drive the real app
on a simulator through the four required user flows. The analyzer reports no
issues.

## How it is put together

```
lib/
├── domain/     Pure Dart: vendors, reviews, opening hours, filtering. No Flutter imports.
├── data/       Repository interface + the in-memory seed of 14 stalls.
├── state/      Four ChangeNotifiers: clock, catalog, saved, reviews.
├── app/        Composition root, AppScope, route table.
├── screens/    One folder per screen; screen/view split so views embed in a tablet pane.
├── widgets/    Shared components (vendor card, chips, status badge, nav).
└── theme/      Design tokens and the type scale.
```

Three decisions worth calling out:

**Open/closed status is derived, never stored.** `OpeningHours.statusAt(now)` computes state and the
next transition from the vendor's own hours, so a badge cannot go stale. It handles stalls trading
past midnight by checking the previous day's window first — a van open 18:00–03:00 correctly reads
OPEN at 1am.

**One clock, subscribed to at the leaves.** A single `ClockController` ticks on the minute. Only the
widgets that display time-derived content listen to it, so a tick repaints the status badges on
Discover, Saved and Detail simultaneously without rebuilding the screens holding them.

**No third-party runtime dependencies.** State is `ChangeNotifier` + `ListenableBuilder` behind an
`InheritedWidget`. The reads are deliberately non-subscribing, which is what keeps the per-minute
tick cheap.

## Accessibility

The palette was measured against WCAG 2.1 AA before the build, not after. Body text is 16.29:1 on the
app background and secondary text 4.99:1. Brand orange `#E85D04` measures 3.50:1 on white, so it is
used only for large text and non-text UI; a darker `#BF4A02` (5.01:1) carries anything smaller.
Trading status always spells the word "OPEN" or "CLOSED" so it is never conveyed by colour alone, and
system text scaling is honoured to 200%. Filter chips and navigation tabs expose real activation
actions to assistive technology, and tap-target, labelling and contrast guidelines are asserted in
the test suite rather than assumed.
