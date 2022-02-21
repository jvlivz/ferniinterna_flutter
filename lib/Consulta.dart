class Consulta {
  final String? encabezado;
  final String? pie;
  final String? descripcion;
  final String? descripcionCorta;
  final String? descripcionLarga;
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
  final List<String> imagenes;

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
      this.nombre = "",
      this.imagenes = const [],
      this.descripcionCorta = "",
      this.descripcionLarga = ""});

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      encabezado: json['ENCABEZADO'] ?? "",
      pie: json['PIE'] ?? "",
      descripcion: json['DESCRIPCION'] ?? "",
      descripcionCorta: json['DESCRIPCIONCORTA'] ?? "",
      descripcionLarga: json['DESCRIPCIONLARGA'] ?? "",
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
      exhibicion: (json['EXHIBICION'] != null && json['EXHIBICION'] != "")
          ? int.parse(json['EXHIBICION'])
          : null,
      condVta: json['COND_VTA'] ?? "",
      promoHasta: json['PROMOHASTA'] ?? "",
      categPub: json['CATEG_PUB'] ?? "",
      promoSucursales: json['PROMOSUCURSALES'] ?? "",
      imagen: json['IMAGEN'] ?? "",
      nombre: json['NOMBRE'] ?? "",
      imagenes: (json['IMAGENES'] != null) ? List.from(json["IMAGENES"]) : [],
    );
  }
}