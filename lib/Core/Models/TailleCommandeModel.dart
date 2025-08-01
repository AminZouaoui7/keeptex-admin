class TailleCommandeModel {
  final String taille;
  final int quantite;

  TailleCommandeModel({
    required this.taille,
    required this.quantite,
  });

  factory TailleCommandeModel.fromJson(Map<String, dynamic> json) {
    return TailleCommandeModel(
      taille: json['taille'] ?? '',
      quantite: json['quantite'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taille': taille,
      'quantite': quantite,
    };
  }
}
