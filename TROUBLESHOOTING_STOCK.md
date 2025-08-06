# Guide de dépannage - Mouvements de stock

## Problème : "Aucune entrée trouvée" après ajout de quantité

### Vérifications à effectuer :

1. **Vérifier l'API backend**
   - S'assurer que le serveur backend tourne sur `http://172.21.160.1:5000`
   - Tester l'endpoint : `GET http://172.21.160.1:5000/api/stock-movements`

2. **Vérifier les logs**
   - Ouvrir la console de debug Flutter
   - Rechercher les messages : "Total mouvements: X" et "Types de mouvements: ..."

3. **Types de mouvements supportés**
   - ENTREE / entree
   - SORTIE / sortie
   - creation
   - ajout
   - suppression
   - retrait

4. **Test rapide**
   - Utiliser le bouton "Créer mouvement test" sur la page
   - Vérifier si le mouvement apparaît

5. **Vérifier la base de données**
   - S'assurer que le backend enregistre bien les mouvements
   - Vérifier la table `stock_movements`

### Solutions possibles :

1. **Si l'endpoint 404** : Le backend n'a pas les routes définies
2. **Si aucun mouvement** : Le système d'enregistrement automatique n'est pas activé
3. **Si types incorrects** : Ajuster la logique de filtrage dans `_filterMovements`

### Pour activer l'enregistrement automatique :

Assurez-vous que le backend utilise le `StockLogger` pour enregistrer automatiquement les mouvements lors des modifications de quantité.