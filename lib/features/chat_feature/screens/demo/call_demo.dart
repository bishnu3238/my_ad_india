import 'package:flutter/material.dart';
import 'package:chat_sdk/chat_sdk.dart';

import '../../../../core/data/api/api_config.dart';

class CallExampleScreen extends StatefulWidget {
  const CallExampleScreen({super.key});

  @override
  State<CallExampleScreen> createState() => _CallExampleScreenState();
}

class _CallExampleScreenState extends State<CallExampleScreen> {
  late final SocketManager socket;
  late final CallService callService;
  String conversationId = '2';
  String currentUserId = '1';
  String otherUserId = '3';

  bool _isCalling = false;
  bool _isIncoming = false;
  String? _callType;
  String? _callerName;

  @override
  void initState() {
    super.initState();
    socket = SocketManager();
    socket.connect(ApiConfig.socketUrl);
    callService = CallService(socket);

    // Listen for incoming calls
    callService.onIncomingCall((data) {
      setState(() {
        _isIncoming = true;
        _callType = data['callType'];
        _callerName = data['callerName'] ?? data['callerId'];
      });
      _showIncomingCallSheet(data);
    });

    // Listen for call ended
    callService.onCallEnded((data) {
      setState(() {
        _isCalling = false;
        _isIncoming = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Call ended')));
      Navigator.of(context, rootNavigator: true).maybePop();
    });
  }

  void _showIncomingCallSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  data['callType'] == 'video' ? Icons.videocam : Icons.call,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Incoming ${data['callType']} call',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('From: ${data['callerName'] ?? data['callerId']}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.call_end, color: Colors.white),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        callService.sendCallResponse({
                          ...data,
                          'response': 'rejected',
                        });
                        setState(() {
                          _isIncoming = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        callService.sendCallResponse({
                          ...data,
                          'response': 'accepted',
                        });
                        setState(() {
                          _isCalling = true;
                          _isIncoming = false;
                        });
                        Navigator.pop(context);
                        _showCallingPage(
                          isIncoming: true,
                          callType: data['callType'],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showCallingPage({bool isIncoming = false, String? callType}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => CallingScreen(
              isIncoming: isIncoming,
              callType: callType ?? 'audio',
              onEnd: _endCall,
            ),
      ),
    );
  }

  void _startCall(String type) {
    setState(() {
      _isCalling = true;
      _callType = type;
    });
    callService.initiateCall({
      'conversationId': conversationId,
      'callerType': 'customer',
      'callerId': currentUserId,
      'receiverType': 'merchant',
      'receiverId': otherUserId,
      'callType': type, // 'audio' or 'video'
    });
    _showCallingPage(callType: type);
  }

  void _endCall() {
    callService.endCall({
      'conversationId': conversationId,
      'callerId': currentUserId,
    });
    setState(() {
      _isCalling = false;
      _isIncoming = false;
    });
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Example')),
      body: Center(
        child:
            _isCalling
                ? const Text('Calling...')
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.call),
                      label: const Text('Start Audio Call'),
                      onPressed: () => _startCall('audio'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.videocam),
                      label: const Text('Start Video Call'),
                      onPressed: () => _startCall('video'),
                    ),
                  ],
                ),
      ),
    );
  }
}

class CallingScreen extends StatelessWidget {
  final bool isIncoming;
  final String callType;
  final VoidCallback onEnd;

  const CallingScreen({
    super.key,
    required this.isIncoming,
    required this.callType,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: callType == 'video' ? Colors.black : Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: callType == 'video' ? Colors.black : null,
        title: Text(
          '${isIncoming ? "In Call" : "Calling"} (${callType.toUpperCase()})',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: onEnd,
          ),
        ],
      ),
      body: Center(
        child: Icon(
          callType == 'video' ? Icons.videocam : Icons.call,
          size: 120,
          color: callType == 'video' ? Colors.white : Colors.blue,
        ),
      ),
    );
  }
}
