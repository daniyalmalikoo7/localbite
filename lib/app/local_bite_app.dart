import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vendor_repository.dart';
import '../state/catalog_controller.dart';
import '../state/clock_controller.dart';
import '../state/reviews_controller.dart';
import '../state/saved_controller.dart';
import '../theme/app_theme.dart';
import 'app_router.dart';
import 'app_scope.dart';

/// Owns the controllers for the lifetime of the app and disposes them.
class LocalBiteApp extends StatefulWidget {
  const LocalBiteApp({super.key, this.repository, this.clock});

  /// Overridable so tests can supply fixed data and a frozen clock.
  final VendorRepository? repository;
  final ClockController? clock;

  @override
  State<LocalBiteApp> createState() => _LocalBiteAppState();
}

class _LocalBiteAppState extends State<LocalBiteApp> {
  late final VendorRepository _repository =
      widget.repository ?? InMemoryVendorRepository();
  late final ClockController _clock;
  late final CatalogController _catalog;
  late final SavedController _saved;
  late final ReviewsController _reviews;
  late final bool _ownsClock;

  @override
  void initState() {
    super.initState();
    _ownsClock = widget.clock == null;
    _clock = widget.clock ?? ClockController();
    if (_ownsClock) _clock.start();
    _catalog = CatalogController(repository: _repository, clock: _clock);
    _saved = SavedController(
      // Two stalls pre-saved so the Saved tab demonstrates live status
      // immediately rather than opening empty.
      initial: const {'ahmeds-shawarma', 'street-ramen-co'},
    );
    _reviews = ReviewsController(repository: _repository);
  }

  @override
  void dispose() {
    _catalog.dispose();
    _saved.dispose();
    _reviews.dispose();
    if (_ownsClock) _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      clock: _clock,
      catalog: _catalog,
      saved: _saved,
      reviews: _reviews,
      child: MaterialApp(
        title: 'LocalBite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRouter.shell,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.overlayDarkIcons,
          // Honours the system text size while bounding it, so a 3x setting
          // cannot break the layout outright.
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.6,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
