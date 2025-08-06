# Guide de configuration du backend pour les mouvements de stock

## Problème identifié
Les endpoints API suivants n'existent pas sur votre backend :
- `GET /api/stock-movements`
- `GET /api/stock-movements/stats`
- `POST /api/stock-movements`

## Solution 1 : Utiliser le mode démonstration (actuel)
Le mode mock est maintenant activé automatiquement et affiche des données de test.

## Solution 2 : Configurer le backend

### 1. Vérifier que le backend tourne
```bash
# Dans votre dossier backend
npm start
# ou
node server.js
```

### 2. Ajouter les routes nécessaires dans votre backend

#### Route GET /api/stock-movements
```javascript
// routes/stockMovements.js
router.get('/stock-movements', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;
    
    const movements = await StockMovement.findAll({
      include: [
        { model: Article, attributes: ['nom'] },
        { model: User, attributes: ['name'] }
      ],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
    
    res.json(movements);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

#### Route GET /api/stock-movements/stats
```javascript
// routes/stockMovements.js
router.get('/stock-movements/stats', authenticateToken, async (req, res) => {
  try {
    const stats = await StockMovement.findAll({
      attributes: [
        [Sequelize.fn('COUNT', Sequelize.col('id')), 'totalMovements'],
        [Sequelize.fn('SUM', Sequelize.literal("CASE WHEN type = 'ENTREE' THEN 1 ELSE 0 END")), 'totalEntrees'],
        [Sequelize.fn('SUM', Sequelize.literal("CASE WHEN type = 'SORTIE' THEN 1 ELSE 0 END")), 'totalSorties']
      ]
    });
    
    res.json(stats[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

#### Route POST /api/stock-movements
```javascript
// routes/stockMovements.js
router.post('/stock-movements', authenticateToken, async (req, res) => {
  try {
    const { articleId, type, quantity, oldQuantity, newQuantity, reason } = req.body;
    
    const movement = await StockMovement.create({
      articleId,
      type,
      quantity,
      oldQuantity,
      newQuantity,
      reason,
      userId: req.user.id
    });
    
    const fullMovement = await StockMovement.findByPk(movement.id, {
      include: [
        { model: Article, attributes: ['nom'] },
        { model: User, attributes: ['name'] }
      ]
    });
    
    res.status(201).json(fullMovement);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### 3. Vérifier la configuration Sequelize
Assurez-vous que le modèle StockMovement est bien défini :

```javascript
// models/StockMovement.js
const StockMovement = sequelize.define('StockMovement', {
  type: {
    type: DataTypes.ENUM('ENTREE', 'SORTIE'),
    allowNull: false
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  oldQuantity: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  newQuantity: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  reason: {
    type: DataTypes.STRING,
    allowNull: true
  }
});

StockMovement.associate = (models) => {
  StockMovement.belongsTo(models.Article, { foreignKey: 'articleId' });
  StockMovement.belongsTo(models.User, { foreignKey: 'userId' });
};
```

### 4. Activer l'enregistrement automatique
Assurez-vous que le StockLogger est utilisé dans votre backend :

```javascript
// services/stockLogger.js
const StockLogger = {
  async logMovement(articleId, type, quantity, oldQuantity, newQuantity, reason = '') {
    return await StockMovement.create({
      articleId,
      type,
      quantity,
      oldQuantity,
      newQuantity,
      reason,
      userId: 1 // Remplacer par l'utilisateur connecté
    });
  }
};

module.exports = StockLogger;
```

### 5. Tester la connexion
```bash
curl http://localhost:5000/api/stock-movements
```

### 6. Désactiver le mode mock dans l'app Flutter

Quand votre backend est prêt, modifiez StockMovementService.dart :

```dart
// Dans StockMovementService, changez _useMock = true vers _useMock = false
bool _useMock = false; // Désactiver le mode mock
```

## URLs à vérifier
- Backend : http://172.21.160.1:5000
- Stock movements : http://172.21.160.1:5000/api/stock-movements
- Stats : http://172.21.160.1:5000/api/stock-movements/stats

## Messages d'erreur courants
- "Endpoint non trouvé" : Routes manquantes
- "Connection refused" : Backend non démarré
- "Network unreachable" : Mauvaise IP ou firewall