import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../repository/chat_repository.dart';
import 'chat_state.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  ChatState _state = ChatState();

  // Timer for typing indicator
  Timer? _typingTimer;

  // Audio recording
  final _audioRecorder = AudioRecorder();
  String? _recordingPath;

  // Subscriptions
  final List<StreamSubscription> _subscriptions = [];

  ChatViewModel(this._repository) {
    _setupListeners();
  }

  // Getters
  ChatState get state => _state;

  // Initialize with user ID
  Future<void> initialize(String userId) async {
    _updateState(_state.copyWith(viewState: ChatViewState.loading));

    try {
      await _repository.initialize(userId);
      await refreshConversations();

      _updateState(
        _state.copyWith(
          viewState: ChatViewState.loaded,
          isConnected: _repository.isConnected(),
        ),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(
          viewState: ChatViewState.error,
          errorMessage: 'Failed to initialize chat: $e',
        ),
      );
    }
  }

  // Set up listeners for repository streams
  void _setupListeners() {
    // Listen for conversations updates
    _subscriptions.add(
      _repository.conversationsStream.listen((conversations) {
        _updateState(_state.copyWith(conversations: conversations));
      }),
    );

    // Listen for active conversation updates
    _subscriptions.add(
      _repository.activeConversationStream.listen((conversation) {
        _updateState(_state.copyWith(activeConversation: conversation));
      }),
    );

    // Listen for messages updates
    _subscriptions.add(
      _repository.messagesStream.listen((messages) {
        _updateState(_state.copyWith(messages: messages));

        // Scroll to bottom after messages update
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_state.scrollController.hasClients && messages.isNotEmpty) {
            _state.scrollController.animateTo(
              _state.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }),
    );
  }

  // Update state and notify listeners
  void _updateState(ChatState newState) {
    _state = newState;
    notifyListeners();
  }

  // Refresh conversations
  Future<void> refreshConversations() async {
    _updateState(_state.copyWith(viewState: ChatViewState.loading));

    try {
      await _repository.refreshConversations();
      _updateState(_state.copyWith(viewState: ChatViewState.loaded));
    } catch (e) {
      _updateState(
        _state.copyWith(
          viewState: ChatViewState.error,
          errorMessage: 'Failed to load conversations: $e',
        ),
      );
    }
  }

  // Open a conversation
  Future<void> openConversation(String conversationId) async {
    _updateState(_state.copyWith(viewState: ChatViewState.loading));

    try {
      await _repository.setActiveConversation(conversationId);
      _updateState(_state.copyWith(viewState: ChatViewState.loaded));
    } catch (e) {
      _updateState(
        _state.copyWith(
          viewState: ChatViewState.error,
          errorMessage: 'Failed to open conversation: $e',
        ),
      );
    }
  }

  // Create and open a new conversation
  Future<void> createAndOpenConversation(
    String merchantId,
    String merchantName,
  ) async {
    _updateState(_state.copyWith(viewState: ChatViewState.loading));

    try {
      final conversation = await _repository.createConversation(
        merchantId,
        merchantName,
      );
      await _repository.setActiveConversation(conversation.id);
      _updateState(_state.copyWith(viewState: ChatViewState.loaded));
    } catch (e) {
      _updateState(
        _state.copyWith(
          viewState: ChatViewState.error,
          errorMessage: 'Failed to create conversation: $e',
        ),
      );
    }
  }

  // Close active conversation
  void closeConversation() {
    _repository.clearActiveConversation();
    _updateState(
      _state.copyWith(
        viewState: ChatViewState.loaded,
        activeConversation: null,
        messages: [],
      ),
    );
  }

  // Send a text message
  Future<void> sendTextMessage() async {
    final text = _state.messageController.text.trim();
    if (text.isEmpty || _state.activeConversation == null) return;

    _updateState(_state.copyWith(viewState: ChatViewState.sending));
    dev.log(
      'Sending message: $text || ${_state.activeConversation!.id} || ${state.viewState.name}',
    );

    try {
      await _repository.sendMessage(
        _state.activeConversation!.id,
        text,
        MessageType.text,
      );

      // Clear text input
      _state.messageController.clear();
      _updateState(_state.copyWith(viewState: ChatViewState.loaded));

      // Stop typing indicator
      _stopTypingIndicator();
    } catch (e) {
      _updateState(
        _state.copyWith(
          viewState: ChatViewState.error,
          errorMessage: 'Failed to send message: $e',
        ),
      );
    }
  }

  // Handle text input changes for typing indicator
  void onTextChanged(String text) {
    // Cancel previous timer
    _typingTimer?.cancel();

    // Send typing indicator if text is not empty
    if (text.isNotEmpty && _state.activeConversation != null) {
      _sendTypingIndicator(true);

      // Set timer to stop typing indicator after 2 seconds of inactivity
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _stopTypingIndicator();
      });
    } else if (text.isEmpty) {
      _stopTypingIndicator();
    }
  }

  // Send typing indicator
  void _sendTypingIndicator(bool isTyping) {
    if (_state.activeConversation != null) {
      _repository.sendTypingIndicator(_state.activeConversation!.id, isTyping);
    }
  }

  // Stop typing indicator
  void _stopTypingIndicator() {
    if (_state.activeConversation != null) {
      _repository.sendTypingIndicator(_state.activeConversation!.id, false);
    }
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (_state.activeConversation == null ||
        _state.isLoadingMore ||
        !_state.hasMoreMessages) {
      return;
    }

    _updateState(_state.copyWith(isLoadingMore: true));

    try {
      final currentMessages = _state.messages;
      final offset = currentMessages.length;

      final messages = await _repository.refreshMessages(
        _state.activeConversation!.id,
        offset: offset,
      );

      // Check if we have more messages to load
      final hasMore = messages.length > currentMessages.length;

      _updateState(
        _state.copyWith(isLoadingMore: false, hasMoreMessages: hasMore),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Failed to load more messages: $e',
        ),
      );
    }
  }

  // Mark conversation as read
  Future<void> markAsRead() async {
    if (_state.activeConversation == null) return;

    try {
      await _repository.markConversationAsRead(_state.activeConversation!.id);
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
    }
  }

  // Delete selected messages
  Future<void> deleteSelectedMessages() async {
    if (_state.activeConversation == null ||
        _state.selectedMessageIds.isEmpty) {
      return;
    }

    try {
      await _repository.deleteMessages(
        _state.activeConversation!.id,
        _state.selectedMessageIds,
      );

      _updateState(_state.clearSelection());
    } catch (e) {
      _updateState(
        _state.copyWith(errorMessage: 'Failed to delete messages: $e'),
      );
    }
  }

  // Toggle attachment menu
  void toggleAttachmentMenu() {
    _updateState(_state.toggleAttachmentMenu());
  }

  // Toggle selection mode
  void toggleSelectionMode() {
    _updateState(_state.toggleSelectionMode());
  }

  // Toggle message selection
  void toggleMessageSelection(String messageId) {
    _updateState(_state.toggleMessageSelection(messageId));
  }

  // Clear error message
  void clearError() {
    _updateState(_state.clearError());
  }

  // Toggle search mode
  void toggleSearchMode() {
    _updateState(_state.toggleSearchMode());
  }

  // Search messages
  void searchMessages(String query) {
    if (query.isEmpty || _state.messages.isEmpty) {
      _updateState(_state.copyWith(searchResults: []));
      return;
    }

    final results =
        _state.messages.where((message) {
          return message.content.toLowerCase().contains(query.toLowerCase());
        }).toList();

    _updateState(_state.copyWith(searchQuery: query, searchResults: results));
  }

  // Send image message
  Future<void> sendImageMessage(ImageSource source) async {
    if (_state.activeConversation == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _updateState(_state.copyWith(viewState: ChatViewState.sending));

        // Upload file
        final fileUrl = await _repository.uploadFile(
          _state.activeConversation!.id,
          pickedFile.path,
          MessageType.image,
        );

        // Send message with file URL
        await _repository.sendMessage(
          _state.activeConversation!.id,
          fileUrl,
          MessageType.image,
        );

        _updateState(
          _state.copyWith(
            viewState: ChatViewState.loaded,
            isAttachmentMenuOpen: false,
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          viewState: ChatViewState.error,
          errorMessage: 'Failed to send image: $e',
          isAttachmentMenuOpen: false,
        ),
      );
    }
  }

  // Start audio recording
  Future<void> startRecording() async {
    if (_state.activeConversation == null) return;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Microphone permission is required to record audio',
        ),
      );
      return;
    }

    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      _recordingPath =
          '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
        // encoder: AudioEncoder.aacLc,
        // bitRate: 128000,
        // samplingRate: 44100,
      );

      _updateState(_state.copyWith(isRecording: true));
    } catch (e) {
      _updateState(
        _state.copyWith(errorMessage: 'Failed to start recording: $e'),
      );
    }
  }

  // Stop audio recording and send
  Future<void> stopRecordingAndSend() async {
    if (!_state.isRecording ||
        _recordingPath == null ||
        _state.activeConversation == null) {
      return;
    }

    try {
      // Stop recording
      await _audioRecorder.stop();

      _updateState(
        _state.copyWith(isRecording: false, viewState: ChatViewState.sending),
      );

      // Upload audio file
      final fileUrl = await _repository.uploadFile(
        _state.activeConversation!.id,
        _recordingPath!,
        MessageType.audio,
      );

      // Send message with file URL
      await _repository.sendMessage(
        _state.activeConversation!.id,
        fileUrl,
        MessageType.audio,
      );

      _updateState(_state.copyWith(viewState: ChatViewState.loaded));
    } catch (e) {
      _updateState(
        _state.copyWith(
          isRecording: false,
          viewState: ChatViewState.error,
          errorMessage: 'Failed to send audio: $e',
        ),
      );
    }
  }

  // Cancel audio recording
  Future<void> cancelRecording() async {
    if (!_state.isRecording) return;

    try {
      await _audioRecorder.stop();

      // Delete recording file
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _updateState(_state.copyWith(isRecording: false));
    } catch (e) {
      _updateState(
        _state.copyWith(
          isRecording: false,
          errorMessage: 'Failed to cancel recording: $e',
        ),
      );
    }
  }

  // Reconnect to chat server
  Future<void> reconnect() async {
    _updateState(_state.copyWith(viewState: ChatViewState.loading));

    try {
      final success = await _repository.connect();

      if (success) {
        // Refresh data
        await refreshConversations();

        if (_state.activeConversation != null) {
          await _repository.refreshMessages(_state.activeConversation!.id);
        }

        _updateState(
          _state.copyWith(viewState: ChatViewState.loaded, isConnected: true),
        );
      } else {
        _updateState(
          _state.copyWith(
            viewState: ChatViewState.offline,
            isConnected: false,
            errorMessage: 'Failed to connect to chat server',
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          viewState: ChatViewState.error,
          isConnected: false,
          errorMessage: 'Failed to reconnect: $e',
        ),
      );
    }
  }

  @override
  void dispose() {
    // Cancel subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    // Cancel typing timer
    _typingTimer?.cancel();

    // Dispose state resources
    _state.dispose();

    // Dispose audio recorder
    _audioRecorder.dispose();

    super.dispose();
  }
}
