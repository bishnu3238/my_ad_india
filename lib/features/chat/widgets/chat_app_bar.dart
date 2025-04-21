import 'package:flutter/material.dart';
import '../models/chat_conversation.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatConversation? conversation;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onBackPressed;
  final VoidCallback onInfoPressed;
  final VoidCallback onClearSelection;
  final VoidCallback onDeleteSelected;
  final bool isSearching;
  final VoidCallback onSearchPressed;
  final Function(String) onSearchChanged;

  const ChatAppBar({
    Key? key,
    this.conversation,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    required this.onBackPressed,
    required this.onInfoPressed,
    required this.onClearSelection,
    required this.onDeleteSelected,
    this.isSearching = false,
    required this.onSearchPressed,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return _buildSearchAppBar(context);
    }
    
    if (isSelectionMode) {
      return _buildSelectionAppBar(context);
    }
    
    return _buildNormalAppBar(context);
  }

  AppBar _buildNormalAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      title: conversation != null ? Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: conversation!.merchantAvatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      conversation!.merchantAvatar!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.business,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.business,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation!.merchantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (conversation!.isActive)
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade400,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ) : const Text('Chat'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchPressed,
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: conversation != null ? onInfoPressed : null,
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onClearSelection,
      ),
      title: Text('$selectedCount selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: selectedCount > 0 ? onDeleteSelected : null,
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onSearchPressed,
      ),
      title: TextField(
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search messages...',
          border: InputBorder.none,
        ),
        onChanged: onSearchChanged,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
