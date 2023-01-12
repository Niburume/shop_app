import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../models/http_exception.dart';

class ProductItem extends StatelessWidget {
  bool throwError = false;
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);

    return Consumer<Product>(
      builder: (BuildContext _, product, Widget? child) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            leading: IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(await product.toggleFavoriteStatus(
                        context, product.id))));
              },
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                    'Added item to cart',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingeItem(product.id);
                    },
                  ),
                ));
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          child: GestureDetector(
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    const AssetImage('assets/images/image_placeholder.jpg'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
          ),
        ),
      ),
    );
  }
}
