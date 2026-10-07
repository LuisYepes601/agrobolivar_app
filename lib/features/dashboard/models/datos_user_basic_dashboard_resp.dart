class DatosUserBasicDashboardResp {
  final String userName;
  final String userRole;
  final String? fotoPerfil;

  DatosUserBasicDashboardResp({
    required this.userName,
    required this.userRole,
    this.fotoPerfil,
  });

  factory DatosUserBasicDashboardResp.fromJson(Map<String, dynamic> json) {
    return DatosUserBasicDashboardResp(
      userName: json['userName'] ?? 'Productor AgroBolívar',
      userRole: json['userRole'] ?? 'Productor',
      fotoPerfil: json['fotoPerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userRole': userRole,
      'fotoPerfil': fotoPerfil,
    };
  }

  factory DatosUserBasicDashboardResp.mock() {
    return DatosUserBasicDashboardResp(
      userName: 'Productor AgroBolívar',
      userRole: 'Productor',
      fotoPerfil: null, // O una URL de imagen de prueba
    );
  }
}