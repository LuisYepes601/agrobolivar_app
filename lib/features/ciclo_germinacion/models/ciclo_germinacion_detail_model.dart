// lib/features/ciclo_germinacion/models/ciclo_germinacion_detail_model.dart

class CicloGerminacionDetailModel {
  final DateTime? deleteAt;
  final bool? isDelete;
  final String? createBy;
  final String? creatorName;
  final String? updateBy;
  final String? updateName;
  final String? deleteBy;
  final String? deleteName;

  CicloGerminacionDetailModel({
    this.deleteAt,
    this.isDelete,
    this.createBy,
    this.creatorName,
    this.updateBy,
    this.updateName,
    this.deleteBy,
    this.deleteName,
  });

  factory CicloGerminacionDetailModel.fromJson(Map<String, dynamic> json) {
    return CicloGerminacionDetailModel(
      deleteAt: json['deleteAt'] != null
          ? DateTime.tryParse(json['deleteAt'].toString())
          : null,
      isDelete: json['isDelete'] as bool?,
      createBy: json['createBy'] as String?,
      creatorName: json['creatorName'] as String?,
      updateBy: json['updateBy'] as String?,
      updateName: json['updateName'] as String?,
      deleteBy: json['deleteBy'] as String?,
      deleteName: json['deleteName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deleteAt': deleteAt?.toIso8601String(),
      'isDelete': isDelete,
      'createBy': createBy,
      'creatorName': creatorName,
      'updateBy': updateBy,
      'updateName': updateName,
      'deleteBy': deleteBy,
      'deleteName': deleteName,
    };
  }
}