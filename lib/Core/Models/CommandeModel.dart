class CommandeModel {
  final String? id;
  final String type;
  final DateTime date;
  late final String etat;
  final String description;
  final String typeModele;
  final String typeTissue;
  final String logo;
  final String logoPath;
  final String couleur;
  final int quantiteTotale;
  final double prixTotal;
  final double acompteRequis;
  final String estimation;
  final String photo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String clientName;
  bool acomptePaye; // ✅ champ corrigé

  CommandeModel({
    this.id,
    required this.type,
    required this.date,
    required this.etat,
    required this.description,
    required this.typeModele,
    required this.typeTissue,
    required this.logo,
    required this.logoPath,
    required this.couleur,
    required this.quantiteTotale,
    required this.prixTotal,
    required this.acompteRequis,
    required this.estimation,
    required this.photo,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.clientName,
    required this.acomptePaye, // ✅ ici aussi
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id']?.toString(),
      type: json['type'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      etat: json['etat'] ?? '',
      description: json['description'] ?? '',
      typeModele: json['type_modele'] ?? '',
      typeTissue: json['type_tissue'] ?? '',
      logo: json['logo'] ?? '',
      logoPath: json['logo_path'] ?? '',
      couleur: json['couleur'] ?? '',
      quantiteTotale: json['quantite_totale'] ?? 0,
      prixTotal: _parseToDouble(json['prix_total']),
      acompteRequis: _parseToDouble(json['acompte_requis']),
      estimation: json['estimation']?.toString() ?? '',
      photo: json['photo'] ?? '',
      userId: json['userId']?.toString() ?? '',
      clientName: json['user']?['name'] ?? 'Client inconnu',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      acomptePaye: json['acomptepaye'] ?? false, // ✅ MAJ avec clé backend exacte
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date.toIso8601String(),
      'etat': etat,
      'description': description,
      'type_modele': typeModele,
      'type_tissue': typeTissue,
      'logo': logo,
      'logo_path': logoPath,
      'couleur': couleur,
      'quantite_totale': quantiteTotale,
      'prix_total': prixTotal,
      'acompte_requis': acompteRequis,
      'estimation': estimation,
      'photo': photo,
      'createdat': createdAt.toIso8601String(),
      'updatedat': updatedAt.toIso8601String(),
      'userid': userId,
      'client_name': clientName,
      'acomptepaye': acomptePaye, // ✅ correspond au nom backend
    };
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
