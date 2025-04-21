import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:my_ad/features/ead_products/body/product_card.dart';
import 'package:my_ad/features/ead_products/ead_product_details/core/ead_product_details_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SimilarProductsSection extends StatelessWidget {
  final ProductDetailsViewModel viewModel;

  const SimilarProductsSection({Key? key, required this.viewModel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = viewModel.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar Products',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 245,
          child:
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.similarProducts.isEmpty
                  ? Center(
                    child: Text(
                      'No similar products found',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.similarProducts.length,
                    itemBuilder: (context, index) {
                      final similarProduct = state.similarProducts[index];
                      return SizedBox(
                        width: 180,
                        child: ProductCard(
                          product: similarProduct,
                          onTap:
                              () => _navigateToProductDetails(
                                context,
                                similarProduct,
                              ),
                          onCall:
                              () =>
                                  _launchPhone(similarProduct.merchant.mobile),
                          onChat:
                              () => _launchWhatsApp(
                                similarProduct.merchant.mobile,
                              ),
                          distanceFromUser: '',
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  void _navigateToProductDetails(BuildContext context, ProductModel product) {
    // Navigation logic would go here
    // For example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EadProductDetails(
    //       provider: EadProductsViewModel()..addProduct(product),
    //     ),
    //   ),
    // );
  }

  void _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchWhatsApp(String phone) async {
    String message = "Hello, I'm interested in your service.";
    var encodedMessage = Uri.encodeComponent(message);

    final url = 'https://wa.me/$phone?text=$encodedMessage';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
