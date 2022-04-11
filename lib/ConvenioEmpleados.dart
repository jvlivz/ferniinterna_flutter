import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';

import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_widget/barcode_widget.dart';

class ConvenioEmpleados extends StatelessWidget {
  const ConvenioEmpleados({Key? key}) : super(key: key);

  static const String _title = 'Convenio Empleados ';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            _title,
            style: new TextStyle(fontFamily: "Gretoon"),
          ),
          backgroundColor: Color.fromARGB(255, 254, 0, 36),
        ),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController dniController = TextEditingController();
  String ean13 = "";
  String nombreApellido = "";
  String ultimaTrx = "";

  void initState() {
    super.initState();
    cargaUsuario();
//    WidgetsBinding.instance.addPostFrameCallback((_) => leerDatos());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Ingresa tu DNI',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                autofocus: true,
                controller: dniController,
                textInputAction: TextInputAction.next,
                onSubmitted: (value) {
                  if (dniController.text.isNotEmpty && value.isNotEmpty)
                    setState(() {
                      buscaUsuario(dniController.text, context);
                    });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'DNI',
                ),
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: const Text('Obtener Credencial'),
                  onPressed: () {
                    setState(() {
                      buscaUsuario(dniController.text, context);
                    });
                  },
                )),
            if (ean13 != "")
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: BarcodeWidget(
                    barcode: Barcode.ean13(),
                    data: ean13,
                  )),
            if (ean13 != "")
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    nombreApellido,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  )),
            if (ean13 != "")
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Última compra: " + ultimaTrx,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  )),
          ],
        ));
  }

  void cargaUsuario() async {
    // Obtain shared preferences.
    String dni = "";
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('convenio.dni') != null) {
      dni = prefs.getString('convenio.dni').toString();

      dniController.value = TextEditingValue(
        text: dni,
        selection: TextSelection.fromPosition(
          TextPosition(offset: dni.length),
        ),
      );
    }
    buscaUsuario(dni, context);
  }

  void buscaUsuario(String dni, BuildContext contexto) async {
    String textoAlerta = "";
    String urlBase = Util.urlBase();
    final prefs = await SharedPreferences.getInstance();
    try {
      //?lin=1&usu=" & TxtUsuario.Text.ToLowerCase().Trim()  &"&pass="& passEncriptada

      var res = await http.get(
          Uri.parse(urlBase + "verificadores/consulta.aspx?convenio=" + dni));

      var resBody =
          json.decode(res.body.replaceAll(":NULL", ":null").toLowerCase());

      if (resBody["nrotarjeta"] != "") {
        // Obtain shared preferences.

        await prefs.setString('convenio.dni', dni);
        await prefs.setString('convenio.nrotarjeta', resBody["nrotarjeta"]);
        await prefs.setString(
            'convenio.nombre', resBody["nombre"].toString().toCapitalized());
        await prefs.setString('convenio.apellido',
            resBody["apellido"].toString().toCapitalized());
        await prefs.setString('convenio.ultimaTrx', resBody["fechaultimatrx"]);
        //codigoUsuario = resBody["USUARIO"];
        //nombreUsuario = resBody["NOMBRE"];

        textoAlerta = "♥‿♥ Hola " + resBody["nombre"];
        FocusManager.instance.primaryFocus?.unfocus();

        // Create a DataMatrix barcode

        setState(() {
          ean13 = resBody["nrotarjeta"];
          nombreApellido = resBody["nombre"].toString().toCapitalized() +
              " " +
              resBody["apellido"].toString().toCapitalized();
          ultimaTrx = resBody["fechaultimatrx"].toString();
        });
      } else {
        textoAlerta = "◔_◔... No encuentro tu usuario en el sistema.";
      }
    } catch (error) {
      await prefs.remove('login_name');
      await prefs.remove('login_user');
      //codigoUsuario = "";
      //nombreUsuario = "";
      textoAlerta =
          "⊙﹏⊙... se produjo un error al obtener los datos de tu usuario.";

      log(error.toString());
    }
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

    setState(() {
      // this.codigoUsuario = codigoUsuario;
      // this.nombreUsuario = nombreUsuario;
    });
    SnackBar snackBar = SnackBar(
      content: Text(textoAlerta),
    );
    ScaffoldMessenger.of(contexto).showSnackBar(snackBar);
  }
}

String encriptarPass(String s) {
  var bytes = utf8.encode(s); // data being hashed

  var digest = sha512.convert(bytes);

  return digest.toString();
}
