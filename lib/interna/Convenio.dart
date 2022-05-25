class Convenio {
  String nrotarjeta="";
  String fechaultimatrx="";
  String nombre="";
  String apellido="";
  String error="";

  Convenio(
      {this.nrotarjeta="",
      this.fechaultimatrx="",
      this.nombre="",
      this.apellido="",
      this.error=""});

  Convenio.fromJson(Map<String, dynamic> json) {
    nrotarjeta = json['nrotarjeta'];
    fechaultimatrx = json['fechaultimatrx'];
    nombre = json['nombre'];
    apellido = json['apellido'];
    error = json['error'];
  }

   
}