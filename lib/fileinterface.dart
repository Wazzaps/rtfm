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

class UpdatesBegin extends DirViewUpdate {
  const UpdatesBegin() : super();
}

class UpdatesFinished extends DirViewUpdate {
  final String? error;
  const UpdatesFinished({this.error}) : super();
}

class DirViewRow {
  String name;
  FileType type;
  String? mimeType;
  DateTime? lastModified;
  int? size;
  bool isFolderExpanded;
  int depth;

  DirViewRow({
    this.name = "",
    this.type = FileType.unknown,
    this.mimeType,
    this.lastModified,
    this.size,
    this.isFolderExpanded = false,
    this.depth = 0,
  });

  @override
  String toString() {
    return "DirViewRow(name: $name, type: $type, isFolderExpanded: $isFolderExpanded, depth: $depth)";
  }
}

class DirView {
  final String path;
  late final Stream<DirViewUpdate> stream;
  late final StreamController<DirViewUpdate> _controller;

  DirView(this.path) {
    _controller = StreamController();
    stream = _controller.stream.asBroadcastStream();

    _controller.add(const UpdatesBegin());

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
      file.stat().then(
        (stat) {
          if (file is File) {
            _controller.add(RowUpdate(i, lastModified: stat.modified, size: stat.size));
          } else {
            _controller.add(RowUpdate(i, lastModified: stat.modified));
          }
        },
        onError: (err) {},
      );
      return i + 1;
    }).then(
      (_) {
        _controller.add(const UpdatesFinished());
      },
      onError: (err) {
        print("fs err: ${err.toString()}");
        if (err is FileSystemException && err.osError != null) {
          _controller.add(UpdatesFinished(error: err.osError!.message));
        } else {
          _controller.add(UpdatesFinished(error: err.toString()));
        }
      },
    );
  }

  DirViewRenderer render() {
    return DirViewRenderer(stream);
  }

  DirViewIsLoading isLoading() {
    return DirViewIsLoading(stream);
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
      // print("Update: $_update");
      if (_update is UpdatesBegin) {
        // Nothing to do right now
      } else if (_update is UpdatesFinished) {
        // Nothing to do right now
      } else if (_update is RowAdd) {
        RowAdd update = _update;

        _state.insert(update.rowId, DirViewRow());
      } else if (_update is RowDelete) {
        RowDelete update = _update;

        _state.removeAt(update.rowId);
      } else if (_update is RowUpdate) {
        RowUpdate update = _update;

        assert(_state.length >= update.rowId, "${_state.length} >= ${update.rowId}");

        if (update.name != null) {
          _state[update.rowId].name = update.name!;
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

class DirViewLoadInfo {
  final DirViewLoadState state;
  final String? error;

  const DirViewLoadInfo(this.state, {this.error});
}

enum DirViewLoadState {
  loaded,
  loading,
  error,
}

class DirViewIsLoading {
  late final Stream<DirViewLoadInfo> stream;
  late final StreamController<DirViewLoadInfo> _controller;
  DirViewLoadInfo _state = const DirViewLoadInfo(DirViewLoadState.loaded);
  Timer? timer;

  DirViewIsLoading(Stream<DirViewUpdate> updateStream) {
    _controller = StreamController();
    stream = _controller.stream;

    updateStream.forEach((_update) {
      if (_update is UpdatesBegin) {
        timer = Timer(
          const Duration(milliseconds: 200),
          () {
            _state = const DirViewLoadInfo(DirViewLoadState.loading);
            _controller.add(_state);
          },
        );
      } else if (_update is UpdatesFinished) {
        timer?.cancel();

        _state = _update.error == null
            ? const DirViewLoadInfo(DirViewLoadState.loaded)
            : DirViewLoadInfo(DirViewLoadState.error, error: _update.error);
        _controller.add(_state);
      }
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
