import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceStatsCard extends StatelessWidget {
  final int totalServices;
  final int remainingServices;
  final int remainingUpdates;
  final DateTime validUntil;

  const ServiceStatsCard({
    super.key,
    required this.totalServices,
    required this.remainingServices,
    required this.remainingUpdates,
    required this.validUntil,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isExpired = validUntil.isBefore(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.shade100, Colors.blueAccent.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'Service Plan Status',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isExpired ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isExpired ? 'Expired' : 'Active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.white.withOpacity(0.5)),
            _buildStatRow(
              'Total Services',
              '$totalServices',
              Icons.business_center,
              color: Colors.white,
            ),
            _buildStatRow(
              'Remaining Services',
              '$remainingServices',
              Icons.add_circle_outline,
              isWarning: remainingServices == 0,
              color: Colors.white,
            ),
            _buildStatRow(
              'Remaining Updates',
              '$remainingUpdates',
              Icons.update,
              isWarning: remainingUpdates == 0,
              color: Colors.white,
            ),
            _buildStatRow(
              'Valid Until',
              dateFormat.format(validUntil),
              Icons.calendar_today,
              isWarning: isExpired,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            if (isExpired)
              const Text(
                'Your plan has expired. Please renew to add or update services.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            if (remainingServices == 0 && !isExpired)
              const Text(
                'You\'ve reached your service limit. Upgrade your plan to add more services.',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {bool isWarning = false, Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Icon(icon, color: isWarning ? Colors.red : color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 15, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.red : color,
            ),
          ),
        ],
      ),
    );
  }
}
