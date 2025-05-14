import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../../core/provider/call_provider.dart';

class CallScreen extends StatefulWidget {
  final bool isIncoming;
  final Map<String, dynamic>
  callData; // Contains caller/receiver info, callType, etc.

  const CallScreen({super.key, required this.isIncoming, required this.callData});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  bool _micOn = true;
  bool _camOn = true;
  bool _speakerOn = false;
  bool _isFrontCamera = true;
  late AnimationController _ringController;
  late Animation<double> _ringAnim;
  String? _error;
  late CallProvider callProvider;

  @override
  void initState() {
    super.initState();
    callProvider = Provider.of<CallProvider>(context, listen: false);

    _ringController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _ringAnim = Tween<double>(begin: 0.7, end: 1.0).animate(_ringController);
    _ringController.repeat(reverse: true);

    if (!widget.isIncoming) {
      _startOutgoingCall();
    }
  }

  Future<void> _startOutgoingCall() async {
    try {
      await callProvider.startCall(
        video: widget.callData['callType'] == 'video',
        callData: widget.callData,
      );
    } catch (e) {
      setState(() => _error = 'Failed to start call: $e');
    }
  }

  Future<void> _answerCall() async {
    try {
      await callProvider.answerCall(widget.callData);
    } catch (e) {
      setState(() => _error = 'Failed to answer call: $e');
    }
  }

  Future<void> _endCall() async {
    await callProvider.endCall();
    if (mounted) Navigator.pop(context);
  }

  void _toggleMic() {
    setState(() => _micOn = !_micOn);
    callProvider.localStream?.getAudioTracks().forEach((track) {
      track.enabled = _micOn;
    });
  }

  void _toggleCam() {
    setState(() => _camOn = !_camOn);
    callProvider.localStream?.getVideoTracks().forEach((track) {
      track.enabled = _camOn;
    });
  }

  void _switchCamera() async {
    final videoTrack = callProvider.localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
      setState(() => _isFrontCamera = !_isFrontCamera);
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    callProvider.endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, call, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Video view
              if (call.isVideo && call.remoteStream != null)
                RTCVideoView(
                  RTCVideoRenderer()..srcObject = call.remoteStream,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              if (call.isVideo && call.localStream != null)
                Positioned(
                  right: 16,
                  top: 48,
                  child: SizedBox(
                    width: 120,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RTCVideoView(
                        RTCVideoRenderer()..srcObject = call.localStream,
                        mirror: _isFrontCamera,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ),
              // Call UI overlay
              _CallOverlay(
                isIncoming: widget.isIncoming,
                callProvider: call,
                micOn: _micOn,
                camOn: _camOn,
                speakerOn: _speakerOn,
                isFrontCamera: _isFrontCamera,
                ringAnim: _ringAnim,
                ringController: _ringController,
                onAnswer: _answerCall,
                onEnd: _endCall,
                onMic: _toggleMic,
                onCam: _toggleCam,
                onSwitchCamera: _switchCamera,
                error: _error,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CallOverlay extends StatelessWidget {
  final bool isIncoming;
  final CallProvider callProvider;
  final bool micOn;
  final bool camOn;
  final bool speakerOn;
  final bool isFrontCamera;
  final Animation<double> ringAnim;
  final AnimationController ringController;
  final VoidCallback onAnswer;
  final VoidCallback onEnd;
  final VoidCallback onMic;
  final VoidCallback onCam;
  final VoidCallback onSwitchCamera;
  final String? error;

  const _CallOverlay({
    required this.isIncoming,
    required this.callProvider,
    required this.micOn,
    required this.camOn,
    required this.speakerOn,
    required this.isFrontCamera,
    required this.ringAnim,
    required this.ringController,
    required this.onAnswer,
    required this.onEnd,
    required this.onMic,
    required this.onCam,
    required this.onSwitchCamera,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final callState = callProvider.callState;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(error!, style: TextStyle(color: Colors.red)),
              ),
            if (callState == CallState.connecting ||
                callState == CallState.ringing)
              ScaleTransition(
                scale: ringAnim,
                child: Icon(
                  Icons.ring_volume,
                  color: Colors.greenAccent,
                  size: 64,
                ),
              ),
            if (callState == CallState.inCall) _CallTimer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CallActionButton(
                  icon: micOn ? Icons.mic : Icons.mic_off,
                  color: micOn ? Colors.white : Colors.red,
                  onTap: onMic,
                  tooltip: micOn ? 'Mute' : 'Unmute',
                ),
                if (callProvider.isVideo)
                  _CallActionButton(
                    icon: camOn ? Icons.videocam : Icons.videocam_off,
                    color: camOn ? Colors.white : Colors.red,
                    onTap: onCam,
                    tooltip: camOn ? 'Turn off camera' : 'Turn on camera',
                  ),
                if (callProvider.isVideo)
                  _CallActionButton(
                    icon: Icons.cameraswitch,
                    color: Colors.white,
                    onTap: onSwitchCamera,
                    tooltip: 'Switch camera',
                  ),
                _CallActionButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: onEnd,
                  tooltip: 'End Call',
                ),
                if (isIncoming && callState == CallState.ringing)
                  _CallActionButton(
                    icon: Icons.call,
                    color: Colors.green,
                    onTap: onAnswer,
                    tooltip: 'Answer',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }
}

class _CallTimer extends StatefulWidget {
  @override
  State<_CallTimer> createState() => _CallTimerState();
}

class _CallTimerState extends State<_CallTimer> {
  late Stopwatch _stopwatch;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration _) {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '$minutes:$seconds',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
