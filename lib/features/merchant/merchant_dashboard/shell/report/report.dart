import 'package:flutter/material.dart';
import 'package:pack/pack.dart';

class MerchantReportsScreen extends StatelessWidget {
  const MerchantReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: Column(
        children: [
          // Chart section
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Revenue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'weekly', label: Text('Weekly')),
                        ButtonSegment(value: 'monthly', label: Text('Monthly')),
                      ],
                      selected: {'weekly'},
                      onSelectionChanged: (newSelection) {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: ChartPainter(),
                  ),
                ),
              ],
            ),
          ),
          // Stats section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildReportSection('Total Orders', [
                  _buildReportItem('This Week', '45', Icons.shopping_bag, Colors.blue),
                  _buildReportItem('Last Week', '38', Icons.shopping_bag, Colors.grey),
                ]),
                const SizedBox(height: 16),
                _buildReportSection('Total Revenue', [
                  _buildReportItem('This Week', '\$1,245', Icons.monetization_on, Colors.green),
                  _buildReportItem('Last Week', '\$980', Icons.monetization_on, Colors.grey),
                ]),
                const SizedBox(height: 16),
                _buildReportSection('User Visits', [
                  _buildReportItem('This Week', '324', Icons.people, Colors.purple),
                  _buildReportItem('Last Week', '286', Icons.people, Colors.grey),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: items.map((item) => Expanded(child: item)).toList(),
        ),
      ],
    );
  }

  Widget _buildReportItem(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}