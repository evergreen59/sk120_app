import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/communication_log/communication_log_page.dart';
import '../features/control/control_page.dart';
import '../features/groups/data_groups_page.dart';
import '../features/history/history_page.dart';
import '../features/monitoring/monitoring_page.dart';
import '../features/settings/settings_page.dart';
import 'theme/app_theme.dart';

final appRouter = GoRouter(
  initialLocation: '/control',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/control',
              builder: (context, state) => const ControlPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/monitor',
              builder: (context, state) => const MonitoringPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/groups',
              builder: (context, state) => const DataGroupsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'logs',
                  builder: (context, state) => const CommunicationLogPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const destinations = [
    (Icons.tune_rounded, '控制'),
    (Icons.monitor_heart_outlined, '监控'),
    (Icons.grid_view_rounded, '数据组'),
    (Icons.history_rounded, '历史'),
    (Icons.settings_outlined, '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final wide = MediaQuery.sizeOf(context).width > 1000;
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: Row(
        children: [
          if (!mobile)
            Container(
              width: wide ? 220 : 84,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.cyan,
                          size: 25,
                        ),
                        if (wide) ...[
                          const SizedBox(width: 10),
                          Text(
                            'XY-SK120',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: NavigationRail(
                      selectedIndex: current,
                      onDestinationSelected: navigationShell.goBranch,
                      labelType: wide
                          ? NavigationRailLabelType.all
                          : NavigationRailLabelType.selected,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.$1),
                            selectedIcon: Icon(destination.$1),
                            label: Text(destination.$2),
                          ),
                      ],
                    ),
                  ),
                  if (wide)
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'BLE / Modbus RTU',
                        style: TextStyle(color: AppColors.dim, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: current,
              onDestinationSelected: navigationShell.goBranch,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.$1),
                    label: destination.$2,
                  ),
              ],
            )
          : null,
    );
  }
}
