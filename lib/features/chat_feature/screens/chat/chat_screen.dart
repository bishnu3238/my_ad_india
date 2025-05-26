import 'dart:developer' as dev;
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:my_ad/features/chat_feature/route/routes.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/provider/chat_provider.dart';
import '../../models/models.dart';
import '../../core/services/api_client.dart';
import '../../core/services/socket_services.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  final int receiverId;
  final int senderId;
  final String senderType; // 'customer'
  final String receiverName;
  final String? token;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.senderId,
    required this.senderType,
    required this.receiverName,
    this.token,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late ChatProvider chatProvider;
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  File? _attachment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _initSocket();
  }

  _initSocket() async {
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
    dev.log(
      'socket connected: ${chatProvider.socketService.connectionStatus.isBroadcast} ',
    );
  }

  Future<void> _startOrFetchConversation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      dev.log(
        "Fetching conversation... ${widget.senderId} ${widget.receiverId} ",
      );
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
    dev.log('Sending message: $data');

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
    });
  }

  void _onTyping(String value) {
    if (!_isTyping && value.isNotEmpty) {
      _isTyping = true;
      chatProvider.sendTyping({
        'conversationId': chatProvider.currentConversation?.id.toString(),
        'userType': widget.senderType,
        'userId': widget.senderId.toString(),
        'receiverType': 'merchant',
        'receiverId': widget.receiverId.toString(),
      });
    } else if (_isTyping && value.isEmpty) {
      _isTyping = false;
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
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
      // Implement delete chat logic (API call if available)
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
      'receiverType': 'merchant',
      'receiverId': widget.receiverId.toString(),
      'callType': video ? 'video' : 'audio',
    };
    // Implement call initiation via socket
    chatProvider.socketService.initiateCall(data);
    _showSnackBar(video ? 'Video call started...' : 'Audio call started...');
    // ChatFeatureRoutes.goToChatSdkScreen(  context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        chat.status;
        return Scaffold(
          appBar: _ChatAppBar(
            merchantName: widget.receiverName.capitalized,
            onDelete: _deleteChat,
            onShare: _shareChat,
            onCall: () => _call(video: false),
            onVideoCall: () => _call(video: true),
          ),
          body:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                    child: Text(_error!, style: TextStyle(color: Colors.red)),
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: _MessageList(
                          messages: chat.messages,
                          userType: widget.senderType,
                          userId: widget.senderId,
                        ),
                      ),
                      if (_attachment != null)
                        _AttachmentPreview(
                          file: _attachment!,
                          onRemove: () => setState(() => _attachment = null),
                        ),
                      _TypingIndicator(chat: chat),
                      _InputBar(
                        controller: _controller,
                        onSend: _onSend,
                        onTyping: _onTyping,
                        hasAttachment: _attachment != null,
                        pickAttachment: _pickAttachment,
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

// --- Modular Widgets ---

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String merchantName;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onCall;
  final VoidCallback onVideoCall;

  const _ChatAppBar({
    required this.merchantName,
    required this.onDelete,
    required this.onShare,
    required this.onCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    dev.log(
      "SOCKET CONNECTED: ${context.read<ChatProvider>().socketService.isConnected}",
    );
    return AppBar(
      leadingWidth: 45,
      leading:
          context.read<ChatProvider>().currentConversation == null
              ? const SizedBox()
              : Container(
                padding: 10.left,
                child: FittedBox(
                  child: ImageView(
                    shape: ImageShape.circle,
                    width: 20,
                    height: 20,
                    source: ImageSource.network,
                    path:
                        context
                            .read<ChatProvider>()
                            .currentConversation
                            ?.merchantImage!,
                  ),
                ),
              ),
      title: Row(
        children: [
          Expanded(
            child: AutoSizeText(
              merchantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: ScreenUtils().getFontSize(14),
                fontWeight: FontWeight.w600,
              ),
              // StatusIndicator(isOnline: ,),
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

class _MessageList extends StatelessWidget {
  final List<Message> messages;
  final String userType;
  final int userId;

  const _MessageList({
    required this.messages,
    required this.userType,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return messages.isEmpty
        ? Center(child: Text('No messages yet'))
        : ListView.builder(
          reverse: true,
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, idx) {
            final msg = messages[messages.length - 1 - idx];
            final isMe = msg.senderType == userType && msg.senderId == userId;
            return _MessageBubble(message: msg, isMe: isMe);
          },
        );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bgColor = isMe ? Colors.blue[100] : Colors.grey[200];
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
      bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
    );
    return Align(
      alignment: align,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
        child:
            message.messageType == 'file' && message.fileUrl != null
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file),
                    SizedBox(width: 8),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Implement file open/download logic
                        },
                        child: Text(
                          message.fileUrl ?? 'File',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Text(message.message),

                    // Text(message.createdAt.toUniversalTime()),
                  ],
                ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(child: Text(file.path.split('/').last)),
          IconButton(icon: Icon(Icons.close), onPressed: onRemove),
        ],
      ),
    );
  }
}

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

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(String) onTyping;
  final bool hasAttachment;
  final VoidCallback pickAttachment;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onTyping,
    required this.hasAttachment,
    required this.pickAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: 5.symmetricVH(8),
        child: Card(
          child: Row(
            children: [
              IconButton(
                icon: Icon(FontAwesomeIcons.paperclip),
                onPressed: pickAttachment,
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
                  color: hasAttachment ? Colors.blue : null,
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
