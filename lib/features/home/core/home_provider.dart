import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../terms/core/terms_and_conditiaons_route.dart';


class HomeProvider extends ChangeNotifier{
  final StatefulNavigationShell shell;
  HomeProvider({required this.shell});

   bool _showPopup = true;

   bool get showPopup => _showPopup;



  Future<void> popupShowed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('_showPopup', false);
    _showPopup = false;
    notifyListeners();
  }

  Future<bool> checkShowPopupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _showPopup = prefs.getBool('_showPopup') ?? true;
    return _showPopup;
  }

  void showReferralPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildReferralContent(context),
        );
      },
    );
  }

  Widget _buildReferralContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/referral_icon.png', // Make sure to add this image to your assets
            height: 100,
            width: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Refer & Earn Program',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Invite your friends and earn rewards for each successful referral. Join our affiliate program and create a new stream of income.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Maybe Later',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToTermsPage(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('Know More'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToTermsPage(BuildContext context) {
    context.push(TermsRoute.termsAndConditions);

  }


}