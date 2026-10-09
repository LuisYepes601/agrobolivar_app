class AuditDetailsModel {
  final DateTime? deleteAt;
  final bool? isDelete;
  final String? createBy;
  final String? creatorName;
  final String? updateBy;
  final String? updateName;
  final String? deleteBy;
  final String? deleteName;

  AuditDetailsModel({
    this.deleteAt,
    this.isDelete,
    this.createBy,
    this.creatorName,
    this.updateBy,
    this.updateName,
    this.deleteBy,
    this.deleteName,
  });

  factory AuditDetailsModel.fromJson(Map<String, dynamic> json) {
    return AuditDetailsModel(
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

  AuditDetailsModel copyWith({
    DateTime? deleteAt,
    bool? isDelete,
    String? createBy,
    String? creatorName,
    String? updateBy,
    String? updateName,
    String? deleteBy,
    String? deleteName,
  }) {
    return AuditDetailsModel(
      deleteAt: deleteAt ?? this.deleteAt,
      isDelete: isDelete ?? this.isDelete,
      createBy: createBy ?? this.createBy,
      creatorName: creatorName ?? this.creatorName,
      updateBy: updateBy ?? this.updateBy,
      updateName: updateName ?? this.updateName,
      deleteBy: deleteBy ?? this.deleteBy,
      deleteName: deleteName ?? this.deleteName,
    );
  }
}