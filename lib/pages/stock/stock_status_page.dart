import 'package:flutter/material.dart';
import '../../BaseScaffold.dart';

// Définition des couleurs
class AppColors {
  static const Color vertJade = Color(0xFF76C893);
  static const Color vertSarcelle = Color(0xFF52B69A);
  static const Color bleuCanard = Color(0xFF34A0A4);
  static const Color bleuOcean = Color(0xFF168AAD);
}

// Exemple de modèle de données (à remplacer par ton vrai modèle)
class Article {
  final String nom;
  final String categorie;
  final String couleur;
  final int quantite;
  final String unite;

  Article({
    required this.nom,
    required this.categorie,
    required this.couleur,
    required this.quantite,
    required this.unite,
  });
}

class StockStatusPage extends StatelessWidget {
  const StockStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de liste d'articles (à remplacer par appel API)
    final List<Article> articles = [
      Article(nom: 'Tissu Coton', categorie: 'Tissu', couleur: 'Blanc', quantite: 12, unite: 'mètre'),
      Article(nom: 'Fermeture Éclair', categorie: 'Accessoire', couleur: 'Noir', quantite: 3, unite: 'pièce'),
      Article(nom: 'Fil Nylon', categorie: 'Fil', couleur: 'Rouge', quantite: 20, unite: 'bobine'),
    ];

    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Vue d\'ensemble des articles en stock',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.bleuOcean,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: articles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final isLowStock = article.quantite < 5;

                  return Container(
                    decoration: BoxDecoration(
                      color: isLowStock ? Colors.red.shade100 : AppColors.vertJade.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.bleuCanard, width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.nom,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bleuCanard,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Catégorie : ${article.categorie}'),
                        Text('Couleur : ${article.couleur}'),
                        Text('Quantité : ${article.quantite} ${article.unite}'),
                        if (isLowStock)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              '⚠ Stock faible',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
