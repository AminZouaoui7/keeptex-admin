class ArticleModel {
  final String id;
  final String nom;
  final String categorie;
  final String couleur;
  final String? taille;
  final int quantite;
  final String unite;
  final int seuil;

  ArticleModel({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.couleur,
    this.taille,
    required this.quantite,
    required this.unite,
    required this.seuil,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: (json['id'] ?? json['_id']).toString(), // 🔒 Sécurisation ici
      nom: json['nom'],
      categorie: json['categorie'],
      couleur: json['couleur'],
      taille: json['taille'],
      quantite: json['quantite'],
      unite: json['unite'],
      seuil: json['seuil'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nom': nom,
      'categorie': categorie,
      'couleur': couleur,
      'quantite': quantite,
      'unite': unite,
      'seuil': seuil,
    };
    
    if (taille != null && taille!.isNotEmpty) {
      data['taille'] = taille;
    }

    return data;
  }
}
