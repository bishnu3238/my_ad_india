import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/merchant_registration_view_model.dart';
import 'help_dialog.dart';

class MerchantRegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MerchantRegistrationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Merchant Registration',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue[700],
      elevation: 0,
      leading: Consumer<MerchantRegistrationViewModel>(
        builder: (context, viewModel, _) {
          return IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (viewModel.currentStep > 0) {
                // viewModel.previousStep();
              } else if (context.canPop()) {
                context.pop();
              }
            },
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () {
            showDialog(context: context, builder: (_) => const HelpDialog());
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
