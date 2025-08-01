class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? role;
  final String? resetPasswordToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? numeroTelephone;
  final String? etat;
  final double? salaireH;
  final int? conge;
  final int? absence;
  final String? cin;
  final double? accounte;
  final String? token; // facultatif

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.resetPasswordToken,
    required this.createdAt,
    required this.updatedAt,
    required this.numeroTelephone,
    required this.etat,
    required this.salaireH,
    required this.conge,
    required this.absence,
    required this.cin,
    required this.accounte,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(), // ✅ sécurisé pour int
      email: json['email']?.toString(), // ✅ sécurisé
      password: json['password'],
      role: json['role'],
      resetPasswordToken: json['resetpasswordToken'],
      createdAt: json['createdat'] != null ? DateTime.tryParse(json['createdat']) : null,
      updatedAt: json['updatedat'] != null ? DateTime.tryParse(json['updatedat']) : null,
      numeroTelephone: json['num']?.toString(), // ✅ sécurisé
      etat: json['etat'],
      salaireH: json['salaire_h'] != null ? (json['salaire_h'] as num).toDouble() : null,
      conge: json['conge'],
      absence: json['absence'],
      cin: json['cin']?.toString(),
      accounte: json['accounte'] != null ? (json['accounte'] as num).toDouble() : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'resetpasswordToken': resetPasswordToken,
      'createdat': createdAt?.toIso8601String(),
      'updatedat': updatedAt?.toIso8601String(),
      'num': numeroTelephone,
      'etat': etat,
      'salaire_h': salaireH,
      'conge': conge,
      'absence': absence,
      'cin': cin,
      'accounte': accounte,
      'token': token,
    };
  }

  // ✅ Utile pour copier/modifier l'objet (ex: ajouter token après login)
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? resetPasswordToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? numeroTelephone,
    String? etat,
    double? salaireH,
    int? conge,
    int? absence,
    String? cin,
    double? accounte,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      resetPasswordToken: resetPasswordToken ?? this.resetPasswordToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      numeroTelephone: numeroTelephone ?? this.numeroTelephone,
      etat: etat ?? this.etat,
      salaireH: salaireH ?? this.salaireH,
      conge: conge ?? this.conge,
      absence: absence ?? this.absence,
      cin: cin ?? this.cin,
      accounte: accounte ?? this.accounte,
      token: token ?? this.token,
    );
  }
}
