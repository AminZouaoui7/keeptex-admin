class EmployeeLite {
  final String id;
  final String nom;
  final String? telephone;
  final String? cin;
  final double salaireH;
  final String? etat;

  const EmployeeLite({
    required this.id,
    required this.nom,
    this.telephone,
    this.cin,
    required this.salaireH,
    this.etat,
  });

  factory EmployeeLite.fromJson(Map<String, dynamic> json) {
    return EmployeeLite(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      nom: json['nom']?.toString() ?? json['name']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? json['numeroTelephone']?.toString(),
      cin: json['cin']?.toString(),
      salaireH: (json['salaire_h'] ?? json['salaireH'] ?? 0.0).toDouble(),
      etat: json['etat']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'cin': cin,
      'salaire_h': salaireH,
      'etat': etat,
    };
  }

  @override
  String toString() {
    return 'EmployeeLite(id: $id, nom: $nom, telephone: $telephone, cin: $cin, salaireH: $salaireH, etat: $etat)';
  }
}