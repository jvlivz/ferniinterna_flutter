import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ferniinterna/ConvenioEmpleados.dart';
import 'package:ferniinterna/FerniOnline.dart';
import 'package:ferniinterna/Inventario.dart';
import 'package:ferniinterna/Login.dart';
import 'package:ferniinterna/precios.dart';
import 'package:ferniinterna/util.dart';
import 'package:ferniinterna/verificador.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  StreamController<bool> _streamController = new StreamController.broadcast();
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);
  bool _esAutorizado = false;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    initConnectivity();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status' + e.message.toString());
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    while (!await Util.verificarRed()) print("verificando red");

    setState(() {
      print("ip " + Util.wifiIP.toString());
      print("autorizado " + Util.esAutorizado.toString());

      if (_esAutorizado ||
          (Util.esAutorizado != null && Util.esAutorizado == true))
        _esAutorizado = true;
      else
        _esAutorizado = false;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();

    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            UserAccountsDrawerHeader(
              accountName: Text("Hola!"),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Color.fromARGB(255, 254, 0, 36),
                  backgroundImage: Image.asset("assets/images/fr.png").image
                  //NetworkImage("http://tineye.com/images/widgets/mona.jpg"),
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
            if (_esAutorizado)
              ListTile(
                title: const Text('Descuento Empleados'),
                leading: Icon(Icons.recent_actors),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConvenioEmpleados()),
                  );
                },
              ),
            if (_esAutorizado)
              ListTile(
                title: const Text('Facebook grupo Ferni'),
                leading: Icon(LineIcons.peopleCarry),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  abrirFacebookGrupo();
                },
              ),
            ListTile(
              title: const Text('TikTok'),
              leading: Icon(LineIcons.video),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirTiktok();
              },
            ),
            ListTile(
              title: const Text('Instagram'),
              leading: Icon(LineIcons.instagram),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirInstagram();
              },
            ),
            ListTile(
              title: const Text('Facebook '),
              leading: Icon(LineIcons.facebook),
              onTap: () {
                // Update the state of the app.
                // ...
                abrirFacebook();
              },
            ),
            ListTile(
              title: const Text('Twitter'),
              leading: Icon(LineIcons.twitter),
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
          heightFactor: 1,
          widthFactor: 1,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Wrap(
                        spacing: 0.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between lines
                        children: <Widget>[
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Verificador",
                              icono: LineIcons.barcode,
                              colorIcono: Colors.green,
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Verificador()),
                                  )),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Imprimir precios",
                              icono: LineIcons.receipt,
                              colorIcono: Colors.lightBlue,
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Precios()),
                                  )),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Exhibiciones",
                              colorIcono: Colors.deepOrange,
                              icono: LineIcons.shapes,
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  )),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "FerniOnline",
                              colorIcono: Colors.indigo,
                              icono: LineIcons.shoppingCart,
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FerniOnline()),
                                  )),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Inventario",
                              colorIcono: Colors.amber,
                              icono: LineIcons.checkSquare,
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Inventario()),
                                  )),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Mono",
                              colorIcono: Color.fromARGB(255, 47, 201, 9),
                              icono: LineIcons.book,
                              onPressed: () => abrirmono()),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Catálogo de ofertas",
                              icono: LineIcons.tag,
                              colorIcono: Colors.deepPurple,
                              onPressed: () => abrirOfertas()),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "#ActitudFerni",
                              colorIcono: Color.fromARGB(255, 206, 63, 19),
                              icono: LineIcons.peopleCarry,
                              onPressed: () => abrirDDOO()),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Intranet",
                              colorIcono: Color.fromARGB(255, 19, 98, 202),
                              icono: LineIcons.confluence,
                              onPressed: () => abrirIntranet()),
                          SquareButton(
                              status: _esAutorizado,
                              texto: "Novedades Mkt",
                              colorIcono: Color.fromARGB(255, 219, 80, 16),
                              icono: LineIcons.newspaper,
                              onPressed: () => abrirMkt()),
                          SquareButton(
                              status: true,
                              texto: "Facebook",
                              colorIcono: Color.fromARGB(255, 52, 118, 218),
                              icono: LineIcons.facebook,
                              onPressed: () => abrirFacebook()),
                          SquareButton(
                              status: true,
                              texto: "Instagram",
                              colorIcono: Color.fromARGB(255, 218, 52, 163),
                              icono: LineIcons.instagram,
                              onPressed: () => abrirInstagram()),
                          SquareButton(
                              status: true,
                              texto: "TikTok",
                              colorIcono: Color.fromARGB(255, 52, 218, 80),
                              icono: LineIcons.video,
                              onPressed: () => abrirTiktok()),
                        ]),
                  ])))),

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
    bool sucursalResult = (Util.esSucursal == true);

    if (sucursalResult)
      Util.launchURL("https://www.ferniplast.com/nuestras-ofertas");
    else
      Util.launchURL("https://www.ferniplastmayorista.com/ofertas/");
  }

  abrirmono() {
    bool sucursalResult = (Util.esSucursal == true);

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

  void abrirTiktok() {
    Util.launchURL("https://www.tiktok.com/@ferniplastoficial?lang=es");
  }
}

class SquareButton extends StatelessWidget {
  const SquareButton(
      {Key? key,
      required this.texto,
      required this.icono,
      required this.colorIcono,
      required this.onPressed,
      required this.status})
      : super(key: key);

  final bool status;
  final String texto;
  final IconData icono;
  final VoidCallback onPressed;
  final Color colorIcono;

  @override
  Widget build(BuildContext context) {
    //final Color rojoFerni = Color.fromARGB(255, 32, 32, 32);

    return StreamBuilder<bool>(
      builder: (BuildContext context, snapShot) {
        if (status) {
          return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * .008),
              child: Material(
                  borderRadius: BorderRadius.circular(7.0),
                  elevation: 2,
                  shadowColor: Color.fromARGB(255, 228, 228, 228),
                  child: Container(
                      height: MediaQuery.of(context).size.width * .3,
                      width: MediaQuery.of(context).size.width * .3,
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
                                texto + "\n",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            .035,
                                    color: Colors.grey[700]),
                              ))
                            ]),
                      ))));
        } else
          return SizedBox.shrink();
      },
    );
  }
}
