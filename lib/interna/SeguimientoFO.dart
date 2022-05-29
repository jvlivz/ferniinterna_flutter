class SeguimientoFO {
  bool consultaok = false;
  String? mensaje = "";
  String? nroPedido = "";
  String? codigo = "";
  String? nombre = "";
  String? eMail = "";
  String? formaenvio = "";
  String? idSucRet = "";
  String? sucRetiro = "";
  String? fecha = "";
  int nroPrecin = 0;
  String? remitado = "";
  String? fechaRemi = "";
  String? cantItems = "";
  String? leidosuc = "";
  String? notificado = "";
  String? renotifica = "";
  String? entregado = "";
  String? recibidosuc = "";
  String? entregadosuc = "";
  bool llegook = false;
  String? retornocd = "";
  String? recibidocd = "";
  bool entregadook = false;
  String? notificasms = "";
  String? renotificasms = "";

  String? salidaCD = "";
  String? notificaSalidaCD = "";
    String? salidaCDUsuario = "";


  SeguimientoFO(
      {this.consultaok = false,
      this.mensaje = "",
      this.nroPedido = "",
      this.codigo = "",
      this.nombre = "",
      this.eMail = "",
      this.formaenvio = "",
      this.idSucRet = "",
      this.sucRetiro = "",
      this.fecha = "",
      this.nroPrecin = 0,
      this.remitado = "",
      this.fechaRemi = "",
      this.cantItems = "",
      this.leidosuc = "",
      this.notificado = "",
      this.renotifica = "",
      this.entregado = "",
      this.recibidosuc = "",
      this.entregadosuc = "",
      this.llegook = false,
      this.retornocd = "",
      this.recibidocd = "",
      this.entregadook = false,
      this.notificasms = "",
      this.renotificasms = "",
      this.salidaCD="",
      this.notificaSalidaCD="",
      this.salidaCDUsuario=""});

  SeguimientoFO.fromJson(Map<String, dynamic> json) {
    consultaok = json['consultaok'];
    mensaje = json['mensaje'];
    nroPedido = json['nro_pedido'];
    codigo = json['codigo'];
    nombre = json['nombre'];
    eMail = json['e_mail'];
    formaenvio = json['formaenvio'];
    idSucRet = json['id_suc_ret'];
    sucRetiro = json['suc_retiro'];
    fecha = json['fecha'];
    nroPrecin = json['nro_precin'];
    remitado = json['remitado'];
    fechaRemi = json['fecha_remi'];
    cantItems = json['cant_items'];
    leidosuc = json['leidosuc'];
    notificado = json['notificado'];
    renotifica = json['renotifica'];
    entregado = json['entregado'];
    recibidosuc = json['recibidosuc'];
    entregadosuc = json['entregadosuc'];
    llegook = json['llegook'];
    retornocd = json['retornocd'];
    recibidocd = json['recibidocd'];
    entregadook = json['entregadook'];
    notificasms = json['notificasms'];
    renotificasms = json['renotificasms'];
    notificaSalidaCD = json['notificasalidacd'];
    salidaCD = json['salidacd'];
    salidaCDUsuario= json['salidacdusuario'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['consultaok'] = this.consultaok;
    data['mensaje'] = this.mensaje;
    data['nro_pedido'] = this.nroPedido;
    data['codigo'] = this.codigo;
    data['nombre'] = this.nombre;
    data['e_mail'] = this.eMail;
    data['formaenvio'] = this.formaenvio;
    data['id_suc_ret'] = this.idSucRet;
    data['suc_retiro'] = this.sucRetiro;
    data['fecha'] = this.fecha;
    data['nro_precin'] = this.nroPrecin;
    data['remitado'] = this.remitado;
    data['fecha_remi'] = this.fechaRemi;
    data['cant_items'] = this.cantItems;
    data['leidosuc'] = this.leidosuc;
    data['notificado'] = this.notificado;
    data['renotifica'] = this.renotifica;
    data['entregado'] = this.entregado;
    data['recibidosuc'] = this.recibidosuc;
    data['entregadosuc'] = this.entregadosuc;
    data['llegook'] = this.llegook;
    data['retornocd'] = this.retornocd;
    data['recibidocd'] = this.recibidocd;
    data['entregadook'] = this.entregadook;
    data['notificasms'] = this.notificasms;
    data['renotificasms'] = this.renotificasms;
    return data;
  }

  limpiar() {
    this.nroPedido = "";
  }
}
