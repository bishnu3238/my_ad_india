// src/presentation/widgets/auth_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool isFilled;
  final Color? accentColor;
  final bool useGlassmorphism;

  const AuthTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onEditingComplete,
    this.focusNode,
    this.textInputAction,
    this.isFilled = false,
    this.accentColor,
    this.useGlassmorphism = false,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late AnimationController _animationController;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.accentColor ?? Theme.of(context).colorScheme.primary;
    final bool hasFocus = widget.focusNode?.hasFocus ?? false;

    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    AnimatedDefaultTextStyle(
    duration: const Duration(milliseconds: 200),
    style: TextStyle(
    fontSize: 14,
    fontWeight: hasFocus ? FontWeight.w600 : FontWeight.w500,
    color: widget.useGlassmorphism
    ? Colors.white
        : hasFocus
    ? primaryColor
        : Theme.of(context).colorScheme.onSurface,
    ),
    child: Text(widget.label),
    ),
    const SizedBox(height: 8),
    AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: hasFocus
    ? [
    BoxShadow(
    color: primaryColor.withOpacity(0.2),
    blurRadius: 8,
    offset: const Offset(0, 2),
    )
    ]
        : null,
    ),
    child: Stack(
    children: [
    TextFormField(
    controller: widget.controller,
    obscureText: widget.isPassword && _obscureText,
    keyboardType: widget.keyboardType,
    validator: widget.validator,
    enabled: widget.enabled,
    focusNode: widget.focusNode,
    textInputAction: widget.textInputAction,
    onEditingComplete: widget.onEditingComplete,
    style: TextStyle(
    fontSize: 16,
    color: widget.useGlassmorphism ? Colors.white : null,
    ),
    cursorColor: primaryColor,
    cursorWidth: 1.5,
    cursorRadius: const Radius.circular(4),
    onChanged: (_) {
    // Added to ensure state updates when text changes
    if (mounted) setState(() {});
    },
    onTap: () {
    // Provide haptic feedback on field tap
    HapticFeedback.selectionClick();
    },
    inputFormatters: [
    LengthLimitingTextInputFormatter(
    widget.keyboardType == TextInputType.phone ? 10 : 200,
    ),
    ],
    decoration: InputDecoration(
    hintText: widget.hint,
    hintStyle: TextStyle(
    color: widget.useGlassmorphism
    ? Colors.white.withOpacity(0.5)
        : Theme.of(context).hintColor,
    ),
    prefixIcon: widget.prefixIcon != null
    ? ScaleTransition(
    scale: _iconScaleAnimation,
    child: widget.prefixIcon,
    )
        : null,
    suffixIcon: widget.isPassword
    ? IconButton(
    icon: AnimatedCrossFade(
    firstChild: Icon(
    Icons.visibility_outlined,
    color: widget.useGlassmorphism
    ? Colors.white
        : hasFocus ? primaryColor : null,
    ),
    secondChild: Icon(
    Icons.visibility_off_outlined,
    color: widget.useGlassmorphism
    ? Colors.white
        : hasFocus ? primaryColor : null,
    ),
    crossFadeState: _obscureText
    ? CrossFadeState.showFirst
        : CrossFadeState.showSecond,
    duration: const Duration(milliseconds: 200),
    ),
    splashRadius: 20,
    onPressed: () {
    HapticFeedback.selectionClick();
    setState(() {
    _obscureText = !_obscureText;
    });
    },
    )
        : widget.suffixIcon,
    filled: true,
    fillColor: widget.useGlassmorphism
    ? Colors.white.withOpacity(0.1)
        : hasFocus
    ? primaryColor.withOpacity(0.05)
        : Theme.of(context).colorScheme.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
    color: widget.useGlassmorphism
    ? Colors.white.withOpacity(0.2)
        : widget.isFilled
    ? primaryColor.withOpacity(0.3)
        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
    width: widget.useGlassmorphism || widget.isFilled ? 1.0 : 0.5,
    ),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
    color: widget.useGlassmorphism
    ? Colors.white
        : primaryColor,
    width: 1.5,
    ),
    ),
    errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
    color: Theme.of(context).colorScheme.error,
    width: 1.0,
    ),
    ),
    focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
    color: Theme.of(context).colorScheme.error,
    width: 1.5,
    ),
    ),
    errorStyle: TextStyle(
    color: widget.useGlassmorphism
    ? Colors.white70
        : Theme.of(context).colorScheme.error,
    ),
    ),
    ),
    if (hasFocus) Positioned(
    right: 0,
    top: 0,
    bottom: 0,
    child: AnimatedOpacity(
    opacity: hasFocus ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 200),
    child: Container(
    width: 3,
    decoration: BoxDecoration(
    color: widget.useGlassmorphism
    ? Colors.white
        : primaryColor,
    borderRadius: const BorderRadius.only(
    topRight: Radius.circular(16),
    bottomRight: Radius.circular(16),
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ],
    );}}