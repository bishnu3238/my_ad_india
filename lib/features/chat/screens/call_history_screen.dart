import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/chat_models.dart';
import '../services/chat_manager.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  Future<void> _loadCallHistory() async {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    await chatManager.refreshCallHistory();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCallHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCallHistoryList(),
    );
  }

  Widget _buildCallHistoryList() {
    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        final callHistory = chatManager.callHistory;
        
        if (callHistory.isEmpty) {
          return const Center(
            child: Text(
              'No call history',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        
        // Group calls by date
        final Map<String, List<CallLog>> groupedCalls = {};
        final dateFormat = DateFormat('MMMM d, yyyy');
        
        for (var call in callHistory) {
          final dateString = dateFormat.format(call.createdAt);
          if (!groupedCalls.containsKey(dateString)) {
            groupedCalls[dateString] = [];
          }
          groupedCalls[dateString]!.add(call);
        }
        
        final sortedDates = groupedCalls.keys.toList()
          ..sort((a, b) => dateFormat.parse(b).compareTo(dateFormat.parse(a)));
        
        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dateCalls = groupedCalls[date]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...dateCalls.map((call) => _buildCallItem(call)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCallItem(CallLog call) {
    final timeFormat = DateFormat('h:mm a');
    
    // Determine call icon and color based on status and type
    IconData callIcon;
    Color iconColor;
    
    if (call.callDirection == 'incoming') {
      if (call.status == 'missed') {
        callIcon = Icons.call_missed;
        iconColor = Colors.red;
      } else if (call.status == 'rejected') {
        callIcon = Icons.call_received;
        iconColor = Colors.orange;
      } else {
        callIcon = Icons.call_received;
        iconColor = Colors.green;
      }
    } else {
      callIcon = Icons.call_made;
      iconColor = call.status == 'rejected' ? Colors.orange : Colors.blue;
    }
    
    // If it's a video call, use video icons
    if (call.callType == 'video') {
      if (call.callDirection == 'incoming') {
        if (call.status == 'missed') {
          callIcon = Icons.missed_video_call;
        } else {
          callIcon = Icons.video_call;
        }
      } else {
        callIcon = Icons.video_call;
      }
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: call.otherUserImage.isNotEmpty
            ? NetworkImage(call.otherUserImage)
            : null,
        child: call.otherUserImage.isEmpty
            ? Text(call.otherUserName[0].toUpperCase())
            : null,
      ),
      title: Text(
        call.otherUserName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Icon(
            callIcon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${call.callDirection == 'incoming' ? 'Incoming' : 'Outgoing'} ${call.callType} call',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeFormat.format(call.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            call.duration != null ? call.durationString : 'Not answered',
            style: TextStyle(
              fontSize: 12,
              color: call.duration != null ? Colors.black54 : Colors.red,
            ),
          ),
        ],
      ),
      onTap: () {
        // Could show call details or offer to call back
      },
    );
  }
}