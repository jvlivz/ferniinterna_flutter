import 'dart:convert';
//import 'dart:developer';
//import 'dart:html';
import 'package:ferniinterna/Consulta.dart';
import 'package:ferniinterna/Usuario.dart';
import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DetailScreen.dart';

class Precios extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PreciosState();
  }
}

class _PreciosState extends State<Precios> {
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);
  final txtCodigoController = TextEditingController();
  final txtUsuarioController = TextEditingController();
  final txtCantController = TextEditingController();
  final txtPrecioController = TextEditingController();

  Consulta datos = new Consulta();

  List<String> listaUltimos = [];
  String ultimos = "";
  List data = [];
  List<DropdownMenuItem<String>> impresoras = [];
  String _impresoraSeleccionada = "";
  bool mostrarOfertaEspecial = false;
  double precioEspecial = 0;
  int cantidadEspecial = 0;
  String codigoUsuario = "";
  String nombreUsuario = "";

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

  Future<String> leerImpresoras() async {
    String urlBase = Util.urlBase();
    var res = await http
        .get(Uri.parse(urlBase + "verificadores/consulta.aspx?cim=1"));

    var resBody = json.decode(res.body);

    setState(() {
      data = resBody;
      impresoras = data
          .map((item) =>
              DropdownMenuItem(child: Text(item), value: item.toString()))
          .toList();

      impresoras.insert(
          0,
          DropdownMenuItem(
              child: Text("Sistema de Precios (ERP)"),
              value: "Sistema de Precios (ERP)"));
      _impresoraSeleccionada = "Sistema de Precios (ERP)";
    });
    print(resBody);

    return "Sucess";
  }

  void leerBarra() async {
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
    leerDatos(barcodeScanRes);
  }

  void leerDatos(String codigo) async {
    String urlBase = Util.urlBase();

    final response = await http
        .get(Uri.parse(urlBase + "verificadores/consulta.aspx?cod=" + codigo));
    var parsedJson = json.decode(response.body);
    print(response.body);

    setState(() {
      cantidadEspecial = 0;
      precioEspecial = 0;
      mostrarOfertaEspecial = false;
      datos = Consulta.fromJson(parsedJson);
    });
  }

  void initState() {
    super.initState();
    cargaUsuario();
    leerImpresoras();
//    WidgetsBinding.instance.addPostFrameCallback((_) => leerDatos());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    //debugPaintSizeEnabled = true;

    String idSucursal = "";
    idSucursal = Util.obtenerIDSucursal();

    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.center_focus_weak),
              onPressed: () {
                leerBarra();
              },
            ),
          ],
          title: Text(
            "Precios",
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
                    Row(children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: txtUsuarioController,
                          autocorrect: false,
                          autofocus: true,
                          enableSuggestions: false,
                          maxLength: 4,
                          onChanged: (String str) {
                            setState(() {
                             codigoUsuario="";
                             nombreUsuario="";
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
                        child: DropdownButton(
                          items: impresoras,
                          value: _impresoraSeleccionada,
                          onChanged: (newVal) {
                            setState(() {
                              _impresoraSeleccionada = newVal.toString();
                            });
                          },
                        ),
                      ),
                    ]),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller: txtCodigoController,
                            autocorrect: false,
                            autofocus: true,
                            enableSuggestions: false,
                            maxLength: 13,
                            onSubmitted: (String str) {
                              setState(() {
                                leerDatos(str);
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
                                leerDatos(txtCodigoController.text);
                              });
                            },
                            icon: Icon(Icons.search,
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
                                          if (idSucursal != "")
                                            TextSpan(
                                                text:
                                                    "Sucursal: " + idSucursal),
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
                                    title: Text("Tipo de etiqueta"),
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
                                                  icon: Icon(Icons.money),
                                                  label: Text("Oferta"),
                                                  onPressed: () => setState(() {
                                                    mostrarOfertaEspecial =
                                                        true;
                                                    txtPrecioController.value =
                                                        TextEditingValue(
                                                            text: "");
                                                    txtCantController.value =
                                                        TextEditingValue(
                                                            text: "");
                                                  }),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 4, 0),
                                                child: TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                      primary: Colors.blue,
                                                      backgroundColor:
                                                          Colors.white,
                                                      minimumSize:
                                                          Size.fromHeight(50)),
                                                  icon: Icon(Icons.crop_5_4),
                                                  label: Text("Normal"),
                                                  onPressed: () =>
                                                      imprimir(2, datos),
                                                ),
                                              ),
                                            ])),
                                        Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      4, 8, 0, 8),
                                                  child: TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                        primary: Colors.indigo,
                                                        backgroundColor:
                                                            Colors.white,
                                                        minimumSize:
                                                            Size.fromHeight(
                                                                50)),
                                                    icon: Icon(
                                                        Icons.crop_portrait),
                                                    label: Text("Destacado"),
                                                    onPressed: () =>
                                                        imprimir(1, datos),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      4, 0, 0, 0),
                                                  child: TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                        primary: Colors.black,
                                                        backgroundColor:
                                                            Colors.white,
                                                        minimumSize:
                                                            Size.fromHeight(
                                                                50)),
                                                    icon: Icon(Icons.crop_7_5),
                                                    label: Text("Perfu"),
                                                    onPressed: () =>
                                                        imprimir(3, datos),
                                                  ),
                                                )
                                              ],
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              if (mostrarOfertaEspecial)
                                Card(
                                    color: Colors.white70,
                                    child: ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 10, 25, 0),
                                        title: Text("Etiqueta Especial"),
                                        subtitle: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller: txtCantController,
                                                autocorrect: false,
                                                autofocus: true,
                                                enableSuggestions: false,
                                                maxLength: 3,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText: 'Cantidad',
                                                    counterStyle: TextStyle(
                                                      height:
                                                          double.minPositive,
                                                    ),
                                                    counterText: ""),
                                              ),
                                            ),
                                            Text("x"),
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller: txtPrecioController,
                                                autocorrect: false,
                                                autofocus: true,
                                                enableSuggestions: false,
                                                maxLength: 9,
                                                onSubmitted: (String str) {
                                                  setState(() {
                                                    imprimirEspecial(
                                                        datos,
                                                        txtCantController
                                                            .value.text,
                                                        txtPrecioController
                                                            .value.text);
                                                  });
                                                },
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        signed: false,
                                                        decimal: true),
                                                decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText: 'Precio',
                                                    counterStyle: TextStyle(
                                                      height:
                                                          double.minPositive,
                                                    ),
                                                    counterText: ""),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    imprimirEspecial(
                                                        datos,
                                                        txtCantController
                                                            .value.text,
                                                        txtPrecioController
                                                            .value.text);
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
                                                      TextSpan(text: "Stock: "),
                                                      if (datos.stock != "")
                                                        TextSpan(
                                                          text: datos.stock
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
                                                      TextSpan(
                                                          text: "Exhib.: "),
                                                      if (datos.exhibicion !=
                                                          null)
                                                        TextSpan(
                                                          text: datos.exhibicion
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
                                                      TextSpan(
                                                          text: "Cat. Gen: "),
                                                      if (datos.categPub != "")
                                                        TextSpan(
                                                          text: datos.categPub
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
                                  title: Text("Últimos precios realizados"),
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

  imprimir(int i, Consulta datos) async {
    String textoAlerta = "";

    try {
      if (codigoUsuario != "") {
        String urlBase = Util.urlBase(esPrecios: true);
        final prefs = await SharedPreferences.getInstance();

        String impresora = "";

        if (_impresoraSeleccionada != "Sistema de Precios (ERP)")
          impresora = "&imp=" +
              _impresoraSeleccionada.replaceAll("Impresora Portatil #", "");

        var res = await http.get(Uri.parse(urlBase +
            "verificadores/consulta.aspx?prec=1&sku=" +
            datos.idArtic.toString() +
            "&bar=" +
            datos.idArtic.toString() +
            "&usu=" +
            codigoUsuario +
            "&tetq=3&ope=" +
            codigoUsuario +
            "&UO=" +
            cantidadEspecial.toString() +
            "&PO=" +
            ((precioEspecial == 0) ? "0" : precioEspecial.toString()) +
            impresora));

        var resBody = json.decode(res.body.replaceAll(":NULL", ":null"));

        if (resBody["CODIGO"] != "") {
          listaUltimos.insert(0, datos.descripcion.toString() + "\n");

          if (listaUltimos.length > 10) listaUltimos.removeAt(10);

          setState(() {
            cantidadEspecial = 0;
            precioEspecial = 0;
            mostrarOfertaEspecial = false;
            ultimos = listaUltimos.join("\n");
          });
        }
      } else {
        SnackBar snackBar = SnackBar(
          content: Text(
              "◔_◔...No me dijiste quien sos, completá tu usuario por favor..."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (error) {
      textoAlerta =
          "⊙﹏⊙... se produjo un error al enviar los datos de etiquetas.";
      txtUsuarioController.value = TextEditingValue(text: "");
    }
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

    SnackBar snackBar = SnackBar(
      content: Text(textoAlerta),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  void imprimirEspecial(Consulta datos, String cantidad, String precio) {
    if (Util.isInteger(cantidad) &&
        Util.isDouble(precio) &&
        int.parse(cantidad) > 0 &&
        int.parse(cantidad) < 1000 &&
        double.parse(precio) > 0 &&
        double.parse(precio) < 99999) {
      setState(() {
        precioEspecial = double.parse(
            double.parse(precio.replaceAll(",", ".")).toStringAsFixed(2));
        cantidadEspecial = int.parse(cantidad);
      });

      SnackBar snackBar = SnackBar(
        content: Text(
            "Ahora por favor seleccione el tamaño de etiqueta a imprimir:\n\nDestacado, normal o perfu..."),
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      SnackBar snackBar = SnackBar(
        content: Text("Verifique los datos ingresados!"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
