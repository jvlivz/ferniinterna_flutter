class Usuario {
  final String? nombre;
  final String? prioridad;
  final String? usuario;
  final String? pass;
  final String? appexhib;
  final String? error;

  Usuario(
      {this.nombre = "",
      this.prioridad = "",
      this.usuario = "",
      this.pass = "",
      this.error = "",
      this.appexhib = ""});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['NOMBRE'] ?? "",
      prioridad: json['PRIORIDAD'] ?? "",
      usuario: json['USUARIO'] ?? "",
      pass: json['PASS'] ?? "",
      appexhib: json['APPEXHIB'] ?? "",
      error: json['ERROR'] ?? "",
    );
  }
}
