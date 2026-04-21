import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'providers/listing_types_provider.dart';
import 'screens/splash_screen.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Initialize Firebase only on mobile platforms (not web)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      // Initialize FCM Push Notifications (Android only for now)
      if (Platform.isAndroid) {
        try {
          await FCMService.initialize();
        } catch (fcmError) {
          debugPrint('FCM initialization error (non-fatal): $fcmError');
        }
      }
    } catch (firebaseError) {
      debugPrint('Firebase initialization error: $firebaseError');
    }
  }

  runApp(const RentoGoApp());
}

class RentoGoApp extends StatelessWidget {
  const RentoGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
        ChangeNotifierProvider(create: (_) => ListingTypesProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'Rento Go',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            locale: appProvider.locale,
            supportedLocales: const [Locale('ar'), Locale('he'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              // Arabic and Hebrew are RTL, English is LTR
              final isRtl =
                  appProvider.locale.languageCode == 'ar' ||
                  appProvider.locale.languageCode == 'he';
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
