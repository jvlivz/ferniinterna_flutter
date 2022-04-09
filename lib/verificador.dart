import 'dart:convert';
import 'package:ferniinterna/Consulta.dart';
import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:line_icons/line_icons.dart';

import 'DetailScreen.dart';

class Verificador extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VerificadorState();
  }
}

class _VerificadorState extends State<Verificador> {
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);
  final txtCodigoController = TextEditingController();

  Consulta datos = new Consulta();

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
    if (codigo.length == 0) return;

    String urlBase = Util.urlBase();

    final response = await http
        .get(Uri.parse(urlBase + "verificadores/consulta.aspx?cod=" + codigo));
    var parsedJson = json.decode(response.body);
    print(response.body);

    setState(() {
      datos = Consulta.fromJson(parsedJson);
    });
  }

  void initState() {
    super.initState();

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
              icon: Icon(LineIcons.barcode),
              onPressed: () {
                leerBarra();
              },
            ),
          ],
          title: Text(
            "Verificador",
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
                                                          0)
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
                              if (datos.descripcionCorta != "" ||
                                  datos.descripcionLarga != "")
                                Card(
                                  color: Colors.white70,
                                  child: ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 10, 25, 0),
                                      title: Text("Descripciones"),
                                      subtitle: Column(
                                        children: [
                                          Text(datos.descripcionCorta
                                              .toString()),
                                          Html(
                                              data: datos.descripcionLarga
                                                  .toString())
                                        ],
                                      )),
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
