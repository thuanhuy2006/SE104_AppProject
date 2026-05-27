import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/app_providers.dart';
import 'screens/main_screen.dart';
import 'screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EraCloneApp());
}

// Màu sắc chủ đạo (Dùng chung)
const Color eraBackground = Color(0xFF221F27);
const Color eraCardColor = Color(0xFF33303A);
const Color eraText = Colors.white;
const Color eraGreen = Color(0xFF81C784);

class EraCloneApp extends StatelessWidget {
  const EraCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        // Đã xóa AddressProvider dư thừa ở đây!
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Era Store',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: eraBackground,
          primaryColor: Colors.white,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            surface: eraBackground,
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isInitializing) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          );
        }

        if (userProvider.isLoggedIn) {
          return const MainScreen();
        }

        return const LoginPage();
      },
    );
  }
}