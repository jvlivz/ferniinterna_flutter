import 'package:ferniinterna/Login.dart';
import 'package:ferniinterna/exhibiciones.dart';
import 'package:ferniinterna/precios.dart';
import 'package:ferniinterna/util.dart';
import 'package:ferniinterna/verificador.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

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
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);

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
        title: Text(widget.title, style: TextStyle(fontFamily: 'Gretoon')),
        backgroundColor: rojoFerni,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Hola Usuario, bienvenido!"),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                radius: 50.0,
                backgroundColor: const Color(0xFF778899),
                backgroundImage:
                    NetworkImage("http://tineye.com/images/widgets/mona.jpg"),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 254, 0, 36),
              ),
            ),
            ListTile(
              title: const Text('Visitar Ferniplast.com'),
              leading: Icon(Icons.shopping_bag),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirFerniplastCom();
              },
            ),
            ListTile(
              title: const Text('Descuento Empleados'),
              leading: Icon(Icons.recent_actors),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Facebook grupo Ferni'),
              leading: Icon(Icons.groups),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirFacebookGrupo();
              },
            ),
            ListTile(
              title: const Text('Instagram'),
              leading: Icon(Icons.photo_camera),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirInstagram();
              },
            ),
            ListTile(
              title: const Text('Facebook '),
              leading: Icon(Icons.facebook),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirFacebook();
              },
            ),
            ListTile(
              title: const Text('Twitter'),
              leading: Icon(Icons.message),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirTwitter();
              },
            ),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: new EdgeInsets.all(8.0),
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
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    // Generate 100 widgets that display their index in the List.
                    children: <Widget>[
                      SquareButton(
                          texto: "Catálogo de ofertas",
                          icono: LineIcons.tag,
                          colorIcono: Colors.deepPurple,
                          onPressed: () => abrirOfertas()),
                      SquareButton(
                          texto: "Verificador",
                          icono: LineIcons.barcode,
                          colorIcono: Colors.green,
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Verificador()),
                              )),
                      SquareButton(
                          texto: "Imprimir precios",
                          icono: LineIcons.receipt,
                          colorIcono: Colors.lightBlue,
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Precios()),
                              )),
                      SquareButton(
                          texto: "Exhibiciones",
                          colorIcono: Colors.deepOrange,
                          icono: LineIcons.shapes,
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              )),
                      SquareButton(
                          texto: "FerniOnline",
                          colorIcono: Colors.indigo,
                          icono: LineIcons.shoppingCart,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "Inventario",
                          colorIcono: Colors.amber,
                          icono: LineIcons.checkSquare,
                          onPressed: () => print("Button Clicked!")),
                      SquareButton(
                          texto: "Mono",
                          colorIcono: Color.fromARGB(255, 47, 201, 9),
                          icono: LineIcons.book,
                          onPressed: () => abrirmono()),
                      SquareButton(
                          texto: "#ActitudFerni",
                          colorIcono: Color.fromARGB(255, 206, 63, 19),
                          icono: LineIcons.peopleCarry,
                          onPressed: () => abrirDDOO()),
                      SquareButton(
                          texto: "Intranet",
                          colorIcono: Color.fromARGB(255, 19, 98, 202),
                          icono: LineIcons.confluence,
                          onPressed: () => abrirIntranet()),
                      SquareButton(
                          texto: "Novedades Mkt",
                          colorIcono: Color.fromARGB(255, 219, 80, 16),
                          icono: LineIcons.newspaper,
                          onPressed: () => abrirMkt()),
                      SquareButton(
                          texto: "Facebook",
                          colorIcono: Color.fromARGB(255, 52, 118, 218),
                          icono: LineIcons.facebook,
                          onPressed: () => abrirFacebook()),
                      SquareButton(
                          texto: "Instagram",
                          colorIcono: Color.fromARGB(255, 218, 52, 163),
                          icono: LineIcons.instagram,
                          onPressed: () => abrirInstagram()),
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

  abrirOfertas() {
    bool sucursalResult = Util.esSucursal();

    if (sucursalResult)
      Util.launchURL("https://www.ferniplast.com/nuestras-ofertas");
    else
      Util.launchURL("https://www.ferniplastmayorista.com/ofertas/");
  }

  abrirmono() {
    bool sucursalResult = Util.esSucursal();

    if (sucursalResult) Util.launchURL("http://192.168.100.245/mono/");
  }

  abrirDDOO() {
    Util.launchURL("https://sites.google.com/view/rrhh-ferniplast/inicio");
  }

  abrirIntranet() {
    Util.launchURL("http://192.168.100.245");
  }

  void abrirFerniplastCom() {
    Util.launchURL("https://www.ferniplast.com");
  }

  void abrirFacebookGrupo() {
    Util.launchURL("https://www.facebook.com/groups/ferniplast");
  }

  void abrirInstagram() {
    Util.launchURL("https://www.instagram.com/Ferniplast/");
  }

  void abrirFacebook() {
    Util.launchURL("https://www.facebook.com/Ferniplast/");
  }

  void abrirTwitter() {
    Util.launchURL("https://twitter.com/Ferniplast");
  }

  void abrirMkt() {
    Util.launchURL("http://192.168.100.245/marketing/");
  }
}

class SquareButton extends StatelessWidget {
  const SquareButton(
      {Key? key,
      required this.texto,
      required this.icono,
      required this.colorIcono,
      required this.onPressed})
      : super(key: key);

  final String texto;
  final IconData icono;
  final VoidCallback onPressed;
  final Color colorIcono;

  @override
  Widget build(BuildContext context) {
    final Color rojoFerni = Color.fromARGB(255, 32, 32, 32);

    return Material(
        borderRadius: BorderRadius.circular(7.0),
        elevation: 2,
        shadowColor: Color.fromARGB(255, 228, 228, 228),
        child: Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(25.0),
              ),
            ),
            child: TextButton(
              onPressed: onPressed,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Icon(
                      icono,
                      size: MediaQuery.of(context).size.width * .15,
                      color: colorIcono,
                    )),
                    Center(
                        child: Text(
                      texto,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .025,
                           
                          color: Colors.grey[700]),
                    ))
                  ]),
            )));
  }
}
