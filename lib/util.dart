//import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';
import 'package:permission_handler/permission_handler.dart';

class Util {
  static String? wifiName = "";
  static String? wifiIP = "";
  static bool? esAutorizado;
  static bool? esSucursal;

  static Future<bool> verificarRed() async {
    wifiName = "N/A";
    wifiIP = "0.0.0.0";
    try {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.

        var status = await Permission.location.status;
        if (status.isDenied) {
          await Permission.location.request();
        }

// You can can also directly ask the permission about its status.
        if (await Permission.location.isGranted) {
          // The OS restricts access, for example because of parental controls.
          final info = NetworkInfo();

          wifiName = await info.getWifiName(); // FooNetwork
          wifiIP = await info.getWifiIP();
          String currentIp = obtenerIpSucursal();
          if (currentIp != "0.0.0.0") return true;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  static String obtenerIpSucursal({bool esPrecios = false}) {
    var ip = "0.0.0.0";
    //if (esPrecios) ip = "192.168.3.204";

if (wifiIP.toString() == "192.168.232.2")  ip = "192.168.3.253";

    if (wifiIP != null &&
        wifiName != null &&
        wifiName.toString().toLowerCase() == "reyes") {
      String currentIp = wifiIP.toString().split('.')[2];
      print(currentIp);

      

      if (currentIp == "1" || currentIp == "141") ip = "192.168.1.253";
      if (currentIp == "2" || currentIp == "142") ip = "192.168.2.253";
      if (currentIp == "3" || currentIp == "143") ip = "192.168.3.253";
      if (currentIp == "4" || currentIp == "144") ip = "192.168.4.253";
      if (currentIp == "5") ip = "192.168.5.253";
      if (currentIp == "6" || currentIp == "6") ip = "192.168.6.253";
      if (currentIp == "107" || currentIp == "147") ip = "192.168.107.253";
      if (currentIp == "80" || currentIp == "83") ip = "192.168.80.253";
      if (currentIp == "90" ||
          currentIp == "91" ||
          currentIp == "92" ||
          currentIp == "93" ||
          currentIp == "94" ||
          currentIp == "95" ||
          currentIp == "96") ip = "192.168.90.253";
      if (currentIp == "10" || currentIp == "9" || currentIp == "14")
        ip = "192.168.9.245";
      if (currentIp == "7") ip = "192.168.100.245";
    }

    if (ip != "0.0.0.0") esAutorizado = true;
    if (ip != "192.168.9.245")
      esSucursal = true;
    else
      esSucursal = true;

    print(esAutorizado);
    print(esSucursal);
    print(wifiName);
    print(wifiIP);
    print(ip);
    return ip;
  }

  static String obtenerIDSucursal({bool esPrecios = false}) {
    String ip = obtenerIpSucursal(esPrecios: esPrecios);

    if (ip.startsWith("192.168.1.")) return "F1";
    if (ip.startsWith("192.168.2.")) return "F2";
    if (ip.startsWith("192.168.3.")) return "F3";
    if (ip.startsWith("192.168.4.")) return "F4";
    if (ip.startsWith("192.168.5.")) return "F5";
    if (ip.startsWith("192.168.6.")) return "F6";
    if (ip.startsWith("192.168.107.")) return "F7";
    if (ip.startsWith("192.168.80.")) return "F8";
    if (ip.startsWith("192.168.100.")) return "CD";
    if (ip.startsWith("192.168.9.")) return "MY";
    if (ip.startsWith("192.168.90.")) return "F9";

    return "";
  }

  static String urlBase({bool esPrecios = false}) {
    String sucursalResult = obtenerIpSucursal(esPrecios: esPrecios);

    return "http://" + sucursalResult + "/";
  }

  static launchURL(String url) async {
    print("launching " + url);
    //if (await canLaunch(url)) {
    await launch(url);
    //} else {
    //  throw 'Could not launch $url';
    //}
  }

  static bool isDouble(String s) {
    if (s == null || s.trim() == "") {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static bool isInteger(String s) {
    if (s == null || s.trim() == "") {
      return false;
    }
    return int.tryParse(s) != null;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
