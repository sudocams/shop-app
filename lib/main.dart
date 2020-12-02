import 'package:Shop/Screens/splash_screen.dart';

import './providers/auth.dart';

import './Screens/auth_screen.dart';
import './Screens/edit_product_screen.dart';
import './Screens/products_overview_screen.dart';

import './Screens/orders_screen.dart';
import './Screens/user_products.dart';

import './providers/orders.dart';

import './providers/cart.dart';

import './Screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

import './providers/products_provider.dart';
import 'package:flutter/material.dart';

import './Screens/cart_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          // create: (_) => Products(null, []),
          update: (context, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          // create: (_) => Orders(null, []),
          update: (context, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      // create: (ctx) => Products(),
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primaryColor: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          debugShowCheckedModeBanner: false,
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLog(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            CartScreen.routeName: (ctx) => CartScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            // AuthScreen.routeName: (ctx) => AuthScreen()
          },
        ),
      ),
    );
  }
}
