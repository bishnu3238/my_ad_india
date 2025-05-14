import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

import '../core/merchant_dashboard_provider.dart';
import 'card_view_info.dart';

class MerchantServicesPage extends StatefulWidget {
  const MerchantServicesPage({super.key});

  @override
  State<MerchantServicesPage> createState() => _MerchantServicesPageState();
}

class _MerchantServicesPageState extends State<MerchantServicesPage> {
  bool isGrid = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final services = provider.services;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (services.isEmpty) {
      return const Center(child: Text('No services available.'));
    }

    final showToggle = services.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // important for unbounded height context
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "My Dashboard",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            if (showToggle)
              Padding(
                padding: 8.all,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.view_list,
                        color: isGrid ? Colors.grey : Colors.blue,
                      ),
                      onPressed: () => setState(() => isGrid = false),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color: isGrid ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () => setState(() => isGrid = true),
                    ),
                  ],
                ),
              ),
          ],
        ),

        if (isGrid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: services.length,
            itemBuilder:
                (context, index) => CardViewInfo(service: services[index]),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(5),
            itemCount: services.length,
            itemBuilder:
                (context, index) => CardViewInfo(service: services[index]),
          ),
      ],
    );
  }
}
