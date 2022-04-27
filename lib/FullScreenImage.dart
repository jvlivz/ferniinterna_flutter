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
      text: nombreUsuario,
      selection: TextSelection.fromPosition(
        TextPosition(offset: nombreUsuario.length),
      ),
    );
  }

  String dropdownvalue = 'No corresponde a la presentación.';

  // List of items in our dropdown menu
  var items = [
    'No corresponde a la presentación.',
    'Está pixelada o es de mala calidad.',
    'Está mal cortada.',
    'No corresponde al producto.',
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
                style: new TextStyle(fontSize: 12),
              ),
              backgroundColor: Color.fromARGB(255, 254, 0, 36)),
          body: SafeArea(
              child: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
                child: Column(children: [
              TextField(
                controller: txtUsuarioController,
                autocorrect: false,
                autofocus: false,
                enableSuggestions: false,
                maxLength: 25,
                onChanged: (String str) {
                  setState(() {
                    nombreUsuario = str;
                  });
                },
                decoration: InputDecoration(
                    hintText: 'Tu nombre...',
                    counterStyle: TextStyle(
                      height: double.minPositive,
                    ),
                    counterText: ""),
              ),
              DropdownButton(
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
              ElevatedButton(
                child: const Text('Reportar a Marketing'),
                onPressed: () {
                  enviarReporte(dropdownvalue.toLowerCase(), widget.idArtic);
                },
              ),
              Hero(
                tag: widget.tag,
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  imageUrl: widget.imageUrl,
                ),
              ),
            ])),
          ))),
    );
  }

  void enviarReporte(String dropdownvalue, String idArtic) async {
    try {
      if (nombreUsuario != "") {
        String urlBase = Util.urlBase();

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
