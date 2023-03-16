import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screen/auth_screen.dart';
import 'package:shop_app/screen/cart_screen.dart';
import 'package:shop_app/screen/edit_product_screen.dart';
import 'package:shop_app/screen/orders_screen.dart';
import 'package:shop_app/screen/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screen/splash_screen.dart';
import 'package:shop_app/screen/user_products_screen.dart';

import 'screen/products_overview_screen.dart';
import 'providers/products_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          create: (ctx) =>
              ProductsProvider([], authToken: 'authToken', userId: ''),
          update: (ctx, auth, previousProducts) =>
              ProductsProvider(
                previousProducts == null ? [] : previousProducts.items,
                authToken: auth.token == null ? '' : auth.token.toString(),
                userId: auth.userId == null ? '' : auth.userId.toString(),
              ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders([], authToken: 'authToken', userId: ''),
          update: (ctx, auth, previousOrders) =>
              Orders(
                  previousOrders == null ? [] : previousOrders.orders,
                  authToken: auth.token == null ? '' : auth.token.toString(),
                  userId: auth.userId == null ? '' : auth.userId.toString()),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) =>
            MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: const PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                    }
                ),
              ),
              home: auth.isAuth
                  ? const ProductsOverviewScreen()
                  : FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, authResultSnapshot) =>
                authResultSnapshot.connectionState ==
                    ConnectionState.waiting
                    ? const SplashScreen()
                    : AuthScreen(),
              ),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => const CartScreen(),
                OrdersScreen.routeName: (ctx) => const OrdersScreen(),
                UserProductsScreen.routeName: (
                    ctx) => const UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => const EditProductScreen(),
              },
            ),
      ),
    );
  }
}
