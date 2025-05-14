import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/product/products_model.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/extensions/contextx.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/model/user/user_model.dart';
import '../../../../core/injector/dependency_injection.dart';

class ProductReviewSection extends StatelessWidget {
  const ProductReviewSection({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final user =
        context.read<AuthProviderModel<UserModel>>().user ?? UserModel.empty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ReviewSystem(
            itemId: product.merchant.id,

            currentUserId: user.id,
            currentUserName: user.name,
            currentUserImageUrl: user.profileImage,
            allowImageUploads: false,

            reviewService: DependencyInjector.get<ReviewService>(),
          ),
        ),
      ],
    );
  }
}
