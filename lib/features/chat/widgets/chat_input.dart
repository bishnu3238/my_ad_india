import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isRecording;
  final bool isAttachmentMenuOpen;
  final Function(String) onTextChanged;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;
  final VoidCallback onRecordCancel;

  const ChatInput({
    Key? key,
    required this.controller,
    this.isRecording = false,
    this.isAttachmentMenuOpen = false,
    required this.onTextChanged,
    required this.onSendPressed,
    required this.onAttachmentPressed,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onRecordStart,
    required this.onRecordStop,
    required this.onRecordCancel,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with SingleTickerProviderStateMixin {
  bool _showSend = false;
  late AnimationController _animationController;
  late Animation<double> _micScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Check if there's text already in the controller
    _showSend = widget.controller.text.trim().isNotEmpty;
    
    // Add listener to controller to toggle send button
    widget.controller.addListener(_onTextChanged);
    
    // Initialize animation controller for recording
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _micScaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start pulsing animation if recording
    if (widget.isRecording) {
      _animationController.repeat(reverse: true);
    }
  }
  
  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle recording state changes
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }
  
  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _showSend) {
      setState(() {
        _showSend = hasText;
      });
    }
    
    // Notify parent of text changes
    widget.onTextChanged(widget.controller.text);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Attachment menu
        if (widget.isAttachmentMenuOpen)
          _buildAttachmentMenu(),
        
        // Input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: Icon(
                    widget.isAttachmentMenuOpen
                        ? Icons.close
                        : Icons.attach_file,
                    color: widget.isAttachmentMenuOpen
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                  ),
                  onPressed: widget.onAttachmentPressed,
                ),
                
                // Text input field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !widget.isRecording,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send/Mic button
                _showSend
                    ? IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: widget.onSendPressed,
                      )
                    : _buildMicButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMicButton() {
    return GestureDetector(
      onLongPress: () {
        // Start recording
        widget.onRecordStart();
      },
      onLongPressEnd: (_) {
        // Stop recording and send
        widget.onRecordStop();
      },
      onLongPressCancel: () {
        // Cancel recording
        widget.onRecordCancel();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isRecording
                  ? Colors.red
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Transform.scale(
              scale: widget.isRecording ? _micScaleAnimation.value : 1.0,
              child: Icon(
                widget.isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAttachmentMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            color: Colors.purple,
            onTap: widget.onCameraPressed,
          ),
          _buildAttachmentOption(
            icon: Icons.photo,
            label: 'Gallery',
            color: Colors.green,
            onTap: widget.onGalleryPressed,
          ),
          _buildAttachmentOption(
            icon: Icons.location_on,
            label: 'Location',
            color: Colors.orange,
            onTap: () {
              // Location sharing functionality would go here
            },
          ),
          _buildAttachmentOption(
            icon: Icons.insert_drive_file,
            label: 'Document',
            color: Colors.blue,
            onTap: () {
              // Document sharing functionality would go here
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
