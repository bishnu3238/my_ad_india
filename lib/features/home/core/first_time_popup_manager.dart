import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_ad/features/terms/core/terms_and_conditiaons_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_ad/features/home/core/home_navigator.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:pack/auth/custom_auth.dart';

// First-time popup handler
class FirstTimePopupManager {
  static const String _hasShownPopupKey = 'has_shown_referral_popup';

  static Future<bool> shouldShowPopup() async {
    final prefs = await SharedPreferences.getInstance();
    // TODO: uncomment first one.
    return !(prefs.getBool(_hasShownPopupKey) ?? false);
    // return (prefs.getBool(_hasShownPopupKey) ?? false);
  }

  static Future<void> markPopupAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShownPopupKey, true);
  }

  static Future<void> showReferralPopupIfNeeded(BuildContext context) async {
    if (await shouldShowPopup()) {
      // Wait for the build to complete before showing dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showReferralPopup(context);
      });
      await markPopupAsShown();
    }
  }

  static void _showReferralPopup(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoFirstTimePopup(),
    );
  }
}

// Cupertino-styled first-time popup
class CupertinoFirstTimePopup extends StatelessWidget {
  const CupertinoFirstTimePopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Icon(
              CupertinoIcons.gift_fill,
              color: CupertinoColors.systemBlue,
              size: 50,
            ),
          ),
          Text(
            'Refer & Earn',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'Join our referral program to earn rewards by inviting friends. Become an agent and enhance your income opportunities.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: false,
          child: Text('Maybe Later'),
          onPressed: () {
            context.pop();
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Know More'),
          onPressed: () {
            context.pop();
            context.push(TermsRoute.termsAndConditions);
          },
        ),
      ],
    );
  }
}
