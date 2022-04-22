import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:ferniinterna/Usuario.dart';
import 'package:ferniinterna/exhibiciones.dart';
import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late FocusNode passFocus;
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              "Exhibiciones",
              style: new TextStyle(fontFamily: "Gretoon"),
            ),
            backgroundColor: rojoFerni),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Ingrese sus datos de acceso al ERP',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    autofocus: true,
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Usuario',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: TextField(
                    obscureText: true,
                    onSubmitted: (value) {
                      if (nameController.text.isNotEmpty && value.isNotEmpty)
                        setState(() {
                          buscaUsuario(nameController.text, value, context);
                        });
                    },
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Clave',
                    ),
                  ),
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Ingresar'),
                      onPressed: () {
                        setState(() {
                          buscaUsuario(nameController.text,
                              passwordController.text, context);
                        });
                      },
                    )),
              ],
            )));
  }

  void buscaUsuario(String usuario, String pass, BuildContext contexto) async {
    String textoAlerta = "";
    String urlBase = Util.urlBase();
    final prefs = await SharedPreferences.getInstance();
    try {
      //?lin=1&usu=" & TxtUsuario.Text.ToLowerCase().Trim()  &"&pass="& passEncriptada

      String passEncriptada =
          encriptarPass(usuario.toLowerCase().trim() + "sALT3AD1TO" + pass)
              .toUpperCase();
      var res = await http.get(Uri.parse(urlBase +
          "verificadores/consulta.aspx?lin=1&usu=" +
          usuario +
          "&pass=" +
          passEncriptada));

      var resBody =
          json.decode(res.body.replaceAll(":NULL", ":null").toLowerCase());

      if (resBody["usuario"] != null && resBody["usuario"] != "") {
        // Obtain shared preferences.

        await prefs.setString('login_name', resBody["nombre"]);
        await prefs.setString('login_user', resBody["usuario"]);
        //codigoUsuario = resBody["usuario"];
        //nombreUsuario = resBody["nombre"];

        Usuario usuario = new Usuario(
            nombre: resBody["nombre"],
            appexhib: resBody["appexhib"],
            pass: pass,
            prioridad: resBody["prioridad"],
            usuario: resBody["usuario"]);

        textoAlerta = "♥‿♥ Hola " + resBody["nombre"];
        FocusManager.instance.primaryFocus?.unfocus();

        SnackBar snackBar = SnackBar(
          content: Text(textoAlerta),
        );
        ScaffoldMessenger.of(contexto).showSnackBar(snackBar);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Exhibiciones(),
            // Pass the arguments as part of the RouteSettings. The
            // DetailScreen reads the arguments from these settings.
            settings: RouteSettings(
              arguments: usuario,
            ),
          ),
        );
      } else {
        await prefs.remove('login_name');
        await prefs.remove('login_user');
        //codigoUsuario = "";
        //nombreUsuario = "";
        textoAlerta = "◔_◔... No encuentro tu usuario en el sistema.";
        nameController.value = TextEditingValue(text: "");
        passwordController.value = TextEditingValue(text: "");
      }
    } catch (error) {
      await prefs.remove('login_name');
      await prefs.remove('login_user');
      //codigoUsuario = "";
      //nombreUsuario = "";
      textoAlerta =
          "⊙﹏⊙... se produjo un error al obtener los datos de tu usuario.";
      nameController.value = TextEditingValue(text: "");
      passwordController.value = TextEditingValue(text: "");

      SnackBar snackBar = SnackBar(
        content: Text(textoAlerta),
      );
      ScaffoldMessenger.of(contexto).showSnackBar(snackBar);
      log(error.toString());
    }
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  }
}

String encriptarPass(String s) {
  var bytes = utf8.encode(s); // data being hashed

  var digest = sha512.convert(bytes);

  return digest.toString();
}
