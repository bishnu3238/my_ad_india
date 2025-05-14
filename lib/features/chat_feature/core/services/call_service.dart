import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_services.dart';

typedef OnSignalingMessage = void Function(Map<String, dynamic> data);

class CallService {
  final SocketService socketService;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  OnSignalingMessage? onSignalingMessage;
  Function(String state)? onIceConnectionState;

  CallService({required this.socketService, this.onSignalingMessage, this.onIceConnectionState});

  Future<void> initCall({required bool video}) async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': video,
      });
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      });

      _peerConnection!.addStream(_localStream!);

      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate != null) {
          socketService.sendMessage({
            'type': 'ice-candidate',
            'candidate': candidate.toMap(),
          });
        }
      };

      _peerConnection!.onAddStream = (stream) {
        _remoteStream = stream;
      };

      _peerConnection!.onIceConnectionState = (state) {
        if (onIceConnectionState != null) {
          onIceConnectionState!(state.toString());
        }
      };
    } catch (e) {
      throw Exception('Failed to initialize call: $e');
    }
  }

  Future<void> makeOffer(Map<String, dynamic> callData) async {
    try {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      socketService.initiateCall({
        ...callData,
        'sdp': offer.sdp,
        'type': offer.type,
      });
    } catch (e) {
      throw Exception('Failed to make offer: $e');
    }
  }

  Future<void> handleOffer(Map<String, dynamic> data) async {
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      socketService.respondToCall({
        ...data,
        'sdp': answer.sdp,
        'type': answer.type,
      });
    } catch (e) {
      throw Exception('Failed to handle offer: $e');
    }
  }

  Future<void> handleAnswer(Map<String, dynamic> data) async {
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
    } catch (e) {
      throw Exception('Failed to handle answer: $e');
    }
  }

  Future<void> handleIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      throw Exception('Failed to add ICE candidate: $e');
    }
  }

  // Mute/unmute microphone
  void toggleMute(bool mute) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !mute;
    });
  }

  // Enable/disable camera
  void toggleCamera(bool enable) {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = enable;
    });
  }

  // Switch camera (front/back)
  Future<void> switchCamera() async {
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
    }
  }

  // Hold/resume call
  void hold(bool hold) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !hold;
    });
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !hold;
    });
  }

  // Send DTMF tones (if supported)
  Future<void> sendDTMF(String tones) async {
    final senders = await _peerConnection?.getSenders();
    RTCRtpSender? audioSender;
    if (senders != null) {
      try {
        audioSender = senders.firstWhere((s) => s.track?.kind == 'audio');
      } catch (_) {
        audioSender = null;
      }
    }
    final dtmf = audioSender?.dtmfSender;
    if (dtmf != null) {
      await dtmf.insertDTMF(tones);
    }
  }

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  Future<void> dispose() async {
    await _localStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
  }
}
