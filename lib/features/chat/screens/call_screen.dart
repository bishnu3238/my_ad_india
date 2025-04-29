import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_manager.dart';

class CallScreen extends StatefulWidget {
  final bool isOutgoing;
  final String callType;
  final String otherUserName;
  final String otherUserImage;
  final String otherUserType;
  final String otherUserId;
  final String conversationId;
  final String? callId;
  final String? callerType;
  final String? callerId;

  const CallScreen({
    super.key,
    required this.isOutgoing,
    required this.callType,
    required this.otherUserName,
    required this.otherUserImage,
    required this.otherUserType,
    required this.otherUserId,
    required this.conversationId,
    this.callId,
    this.callerType,
    this.callerId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoEnabled = true;
  bool _isCallConnected = false;
  bool _isCallEnded = false;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  late StreamSubscription _callResponseSubscription;
  late StreamSubscription _callEndedSubscription;

  @override
  void initState() {
    super.initState();
    _setupCallListeners();
    
    if (!widget.isOutgoing) {
      // This is an incoming call, already connected
      _startCallTimer();
      _isCallConnected = true;
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callResponseSubscription.cancel();
    _callEndedSubscription.cancel();
    super.dispose();
  }

  void _setupCallListeners() {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    // Listen for call responses (for outgoing calls)
    _callResponseSubscription = chatManager.socketService.onCallResponse.listen((data) {
      if (widget.isOutgoing && data['callId'] == widget.callId) {
        final response = data['response'];
        
        if (response == 'answered') {
          setState(() {
            _isCallConnected = true;
          });
          _startCallTimer();
        } else if (response == 'rejected') {
          _handleCallRejected();
        }
      }
    });
    
    // Listen for call ended events
    _callEndedSubscription = chatManager.socketService.onCallEnded.listen((data) {
      if (data['callId'] == widget.callId) {
        _handleCallEnded();
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _handleCallRejected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.otherUserName} rejected the call')),
    );
    Navigator.pop(context);
  }

  void _handleCallEnded() {
    if (!_isCallEnded) {
      setState(() {
        _isCallEnded = true;
      });
      
      _callTimer?.cancel();
      
      // Show call ended message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call ended')),
      );
      
      // Close the call screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _answerCall() {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    chatManager.respondToCall(
      widget.callId!,
      'answered',
      widget.callerType!,
      widget.callerId!,
    );
    
    setState(() {
      _isCallConnected = true;
    });
    
    _startCallTimer();
  }

  void _rejectCall() {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    chatManager.respondToCall(
      widget.callId!,
      'rejected',
      widget.callerType!,
      widget.callerId!,
    );
    
    Navigator.pop(context);
  }

  void _endCall() {
    if (_isCallEnded) return;
    
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    // Add null checks to prevent the error
    if (widget.callId == null) {
      debugPrint('Cannot end call: callId is null');
      
      // Just close the call screen if we can't properly end the call
      setState(() {
        _isCallEnded = true;
      });
      
      _callTimer?.cancel();
      
      // Close the call screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
      
      return;
    }
    
    try {
      chatManager.endCall(
        widget.callId!,
        widget.otherUserType,
        widget.otherUserId,
      );
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
    
    _handleCallEnded();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    // Implement actual mute functionality with a real call provider
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // Implement actual speaker functionality with a real call provider
  }

  void _toggleVideo() {
    if (widget.callType != 'video') return;
    
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    // Implement actual video toggle functionality with a real call provider
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.callType == 'video' && _isVideoEnabled && _isCallConnected
                  ? _buildVideoCallView()
                  : _buildAudioCallView(),
            ),
            _buildCallControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCallView() {
    // In a real implementation, this would show the video stream
    // For now, we'll just show a placeholder
    return Stack(
      children: [
        // Main video (other user)
        Container(
          color: Colors.grey[900],
          child: const Center(
            child: Text(
              'Video Call',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
        
        // Self video (picture-in-picture)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'You',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        
        // Call info overlay
        Positioned(
          top: 16,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otherUserName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isCallConnected
                    ? _formatDuration(_callDuration)
                    : widget.isOutgoing
                        ? 'Calling...'
                        : 'Incoming call',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCallView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: widget.otherUserImage.isNotEmpty
                  ? NetworkImage(widget.otherUserImage)
                  : null,
              child: widget.otherUserImage.isEmpty
                  ? Text(
                      widget.otherUserName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 48),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isCallConnected
                  ? _formatDuration(_callDuration)
                  : widget.isOutgoing
                      ? 'Calling...'
                      : 'Incoming call',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Colors.black,
      child: _isCallConnected || widget.isOutgoing
          ? _buildActiveCallControls()
          : _buildIncomingCallControls(),
    );
  }

  Widget _buildActiveCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCallButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          label: _isMuted ? 'Unmute' : 'Mute',
          onPressed: _toggleMute,
          backgroundColor: Colors.grey[800]!,
        ),
        _buildCallButton(
          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
          label: _isSpeakerOn ? 'Speaker Off' : 'Speaker On',
          onPressed: _toggleSpeaker,
          backgroundColor: Colors.grey[800]!,
        ),
        if (widget.callType == 'video')
          _buildCallButton(
            icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            label: _isVideoEnabled ? 'Video Off' : 'Video On',
            onPressed: _toggleVideo,
            backgroundColor: Colors.grey[800]!,
          ),
        _buildCallButton(
          icon: Icons.call_end,
          label: 'End',
          onPressed: _endCall,
          backgroundColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCallButton(
          icon: Icons.call_end,
          label: 'Decline',
          onPressed: _rejectCall,
          backgroundColor: Colors.red,
        ),
        _buildCallButton(
          icon: Icons.call,
          label: 'Answer',
          onPressed: _answerCall,
          backgroundColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
