import 'package:flutter/material.dart';
import 'package:pack/ui/ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuildAvatar<T> extends StatelessWidget {
  final List<T>? list;
  final VoidCallback onTap;
  const BuildAvatar({super.key, this.list, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          list == null && list == [] ? 3 : list!.length,
              (index) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ImageView(
              source: ImageSource.network,
              onTap: onTap,
              path: list != null && list != [] ?
              list![index].toString() :
              'https://i.pravatar.cc/150?img=${index + 1}',
            ),
          ),
        ),
        Icon(FontAwesomeIcons.plus, color: theme.surface, size: 18),
      ],
    );
  }
}
