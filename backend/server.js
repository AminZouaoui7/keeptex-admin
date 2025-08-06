const express = require('express');
const cors = require('cors');
const { Sequelize, DataTypes } = require('sequelize');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 5000;

// Configuration Sequelize
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './database.sqlite',
  logging: false
});

// Middleware
app.use(cors());
app.use(express.json());

// Modèle StockMovement
const StockMovement = sequelize.define('StockMovement', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
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
  },
  articleId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false
  }
});

// Modèle Article
const Article = sequelize.define('Article', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nom: {
    type: DataTypes.STRING,
    allowNull: false
  },
  quantite: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
});

// Modèle User
const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  }
});

// Associations
StockMovement.belongsTo(Article, { foreignKey: 'articleId' });
StockMovement.belongsTo(User, { foreignKey: 'userId' });

// Middleware d'authentification simplifié
const authenticateToken = (req, res, next) => {
  // Pour le développement, on autorise toutes les requêtes
  next();
};

// Routes StockMovements

// GET /api/stock-movements
app.get('/api/stock-movements', authenticateToken, async (req, res) => {
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

// GET /api/stock-movements/stats
app.get('/api/stock-movements/stats', authenticateToken, async (req, res) => {
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

// POST /api/stock-movements
app.post('/api/stock-movements', authenticateToken, async (req, res) => {
  try {
    const { articleId, type, quantity, oldQuantity, newQuantity, reason } = req.body;
    
    const movement = await StockMovement.create({
      articleId,
      type,
      quantity,
      oldQuantity,
      newQuantity,
      reason,
      userId: 1 // ID par défaut pour le développement
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

// GET /api/articles/:id/movements
app.get('/api/articles/:id/movements', authenticateToken, async (req, res) => {
  try {
    const movements = await StockMovement.findAll({
      where: { articleId: req.params.id },
      include: [
        { model: Article, attributes: ['nom'] },
        { model: User, attributes: ['name'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    
    res.json(movements);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Route de test
app.get('/api/test', (req, res) => {
  res.json({ message: 'Backend Keeptex fonctionne!' });
});

// Initialisation de la base de données
async function initializeDatabase() {
  try {
    await sequelize.authenticate();
    console.log('✅ Connexion à la base de données réussie');
    
    await sequelize.sync({ force: false });
    console.log('✅ Base de données synchronisée');
    
    // Ajouter des données de test si la base est vide
    const articleCount = await Article.count();
    if (articleCount === 0) {
      console.log('📝 Ajout de données de test...');
      const testArticle = await Article.create({ nom: 'Article Test', quantite: 10 });
      const testUser = await User.create({ name: 'Admin Test', email: 'admin@test.com' });
      
      await StockMovement.create({
        type: 'ENTREE',
        quantity: 10,
        oldQuantity: 0,
        newQuantity: 10,
        reason: 'Stock initial',
        articleId: testArticle.id,
        userId: testUser.id
      });
    }
  } catch (error) {
    console.error('❌ Erreur lors de l\'initialisation:', error);
  }
}

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
  console.log(`🌐 Accessible depuis le réseau sur http://172.21.160.1:${PORT}`);
  initializeDatabase();
});