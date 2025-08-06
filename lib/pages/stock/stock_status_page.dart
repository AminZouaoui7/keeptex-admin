import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../BaseScaffold.dart';
import '../../Core/Models/ArticleModel.dart';
import '../../Services/ArticleService.dart';

// Couleurs personnalisées
class AppColors {
  static const Color vertJade = Color(0xFF76C893);
  static const Color vertSarcelle = Color(0xFF52B69A);
  static const Color bleuCanard = Color(0xFF34A0A4);
  static const Color bleuOcean = Color(0xFF168AAD);
}

class StockStatusPage extends StatefulWidget {
  const StockStatusPage({super.key});

  @override
  State<StockStatusPage> createState() => _StockStatusPageState();
}

class _StockStatusPageState extends State<StockStatusPage> {
  final ArticleService _articleService = ArticleService();
  List<ArticleModel> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final articles = await _articleService.getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur chargement articles : $e");
      setState(() => _isLoading = false);
    }
  }

  void _showEditDialog(ArticleModel article) {
    final _formKey = GlobalKey<FormState>();
    final nomController = TextEditingController(text: article.nom);
    final categorieController = TextEditingController(text: article.categorie);
    final couleurController = TextEditingController(text: article.couleur);
    final tailleController = TextEditingController(text: article.taille);
    final quantiteController = TextEditingController(text: article.quantite.toString());
    final uniteController = TextEditingController(text: article.unite);
    final seuilController = TextEditingController(text: article.seuil.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier l\'article'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: categorieController,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: couleurController,
                  decoration: const InputDecoration(labelText: 'Couleur'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: tailleController,
                  decoration: const InputDecoration(labelText: 'Taille'),
                ),
                TextFormField(
                  controller: quantiteController,
                  decoration: const InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Champ requis';
                    if (int.tryParse(value) == null) return 'Nombre invalide';
                    if (int.parse(value) < 0) return 'La quantité doit être positive';
                    return null;
                  },
                ),
                TextFormField(
                  controller: uniteController,
                  decoration: const InputDecoration(labelText: 'Unité'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: seuilController,
                  decoration: const InputDecoration(labelText: 'Seuil'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Champ requis';
                    if (int.tryParse(value) == null) return 'Nombre invalide';
                    if (int.parse(value) < 0) return 'Le seuil doit être positif';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Valider'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updatedArticle = ArticleModel(
                  id: article.id,
                  nom: nomController.text,
                  categorie: categorieController.text,
                  couleur: couleurController.text,
                  taille: tailleController.text,
                  quantite: int.parse(quantiteController.text),
                  unite: uniteController.text,
                  seuil: int.parse(seuilController.text),
                );

                await _articleService.updateArticle(article.id, updatedArticle);
                Navigator.of(context).pop();
                _fetchArticles();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Article modifié avec succès')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddArticleDialog() {
    final _formKey = GlobalKey<FormState>();
    final nomController = TextEditingController();
    final categorieController = TextEditingController();
    final couleurController = TextEditingController();
    final tailleController = TextEditingController();
    final quantiteController = TextEditingController();
    final uniteController = TextEditingController();
    final seuilController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajouter un nouvel article'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: categorieController,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: couleurController,
                  decoration: const InputDecoration(labelText: 'Couleur'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: tailleController,
                  decoration: const InputDecoration(labelText: 'Taille'),
                ),
                TextFormField(
                  controller: quantiteController,
                  decoration: const InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Champ requis';
                    final number = int.tryParse(value);
                    if (number == null) return 'Nombre entier requis';
                    if (number < 0) return 'Doit être positif';
                    return null;
                  },
                ),
                TextFormField(
                  controller: uniteController,
                  decoration: const InputDecoration(labelText: 'Unité'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: seuilController,
                  decoration: const InputDecoration(labelText: 'Seuil'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Champ requis';
                    final number = int.tryParse(value);
                    if (number == null) return 'Nombre entier requis';
                    if (number < 0) return 'Doit être positif';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Ajouter'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final newArticle = ArticleModel(
                    id: '',
                    nom: nomController.text.trim(),
                    categorie: categorieController.text.trim(),
                    couleur: couleurController.text.trim(),
                    taille: tailleController.text.trim().isEmpty ? null : tailleController.text.trim(),
                    quantite: int.tryParse(quantiteController.text) ?? 0,
                    unite: uniteController.text.trim(),
                    seuil: int.tryParse(seuilController.text) ?? 0,
                  );

                  await _articleService.addArticle(newArticle);
                  Navigator.of(context).pop();
                  _fetchArticles();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Article ajouté avec succès')),
                  );
                } catch (e) {
                  String errorMessage = 'Erreur lors de l\'ajout de l\'article';
                  if (e is DioException && e.response?.statusCode == 400) {
                    errorMessage = 'Données invalides. Veuillez vérifier tous les champs.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        backgroundColor: AppColors.bleuCanard,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Ajouter un nouvel article',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
          ? const Center(child: Text("Aucun article trouvé."))
          : Padding(
        padding: const EdgeInsets.all(16.0),

        child: ListView.separated(
          itemCount: _articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final article = _articles[index];
            final isLow = article.quantite <= article.seuil;

            return Container(
              decoration: BoxDecoration(
                color: isLow
                    ? Colors.red.shade100
                    : AppColors.vertJade.withOpacity(0.2),
                border: Border.all(
                  color: isLow ? Colors.red : AppColors.bleuCanard,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
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
                  Text("Catégorie : ${article.categorie}"),
                  Text("Couleur : ${article.couleur}"),
                  if (article.taille != null)
                    Text("Taille : ${article.taille}"),
                  Text("Quantité : ${article.quantite} ${article.unite}"),
                  Text("Seuil : ${article.seuil}"),
                  if (isLow)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '⚠ Stock inférieur au seuil',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _showEditDialog(article);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bleuCanard,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmation'),
                              content: const Text(
                                  'Voulez-vous vraiment supprimer cet article ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _articleService.deleteArticle(article.id);
                            _fetchArticles();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🗑️ Article supprimé')),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
