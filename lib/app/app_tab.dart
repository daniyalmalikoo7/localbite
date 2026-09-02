import 'package:flutter/material.dart';

/// The four destinations in the bottom navigation.
enum AppTab {
  discover('Discover', Icons.storefront_outlined, Icons.storefront_rounded),
  map('Map', Icons.map_outlined, Icons.map_rounded),
  saved('Saved', Icons.favorite_border_rounded, Icons.favorite_rounded),
  profile('Profile', Icons.person_outline_rounded, Icons.person_rounded);

  const AppTab(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
