import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _textureId = 0;
  String _status = 'Nothing to see here';
  static const foo = MethodChannel('foo');

  Future<void> loadImage(String imageUrl) async {
    return foo.invokeMethod('registerTexture', <String, dynamic> {
      'url': imageUrl,
    });
  }

  Future<int> getTextureId() async {
    return foo.invokeMethod('getTextureId').then((textureId) {
      return textureId as int;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter == 1) {
        //String imageUrl = 'https://chris.bracken.jp/post/2005-04-09-sakura.jpg';
        String imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Tree_example_VIS.jpg/640px-Tree_example_VIS.jpg';
        loadImage(imageUrl).then((_) {
          print('Loaded $imageUrl');
          setState(() {
            _status = 'loaded $imageUrl';
          });
        });
      } else {
        getTextureId().then((textureId) {
          print('Got textureId in dart: $textureId');
          setState(() {
            _textureId = textureId;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_status),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: SizedBox(
                width: 640,
                height: 480,
                child: Texture(textureId: _textureId),
              ),
            ),
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
