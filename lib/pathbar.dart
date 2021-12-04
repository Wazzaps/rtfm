import 'package:flutter/material.dart';

import 'main.dart';

class PathBar extends StatelessWidget {
  const PathBar({Key? key}) : super(key: key);

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
    return Row(
      children: [
        Icon(Icons.home_rounded, color: Colors.white.withOpacity(0.8), size: 18),
        Container(width: 4),
        _pathComponent("Home"),
        _slash(),
        _pathComponent("Documents"),
        _slash(),
        _pathComponent("Reports"),
        _slash(),
        _pathComponent("2020"),
        _slash(),
        ButtonWrapper(
          child: SizedBox(
            height: 30,
            child: Row(
              children: [
                Container(width: 9),
                const Icon(Icons.folder_rounded, color: Colors.white, size: 18),
                Container(width: 4),
                const Text("From Greg"),
                Container(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                Container(width: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
