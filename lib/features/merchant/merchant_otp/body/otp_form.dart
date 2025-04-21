// lib/features/auth/presentation/widgets/otp_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPForm extends StatefulWidget {
  final Function(String) onComplete;

  const OTPForm({super.key, required this.onComplete});

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;
  final int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _otpFocusNodes = List.generate(_otpLength, (_) => FocusNode());

    // Listen for changes to update the parent
    for (var controller in _otpControllers) {
      controller.addListener(_updateParent);
    }
  }

  void _updateParent() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == _otpLength) {
      widget.onComplete(otp);
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.removeListener(_updateParent);
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Clear all OTP fields
  void _clearAll() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (_otpFocusNodes.isNotEmpty) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
    }
  }

  // Handle paste functionality
  void _handlePaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final pastedText = clipboardData.text!;
      
      // Check if pasted text contains only digits and has correct length
      if (pastedText.length == _otpLength && 
          RegExp(r'^\d+$').hasMatch(pastedText)) {
        
        // Fill in all fields
        for (int i = 0; i < _otpLength; i++) {
          _otpControllers[i].text = pastedText[i];
        }
        
        // Unfocus after pasting
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_otpLength, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                onChanged: (value) {
                  _handleDigitInput(value, index);
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _handlePaste,
              icon: const Icon(Icons.paste, size: 18),
              label: const Text('Paste OTP'),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  void _handleDigitInput(String value, int index) {
    // Auto-advance to next field
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
    // Go back to previous field when deleting
    else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }
}

// Extension for OTP input field
class OTPInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits
    if (newValue.text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // Only allow one character
    if (newValue.text.length > 1) {
      return TextEditingValue(
        text: newValue.text.substring(0, 1),
        selection: const TextSelection.collapsed(offset: 1),
      );
    }
    
    return newValue;
  }
}