import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/users_product_screen.dart';
import './providers/orders.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),

        // Here you provide the data from another class throw the another provider by constructor.
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(null, [], null),
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              previousProducts == null ? [] : previousProducts.items,
              auth.userId),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(null, null),
          update: (ctx, auth, _) => Orders(auth.token, auth.userId),
        ),
      ],
      child: Consumer<Auth>(
        builder: (
          ctx,
          auth,
          _,
        ) =>
            MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
                  .copyWith(secondary: Colors.deepOrange),
              fontFamily: 'Lato'),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
