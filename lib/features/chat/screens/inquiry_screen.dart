import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/chat_models.dart';
import '../services/chat_manager.dart';
import 'chat_screen.dart';

class InquiryScreen extends StatefulWidget {
  const InquiryScreen({Key? key}) : super(key: key);

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadInquiries('pending');
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    
    String status;
    switch (_tabController.index) {
      case 0:
        status = 'pending';
        break;
      case 1:
        status = 'responded';
        break;
      case 2:
        status = 'closed';
        break;
      default:
        status = 'pending';
    }
    
    _loadInquiries(status);
  }
  
  Future<void> _loadInquiries(String status) async {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await chatManager.refreshInquiries(status: status);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load inquiries: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateInquiryStatus(Inquiry inquiry, String newStatus) async {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    try {
      await chatManager.updateInquiryStatus(inquiry.id, newStatus);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inquiry marked as $newStatus')),
      );
      
      // Refresh the current tab
      _handleTabChange();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update inquiry: $e')),
      );
    }
  }
  
  // Helper method to get the appropriate action buttons based on inquiry status
  List<Widget> _getActionButtons(Inquiry inquiry, String currentStatus) {
    final List<Widget> buttons = [];
    
    // Reply button is always available
    buttons.add(
      TextButton.icon(
        icon: const Icon(Icons.chat),
        label: const Text('Reply'),
        onPressed: () => _navigateToChat(inquiry),
      ),
    );
    
    buttons.add(const SizedBox(width: 8));
    
    // Status-specific buttons
    if (currentStatus == 'pending') {
      buttons.add(
        TextButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Mark as Responded'),
          onPressed: () => _updateInquiryStatus(inquiry, 'responded'),
        ),
      );
    } else if (currentStatus == 'responded') {
      buttons.add(
        TextButton.icon(
          icon: const Icon(Icons.done_all),
          label: const Text('Close Inquiry'),
          onPressed: () => _updateInquiryStatus(inquiry, 'closed'),
        ),
      );
    }
    
    return buttons;
  }
  
  void _navigateToChat(Inquiry inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: inquiry.conversationId,
          otherUserName: inquiry.customerName,
          otherUserImage: inquiry.customerImage,
          otherUserType: 'customer',
          otherUserId: inquiry.customerId,
        ),
      ),
    ).then((_) {
      // Refresh inquiries when returning from chat
      _handleTabChange();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Inquiries'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Responded'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInquiryList('pending'),
          _buildInquiryList('responded'),
          _buildInquiryList('closed'),
        ],
      ),
    );
  }
  
  Widget _buildInquiryList(String status) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        final inquiries = chatManager.inquiries;
        
        if (inquiries.isEmpty) {
          return Center(
            child: Text(
              'No ${status} inquiries',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => _loadInquiries(status),
          child: ListView.builder(
            itemCount: inquiries.length,
            itemBuilder: (context, index) {
             final inquiry = inquiries[index];
              return _buildInquiryItem(inquiry, status);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildInquiryItem(Inquiry inquiry, String currentStatus) {
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: inquiry.customerImage.isNotEmpty
                      ? NetworkImage(inquiry.customerImage)
                      : null,
                  child: inquiry.customerImage.isEmpty
                      ? Text(inquiry.customerName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inquiry.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        dateFormat.format(inquiry.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(inquiry.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              inquiry.inquiryText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _getActionButtons(inquiry, currentStatus),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'responded':
        color = Colors.blue;
        label = 'Responded';
        break;
      case 'closed':
        color = Colors.green;
        label = 'Closed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
