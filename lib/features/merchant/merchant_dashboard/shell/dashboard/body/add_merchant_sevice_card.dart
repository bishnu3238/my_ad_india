import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
 import 'package:pack/extensions/extensions.dart';
import 'package:pack/services/service.dart';
import '../../../../../../core/data/model/model.dart';
import '../../../core/merchant_dashboard_route.dart';

class AddMerchantServiceCard extends StatelessWidget {
  const AddMerchantServiceCard({
    super.key,
    required this.selectedCategory,
    required this.selectedService,
  });

  final CategoryModel? selectedCategory;
  final ServiceModel? selectedService;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  "Department ",
                  style: GoogleFonts.poppins(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: ScreenUtils().getFontSize(15),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  dense: true,
                  horizontalTitleGap: 10,
                  contentPadding: 10.symmetricHV(5),
                  leading: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.storefront, color: Colors.blue, size: 32),
                  ),
                  title: Text(
                    selectedService?.serviceName ?? "No Service Selected",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: context.colorScheme.primary,
                    ),
                  ),

                  subtitle: AutoSizeText(
                    selectedCategory?.category.trim() ?? "No Category Selected",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: context.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        'Complete your Process to add services',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          () => context.push(MerchantDashboardRoute.addService),
                      child: Text(
                        'Add Service',
                        style: TextStyle(color: context.colorScheme.surface),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
