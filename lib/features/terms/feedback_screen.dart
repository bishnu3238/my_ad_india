import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:async';

class FeedbackScreen extends StatefulWidget {
  final String serviceProviderId;
  final String serviceId;
  final String customerName;

  const FeedbackScreen({
    super.key,
    required this.serviceProviderId,
    required this.serviceId,
    required this.customerName,
  });

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  double _rating = 0;
  String _review = '';
  List<String> _selectedTags = [];
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _errorMessage;

  // Predefined tags for quick feedback
  final List<String> _feedbackTags = [
    'Professional',
    'On time',
    'Skilled',
    'Friendly',
    'Clean work',
    'Fair price',
    'Responsive',
    'Knowledgeable',
    'Would recommend',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_rating == 0) {
        setState(() {
          _errorMessage = 'Please provide a rating';
        });
        return;
      }

      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 2));

        // Mock feedback submission
        final bool success = await _mockSubmitFeedback();

        if (success) {
          setState(() {
            _isSuccess = true;
            _isSubmitting = false;
          });

          // Auto navigate back after success
          Timer(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pop(true); // Return true to indicate successful submission
            }
          });
        } else {
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Unable to submit feedback. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      }
    }
  }

  // Mock feedback submission - in real app this would be an API call
  Future<bool> _mockSubmitFeedback() async {
    // In a real app, you would send this data to your backend
    final feedbackData = {
      'serviceProviderId': widget.serviceProviderId,
      'serviceId': widget.serviceId,
      'customerName': _isAnonymous ? 'Anonymous' : widget.customerName,
      'rating': _rating,
      'review': _review,
      'tags': _selectedTags,
      'isAnonymous': _isAnonymous,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('Submitting feedback: $feedbackData');

    // Return true to simulate successful submission (95% of the time)
    return (DateTime.now().millisecondsSinceEpoch % 100) < 95;
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Rate Your Experience',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isSuccess ? _buildSuccessView() : _buildFeedbackForm(),
    );
  }

  Widget _buildSuccessView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade600,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your feedback helps improve our service and assists others in making informed decisions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header with animation
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Rating Bar
                  _buildRatingBar(),
                  const SizedBox(height: 32),

                  // Quick Feedback Tags
                  _buildQuickTags(),
                  const SizedBox(height: 24),

                  // Review Text Field
                  _buildReviewField(),
                  const SizedBox(height: 20),

                  // Anonymous Option
                  _buildAnonymousOption(),
                  const SizedBox(height: 8),

                  // Error Message (if any)
                  if (_errorMessage != null) _buildErrorMessage(),
                  const SizedBox(height: 16),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share Your Experience',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your feedback helps us improve and helps others find great service providers.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you rate your experience?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: RatingBar.builder(
            initialRating: _rating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 50,
            unratedColor: Colors.grey.shade300,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star_rounded,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
                // Clear error if user rates after seeing error
                if (_errorMessage == 'Please provide a rating') {
                  _errorMessage = null;
                }
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getRatingColor(),
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText() {
    if (_rating == 0) return 'Tap to rate';
    if (_rating <= 1) return 'Poor';
    if (_rating <= 2) return 'Below average';
    if (_rating <= 3) return 'Average';
    if (_rating <= 4) return 'Good';
    return 'Excellent';
  }

  Color _getRatingColor() {
    if (_rating == 0) return Colors.grey;
    if (_rating <= 1) return Colors.red.shade700;
    if (_rating <= 2) return Colors.orange.shade700;
    if (_rating <= 3) return Colors.amber.shade700;
    if (_rating <= 4) return Colors.lightGreen.shade700;
    return Colors.green.shade700;
  }

  Widget _buildQuickTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What was great about the service?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: _feedbackTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return InkWell(
              onTap: () => _toggleTag(tag),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.blue.shade100.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                      : null,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional comments (optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          onChanged: (value) => _review = value,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Share more details about your experience...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Switch(
            value: _isAnonymous,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value;
              });
            },
            activeColor: Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit Anonymously',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Your name will not be displayed with your feedback',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blue.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.blue.shade200,
        ),
        child: _isSubmitting
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Submitting...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        )
            : const Text(
          'Submit Feedback',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Usage:
// Navigator.of(context).push(
//   MaterialPageRoute(
//     builder: (context) => FeedbackScreen(
//       serviceProviderId: 'sp_123',
//       serviceId: 'service_456',
//       customerName: 'John Doe',
//     ),
//   ),
// );