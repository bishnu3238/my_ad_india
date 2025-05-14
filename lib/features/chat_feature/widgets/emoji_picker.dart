import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {
  final void Function(String emoji) onEmojiSelected;

  const EmojiPicker({Key? key, required this.onEmojiSelected}) : super(key: key);

  static const _emojis = [
    '😀','😁','😂','🤣','😃','😄','😅','😆','😉','😊','😍','😘','😗','😙','😚','🙂','🤗','🤩','🤔','🤨','😐','😑','😶','🙄','😏','😣','😥','😮','🤐','😯','😪','😫','😴','😌','😛','😜','😝','🤤','😒','😓','😔','😕','🙃','🤑','😲','☹️','🙁','😖','😞','😟','😤','😢','😭','😦','😧','😨','😩','🤯','😬','😰','😱','🥵','🥶','😳','🤪','😵','😡','😠','🤬','😷','🤒','🤕','🤢','🤮','🤧','😇','🥳'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: Colors.grey[100],
      child: GridView.count(
        crossAxisCount: 8,
        children: _emojis.map((e) {
          return InkWell(
            onTap: () => onEmojiSelected(e),
            child: Center(child: Text(e, style: TextStyle(fontSize: 24))),
          );
        }).toList(),
      ),
    );
  }
}
