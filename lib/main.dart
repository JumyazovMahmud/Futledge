import 'package:flutter/material.dart';
import 'package:internglobe/service/connectivity_service.dart';

import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final connectivityService = ConnectivityService();
            connectivityService.initialize();
            return connectivityService;
          },
        ),
      ],
      child: const FutledgeApp(),
    ),
  );
}

class FutledgeApp extends StatelessWidget {
  const FutledgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        return MaterialApp(
          title: 'Futledge',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
          routes: {
            '/main': (context) => const MainScreen(),
          },
        );
      },
    );
  }
}