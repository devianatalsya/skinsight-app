import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/widgets/shared_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SoftlyApp());
}

class SoftlyApp extends StatelessWidget {
  const SoftlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Softly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Stack(
          children: [
            ?child,
            const Positioned.fill(
              child: GrainOverlay(),
            ),
          ],
        );
      },
      home: const HomePage(),
    );
  }
}
