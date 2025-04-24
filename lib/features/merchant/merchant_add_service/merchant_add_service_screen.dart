import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/merchant_add_service_provider.dart';
import 'widgets/service_form.dart';

class MerchantAddServiceScreen extends StatefulWidget {
  const MerchantAddServiceScreen({super.key});

  @override
  State<MerchantAddServiceScreen> createState() =>
      _MerchantAddServiceScreenState();
}

class _MerchantAddServiceScreenState extends State<MerchantAddServiceScreen> {
  late MerchantAddServiceProvider provider;
  @override
  void initState() {
    super.initState();
    provider = context.read<MerchantAddServiceProvider>();
    provider.initializeData(context);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Service'),
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.0),
        ),
        // leading: CupertinoNavigationBarBackButton(
        //   onPressed: () => provider.confirmExit(context),
        // ),
      ),
      child: Consumer<MerchantAddServiceProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ServiceForm(
                    // onBackPressed: () => provider.confirmExit(context),
                    onBackPressed: () => context.pop(),
                  ),
                ),
              ),
              if (provider.errorMessage != null)
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: kBottomNavigationBarHeight,
                    color: CupertinoColors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: AutoSizeText(
                        provider.errorMessage.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}
