class UserModel {
  final int idUsuario;
  final String nombre;
  final String correo;

  UserModel({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: int.parse(json['id'].toString()),
      nombre:    json['nombre'],
      correo:    json['correo'],
    );
  }
}
