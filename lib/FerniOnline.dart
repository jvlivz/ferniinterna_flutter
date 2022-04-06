import 'dart:convert';
import 'package:intl/intl.dart';
//import 'dart:developer';
import 'package:ferniinterna/Consulta.dart';
import 'package:ferniinterna/SeguimientoFO.dart';
import 'package:ferniinterna/Usuario.dart';
//import 'package:ferniinterna/Usuario.dart';
import 'package:ferniinterna/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DetailScreen.dart';

class FerniOnline extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FerniOnlineState();
  }
}

class _FerniOnlineState extends State<FerniOnline> {
  final Color rojoFerni = Color.fromARGB(255, 254, 0, 36);
  final txtOrdenController = TextEditingController();
  final txtUsuarioController = TextEditingController();
  final txtPackingListController = TextEditingController();
  late FocusNode codigoFocus;
  late FocusNode packingFocus;

  SeguimientoFO datos = new SeguimientoFO();

  List data = [];
  String codigoUsuario = "";
  String nombreUsuario = "";
  String CompraAdicional = "0";

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

  void leerBarraPackingList() async {
    String barcodeScanRes = "";

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', "Cancelar", true, ScanMode.DEFAULT);

    barcodeScanRes = "05572106618224|23098";

    if (barcodeScanRes.contains('|')) {
      setState(() {
        txtPackingListController.text = barcodeScanRes.split('|')[0];
        txtOrdenController.text = barcodeScanRes.split('|')[1];
      });
    }
    verificarPackingList(context);
/*
    txtPackingListController.value = TextEditingValue(
      text: barcodeScanRes,
      selection: TextSelection.fromPosition(
        TextPosition(offset: barcodeScanRes.length),
      ),
    );
    */
  }

  void initState() {
    super.initState();
    codigoFocus = FocusNode();
    packingFocus = FocusNode();
    cargaUsuario();

//    WidgetsBinding.instance.addPostFrameCallback((_) => leerDatos());
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    codigoFocus.dispose();
    packingFocus.dispose();
    super.dispose();
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
                leerBarraPackingList();
              },
            ),
          ],
          title: Text(
            "FerniOnline",
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
                          enableSuggestions: false,
                          textInputAction: TextInputAction.next,
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
                        child: TextField(
                          controller: txtPackingListController,
                          autocorrect: false,
                          autofocus: true,
                          enableSuggestions: false,
                          focusNode: packingFocus,
                          maxLines: 1,
                          maxLength: 14,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: InputDecoration(
                              hintText: 'Packing List',
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: ""),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: txtOrdenController,
                          autocorrect: false,
                          focusNode: codigoFocus,
                          enableSuggestions: false,
                          maxLength: 13,
                          onSubmitted: (String str) {
                            setState(() {
                              verificarPackingList(context);
                            });
                          },
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          decoration: InputDecoration(
                              hintText: 'N° Orden',
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
                              verificarPackingList(context);
                            });
                          },
                          icon: Icon(LineIcons.search,
                              size: MediaQuery.of(context).size.width * .1),
                        ),
                      ),
                    ]),
                    Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Container(
                            width: double.infinity,
                            child: Column(children: [
                              if (datos.codigo == null &&
                                  datos.consultaok &&
                                  txtOrdenController.text.length > 0 &&
                                  txtPackingListController.text.length > 0)
                                Card(
                                  color: Colors.orange,
                                  child: ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 10, 25, 0),
                                      title: Text("Mmm..."),
                                      subtitle: Text.rich(TextSpan(
                                          text:
                                              "No encuentro nada con esos datos, por favor revisá los números e intenta nuevamente...",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87)))),
                                ),
                              if (!datos.consultaok &&
                                  txtOrdenController.text.length > 0 &&
                                  txtPackingListController.text.length > 0)
                                Card(
                                  color: Colors.red,
                                  child: ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 10, 25, 0),
                                      title: Text("Upss..."),
                                      subtitle: Text.rich(TextSpan(
                                          text:
                                              "Por favor intente nuevamente...",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)))),
                                ),
                              if (datos.nroPedido != null &&
                                  datos.nroPedido != "" &&
                                  ("F" + datos.idSucRet.toString()) !=
                                      Util.obtenerIDSucursal())
                                Card(
                                    color: Colors.yellow,
                                    child: ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(15, 10, 25, 0),
                                        title: Text("Atención"),
                                        subtitle: Text.rich(TextSpan(
                                            text:
                                                "Pedido para retirar en Ferni " +
                                                    datos.idSucRet.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87))))),
                              if (datos.nroPedido != null &&
                                  datos.nroPedido != "")
                                Card(
                                  color: Colors.white70,
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(15, 10, 25, 0),
                                    title: Text("Orden " +
                                        datos.nroPedido.toString() +
                                        " - " +
                                        datos.nroPrecin.toString()),
                                    subtitle: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                              text: datos.nombre
                                                      .toString()
                                                      .toTitleCase() +
                                                  "\n",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          TextSpan(
                                              text: datos.formaenvio
                                                      .toString()
                                                      .toCapitalized() +
                                                  ": "),
                                          TextSpan(
                                              text: datos.idSucRet.toString() +
                                                  "\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          TextSpan(text: "Pedido : "),
                                          TextSpan(
                                              text: DateFormat('dd-MM-yy HH:mm')
                                                      .format(DateFormat(
                                                              "yyyy-MM-dd't'HH:mm:ss")
                                                          .parse(datos.fecha
                                                              .toString())) +
                                                  "\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          TextSpan(text: "Remitado: "),
                                          TextSpan(
                                              text: DateFormat('dd-MM-yy HH:mm')
                                                      .format(DateFormat(
                                                              "yyyy-MM-dd't'HH:mm:ss")
                                                          .parse(datos.fechaRemi
                                                              .toString())) +
                                                  "\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          if (datos.leidosuc != null &&
                                              datos.leidosuc != "")
                                            TextSpan(
                                                text: "Llegó a sucursal : "),
                                          if (datos.leidosuc != null &&
                                              datos.leidosuc != "")
                                            TextSpan(
                                                text: DateFormat(
                                                            'dd-MM-yy HH:mm')
                                                        .format(DateFormat(
                                                                "yyyy-MM-dd HH:mm")
                                                            .parse(datos
                                                                .leidosuc
                                                                .toString())) +
                                                    "\n",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                          if (datos.leidosuc != null &&
                                              datos.leidosuc != "")
                                            TextSpan(text: "Recibido por : "),
                                          if (datos.leidosuc != null &&
                                              datos.leidosuc != "")
                                            TextSpan(
                                                text: datos.recibidosuc
                                                        .toString()
                                                        .toTitleCase() +
                                                    "\n",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                          if (datos.entregado != null &&
                                              datos.entregado != "")
                                            TextSpan(text: "Entregado : "),
                                          if (datos.entregado != null &&
                                              datos.entregado != "")
                                            TextSpan(
                                                text: DateFormat(
                                                            'dd-MM-yy HH:mm')
                                                        .format(DateFormat(
                                                                "yyyy-MM-dd HH:mm")
                                                            .parse(datos
                                                                .entregado
                                                                .toString())) +
                                                    "\n",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                          if (datos.entregado != null &&
                                              datos.entregado != "")
                                            TextSpan(text: "Entregado por : "),
                                          if (datos.entregado != null &&
                                              datos.entregado != "")
                                            TextSpan(
                                                text: datos.entregadosuc
                                                        .toString()
                                                        .toCapitalized() +
                                                    "\n",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                          TextSpan(text: "Ítems: "),
                                          TextSpan(
                                              text: datos.cantItems.toString() +
                                                  "\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (datos.nroPedido != null &&
                                  datos.nroPedido != "" &&
                                  datos.remitado != null &&
                                  datos.remitado.toString() == "s")
                                Card(
                                    color: Colors.white70,
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 10, 25, 0),
                                      title: Text("Acciones"),
                                      subtitle: Column(
                                        children: [
                                          if (datos.leidosuc == null ||
                                              datos.leidosuc == "")
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 8, 4, 8),
                                              child: TextButton.icon(
                                                style: TextButton.styleFrom(
                                                    primary: Colors.blueAccent,
                                                    backgroundColor:
                                                        Colors.white,
                                                    minimumSize:
                                                        Size.fromHeight(50)),
                                                icon: Icon(LineIcons.dolly),
                                                label: Text("Llegó a depósito"),
                                                onPressed: () => setState(() {
                                                  llegoDeposito(datos);
                                                }),
                                              ),
                                            ),
                                          if (datos.leidosuc != null &&
                                              datos.leidosuc != "" &&
                                              (datos.entregado == null ||
                                                  datos.entregado == ""))
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 8, 4, 8),
                                              child: TextButton.icon(
                                                style: TextButton.styleFrom(
                                                    primary: Colors.deepPurple,
                                                    backgroundColor:
                                                        Colors.white,
                                                    minimumSize:
                                                        Size.fromHeight(50)),
                                                icon: Icon(LineIcons
                                                    .clipboardWithCheck),
                                                label:
                                                    Text("Entregado a Cliente"),
                                                onPressed: () => setState(() {
                                                  entregarPedido(datos);
                                                }),
                                              ),
                                            ),
                                          if (Util.obtenerIDSucursal() == "CD")
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
                                                icon: Icon(LineIcons.undo),
                                                label: Text("Retorno a CD"),
                                                onPressed: () =>
                                                    setState(() {
                                                      retornoCD(datos);
                                                    }),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ))
                            ]))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void verificarPackingList(BuildContext context) async {
    String packingList = txtPackingListController.text;
    String orden = txtOrdenController.text;

    if (packingList.length == 0 || orden.length == 0) {
      SnackBar snackBar = SnackBar(
        content: Text("◔_◔...datos no válidos..."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    String url =
        "http://192.168.100.245/verificadores/consulta.aspx?vpfv=1&usu=" +
            codigoUsuario +
            "&packing=" +
            packingList +
            "&nropedido=" +
            orden +
            "&ope=" +
            codigoUsuario;

    final response = await http.get(Uri.parse(url));

    var parsedJson = json.decode(response.body.toLowerCase());
    print(response.body);

    setState(() {
      datos = SeguimientoFO.fromJson(parsedJson);
    });
  }


retornoCD(SeguimientoFO datos) async {
    String textoAlerta = "";

    try {
      if (codigoUsuario != "") {
        final prefs = await SharedPreferences.getInstance();

        FocusManager.instance.primaryFocus?.unfocus();
        if (prefs.getString("login_user") != codigoUsuario) {
          SnackBar snackBar = SnackBar(
            content: Text("◔_◔...verificá tu usuario..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        String url = "http://192.168.100.245/" +
            "verificadores/consulta.aspx?rcfv=1&usu=" +
            codigoUsuario.trim() +
            " " +
            prefs.getString("login_name").toString() +
            "&packing=" +
            datos.nroPrecin.toString() +
            "&nropedido=" +
            datos.nroPedido.toString() +
            "&ope=" +
            codigoUsuario;

        var res = await http.get(Uri.parse(url));

        var resBody =
            json.decode(res.body.replaceAll(":NULL", ":null").toLowerCase());

        if (resBody["consultaok"] == true) {
          setState(() {
            txtPackingListController.text = "";
            txtOrdenController.text = "";
            datos.limpiar();
            FocusManager.instance.primaryFocus?.unfocus();
            packingFocus.requestFocus();
          });
          SnackBar snackBar = SnackBar(
            content: Text("Registro existoso ..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          SnackBar snackBar = SnackBar(
            content: Text("◔_◔...Hubo un problema: " +
                resBody["mensaje"].toString() +
                " ..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          "⊙﹏⊙... se produjo un error al enviar los datos de FerniOnline.";
      txtUsuarioController.value = TextEditingValue(text: "");
    }
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

    SnackBar snackBar = SnackBar(
      content: Text(textoAlerta),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  llegoDeposito(SeguimientoFO datos) async {
    String textoAlerta = "";

    try {
      if (codigoUsuario != "") {
        final prefs = await SharedPreferences.getInstance();

        FocusManager.instance.primaryFocus?.unfocus();
        if (prefs.getString("login_user") != codigoUsuario) {
          SnackBar snackBar = SnackBar(
            content: Text("◔_◔...verificá tu usuario..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        String url = "http://192.168.100.245/" +
            "verificadores/consulta.aspx?ldfv=1&usu=" +
            codigoUsuario.trim() +
            " " +
            prefs.getString("login_name").toString() +
            "&packing=" +
            datos.nroPrecin.toString() +
            "&nropedido=" +
            datos.nroPedido.toString() +
            "&ope=" +
            codigoUsuario;

        var res = await http.get(Uri.parse(url));

        var resBody =
            json.decode(res.body.replaceAll(":NULL", ":null").toLowerCase());

        if (resBody["consultaok"] == true) {
          setState(() {
            txtPackingListController.text = "";
            txtOrdenController.text = "";
            datos.limpiar();
            FocusManager.instance.primaryFocus?.unfocus();
            packingFocus.requestFocus();
          });
          SnackBar snackBar = SnackBar(
            content: Text("Registro existoso ..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          SnackBar snackBar = SnackBar(
            content: Text("◔_◔...Hubo un problema: " +
                resBody["mensaje"].toString() +
                " ..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          "⊙﹏⊙... se produjo un error al enviar los datos de FerniOnline.";
      txtUsuarioController.value = TextEditingValue(text: "");
    }
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

    SnackBar snackBar = SnackBar(
      content: Text(textoAlerta),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  entregarPedido(SeguimientoFO datos) async {
    String textoAlerta = "";

    try {
      if (codigoUsuario != "") {
        final prefs = await SharedPreferences.getInstance();

        FocusManager.instance.primaryFocus?.unfocus();
        if (prefs.getString("login_user") != codigoUsuario) {
          SnackBar snackBar = SnackBar(
            content: Text("◔_◔...verificá tu usuario..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        await showAlertDialog(context);

        String url = "http://192.168.100.245/" +
            "verificadores/consulta.aspx?ecfv=1&usu=" +
            codigoUsuario.trim() +
            " " +
            prefs.getString("login_name").toString() +
            "&packing=" +
            datos.nroPrecin.toString() +
            "&nropedido=" +
            datos.nroPedido.toString() +
            "&ope=" +
            codigoUsuario +
            "&cet=" +
            CompraAdicional;

        var res = await http.get(Uri.parse(url));

        var resBody =
            json.decode(res.body.replaceAll(":NULL", ":null").toLowerCase());

        if (resBody["consultaok"] == true) {
          setState(() {
            txtPackingListController.text = "";
            txtOrdenController.text = "";
            datos.limpiar();
            FocusManager.instance.primaryFocus?.unfocus();
            packingFocus.requestFocus();
          });
          SnackBar snackBar = SnackBar(
            content: Text("Registro existoso ..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          SnackBar snackBar = SnackBar(
            content: Text("◔_◔...Hubo un problema: " +
                resBody["mensaje"].toString() +
                " ..."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          "⊙﹏⊙... se produjo un error al enviar los datos de FerniOnline.";
      txtUsuarioController.value = TextEditingValue(text: "");
    }
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

    SnackBar snackBar = SnackBar(
      content: Text(textoAlerta),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showAlertDialog(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        setState(() {
          CompraAdicional = "0";
        });
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Si"),
      onPressed: () {
        setState(() {
          CompraAdicional = "1";
        });
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Compra adicional"),
      content: Text(
          "El cliente tiene intenciones de ver o comprar algo más dentro de la sucursal?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    await showDialog(
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
        textoAlerta = "♥‿♥ Hola " + resBody["NOMBRE"];
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
