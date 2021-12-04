import 'package:flutter/material.dart';

class FileListView extends StatelessWidget {
  const FileListView({Key? key}) : super(key: key);

  Widget _colHeader(String name, double width, {bool isFirst = false, bool isSorted = false, bool isSortRev = false}) {
    return Container(
      constraints: BoxConstraints(minWidth: width),
      child: Row(
        children: [
          if (!isFirst)
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(width: 1, color: const Color(0xFF4B4C4D)),
            ),
          SizedBox(width: (isFirst ? 6 : 3)),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFFBFC0C0),
              fontSize: 12,
            ),
          ),
          if (isSorted)
            Icon(
              (isSortRev ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded),
              color: const Color(0xFFBFC0C0),
              size: 12,
            )
        ],
      ),
    );
  }

  Widget _fileRow(
    String name,
    IconData? icon, {
    String extension = "",
    bool isEvenRow = false,
    bool isFolder = false,
    int depth = 0,
  }) {
    return Container(
      height: 18,
      color: isEvenRow ? const Color(0xFF252628) : const Color(0xFF1E1F21),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: Row(
              children: [
                SizedBox(width: 4 + depth * 14),
                if (isFolder)
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFBFC0C0),
                    size: 12,
                  ),
                if (!isFolder) const SizedBox(width: 12),
                const SizedBox(width: 4),
                if (icon != null)
                  Icon(
                    icon,
                    color: const Color(0xFFBFC0C0),
                    size: 12,
                  ),
                const SizedBox(width: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> files = <Widget>[
      _fileRow("A Folder", Icons.folder_rounded, isEvenRow: true, isFolder: true),
      _fileRow("Another Folder", Icons.folder_rounded, isEvenRow: false, isFolder: true, depth: 1),
      _fileRow("A File Inside 2", Icons.description_rounded, extension: ".txt", isEvenRow: true, depth: 2),
      _fileRow("A File Inside", Icons.description_rounded, extension: ".txt", isEvenRow: false, depth: 1),
      _fileRow("File 1", Icons.description_rounded, extension: ".txt", isEvenRow: true),
      _fileRow("File 2", Icons.description_rounded, extension: ".txt", isEvenRow: false),
      _fileRow("File 3", Icons.description_rounded, extension: ".txt", isEvenRow: true),
      _fileRow("File 4", Icons.description_rounded, extension: ".txt", isEvenRow: false),
      _fileRow("File 5", Icons.description_rounded, extension: ".txt", isEvenRow: true),
      _fileRow("File 6", Icons.description_rounded, extension: ".txt", isEvenRow: false),
      _fileRow("File 7", Icons.description_rounded, extension: ".txt", isEvenRow: true),
    ];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column titles
          Container(
            height: 17,
            child: Row(
              children: [
                _colHeader("Name", 300, isFirst: true, isSorted: true),
                const Spacer(),
                _colHeader("Last Modified", 125),
                _colHeader("Size", 80),
                _colHeader("Type", 110),
              ],
            ),
            color: const Color(0xFF2B2C2E),
          ),

          // Spacers
          Container(
            height: 1,
            color: const Color(0xFF404142),
          ),
          Container(
            height: 1,
            color: const Color(0xFF1B1C1E),
          ),

          // Files
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (index < files.length) {
                  return files[index];
                } else {
                  return _fileRow("", null, isEvenRow: index % 2 == 0);
                }
              },
            ),
          ),
        ],
      ),
      color: const Color(0xFF1E1F21),
    );
  }
}
