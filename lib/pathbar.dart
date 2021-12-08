import 'package:flutter/material.dart';

import 'main.dart';

class PathBar extends StatelessWidget {
  final IconData rootIcon;
  final IconData currentIcon;
  final String path;
  const PathBar({required this.path, required this.rootIcon, required this.currentIcon, Key? key}) : super(key: key);

  Widget _slash() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        "/",
        style: TextStyle(
          color: Color(0xCCFFFFFF),
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }

  Widget _pathComponent(String text) {
    return Text(text, style: TextStyle(color: Colors.white.withOpacity(0.8)));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    List<String> parts = path.split("/");
    String last = parts.removeLast();

    if (parts.isNotEmpty) {
      widgets.add(Icon(rootIcon, color: Colors.white.withOpacity(0.8), size: 18));
      widgets.add(Container(width: 4));

      for (String part in parts) {
        widgets.add(_pathComponent(part));
        widgets.add(_slash());
      }
    }

    widgets.add(ButtonWrapper(
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            Container(width: 9),
            Icon(parts.isEmpty ? rootIcon : currentIcon, color: Colors.white, size: 18),
            Container(width: 4),
            Text(last),
            Container(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
            Container(width: 4),
          ],
        ),
      ),
    ));

    return Row(children: widgets);
  }
}
