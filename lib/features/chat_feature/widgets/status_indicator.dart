import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;
  final bool bordered;

  const StatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 10.0,
    this.bordered = true,
  }) ;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isOnline ? Colors.green : Colors.grey;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: statusColor,
        border: bordered
            ? Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: size * 0.2,
        )
            : null,
      ),
    );
  }
}

class StatusIndicatorWithText extends StatelessWidget {
  final bool isOnline;
  final double indicatorSize;
  final bool showText;

  const StatusIndicatorWithText({
    Key? key,
    required this.isOnline,
    this.indicatorSize = 8.0,
    this.showText = true,
  }) : super(key: key);

  String get statusText => isOnline ? 'Online' : 'Offline';

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isOnline ? Colors.green : Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusIndicator(
          isOnline: isOnline,
          size: indicatorSize,
        ),
        if (showText)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
              ),
            ),
          ),
      ],
    );
  }
}
