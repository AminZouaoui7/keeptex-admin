class ArticleModel {
  final String id;
  final String nom;
  final String categorie;
  final String couleur;
  final String? taille;
  final int quantite;
  final String unite;

  ArticleModel({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.couleur,
    this.taille,
    required this.quantite,
    required this.unite,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? json['_id'],
      nom: json['nom'],
      categorie: json['categorie'],
      couleur: json['couleur'],
      taille: json['taille'],
      quantite: json['quantite'],
      unite: json['unite'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'categorie': categorie,
    'couleur': couleur,
    'taille': taille,
    'quantite': quantite,
    'unite': unite,
  };
}
