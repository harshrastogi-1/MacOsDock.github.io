import 'package:flutter/material.dart';
import 'package:mac_os_dock/widgets/reorderable_wrap.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mac Os Doc Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final color = Colors.white;
  late List<Widget> _tiles;

  @override
  void initState() {
    super.initState();
    _tiles = <Widget>[
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors
                .primaries[Icons.person.hashCode % Colors.primaries.length],
          ),
          child: Icon(
            Icons.person,
            color: color,
          )),
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors
                .primaries[Icons.message.hashCode % Colors.primaries.length],
          ),
          child: Icon(Icons.message, color: color)),
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                Colors.primaries[Icons.call.hashCode % Colors.primaries.length],
          ),
          child: Icon(Icons.call, color: color)),
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors
                .primaries[Icons.camera.hashCode % Colors.primaries.length],
          ),
          child: Icon(Icons.camera, color: color)),
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors
                .primaries[Icons.photo.hashCode % Colors.primaries.length],
          ),
          child: Icon(Icons.photo, color: color)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    void onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = _tiles.removeAt(oldIndex);
        _tiles.insert(newIndex, row);
      });
    }

    var wrap = ReorderableWrap(
        reorderAnimationDuration: const Duration(milliseconds: 1000),
        spacing: 8.0,
        runSpacing: 4.0,
        needsLongPressDraggable: false,
        padding: const EdgeInsets.all(8),
        onReorder: onReorder,
        onNoReorder: (int index) {
          //this callback is optional
          debugPrint(
              '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        },
        onReorderStarted: (int index) {
          //this callback is optional
          debugPrint(
              '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
        },
        children: _tiles);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            // margin: const EdgeInsets.all(70),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black12,
            ),
            child: wrap,
          ),
        ),
      ],
    );
  }
}
