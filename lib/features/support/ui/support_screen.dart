import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/injector/dependency_injection.dart';
import '../core/support_provider.dart';
import '../core/support_state.dart';

class SupportNavigator {
  static const String supportPath = '/support';

  static GoRoute page() => GoRoute(
    path: '/support',
    builder:
        (context, state) => ChangeNotifierProvider(
          create: (_) => DependencyInjector.get<SupportProvider>(),
          child: SupportScreen(),
        ),
  );
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support'), elevation: 0),
      body: Consumer<SupportProvider>(
        builder:
            (context, provider, _) =>
                provider.state.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSupportHeader(),
                          _buildTicketForm(context, provider),
                          if (provider.state.error != null)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                provider.state.error!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          _buildTicketList(provider.state.tickets),
                        ],
                      ),
                    ),
      ),
    );
  }

  Widget _buildSupportHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Icon(Icons.support_agent, size: 48, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            'How can we help you?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Submit a ticket and our team will respond as soon as possible.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketForm(BuildContext context, SupportProvider provider) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onChanged: provider.updateTitle,
              initialValue: provider.state.title,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,

              onChanged: provider.updateDescription,
              initialValue: provider.state.description,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<SupportTicketPriority>(
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              value: provider.state.priority,
              onChanged: (value) => provider.updatePriority(value!),
              items:
                  SupportTicketPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name.toUpperCase()),
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.submitTicket(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Submit Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList(List<SupportTicket> tickets) {
    if (tickets.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Your Tickets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(ticket.title),
                subtitle: Text(ticket.description),
                trailing: Chip(
                  label: Text(ticket.status.name.toUpperCase()),
                  backgroundColor: _getStatusColor(ticket.status),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(SupportTicketStatus status) {
    switch (status) {
      case SupportTicketStatus.open:
        return Colors.blue;
      case SupportTicketStatus.inProgress:
        return Colors.orange;
      case SupportTicketStatus.resolved:
        return Colors.green;
    }
  }
}
