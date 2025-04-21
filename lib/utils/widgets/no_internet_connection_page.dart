import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/constant/image.dart';
import 'package:my_ad/utils/widgets/svg_icon_widget.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';

class NoConnectionWidget extends StatelessWidget {
  final ImageSource? source;
  final String? path;
  final Function onRetryTap;
  final bool isLoading;

  const NoConnectionWidget({
    super.key,
    this.path,
    required this.onRetryTap,
    this.isLoading = false,
    this.source,
  }) : assert(path == null || source == null);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated illustration
            if (source == null && path == null)
              SvgPicture.string(
                AppImage.serverDownSvg,
                height: ScreenUtils().getHorizontalSize(80),
                width: ScreenUtils().getVerticalSize(80),
              ),
            if (source != null && path != null)
              ImageView(
                source: source ?? ImageSource.svg,
                path: path ?? AppImage.serverDownSvg,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),

            // If you don't have a Lottie animation, use this alternative:
            // const Icon(Icons.signal_wifi_off, size: 80, color: Color(0xFF9E9E9E)),
            const SizedBox(height: 32),
            Text(
              'No Internet Connection',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: GoogleFonts.hachiMaruPop(
                fontSize: 13,
                color: const Color(0xFF757575),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isLoading ? null : () => onRetryTap(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.surface,
                minimumSize: const Size(180, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Try Again',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use it:
/*
// In your parent widget
bool _isCheckingConnection = false;

Future<void> _checkConnection() async {
  setState(() {
    _isCheckingConnection = true;
  });

  // Check connectivity
  final hasConnection = await yourConnectivityCheckMethod();

  setState(() {
    _isCheckingConnection = false;
  });

  if (hasConnection) {
    // Fetch data or navigate
    yourDataFetchingMethod();
  }
}

// In your build method
Widget build(BuildContext context) {
  return hasInternetConnection
    ? YourNormalWidget()
    : NoConnectionWidget(
        onRetryPressed: _checkConnection,
        isLoading: _isCheckingConnection,
      );
}
*/
