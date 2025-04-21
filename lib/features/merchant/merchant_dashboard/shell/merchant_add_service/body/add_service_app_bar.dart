import 'package:flutter/material.dart';

class AddServiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AddServiceAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Service Setup',
        style: TextStyle(
          color: Color(0xFF3A1B78),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
