import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skanskin_app/app/router.dart';
import 'package:skanskin_app/core/theme/app_colors.dart';
import 'package:skanskin_app/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // Arabic month names / date symbols must be loaded before any formatting.
  await initializeDateFormatting('ar', null);
  runApp(const ProviderScope(child: SkanSkinApp()));
}

/// Root widget: an Arabic-first, always-RTL Material app driven by GoRouter.
class SkanSkinApp extends ConsumerWidget {
  const SkanSkinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'SkanSkin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // The app is Arabic-first and always laid out RTL, independent of device
      // locale. Wrapping here also forces RTL for overlays (dialogs, sheets).
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: ScrollConfiguration(
          behavior: const _NoGlowScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Removes the Material overscroll glow so scroll surfaces stay visually quiet.
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
