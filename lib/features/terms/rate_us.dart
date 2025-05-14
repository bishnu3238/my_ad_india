import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// ---------------------- Rate Us Page ----------------------
class RateUsPage extends StatefulWidget {
  const RateUsPage({super.key});

  @override
  State<RateUsPage> createState() => _RateUsPageState();
}

class _RateUsPageState extends State<RateUsPage> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;
  bool _showFeedbackForm = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Us'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _submitted ? _buildThankYouView(theme) : _buildRatingView(theme),
    );
  }

  Widget _buildRatingView(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.star,
                size: 70,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'How would you rate your experience?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your feedback helps us improve our services.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 50,
              unratedColor: Colors.grey[300],
              itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: theme.primaryColor,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                  _showFeedbackForm = true;
                });
              },
            ),
            const SizedBox(height: 15),
            Text(
              _getRatingDescription(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _getRatingColor(theme),
              ),
            ),
            if (_showFeedbackForm) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us more (optional)',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts with us...',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _rating > 0 ? _submitRating : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_rating >= 4) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _openAppStore,
                icon: const Icon(Icons.thumb_up),
                label: const Text(
                  'Rate us on App Store',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThankYouView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.check_circle,
                size: 70,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Thank You for Your Feedback!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your rating helps us improve our app and provide better service to all our users.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingDescription() {
    if (_rating == 0) return '';
    if (_rating < 2) return 'Poor';
    if (_rating < 3) return 'Fair';
    if (_rating < 4) return 'Good';
    if (_rating < 5) return 'Very Good';
    return 'Excellent';
  }

  Color _getRatingColor(ThemeData theme) {
    if (_rating == 0) return Colors.grey;
    if (_rating < 3) return Colors.red;
    if (_rating < 4) return Colors.orange;
    return theme.primaryColor;
  }

  void _submitRating() {
    // Here you would typically send the rating to your backend
    // For this example, we'll just show the thank you screen
    setState(() {
      _submitted = true;
    });
  }

  void _openAppStore() async {
    // Replace with actual app store URLs
    final appStoreUrl = Uri.parse('https://apps.apple.com/app/yourapp');
    final playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=your.app.id');

    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        await launchUrl(appStoreUrl);
      } else {
        await launchUrl(playStoreUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open app store')),
      );
    }
  }
}






