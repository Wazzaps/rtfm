import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
// import 'package:native_winpos/native_winpos.dart';
import 'package:rtfm/listview.dart';
import 'package:rtfm/pathbar.dart';
import 'package:rxdart/transformers.dart';

import 'fileinterface.dart';

void main() {
  runApp(const MyApp());
}

class CustomBoxShadow extends BoxShadow {
  final BlurStyle blurStyle;

  const CustomBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.blurStyle = BlurStyle.normal,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(blurStyle, blurSigma);
    assert(() {
      if (debugDisableShadows) result.maskFilter = null;
      return true;
    }());
    return result;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<List<DirViewRow>> _dirStream;
  late Stream<DirViewLoadInfo> _dirIsLoadingStream;
  String dirPath = "/home/david/code/bolddata";
  List<String> navHistory = [];
  List<double> scrollHistory = [];
  List<int?> selectedRowHistory = [];
  int? selectedRowIdx;
  final ScrollController _scrollController = ScrollController();
  bool backBtnHovered = false;
  bool backBtnPressed = false;

  void setPath(String path) {
    dirPath = path;
    var dirView = DirView(dirPath);

    var renderer = dirView.render();
    _dirStream = renderer.stream.debounceTime(const Duration(milliseconds: 1));

    var isLoading = dirView.isLoading();
    _dirIsLoadingStream = isLoading.stream;
  }

  void pushPath(String newPath) {
    navHistory.add(dirPath);
    scrollHistory.add(_scrollController.position.pixels);
    selectedRowHistory.add(selectedRowIdx);
    setPath(newPath);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    selectedRowIdx = null;
  }

  void popPath() {
    if (navHistory.isNotEmpty) {
      setPath(navHistory.removeLast());
    }
    if (scrollHistory.isNotEmpty && _scrollController.hasClients) {
      _scrollController.jumpTo(scrollHistory.removeLast());
    }
    if (selectedRowHistory.isNotEmpty) {
      selectedRowIdx = selectedRowHistory.removeLast();
    }
  }

  @override
  void initState() {
    setPath(dirPath);
    super.initState();
  }

  @override
  void didUpdateWidget(MyApp oldWidget) {
    print("_MyAppState.didUpdateWidget");
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // _dirSub.cancel();
    super.dispose();
  }

  Widget _sidebarRow(IconData icon, String text, {Color iconColor = Colors.white, String? linksTo}) {
    return GestureDetector(
      onTapUp: (_) {
        if (linksTo != null) {
          setState(() {
            pushPath(linksTo);
          });
        }
      },
      child: Container(
        height: 22.0,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(width: 9),
            Icon(icon, color: iconColor, size: 16.0),
            Container(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.fade,
                textWidthBasis: TextWidthBasis.longestLine,
                softWrap: false,
                style: const TextStyle(
                  color: Color(0xffffffff),
                  fontSize: 14,
                  fontFamily: "Ubuntu",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarTag(Color color, String text) {
    return Container(
      height: 22.0,
      alignment: Alignment.centerLeft,
      child: Row(children: [
        Container(width: 13),
        // Icon(Icons.circle, color: color, size: 12.0),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
            boxShadow: [
              CustomBoxShadow(
                color: color.withOpacity(0.8),
                blurRadius: 4,
              ),
            ],
            // border: Border.all(color: Colors.black.withOpacity(0.6), width: 1),
          ),
        ),
        Container(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xffffffff),
              fontSize: 14,
              fontFamily: "Ubuntu",
            ),
          ),
        ),
      ]),
    );
  }

  Widget _sidebarCategory(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 2.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0x80ffffff),
          fontSize: 12,
          fontFamily: "Ubuntu",
          // fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var backBtnColor = const Color(0x00FFFFFF);
    if (backBtnPressed && navHistory.isNotEmpty) {
      backBtnColor = const Color(0x30000000);
    } else if (backBtnHovered && navHistory.isNotEmpty) {
      backBtnColor = const Color(0x0cFFFFFF);
    }

    return BoldApp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                BIconButtons(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          popPath();
                        });
                      },
                      child: MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            backBtnHovered = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            backBtnHovered = false;
                            backBtnPressed = false;
                          });
                        },
                        child: Listener(
                          onPointerDown: (_) {
                            setState(() {
                              backBtnPressed = true;
                            });
                          },
                          onPointerUp: (_) {
                            setState(() {
                              backBtnPressed = false;
                            });
                          },
                          onPointerCancel: (_) {
                            setState(() {
                              backBtnPressed = false;
                            });
                          },
                          child: AnimatedContainer(
                            width: 30,
                            duration: const Duration(milliseconds: 60),
                            color: backBtnColor,
                            child: Icon(
                              Icons.keyboard_arrow_left_rounded,
                              color: navHistory.isNotEmpty ? Colors.white : Colors.white24,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: Colors.white24,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                PathBar(
                  path: dirPath,
                  // rootIcon: Icons.home_rounded,
                  rootIcon: Icons.desktop_windows_rounded,
                  rootText: "David's PC",
                  currentIcon: Icons.folder_rounded,
                  onNav: (String newPath) {
                    setState(() {
                      pushPath(newPath);
                    });
                  },
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: BIconButton(Icons.search_rounded),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: BIconButton(Icons.grid_view_rounded),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: BIconButton(Icons.splitscreen_rounded),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: BIconButton(Icons.more_horiz),
                ),
                const WindowButtons(),
              ],
            ),
          ),

          // Bottom half of window
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sidebar
                SizedBox(
                  width: 160,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sidebarCategory("Favorites"),
                        _sidebarRow(Icons.history_rounded, "Recent"),
                        _sidebarRow(Icons.home_rounded, "Home", linksTo: "/home/david"),
                        _sidebarRow(Icons.description_rounded, "Documents",
                            linksTo: "/home/david/Documents", iconColor: const Color(0xFFA1D7F3)),
                        _sidebarRow(Icons.download_rounded, "Downloads", linksTo: "/home/david/Downloads"),
                        _sidebarRow(Icons.delete_rounded, "Trash", iconColor: const Color(0xFF8698A1)),
                        _sidebarRow(Icons.folder_rounded, "Folder with a long name",
                            iconColor: const Color(0xFFF0BE80),
                            linksTo: "/run/user/1000/gvfs/sftp:host=homeserver.local,user=ubuntu"),
                        _sidebarCategory("Tags"),
                        _sidebarTag(const Color(0xFFFF6464), "Work"),
                        _sidebarTag(const Color(0xFF64C7FF), "Research"),
                        _sidebarTag(const Color(0xFFDBFF74), "Personal"),
                        _sidebarCategory("Disks"),
                        _sidebarRow(Icons.desktop_windows_rounded, "David's PC", linksTo: "/"),
                        _sidebarRow(Icons.phone_android_rounded, "David's Phone"),
                        _sidebarRow(Icons.cloud, "Google Drive"),
                        _sidebarRow(Icons.cloud, "Dropbox"),
                        _sidebarRow(Icons.cloud, "John's NAS"),
                        _sidebarRow(Icons.usb_rounded, "Flash Drive"),
                        const Spacer(),
                        _sidebarRow(Icons.more_horiz, "Other Locations"),
                      ],
                    ),
                  ),
                ),

                // Main contents
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      // Outer shimmer
                      border: Border(
                        top: BorderSide(color: Colors.white.withAlpha(40), width: 1),
                        left: BorderSide(color: Colors.white.withAlpha(40), width: 1),
                      ),
                    ),
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        // Inner shadow
                        border: Border(
                          top: BorderSide(color: Colors.black.withAlpha(51), width: 1),
                          left: BorderSide(color: Colors.black.withAlpha(51), width: 1),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          StreamBuilder<List<DirViewRow>>(
                              stream: _dirStream,
                              initialData: const [],
                              builder: (context, snapshot) {
                                List<List<Object>> dirData = [];
                                if (snapshot.hasData) {
                                  dirData = snapshot.data!.map((f) {
                                    switch (f.type) {
                                      case FileType.folder:
                                        return [
                                          FileListTree(
                                            name: f.name,
                                            icon: Icons.folder_rounded,
                                            iconColor: const Color(0xFFF0BE80),
                                            isFolder: true,
                                            isFolderExpanded: false,
                                          ),
                                          f.lastModified != null ? "${f.lastModified}" : "...",
                                          f.size != null ? "${f.size} items" : "...",
                                          "Folder",
                                        ];
                                      case FileType.file:
                                        return [
                                          FileListTree(
                                            name: f.name,
                                            icon: Icons.description_rounded,
                                            iconColor: const Color(0xFFA1D7F3),
                                          ),
                                          f.lastModified != null ? "${f.lastModified}" : "...",
                                          f.size != null ? formatByteSize(f.size!) : "...",
                                          "File",
                                        ];
                                      case FileType.symlink:
                                        return [
                                          FileListTree(
                                            name: f.name,
                                            icon: Icons.link,
                                            iconColor: const Color(0xFFBABABA),
                                          ),
                                          f.lastModified != null ? "${f.lastModified}" : "...",
                                          "",
                                          "Link",
                                        ];
                                      default:
                                        return [
                                          FileListTree(
                                            name: f.name,
                                            icon: Icons.error_rounded,
                                            iconColor: const Color(0xFFB96034),
                                          ),
                                          f.lastModified != null ? "${f.lastModified}" : "...",
                                          "...",
                                          "Folder",
                                        ];
                                    }
                                  }).toList();
                                  dirData.sort((a, b) {
                                    var aTree = (a.first as FileListTree?)!;
                                    var bTree = (b.first as FileListTree?)!;

                                    // Sort folders first
                                    if (aTree.isFolder != bTree.isFolder) {
                                      return aTree.isFolder ? -1 : 1;
                                    }

                                    return aTree.name.toLowerCase().compareTo(bTree.name.toLowerCase());
                                  });
                                }
                                return FileListView(
                                  onEntryActivate: (rowId) {
                                    var fileListTree = dirData[rowId].first as FileListTree?;
                                    if (fileListTree!.isFolder) {
                                      setState(() {
                                        pushPath("${dirPath == '/' ? '' : dirPath}/${fileListTree.name}");
                                      });
                                    }
                                  },
                                  onEntrySelect: (rowId) {
                                    setState(() {
                                      selectedRowIdx = rowId;
                                    });
                                  },
                                  scrollController: _scrollController,
                                  selectedRowIdx: selectedRowIdx,
                                  columns: const [
                                    FileListColumn("Name", 200, type: ColumnType.tree, expands: true),
                                    FileListColumn("Last Modified", 175, type: ColumnType.stringMuted),
                                    FileListColumn("Size", 80, type: ColumnType.stringMuted),
                                    FileListColumn("Type", 110, type: ColumnType.stringMuted),
                                  ],
                                  data: dirData,
                                );
                              }),
                          Align(
                            alignment: Alignment.topCenter,
                            child: StreamBuilder<DirViewLoadInfo>(
                              stream: _dirIsLoadingStream,
                              initialData: const DirViewLoadInfo(DirViewLoadState.loaded),
                              builder: (context, snapshot) {
                                if (snapshot.data!.state == DirViewLoadState.loading) {
                                  // Loading indicator
                                  return Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      // Outer shimmer
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(color: Colors.white.withAlpha(40), width: 1),
                                      color: const Color(0xFF1E1F21),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFC4C4C4),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (snapshot.data!.state == DirViewLoadState.error) {
                                  // Error bar
                                  return Container(
                                    margin: const EdgeInsets.only(left: 20, right: 20, top: 28),
                                    decoration: BoxDecoration(
                                      // Outer shimmer
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withAlpha(40), width: 1),
                                      color: const Color(0xFF1E1F21),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.error_rounded, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              snapshot.data!.error!,
                                              softWrap: true,
                                              // textWidthBasis: TextWidthBasis.longestLine,
                                              textScaleFactor: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      isDarkTheme: true,
      isTransparencyDisabled: false,
    );
  }

  String formatByteSize(int size) {
    if (size > 1024 * 1024 * 1024 * 1024) {
      return "${(size / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TiB";
    }
    if (size > 1024 * 1024 * 1024) {
      return "${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GiB";
    }
    if (size > 1024 * 1024) {
      return "${(size / (1024 * 1024)).toStringAsFixed(1)} MiB";
    }
    if (size > 1024) {
      return "${(size / 1024).toStringAsFixed(1)} KiB";
    }
    return "$size bytes";
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        children: [
          // Minimize
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 18.0, 7.0, 12.0),
            child: Container(
              width: 8.0,
              height: 2.0,
              color: const Color(0xFFF7F7F7),
            ),
          ),

          // Close
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 8.0, 8.0, 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 16.0,
                height: 16.0,
                color: const Color(0xFFF55E1E),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Text("⨉"), // XXX: replace with actual X icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BIconButton extends StatefulWidget {
  final IconData icon;
  final void Function()? onTap;
  final bool disabled;

  const BIconButton(this.icon, {Key? key, this.onTap, this.disabled = false}) : super(key: key);

  @override
  State<BIconButton> createState() => _BIconButtonState();
}

class _BIconButtonState extends State<BIconButton> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    var bgColor = const Color(0x00FFFFFF);
    if (pressed && !widget.disabled) {
      bgColor = const Color(0x50000000);
    } else if (hovered && !widget.disabled) {
      bgColor = const Color(0x0cFFFFFF);
    }

    return ButtonWrapper(
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              hovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              hovered = false;
              pressed = false;
            });
          },
          child: Listener(
            onPointerDown: (_) {
              setState(() {
                pressed = true;
              });
            },
            onPointerUp: (_) {
              setState(() {
                pressed = false;
              });
            },
            onPointerCancel: (_) {
              setState(() {
                pressed = false;
              });
            },
            child: AnimatedContainer(
              width: 31,
              height: 28,
              duration: const Duration(milliseconds: 60),
              color: bgColor,
              child: Icon(
                widget.icon,
                color: widget.disabled ? Colors.white24 : Colors.white,
                size: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BIconButtons extends StatelessWidget {
  final List<Widget> children;
  const BIconButtons({required this.children, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (children.isNotEmpty) {
      Widget last = children.last;
      for (var child in children.take(children.length - 1)) {
        widgets.add(child);
        widgets.add(Container(width: 1, color: const Color(0x4D000000)));
      }
      widgets.add(last);
    }
    return ButtonWrapper(
      child: SizedBox(
          height: 28,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets,
          )),
    );
  }
}

class ButtonWrapper extends StatelessWidget {
  final Widget child;

  const ButtonWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            child: child,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// void readWindowPosition() {
//   DynamicLibrary.open('libGLES_v3.so');
// }

class BoldApp extends StatefulWidget {
  final Widget child;
  final bool isDarkTheme;
  final bool isTransparencyDisabled;

  const BoldApp({
    Key? key,
    required this.child,
    this.isDarkTheme = true,
    this.isTransparencyDisabled = false,
  }) : super(key: key);

  @override
  State<BoldApp> createState() => _BoldAppState();
}

class _BoldAppState extends State<BoldApp> {
  bool isMaximized = false;
  int background = 0;

  @override
  Widget build(BuildContext context) {
    var backgrounds = [
      FileImage(File("/home/david/Pictures/Wallpapers/void_4k_desktop.jpg")),
      FileImage(File("/home/david/Pictures/Wallpapers/calidity_4k.jpg")),
      FileImage(File("/home/david/Pictures/Wallpapers/pretty-colors-fhd.png")),
      FileImage(File("/home/david/Pictures/Wallpapers/submerged_4k_desktop.jpg")),
      FileImage(File("/home/david/Pictures/Wallpapers/stress.png")),
    ];
    return MediaQuery.fromWindow(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Desktop image for demo
            Image(
              image: backgrounds[background],
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),

            // Window borders
            GestureDetector(
              onTap: () async {
                // print(await NativeWinpos.windowPos);
              },
              onTertiaryTapDown: (_) {
                setState(() {
                  isMaximized = !isMaximized;
                });
              },
              onSecondaryTapDown: (TapDownDetails _details) {
                setState(() {
                  background = (background + 1) % backgrounds.length;
                });
              },
              child: AnimatedPadding(
                padding: isMaximized
                    ? const EdgeInsets.all(0)
                    : const EdgeInsets.symmetric(vertical: 40.0, horizontal: 50.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.linearToEaseOut,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isMaximized ? 0 : 10),
                    boxShadow: [
                      CustomBoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 22,
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                    border:
                        Border.all(color: Colors.black.withOpacity(isMaximized ? 0 : 0.6), width: isMaximized ? 0 : 1),
                  ),
                  child: Stack(
                    children: [
                      // Mica layer wrapping child
                      ClipRRect(
                        borderRadius: BorderRadius.circular(isMaximized ? 0 : 10),
                        child: widget.isTransparencyDisabled
                            ? Container(
                                child: widget.child,

                                // Brightness layer depending on theme
                                color: widget.isDarkTheme ? const Color(0xFF1E1E1E) : const Color(0xFFF1F1F1),
                              )
                            : BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 200.0, sigmaY: 200.0, tileMode: TileMode.mirror),
                                child: Container(
                                  child: widget.child,

                                  // Brightness layer depending on theme
                                  color: widget.isDarkTheme
                                      ? const Color.fromARGB(200, 30, 30, 30)
                                      : Colors.white.withAlpha(180),
                                ),
                              ),
                      ),

                      // Window shimmer
                      IgnorePointer(
                        ignoring: true,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isMaximized ? 0 : 10),
                            border: Border.all(color: Colors.white.withAlpha(isMaximized ? 0 : 40), width: 1),
                          ),
                        ),
                      )
                    ],
                    fit: StackFit.expand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
