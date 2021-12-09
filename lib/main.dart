import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
  late final Stream<List<DirViewRow>> _dirStream;
  String dirPath = "/home/david/code/bolddata";

  @override
  void initState() {
    var dirView = DirView(dirPath);
    var renderer = dirView.render();
    _dirStream = renderer.stream.debounceTime(const Duration(milliseconds: 50));
  }

  @override
  void didUpdateWidget(MyApp oldWidget) {
    print("_MyAppState.didUpdateWidget");
  }

  @override
  void dispose() {
    // _dirSub.cancel();
  }

  Widget _sidebarRow(IconData icon, String text, {Color iconColor = Colors.white}) {
    return Container(
      height: 22.0,
      alignment: Alignment.centerLeft,
      child: Row(children: [
        Container(width: 1),
        Icon(icon, color: iconColor, size: 16.0),
        Container(width: 4),
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

  Widget _sidebarTag(Color color, String text) {
    return Container(
      height: 22.0,
      alignment: Alignment.centerLeft,
      child: Row(children: [
        Container(width: 5),
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
      padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
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
    return BoldApp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                const BIconButtons(),
                const Spacer(),
                PathBar(
                  path: dirPath.replaceAll("/home/david/", "Home/"),
                  rootIcon: Icons.home_rounded,
                  currentIcon: Icons.folder_rounded,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sidebarCategory("Favorites"),
                      _sidebarRow(Icons.history_rounded, "Recent"),
                      _sidebarRow(Icons.home_rounded, "Home"),
                      _sidebarRow(Icons.description_rounded, "Documents", iconColor: const Color(0xFFA1D7F3)),
                      _sidebarRow(Icons.download_rounded, "Downloads"),
                      _sidebarRow(Icons.delete_rounded, "Trash", iconColor: const Color(0xFF8698A1)),
                      _sidebarRow(Icons.folder_rounded, "Custom Folder", iconColor: const Color(0xFFF0BE80)),
                      _sidebarCategory("Tags"),
                      _sidebarTag(const Color(0xFFFF6464), "Work"),
                      _sidebarTag(const Color(0xFF64C7FF), "Research"),
                      _sidebarTag(const Color(0xFFDBFF74), "Personal"),
                      _sidebarCategory("Disks"),
                      _sidebarRow(Icons.desktop_windows_rounded, "David's PC"),
                      _sidebarRow(Icons.history_rounded, "David's Phone"),
                      _sidebarRow(Icons.cloud, "Google Drive"),
                      _sidebarRow(Icons.cloud, "Dropbox"),
                      _sidebarRow(Icons.cloud, "John's NAS"),
                      _sidebarRow(Icons.usb_rounded, "Flash Drive"),
                      const Spacer(),
                      _sidebarRow(Icons.more_horiz, "Other Locations"),
                    ],
                  ),
                ),

                // Main contents
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      // Inner shimmer
                      border: Border(
                        top: BorderSide(color: Colors.white.withAlpha(40), width: 1),
                        left: BorderSide(color: Colors.white.withAlpha(40), width: 1),
                      ),
                    ),
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        // Inner shimmer
                        border: Border(
                          top: BorderSide(color: Colors.black.withAlpha(51), width: 1),
                          left: BorderSide(color: Colors.black.withAlpha(51), width: 1),
                        ),
                      ),
                      child: StreamBuilder<List<DirViewRow>>(
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
                                        extension: f.extension,
                                        icon: Icons.folder_rounded,
                                        iconColor: Color(0xFFF0BE80),
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
                                        extension: f.extension,
                                        icon: Icons.description_rounded,
                                        iconColor: Color(0xFFA1D7F3),
                                      ),
                                      f.lastModified != null ? "${f.lastModified}" : "...",
                                      f.size != null ? "${f.size} bytes" : "...",
                                      "File",
                                    ];
                                  case FileType.symlink:
                                    return [
                                      FileListTree(
                                        name: f.name,
                                        extension: f.extension,
                                        icon: Icons.link,
                                        iconColor: Color(0xFFBABABA),
                                      ),
                                      f.lastModified != null ? "${f.lastModified}" : "...",
                                      "",
                                      "Link",
                                    ];
                                  default:
                                    return [
                                      FileListTree(
                                        name: f.name,
                                        extension: f.extension,
                                        icon: Icons.error_rounded,
                                        iconColor: Color(0xFFB96034),
                                      ),
                                      f.lastModified != null ? "${f.lastModified}" : "...",
                                      "...",
                                      "Folder",
                                    ];
                                }
                              }).toList();
                              dirData.sort((a, b) {
                                if ((a.first as FileListTree?)!.isFolder != (b.first as FileListTree?)!.isFolder) {
                                  return (a.first as FileListTree?)!.isFolder ? -1 : 1;
                                }
                                return (a.first as FileListTree?)!.name.compareTo((b.first as FileListTree?)!.name);
                              });
                            }
                            return FileListView(
                              columns: [
                                FileListColumn("Name", 200, type: ColumnType.tree, expands: true),
                                FileListColumn("Last Modified", 175, type: ColumnType.stringMuted),
                                FileListColumn("Size", 80, type: ColumnType.stringMuted),
                                FileListColumn("Type", 110, type: ColumnType.stringMuted),
                              ],
                              data: dirData,
                              // data: [
                              //   [
                              //     FileListTree(
                              //       name: "A Folder",
                              //       icon: Icons.folder_rounded,
                              //       iconColor: Color(0xFFF0BE80),
                              //       isFolder: true,
                              //       isFolderExpanded: true,
                              //     ),
                              //     "Yesterday at 10:45",
                              //     "2 items",
                              //     "Folder",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name:
                              //           "Another Folder Long Text Long Text Long Text Long Text Long Text Long Text Long Text Long Text",
                              //       icon: Icons.folder_rounded,
                              //       iconColor: Color(0xFFF0BE80),
                              //       isFolder: true,
                              //       isFolderExpanded: true,
                              //       depth: 1,
                              //     ),
                              //     "Yesterday at 10:19",
                              //     "1 item",
                              //     "Folder",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name:
                              //           "A File Inside 2 Long Text Long Text Long Text Long Text Long Text Long Text Long Text Long Text",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //       depth: 2,
                              //     ),
                              //     "Yesterday at 10:21",
                              //     "10 bytes",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "A File Inside",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //       depth: 1,
                              //     ),
                              //     "Today at 09:10",
                              //     "1.2 KiB",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "File 1",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //     ),
                              //     "Today at 09:01",
                              //     "120 KiB",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "File 2",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //     ),
                              //     "Today at 09:02",
                              //     "1 MiB",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "File 3",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //     ),
                              //     "Today at 09:03",
                              //     "20 bytes",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "File 4",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //     ),
                              //     "Today at 09:04",
                              //     "30 bytes",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "File 5",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //     ),
                              //     "Today at 09:05",
                              //     "40 bytes",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "File 6",
                              //       extension: ".txt",
                              //       icon: Icons.description_rounded,
                              //       iconColor: Color(0xFFA1D7F3),
                              //     ),
                              //     "Today at 09:06",
                              //     "50 bytes",
                              //     "Plain Text",
                              //   ],
                              //   [
                              //     FileListTree(
                              //       name: "Some Movie",
                              //       extension: ".mov",
                              //       icon: Icons.movie_rounded,
                              //       iconColor: Color(0xFFFFFFFF),
                              //     ),
                              //     "Today at 09:07",
                              //     "1.2 GiB",
                              //     "QuickTime Video",
                              //   ],
                              // ]
                            );
                          }),
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

class BIconButton extends StatelessWidget {
  final IconData icon;

  const BIconButton(this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonWrapper(
      child: SizedBox(
        width: 31,
        height: 28,
        child: Icon(icon, color: Colors.white, size: 18.0),
      ),
    );
  }
}

class BIconButtons extends StatelessWidget {
  const BIconButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonWrapper(
      child: SizedBox(
          width: 60,
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: Colors.white,
                size: 28,
              ),
              Container(width: 1, color: const Color(0x4D000000)),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
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
              onDoubleTap: () {},
              onDoubleTapDown: (TapDownDetails _details) {
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
                    : const EdgeInsets.symmetric(vertical: 150.0, horizontal: 400.0),
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
