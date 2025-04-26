// feedback_support_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'core/support_provider.dart';

class FeedbackSupportScreen extends StatefulWidget {
  const FeedbackSupportScreen({super.key});

  @override
  State<FeedbackSupportScreen> createState() => _FeedbackSupportScreenState();
}

class _FeedbackSupportScreenState extends State<FeedbackSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Selected tab index
  int _currentIndex = 0;

  // For feedback form
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  List<String> _selectedTags = [];
  bool _isAnonymous = false;

  // For support form
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  SupportTicketPriority _selectedPriority = SupportTicketPriority.medium;
  List<File> _selectedAttachments = [];

  // For ticket reply
  final TextEditingController _replyController = TextEditingController();

  // Available tags for feedback
  final List<String> _availableTags = [
    'User Interface',
    'Performance',
    'Features',
    'Stability',
    'Customer Support',
    'Ease of Use',
    'Value for Money',
    'Connectivity',
    'Navigation',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FeedbackSupportProvider>(
        context,
        listen: false,
      );

      // Set mock user info for demo
      provider.setUserInfo('user_12345', 'John Doe', 'john.doe@example.com');

      // Load tickets and FAQs
      provider.loadUserTickets();
      provider.loadFaqs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Feedback'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Support', icon: Icon(Icons.support_agent)),
            Tab(text: 'Feedback', icon: Icon(Icons.rate_review)),
            Tab(text: 'FAQs', icon: Icon(Icons.help_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSupportTab(), _buildFeedbackTab(), _buildFaqTab()],
      ),
    );
  }

  Widget _buildSupportTab() {
    return Consumer<FeedbackSupportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingTickets && provider.userTickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.ticketError != null && provider.userTickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading support tickets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.ticketError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.loadUserTickets(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Tickets list or empty state
            provider.userTickets.isEmpty
                ? _buildEmptyTicketsState()
                : _buildTicketsList(provider),

            // Create ticket FAB
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _showCreateTicketDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('New Support Ticket'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTicketsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/support.png', // Replace with your asset
            height: 120,
            width: 120,
            // If you don't have an asset, use an icon instead:
            // Icon(Icons.support, size: 120, color: Colors.blue.shade200),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Support Tickets Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Need help? Create a support ticket and our team will assist you shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTicketsList(FeedbackSupportProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for the FAB
      itemCount: provider.userTickets.length,
      itemBuilder: (context, index) {
        final ticket = provider.userTickets[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    Color statusColor;
    IconData statusIcon;

    switch (ticket.status) {
      case SupportTicketStatus.open:
        statusColor = Colors.blue;
        statusIcon = Icons.fiber_new;
        break;
      case SupportTicketStatus.underReview:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_bottom;
        break;
      case SupportTicketStatus.resolved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case SupportTicketStatus.closed:
        statusColor = Colors.grey;
        statusIcon = Icons.done_all;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showTicketDetailsDialog(ticket),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    ticket.status.toString().split('.').last,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        ticket.priority,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(ticket.priority),
                      style: TextStyle(
                        color: _getPriorityColor(ticket.priority),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${ticket.messages.length} ${ticket.messages.length == 1 ? 'message' : 'messages'}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.message, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketDetailsDialog(SupportTicket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ticket.subject,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  ticket.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                ticket.status.toString().split('.').last,
                                style: TextStyle(
                                  color: _getStatusColor(ticket.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created on ${_formatDateFull(ticket.createdAt)}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.flag,
                              size: 16,
                              color: _getPriorityColor(ticket.priority),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Priority: ${_getPriorityText(ticket.priority)}',
                              style: TextStyle(
                                color: _getPriorityColor(ticket.priority),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                      ],
                    ),
                  ),

                  // Messages
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: ticket.messages.length,
                      itemBuilder: (context, index) {
                        final message = ticket.messages[index];
                        // Continuing from where we left off in the previous code...

                        return _buildMessageBubble(message);
                      },
                    ),
                  ),

                  // Reply box (only if ticket is not closed)
                  if (ticket.status != SupportTicketStatus.closed)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              decoration: InputDecoration(
                                hintText: 'Type your reply...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Consumer<FeedbackSupportProvider>(
                            builder: (context, provider, child) {
                              return IconButton(
                                onPressed:
                                    provider.isLoadingTickets
                                        ? null
                                        : () {
                                          if (_replyController.text
                                              .trim()
                                              .isNotEmpty) {
                                            provider
                                                .addTicketReply(
                                                  ticket.id,
                                                  _replyController.text.trim(),
                                                  [], // No attachments for now
                                                )
                                                .then((success) {
                                                  if (success) {
                                                    _replyController.clear();
                                                    Navigator.pop(context);
                                                  }
                                                });
                                          }
                                        },
                                icon:
                                    provider.isLoadingTickets
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.send_rounded),
                                color: Colors.blue,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                  // Close ticket button (only if not already closed)
                  if (ticket.status != SupportTicketStatus.closed)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Consumer<FeedbackSupportProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            onPressed:
                                provider.isLoadingTickets
                                    ? null
                                    : () {
                                      provider.closeTicket(ticket.id).then((
                                        success,
                                      ) {
                                        if (success) {
                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                            ),
                            child:
                                provider.isLoadingTickets
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Close Ticket'),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(SupportMessage message) {
    final isUser = message.isFromUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildSupportAvatar(),
          if (!isUser) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUser ? Colors.blue.shade200 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildSupportAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.support_agent, color: Colors.white, size: 18),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 18),
    );
  }

  void _showCreateTicketDialog(BuildContext context) {
    _subjectController.clear();
    _descriptionController.clear();
    _selectedPriority = SupportTicketPriority.medium;
    _selectedAttachments = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header
                      const Text(
                        'Create Support Ticket',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide details about your issue and we\'ll get back to you as soon as possible.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 24),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subject
                            TextFormField(
                              controller: _subjectController,
                              decoration: InputDecoration(
                                labelText: 'Subject',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.subject),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a subject';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText:
                                    'Please provide details about your issue',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a description';
                                }
                                if (value.trim().length < 10) {
                                  return 'Description is too short';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Priority
                            const Text(
                              'Priority',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPrioritySelector(),
                            const SizedBox(height: 24),

                            // Attachments
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Attachments',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _pickAttachment,
                                  icon: const Icon(Icons.attach_file),
                                  label: const Text('Add'),
                                ),
                              ],
                            ),
                            if (_selectedAttachments.isNotEmpty)
                              _buildAttachmentsList(),
                            const SizedBox(height: 32),

                            // Submit button
                            Consumer<FeedbackSupportProvider>(
                              builder: (context, provider, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed:
                                        provider.isLoadingTickets
                                            ? null
                                            : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                provider
                                                    .createSupportTicket(
                                                      _subjectController.text
                                                          .trim(),
                                                      _descriptionController
                                                          .text
                                                          .trim(),
                                                      _selectedAttachments
                                                          .map(
                                                            (file) => file.path,
                                                          )
                                                          .toList(),
                                                      _selectedPriority,
                                                    )
                                                    .then((success) {
                                                      if (success) {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Support ticket created successfully',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    });
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        provider.isLoadingTickets
                                            ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text('Submit Ticket'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children:
          SupportTicketPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? _getPriorityColor(priority).withOpacity(0.2)
                            : Colors.transparent,
                    border: Border.all(
                      color:
                          isSelected
                              ? _getPriorityColor(priority)
                              : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color:
                            isSelected
                                ? _getPriorityColor(priority)
                                : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPriorityText(priority),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? _getPriorityColor(priority)
                                  : Colors.grey.shade600,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAttachmentsList() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedAttachments.length,
        itemBuilder: (context, index) {
          final file = _selectedAttachments[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.insert_drive_file, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text(
                        file.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAttachments.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedAttachments.add(File(image.path));
      });
    }
  }

  Widget _buildFeedbackTab() {
    return Consumer<FeedbackSupportProvider>(
      builder: (context, provider, child) {
        if (provider.feedbackSubmitted) {
          return _buildFeedbackSuccess();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Feedback Matters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us improve by sharing your experience with our app.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),

              // Rating
              const Text(
                'How would you rate our app?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 48,
                  unratedColor: Colors.grey.shade300,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star_rounded, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingText(_rating),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _getRatingColor(_rating),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tags
              const Text(
                'What aspects do you want to give feedback on?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        selectedColor: Colors.blue.shade100,
                        checkmarkColor: Colors.blue.shade700,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 32),

              // Comment
              const Text(
                'Share your thoughts (optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tell us what you like or how we can improve...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // Anonymous option
              Row(
                children: [
                  Switch(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submit Anonymously',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Your name and account info will not be associated with this feedback',
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
              const SizedBox(height: 32),

              // Error message if any
              if (provider.feedbackError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.feedbackError!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      provider.isSubmittingFeedback || _rating == 0
                          ? null
                          : () {
                            provider.submitAppFeedback(
                              _rating,
                              _feedbackController.text.trim(),
                              _selectedTags,
                              _isAnonymous,
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue.shade600,
                  ),
                  child:
                      provider.isSubmittingFeedback
                          ? const SizedBox(
                            width: 24,
                            height: .24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Submit Feedback',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackSuccess() {
    return Center(
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
            'Thank You for Your Feedback!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Your feedback helps us improve our app and provide a better experience for all users.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<FeedbackSupportProvider>(
                context,
                listen: false,
              );
              provider.resetFeedbackState();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Submit Another Feedback'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    return Consumer<FeedbackSupportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingFaqs && provider.faqs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.faqError != null && provider.faqs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading FAQs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.faqError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.loadFaqs(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Find answers to common questions about our service',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.faqs.length,
                itemBuilder: (context, index) {
                  final faq = provider.faqs[index];
                  return _buildFaqItem(faq);
                },
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Can't find answer section
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Can\'t find what you\'re looking for?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Switch to support tab and open ticket dialog
                        _tabController.animateTo(0);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showCreateTicketDialog(context);
                        });
                      },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Contact Support'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(Map<String, String> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            faq['question']!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          children: [
            Text(
              faq['answer']!,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Utility methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateFull(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getStatusColor(SupportTicketStatus status) {
    switch (status) {
      case SupportTicketStatus.open:
        return Colors.blue;
      case SupportTicketStatus.underReview:
        return Colors.orange;
      case SupportTicketStatus.resolved:
        return Colors.green;
      case SupportTicketStatus.closed:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(SupportTicketPriority priority) {
    switch (priority) {
      case SupportTicketPriority.low:
        return Colors.green;
      case SupportTicketPriority.medium:
        return Colors.orange;
      case SupportTicketPriority.high:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(SupportTicketPriority priority) {
    switch (priority) {
      case SupportTicketPriority.low:
        return Icons.low_priority;
      case SupportTicketPriority.medium:
        return Icons.priority_high;
      case SupportTicketPriority.high:
        return Icons.warning;
    }
  }

  String _getPriorityText(SupportTicketPriority priority) {
    switch (priority) {
      case SupportTicketPriority.low:
        return 'Low';
      case SupportTicketPriority.medium:
        return 'Medium';
      case SupportTicketPriority.high:
        return 'High';
    }
  }

  Color _getRatingColor(double rating) {
    if (rating <= 2) {
      return Colors.red;
    } else if (rating <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getRatingText(double rating) {
    if (rating == 0) {
      return 'No rating selected';
    } else if (rating <= 1) {
      return 'Very Poor';
    } else if (rating <= 2) {
      return 'Poor';
    } else if (rating <= 3) {
      return 'Average';
    } else if (rating <= 4) {
      return 'Good';
    } else {
      return 'Excellent';
    }
  }
}
