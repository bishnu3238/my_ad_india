import 'package:flutter/material.dart';
class ServiceLimitWarning extends StatelessWidget {
  const ServiceLimitWarning({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You have reached your service limit. Please upgrade your plan to add more services.',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
