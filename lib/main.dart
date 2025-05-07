// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/screens/edit_product_screen.dart';
// import 'package:flutter_application_1/screens/splash_screen.dart';
// import 'package:flutter_application_1/utils/app_theme.dart';
// import 'package:provider/provider.dart';
// import 'providers/auth_provider.dart';
// import 'providers/product_provider.dart';
// import 'providers/cart_provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/main_screen.dart';
// import 'screens/product_detail_screen.dart';  // ← تأكد من الاستيراد
// import 'models/product.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => ProductProvider()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Plant Store',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       home: const SplashScreen(),
//      routes: {
//   '/login': (context) => const LoginScreen(),
//   '/register': (context) => const RegisterScreen(),
//   '/main': (context) => const MainScreen(),
//   '/edit': (context) {
//     final product = ModalRoute.of(context)!.settings.arguments as Product;
//     return EditProductScreen(product: product);
//   },
// },

//     );
//   }
// }
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/app_theme.dart';
import 'models/product.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/main': (_) => const MainScreen(),
        '/edit': (ctx) {
          final product = ModalRoute.of(ctx)!.settings.arguments as Product;
          return EditProductScreen(product: product);
        },
        '/product-detail': (ctx) {
          final product = ModalRoute.of(ctx)!.settings.arguments as Product;
          return ProductDetailScreen(product: product);
        },
        '/cart': (_) => const CartScreen(),
      },
    );
  }
}
