import 'package:flutter/material.dart';

class NavDestinationSpec {
  const NavDestinationSpec({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Responsive navigation shell: bottom bar on narrow screens (phones), a
/// compact rail on medium screens (small tablets / split-screen), and an
/// extended rail on wide screens (tablets landscape, desktop, web).
class AdaptiveNavShell extends StatelessWidget {
  const AdaptiveNavShell({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  final List<NavDestinationSpec> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  static const _mediumBreakpoint = 600.0;
  static const _wideBreakpoint = 1000.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < _mediumBreakpoint) {
      return Scaffold(
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }

    final extended = width >= _wideBreakpoint;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              extended: extended,
              minExtendedWidth: 220,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
