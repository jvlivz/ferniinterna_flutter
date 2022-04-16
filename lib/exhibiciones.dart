import 'dart:convert';
import 'package:ferniinterna/Consulta.dart';
import 'package:ferniinterna/Usuario.dart';
import 'package:ferniinterna/alertDialog_widget.dart';
import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DetailScreen.dart';

class Exhibiciones extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExhibicionesState();
  }
}

enum TipoExhibicion { Normal, Estacional, Temporal }

class _ExhibicionesState extends State<Exhibiciones> {
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);
  final txtCodigoController = TextEditingController();
  final txtUsuarioController = TextEditingController();
  final txtCantController = TextEditingController();
  final txtPrecioController = TextEditingController();
  late FocusNode codigoFocus;

  Consulta datos = new Consulta();

  List<String> listaUltimos = [];
  String ultimos = "";
  List data = [];
  List<DropdownMenuItem<String>> impresoras = [];
  bool mostrarOfertaEspecial = false;
  bool mostrarExhibicion = false;

  double precioEspecial = 0;
  int cantidadEspecial = 0;
  String codigoUsuario = "";
  String nombreUsuario = "";
  TipoExhibicion tipoExhibicion = TipoExhibicion.Normal;

  void cargaUsuario() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('login_user') != null)
      setState(() {
        codigoUsuario = prefs.getString('login_user').toString();
      });
    txtUsuarioController.value = TextEditingValue(
      text: codigoUsuario,
      selection: TextSelection.fromPosition(
        TextPosition(offset: codigoUsuario.length),
      ),
    );
  }

  void leerBarra(Usuario usuario) async {
    String barcodeScanRes = "";

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', "Cancelar", true, ScanMode.BARCODE);

    txtCodigoController.value = TextEditingValue(
      text: barcodeScanRes,
      selection: TextSelection.fromPosition(
        TextPosition(offset: barcodeScanRes.length),
      ),
    );

    //todo:sacar
    txtCodigoController.text = barcodeScanRes;
    leerDatos(barcodeScanRes, usuario);
  }

  void leerDatos(String codigo, Usuario usuario) async {
    if (codigo.isEmpty || codigo.length < 3) {
      txtCodigoController.text = "";
      return;
    }
    String urlBase = Util.urlBase();

    final response = await http
        .get(Uri.parse(urlBase + "verificadores/consulta.aspx?cod=" + codigo));
    var parsedJson = json.decode(response.body);
    print(response.body);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      cantidadEspecial = 0;
      precioEspecial = 0;
      mostrarExhibicion = false;

      datos = Consulta.fromJson(parsedJson);

      if (datos.exhNMax == 0) {
        if (usuario.appexhib == "1" || usuario.appexhib == "2") {
          if (datos.categPub == "II")
            datos.tipoExhNormal = "Nuevo Ingreso";
          else
            datos.tipoExhNormal = "Restringida";
        }
      }

      if (datos.exhEtMax == 0) if (usuario.appexhib == "1")
        datos.exhETA = "Restringida";
      else
        datos.exhETA = "No Editable";
    });
  }

  void initState() {
    super.initState();
    codigoFocus = FocusNode();
    cargaUsuario();

//    WidgetsBinding.instance.addPostFrameCallback((_) => leerDatos());
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    codigoFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final usuario = ModalRoute.of(context)!.settings.arguments as Usuario;

    //debugPaintSizeEnabled = true;

    String idSucursal = "";
    idSucursal = Util.obtenerIDSucursal();

    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(LineIcons.barcode),
              onPressed: () {
                leerBarra(usuario);
              },
            ),
          ],
          title: Text(
            "Exhibiciones",
            style: new TextStyle(fontFamily: "Gretoon"),
          ),
          backgroundColor: rojoFerni),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller: txtCodigoController,
                            autocorrect: false,
                            autofocus: true,
                            focusNode: codigoFocus,
                            enableSuggestions: false,
                            maxLength: 13,
                            onSubmitted: (String str) {
                              setState(() {
                                leerDatos(str, usuario);
                              });
                            },
                            keyboardType: TextInputType.numberWithOptions(
                                signed: false, decimal: false),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Ingrese código',
                                counterStyle: TextStyle(
                                  height: double.minPositive,
                                ),
                                counterText: ""),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                leerDatos(txtCodigoController.text, usuario);
                              });
                            },
                            icon: Icon(LineIcons.search,
                                size: MediaQuery.of(context).size.width * .1),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              if (datos.error != "")
                                Card(
                                  color: Colors.red,
                                  child: ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 10, 25, 0),
                                      title: Text("Upss..."),
                                      subtitle: Text.rich(TextSpan(
                                          text: datos.error
                                                  .toString()
                                                  .replaceAll("<br>", "\n") +
                                              "\n",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)))),
                                ),
                              if (datos.idArtic != "")
                                Card(
                                  color: Colors.white70,
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15, 10, 25, 0),
                                    title: Text((datos.descripcion != "")
                                        ? datos.descripcion.toString()
                                        : ""),
                                    subtitle: Text.rich(
                                      TextSpan(
                                        children: [
                                          if (datos.precio != "")
                                            TextSpan(
                                              text: "\$ " +
                                                  datos.precio.toString() +
                                                  "\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: (datos.oferta != "")
                                                      ? Colors.red
                                                      : Colors.black),
                                            ),
                                          if (datos.oferta != "")
                                            TextSpan(
                                                text: datos.oferta.toString() +
                                                    " "),
                                          if (datos.promoHasta != "")
                                            TextSpan(
                                              text: "Hasta: " +
                                                  datos.promoHasta.toString() +
                                                  "\n",
                                            ),
                                          if (datos.bin > 0)
                                            TextSpan(
                                              children: [
                                                TextSpan(text: "BIN: "),
                                                if (datos.bin > 0)
                                                  TextSpan(
                                                    text: datos.bin.toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                              ],
                                            ),
                                          if (datos.bm > 0)
                                            TextSpan(
                                              children: [
                                                TextSpan(text: " BM: "),
                                                if (datos.bm > 0)
                                                  TextSpan(
                                                    text: datos.bm.toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                              ],
                                            ),
                                          TextSpan(text: " CG: "),
                                          if (datos.stock != "")
                                            TextSpan(
                                              text: datos.categPub.toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          TextSpan(
                                            children: [
                                              TextSpan(text: "\nExist.: "),
                                              if (datos.stock != null)
                                                TextSpan(
                                                  text: datos.stock.toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                            ],
                                          ),
                                          TextSpan(text: " CD: "),
                                          if (datos.stockCD != "")
                                            TextSpan(
                                              text: datos.stockCD.toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          if (idSucursal != "")
                                            TextSpan(text: "\nSucursal: "),
                                          if (idSucursal != "")
                                            TextSpan(
                                              text: idSucursal,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                        ],
                                      ),
                                    ),
                                    leading: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .1,
                                      child: (datos.imagen != null &&
                                              datos.imagen != "")
                                          ? GestureDetector(
                                              child: Hero(
                                                  tag: "Imagen1",
                                                  child: CachedNetworkImage(
                                                    imageUrl: Util.urlBase() +
                                                        "verificadores/imagenes/" +
                                                        datos.imagen.toString(),
                                                    progressIndicatorBuilder: (context,
                                                            url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  )),
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (_) {
                                                  return DetailScreen(
                                                    titulo:
                                                        datos.nombre.toString(),
                                                    listOfUrls: datos.imagenes,
                                                  );
                                                }));
                                              },
                                            )
                                          : Container(),
                                    ),
                                  ),
                                ),
                              if (datos.idArtic != "")
                                Card(
                                  color: Colors.white70,
                                  child: ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 10, 25, 0),
                                      subtitle: Column(children: [
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: "N: "),
                                                            if (datos.stock !=
                                                                "")
                                                              TextSpan(
                                                                text: datos
                                                                    .exhibicion
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                              Expanded(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: "T: "),
                                                            if (datos.exhibT !=
                                                                0)
                                                              TextSpan(
                                                                text: datos
                                                                    .exhibT
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                              Expanded(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: "E: "),
                                                            if (datos.exhibE !=
                                                                0)
                                                              TextSpan(
                                                                text: datos
                                                                    .exhibE
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            if (datos
                                                                    .estacional !=
                                                                "")
                                                              TextSpan(
                                                                text: " / " +
                                                                    datos
                                                                        .estacional
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                              Expanded(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: "Acc: "),
                                                            if (datos.exhibA !=
                                                                0)
                                                              TextSpan(
                                                                text: datos
                                                                    .exhibA
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ]),
                                        Row(
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: "Exh N Min/Max: "),
                                                  TextSpan(
                                                    text: datos.minimo
                                                            .toString() +
                                                        " / " +
                                                        datos.exhNMax
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(text: "Exh E/T/A: "),
                                                  TextSpan(
                                                    text: datos.minimo
                                                            .toString() +
                                                        " / " +
                                                        datos.exhNMax
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (datos.tipoExhNormal != "")
                                          Row(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: "Exh Normal: "),
                                                    TextSpan(
                                                      text: datos.tipoExhNormal,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (datos.exhEtMax == 0)
                                          Row(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: "Exh E/T/A: "),
                                                    TextSpan(
                                                      text: datos.exhETA,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (datos.exhEtMax > 0)
                                          Row(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "Exh E/T/A Max: "),
                                                    TextSpan(
                                                      text: datos.exhEtMax
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (datos.hVigEst != "")
                                          Row(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "Hasta Temporal: "),
                                                    TextSpan(
                                                      text: datos.hVigEst
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (datos.hVigExh != "")
                                          Row(
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "Hasta Estacional: "),
                                                    TextSpan(
                                                      text: datos.hVigExh
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                      ])),
                                ),
                              if (datos.condVta != "" &&
                                  datos.condVta.toString().toLowerCase() == "n")
                                Card(
                                  color: Colors.yellow,
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15, 10, 25, 0),
                                    title: Text("Atención"),
                                    subtitle:
                                        Text("Artículo en Colas de Stock"),
                                  ),
                                ),
                              if (datos.idArtic != "")
                                Card(
                                  color: Colors.white70,
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15, 10, 25, 0),
                                    subtitle: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Column(children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 8, 4, 8),
                                                child: TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                      primary: Colors.red,
                                                      backgroundColor:
                                                          Colors.white,
                                                      minimumSize:
                                                          Size.fromHeight(50)),
                                                  icon: Icon(Icons.edit_note),
                                                  label: Text("Normal"),
                                                  onPressed: () => setState(() {
                                                    tipoExhibicion =
                                                        TipoExhibicion.Normal;
                                                    mostrarExhibicion = true;
                                                  }),
                                                ),
                                              ),
                                              if (datos.exhETA != "No Editable")
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 4, 0),
                                                  child: TextButton.icon(
                                                      style:
                                                          TextButton.styleFrom(
                                                              primary:
                                                                  Colors.blue,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              minimumSize: Size
                                                                  .fromHeight(
                                                                      50)),
                                                      icon: Icon(LineIcons
                                                          .calendarTimes),
                                                      label: Text("Estacional"),
                                                      onPressed: () =>
                                                          setState(() {
                                                            tipoExhibicion =
                                                                TipoExhibicion
                                                                    .Estacional;
                                                            mostrarExhibicion =
                                                                true;
                                                          })),
                                                ),
                                            ])),
                                        Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                if (datos.exhETA !=
                                                    "No Editable")
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            4, 8, 0, 8),
                                                    child: TextButton.icon(
                                                      style: TextButton
                                                          .styleFrom(
                                                              primary:
                                                                  Colors.indigo,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              minimumSize: Size
                                                                  .fromHeight(
                                                                      50)),
                                                      icon: Icon(
                                                          LineIcons.stopwatch),
                                                      label: Text("Temporal"),
                                                      onPressed: () =>
                                                          setState(() {
                                                        tipoExhibicion =
                                                            TipoExhibicion
                                                                .Temporal;
                                                        mostrarExhibicion =
                                                            true;
                                                      }),
                                                    ),
                                                  ),
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              if (mostrarExhibicion)
                                Card(
                                    color: Colors.white70,
                                    child: ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 10, 25, 0),
                                        title: Text("Exhibición " +
                                            tipoExhibicion
                                                .toString()
                                                .split('.')
                                                .last),
                                        subtitle: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller: txtCantController,
                                                autocorrect: false,
                                                autofocus: true,
                                                enableSuggestions: false,
                                                maxLength: 4,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        signed: false,
                                                        decimal: false),
                                                decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText: 'Cantidad',
                                                    counterStyle: TextStyle(
                                                      height:
                                                          double.minPositive,
                                                    ),
                                                    counterText: ""),
                                                onSubmitted: (value) {
                                                  setState(() {
                                                    if (int.tryParse(
                                                            txtCantController
                                                                .value.text) !=
                                                        null)
                                                      enviarExhibicion(
                                                          tipoExhibicion,
                                                          int.parse(
                                                              txtCantController
                                                                  .value.text),
                                                          datos,
                                                          usuario);
                                                  });
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (int.tryParse(
                                                            txtCantController
                                                                .value.text) !=
                                                        null)
                                                      enviarExhibicion(
                                                          tipoExhibicion,
                                                          int.parse(
                                                              txtCantController
                                                                  .value.text),
                                                          datos,
                                                          usuario);
                                                  });
                                                },
                                                icon: Icon(Icons.done,
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        .1),
                                              ),
                                            ),
                                          ],
                                        ))),
                              if (datos.idArtic != "")
                                Card(
                                  color: Colors.white70,
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15, 10, 25, 0),
                                    title: Text("Existencias"),
                                    subtitle: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "CD: "),
                                                      if (datos.stockCD != "")
                                                        TextSpan(
                                                          text: datos.stockCD
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F3: "),
                                                      if (datos.stockF3 != "")
                                                        TextSpan(
                                                          text: datos.stockF3
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F6: "),
                                                      if (datos.stockF6 != "")
                                                        TextSpan(
                                                          text: datos.stockF6
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F9: "),
                                                      if (datos.stockF9 != "")
                                                        TextSpan(
                                                          text: datos.stockF9
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              ]),
                                        ),
                                        Expanded(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F1: "),
                                                      if (datos.stockF1 != "")
                                                        TextSpan(
                                                          text: datos.stockF1
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F4: "),
                                                      if (datos.stockF4 != "")
                                                        TextSpan(
                                                          text: datos.stockF4
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F7: "),
                                                      if (datos.stockF7 != "")
                                                        TextSpan(
                                                          text: datos.stockF7
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ),
                                        Expanded(
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F2: "),
                                                      if (datos.stockF2 != "")
                                                        TextSpan(
                                                          text: datos.stockF2
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F5: "),
                                                      if (datos.stockF5 != "")
                                                        TextSpan(
                                                          text: datos.stockF5
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(text: "F8: "),
                                                      if (datos.stockF8 != "")
                                                        TextSpan(
                                                          text: datos.stockF8
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Card(
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15, 10, 25, 0),
                                  title:
                                      Text("Últimos exhibiciones realizadas"),
                                  subtitle: Text(
                                    ultimos,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    Text(
                      "Actualizado " + (datos.fecha ?? ""),
                      style: TextStyle(fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  enviarExhibicion(TipoExhibicion tipoExhibicion, int cantidad, Consulta datos,
      Usuario usuario) async {
    if (tipoExhibicion == TipoExhibicion.Normal) {
      if (cantidad == 0 && datos.exhibT <= 0 && datos.exhibE <= 0) {
        _showDialog(context, datos, cantidad, usuario, tipoExhibicion,
            "Esta seguro de solicitar que este producto no se reponga más?");
      } else {
        if ((cantidad >= datos.minimo && cantidad <= datos.exhNMax) ||
            usuario.appexhib.toString() == "1") {
          await _solicitarExhibicion(
              tipoExhibicion, "", "", datos, cantidad, usuario);
        } else {
          SnackBar snackBar = SnackBar(
            content: Text("Mínimo: " +
                datos.minimo.toString() +
                " máximo: " +
                datos.exhNMax.toString()),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } else {
      if (cantidad == 0)
        _showDialog(context, datos, cantidad, usuario, tipoExhibicion,
            "Esta seguro de solicitar que este producto no se reponga durante la vigencia?");
      else if (cantidad >= 0)
        await _solicitarExhibicion(
            tipoExhibicion, "", "", datos, cantidad, usuario);
      else {
        SnackBar snackBar = SnackBar(
          content: Text("Mínimo: 0"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    FocusManager.instance.primaryFocus?.unfocus();
  }

  _solicitarExhibicion(TipoExhibicion tipoExhibicion, String inicio, String fin,
      Consulta datos, int cantidad, Usuario usuario) async {
    String mensaje = "";
    bool permitida = true;

    //Estacional S con exhib. normal > 0 cualquier cat > prioridad 1 deje cargar exhib estacional, normal y temporaria "Mensaje: Correcto"
    if (datos.estacional == "S" &&
        datos.exhibicion > 0 &&
        usuario.appexhib == "1" &&
        (tipoExhibicion == TipoExhibicion.Normal ||
            tipoExhibicion == TipoExhibicion.Estacional ||
            tipoExhibicion == TipoExhibicion.Estacional))
      mensaje += "Correcto" + "\r\n";

    //ESTACIONAL F con exhib. normal/ESTACIONAL/temp cualquier cat > prioridad 1 "Mensaje: Correcto"
    if (datos.estacional == "F" &&
        (datos.exhibicion > 0 || datos.exhibE > 0 || datos.exhibT > 0) &&
        usuario.appexhib == "1" &&
        (tipoExhibicion == TipoExhibicion.Normal ||
            tipoExhibicion == TipoExhibicion.Estacional ||
            tipoExhibicion == TipoExhibicion.Estacional))
      mensaje += "Correcto" + "\r\n";

    if (tipoExhibicion == TipoExhibicion.Normal) {
      //Estacional S con exhib. normal 0 cualquier categoría > prioridad 2 (gerentes y encargados) y prioridad 1 "Mensaje: Correcto, se cargara su proporción"
      if (datos.estacional == "S" &&
          datos.exhibicion == 0 &&
          (usuario.appexhib == "2" || usuario.appexhib == "1"))
        mensaje += "Correcto, se cargará su proporción" + "\r\n";

      //Estacional S con exhib. normal > 0 categoría # AG > prioridad 2 "Mensaje: Acción no permitida”
      if (datos.estacional == "S" &&
          datos.exhibicion > 0 &&
          datos.categPub != "AG" &&
          usuario.appexhib == "2") {
        mensaje = "Acción no permitida";
        permitida = false;
      }

      //categoría AN > prioridad 2 "Mensaje: Acción no permitida”
      if (datos.categPub == "AN" && usuario.appexhib == "2") {
        mensaje = "Acción no permitida, producto en categoría AN";
        permitida = false;
      }

      //Estacional S con exhib. normal > 0 categ AG> prioridad 2 "Mensaje: Correcto, se cargara su proporción"
      if (datos.estacional == "S" &&
          datos.exhibicion > 0 &&
          datos.categPub == "AG" &&
          usuario.appexhib == "2")
        mensaje += "Correcto, se cargara su proporción" + "\r\n";

      //ESTACIONAL F con exhib. normal 0 cualquier categoría > prioridad 2 "Mensaje: Correcto, se cargara su proporción"
      //ESTACIONAL F con exhib. normal > 0 cualquier categoría > prioridad 2 "Mensaje: Correcto, se cargará su proporción"
      if (datos.estacional == "F" &&
          datos.exhibicion >= 0 &&
          datos.categPub != "AG" &&
          usuario.appexhib == "2")
        mensaje += "Correcto, se cargara su proporción" + "\r\n";

      //ESTACIONAL F con exhib. normal 0, cualquier categoría > prioridad 1 "Mensaje: Correcto"
      if (datos.estacional == "F" &&
          datos.exhibicion == 0 &&
          usuario.appexhib == "1") mensaje += "Correcto" + "\r\n";

      //ESTACIONAL F con exhib. normal > 0 categ AG> prioridad 2 “Mensaje: Correcto, se cargara su proporción"
      if (datos.estacional == "F" &&
          datos.exhibicion > 0 &&
          datos.categPub == "AG" &&
          usuario.appexhib == "2")
        mensaje += "Correcto, se cargara su proporción" + "\r\n";
    }
    //<<<<<<<<<<<<<<<<<<<<<<<<<< fin cambios 9/8/21

    if ((tipoExhibicion == TipoExhibicion.Temporal ||
            tipoExhibicion == TipoExhibicion.Estacional) &&
        cantidad > datos.exhEtMax &&
        usuario.appexhib == "2")
      mensaje += "Esta solicitud va a ser evaluada por MKTP" + "\r\n";

    if (mensaje.isEmpty) mensaje = "Correcto";

    SnackBar snackBar = SnackBar(
      content: Text(mensaje),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    String tipo = "", url = "";
    switch (tipoExhibicion) {
      case TipoExhibicion.Estacional:
        tipo = "2";
        break;
      case TipoExhibicion.Normal:
        tipo = "1";
        break;
      case TipoExhibicion.Temporal:
        tipo = "3";
        break;
      default:
        break;
    }
/*			Case "estacional"
				tipo = "2"
			Case "acciones"
				tipo = "4"
			Case "normal"
				tipo = "1"
			Case "temporal"
				tipo = "3"
*/

    if (permitida) {
      url = "http://" +
          Util.obtenerIpSucursal() +
          "/verificadores/consulta.aspx?exh=1&sku=" +
          datos.idArtic.toString() +
          "&bar=" +
          datos.idArtic.toString() +
          "&usu=" +
          usuario.nombre.toString() +
          "&qty=" +
          cantidad.toString() +
          "&ope=" +
          usuario.usuario.toString() +
          "&tex=" +
          tipo +
          "&fie=" +
          inicio +
          "&ffe=" +
          fin;

      var res = await http.get(Uri.parse(url));

      var resBody =
          json.decode(res.body.replaceAll(":NULL", ":null").toLowerCase());

      if (resBody["exhibicionesok"] == "true") {
        listaUltimos.insert(
            0,
            cantidad.toString() +
                " - " +
                tipoExhibicion.toString().split('.').last +
                " - " +
                datos.descripcion.toString() +
                "\n");

        if (listaUltimos.length > 10) listaUltimos.removeAt(10);

        setState(() {
          mostrarExhibicion = false;
          txtCantController.text = "";
          txtCodigoController.text = "";
          datos.limpiar();
          codigoFocus.requestFocus();
          ultimos = listaUltimos.join("\n");
        });
      } else {
        if (resBody["mensaje"] != "") {
          SnackBar snackBar = SnackBar(
            content: Text(resBody["mensaje"]),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
    //ult = lblDescripcion.Text & " " & lblTipoExhibicion.Text & " " & txtCantidad.Text
  }

  _showDialog(BuildContext context, Consulta datos, int cantidad,
      Usuario usuario, TipoExhibicion tipoExhibicion, String texto) async {
    VoidCallback continueCallBack = () => {
          _solicitarExhibicion(tipoExhibicion, "", "", datos, cantidad, usuario)
        };

    VoidCallback cancelCallBack = () => {};
    BlurryDialog alert =
        BlurryDialog("Atención", texto, continueCallBack, cancelCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
        textoAlerta = "◔_◔... No encuentro tu ususario en el sistema.";
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
}

class Utiles {
  static ImageProvider imagen(String? imagen) {
    if (imagen != null) {
      try {
        String urlBase = Util.urlBase();

        return NetworkImage(
          urlBase + "verificadores/imagenes/" + imagen,
        );
      } catch (e) {
        return AssetImage('assets/no_foto.png');
      }
    } else
      return AssetImage('assets/no_foto.png');
  }

  static String precioFormateado(String precio) {
    if (precio == "") return " ";

    const int $sup1 = 0x00B9;
    const int $sup2 = 0x00B2;
    const int $sup3 = 0x00B3;
    const int $sup4 = 0x2074;
    const int $sup5 = 0x2075;
    const int $sup6 = 0x2076;
    const int $sup7 = 0x2077;
    const int $sup8 = 0x2078;
    const int $sup9 = 0x2079;
    const int $sup0 = 0x2070;

    String entero = precio.split(',')[0];
    String decimal = precio
        .split(',')[1]
        .replaceAll('1', String.fromCharCode($sup1))
        .replaceAll('2', String.fromCharCode($sup2))
        .replaceAll('3', String.fromCharCode($sup3))
        .replaceAll('4', String.fromCharCode($sup4))
        .replaceAll('5', String.fromCharCode($sup5))
        .replaceAll('6', String.fromCharCode($sup6))
        .replaceAll('7', String.fromCharCode($sup7))
        .replaceAll('8', String.fromCharCode($sup8))
        .replaceAll('9', String.fromCharCode($sup9))
        .replaceAll('0', String.fromCharCode($sup0));
    return "\$" + entero + decimal;
  }
}
