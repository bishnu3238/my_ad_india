import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;
  final bool centered;
  final bool overlay;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.color,
    this.size = 36.0,
    this.strokeWidth = 3.0,
    this.centered = true,
    this.overlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: color != null
                ? AlwaysStoppedAnimation<Color>(color!)
                : AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              message!,
              style: TextStyle(
                color: color ?? Colors.grey[600] ?? Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );

    final Widget content = centered ? Center(child: loadingWidget) : loadingWidget;

    if (overlay) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: content,
      );
    }

    return content;
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color? color;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingIndicator(
        message: message,
        color: color,
      ),
    );
  }
}

class OverlayLoading extends StatelessWidget {
  final String? message;
  final Color? color;

  const OverlayLoading({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingIndicator(
      message: message,
      color: color,
      overlay: true,
    );
  }
}
