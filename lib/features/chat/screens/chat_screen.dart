import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/chat_models.dart';
import '../services/chat_manager.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherUserImage;
  final String otherUserType;
  final String otherUserId;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserImage,
    required this.otherUserType,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _isSending = false;
  bool _showAttachmentOptions = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    // Set current conversation
    chatManager.setCurrentConversation(
      widget.conversationId,
      widget.otherUserType,
      widget.otherUserId,
    );
    
    // Load messages
    await chatManager.loadMessages(widget.conversationId, refresh: true);
    
    setState(() {
      _isLoading = false;
    });
    
    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    setState(() {
      _isSending = true;
    });
    
    try {
      await chatManager.sendTextMessage(message);
      _messageController.clear();
      
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    
    setState(() {
      _isSending = true;
      _showAttachmentOptions = false;
    });
    
    try {
      final chatManager = Provider.of<ChatManager>(context, listen: false);
      await chatManager.sendFileMessage(File(image.path), 'image');
      
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendFile() async {
    final XFile? file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    
    setState(() {
      _isSending = true;
      _showAttachmentOptions = false;
    });
    
    try {
      final chatManager = Provider.of<ChatManager>(context, listen: false);
      await chatManager.sendFileMessage(File(file.path), 'file');
      
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send file: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _initiateCall(String callType) {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    try {
      chatManager.initiateCall(callType);
      
      // Navigate to call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            isOutgoing: true,
            callType: callType,
            otherUserName: widget.otherUserName,
            otherUserImage: widget.otherUserImage,
            otherUserType: widget.otherUserType,
            otherUserId: widget.otherUserId,
            conversationId: widget.conversationId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initiate call: $e')),
      );
    }
  }

  void _showInquiryDialog() {
    final TextEditingController inquiryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Inquiry'),
        content: TextField(
          controller: inquiryController,
          decoration: const InputDecoration(
            hintText: 'Enter your inquiry details...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final inquiry = inquiryController.text.trim();
              if (inquiry.isEmpty) return;
              
              Navigator.pop(context);
              
              final chatManager = Provider.of<ChatManager>(context, listen: false);
              
              try {
                await chatManager.sendInquiry(inquiry, widget.otherUserId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inquiry sent successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to send inquiry: $e')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUserImage.isNotEmpty
                  ? NetworkImage(widget.otherUserImage)
                  : null,
              child: widget.otherUserImage.isEmpty
                  ? Text(widget.otherUserName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 8),
            Text(widget.otherUserName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _initiateCall('audio'),
            tooltip: 'Audio call',
            key: const ValueKey('chat_audio_call_button'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _initiateCall('video'),
            tooltip: 'Video call',
            key: const ValueKey('chat_video_call_button'),
          ),
          Consumer<ChatManager>(
            builder: (context, chatManager, _) {
              if (chatManager.userType == 'customer') {
                return IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: _showInquiryDialog,
                  tooltip: 'Send inquiry',
                  key: const ValueKey('chat_inquiry_button'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        final messages = chatManager.getMessages(widget.conversationId);
        
        if (messages.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        
        // Group messages by date
        final Map<String, List<ChatMessage>> groupedMessages = {};
        final dateFormat = DateFormat('MMMM d, yyyy');
        
        for (var message in messages) {
          final dateString = dateFormat.format(message.createdAt);
          if (!groupedMessages.containsKey(dateString)) {
            groupedMessages[dateString] = [];
          }
          groupedMessages[dateString]!.add(message);
        }
        
        final sortedDates = groupedMessages.keys.toList()
          ..sort((a, b) => dateFormat.parse(a).compareTo(dateFormat.parse(b)));
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dateMessages = groupedMessages[date]!;
            
            return Column(
              children: [
                _buildDateSeparator(date),
                ...dateMessages.map((message) => _buildMessageBubble(message)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateSeparator(String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final timeFormat = DateFormat('h:mm a');
    final isMe = message.isMine;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.messageType == 'image')
             _buildImageMessage(message)
            else if (message.messageType == 'file')
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('File Attachment'),
                subtitle: Text(message.message),
                onTap: () {
                  // Open file
                },
              )
            else if (message.messageType == 'inquiry')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inquiry',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(message.message),
                  ],
                ),
              )
            else
              Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeFormat.format(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Consumer<ChatManager>(
      builder: (context, chatManager, child) {
        final isTyping = chatManager.isTyping(widget.conversationId);
        
        return Column(
          children: [
            if (isTyping)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.otherUserName} is typing...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (_showAttachmentOptions)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.image,
                      label: 'Image',
                      onTap: _sendImage,
                    ),
                    _buildAttachmentOption(
                      icon: Icons.attach_file,
                      label: 'File',
                      onTap: _sendFile,
                    ),
                    _buildAttachmentOption(
                      icon: Icons.close,
                      label: 'Cancel',
                      onTap: () => setState(() => _showAttachmentOptions = false),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _showAttachmentOptions = !_showAttachmentOptions),
                    tooltip: 'Add attachment',
                    key: const ValueKey('chat_attachment_button'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => chatManager.sendTypingIndicator(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                          onPressed: _sendMessage,
                          tooltip: 'Send message',
                          key: const ValueKey('chat_send_button'),
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  // Helper method to handle image URLs safely
  Widget _buildImageMessage(ChatMessage message) {
    if (message.fileUrl == null || message.fileUrl!.isEmpty) {
      return const Text('Image not available');
    }
    
    String imageUrl = message.fileUrl!;
    
    // Validate URL
    try {
      final uri = Uri.parse(imageUrl);
      if (!uri.hasScheme) {
        // If no scheme, assume it's a relative URL and add the server base URL
        imageUrl = 'http://localhost:3000${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
      }
    } catch (e) {
      return Text('Invalid image URL: $imageUrl');
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
