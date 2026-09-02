import 'package:flutter/material.dart';

import '../app/app_tab.dart';
import '../widgets/adaptive_nav.dart';
import 'discover/discover_screen.dart';
import 'map/map_placeholder_screen.dart';
import 'profile/profile_screen.dart';
import 'saved/saved_screen.dart';

/// Tab host.
///
/// `IndexedStack` keeps all four subtrees alive, so the Discover scroll
/// position and chip selection survive a trip to Saved and back.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  AppTab _tab = AppTab.discover;

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavScaffold(
      current: _tab,
      onSelected: (tab) => setState(() => _tab = tab),
      body: IndexedStack(
        index: _tab.index,
        children: const [
          DiscoverScreen(),
          MapPlaceholderScreen(),
          SavedScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }
}
