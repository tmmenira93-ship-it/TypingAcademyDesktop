import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(TypingAcademyApp(state: state));
}

class TypingAcademyApp extends StatelessWidget {
  const TypingAcademyApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: state,
      // Only the settings that change how the whole app looks. Progress updates
      // (after every lesson) no longer rebuild MaterialApp and the Navigator.
      child: Selector<AppState, (ThemeMode, double, bool)>(
        selector: (_, app) => (app.settings.themeMode, app.settings.fontScale, app.settings.isArabic),
        builder: (context, look, _) {
          final (themeMode, fontScale, arabic) = look;
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            builder: (context, child) {
              return Directionality(
                textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(fontScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
