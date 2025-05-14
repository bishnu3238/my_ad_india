import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:pack/extensions/extensions.dart';
import '../../core/provider/chat_provider.dart';
import '../../models/models.dart';
import '../../core/services/socket_services.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/attachment_preview.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/emoji_picker.dart';
import '../../widgets/attachment_picker.dart';
import '../../utils/message_formater.dart';

class ChatDetailScreen extends StatefulWidget {
  final int receiverId;
  final int senderId;
  final String senderType;
  final String receiverName;
  final String? token;

  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.senderId,
    required this.senderType,
    required this.receiverName,
    this.token,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  late ChatProvider chatProvider;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  File? _attachment;
  bool _isLoading = true;
  String? _error;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  Future<void> _initSocket() async {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.socketService.connect(
      baseUrl: ApiConfig.socketUrl,
      userType: widget.senderType,
      userId: widget.senderId,
      token: widget.token,
    );
    if (chatProvider.socketService.connectionStatus.isBroadcast) {
      _startOrFetchConversation();
      chatProvider.listenForNewMessages();
    }
  }

  Future<void> _startOrFetchConversation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      int customerId =
          widget.senderType == 'customer' ? widget.senderId : widget.receiverId;
      int merchantId =
          widget.senderType == 'merchant' ? widget.senderId : widget.receiverId;
      int conversationId = await chatProvider.apiClient.createConversation(
        customerId,
        merchantId,
      );
      Conversation convo = await chatProvider.apiClient.getConversationDetails(
        conversationId,
      );
      await chatProvider.selectConversation(convo);
    } catch (e) {
      setState(() {
        _error = 'Failed to start chat: $e';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachment == null) return;

    Map<String, dynamic> data = {
      'conversationId': chatProvider.currentConversation?.id.toString(),
      'senderType': widget.senderType,
      'senderId': widget.senderId.toString(),
      'receiverType': widget.senderType == 'merchant' ? 'customer' : 'merchant',
      'receiverId': widget.receiverId.toString(),
      'message': text.isNotEmpty ? text : 'Attachment',
      'messageType': _attachment != null ? 'file' : 'text',
      'fileUrl': null,
    };

    if (_attachment != null) {
      try {
        final url = await chatProvider.apiClient.uploadFile(_attachment!);
        data['fileUrl'] = url;
      } catch (e) {
        _showSnackBar('File upload failed: $e');
        return;
      }
    }

    await chatProvider.sendMessage(data);
    _controller.clear();
    setState(() {
      _attachment = null;
      _isTyping = false;
      _showEmojiPicker = false;
    });
    _scrollToBottom();
  }

  void _onTyping(String value) {
    if (!_isTyping && value.isNotEmpty) {
      _isTyping = true;
      chatProvider.sendTyping({
        'conversationId': chatProvider.currentConversation?.id.toString(),
        'userType': widget.senderType,
        'userId': widget.senderId.toString(),
        'receiverType':
            widget.senderType == 'merchant' ? 'customer' : 'merchant',
        'receiverId': widget.receiverId.toString(),
      });
    } else if (_isTyping && value.isEmpty) {
      _isTyping = false;
    }
  }

  Future<void> _pickAttachment() async {
    final file = await AttachmentPicker.pick(context);
    if (file != null) {
      setState(() {
        _attachment = file;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _deleteChat() async {
    if (chatProvider.currentConversation == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete Chat'),
            content: Text('Are you sure you want to delete this chat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      chatProvider.clear();
      Navigator.pop(context);
    }
  }

  void _shareChat() {
    if (chatProvider.messages.isEmpty) return;
    final chatText = chatProvider.messages
        .map((m) => '${m.senderName ?? m.senderType}: ${m.message}')
        .join('\n');
    Share.share(chatText, subject: 'Chat with ${widget.receiverName}');
  }

  void _call({required bool video}) {
    final data = {
      'conversationId': chatProvider.currentConversation?.id.toString(),
      'callerType': widget.senderType,
      'callerId': widget.senderId.toString(),
      'receiverType': widget.senderType == 'merchant' ? 'customer' : 'merchant',
      'receiverId': widget.receiverId.toString(),
      'callType': video ? 'video' : 'audio',
    };
    chatProvider.socketService.initiateCall(data);
    _showSnackBar(video ? 'Video call started...' : 'Audio call started...');
    // Navigate to call screen if needed
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        return Scaffold(
          appBar: _AdvancedChatAppBar(
            merchantName: widget.receiverName.capitalized,
            merchantImage: chat.currentConversation?.merchantImage,
            isOnline: true, // TODO: Bind to real online status
            onDelete: _deleteChat,
            onShare: _shareChat,
            onCall: () => _call(video: false),
            onVideoCall: () => _call(video: true),
          ),
          body:
              _isLoading
                  ? const LoadingIndicator(message: "Loading chat...")
                  : _error != null
                  ? Center(
                    child: Text(_error!, style: TextStyle(color: Colors.red)),
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            _AdvancedMessageList(
                              messages: chat.messages,
                              userType: widget.senderType,
                              userId: widget.senderId,
                              scrollController: _scrollController,
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: _TypingIndicator(chat: chat),
                            ),
                          ],
                        ),
                      ),
                      if (_attachment != null)
                        AttachmentPreviewBeforeSend(
                          file: _attachment!,
                          fileName: _attachment!.path.split('/').last,
                          onRemove: () => setState(() => _attachment = null),
                        ),
                      _AdvancedInputBar(
                        controller: _controller,
                        onSend: _onSend,
                        onTyping: _onTyping,
                        hasAttachment: _attachment != null,
                        pickAttachment: _pickAttachment,
                        showEmojiPicker: _showEmojiPicker,
                        onEmojiPressed: _toggleEmojiPicker,
                      ),
                      if (_showEmojiPicker)
                        EmojiPicker(
                          onEmojiSelected: (emoji) {
                            _controller.text += emoji;
                            _onTyping(_controller.text);
                          },
                        ),
                    ],
                  ),
          // floatingActionButton:
          //     chat.messages.length > 10
          //         ? FloatingActionButton(
          //           mini: true,
          //           onPressed: _scrollToBottom,
          //           tooltip: "Scroll to latest",
          //           child: Icon(Icons.arrow_downward),
          //         )
          //         : null,
        );
      },
    );
  }
}

// --- Advanced AppBar with avatar, status, and actions ---
class _AdvancedChatAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String merchantName;
  final String? merchantImage;
  final bool isOnline;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onCall;
  final VoidCallback onVideoCall;

  const _AdvancedChatAppBar({
    required this.merchantName,
    required this.merchantImage,
    required this.isOnline,
    required this.onDelete,
    required this.onShare,
    required this.onCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage:
                  merchantImage != null ? NetworkImage(merchantImage!) : null,
              child:
                  merchantImage == null ? Icon(Icons.person, size: 28) : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: StatusIndicator(isOnline: isOnline, size: 12),
            ),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            merchantName,
            maxLines: 1,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Text(
            isOnline ? "Online" : "Offline",
            style: TextStyle(
              fontSize: 12,
              color: isOnline ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.call),
          tooltip: 'Audio Call',
          onPressed: onCall,
        ),
        IconButton(
          icon: Icon(Icons.videocam),
          tooltip: 'Video Call',
          onPressed: onVideoCall,
        ),
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'Share Chat',
          onPressed: onShare,
        ),
        IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'Delete Chat',
          onPressed: onDelete,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// --- Advanced Message List with date separators and status ---
class _AdvancedMessageList extends StatelessWidget {
  final List<Message> messages;
  final String userType;
  final int userId;
  final ScrollController scrollController;

  const _AdvancedMessageList({
    required this.messages,
    required this.userType,
    required this.userId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(child: Text('No messages yet'));
    }
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, idx) {
        final msg = messages[messages.length - 1 - idx];
        final isMe = msg.senderType == userType && msg.senderId == userId;
        final showDate =
            idx == 0 ||
            MessageFormatter.formatMessageTime(msg.createdAt) !=
                MessageFormatter.formatMessageTime(
                  messages[messages.length - idx].createdAt,
                );
        return Column(
          children: [
            if (showDate)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  MessageFormatter.formatMessageTime(msg.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            MessageBubble(
              message: msg,
              isMe: isMe,
              onLongPress: () {
                // Show options: copy, delete, forward, reply
                showModalBottomSheet(
                  context: context,
                  builder:
                      (ctx) => _MessageActionsSheet(message: msg, isMe: isMe),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// --- Typing Indicator ---
class _TypingIndicator extends StatefulWidget {
  final ChatProvider chat;
  const _TypingIndicator({required this.chat});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
    widget.chat.socketService.onUserTyping.listen((event) {
      setState(() {
        _show = true;
      });
      _controller.repeat(reverse: true);
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) setState(() => _show = false);
        _controller.stop();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return SizedBox.shrink();
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Merchant is typing...'),
          ],
        ),
      ),
    );
  }
}

// --- Advanced Input Bar with emoji and attachment ---
class _AdvancedInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(String) onTyping;
  final bool hasAttachment;
  final VoidCallback pickAttachment;
  final bool showEmojiPicker;
  final VoidCallback onEmojiPressed;

  const _AdvancedInputBar({
    required this.controller,
    required this.onSend,
    required this.onTyping,
    required this.hasAttachment,
    required this.pickAttachment,
    required this.showEmojiPicker,
    required this.onEmojiPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Card(
          child: Row(
            children: [
              IconButton(
                icon: Icon(FontAwesomeIcons.paperclip),
                onPressed: pickAttachment,
              ),
              IconButton(
                icon: Icon(
                  Icons.emoji_emotions,
                  color: showEmojiPicker ? Colors.blue : null,
                ),
                onPressed: onEmojiPressed,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onTyping,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color:
                      hasAttachment || controller.text.isNotEmpty
                          ? Colors.blue
                          : null,
                ),
                onPressed: onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Message Actions Bottom Sheet ---
class _MessageActionsSheet extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageActionsSheet({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.copy),
            title: Text('Copy'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.message));
              Navigator.pop(context);
            },
          ),
          if (isMe)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                // TODO: Implement delete message
                Navigator.pop(context);
              },
            ),
          ListTile(
            leading: Icon(Icons.reply),
            title: Text('Reply'),
            onTap: () {
              // TODO: Implement reply
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.forward),
            title: Text('Forward'),
            onTap: () {
              // TODO: Implement forward
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
