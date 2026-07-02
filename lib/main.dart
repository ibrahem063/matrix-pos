import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/providers/app_auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/products/providers/product_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Before running the app, connect Firebase:
  // 1) flutter pub add firebase_core firebase_auth cloud_firestore provider intl
  // 2) flutterfire configure
  // 3) For Android, make sure google-services.json exists.
  // 4) For iOS, make sure GoogleService-Info.plist exists.
  await Firebase.initializeApp();

  runApp(const MarketPosApp());
}

class MarketPosApp extends StatelessWidget {
  const MarketPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Market POS',
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
