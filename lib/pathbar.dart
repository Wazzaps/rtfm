import 'package:flutter/material.dart';

import 'main.dart';

class PathBar extends StatelessWidget {
  final IconData rootIcon;
  final IconData currentIcon;
  final String path;
  final String rootText;
  final void Function(String path)? onNav;
  const PathBar({
    required this.path,
    required this.rootIcon,
    required this.rootText,
    required this.currentIcon,
    this.onNav,
    Key? key,
  }) : super(key: key);

  Widget _slash() {
    return const SizedBox(
      width: 13,
      height: 40,
      child: Center(
        child: Text(
          "/",
          style: TextStyle(
            color: Color(0xCCFFFFFF),
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }

  Widget _pathComponent(String text) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    List<String> parts = path.split("/");
    String last = parts.removeLast();

    bool currentDirIsRoot = parts.isEmpty || path == "/";

    if (!currentDirIsRoot) {
      widgets.add(Icon(rootIcon, color: Colors.white.withOpacity(0.8), size: 18));
      widgets.add(Container(width: 4));
      widgets.add(GestureDetector(
        onTapUp: (_) {
          var newPath = "/";
          print("Navigate: $newPath");
          if (onNav != null) {
            onNav!(newPath);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: _pathComponent(rootText),
      ));

      for (MapEntry<int, String> _part in parts.asMap().entries) {
        String part = _part.value;

        widgets.add(GestureDetector(
          onTapUp: (_) {
            var newPath = parts.getRange(0, _part.key + 1).join('/');
            print("Navigate: $newPath");
            if (onNav != null) {
              onNav!(newPath);
            }
          },
          behavior: HitTestBehavior.translucent,
          child: _pathComponent(part),
        ));
        widgets.add(GestureDetector(
          onTapUp: (_) {
            print("open path entry");
          },
          behavior: HitTestBehavior.translucent,
          child: _slash(),
        ));
      }
    }

    widgets.add(GestureDetector(
      onTap: () {
        print("open dir menu");
      },
      behavior: HitTestBehavior.translucent,
      child: ButtonWrapper(
        child: SizedBox(
          height: 30,
          child: Row(
            children: [
              Container(width: 9),
              Icon(currentDirIsRoot ? rootIcon : currentIcon, color: Colors.white, size: 18),
              Container(width: 4),
              Text(currentDirIsRoot ? rootText : last),
              Container(width: 2),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
              Container(width: 4),
            ],
          ),
        ),
      ),
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: 40,
        child: Row(children: widgets),
      ),
    );
  }
}
