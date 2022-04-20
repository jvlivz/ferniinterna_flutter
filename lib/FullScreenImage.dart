import 'package:cached_network_image/cached_network_image.dart';
import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  final String tag;
  final String titulo;
  final String idArtic;

  FullScreenImage(
      {required this.imageUrl,
      required this.tag,
      required this.titulo,
      required this.idArtic});

  @override
  State<StatefulWidget> createState() {
    return _FullScreenImageState();
  }
}

class _FullScreenImageState extends State<FullScreenImage> {
/*   initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }

  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } */
  final txtUsuarioController = TextEditingController();

  String codigoUsuario = "";
  String nombreUsuario = "";

  void cargaUsuario() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('login_user') != null)
      setState(() {
        codigoUsuario = prefs.getString('login_user').toString();
        nombreUsuario = prefs.getString('login_name').toString();
      });
    txtUsuarioController.value = TextEditingValue(
      text: codigoUsuario,
      selection: TextSelection.fromPosition(
        TextPosition(offset: codigoUsuario.length),
      ),
    );
  }

  String dropdownvalue = 'Está pixelada o es de mala calidad.';

  // List of items in our dropdown menu
  var items = [
    'Está pixelada o es de mala calidad.',
    'Está mal cortada.',
    'No corresponde al producto.',
    'No corresponde a la presentación.',
    'Tiene otro problema.',
  ];

  void initState() {
    super.initState();
    cargaUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Scaffold(
        appBar: AppBar(
            title: Text(
              widget.titulo,
              style: new TextStyle(fontFamily: "Gretoon", fontSize: 12),
            ),
            backgroundColor: Color.fromARGB(255, 254, 0, 36)),
        body: SafeArea(
          child: GestureDetector(
            child: Center(
              child: ListView(children: [
                Hero(
                  tag: widget.tag,
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                    imageUrl: widget.imageUrl,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: txtUsuarioController,
                        autocorrect: false,
                        autofocus: false,
                        enableSuggestions: false,
                        maxLength: 4,
                        onChanged: (String str) {
                          setState(() {
                            codigoUsuario = "";
                            nombreUsuario = "";
                          });
                        },
                        onSubmitted: (String str) {
                          setState(() {
                            buscaUsuario(str, context);
                          });
                        },
                        decoration: InputDecoration(
                            hintText: 'Usuario',
                            counterStyle: TextStyle(
                              height: double.minPositive,
                            ),
                            counterText: ""),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(nombreUsuario),
                    ),
                  ]),
                ),
                Center(
                  child: DropdownButton(
                    // Initial Value
                    value: dropdownvalue,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                    },
                  ),
                ),
                Container(
                    height: 30,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Reportar a Marketing'),
                      onPressed: () {
                        enviarReporte(dropdownvalue.toLowerCase(), widget.idArtic);
                      },
                    )),
              ]),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void buscaUsuario(String str, BuildContext contexto) async {
    String textoAlerta = "";
    String codigoUsuario = "";
    String nombreUsuario = "";
    String urlBase = Util.urlBase();
    final prefs = await SharedPreferences.getInstance();
    try {
      var res = await http
          .get(Uri.parse(urlBase + "verificadores/consulta.aspx?ope=" + str));

      var resBody = json.decode(res.body.replaceAll(":NULL", ":null"));

      if (resBody["CODIGO"] != "") {
        // Obtain shared preferences.

        await prefs.setString('login_name', resBody["NOMBRE"]);
        await prefs.setString('login_user', resBody["CODIGO"]);
        codigoUsuario = resBody["CODIGO"];
        nombreUsuario = resBody["NOMBRE"];
        textoAlerta = "♥‿♥ Bienvenid@ " + resBody["NOMBRE"];
        txtUsuarioController.value =
            TextEditingValue(text: resBody["CODIGO"].toString().trim());
      } else {
        await prefs.remove('login_name');
        await prefs.remove('login_user');
        codigoUsuario = "";
        nombreUsuario = "";
        textoAlerta = "◔_◔... No encuentro tu usuario en el sistema.";
        txtUsuarioController.value = TextEditingValue(text: "");
      }
    } catch (error) {
      await prefs.remove('login_name');
      await prefs.remove('login_user');
      codigoUsuario = "";
      nombreUsuario = "";
      textoAlerta =
          "⊙﹏⊙... se produjo un error al obtener los datos de tu usuario.";
      txtUsuarioController.value = TextEditingValue(text: "");
    }
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

    setState(() {
      this.codigoUsuario = codigoUsuario;
      this.nombreUsuario = nombreUsuario;
    });
    SnackBar snackBar = SnackBar(
      content: Text(textoAlerta),
    );
    ScaffoldMessenger.of(contexto).showSnackBar(snackBar);
  }

  void enviarReporte(String dropdownvalue, String idArtic) async {
    try {
      if (codigoUsuario != "") {
        String urlBase = Util.urlBase();

        final prefs = await SharedPreferences.getInstance();

        //String nombre = prefs.getString('login_name') ?? "";

        String url = urlBase +
            "verificadores/consulta.aspx?ric=" +
            idArtic +
            "&rim=" +
            dropdownvalue +
            "&riu=" +
            base64.encode(utf8.encode(nombreUsuario)) +
            "&rio=" +
            base64.encode(utf8.encode(dropdownvalue));

        await http.get(Uri.parse(url));

        print(url);
        SnackBar snackBar = SnackBar(
          content: Text("♥‿♥...Gracias! ..."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      } else {
        SnackBar snackBar = SnackBar(
          content: Text(
              "◔_◔...No me dijiste quien sos, completá tu usuario por favor..."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (error) {
      SnackBar snackBar = SnackBar(
        content: Text(
            "⊙﹏⊙... se produjo un error al enviar los datos de etiquetas."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
