import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/theme/app_color_palette.dart';
 import 'package:pack/constant/constant.dart';
import 'package:go_router/go_router.dart';

class AdContentScreen extends StatefulWidget {
  const AdContentScreen({super.key});

  @override
  State<AdContentScreen> createState() => _AdContentScreenState();
}

class _AdContentScreenState extends State<AdContentScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goTo();
  }

  _goTo() async {
    setState(() => _isLoading = true);
    Future.delayed(oneSecond, () {
      // if (mounted) context.push(MerchantRegistrationRoute.merchantRegistration);
    }).whenComplete(() => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child:
              _isLoading
                  ? Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Loading ...'),
                      SpinKitCircle(color: AppColors.accentAmber),
                    ],
                  )
                  : const SizedBox(),
        ),
      ),
    );
  }
}
