import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/data/model/customer_visit_model.dart';
import '../../chat_feature/models/inquiry.dart';
import 'core/customer_inquiry_provider.dart';

class CustomerInquiriesPage extends StatefulWidget {
  const CustomerInquiriesPage({super.key});

  @override
  State<CustomerInquiriesPage> createState() => _CustomerInquiriesPageState();
}

class _CustomerInquiriesPageState extends State<CustomerInquiriesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomerInquiriesProvider>();
      provider.init(); // loads both visits and inquiries from server
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = context.read<CustomerInquiriesProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (provider.selectedTab == InquiryTab.inquiries) {
        provider.loadMoreInquiries();
      } else {
        provider.loadMoreVisits();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<CustomerInquiriesProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                _buildHeader(provider),
                _buildTabBar(provider),
                Expanded(
                  child: _buildContent(provider),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<CustomerInquiriesProvider>(
        builder: (context, provider, _) {
          if (provider.selectedTab == InquiryTab.inquiries) {
            return FloatingActionButton.extended(
              onPressed: () => _showCreateInquiryDialog(),
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Inquiry'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(CustomerInquiriesProvider provider) {
    return Material(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ...existing code for title...
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Inquiries',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage customer visits and inquiries',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatsSection(provider),
            const SizedBox(height: 24),
            _buildSearchAndFilters(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(CustomerInquiriesProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard('Total Visits', provider.totalVisits.toString(), Icons.people_outline, Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard('Total Inquiries', provider.totalInquiries.toString(), Icons.mail_outline, Colors.green),
          const SizedBox(width: 12),
          _buildStatCard('Pending', provider.pendingInquiries.toString(), Icons.pending_outlined, Colors.orange),
          const SizedBox(width: 12),
          _buildStatCard('Resolved', provider.resolvedInquiries.toString(), Icons.check_circle_outline, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(CustomerInquiriesProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildSearchBar(provider),
        ),
        const SizedBox(width: 12),
        _buildSortButton(provider),
        const SizedBox(width: 12),
        if (provider.selectedTab == InquiryTab.inquiries)
          _buildFilterButton(provider),
      ],
    );
  }

  Widget _buildSearchBar(CustomerInquiriesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          provider.setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search inquiries...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[500]),
            onPressed: () {
              _searchController.clear();
              provider.setSearchQuery('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSortButton(CustomerInquiriesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<SortBy>(
        onSelected: (value) => provider.setSortBy(value),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(Icons.sort, color: Colors.grey[600]),
        ),
        itemBuilder: (context) => SortBy.values.map((sort) {
          return PopupMenuItem(
            value: sort,
            child: Row(
              children: [
                Icon(
                  provider.sortBy == sort ? Icons.check : Icons.sort,
                  size: 16,
                  color: provider.sortBy == sort ? Colors.blue : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(_getSortLabel(sort)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterButton(CustomerInquiriesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: provider.statusFilter != null ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<InquiryStatus?>(
        onSelected: (value) => provider.setStatusFilter(value),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.filter_list,
            color: provider.statusFilter != null ? Colors.blue[600] : Colors.grey[600],
          ),
        ),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: null,
            child: Row(
              children: [
                Icon(Icons.clear_all, size: 16),
                SizedBox(width: 8),
                Text('All Status'),
              ],
            ),
          ),
          ...InquiryStatus.values.map((status) {
            return PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    provider.statusFilter == status ? Icons.check : _getStatusIcon(status),
                    size: 16,
                    color: provider.statusFilter == status ? Colors.blue : _getInquiryStatusColor(status.name),
                  ),
                  const SizedBox(width: 8),
                  Text(_getStatusLabel(status)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabBar(CustomerInquiriesProvider provider) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          provider.setSelectedTab(InquiryTab.values[index]);
        },
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[600],
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.people_outline),
            text: 'Customer Visits',
          ),
          Tab(
            icon: Icon(Icons.mail_outline),
            text: 'Inquiries',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CustomerInquiriesProvider provider) {
    if (provider.errorMessage.isNotEmpty) {
      return _buildErrorState(provider);
    }
    return TabBarView(
      controller: _tabController,
      children: [
        _buildVisitsTab(provider),
        _buildInquiriesTab(provider),
      ],
    );
  }

  Widget _buildVisitsTab(CustomerInquiriesProvider provider) {
    if (provider.isLoadingVisits && provider.visits.isEmpty) {
      return _buildLoadingState();
    }
    if (provider.visits.isEmpty) {
      return _buildEmptyState(
        'No customer visits found',
        Icons.people_outline,
        'Customer visits will appear here once they contact you.',
      );
    }
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.visits.length + (provider.hasMoreVisits ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.visits.length) {
            return _buildLoadMoreIndicator(provider.isLoadingVisits);
          }
          return _buildVisitCard(provider.visits[index]);
        },
      ),
    );
  }

  Widget _buildInquiriesTab(CustomerInquiriesProvider provider) {
    if (provider.isLoadingInquiries && provider.inquiries.isEmpty) {
      return _buildLoadingState();
    }
    if (provider.inquiries.isEmpty) {
      return _buildEmptyState(
        'No inquiries found',
        Icons.mail_outline,
        'Customer inquiries will appear here. Try adjusting your search or filters.',
      );
    }
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.inquiries.length + (provider.hasMoreInquiries ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.inquiries.length) {
            return _buildLoadMoreIndicator(provider.isLoadingInquiries);
          }
          return _buildInquiryCard(provider.inquiries[index]);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(CustomerInquiriesProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              provider.clearError();
              provider.init();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(Inquiry inquiry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showInquiryDetails(inquiry),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    radius: 20,
                    child: Text(
                      (inquiry.customerName?.isNotEmpty == true
                          ? inquiry.customerName![0].toUpperCase()
                          : 'U'),
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inquiry.customerName ?? 'Unknown Customer',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          inquiry.subject,
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(inquiry.status, _getInquiryStatusColor(inquiry.status)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                inquiry.message,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (inquiry.attachmentUrl != null) ...[
                    Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Attachment',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(inquiry.createdAt ?? DateTime.now()),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (inquiry.notes?.isNotEmpty == true)
                    Icon(Icons.note, size: 16, color: Colors.orange[600]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitCard(CustomerVisit visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showVisitDetails(visit),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[50],
                    radius: 20,
                    child: Text(
                      visit.customer.username.isNotEmpty
                          ? visit.customer.username[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.customer.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          visit.customer.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildContactTypeChip(visit.contactType),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                visit.message,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(DateTime.parse(visit.dated)),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusChip(visit.status, _getVisitStatusColor(visit.status)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTypeChip(String contactType) {
    final color = _getContactTypeColor(contactType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getContactTypeIcon(contactType),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            contactType.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }

  // Dialog methods
  void _showInquiryDetails(Inquiry inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Inquiry Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', inquiry.customerName ?? 'Unknown'),
              _buildDetailRow('Subject', inquiry.subject),
              _buildDetailRow('Message', inquiry.message),
              _buildDetailRow('Status', inquiry.status),
              if (inquiry.attachmentUrl != null)
                _buildDetailRow('Attachment', 'Yes'),
              if (inquiry.notes?.isNotEmpty == true)
                _buildDetailRow('Notes', inquiry.notes!),
              _buildDetailRow('Created', _formatDate(inquiry.createdAt ?? DateTime.now())),
              if (inquiry.updatedAt != null)
                _buildDetailRow('Updated', _formatDate(inquiry.updatedAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showStatusUpdateDialog(inquiry);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(Inquiry inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['pending', 'in_progress', 'resolved', 'closed']
              .map((status) => ListTile(
            title: Text(_getStatusLabel(InquiryStatus.values.firstWhere(
                    (e) => e.name == status))),
            leading: Radio<String>(
              value: status,
              groupValue: inquiry.status,
              onChanged: (value) {
                if (value != null) {
                  context.read<CustomerInquiriesProvider>()
                      .updateInquiryStatus(inquiry.id, value);
                  Navigator.pop(context);
                }
              },
            ),
          ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showVisitDetails(CustomerVisit visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Visit Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', visit.customer.username),
              _buildDetailRow('Email', visit.customer.email),
              _buildDetailRow('Phone', visit.customer.mobile),
              _buildDetailRow('Contact Type', visit.contactType),
              _buildDetailRow('Message', visit.message),
              _buildDetailRow('Date', _formatDate(DateTime.parse(visit.dated))),
              _buildDetailRow('Status', visit.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle follow-up action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Follow Up'),
          ),
        ],
      ),
    );
  }

  void _showCreateInquiryDialog() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Inquiry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle create inquiry
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getSortLabel(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.date:
        return 'Date';
      case SortBy.status:
        return 'Status';
      case SortBy.customer:
        return 'Customer';
      default:
        return '';
    }
  }

  String _getStatusLabel(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.pending:
        return 'Pending';
      case InquiryStatus.inProgress:
        return 'In Progress';
      case InquiryStatus.resolved:
        return 'Resolved';
      case InquiryStatus.closed:
        return 'Closed';
      default:
        return '';
    }
  }

  IconData _getStatusIcon(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.pending:
        return Icons.pending;
      case InquiryStatus.inProgress:
        return Icons.hourglass_empty;
      case InquiryStatus.resolved:
        return Icons.check_circle;
      case InquiryStatus.closed:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getContactTypeColor(String contactType) {
    switch (contactType) {
      case 'email':
        return Colors.blue;
      case 'phone':
        return Colors.green;
      case 'chat':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getContactTypeIcon(String contactType) {
    switch (contactType) {
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.help_outline;
    }
  }

  Color _getVisitStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getInquiryStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}