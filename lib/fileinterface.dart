import 'dart:async';
import 'dart:io';

import 'package:rxdart/transformers.dart';

enum FileType {
  unknown,
  file,
  folder,
  symlink,
}

class FileInfo {
  String name;
  FileType type;
  String mimeType;
  int lastModified;
  int size;

  FileInfo(this.name, this.type, this.mimeType, this.lastModified, this.size);
}

class DirViewUpdate {
  const DirViewUpdate();
}

class RowAdd extends DirViewUpdate {
  final int rowId;

  const RowAdd(this.rowId) : super();
}

class RowUpdate extends DirViewUpdate {
  final int rowId;
  final String? name;
  final FileType? type;
  final String? mimeType;
  final DateTime? lastModified;
  final int? size;

  const RowUpdate(this.rowId, {this.name, this.type, this.mimeType, this.lastModified, this.size}) : super();
}

class RowDelete extends DirViewUpdate {
  final int rowId;

  const RowDelete(this.rowId) : super();
}

class DirViewRow {
  String name;
  String extension;
  FileType type;
  String? mimeType;
  DateTime? lastModified;
  int? size;
  bool isFolderExpanded;
  int depth;

  DirViewRow({
    this.name = "",
    this.extension = "",
    this.type = FileType.unknown,
    this.mimeType,
    this.lastModified,
    this.size,
    this.isFolderExpanded = false,
    this.depth = 0,
  });

  @override
  String toString() {
    return "DirViewRow(name: $name, extension: $extension, type: $type, isFolderExpanded: $isFolderExpanded, depth: $depth)";
  }
}

class DirView {
  final String path;
  late final Stream<DirViewUpdate> stream;
  late final StreamController<DirViewUpdate> _controller;

  DirView(this.path) {
    _controller = StreamController();
    stream = _controller.stream;

    // Read directory initially
    Directory(path).list(followLinks: false).fold(0, (int i, file) {
      _controller.add(RowAdd(i));
      FileType type = FileType.unknown;
      if (file is File) {
        type = FileType.file;
      } else if (file is Directory) {
        type = FileType.folder;
        file.list(followLinks: false).length.then((entCount) {
          _controller.add(RowUpdate(i, size: entCount));
        });
      } else if (file is Link) {
        type = FileType.symlink;
      }
      _controller.add(RowUpdate(i, name: file.path.split("/").last, type: type));
      file.stat().then((stat) {
        if (file is File) {
          _controller.add(RowUpdate(i, lastModified: stat.modified, size: stat.size));
        } else {
          _controller.add(RowUpdate(i, lastModified: stat.modified));
        }
      });
      return i + 1;
    });
  }

  DirViewRenderer render() {
    return DirViewRenderer(stream);
  }
}

class DirViewRenderer {
  late final Stream<List<DirViewRow>> stream;
  late final StreamController<List<DirViewRow>> _controller;
  final List<DirViewRow> _state = [];

  DirViewRenderer(Stream<DirViewUpdate> updateStream) {
    _controller = StreamController();
    stream = _controller.stream;

    updateStream.forEach((_update) {
      print("Update: $_update");
      if (_update is RowAdd) {
        RowAdd update = _update;

        _state.insert(update.rowId, DirViewRow());
      } else if (_update is RowDelete) {
        RowDelete update = _update;

        _state.removeAt(update.rowId);
      } else if (_update is RowUpdate) {
        RowUpdate update = _update;

        assert(_state.length >= update.rowId, "${_state.length} >= ${update.rowId}");

        if (update.name != null) {
          var parts = update.name!.split(".");
          if (parts.length >= 2) {
            _state[update.rowId].extension = ".${parts.removeLast()}";
          }
          _state[update.rowId].name = parts.join(".");
        }
        if (update.type != null) {
          _state[update.rowId].type = update.type!;
        }
        if (update.mimeType != null) {
          _state[update.rowId].mimeType = update.mimeType!;
        }
        if (update.lastModified != null) {
          _state[update.rowId].lastModified = update.lastModified!;
        }
        if (update.size != null) {
          _state[update.rowId].size = update.size!;
        }
      } else {
        print("Unknown update type: ${_update.runtimeType}");
      }

      _controller.add(_state);
    });
  }
}

void main() {
  var dirView = DirView("/home/david/code/bolddata");
  var renderer = dirView.render();
  renderer.stream.debounceTime(const Duration(milliseconds: 10)).forEach((state) {
    print("State: $state");
  });
}
