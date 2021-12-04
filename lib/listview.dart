import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ColumnType {
  tree,
  string,
  stringMuted,
}

class FileListColumn {
  final String name;
  final int width;
  final bool expands;
  final ColumnType type;

  const FileListColumn(this.name, this.width, {this.type = ColumnType.string, this.expands = false});
}

class FileListTree {
  final String name;
  final String extension;
  final bool isFolder;
  final bool isFolderExpanded;
  final IconData icon;
  final Color iconColor;
  final int depth;

  const FileListTree({
    required this.name,
    required this.icon,
    this.iconColor = const Color(0xFFBFC0C0),
    this.depth = 0,
    this.extension = "",
    this.isFolder = false,
    this.isFolderExpanded = false,
  });
}

class FileListView extends StatefulWidget {
  final List<FileListColumn> columns;
  final List<List<dynamic>> data;

  const FileListView({Key? key, required this.columns, this.data = const []}) : super(key: key);

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  Widget _colHeader(String name, double width, {bool isFirst = false, bool isSorted = false, bool isSortRev = false}) {
    return SizedBox(
      width: width,
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
    IconData? icon,
    Color iconColor, {
    String extension = "",
    bool isFolder = false,
    bool isFolderExpanded = false,
    int depth = 0,
    required double width,
  }) {
    return Row(
      children: [
        SizedBox(
          width: width,
          child: Row(
            children: [
              SizedBox(width: 4 + depth * 14),
              if (isFolder && isFolderExpanded)
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFBFC0C0),
                  size: 12,
                ),
              if (isFolder && !isFolderExpanded)
                const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Color(0xFFBFC0C0),
                  size: 12,
                ),
              if (!isFolder) const SizedBox(width: 12),
              const SizedBox(width: 4),
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor,
                  size: 12,
                ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.fade,
                  textWidthBasis: TextWidthBasis.longestLine,
                  softWrap: false,
                ),
              ),
              Text(
                extension,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF929293),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var colWidths = <int>[];
      if (widget.columns.isNotEmpty) {
        colWidths = widget.columns.map((c) => c.width).toList();
        var expandableCols = widget.columns.asMap().entries.where((e) => e.value.expands).map((e) => e.key).toList();
        if (expandableCols.isEmpty) {
          expandableCols = [widget.columns.length - 1];
        }

        var totalRequestedWidth = colWidths.reduce((a, b) => a + b);
        var extraWidth = math.max(constraints.maxWidth - totalRequestedWidth, 0);
        var extraWidthPerCol = (extraWidth / expandableCols.length).floor();

        var firstExpandableColIdx = expandableCols.removeAt(0);
        for (var colIdx in expandableCols) {
          colWidths[colIdx] += extraWidthPerCol;
          extraWidth -= extraWidthPerCol;
        }
        colWidths[firstExpandableColIdx] += extraWidth.floor();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column titles
          Container(
            height: 17,
            child: Row(
              children: widget.columns
                  .asMap()
                  .entries
                  .map((w) => _colHeader(
                        w.value.name,
                        colWidths[w.key].toDouble(),
                        isFirst: w.key == 0,
                        isSorted: w.key == 0,
                      ))
                  .toList(),
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
                if (index < widget.data.length) {
                  return Container(
                    height: 18,
                    color: (index % 2 == 0) ? const Color(0xFF252628) : const Color(0xFF1E1F21),
                    child: Row(
                      children: widget.data[index].asMap().entries.map((e) {
                        final colMetadata = widget.columns[e.key];
                        Widget w = const Text("[ERR]");

                        switch (colMetadata.type) {
                          case ColumnType.tree:
                            var tree = e.value as FileListTree;
                            w = _fileRow(
                              tree.name,
                              tree.icon,
                              tree.iconColor,
                              width: colWidths[e.key].toDouble(),
                              extension: tree.extension,
                              isFolder: tree.isFolder,
                              isFolderExpanded: tree.isFolderExpanded,
                              depth: tree.depth,
                            );
                            break;

                          case ColumnType.string:
                          case ColumnType.stringMuted:
                            w = Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 2.0),
                              child: Text(
                                e.value as String,
                                style: TextStyle(
                                  color: colMetadata.type == ColumnType.stringMuted
                                      ? const Color(0xFF929293)
                                      : const Color(0xFFFFFFFF),
                                ),
                                overflow: TextOverflow.fade,
                                textWidthBasis: TextWidthBasis.longestLine,
                                softWrap: false,
                              ),
                            );
                            break;
                        }

                        return SizedBox(width: colWidths[e.key].toDouble(), child: w);
                      }).toList(),
                    ),
                  );
                } else {
                  return Container(
                    height: 18,
                    color: (index % 2 == 0) ? const Color(0xFF252628) : const Color(0xFF1E1F21),
                  );
                }
              },
            ),
          ),
        ],
      );
    });
  }
}
