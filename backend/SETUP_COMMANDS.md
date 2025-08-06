# 🚀 Commandes pour configurer le backend Keeptex

## 📋 Étapes à suivre dans Trae

### 1. Ouvrir le terminal backend
```bash
cd backend
```

### 2. Installer les dépendances
```bash
npm install
```

### 3. Démarrer le serveur
```bash
npm start
```

### 4. Tester le backend
Ouvrez votre navigateur et allez à :
- http://localhost:5000/api/test
- http://localhost:5000/api/stock-movements

## 🔧 Configuration Flutter

### Désactiver le mode mock
1. Ouvrez `lib/services/StockMovementService.dart`
2. Changez : `bool _useMock = true;` 
3. En : `bool _useMock = false;`

## 📱 URLs de test
- Backend : http://localhost:5000
- API mouvements : http://localhost:5000/api/stock-movements
- API stats : http://localhost:5000/api/stock-movements/stats

## 🎯 Résumé rapide
1. **npm install** → Installe les dépendances
2. **npm start** → Lance le serveur
3. **Mode mock OFF** → Utilise le backend réel

## ✅ Vérification
Après `npm start`, vous devriez voir :
```
🚀 Serveur démarré sur http://localhost:5000
✅ Connexion à la base de données réussie
✅ Base de données synchronisée
📝 Ajout de données de test...
```