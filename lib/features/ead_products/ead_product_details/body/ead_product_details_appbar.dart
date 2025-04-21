import 'package:flutter/material.dart';

class EadServiceDetailsAppBar extends StatelessWidget implements PreferredSizeWidget{
  const EadServiceDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text('data'),);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
