import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/extensions/contextx.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/data/model/model.dart';
import 'product_image_carousel.dart';

class EadServiceDetailsAppBar extends StatelessWidget implements PreferredSizeWidget{
  final ProductModel product;
  const EadServiceDetailsAppBar({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImageCarousel(product: product),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colorScheme.surface),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(Icons.share, color: context.colorScheme.surface),
            onPressed: () => _shareProduct(product),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

void _shareProduct(ProductModel product) {
  final text =
      'Check out ${product.serviceName} by ${product.merchant.companyName}. Contact them at ${product.merchant.mobile}';
  Share.share(text);
}
