import 'package:ferniinterna/util.dart';
import 'package:ferniinterna/verificador.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferniplast',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: SafeArea(child: MyHomePage(title: 'Ferniplast')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //debugPaintSizeEnabled = true;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: new EdgeInsets.all(12.0),
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                child: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    // Generate 100 widgets that display their index in the List.
                    children: <Widget>[
                      SquareButton(
                          texto: "Catálogo de ofertas",
                          icono: Icons.request_quote,
                          onPressed: () => abrirOfertas()),
                      SquareButton(
                          texto: "Verificador",
                          icono: Icons.price_check,
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Verificador()),
                              )),
                      SquareButton(
                          texto: "Imprimir precios",
                          icono: Icons.receipt,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "Exhibiciones",
                          icono: Icons.space_dashboard,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "FerniOnline",
                          icono: Icons.shopping_cart,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "Inventario",
                          icono: Icons.widgets,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "Mono",
                          icono: Icons.collections_bookmark,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "#ActitudFerni",
                          icono: Icons.group_add,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "Intranet",
                          icono: Icons.stream,
                          onPressed: () => print("Button Clicked!")),
                    ]),
              )
            ],
          ),
        ),
      ),
      //   floatingActionButton: FloatingActionButton(
      //     onPressed: (() => Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const Verificador()),
      //         )),
      //     tooltip: 'Abrir verificador',
      //     child: Icon(Icons.add),
      //   ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  verCatalogo() {}

  abrirOfertas() async {
    bool sucursalResult = await Util.esSucursal();

    if (sucursalResult)
      Util.launchURL("https://www.ferniplast.com/nuestras-ofertas");
    else
      Util.launchURL("https://www.ferniplastmayorista.com/ofertas/");
  }
}

class SquareButton extends StatelessWidget {
  const SquareButton(
      {Key? key,
      required this.texto,
      required this.icono,
      required this.onPressed})
      : super(key: key);

  final String texto;
  final IconData icono;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Icon(
              icono,
              size: MediaQuery.of(context).size.width * .2,
            )),
            Center(
                child: Text(
              texto,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width * .025),
            ))
          ]),
    );
  }
}
