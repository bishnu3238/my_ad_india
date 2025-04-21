import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pack/extensions/contextx.dart';
import 'package:provider/provider.dart';

import '../core/ead_product_view_model.dart';

class EadProductsAppbar extends StatelessWidget implements PreferredSizeWidget {
  const EadProductsAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EadProductsViewModel>(
      builder: (context, viewModel, child) {
        return CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground,
          middle: Text(viewModel.title),
          automaticallyImplyLeading: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // TODO: Implement filter bottom sheet
                  _showFilterBottomSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Filter Services',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              // Add filter options like location, service type, etc.
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location'),
                onTap: () {
                  // TODO: Implement location filter
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Service Type'),
                onTap: () {
                  // TODO: Implement service type filter
                },
              ),
              // Add more filter options as needed
            ],
          ),
        );
      },
    );
  }
}

class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function() onClear;
  final String searchQuery;

  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
    required this.searchQuery,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isExpanded = true;
        });
        _animationController.forward();
      } else if (!_focusNode.hasFocus && _controller.text.isEmpty) {
        setState(() {
          _isExpanded = false;
        });
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onSearch,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              prefixIcon: Icon(
                Icons.search,
                color:
                    _isExpanded
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon:
                  _controller.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          widget.onClear();
                          _focusNode.unfocus();
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            cursorColor: theme.colorScheme.primary,
            textInputAction: TextInputAction.search,
            onSubmitted: widget.onSearch,
          ),
        ),
      ),
    );
  }
}
