import 'dart:convert';
import 'package:ferniinterna/TextWithDivider.dart';
import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class Consulta {
  final String? encabezado;
  final String? pie;
  final String? descripcion;
  final String? desc1;
  final String? error;
  final String? uni2;
  final String? pre2;
  final String? desc2;
  final String? uni1;
  final String? pre1;
  final String? precio;
  final String? idArtic;
  final String? fecha;
  final String? oferta;
  final String? stockF1;
  final String? stockF2;
  final String? stockF3;
  final String? stockF4;
  final String? stockF5;
  final String? stockF6;
  final String? stockF7;
  final String? stockF8;
  final String? stockF9;

  final String? stockCD;
  final String? ventaPromedio;
  final String? stock;
  final int? exhibicion;
  final String? condVta;
  final String? promoHasta;
  final String? categPub;
  final String? promoSucursales;
  final String? imagen;
  final String? nombre;

  Consulta(
      {this.encabezado = "",
      this.pie = "",
      this.descripcion = "",
      this.desc1 = "",
      this.error = "",
      this.uni2 = "",
      this.pre2 = "",
      this.desc2 = "",
      this.uni1 = "",
      this.pre1 = "",
      this.precio = "",
      this.idArtic = "",
      this.fecha = "",
      this.oferta = "",
      this.stockF1 = "",
      this.stockF2 = "",
      this.stockF3 = "",
      this.stockF4 = "",
      this.stockF5 = "",
      this.stockF6 = "",
      this.stockF7 = "",
      this.stockF8 = "",
      this.stockF9 = "",
      this.stockCD = "",
      this.ventaPromedio = "",
      this.stock = "",
      this.exhibicion,
      this.condVta = "",
      this.promoHasta = "",
      this.categPub = "",
      this.promoSucursales = "",
      this.imagen = "",
      this.nombre = ""});

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      encabezado: json['ENCABEZADO'] ?? "",
      pie: json['PIE'] ?? "",
      descripcion: json['DESCRIPCION'] ?? "",
      desc1: json['DESC1'] ?? "",
      error: json['ERROR'] ?? "",
      uni2: json['UNI2'] ?? "",
      pre2: json['PRE2'] ?? "",
      desc2: json['DESC2'] ?? "",
      uni1: json['UNI1'] ?? "",
      pre1: json['PRE1'] ?? "",
      precio: json['PRECIO'] ?? "",
      idArtic: json['ID_ARTIC'] ?? "",
      fecha: json['FECHA'] ?? "",
      oferta: json['OFERTA'] ?? "",
      stockF1: json['STOCKF1'] ?? "",
      stockF2: json['STOCKF2'] ?? "",
      stockF3: json['STOCKF3'] ?? "",
      stockF4: json['STOCKF4'] ?? "",
      stockF5: json['STOCKF5'] ?? "",
      stockF6: json['STOCKF6'] ?? "",
      stockF7: json['STOCKF7'] ?? "",
      stockF8: json['STOCKF8'] ?? "",
      stockF9: json['STOCKF9'] ?? "",
      stockCD: json['STOCKCD'] ?? "",
      ventaPromedio: json['VENTAPROMEDIO'] ?? "",
      stock: json['STOCK'] ?? "",
      exhibicion: json['EXHIBICION'],
      condVta: json['COND_VTA'] ?? "",
      promoHasta: json['PROMOHASTA'] ?? "",
      categPub: json['CATEG_PUB'] ?? "",
      promoSucursales: json['PROMOSUCURSALES'] ?? "",
      imagen: json['IMAGEN'] ?? "",
      nombre: json['NOMBRE'] ?? "",
    );
  }
}

class Verificador extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VerificadorState();
  }
}

class _VerificadorState extends State<Verificador> {
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);

  Consulta datos = new Consulta();

  void leerDatos() async {
    String urlBase = await Util.urlBase();

    String barcodeScanRes = "";

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', "Cancelar", true, ScanMode.DEFAULT);

    //todo:sacar
    barcodeScanRes = "9902010";

    final response = await http.get(Uri.parse(
        urlBase + "verificadores/consulta.aspx?cod=" + barcodeScanRes));
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

    String idSucursal = "";
    idSucursal = Util.obtenerIDSucursal();

    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.center_focus_weak),
              onPressed: () {
                leerDatos();
              },
            ),
          ],
          title: Text(
            "Leer Precios",
            style: new TextStyle(fontFamily: "Gretoon"),
          ),
          backgroundColor: rojoFerni),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 30,
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * .60,
                        height: MediaQuery.of(context).size.width * .12,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Ingrese código',
                          ),
                        )),
                    TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.search,
                            size: MediaQuery.of(context).size.width * .1),
                        label: Text("")),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * .10,
                        height: MediaQuery.of(context).size.width * .10,
                        child: Image(
                          image: Utiles.imagen(datos.imagen),
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )),
                  ],
                ),
                Divider(),
                TextWithDivider(
                  texto: (datos.descripcion != "")
                      ? datos.descripcion.toString()
                      : "",
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  size: 15,
                  color: Colors.black,
                ),
                TextWithDivider(
                  texto: datos.oferta,
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  size: 10,
                  color: Colors.red,
                  visibleDivider: false,
                ),
                TextWithDivider(
                  texto: (datos.promoHasta != "")
                      ? "Hasta: " + datos.promoHasta.toString()
                      : "",
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  size: 10,
                  color: Colors.red,
                  visibleDivider: false,
                ),
                TextWithDivider(
                  texto: (idSucursal != "") ? "Sucursal: " + idSucursal : "",
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  size: 10,
                  color: Colors.black,
                  visibleDivider: true,
                ),
                TextWithDivider(
                  texto: (datos.precio != "")
                      ? "\$ " + datos.precio.toString()
                      : "",
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  size: 15,
                  color: Colors.red,
                ),
                Text(
                  "Los precios aquí mostrados son de contado, a modo orientativo y pueden variar sin previo aviso, consulte en nuestros locales por planes de financiación." +
                      "\n Act.: " +
                      (datos.fecha ?? ""),
                  style: TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ],
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
        String urlBase = "";
        Util.urlBase().then((value) => {urlBase = value.toString()});

        return NetworkImage(
          urlBase + imagen,
        );
      } catch (e) {
        return AssetImage('assets/no_foto.png');
      }
    } else
      return AssetImage('assets/no_foto.png');
  }

  static String precioFormateado(String precio) {
    if (precio == null || precio == "") return " ";

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
