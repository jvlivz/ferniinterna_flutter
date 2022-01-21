import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';

class Util {
  static Future<String> obtenerIpSucursal() async {
    var ip = "192.168.3.204";

//ToDo:Sacar.
    return ip;
    /* try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
        print('connected');
        final info = NetworkInfo();

        var wifiName = await info.getWifiName(); // FooNetwork
        var wifiIP = await info.getWifiIP(); // 192.168.1.43

        if (wifiIP != null &&
            wifiName != null &&
            wifiName.toLowerCase() == "reyes") {
          if (wifiIP.startsWith("192.168.1.")) ip = "192.168.1.253";
          if (wifiIP.startsWith("192.168.2.")) ip = "192.168.2.253";
          if (wifiIP.startsWith("192.168.3.")) ip = "192.168.3.253";
          if (wifiIP.startsWith("192.168.4.")) ip = "192.168.4.253";
          if (wifiIP.startsWith("192.168.5.")) ip = "192.168.5.253";
          if (wifiIP.startsWith("192.168.6.")) ip = "192.168.6.253";
          if (wifiIP.startsWith("192.168.107.")) ip = "192.168.107.253";
          if ((wifiIP.startsWith("192.168.80.") ||
              wifiIP.startsWith("192.168.83."))) ip = "192.168.80.253";
          if ((wifiIP.startsWith("192.168.90.") ||
              wifiIP.startsWith("192.168.91.") ||
              wifiIP.startsWith("192.168.92.") ||
              wifiIP.startsWith("192.168.93.") ||
              wifiIP.startsWith("192.168.94.") ||
              wifiIP.startsWith("192.168.95.") ||
              wifiIP.startsWith("192.168.96."))) ip = "192.168.90.253";
          if ((wifiIP.startsWith("192.168.100.") ||
              wifiIP.startsWith("192.168.9.") ||
              wifiIP.startsWith("192.168.14."))) ip = "192.168.9.245";
          if (wifiIP.startsWith("192.168.7.")) ip = "192.168.100.245";
        }
      }
    } on SocketException catch (_) {
      print('not connected');
    }

    return ip; */
  }

  static String obtenerIDSucursal()  {
    String ip =  obtenerIpSucursal().toString();

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

  static Future<bool> esSucursal() async {
    String ipSucursalResult = await Util.obtenerIpSucursal();

    if (ipSucursalResult != "192.168.9.245") return true;

    return false;
  }

  static Future<String> urlBase() async {
    String sucursalResult = await obtenerIpSucursal();

    return "http://" + sucursalResult + "/";
  }

  static launchURL(String url) async {
    print("launching " + url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
