import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class XYSk120App extends StatelessWidget {
  const XYSk120App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'XY-SK120 Control',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    routerConfig: appRouter,
  );
}
