import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/communication_log/communication_log_page.dart';
import '../features/control/control_page.dart';
import '../features/groups/data_groups_page.dart';
import '../features/history/history_page.dart';
import '../features/monitoring/monitoring_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/settings_subpages.dart';
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
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const HistoryPage(),
                ),
              ],
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
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'protection',
                  builder: (context, state) => const ProtectionPage(),
                ),
                GoRoute(
                  path: 'advanced',
                  builder: (context, state) => const AdvancedPowerPage(),
                ),
                GoRoute(
                  path: 'device',
                  builder: (context, state) => const DeviceSettingsPage(),
                ),
                GoRoute(
                  path: 'ble',
                  builder: (context, state) => const BleDevicesPage(),
                ),
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
    (Icons.settings_outlined, '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final wide = MediaQuery.sizeOf(context).width > 1000;
    final current = navigationShell.currentIndex;
    final subpage = GoRouterState.of(context).uri.path.split('/').length > 2;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundMid,
              AppColors.background,
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            const _AmbientLight(
              alignment: Alignment(-1.1, -1.1),
              color: AppColors.electricBlue,
            ),
            const _AmbientLight(
              alignment: Alignment(1.0, -0.2),
              color: AppColors.cyan,
            ),
            const _AmbientLight(
              alignment: Alignment(0.0, 1.2),
              color: AppColors.purple,
            ),
            Row(
              children: [
                if (!mobile && !subpage)
                  Container(
                    width: wide ? 220 : 84,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.border),
                      ),
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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
                              style: TextStyle(
                                color: AppColors.dim,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Expanded(child: navigationShell),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: mobile
          ? (subpage
                ? null
                : _GlassTabBar(
                    current: current,
                    onChanged: navigationShell.goBranch,
                  ))
          : null,
    );
  }
}

class _AmbientLight extends StatelessWidget {
  const _AmbientLight({required this.alignment, required this.color});
  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: IgnorePointer(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.2), Colors.transparent],
          ),
        ),
      ),
    ),
  );
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({required this.current, required this.onChanged});
  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(16, 4, 16, 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xB30C1222),
        borderRadius: const BorderRadius.all(Radius.circular(26)),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.glass,
      ),
      child: Row(
        children: [
          for (var index = 0; index < AppShell.destinations.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: current == index
                        ? AppColors.electricBlue.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: AppRadius.medium,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppShell.destinations[index].$1,
                        color: current == index
                            ? AppColors.blueBright
                            : AppColors.dim,
                        size: 21,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppShell.destinations[index].$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: current == index
                              ? AppColors.blueBright
                              : AppColors.dim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
