import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/app_providers.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EtsyCloneApp());
}

// Màu sắc chủ đạo (Dùng chung)
const Color etsyBackground = Color(0xFF221F27);
const Color etsyCardColor = Color(0xFF33303A);
const Color etsyText = Colors.white;
const Color etsyGreen = Color(0xFF81C784);

class EtsyCloneApp extends StatelessWidget {
  const EtsyCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Etsy Clone UI',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: etsyBackground,
          primaryColor: Colors.white,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
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
