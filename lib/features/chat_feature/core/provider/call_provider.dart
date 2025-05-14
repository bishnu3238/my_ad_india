import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../services/call_service.dart';

enum CallState { idle, connecting, ringing, inCall, ended, error, reconnecting }

class CallProvider with ChangeNotifier {
  final CallService callService;
  CallState callState = CallState.idle;
  bool isVideo = false;
  bool isMuted = false;
  bool isCameraOn = true;
  String? error;
  Duration callDuration = Duration.zero;
  DateTime? _callStartTime;
  VoidCallback? onCallEnded;
  VoidCallback? onCallStarted;
  VoidCallback? onCallFailed;
  VoidCallback? onCallReconnecting;

  CallProvider({required this.callService});

  MediaStream? get localStream => callService.localStream;
  MediaStream? get remoteStream => callService.remoteStream;

  // Start a call and track duration
  Future<void> startCall({required bool video, required Map<String, dynamic> callData}) async {
    isVideo = video;
    callState = CallState.connecting;
    error = null;
    notifyListeners();
    try {
      await callService.initCall(video: video);
      await callService.makeOffer(callData);
      callState = CallState.ringing;
      notifyListeners();
      _callStartTime = DateTime.now();
      _startDurationTimer();
      onCallStarted?.call();
    } catch (e) {
      callState = CallState.error;
      error = e.toString();
      onCallFailed?.call();
      notifyListeners();
    }
  }

  Future<void> answerCall(Map<String, dynamic> data) async {
    callState = CallState.inCall;
    error = null;
    notifyListeners();
    try {
      await callService.handleOffer(data);
      _callStartTime = DateTime.now();
      _startDurationTimer();
      onCallStarted?.call();
    } catch (e) {
      callState = CallState.error;
      error = e.toString();
      onCallFailed?.call();
      notifyListeners();
    }
  }

  Future<void> receiveAnswer(Map<String, dynamic> data) async {
    callState = CallState.inCall;
    error = null;
    notifyListeners();
    try {
      await callService.handleAnswer(data);
      if (_callStartTime == null) {
        _callStartTime = DateTime.now();
        _startDurationTimer();
      }
      onCallStarted?.call();
    } catch (e) {
      callState = CallState.error;
      error = e.toString();
      onCallFailed?.call();
      notifyListeners();
    }
  }

  Future<void> handleIceCandidate(Map<String, dynamic> data) async {
    try {
      await callService.handleIceCandidate(data);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void mute(bool mute) {
    isMuted = mute;
    callService.toggleMute(mute);
    notifyListeners();
  }

  void toggleCamera(bool enable) {
    isCameraOn = enable;
    callService.toggleCamera(enable);
    notifyListeners();
  }

  Future<void> switchCamera() async {
    await callService.switchCamera();
    notifyListeners();
  }

  // Call duration timer
  void _startDurationTimer() {
    callDuration = Duration.zero;
    if (_callStartTime == null) return;
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (callState == CallState.inCall && _callStartTime != null) {
        callDuration = DateTime.now().difference(_callStartTime!);
        notifyListeners();
        return true;
      }
      return false;
    });
  }

  // Reconnect logic (for network drops)
  Future<void> reconnectCall({required bool video, required Map<String, dynamic> callData}) async {
    callState = CallState.reconnecting;
    onCallReconnecting?.call();
    notifyListeners();
    try {
      await callService.dispose();
      await callService.initCall(video: video);
      await callService.makeOffer(callData);
      callState = CallState.inCall;
      notifyListeners();
    } catch (e) {
      callState = CallState.error;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> endCall() async {
    callState = CallState.ended;
    notifyListeners();
    await callService.dispose();
    callState = CallState.idle;
    error = null;
    _callStartTime = null;
    callDuration = Duration.zero;
    onCallEnded?.call();
    notifyListeners();
  }
}

