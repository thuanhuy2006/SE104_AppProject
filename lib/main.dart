import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'providers/app_providers.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EtsyCloneApp());
}

class EtsyCloneApp extends StatelessWidget {
  const EtsyCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Etsy Clone UI',
        theme: ThemeData(
          // Chuyển sang chế độ Sáng
          brightness: Brightness.light,
          scaffoldBackgroundColor: etsyBackground,
          primaryColor: etsyText,
          colorScheme: const ColorScheme.light(
            primary: etsyText,
            surface: etsyBackground,
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}